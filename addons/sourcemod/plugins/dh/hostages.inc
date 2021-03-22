
void DH_OnEntityCreated(int entity) {
	SDKHook(entity, SDKHook_Touch, OnTouch);
	SDKHook(entity, SDKHook_ThinkPost, OnThink);
	m_inhibitDoorTimer[entity] = 0.0;
}

public Action DH_OnCalcMainActivityPre(int hostage, int& anim) {	
	return Plugin_Continue;
}
public void DH_OnCalcMainActivityPost(int hostage, int anim) {
	//PrintToChatAll("%d", anim);
}
public Action DH_OnUpdateFollowingPre(int hostage, float delta) {
	return Plugin_Continue;
}
public void DH_OnUpdateFollowingPost(int entity, float delta) {
	AvoidPhysicsProps(entity);
}
void AvoidPhysicsProps(int entity) {
	static float src[3], dst[3], push[3], norm[3], min[3], max[3], vel[3];
	bool debugEnabled = false;
	GetEntDataVector(entity, m_accel, vel);
	
	Entity_GetAbsOrigin(entity, src);
	Phys_GetWorldSpaceCenter(entity, norm);
	
	int ents[8];
	int ret = GetPushawayEnts(entity, ents, sizeof(ents), 5.0, PARTITION_SOLID_EDICTS);
	for(int i=0; i<ret; i++) {
		int target = ents[i];
		if( target != entity ) {
			
			float mass = Phys_IsPhysicsObject(target) ? Phys_GetMass(target) : 30.0;			
			{
				float lerp = 0.0 + Math_Clamp(Math_InvLerp(10.0, 30.0, mass), 0.0, 1.0);
				if( lerp > 0.0 ) {
					Phys_GetWorldSpaceCenter(target, dst);
					SubtractVectors(norm, dst, push);
					
					float flDist = NormalizeVector(push, push);
					if( flDist < 1.0 ) flDist = 1.0;
					
					float flForce = sv_pushaway_hostage_force.FloatValue / flDist * lerp;
					if( flForce > sv_pushaway_max_hostage_force.FloatValue ) flForce = sv_pushaway_max_hostage_force.FloatValue;
									
					ScaleVector(push, flForce);
					AddVectors(vel, push, vel);
					
					if( debugEnabled ) {
						NormalizeVector(push, push);
						ScaleVector(push, 120.0);
						AddVectors(norm, push, dst);
						
						TE_SetupBeamPoints(norm, dst, g_cBeam, g_cBeam, 0, 0, 2.0, 2.0, 2.0, 0, 0.0, { 0, 255, 0, 250 }, 0);
						TE_SendToAll();
						
						TE_SetupBeamPoints(dst, norm, g_cBeam, g_cBeam, 0, 0, 2.0, 2.0, 2.0, 0, 0.0, { 0, 255, 0, 250 }, 0);
						TE_SendToAll();
					}
				}
			}
			
			if( target > 0 && IsValidEntity(target) && !IsValidClient(target) && (HasEntProp(target, Prop_Data, "m_bAwake")||HasEntProp(target, Prop_Data, "m_bCanBePickedUp")) ) {
				float lerp = 1.0 - Math_Clamp(Math_InvLerp(10.0, 30.0, mass), 0.0, 1.0);
				if( lerp > 0.0 ) {
					Entity_GetAbsOrigin(target, dst);
					SubtractVectors(dst, src, push);
					
					float flDist = NormalizeVector(push, push);
					if( flDist < 1.0 ) flDist = 1.0;
					
					float flForce = sv_pushaway_force.FloatValue / flDist * lerp * 0.25;
					if( flForce > sv_pushaway_max_force.FloatValue ) flForce = sv_pushaway_max_force.FloatValue;
					
					ScaleVector(push, flForce);
					
					if( GetVectorLength(push) > 0.0 ) {
						Entity_GetAbsVelocity(target, dst);
						AddVectors(dst, push, push);
						TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, push);
					}
					
					if( debugEnabled ) {					
						NormalizeVector(push, push);
						ScaleVector(push, 120.0);
						AddVectors(src, push, dst);
		
						TE_SetupBeamPoints(src, dst, g_cBeam, g_cBeam, 0, 0, 2.0, 2.0, 2.0, 0, 0.0, { 255, 0, 0, 250 }, 0);
						TE_SendToAll();
						
						TE_SetupBeamPoints(dst, src, g_cBeam, g_cBeam, 0, 0, 2.0, 2.0, 2.0, 0, 0.0, { 255, 0, 0, 250 }, 0);
						TE_SendToAll();
					}
				}
			}
		}
	}
	
	if( GetVectorLength(vel) > 0.0 ) {
		Entity_GetMinSize(entity, min);
		Entity_GetMaxSize(entity, max);

		NormalizeVector(vel, push);
		AddVectors(src, push, dst);
		
		if( debugEnabled ) {		
			TE_SetupBeamPoints(src, dst, g_cBeam, g_cBeam, 0, 0, 1.0, 2.0, 2.0, 0, 0.0, { 0, 0, 255, 250 }, 0);
			TE_SendToAll();
		}

		Handle ray1 = TR_TraceHullFilterEx(src, dst, min, max, MASK_PLAYERSOLID, FilterToOne, entity);
		if( !TR_StartSolid(ray1) && TR_GetFraction(ray1) < 1.0 ) {
			TR_GetPlaneNormal(ray1, norm);
			
			if( norm[2] < 0.7 ) {				
				TR_GetEndPosition(dst, ray1);				
				AddVectors(dst, push, dst);
				
				push[0] = dst[0];
				push[1] = dst[1];
				push[2] = dst[2] + STEP_SIZE;
				
				if( debugEnabled ) {
					TE_SetupBeamPoints(push, dst, g_cBeam, g_cBeam, 0, 0, 1.0, 2.0, 2.0, 0, 0.0, { 0, 255, 0, 250 }, 0);
					TE_SendToAll();
				}
				
				Handle ray2 = TR_TraceHullFilterEx(push, dst, min, max, MASK_PLAYERSOLID, FilterToOne, entity);
				if( !TR_StartSolid(ray2) && TR_GetFraction(ray2) > 0.0 ) {
					src[2] += (STEP_SIZE*(1.0-TR_GetFraction(ray2)) + 1.0);
					TeleportEntity(entity, src, NULL_VECTOR, NULL_VECTOR);
				}
				CloseHandle(ray2);
			}
		}
		CloseHandle(ray1);
	}
	
	SetEntDataVector(entity, m_accel, vel);
}

