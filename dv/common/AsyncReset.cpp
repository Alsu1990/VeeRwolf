#include "AsyncReset.h"

AsyncReset::AsyncReset(CData* reset, uint64_t duration)
{
    this->reset = reset;
    this->state = 0;
    this->duration = duration;
    schedule(0);
}
