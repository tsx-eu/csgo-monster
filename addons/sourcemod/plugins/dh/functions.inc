
stock bool IsValidClient(int client) {
	if (client <= 0 || client > MaxClients)
		return false;
	
	if (!IsValidEdict(client) || !IsClientConnected(client))
		return false;
	
	return true;
}
stock float Math_Lerp(float a, float b, float n) {
	return (1 - n) * a + n * b;
}
stock float Math_InvLerp(float a, float b, float v) {
	return (v - a) / (b - a);
}
public bool FilterToOne(int entity, int mask, any data) {
	return (data != entity);
}
public bool FilterHostage(int entity, int mask, any data) {
	if( entity <= MaxClients )
		return true;
	if( data == entity || HasEntProp(entity, Prop_Send, "m_nHostageState") )
		return false;
	return true;
}

public bool GetPushawayEnts_enumerator(int entity, any ref) {
	ArrayList data = view_as<ArrayList>(ref);
	data.Push(entity);
	
	return data.Length < data.BlockSize;
}

stock int Entity_GetAttachment(int entity, const char[] name, float pos[3], float ang[3]) {
	int attach = SDKCall(hSDKCallLookupAttachment, entity, name);
	if( attach > 0 )
		SDKCall(hSDKCallGetAttachment, entity, attach, pos, ang); 
	return attach;
}

stock int Entity_TraceMeleeHull(int entity, float src[3], float hit[3]) {
	float ang[3], dst[3], min[3], max[3];
	
	Entity_GetAbsAngles(entity, ang);
	GetAngleVectors(ang, dst, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(dst, 10000.0);
	AddVectors(src, dst, dst);
	
	min[0] = min[1] = min[2] = -MELEE_HULL;
	max[0] = max[1] = max[2] =  MELEE_HULL;
	
	int target = -1;
	Handle trace = TR_TraceHullFilterEx(src, dst, min, max, MASK_SHOT, FilterToOne, entity);
	if( TR_DidHit(trace) ) {
		TR_GetEndPosition(hit, trace);
		target = TR_GetEntityIndex(trace);
	}
	delete trace;
	
	return target;
}
stock bool Entity_IsInSightRange(int client, int target, float angle = 90.0, float distance = 99999.9, bool heightcheck = true) {
	float src[3], dst[3], ang[3], anglevector[3], targetvector[3], min[3], max[3];
	float resultangle, resultdistance;
	
	Entity_GetAbsOrigin(client, src);
	Entity_GetAbsOrigin(target, dst);
	
	// Can be seen
	min[0] = min[1] = min[2] = -MELEE_HULL;
	max[0] = max[1] = max[2] =  MELEE_HULL;
	src[2] += HEIGHT_SIZE;
	dst[2] += HEIGHT_SIZE;	
	Handle trace = TR_TraceHullFilterEx(src, dst, min, max, MASK_SHOT, FilterHostage, client);
	if( TR_DidHit(trace) ) {
		if( TR_GetEntityIndex(trace) != target ) {
			delete trace;
			return false;
		}
	}
	
	// in view angle
	Entity_GetAbsAngles(client, ang);
	ang[0] = ang[2] = 0.0;
	GetAngleVectors(ang, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
		
	if( heightcheck )
		resultdistance = GetVectorDistance(src, dst);
	
	src[2] = dst[2] = 0.0;
	MakeVectorFromPoints(src, dst, targetvector);
	NormalizeVector(targetvector, targetvector);
	
	resultangle = RadToDeg(ArcCosine(GetVectorDotProduct(targetvector, anglevector)));
	
	if( resultangle <= angle / 2.0 ) {
		if( !heightcheck )
			resultdistance = GetVectorDistance(src, dst);
		return distance >= resultdistance;
	}
	
	return false;
}
stock bool Entity_IsAttackAble(int entity) {
	static char classname[128];
	
	if( entity > 0 && entity <= MaxClients )
		return true;
	
	GetEdictClassname(entity, classname, sizeof(classname));
	if( StrEqual(classname, "func_breakable_surf") || StrEqual(classname, "func_breakable") )
		return true;
	
	return false;
}
stock float GetProjectileAngle(float dir[3], float v, float gravity) {
	float v2 = v*v;
	float g = -sv_gravity.FloatValue * gravity;
	
	float x = SquareRoot(dir[0] * dir[0] + dir[1] * dir[1]); // Distance au sol
	float y = -dir[2];										 // Distance en hauteur
	
	if( g == 0.0 )
		g = 0.01;
	if( x == 0.0 )
		x = 0.01;
	
	float delta = (v2*v2) - g * (g*x*x + 2.0*y*v2 );
	if( delta < 0.0 )
		return 45.0;
	
	float neg = (v2-SquareRoot(delta))/(g*x);
	return RadToDeg(ArcTangent(neg));
}
stock int GetPushawayEnts(int entity, int[] ents, int nMaxEnts, float flPlayerExpand=0.0, int PartitionMask=PARTITION_SOLID_EDICTS) {
	static float src[3], min[3], max[3];
	
	Entity_GetAbsOrigin(entity, src);
	Entity_GetMinSize(entity, min);
	Entity_GetMaxSize(entity, max);
		
	if( flPlayerExpand > 0.0 ) {
		for(int i=0; i<3; i++) {
			min[i] -= flPlayerExpand;
			max[i] += flPlayerExpand;
		}
	}
	
	ArrayList data = new ArrayList(nMaxEnts);
	TR_EnumerateEntitiesHull(src, src, min, max, PartitionMask, GetPushawayEnts_enumerator, data);
	int size = nMaxEnts < data.Length ? nMaxEnts : data.Length;

	for(int i=0; i<size; i++) {
		ents[i] = data.Get(i);
	}
	
	delete data;
	return size;
}

