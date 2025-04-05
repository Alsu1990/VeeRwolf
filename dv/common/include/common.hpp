
#pragma once
#include "verilated.h"
#include <vector>

class SimElement {
public:
    virtual ~SimElement() { }
    virtual void onReset() { }
    virtual void postReset() { }
    virtual void preCycle() { }
    virtual void postCycle() { }
};

class TimeProcess {
public:
    uint64_t wakeDelay;
    bool wakeEnable;
    virtual ~TimeProcess() { }
    virtual void schedule(uint64_t delay);
    virtual void tick();
};

class SensitiveProcess {
public:
    virtual ~SensitiveProcess() { }
    virtual void tick(uint64_t time) { }
};

class AsyncReset : public TimeProcess {
public:
    CData* reset;
    uint32_t state;
    uint64_t duration;
    AsyncReset(CData* reset, uint64_t duration);

    virtual void tick();
};

class ClockDomain : public TimeProcess {
public:
    CData* clk;
    CData* reset;
    uint64_t tooglePeriod;
    std::vector<SimElement*> simElements;

    // Constructor
    ClockDomain(CData* clk, CData* reset, uint64_t period, uint64_t delay);

    // Methods
    virtual void tick();
    void add(SimElement* that);

private:
    bool postCycle = false;
};
