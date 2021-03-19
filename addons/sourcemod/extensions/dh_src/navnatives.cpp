#include "extension.h"

#include "navnatives.h"


static cell_t Load(IPluginContext* pContext, const cell_t* params) {
    return (Load());
}
static cell_t GetArea(IPluginContext* pContext, const cell_t* params) {
    float pos[3];
    cell_t* addr;

    pContext->LocalToPhysAddr(params[1], &addr);
    pos[0] = sp_ctof(addr[0]);
    pos[1] = sp_ctof(addr[1]);
    pos[2] = sp_ctof(addr[2]);

    return GetAreaIdFromWorldPosition(pos);
}

BEGIN_NATIVES(Nav)
	ADD_NATIVE(Nav, Load)
	ADD_NATIVE(Nav, GetArea)
END_NATIVES()
