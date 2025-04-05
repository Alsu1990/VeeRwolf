#include "verilated.h"

class success : public std::exception { };
template <class T>
class Workspace {
public:
    vector<TimeProcess*> timeProcesses;
    vector<SensitiveProcess*> checkProcesses;
    T* top;
    bool resetDone = false;
    double timeToSec = 1e-12;
    double speedFactor = 1.0;
    uint64_t allowedTime = 0;
    string name;
    uint64_t time = 0;
#ifdef TRACE
    VerilatedFstC* tfp;
#endif

    ofstream logTraces;

    Workspace(string name)
    {
        this->name = name;
        top = new T;
        logTraces.open(name + ".logTrace");
    }

    virtual ~Workspace()
    {
        delete top;
#ifdef TRACE
        delete tfp;
#endif

        for (auto* p : timeProcesses)
            delete p;
        for (auto* p : checkProcesses)
            delete p;
    }

    Workspace* setSpeedFactor(double value)
    {
        speedFactor = value;
        return this;
    }

    virtual void postReset() { }
    virtual void checks() { }
    virtual void pass() { throw success(); }
    virtual void fail() { throw std::exception(); }

    virtual void dump(uint64_t i)
    {
#ifdef TRACE
        if (i >= TRACE_START)
            tfp->dump(i);
#endif
    }

    Workspace* run(double timeout = 1e6)
    {

// init trace dump
#ifdef TRACE
        Verilated::traceEverOn(true);
        tfp = new VerilatedFstC;
        top->trace(tfp, 99);
        tfp->open((string(name) + ".fst").c_str());
#endif

        struct timespec start_time, tick_time;
        uint64_t tickLastSimTime = 0;
        top->eval();

        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start_time);
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &tick_time);

        uint32_t flushCounter = 0;
        try {
            while (1) {
                uint64_t delay = ~0l;
                for (TimeProcess* p : timeProcesses)
                    if (p->wakeEnable && p->wakeDelay < delay)
                        delay = p->wakeDelay;

                if (time * timeToSec > timeout) {
                    printf("Simulation timeout triggered (%f)\n", time * timeToSec);
                    fail();
                }
                if (delay == ~0l) {
                    fail();
                }
                if (delay != 0) {
                    dump(time);
                }
                for (TimeProcess* p : timeProcesses) {
                    p->wakeDelay -= delay;
                    if (p->wakeDelay == 0) {
                        p->wakeEnable = false;
                        p->tick();
                    }
                }

                top->eval();
                for (auto* p : checkProcesses)
                    p->tick(time);

                if (delay != 0) {
                    if (time - tickLastSimTime > 1000 * 400000 || time - tickLastSimTime > 1.0 * speedFactor / timeToSec) {
                        struct timespec end_time;
                        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &end_time);
                        uint64_t diffInNanos = end_time.tv_sec * 1e9 + end_time.tv_nsec - tick_time.tv_sec * 1e9 - tick_time.tv_nsec;
                        tick_time = end_time;
                        double dt = diffInNanos * 1e-9;
#ifdef PRINT_PERF
                        printf("Simulation speed : %f ms/realTime\n", (time - tickLastSimTime) / dt * timeToSec * 1e3);
#endif
                        tickLastSimTime = time;
                    }
                    time += delay;
                    while (allowedTime < delay) {
                        struct timespec end_time;
                        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &end_time);
                        uint64_t diffInNanos = end_time.tv_sec * 1e9 + end_time.tv_nsec - start_time.tv_sec * 1e9 - start_time.tv_nsec;
                        start_time = end_time;
                        double dt = diffInNanos * 1e-9;
                        allowedTime += dt * speedFactor / timeToSec;
                        if (allowedTime > 0.01 * speedFactor / timeToSec)
                            allowedTime = 0.01 * speedFactor / timeToSec;
                    }
                    allowedTime -= delay;

                    flushCounter++;
                    if (flushCounter > 100000) {
#ifdef TRACE
                        tfp->flush();
// printf("flush\n");
#endif
                        flushCounter = 0;
                    }
                }

                if (Verilated::gotFinish())
                    exit(0);
            }
            cout << "timeout" << endl;
            fail();
        } catch (const success e) {
            cout << "SUCCESS " << name << endl;
        } catch (const std::exception& e) {
            cout << "FAIL " << name << endl;
        }

        dump(time);
        dump(time + 10);
#ifdef TRACE
        tfp->close();
#endif
        return this;
    }
};
