
APLRes Native_REGISTER() {
	CreateNative("DH_Create", 				Native_DH_Create);
	CreateNative("DH_Spawn", 				Native_DH_Spawn);
	CreateNative("DH_Kill", 				Native_DH_Kill);
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
	
	CreateNative("DH_Melee", 				Native_DH_Melee);
	CreateNative("DH_Projectile", 			Native_DH_Projectile);
	CreateNative("DH_Damage", 				Native_DH_Damage);
	
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
	view_as<PrivateForward>(g_hClass[id][NPC_EVENT_DAMAGE]) = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell);		// void(NPCInstance entity, int attacker, int damage)
	
	g_hNamedIdentified.SetValue(g_szClass[id][NPC_szName], id);
	
	return g_iClassCount++;
}

public any Native_DH_Kill(Handle plugin, int numParams) {
	int entity = GetNativeCell(1);
	int id = g_iInstance[entity][NPC_iClass];
	
	
	Director.Unregister(view_as<NPCInstance>(entity));
	
	g_iInstance[entity][NPC_iHealth] = 0;
	
	int animator = EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]);
	fctDead(id, entity, animator, GetGameTime());
}

#define EF_BONEMERGE                (1 << 0)
#define EF_NOSHADOW                 (1 << 4)
#define EF_NODRAW         			(1 << 5)
#define EF_NORECEIVESHADOW          (1 << 6)
#define EF_PARENT_ANIMATES          (1 << 9)

