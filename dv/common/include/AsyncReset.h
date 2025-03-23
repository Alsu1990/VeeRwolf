
#include "common.h"

class AsyncReset : public TimeProcess {
public:
    CData* reset;
    uint32_t state;
    uint64_t duration;
    AsyncReset(CData* reset, uint64_t duration);

    virtual void tick();
};
