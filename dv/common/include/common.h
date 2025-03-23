
#pragma once

#include "verilated_fst_c.h"

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
    uint64_t wakeDelay = 0;
    bool wakeEnable = false;
    virtual ~TimeProcess() { }
    virtual void schedule(uint64_t delay)
    {
        wakeDelay = delay;
        wakeEnable = true;
    }
    virtual void tick() { }
};

class SensitiveProcess {
public:
    virtual ~SensitiveProcess() { }
    virtual void tick(uint64_t time) { }
};