public int Native_DH_Spawn(Handle plugin, int numParams) {
	static char tmp[32];
	Format(tmp, sizeof(tmp), "!self,KillHierarchy,,%f,-1", REMOVE_TIME);
	
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
	Entity_SetHealth(entity, g_iClass[id][NPC_iHealth]);
	
	for(int i=0; i<view_as<int>(NPCData_max_Int); i++)
		g_iInstance[entity][i] = g_iClass[id][i];
	
	for(int i=0; i<view_as<int>(NPCData_max_Float); i++)
		view_as<float>(g_flInstance[entity][i]) = view_as<float>(g_flClass[id][i]);
	
	g_iInstance[entity][NPC_iClass] = id;
	g_iInstance[entity][NPC_iHealth] = g_iClass[id][NPC_iHealth];
	
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
	
	view_as<float>(g_flInstance[entity][NPC_flNextDoor]) = GetGameTime();
	g_iInstance[entity][NPC_iAnimator] = EntIndexToEntRef(child);
	
	SDKHook(entity, SDKHook_Touch, OnTouch);
	SDKHook(entity, SDKHook_ThinkPost, OnThink);
	SDKHook(entity, SDKHook_OnTakeDamage, OnDamage);
	Director.Register(view_as<NPCInstance>(entity));
	
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
	view_as<float>(g_flClass[GetNativeCell(1)][GetNativeCell(2)]) = GetNativeCell(3);
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
	view_as<float>(g_flInstance[GetNativeCell(1)][GetNativeCell(2)]) = GetNativeCell(3);
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
	
	if( g_anClass[id][anim][0].seq > 0 ) {
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
	
	return 0.0;
}
public any Native_DH_Gesture(Handle plugin, int numParams) {
	int entity = GetNativeCell(1);
	int anim = GetNativeCell(2);
	float desired_duration = GetNativeCell(3);
	bool remove = GetNativeCell(4);
	
	int id = g_iInstance[entity][NPC_iClass];
	
	if( g_anClass[id][anim][0].seq > 0 ) {
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
	return 0.0;
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

public any Native_DH_Melee(Handle plugin, int numParams) {
	DataPack pack;
	CreateDataTimer(GetNativeCell(4), Task_DH_Melee, pack, TIMER_DATA_HNDL_CLOSE);
	pack.WriteCell(EntIndexToEntRef(GetNativeCell(1)));	// instanceId
	pack.WriteCell(GetNativeCell(2));					// damage
	pack.WriteCell(GetNativeCell(3));					// range
}
public Action Task_DH_Melee(Handle timer, DataPack pack) {
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	
	if( entity > 0 ) {
		int damage = pack.ReadCell();
		float range = pack.ReadCell();
		
		float src[3], hit[3];
		Entity_GetAbsOrigin(entity, src);
		src[2] += HEIGHT_SIZE;
		
		int target = Entity_TraceMeleeHull(entity, src, hit);
		if( target > 0 && GetVectorDistance(src, hit) < range ) {
			DH_Damage(view_as<NPCInstance>(entity), target, damage, entity, DMG_CRUSH | DMG_SLASH);
		}
	}
	
	g_iInstance[entity][NPC_iAttackMeleeCount]++;
	return Plugin_Stop;
}
public any Native_DH_Projectile(Handle plugin, int numParams) {
	static char model[PLATFORM_MAX_PATH];
	
	DataPack pack;
	CreateDataTimer(GetNativeCell(3), Task_DH_Projectile, pack, TIMER_DATA_HNDL_CLOSE);
	pack.WriteCell(EntIndexToEntRef(GetNativeCell(1)));	// instanceId
	
	GetNativeString(2, model, sizeof(model));
	pack.WriteString(model);							// model
	
	pack.WriteCell(GetNativeCell(4)); 					// spreadAngle
	pack.WriteCell(GetNativeCell(5)); 					// speed 
	pack.WriteCell(GetNativeCell(6)); 					// gravity 
	
	pack.WriteCell(plugin);
	pack.WriteFunction(GetNativeFunction(7)); 			// DH_ProjectileCreate
	pack.WriteFunction(GetNativeFunction(8)); 			// DH_ProjectileHit
}
public Action Task_DH_Projectile(Handle timer, DataPack pack) {
	static char model[PLATFORM_MAX_PATH];
	pack.Reset();
	
	bool wellAimed = false;
	int entity = EntRefToEntIndex(pack.ReadCell());
	
	if( entity > 0 ) {
		pack.ReadString(model, sizeof(model));
		
		float spreadAngle = pack.ReadCell();
		float speed = pack.ReadCell();
		float gravity = pack.ReadCell();
		
		Handle plugin = pack.ReadCell();
		Function create = pack.ReadFunction();
		Function hit = pack.ReadFunction();
		
		int target = g_iInstance[entity][NPC_iLeader];
		
		int ent = CreateEntityByName("hegrenade_projectile");
		//DispatchKeyValue(ent, "classname", name);
		DispatchSpawn(ent);
		
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", entity);
		SetEntPropFloat(ent, Prop_Send, "m_flElasticity", 0.4);
		SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
		SetEntityModel(ent, model);
		SetEntityGravity(ent, gravity);
		
		float vecOrigin[3], vecTarget[3], vecDir[3], vecAngles[3], vecPush[3];
		
		int animator = EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]);
		if( animator > 0 && Entity_GetAttachment(animator, "muzzle_flash", vecOrigin, vecAngles) > 0 ) {
			vecOrigin[2] += 8.0;
		}
		else {
			Entity_GetAbsOrigin(entity, vecOrigin);
			vecOrigin[2] += HEIGHT_SIZE;
		}
		
		if( Entity_IsInSightRange(entity, target, 45.0/2.0) ) {
			Entity_GetAbsOrigin(target, vecTarget);
			vecTarget[2] += HEIGHT_SIZE;
			
			// shot toward player movement direction
			// TODO: Limit the prediction of the movement based on the difficulty ?
			Entity_GetAbsVelocity(target, vecPush);
			ScaleVector(vecPush, GetVectorDistance(vecOrigin, vecTarget) / speed );
			AddVectors(vecTarget, vecPush, vecTarget);
			
			SubtractVectors(vecTarget, vecOrigin, vecDir);
			GetVectorAngles(vecDir, vecAngles);
			
			vecAngles[0] = GetProjectileAngle(vecDir, speed, gravity);
			wellAimed = true;
		}
		else {
			Entity_GetAbsAngles(entity, vecAngles);
		}
		
		vecDir[0] = vecDir[2] = 0.0;
		vecDir[1] = GetRandomFloat(-1.0, 1.0);
		NormalizeVector(vecDir, vecDir);
		
		// first shot will always miss.
		if( g_iInstance[entity][NPC_iAttackRangeCount] == 0 && false )
			ScaleVector(vecDir, (spreadAngle < 2.5 ? 2.5 : spreadAngle) * 3.0);
		else
			ScaleVector(vecDir, GetRandomFloat(0.0, spreadAngle));
		
		AddVectors(vecDir, vecAngles, vecAngles);
		GetAngleVectors(vecAngles, vecPush, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vecPush, speed);
		
		TeleportEntity(ent, vecOrigin, vecAngles, vecPush);
		TeleportEntity(entity, NULL_VECTOR, vecAngles, NULL_VECTOR);
		
		CreateTimer(0.1, Think_DH_Projectile, EntIndexToEntRef(ent), TIMER_REPEAT);
		
		if( create != INVALID_FUNCTION ) {
			Call_StartFunction(plugin, create);
			Call_PushCell(entity);
			Call_PushCell(ent);
			Call_Finish();
		}
		if( hit != INVALID_FUNCTION ) {
			g_hProjectile[ent] = new DataPack();
			g_hProjectile[ent].WriteCell(EntIndexToEntRef(entity));
			g_hProjectile[ent].WriteCell(plugin);
			g_hProjectile[ent].WriteFunction(hit);
			SDKHook(ent, SDKHook_Touch, Touch_DH_Projectile);
		}
	}
	
	if( wellAimed )
		g_iInstance[entity][NPC_iAttackRangeCount]++;
	
	return Plugin_Stop;
}
public Action Touch_DH_Projectile(int ent, int target) {
	g_hProjectile[ent].Reset();
	
	int entity = EntRefToEntIndex(g_hProjectile[ent].ReadCell());
	if( entity > 0 ) {
		Handle plugin = g_hProjectile[ent].ReadCell();
		Function callback = g_hProjectile[ent].ReadFunction();
				
		Call_StartFunction(plugin, callback);
		Call_PushCell(entity);
		Call_PushCell(ent);
		Call_PushCell(target);
		Call_Finish();
	}
	
	AcceptEntityInput(ent, "KillHierarchy");
}
public Action Think_DH_Projectile(Handle timer, any ref) {
	int ent = EntRefToEntIndex(ref);
	if( ent == INVALID_ENT_REFERENCE )
		return Plugin_Stop;
	
	float vel[3], ang[3];
	Entity_GetAbsVelocity(ent, vel);
	GetVectorAngles(vel, ang);
	TeleportEntity(ent, NULL_VECTOR, ang, NULL_VECTOR);
	
	return Plugin_Continue;
}
public any Native_DH_Damage(Handle plugin, int numParams) {
	int entity = GetNativeCell(1);
	int target = GetNativeCell(2);
	float damage = float(GetNativeCell(3)) * Director.DifficultyDamage;
	int inflictor = GetNativeCell(4);
	int id = g_iInstance[entity][NPC_iClass];
	
	int maxHealth = Entity_GetMaxHealth(entity);
	int health = Entity_GetHealth(target);
	
	if( inflictor == 0 )
		inflictor = entity;
	
	// PreCalculation in float
	// --------------------------------------------------------------------------
	// Less damage from behind
	if( Entity_IsInSightRange(target, entity) )
		damage *= 0.5;
	
	// Damage reduction depending on health
	float fraction = SquareRoot(float(health)/float(maxHealth+1));
	if( fraction != fraction )
		fraction = 1.0;
	if( fraction > 1.0 )
		fraction = 1.0;
	if( fraction < 0.0 )
		fraction = 0.0;
	damage *= fraction;
	
	// PostCalculation in int
	// --------------------------------------------------------------------------
	int iDamage = RoundToCeil(damage);
	// First attack cannot kill
	if( g_iInstance[entity][NPC_iAttackSucceded] == 0 && iDamage > health )
		iDamage = health - 1;
	
	// Minimal damage.
	if( iDamage < 1 )
		iDamage = 1;
	
	Entity_Hurt(target, iDamage, entity, GetNativeCell(5), g_szClass[id][NPC_szName]);
	if( IsValidClient(target) )
		g_iInstance[entity][NPC_iAttackSucceded]++;
}