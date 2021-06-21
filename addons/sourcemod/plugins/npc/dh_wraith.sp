#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <smlib>

#include <dh>
#include <precache>

char g_szModel[PLATFORM_MAX_PATH] =	"models/dh/wraith/wraith.mdl";

char g_szSounds[][PLATFORM_MAX_PATH] = {
	
};

public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "DH-CORE") ) {
		NPCClass g_Class = NPCClass("Wraith", "wraith", g_szModel);
		g_Class.Health = 250;
		g_Class.Speed = 250.0;
		g_Class.Gravity = 1.0;
		g_Class.MinBody = 0;
		g_Class.MaxBody = 0;
		g_Class.MinSkin = 0;
		g_Class.MaxSkin = 7;
		g_Class.NearRange = NPC_RANGE_MELEE - 16.0;
		g_Class.WaitRange = NPC_RANGE_MELEE * 4.0;
		
		g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
		
		g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		100, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_WALK,     1, 		80, 	40.0);
		g_Class.AddAnimation(NPC_ANIM_RUN, 		1, 		80, 	40.0);
		
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	2, 		30, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	3,		30, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	4,		30, 	30.0);
		
		g_Class.AddAnimation(NPC_ANIM_DYING, 	7, 		50, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_DYING, 	8, 		30, 	30.0);
		
		g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
		g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
		g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
		g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
	}
}
public float OnAttack(NPCInstance entity, int attack_id) {
	static char sound[PLATFORM_MAX_PATH];
	
	entity.Melee(10, NPC_RANGE_MELEE, 10 / 50.0);
	return entity.Gesture(NPC_ANIM_ATTACK);
}
public void OnSpawn(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
	
	int body = 0;
	
	bool cloth = GetRandomInt(0, 1) == 0;
	
	if( GetRandomInt(0, 1) == 0 ) // wristband
		body += 1;
	
	if( cloth && GetRandomInt(0, 1) == 0 ) // sleeve
		body += 2;
		
	if( !cloth && GetRandomInt(0, 1) == 0 ) // shoulderpad
		body += 4;
	
	if( GetRandomInt(0, 1) == 0 ) // scarf
		body += 8;
	
	if( GetRandomInt(0, 1) == 0 ) // necklace
		body += 16;
	
	if( cloth && GetRandomInt(0, 1) == 0 ) // hood
		body += 32;
	
	if( GetRandomInt(0, 1) == 0 ) // hair
		body += 64;
	
	if( GetRandomInt(0, 1) == 0 ) // eye
		body += 128;
	
	if( !cloth && GetRandomInt(0, 1) == 0 ) // dress
		body += 256;
	
	if( cloth ) // cloth
		body += 512;
	
	int weapon = GetRandomInt(0, 2);
	switch(weapon) {
		case 1: {
			body += 1024;
		}
		case 2: {
			body += 2048;
		}
	}
	
	entity.Body = body;
	
	int animator = EntRefToEntIndex(DH_GetInstanceInt(entity, NPC_iAnimator));
	if( animator > 0 ) {
		SetEntProp(animator, Prop_Send, "m_nBody", body);
	}
	
}
public void OnDead(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
}
public void OnDamage(NPCInstance entity, int attacker, int damage) {
	static char sound[PLATFORM_MAX_PATH];
}

public void OnMapStart() {
	Precache_Model(g_szModel);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}
