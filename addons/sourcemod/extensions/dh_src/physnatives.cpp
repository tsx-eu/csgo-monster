#include "extension.h"

#include "vphysics_interface.h"
#include "vphysics/constraints.h"

#include "physnatives.h"
#include "physhandles.h"

static cell_t IsPhysicsObject(IPluginContext *pContext, const cell_t *params)
{
	return (params[1] > 0 && params[1] < gpGlobals->maxEntities && GetPhysicsObject(params[1]))?1:0;
}
////////////////////////////////////////////////////////
static cell_t SetMass(IPluginContext *pContext, const cell_t *params)
{
	IPhysicsObject *m_pPhysicsObject = GetPhysicsObject(params[1]);

	if(!m_pPhysicsObject) {
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	m_pPhysicsObject->SetMass(sp_ctof(params[2]));

	return 1;
}

static cell_t GetMass(IPluginContext *pContext, const cell_t *params)
{
	IPhysicsObject *m_pPhysicsObject = GetPhysicsObject(params[1]);

	if(!m_pPhysicsObject) {
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	return sp_ftoc(m_pPhysicsObject->GetMass());
}
////////////////////////////////////////////////////////
static cell_t GetWorldSpaceCenter(IPluginContext *pContext, const cell_t *params)
{
	edict_t *pEdict = PEntityOfEntIndex(gamehelpers->ReferenceToIndex(params[1]));
	if (!pEdict || pEdict->IsFree()) {
		return pContext->ThrowNativeError("Entity %d is invalid", params[1]);
	}


	ICollideable* pCollidable = pEdict->GetCollideable();

	Vector res;
	Vector pos = pCollidable->GetCollisionOrigin();
	Vector center = (pCollidable->OBBMins() + pCollidable->OBBMaxs()) * 0.5f;

	if( ( pCollidable->GetCollisionAngles() == vec3_angle ) || ( center == vec3_origin ) ) {
		res = pos + center;
	}
	else {
		VectorTransform(center, pCollidable->CollisionToWorldTransform(), res);
	}

	cell_t *addr;
	pContext->LocalToPhysAddr(params[2], &addr);
	addr[0] = sp_ftoc(res.x);
	addr[1] = sp_ftoc(res.y);
	addr[2] = sp_ftoc(res.z);

	return 1;
}
static cell_t LocalToWorld(IPluginContext *pContext, const cell_t *params)
{
	IPhysicsEnvironment *pPhysicsEnvironment = iphysics->GetActiveEnvironmentByIndex(0);

	if (!pPhysicsEnvironment)
	{
		return pContext->ThrowNativeError("IPhysicsEnvironment null.");
	}

	IPhysicsObject *pObject = GetPhysicsObject(params[1]);

	if (!pObject)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	cell_t *addr;
	pContext->LocalToPhysAddr(params[3], &addr);

	Vector inputVec = Vector(sp_ctof(addr[0]), sp_ctof(addr[1]), sp_ctof(addr[2]));
	Vector outputVec;

	pObject->LocalToWorld(&outputVec, inputVec);

	cell_t *addr2;
	pContext->LocalToPhysAddr(params[2], &addr2);
	addr2[0] = sp_ftoc(outputVec.x);
	addr2[1] = sp_ftoc(outputVec.y);
	addr2[2] = sp_ftoc(outputVec.z);

	return 1;
}

static cell_t WorldToLocal(IPluginContext *pContext, const cell_t *params)
{
	IPhysicsEnvironment *pPhysicsEnvironment = iphysics->GetActiveEnvironmentByIndex(0);

	if (!pPhysicsEnvironment)
	{
		return pContext->ThrowNativeError("IPhysicsEnvironment null.");
	}

	IPhysicsObject *pObject = GetPhysicsObject(params[1]);

	if (!pObject)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	cell_t *addr;
	pContext->LocalToPhysAddr(params[3], &addr);

	Vector inputVec = Vector(sp_ctof(addr[0]), sp_ctof(addr[1]), sp_ctof(addr[2]));
	Vector outputVec;

	pObject->WorldToLocal(&outputVec, inputVec);

	cell_t *addr2;
	pContext->LocalToPhysAddr(params[2], &addr2);
	addr2[0] = sp_ftoc(outputVec.x);
	addr2[1] = sp_ftoc(outputVec.y);
	addr2[2] = sp_ftoc(outputVec.z);

	return 1;
}
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

	if (!data) {
		return NULL;
	}

	typedescription_t *type = gamehelpers->FindInDataMap(data, "m_pPhysicsObject");

	if (!type) {
		return NULL;
	}

#if SOURCE_ENGINE >= SE_LEFT4DEAD
	return *(IPhysicsObject **)((char *)pEntity + type->fieldOffset);
#else
	return *(IPhysicsObject **)((char *)pEntity + type->fieldOffset[TD_OFFSET_NORMAL]);
#endif
}
static cell_t CreateConstraintGroup(IPluginContext *pContext, const cell_t *params)
{
	if (!iphysics)
	{
		return pContext->ThrowNativeError("IPhysics null.");
	}

	IPhysicsEnvironment *pPhysicsEnvironment = iphysics->GetActiveEnvironmentByIndex(0);

	if (!pPhysicsEnvironment)
	{
		return pContext->ThrowNativeError("IPhysicsEnvironment null.");
	}

	constraint_groupparams_t constraintgroup;

	constraintgroup.additionalIterations = params[1];
	constraintgroup.minErrorTicks = params[2];
	constraintgroup.errorTolerance = sp_ctof(params[3]);

	IPhysicsConstraintGroup *pConstraintGroup = pPhysicsEnvironment->CreateConstraintGroup(constraintgroup);

	RETURN_NEW_HANDLE(ConstraintGroup, pConstraintGroup);
}
static cell_t CreateSpring(IPluginContext *pContext, const cell_t *params)
{
	if (!iphysics)
	{
		return pContext->ThrowNativeError("IPhysics null.");
	}

	IPhysicsEnvironment *pPhysicsEnvironment = iphysics->GetActiveEnvironmentByIndex(0);

	if (!pPhysicsEnvironment)
	{
		return pContext->ThrowNativeError("IPhysicsEnvironment null.");
	}

	IPhysicsObject *pObjectStart = GetPhysicsObject(params[1]);

	if (!pObjectStart)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	IPhysicsObject *pObjectEnd = GetPhysicsObject(params[2]);

	if (!pObjectEnd)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[2]);
	}

	springparams_t spring;

	cell_t *cellStartPos;
	pContext->LocalToPhysAddr(params[3], &cellStartPos);
	spring.startPosition = Vector(sp_ctof(cellStartPos[0]), sp_ctof(cellStartPos[1]), sp_ctof(cellStartPos[2]));

	cell_t *cellEndPos;
	pContext->LocalToPhysAddr(params[4], &cellEndPos);
	spring.endPosition = Vector(sp_ctof(cellEndPos[0]), sp_ctof(cellEndPos[1]), sp_ctof(cellEndPos[2]));

	spring.useLocalPositions = (params[5] > 0)?true:false;

	spring.naturalLength = sp_ctof(params[6]);

	spring.constant = sp_ctof(params[7]);
	spring.damping = sp_ctof(params[8]);
	spring.relativeDamping = sp_ctof(params[9]);

	spring.onlyStretch = (params[10] > 0)?true:false;

	IPhysicsSpring *pSpring = pPhysicsEnvironment->CreateSpring(pObjectStart, pObjectEnd, &spring);

	RETURN_NEW_HANDLE(Spring, pSpring);
}
static cell_t CreateFixedConstraint(IPluginContext *pContext, const cell_t *params)
{
	if (!iphysics)
	{
		return pContext->ThrowNativeError("IPhysics null.");
	}

	IPhysicsEnvironment *pPhysicsEnvironment = iphysics->GetActiveEnvironmentByIndex(0);

	if (!pPhysicsEnvironment)
	{
		return pContext->ThrowNativeError("IPhysicsEnvironment null.");
	}

	IPhysicsObject *pReferenceObject = GetPhysicsObject(params[1]);

	if (!pReferenceObject)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	IPhysicsObject *pAttachedObject = GetPhysicsObject(params[2]);

	if (!pAttachedObject)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[2]);
	}

	IPhysicsConstraintGroup *pConstraintGroup = NULL;
	GET_POINTER_FROM_HANDLE(ConstraintGroup, 3, pConstraintGroup);

	constraint_fixedparams_t fixedconstraint;

	fixedconstraint.InitWithCurrentObjectState(pReferenceObject, pAttachedObject);

	fixedconstraint.constraint.strength = sp_ctof(params[4]);
	fixedconstraint.constraint.forceLimit = sp_ctof(params[5]);
	fixedconstraint.constraint.torqueLimit = sp_ctof(params[6]);

	fixedconstraint.constraint.bodyMassScale[0] = sp_ctof(params[7]);
	fixedconstraint.constraint.bodyMassScale[1] = sp_ctof(params[8]);

	fixedconstraint.constraint.isActive = (params[9] > 0)?true:false;

	IPhysicsConstraint *pConstraint = pPhysicsEnvironment->CreateFixedConstraint(pReferenceObject, pAttachedObject, pConstraintGroup, fixedconstraint);

	RETURN_NEW_HANDLE(Constraint, pConstraint);
}