stock void Animate(int entity, int animator) {
	if( view_as<float>(g_flInstance[entity][NPC_flNextAnim]) < GetGameTime() ) {
		NPCInstance instance = view_as<NPCInstance>(entity);
		
		float vel[3], speed;
		Entity_GetAbsVelocity(entity, vel);
		vel[2] = 0.0;
		speed = GetVectorLength(vel);
		
		if( speed > 100.0 )
			DH_Animate(instance, NPC_ANIM_RUN, -1.0, 0.25);
		else if( speed > 1.0 )
			DH_Animate(instance, NPC_ANIM_WALK, -1.0, 0.25);
		else
			DH_Animate(instance, NPC_ANIM_IDLE, -1.0, 0.25);
	}
	
	//SetEntPropFloat(animator, Prop_Data, "m_flPlaybackRate", g_flInstance[entity][NPC_flAnimScale]);
	//SetEntProp(animator, Prop_Data, "m_nSequence", g_iInstance[entity][NPC_iCurrentAnim]);
	//SetEntProp(animator, Prop_Data, "m_nIdealSequence", g_iInstance[entity][NPC_iCurrentAnim]);
}
public Action OnTouch(int entity, int target) {
	static char classname[128];
	
	if( target > 0 ) {
		GetEdictClassname(target, classname, sizeof(classname));
		
		if( m_inhibitDoorTimer[entity] < GetGameTime() && (StrContains(classname, "func_door") == 0 || StrContains(classname, "prop_door") == 0) ) {
			AcceptEntityInput(target, "Use", entity, entity);
			m_inhibitDoorTimer[entity] = GetGameTime() + 3.0;
		}
		
		if( StrContains(classname, "func_breakable_surf") == 0 ) {
			SDKHooks_TakeDamage(target, entity, entity, 100.0, DMG_CRUSH);
		}
	}
}
public void OnThink(int entity) {
	// Animate entity	
	//
	
	if( EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]) > 0 ) {
		SetEntProp(entity, Prop_Send, "m_bClientSideAnimation", 1);
		SetEntProp(g_iInstance[entity][NPC_iAnimator], Prop_Send, "m_bClientSideAnimation", 0);
		
		SDKCall(hSDKCallStudioFrameAdvance, EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator])); 
		
		SetEntPropEnt(entity, Prop_Send, "m_leader", g_iInstance[entity][NPC_iLeader]);
		Animate(entity, EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]));
	}
}