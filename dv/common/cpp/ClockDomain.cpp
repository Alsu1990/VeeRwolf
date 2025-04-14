#include "ClockDomain.h"

ClockDomain::ClockDomain(CData* clk, CData* reset, uint64_t period, uint64_t delay)
{
    this->clk = clk;
    this->reset = reset;
    *clk = 0;
    this->tooglePeriod = period / 2;
    schedule(delay);
}

void ClockDomain::tick()
{

    if (*clk == 0) {
        for (SimElement* simElement : simElements) {
            simElement->preCycle();
        }
        postCycle = true;
        *clk = 1;
        schedule(0);
    } else {
        if (postCycle) {
            postCycle = false;
            for (SimElement* simElement : simElements) {
                simElement->postCycle();
            }
        } else {
            *clk = 0;
        }
        schedule(tooglePeriod);
    }
}

void ClockDomain::add(SimElement* that)
{
    simElements.push_back(that);
}
