#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <precache>




char g_szModel1[PLATFORM_MAX_PATH] =	"models/dh/boss/aessidhe.mdl";
char g_szModel2[PLATFORM_MAX_PATH] =	"models/dh/boss/aessidhe_spear.mdl";
int g_cBeam;

char g_szSounds[][PLATFORM_MAX_PATH] = {
	"dh/npc/zombie/Attack_01.mp3"
};

public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "DH-CORE") ) {
		NPCClass g_Class = NPCClass("Aes Sidhe", "aessidhe", g_szModel1);
		g_Class.Health = 250;
		g_Class.Speed = 250.0;
		g_Class.Gravity = 1.0;
		g_Class.MinBody = 0;
		g_Class.MaxBody = 18;
		g_Class.MinSkin = 0;
		g_Class.MaxSkin = 0;
		g_Class.NearRange = NPC_RANGE_MELEE - 16.0;
		g_Class.WaitRange = NPC_RANGE_MELEE * 4.0;
		
		g_Class.AddAttack(NPC_ATTACK_WEAPON, 	512.0);
		
		g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		200, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_WALK,     4, 		74, 	60.0);
		g_Class.AddAnimation(NPC_ANIM_RUN, 		3, 		90, 	60.0);
		g_Class.AddAnimation(NPC_ANIM_DYING,	17, 	300, 	60.0);
		
		g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
		g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
		g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
		g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
	}
}


enum struct s_pos {
	float pos[3];
	float start;
	float end;
	MoveType move;
}

ArrayList g_Anim[2048];

void Push(int entity, float pos[3], float start, float end, MoveType move = MOVETYPE_STEP) {
	s_pos data;
	data.pos = pos;
	data.start = GetGameTime() + start;
	data.end = GetGameTime() + end;
	data.move = move;
	
	if( g_Anim[entity] == null ) 
		g_Anim[entity] = new ArrayList(sizeof(data));
	
	g_Anim[entity].PushArray(data, sizeof(data));
}

public float OnAttack(NPCInstance entity, int attack_id) {
	static char sound[PLATFORM_MAX_PATH];
	
	float time = 0.0;
	float pos[3], ang[3], vel[3];
	Entity_GetAbsOrigin(entity.Id, pos);
	Entity_GetAbsAngles(entity.Id, ang);
	
	int weapon = GetEntPropEnt(entity.Id, Prop_Data, "m_hActiveWeapon");
	
	attack_id = 1;
	
	switch(attack_id) {
		case 0:	{
			time = entity.GestureEx(22, 240, 60.0); 	// dash
			GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(vel, 512.0);
			AddVectors(pos, vel, vel);
			
			Push(entity.Id, vel, 65/60.0, 85/60.0, MOVETYPE_FLY);
		}
		case 1:	{
			time = entity.GestureEx(30, 740, 60.0);
			// -insecure -tools -nop4
			// snatch
			// 
			
			int p = AttachParticle(entity.Id, "cast_red", 10.0);
			DispatchKeyValue(p, "OnUser1", "!self,StopPlayEndCap,,8.0,-1");
			AcceptEntityInput(p, "FireUser1");
			
			for(int i=0; i<128; i++) {
				CreateTimer(GetRandomFloat( 50/60.0, 200/60.0), Task_CreateSpear, entity);
				CreateTimer(GetRandomFloat(250/60.0, 350/60.0), Task_DamageSpear, entity);
				CreateTimer(GetRandomFloat(480/60.0, 500/60.0), Task_CleanSpear, entity);
			}
			
		}
		default: {
			PrintToChatAll("[ERR] Unknown attackid: %d", attack_id);
		}
	}
	
	entity.Freeze = GetGameTime() + time;
	return time + 1.0;
}
public Action Task_CleanSpear(Handle timer, any entity) {
	static char classname[128];
	float pos[3];
	
	int ent = -1;
	while( (ent = FindEntityByClassname(ent, "info_particle_system")) && ent > 0 ) {
		GetEdictClassname(ent, classname, sizeof(classname));
		
		if( StrEqual(classname, "aessidhe_particle_spear") ) {
			Entity_GetAbsOrigin(ent, pos);
			
			AcceptEntityInput(ent, "StopPlayEndCap");
			AcceptEntityInput(ent, "FireUser1");
			AcceptEntityInput(ent, "FireUser2");
			
			DispatchKeyValue(ent, "classname", "info_particle_system");
			break;
		}
	}
}