static cell_t CreateLengthConstraint(IPluginContext *pContext, const cell_t *params)
{
	if (!iphysics)
	{
		return pContext->ThrowNativeError("IPhysics null.");
	}

	IPhysicsEnvironment *pPhysicsEnvironment = iphysics->GetActiveEnvironmentByIndex(0);

	if (!pPhysicsEnvironment)
	{
		return pContext->ThrowNativeError("IPhysicsEnvironment null.");
	}

	IPhysicsObject *pReferenceObject = GetPhysicsObject(params[1]);

	if (!pReferenceObject)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	IPhysicsObject *pAttachedObject = GetPhysicsObject(params[2]);

	if (!pAttachedObject)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[2]);
	}

	IPhysicsConstraintGroup *pConstraintGroup = NULL;
	GET_POINTER_FROM_HANDLE(ConstraintGroup, 3, pConstraintGroup);

	constraint_lengthparams_t lengthconstraint;

	cell_t *refPosition;
	pContext->LocalToPhysAddr(params[4], &refPosition);
	//pReferenceObject->WorldToLocal(&lengthconstraint.objectPosition[0], Vector(sp_ctof(refPosition[0]), sp_ctof(refPosition[1]), sp_ctof(refPosition[2])));
	lengthconstraint.objectPosition[0] = Vector(sp_ctof(refPosition[0]), sp_ctof(refPosition[1]), sp_ctof(refPosition[2]));

	cell_t *attachedPosition;
	pContext->LocalToPhysAddr(params[5], &attachedPosition);
	//pAttachedObject->WorldToLocal(&lengthconstraint.objectPosition[1], Vector(sp_ctof(attachedPosition[0]), sp_ctof(attachedPosition[1]), sp_ctof(attachedPosition[2])));
	lengthconstraint.objectPosition[1] = Vector(sp_ctof(attachedPosition[0]), sp_ctof(attachedPosition[1]), sp_ctof(attachedPosition[2]));

	lengthconstraint.totalLength = sp_ctof(params[6]);
	lengthconstraint.minLength = sp_ctof(params[7]);

	lengthconstraint.constraint.strength = sp_ctof(params[8]);
	lengthconstraint.constraint.forceLimit = sp_ctof(params[9]);
	lengthconstraint.constraint.torqueLimit = sp_ctof(params[10]);

	lengthconstraint.constraint.bodyMassScale[0] = sp_ctof(params[11]);
	lengthconstraint.constraint.bodyMassScale[1] = sp_ctof(params[12]);

	lengthconstraint.constraint.isActive = (params[13] > 0)?true:false;

	IPhysicsConstraint *pConstraint = pPhysicsEnvironment->CreateLengthConstraint(pReferenceObject, pAttachedObject, pConstraintGroup, lengthconstraint);

	RETURN_NEW_HANDLE(Constraint, pConstraint);
}

