#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <smlib>

#include <dh>
#include <precache>

char g_szModel[PLATFORM_MAX_PATH] =	"models/dh/boss/aessidhe.mdl";

char g_szSounds[][PLATFORM_MAX_PATH] = {
	"dh/npc/zombie/Attack_01.mp3",
	"dh/npc/zombie/Attack_02.mp3",
	"dh/npc/zombie/Attack_03.mp3",
	"dh/npc/zombie/Attack_04.mp3",
	"dh/npc/zombie/Attack_05.mp3",
	"dh/npc/zombie/Attack_06.mp3",
	"dh/npc/zombie/Attack_07.mp3",
	"dh/npc/zombie/Attack_08.mp3",
	
	"dh/npc/zombie/Breathing_01.mp3",
	"dh/npc/zombie/Breathing_02.mp3",
	"dh/npc/zombie/Breathing_03.mp3",
	"dh/npc/zombie/Breathing_04.mp3",
	"dh/npc/zombie/Breathing_05.mp3",
	"dh/npc/zombie/Breathing_06.mp3",
	
	"dh/npc/zombie/Death_01.mp3",
	"dh/npc/zombie/Death_02.mp3",
	"dh/npc/zombie/Death_03.mp3",
	"dh/npc/zombie/Death_04.mp3",
	"dh/npc/zombie/Death_05.mp3",
	"dh/npc/zombie/Death_06.mp3",
	"dh/npc/zombie/Death_07.mp3",
	"dh/npc/zombie/Death_08.mp3",
	"dh/npc/zombie/Death_09.mp3",
	"dh/npc/zombie/Death_10.mp3",
	
	"dh/npc/zombie/Growl_01.mp3",
	"dh/npc/zombie/Growl_02.mp3",
	"dh/npc/zombie/Growl_03.mp3",
	"dh/npc/zombie/Growl_04.mp3",
	"dh/npc/zombie/Growl_05.mp3",
	"dh/npc/zombie/Growl_06.mp3",
	"dh/npc/zombie/Growl_07.mp3",
	"dh/npc/zombie/Growl_08.mp3",
	"dh/npc/zombie/Growl_09.mp3",
	
	"dh/npc/zombie/Hit_01.mp3",
	"dh/npc/zombie/Hit_02.mp3",
	"dh/npc/zombie/Hit_03.mp3",
	"dh/npc/zombie/Hit_04.mp3",
	"dh/npc/zombie/Hit_05.mp3",
	
	"dh/npc/zombie/Talking_01.mp3",
	"dh/npc/zombie/Talking_02.mp3",
	"dh/npc/zombie/Talking_03.mp3",
	"dh/npc/zombie/Talking_04.mp3",
	"dh/npc/zombie/Talking_05.mp3",
	"dh/npc/zombie/Talking_06.mp3",
	"dh/npc/zombie/Talking_07.mp3",
	"dh/npc/zombie/Talking_08.mp3"
};

public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "DH-CORE") ) {
		NPCClass g_Class = NPCClass("Aes Sidhe", "aessidhe", g_szModel);
		g_Class.Health = 250;
		g_Class.Speed = 250.0;
		g_Class.Gravity = 1.0;
		g_Class.MinBody = 0;
		g_Class.MaxBody = 18;
		g_Class.MinSkin = 0;
		g_Class.MaxSkin = 0;
		g_Class.NearRange = NPC_RANGE_MELEE - 16.0;
		g_Class.WaitRange = NPC_RANGE_MELEE * 4.0;
		
		for(int i=0; i<11; i++)
			g_Class.AddAttack(NPC_ATTACK_WEAPON, 	256.0);
		
		g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		200, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_WALK,     4, 		74, 	60.0);
		g_Class.AddAnimation(NPC_ANIM_RUN, 		3, 		90, 	60.0);
			
		g_Class.AddAnimation(NPC_ANIM_DYING, 	5, 		55, 	25.0);
		
		g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
		g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
		g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
		g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
	}
}
public float OnAttack(NPCInstance entity, int attack_id) {
	static char sound[PLATFORM_MAX_PATH];
	
	float time = 0.0;
	
	switch(attack_id) {
		case 0:	time = entity.GestureEx(22, 240, 60.0); 	// dash
		case 1:	time = entity.GestureEx(23, 556, 60.0); 	// jump than dash
		
		case 2:	time = entity.GestureEx(28, 616, 60.0); 	// summon
		case 3:	time = entity.GestureEx(29, 340, 60.0); 	// tail
		case 4:	time = entity.GestureEx(30, 740, 60.0); 	// storm
		
		case 5:	time = entity.GestureEx(31, 152, 60.0); 	// 1x slash
		case 6:	time = entity.GestureEx(34, 310, 60.0); 	// 2x slash
		case 7:	time = entity.GestureEx(33, 490, 60.0); 	// 3x slash
		case 8:	time = entity.GestureEx(32, 570, 60.0); 	// 4x slash
		
		case 9:	time = entity.GestureEx(36, 242, 60.0); 	// swing
		case 10:	time = entity.GestureEx(41, 168, 60.0); // summon fast
		
		default: {
			PrintToChatAll("[ERR] Unknown attackid: %d", attack_id);
		}
	}
	
	return time;
}
public void OnSpawn(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
	
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
	Precache_Model(g_szModel);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}
