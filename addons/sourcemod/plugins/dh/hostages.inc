public void DH_OnEntityCreated(int hostage) {
	
}
public Action DH_OnTrackPath(int hostage, float dst[3], float delta) {
	if( g_iInstance[hostage][NPC_iHealth] <= 0 )
		return Plugin_Handled;
	
	float src[3], vel[3], acc[3];
	Entity_GetAbsOrigin(hostage, src);
	GetEntPropVector(hostage, Prop_Send, "m_vel", vel);
	
	// face in the direction of our motion
	ScaleVector(vel, 10.0);
	AddVectors(src, vel, vel);	
	CCSNavPath(hostage).FaceToward(vel, delta);
	
	if( GetEntityFlags(hostage) & FL_ONGROUND ) {
		// move towards dst
		SubtractVectors(dst, src, vel);
		vel[2] = 0.0;
		NormalizeVector(vel, vel);
	}
	else {
		// continue forward motion
		Entity_GetAbsAngles(hostage, src);
		GetAngleVectors(src, vel, NULL_VECTOR, NULL_VECTOR);
	}
	
	ScaleVector(vel, view_as<float>(g_flClass[ g_iInstance[hostage][NPC_iClass] ][NPC_flSpeed])*2.1775);
	GetEntDataVector(hostage, m_accel, acc);
	AddVectors(vel, acc, acc);
	SetEntDataVector(hostage, m_accel, acc);
	
	return Plugin_Handled;
}
public Action DH_OnUpdateFollowingPre(int entity, float delta) {
	float src[3], dst[3], end[3];
	CCSNavPath path = CCSNavPath(entity);
	int id = g_iInstance[entity][NPC_iClass];

	if( g_iInstance[entity][NPC_iLeader] > 0 ) {
		Entity_GetAbsOrigin(entity, src);
		Entity_GetAbsOrigin(g_iInstance[entity][NPC_iLeader], dst);
		
		// if leader has moved, repath
		if( path.IsValid() ) {
			path.GetEndpoint(end);
			if( GetVectorDistance(dst, end) > NPC_RANGE_REPATH )
				path.Invalidate();
		}
		
		// build a path to our leader
		if( !path.IsValid() && path.CanRepath )
			path.Compute(src, dst);
		
		// if our rescuer is too far away, give up
		if( GetVectorDistance(src, dst) > NPC_RANGE_GIVEUP || path.GetLength() > NPC_RANGE_GIVEUP*2.0 )
			return Plugin_Handled;
		
		// don't crowd the leader
		bool walk = true;
		if( g_iInstance[entity][NPC_isWaiting] == 1 ) {
			if( GetVectorDistance(src, dst) < view_as<float>(g_flClass[id][NPC_flWaitRange]) )
				walk = false;
		}
		else {
			if( GetVectorDistance(src, dst) < view_as<float>(g_flClass[id][NPC_flNearRange]) )
				walk = false;
		}
		
		// move along path towards the leader
		if( walk )
			path.Track(delta);
		else
			path.FaceToward(dst, delta);
	}
	
	return Plugin_Handled;
	
}
public void DH_OnUpdateFollowingPost(int entity, float delta) {
	if( g_iInstance[entity][NPC_iHealth] <= 0 )
		return;
	
	AvoidPhysicsProps(entity);
}
// -------------------------------------
public Action OnDamage(int victim, int& attacker, int& inflictor, float& damage, int& damageType, int& weapon, float damageForce[3], float damagePosition[3]) {
	int id = g_iInstance[victim][NPC_iClass];
	
	g_iInstance[victim][NPC_iHealth] -= RoundFloat(damage);	
	
	Call_StartForward(view_as<Handle>(g_hClass[id][NPC_EVENT_DAMAGE]));
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(RoundFloat(damage));
	Call_Finish();
	
	if( g_iInstance[victim][NPC_iHealth] <= 0 )
		view_as<NPCInstance>(victim).Kill();
}
public Action OnTouch(int entity, int target) {
	static char classname[128];
	
	if( target > 0 ) {
		GetEdictClassname(target, classname, sizeof(classname));
		
		if( view_as<float>(g_flInstance[entity][NPC_flNextDoor]) < GetGameTime() && (StrContains(classname, "func_door") == 0 || StrContains(classname, "prop_door") == 0) ) {
			AcceptEntityInput(target, "Use", entity, entity);
			view_as<float>(g_flInstance[entity][NPC_flNextDoor]) = GetGameTime() + 3.0;
		}
		
		if( StrContains(classname, "func_breakable_surf") == 0 ) {
			SDKHooks_TakeDamage(target, entity, entity, 100.0, DMG_CRUSH);
		}
	}
}
public void OnThink(int entity) {
	// Animate entity	
	//
	float time = GetGameTime();
	int id = g_iInstance[entity][NPC_iClass];
	int animator = EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]);

	if( animator > 0 ) {
		fctAnimate(id, entity, animator, time);
	}
	
	SetEntPropEnt(entity, Prop_Send, "m_leader", g_iInstance[entity][NPC_iLeader]);
	fctAttack(id, entity, animator, time);
}
public Action OnEntityDissolve(Handle timer, any ref) {
	int entity = EntRefToEntIndex(ref);
	if( entity > 0 ) {
		int animator = EntRefToEntIndex(g_iInstance[entity][NPC_iAnimator]);
		if( animator > 0 )
			Effect_DissolveEntity(animator, DISSOLVE_ELECTRICAL_LIGHT);
	}
	return Plugin_Handled;
}
// -------------------------------------
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
// -------------------------------------
public void fctDead(int id, int entity, int animator, float time) {
	SetEntPropEnt(entity, Prop_Send, "m_leader", 0);
	
	SDKUnhook(entity, SDKHook_Touch, OnTouch);
	SDKUnhook(entity, SDKHook_ThinkPost, OnThink);
	SDKUnhook(entity, SDKHook_OnTakeDamage, OnDamage);
	
	Call_StartForward(view_as<Handle>(g_hClass[id][NPC_EVENT_DEAD]));
	Call_PushCell(entity);
	Call_Finish();
	
	view_as<NPCInstance>(entity).Animate(NPC_ANIM_DYING);
	SetEntProp(animator, Prop_Data, "m_bSequenceLoops", 0);
	IAnimator(animator).RemoveAllGesture();
	
	Entity_SetCollisionGroup(entity, COLLISION_GROUP_DEBRIS);
	AcceptEntityInput(entity, "FireUser1");
	CreateTimer(REMOVE_TIME * 0.75, OnEntityDissolve, EntIndexToEntRef(entity));
}
public void fctAttack(int id, int entity, int animator, float time) {
	
	if( view_as<float>(g_flInstance[entity][NPC_flNextAttack]) < time ) {
		
		float duration = 0.1;
		int attackId = -1;
		int sum = 0;
		int rnd = GetRandomInt(0, g_iClass[id][NPC_iAttackSum]);
		
		do {
			attackId++;
			sum += g_atClass[id][attackId].probability;
		} while (sum < rnd);
		
		float hit[3], src[3];
		int target;
		bool can = false;
		switch( g_atClass[id][attackId].type ) {
			case NPC_ATTACK_MELEE: {
				Entity_GetAbsOrigin(entity, src);
				src[2] += HEIGHT_SIZE;
				target = Entity_TraceMeleeHull(entity, src, hit);
				
				if( target > 0 && GetVectorDistance(src, hit) < g_atClass[id][attackId].range ) {
					can = true;
				}
			}
			case NPC_ATTACK_WEAPON: {			
				if( g_iInstance[entity][NPC_isWaiting] == 0 )
					can = Entity_IsInSightRange(entity, g_iInstance[entity][NPC_iLeader], 45.0, g_atClass[id][attackId].range);
			}
		}
		
		if( can ) {
			Call_StartForward(view_as<Handle>(g_hClass[id][NPC_EVENT_ATTACK]));
			Call_PushCell(entity);
			Call_PushCell(attackId);
			Call_Finish(duration);
		}
		
		view_as<float>(g_flInstance[entity][NPC_flNextAttack]) = time + duration;
	}
}
public void fctAnimate(int id, int entity, int animator, float time) {	
	float vel[3], speed;
	Entity_GetAbsVelocity(entity, vel);
	vel[2] = 0.0;
	speed = GetVectorLength(vel);
	view_as<float>(g_flInstance[entity][NPC_flSpeed]) = (view_as<float>(g_flInstance[entity][NPC_flSpeed]) * (9.0/10.0)) + (speed * (1.0/10.0));
	
	NPCInstance instance = view_as<NPCInstance>(entity);
	
	if( view_as<float>(g_flInstance[entity][NPC_flNextAnim]) < time ) {
		
		if( false && instance.Class.HasAnimation(NPC_ANIM_SPEED) ) {
			instance.Animate(NPC_ANIM_SPEED);
			SetEntProp(animator, Prop_Data, "m_bSequenceLoops", 1);
		}
		else {	
			if( speed > 100.0 )
				instance.Animate(NPC_ANIM_RUN);
			else if( speed > 1.0 )
				instance.Animate(NPC_ANIM_WALK);
			else
				instance.Animate(NPC_ANIM_IDLE);
			
			view_as<float>(g_flInstance[entity][NPC_flNextAnim]) = time + 0.25;
		}
	}
	
	float param = speed / view_as<float>(g_flClass[g_iInstance[entity][NPC_iClass]][NPC_flSpeed]);	
	instance.Pose(NPC_POSE_SPEED, param);
	
	IAnimator(animator).Play();
}
