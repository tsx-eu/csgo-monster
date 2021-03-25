
APLRes Native_REGISTER() {
	CreateNative("DH_Create", 				Native_DH_Create);
	CreateNative("DH_Spawn", 				Native_DH_Spawn);
	CreateNative("DH_GetClass", 			Native_DH_GetClass);
	
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
	CreateNative("DH_HasAnimation", 		Native_DH_HasAnimation);
	CreateNative("DH_RegisterAttack", 		Native_DH_RegisterAttack);
	CreateNative("DH_RegisterHook", 		Native_DH_RegisterHook);
	CreateNative("DH_RegisterPose", 		Native_DH_RegisterPose);
	
	CreateNative("DH_Animate", 				Native_DH_Animate);
	CreateNative("DH_Gesture", 				Native_DH_Gesture);
	CreateNative("DH_Pose", 				Native_DH_Pose);
	
	RegPluginLibrary("DH-CORE"); 
	return APLRes_Success;
}
public int Native_DH_Create(Handle plugin, int numParams) {
	int id = g_iClassCount;
	
	GetNativeString(1, g_szClass[id][NPC_szFullName], sizeof(g_szClass[][]));
	GetNativeString(2, g_szClass[id][NPC_szName], sizeof(g_szClass[][]));
	GetNativeString(3, g_szClass[id][NPC_szModel], sizeof(g_szClass[][]));
	
	view_as<PrivateForward>(g_hClass[id][NPC_EVENT_SPAWN]) = CreateForward(ET_Hook, Param_Cell);					// void(NPCInstance entity)
	view_as<PrivateForward>(g_hClass[id][NPC_EVENT_ATTACK]) = CreateForward(ET_Hook, Param_Cell, Param_Cell);		// void(NPCInstance entity, int attack_id)
	view_as<PrivateForward>(g_hClass[id][NPC_EVENT_DEAD]) = CreateForward(ET_Hook, Param_Cell);						// void(NPCInstance entity)
	
	g_hNamedIdentified.SetValue(g_szClass[id][NPC_szName], id);
	
	return g_iClassCount++;
}

#define EF_BONEMERGE                (1 << 0)
#define EF_NOSHADOW                 (1 << 4)
#define EF_NODRAW         			(1 << 5)
#define EF_NORECEIVESHADOW          (1 << 6)
#define EF_PARENT_ANIMATES          (1 << 9)

