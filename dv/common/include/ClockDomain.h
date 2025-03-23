#pragma once

#include "common.h"
#include "verilated.h"
#include <vector>

class ClockDomain : public TimeProcess {

public:
    // Members
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
