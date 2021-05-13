#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <smlib>
#include <sdkhooks>

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
	
	attack_id = 0;
	
	switch(attack_id) {
		case 0:	{
			time = entity.GestureEx(22, 240, 60.0); 	// dash
			GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(vel, 512.0);
			AddVectors(pos, vel, vel);
			
			Push(entity.Id, vel, 65/60.0, 85/60.0, MOVETYPE_FLY);
		}
		case 1:	time = entity.GestureEx(23, 556, 60.0); 	// jump than dash
		
		case 2:	time = entity.GestureEx(28, 616, 60.0); 	// summon
		case 3:	time = entity.GestureEx(29, 340, 60.0); 	// tail
		case 4:	time = entity.GestureEx(30, 740, 60.0); 	// storm
		
		case 5:	time = entity.GestureEx(31, 152, 60.0); 	// 1x slash
		case 6:	time = entity.GestureEx(34, 310, 60.0); 	// 2x slash
		case 7:	time = entity.GestureEx(33, 490, 60.0); 	// 3x slash
		case 8:	time = entity.GestureEx(32, 570, 60.0); 	// 4x slash
		
		case 9:	time = entity.GestureEx(36, 242, 60.0); 	// swing
		case 10:time = entity.GestureEx(41, 168, 60.0); 	// summon fast
		
		default: {
			PrintToChatAll("[ERR] Unknown attackid: %d", attack_id);
		}
	}
	
	entity.Freeze = GetGameTime() + time;
	return time + 1.0;
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
	
	SDKHook(entity.Id, SDKHook_Think, OnThink);
	SDKHook(entity.Id, SDKHook_Touch, OnTouch);
	
	Entity_SetMinSize(entity.Id, view_as<float>({ -32.0, -32.0, 0.0 }));
	Entity_SetMaxSize(entity.Id, view_as<float>({  32.0,  32.0, 128.0 }));
	Entity_SetSolidFlags(entity.Id, FSOLID_CUSTOMBOXTEST|FSOLID_CUSTOMRAYTEST);
	Entity_SetSolidType(entity.Id, SOLID_OBB);
	Entity_SetCollisionGroup(entity.Id, COLLISION_GROUP_NPC);
}
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damageType, int& weapon, float damageForce[3], float damagePosition[3]) {
	PrintToChatAll("hi");
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
	
	TE_SetupBeamRingPoint(pos, 1.0, 32.0, g_cBeam, g_cBeam, 0, 10, 0.1, 4.0, 0.0, { 255, 0, 0, 255 }, 0, 0);
	TE_SendToAll();
	
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