public int Native_DH_Spawn(Handle plugin, int numParams) {
	static char tmp[32];
	Format(tmp, sizeof(tmp), "!self,Kill,,%f,-1", 30.0);
	
	float pos[3], ang[3];
	int id = GetNativeCell(1);
	
	GetNativeArray(2, pos, sizeof(pos));
	GetNativeArray(3, ang, sizeof(ang));
	
	int entity = CreateEntityByName("hostage_entity");
	DispatchKeyValue(entity, "OnUser1", tmp);
	DispatchSpawn(entity);
	
	SetEntityModel(entity, g_szClass[id][NPC_szModel]);
	ActivateEntity(entity);
	TeleportEntity(entity, pos, ang, NULL_VECTOR);
	
	SetEntProp(entity, Prop_Send, "m_nHostageState", 3);
	SetEntProp(entity, Prop_Send, "m_bClientSideAnimation", 0);
	g_iInstance[entity][NPC_iClass] = id;
	
	
	int child = CreateEntityByName("monster_generic");
	DispatchKeyValue(child, "model", g_szClass[id][NPC_szModel]);
	DispatchSpawn(child);
	ActivateEntity(child);
	SetEntProp(child, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_NORECEIVESHADOW|EF_PARENT_ANIMATES);	
	SetEntProp(child, Prop_Send, "m_nBody", GetRandomInt(g_iClass[id][NPC_iMinBody], g_iClass[id][NPC_iMaxBody]));
	SetEntProp(child, Prop_Send, "m_nSkin", GetRandomInt(g_iClass[id][NPC_iMinSkin], g_iClass[id][NPC_iMaxSkin]));
	SetEntProp(child, Prop_Data, "m_lifeState", 2);
	SetEntProp(entity, Prop_Send, "m_bClientSideAnimation", 0);
	
	TeleportEntity(child, pos, ang, NULL_VECTOR);
	SetVariantString("!activator");
	AcceptEntityInput(child, "SetParent", entity);	

	g_iInstance[entity][NPC_iAnimator] = EntIndexToEntRef(child);	
	
	Call_StartForward(view_as<Handle>(g_hClass[id][NPC_EVENT_SPAWN]));
	Call_PushCell(entity);
	Call_Finish();
	
	return entity;
}
public int Native_DH_GetClass(Handle plugin, int numParams) {
	static char tmp[PLATFORM_MAX_PATH];
	GetNativeString(1, tmp, sizeof(tmp));
	
	int id;
	if( g_hNamedIdentified.GetValue(tmp, id) )
		return id;
	
	return -1;	
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
public any Native_DH_HasAnimation(Handle plugin, int numParams) {
	int id = GetNativeCell(1);
	int anim = GetNativeCell(2);
	return g_anClass[id][anim][0].seq >= 1;
}
public any Native_DH_RegisterAttack(Handle plugin, int numParams) {
	int id = GetNativeCell(1);
	int cpt = g_iClass[id][NPC_iAttackCount];
	
	g_atClass[id][cpt].type = GetNativeCell(2);
	g_atClass[id][cpt].range = GetNativeCell(3);
	g_atClass[id][cpt].probability = GetNativeCell(4);
	
	g_iClass[id][NPC_iAttackCount] = cpt + 1;
	g_iClass[id][NPC_iAttackSum] = g_iClass[id][NPC_iAttackSum] + g_atClass[id][cpt].probability;
}
public any Native_DH_RegisterHook(Handle plugin, int numParams) {
	g_hClass[GetNativeCell(1)][GetNativeCell(2)].AddFunction(plugin, GetNativeFunction(3));
}
public any Native_DH_RegisterPose(Handle plugin, int numParams) {
	g_iPose[GetNativeCell(1)][GetNativeCell(2)] = GetNativeCell(3);
}
public any Native_DH_Animate(Handle plugin, int numParams) {
	int entity = GetNativeCell(1);
	int anim = GetNativeCell(2);
	float desired_duration = GetNativeCell(3);
	//float trim = GetNativeCell(4);
	
	int id = g_iInstance[entity][NPC_iClass];
	int rnd = Math_GetRandomInt(1, g_anClass[id][anim][0].seq);
	
	int seq = g_anClass[id][anim][rnd].seq;
	float duration = g_anClass[id][anim][rnd].frames / g_anClass[id][anim][rnd].fps;
	float scale = 1.0;
	
	if( desired_duration >= 0.0 ) {
		scale = duration / desired_duration;
		duration = desired_duration;
	}
	
	//if( trim >= 0.0 )
	//	duration = trim;
	
	g_iInstance[entity][NPC_iCurrentAnim] = seq;
	view_as<float>(g_flInstance[entity][NPC_flNextAnim]) = (GetGameTime() + duration);
	view_as<float>(g_flInstance[entity][NPC_flAnimScale]) = scale;
	
	int animator = EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]);
	if( animator > 0 ) {
		//SetEntPropFloat(animator, Prop_Data, "m_flAnimTime", GetGameTime());
		SetEntPropFloat(animator, Prop_Data, "m_flPlaybackRate", scale);
		
		SetEntProp(animator, Prop_Send, "m_nSequence", seq);
		SetEntProp(animator, Prop_Data, "m_nIdealSequence", seq);
		
		SetEntPropFloat(animator, Prop_Data, "m_flAnimTime", GetGameTime());
		SetEntProp(animator, Prop_Data, "m_bSequenceLoops", 1);
	}
	
	return duration;
}
public any Native_DH_Gesture(Handle plugin, int numParams) {
	int entity = GetNativeCell(1);
	int anim = GetNativeCell(2);
	float desired_duration = GetNativeCell(3);
	bool remove = GetNativeCell(4);
	
	int id = g_iInstance[entity][NPC_iClass];
	int rnd = Math_GetRandomInt(1, g_anClass[id][anim][0].seq);
	
	int seq = g_anClass[id][anim][rnd].seq;
	float duration = g_anClass[id][anim][rnd].frames / g_anClass[id][anim][rnd].fps;
	float scale = 1.0;
	
	if( desired_duration >= 0.0 ) {
		scale = duration / desired_duration;
		duration = desired_duration;
	}
	
	int animator = EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]);
	if( animator > 0 ) {
		IAnimator refAnim = IAnimator(animator);

		if( remove ) {
			for(int i=1; i<g_anClass[id][anim][0].seq; i++)
				refAnim.RemoveGesture(g_anClass[id][anim][i].seq);
		}
		
		int layer = refAnim.AddGesture(seq, true);
		if( desired_duration >= 0.0 )
			refAnim.CBaseAnimatingOverlay().SetLayerPlaybackRate(layer, scale);
	}
	
	return duration;
}
public any Native_DH_Pose(Handle plugin, int numParams) {
	int entity = GetNativeCell(1);
	int anim = GetNativeCell(2);
	float value = GetNativeCell(3);
	
	if( value > 1.0 )
		value = 1.0;
	if( value < 0.0 )
		value = 0.0;
	
	int id = g_iInstance[entity][NPC_iClass];
	int animator = EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]);
	
	if( animator > 0 ) {
		SetEntPropFloat(animator, Prop_Send, "m_flPoseParameter", value, g_iPose[id][anim]);
	}
}