static cell_t CreateHingeConstraint(IPluginContext *pContext, const cell_t *params)
{
	if (!iphysics)
	{
		return pContext->ThrowNativeError("IPhysics null.");
	}

	IPhysicsEnvironment *pPhysicsEnvironment = iphysics->GetActiveEnvironmentByIndex(0);

	if (!pPhysicsEnvironment)
	{
		return pContext->ThrowNativeError("IPhysicsEnvironment null.");
	}

	IPhysicsObject *pReferenceObject = GetPhysicsObject(params[1]);

	if (!pReferenceObject)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[1]);
	}

	IPhysicsObject *pAttachedObject = GetPhysicsObject(params[2]);

	if (!pAttachedObject)
	{
		return pContext->ThrowNativeError("IPhysicsObject for entity %d null.", params[2]);
	}

	IPhysicsConstraintGroup *pConstraintGroup = NULL;
	GET_POINTER_FROM_HANDLE(ConstraintGroup, 3, pConstraintGroup);

	constraint_hingeparams_t hingeconstraint;

	cell_t *worldPosition;
	pContext->LocalToPhysAddr(params[4], &worldPosition);
	hingeconstraint.worldPosition = Vector(sp_ctof(worldPosition[0]), sp_ctof(worldPosition[1]), sp_ctof(worldPosition[2]));

	cell_t *worldAxisDirection;
	pContext->LocalToPhysAddr(params[5], &worldAxisDirection);
	hingeconstraint.worldAxisDirection = Vector(sp_ctof(worldAxisDirection[0]), sp_ctof(worldAxisDirection[1]), sp_ctof(worldAxisDirection[2]));

	hingeconstraint.hingeAxis.minRotation = sp_ctof(params[6]);
	hingeconstraint.hingeAxis.maxRotation = sp_ctof(params[7]);
	hingeconstraint.hingeAxis.angularVelocity = sp_ctof(params[8]);
	hingeconstraint.hingeAxis.torque = sp_ctof(params[9]);

	hingeconstraint.constraint.strength = sp_ctof(params[10]);
	hingeconstraint.constraint.forceLimit = sp_ctof(params[11]);
	hingeconstraint.constraint.torqueLimit = sp_ctof(params[12]);

	hingeconstraint.constraint.bodyMassScale[0] = sp_ctof(params[13]);
	hingeconstraint.constraint.bodyMassScale[1] = sp_ctof(params[14]);

	hingeconstraint.constraint.isActive = (params[15] > 0)?true:false;

	IPhysicsConstraint *pConstraint = pPhysicsEnvironment->CreateHingeConstraint(pReferenceObject, pAttachedObject, pConstraintGroup, hingeconstraint);

	RETURN_NEW_HANDLE(Constraint, pConstraint);
}

BEGIN_NATIVES(Phys)
	ADD_NATIVE(Phys, IsPhysicsObject)
	ADD_NATIVE(Phys, SetMass)
	ADD_NATIVE(Phys, GetMass)
	ADD_NATIVE(Phys, GetWorldSpaceCenter)

	ADD_NATIVE(Phys, LocalToWorld)
	ADD_NATIVE(Phys, WorldToLocal)

	ADD_NATIVE(Phys, CreateSpring)

	ADD_NATIVE(Phys, CreateConstraintGroup)
	ADD_NATIVE(Phys, CreateFixedConstraint)
	ADD_NATIVE(Phys, CreateLengthConstraint)
	ADD_NATIVE(Phys, CreateHingeConstraint)
END_NATIVES()
