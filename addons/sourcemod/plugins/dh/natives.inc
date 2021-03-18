
void Native_REGISTER() {
	CreateNative("DH_Create", 				Native_DH_Create);
	CreateNative("DH_Spawn", 				Native_DH_Spawn);
	
	CreateNative("DH_SetClassInt", 			Native_DH_SetClassInt);
	CreateNative("DH_GetClassInt", 			Native_DH_GetClassInt);
	CreateNative("DH_SetClassFloat",		Native_DH_SetClassFloat);
	CreateNative("DH_GetClassFloat", 		Native_DH_GetClassFloat);
	CreateNative("DH_SetClassString", 		Native_DH_SetClassString);
	CreateNative("DH_GetClassString", 		Native_DH_GetClassString);
	
	CreateNative("DH_SetInstanceInt", 		Native_DH_SetInstanceInt);
	CreateNative("DH_GetInstanceInt", 		Native_DH_GetInstanceInt);
	CreateNative("DH_SetInstanceFloat",		Native_DH_SetInstanceFloat);
	CreateNative("DH_GetInstanceFloat", 	Native_DH_GetInstanceFloat);
	CreateNative("DH_SetInstanceString", 	Native_DH_SetInstanceString);
	CreateNative("DH_GetInstanceString", 	Native_DH_GetInstanceString);
	
	CreateNative("DH_RegisterAnimation", 	Native_DH_RegisterAnimation);
}
public int Native_DH_Create(Handle plugin, int numParams) {
	GetNativeString(1, g_szClass[g_iClassCount][NPC_szFullName], sizeof(g_szClass[][]));
	GetNativeString(2, g_szClass[g_iClassCount][NPC_szName], sizeof(g_szClass[][]));
	GetNativeString(3, g_szClass[g_iClassCount][NPC_szModel], sizeof(g_szClass[][]));
	
	return g_iClassCount++;
}
public int Native_DH_Spawn(Handle plugin, int numParams) {
	static char tmp[32];
	Format(tmp, sizeof(tmp), "!self,Kill,,%f,-1", 30.0);
	
	float pos[3], ang[3];
	int id = GetNativeCell(1);
	NPCClass class = view_as<NPCClass>(id);
	
	GetNativeArray(2, pos, sizeof(pos));
	GetNativeArray(3, ang, sizeof(ang));
	
	int entity = CreateEntityByName("hostage_entity");
	DispatchKeyValue(entity, "model", g_szClass[id][NPC_szModel]);
	DispatchKeyValue(entity, "OnUser1", tmp);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	TeleportEntity(entity, pos, ang, NULL_VECTOR);
	
}
// ---------------------------------------------------------------------------------------------------------
// GetSet Class:
public any Native_DH_SetClassInt(Handle plugin, int numParams) {
	g_iClass[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
}
public any Native_DH_GetClassInt(Handle plugin, int numParams) {
	return g_iClass[GetNativeCell(1)][GetNativeCell(2)];
}
public any Native_DH_SetClassFloat(Handle plugin, int numParams) {
	g_flClass[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
}
public any Native_DH_GetClassFloat(Handle plugin, int numParams) {
	return g_flClass[GetNativeCell(1)][GetNativeCell(2)];
}
public any Native_DH_SetClassString(Handle plugin, int numParams) {
	GetNativeString(3, g_szClass[GetNativeCell(1)][GetNativeCell(2)], sizeof(g_szClass[][]));
}
public any Native_DH_GetClassString(Handle plugin, int numParams) {
	SetNativeString(3, g_szClass[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));
}
// GetSet Instance:
public any Native_DH_SetInstanceInt(Handle plugin, int numParams) {
	g_iInstance[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
}
public any Native_DH_GetInstanceInt(Handle plugin, int numParams) {
	return g_iInstance[GetNativeCell(1)][GetNativeCell(2)];
}
public any Native_DH_SetInstanceFloat(Handle plugin, int numParams) {
	g_flInstance[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
}
public any Native_DH_GetInstanceFloat(Handle plugin, int numParams) {
	return g_flInstance[GetNativeCell(1)][GetNativeCell(2)];
}
public any Native_DH_SetInstanceString(Handle plugin, int numParams) {
	GetNativeString(3, g_szInstance[GetNativeCell(1)][GetNativeCell(2)], sizeof(g_szInstance[][]));
}
public any Native_DH_GetInstanceString(Handle plugin, int numParams) {
	SetNativeString(3, g_szInstance[GetNativeCell(1)][GetNativeCell(2)], GetNativeCell(4));
}
public any Native_DH_RegisterAnimation(Handle plugin, int numParams) {
	int id = GetNativeCell(1);
	int data = GetNativeCell(2);
	int cpt = g_anClass[id][data][0].seq + 1;
	
	g_anClass[id][data][cpt].seq = GetNativeCell(3);
	g_anClass[id][data][cpt].frames = GetNativeCell(4);
	g_anClass[id][data][cpt].fps = GetNativeCell(5);
	
	g_anClass[id][data][0].seq = cpt;
}
public any Native_DH_RegisterAttack(Handle plugin, int numParams) {
	int id = GetNativeCell(1);
	int cpt = g_iClass[id][NPC_iAttackCount];
	
	g_atClass[id][cpt].type = GetNativeCell(2);
	g_atClass[id][cpt].damage = GetNativeCell(3);
	g_atClass[id][cpt].range = GetNativeCell(4);
	
	g_iClass[id][NPC_iAttackCount] = cpt + 1;
}