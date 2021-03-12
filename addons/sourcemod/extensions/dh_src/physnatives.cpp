#include "extension.h"
#include "vphysics_interface.h"
#include "vphysics/constraints.h"

#include "physnatives.h"

static cell_t IsPhysicsObject(IPluginContext *pContext, const cell_t *params)
{
	return (params[1] > 0 && params[1] < gpGlobals->maxEntities && GetPhysicsObject(params[1]))?1:0;
}
////////////////////////////////////////////////////////
static cell_t SetMass(IPluginContext *pContext, const cell_t *params)
{
	IPhysicsObject *m_pPhysicsObject = GetPhysicsObject(params[1]);

	if (!m_pPhysicsObject) {
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	m_pPhysicsObject->SetMass(sp_ctof(params[2]));

	return 1;
}

static cell_t GetMass(IPluginContext *pContext, const cell_t *params)
{
	IPhysicsObject *m_pPhysicsObject = GetPhysicsObject(params[1]);

	if (!m_pPhysicsObject) {
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	return sp_ftoc(m_pPhysicsObject->GetMass());
}
////////////////////////////////////////////////////////
/*
static cell_t GetOBBMins(IPluginContext *pContext, const cell_t *params)
{
	edict_t *pEdict = PEntityOfEntIndex(gamehelpers->ReferenceToIndex(params[1]));
	if (!pEdict || pEdict->IsFree()) {
		return pContext->ThrowNativeError("Entity %d is invalid", params[1]);
	}

        Vector min = pEdict->GetCollideable()->OBBMins();

        cell_t *addr;
        pContext->LocalToPhysAddr(params[2], &addr);
        addr[0] = sp_ftoc(min.x);
        addr[1] = sp_ftoc(min.y);
        addr[2] = sp_ftoc(min.z);

        return 1;
}
static cell_t GetOBBMaxs(IPluginContext *pContext, const cell_t *params)
{
        edict_t *pEdict = PEntityOfEntIndex(gamehelpers->ReferenceToIndex(params[1]));
        if (!pEdict || pEdict->IsFree()) {
                return pContext->ThrowNativeError("Entity %d is invalid", params[1]);
        }

        Vector max = pEdict->GetCollideable()->OBBMaxs();

        cell_t *addr;
        pContext->LocalToPhysAddr(params[2], &addr);
        addr[0] = sp_ftoc(max.x);
        addr[1] = sp_ftoc(max.y);
        addr[2] = sp_ftoc(max.z);

        return 1;
}
*/
////////////////////////////////////////////////////////
IPhysicsObject *GetPhysicsObject(int iEntityIndex)
{
	CBaseEntity *pEntity = PEntityOfEntIndex(iEntityIndex)->GetUnknown()->GetBaseEntity();

	if (pEntity)
	{
		return GetPhysicsObject(pEntity);
	} else {
		return NULL;
	}
}
IPhysicsObject *GetPhysicsObject(CBaseEntity *pEntity)
{
	datamap_t *data = gamehelpers->GetDataMap(pEntity);

	if (!data) 
	{
		return NULL;
	}

	typedescription_t *type = gamehelpers->FindInDataMap(data, "m_pPhysicsObject");

	if (!type)
	{
		return NULL;
	}

#if SOURCE_ENGINE >= SE_LEFT4DEAD
	return *(IPhysicsObject **)((char *)pEntity + type->fieldOffset);
#else
	return *(IPhysicsObject **)((char *)pEntity + type->fieldOffset[TD_OFFSET_NORMAL]);
#endif
}

BEGIN_NATIVES(Phys)
	ADD_NATIVE(Phys, IsPhysicsObject)
	ADD_NATIVE(Phys, SetMass)
	ADD_NATIVE(Phys, GetMass)
END_NATIVES()
