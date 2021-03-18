
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
public bool GetPushawayEnts_enumerator(int entity, any ref) {
	ArrayList data = view_as<ArrayList>(ref);
	data.Push(entity);
	
	return data.Length < data.BlockSize;
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