public Action Task_DamageSpear(Handle timer, any entity) {
	static char classname[128];
	float pos[3];
	
	int ent = -1;
	while( (ent = FindEntityByClassname(ent, "info_particle_system")) && ent > 0 ) {
		GetEdictClassname(ent, classname, sizeof(classname));
		
		if( StrEqual(classname, "aessidhe_target_spear") ) {
			Entity_GetAbsOrigin(ent, pos);
			
			int src = CreateEntityByName("info_particle_system");
			DispatchKeyValue(src, "OnUser1", "!self,KillHierarchy,,1.0,-1");
			DispatchKeyValue(src, "OnUser2", "!self,DestroyImmediately,,1.0,-1");
			DispatchKeyValue(src, "classname", "aessidhe_particle_spear");
			DispatchKeyValue(src, "effect_name", "aessidhe_spear");
			TeleportEntity(src, pos, NULL_VECTOR, NULL_VECTOR);
			
			DispatchSpawn(src);
			ActivateEntity(src);
			AcceptEntityInput(src, "Start");
			
			AcceptEntityInput(ent, "FireUser1");
			AcceptEntityInput(ent, "FireUser2");
			AcceptEntityInput(ent, "FireUser3");
			DispatchKeyValue(ent, "classname", "info_particle_system");
			
			break;
		}
	}
}
public Action Task_CreateSpear(Handle timer, any entity) {
	float pos[3], tmp[3], min[3];
	
	Entity_GetAbsOrigin(entity, pos);
	pos[2] += 128.0;
	
	int count = 0;
	int max = 1;
	
	while( count < max ) {
		tmp[0] = GetRandomFloat(-1.0, 1.0);
		tmp[1] = GetRandomFloat(-1.0, 1.0);
		tmp[2] = 0.0;
		NormalizeVector(tmp, tmp);
		ScaleVector(tmp, 4096.0);
		AddVectors(pos, tmp, tmp);
		
		bool valid = false;
		
		Handle visible = TR_TraceRayFilterEx(pos, tmp, MASK_PLAYERSOLID, RayType_EndPoint, FilterToOne, entity);
		if( TR_DidHit(visible) ) {
			TR_GetEndPosition(tmp, visible);
			SubtractVectors(tmp, pos, tmp);
			float len = GetVectorLength(tmp);
			
			if( len > 64.0 ) {
				valid = true;
				NormalizeVector(tmp, tmp);
				ScaleVector(tmp, GetRandomFloat(32.0, len));
				AddVectors(pos, tmp, tmp);
			}
		}
		else {
			valid = true;
		}
		delete visible;
		
		if( valid ) {
			min = tmp;
			min[2] -= 128.0;
			min[2] -= 16.0;
			
			Handle ground = TR_TraceRayFilterEx(tmp, min, MASK_PLAYERSOLID, RayType_EndPoint, FilterToOne, entity);
			if( TR_DidHit(ground) ) {
				TR_GetEndPosition(tmp, ground);
				
				Handle hull = TR_TraceHullFilterEx(tmp, tmp, view_as<float>({ -8.0, -8.0, 2.0 }), view_as<float>({ 8.0, 8.0, 16.0 }), MASK_PLAYERSOLID, FilterToOne, entity);
				if( !TR_DidHit(hull) ) {
					
					int src = CreateEntityByName("info_particle_system");
					DispatchKeyValue(src, "OnUser1", "!self,KillHierarchy,,2.1,-1");
					DispatchKeyValue(src, "OnUser2", "!self,DestroyImmediately,,2.0,-1");
					DispatchKeyValue(src, "OnUser3", "!self,StopPlayEndCap,,1.0,-1");
					DispatchKeyValue(src, "classname", "aessidhe_target_spear");
					DispatchKeyValue(src, "effect_name", "target_circle");
					
					DispatchSpawn(src);
					ActivateEntity(src);
					AcceptEntityInput(src, "Start");
					
					TeleportEntity(src, tmp, NULL_VECTOR, NULL_VECTOR);
					
					count++;
				}
				delete hull;
			}
			delete ground;
		}
		delete visible;
	}
	
	
	//int particle = AttachParticle(weapon, "aessidhe_spear", 10.0, weapon);
	//SetVariantString("snatch");
	//AcceptEntityInput(particle, "SetParentAttachment");
}
#define EF_BONEMERGE                (1 << 0)
#define EF_NOSHADOW                 (1 << 4)
#define EF_NODRAW         			(1 << 5)
#define EF_NORECEIVESHADOW          (1 << 6)
#define EF_ITEM_BLINK          		(1 << 8)
#define EF_PARENT_ANIMATES          (1 << 9)
#define EF_FOLLOWBONE               (1<<10)    


public void OnSpawn(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
	
	int weapon = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(weapon, "model", g_szModel2);
	DispatchSpawn(weapon);
	
	SetEntProp(weapon, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_NORECEIVESHADOW|EF_PARENT_ANIMATES);	
	
	SetVariantString("!activator");
	AcceptEntityInput(weapon, "SetParent", view_as<int>(entity.Animator));
	
	SetVariantString("spear_head");
	AcceptEntityInput(weapon, "SetParentAttachment");
	
	SetEntPropEnt(entity.Id, Prop_Data, "m_hActiveWeapon", weapon);
	
	SDKHook(entity.Id, SDKHook_Think, OnThink);
	SDKHook(entity.Id, SDKHook_Touch, OnTouch);
	
	Entity_SetMinSize(entity.Id, view_as<float>({ -32.0, -32.0, 0.0 }));
	Entity_SetMaxSize(entity.Id, view_as<float>({  32.0,  32.0, 128.0 }));
	Entity_SetSolidFlags(entity.Id, FSOLID_CUSTOMBOXTEST|FSOLID_CUSTOMRAYTEST);
	Entity_SetSolidType(entity.Id, SOLID_OBB);
	Entity_SetCollisionGroup(entity.Id, COLLISION_GROUP_NPC);
}
public void OnTouch(int entity, int target) {
	float vel[3];
	if( target > 0 && target <= 64  ) {
		Entity_GetAbsVelocity(entity, vel);
		
		if( GetVectorLength(vel, true) > 64.0*64.0 ) {
			NormalizeVector(vel, vel);
			ScaleVector(vel, 256.0);
			vel[2] += 256.0;
			
			int flags = GetEntityFlags(target);
			if( flags & FL_ONGROUND ) {
				SetEntityFlags(target, (flags&~FL_ONGROUND) );
				SetEntPropEnt(target, Prop_Send, "m_hGroundEntity", -1);
			}
			
			TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, vel);
		}
	}
}
public void OnThink(int entity) {
	float pos[3], vel[3];
	Entity_GetAbsOrigin(entity, pos);
	
	//TE_SetupBeamRingPoint(pos, 1.0, 32.0, g_cBeam, g_cBeam, 0, 10, 0.1, 4.0, 0.0, { 255, 0, 0, 255 }, 0, 0);
	//TE_SendToAll();
	
	if( g_Anim[entity] != null ) {
		
		s_pos data;
		float now = GetGameTime();
		
		while( g_Anim[entity].Length > 0 ) {
			g_Anim[entity].GetArray(0, data, sizeof(data));
			
			if( data.start >= now )
				break;
			
			if( data.end <= now ) {
				g_Anim[entity].Erase(0);
				continue;
			}
			
			if( GetEntityMoveType(entity) != data.move )
				SetEntityMoveType(entity, data.move);
			
			SubtractVectors(data.pos, pos, vel);
			ScaleVector(vel, GetVectorLength(vel) / (data.end - now) * (1.0/45.0) );
			
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
			break;
		}
		
		if( g_Anim[entity].Length == 0 ) {
			SetEntityMoveType(entity, MOVETYPE_STEP);
			delete g_Anim[entity];
			g_Anim[entity] = null;
		}
	}
}
public void OnDead(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
	
}
public void OnDamage(NPCInstance entity, int attacker, int damage) {
	static char sound[PLATFORM_MAX_PATH];
	static float next[2049];
	
	float time = GetGameTime();

	if( next[entity] < time ) {
		next[entity] = GetGameTime() + 1.0;
	}
}

public void OnMapStart() {
	g_cBeam = Precache_Model("materials/sprites/laserbeam.vmt");
	Precache_Model(g_szModel1);
	Precache_Model(g_szModel2);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}
