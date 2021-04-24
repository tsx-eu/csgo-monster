#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <smlib>

#include <dh>
#include <precache>

char g_szModel[PLATFORM_MAX_PATH] =	"models/npc/tsx/zombie/zombie.mdl";

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
		NPCClass g_Class = NPCClass("Zombie", "zombie", g_szModel);
		g_Class.Health = 250;
		g_Class.Speed = 250.0;
		g_Class.Gravity = 1.0;
		g_Class.MinBody = 0;
		g_Class.MaxBody = 18;
		g_Class.MinSkin = 0;
		g_Class.MaxSkin = 0;
		g_Class.NearRange = NPC_RANGE_MELEE - 16.0;
		g_Class.WaitRange = NPC_RANGE_MELEE * 4.0;
		
		g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
		
		g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		200, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_WALK,     1, 		210, 	28.0);
		g_Class.AddAnimation(NPC_ANIM_RUN, 		2, 		30, 	35.0);
		
		g_Class.AddAnimation(NPC_ANIM_SPEED, 	3, 		30, 	35.0);		
		
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	4, 		40, 	50.0);
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	5,		45, 	50.0);
		
		g_Class.AddAnimation(NPC_ANIM_DYING, 	6, 		55, 	25.0);
		
		g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
		g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
		g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
		g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
	}
}
public float OnAttack(NPCInstance entity, int attack_id) {
	static char sound[PLATFORM_MAX_PATH];
	
	Format(sound, sizeof(sound), "dh/npc/zombie/Attack_%2d.mp3", GetRandomInt(1, 8));
	EmitAmbientSound(sound, NULL_VECTOR, entity.Id, SNDLEVEL_WHISPER, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
	
	entity.Melee(10, NPC_RANGE_MELEE, 10 / 50.0);
	return entity.Gesture(NPC_ANIM_ATTACK);
}
public void OnSpawn(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
	
	Format(sound, sizeof(sound), "dh/npc/zombie/Growl_%2d.mp3", GetRandomInt(1, 9));
	EmitAmbientSound(sound, NULL_VECTOR, entity.Id, SNDLEVEL_WHISPER, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
}
public void OnDead(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
	
	Format(sound, sizeof(sound), "dh/npc/zombie/Death_%2d.mp3", GetRandomInt(1, 10));
	EmitAmbientSound(sound, NULL_VECTOR, entity.Id, SNDLEVEL_WHISPER, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
}
public void OnDamage(NPCInstance entity, int attacker, int damage) {
	static char sound[PLATFORM_MAX_PATH];
	
	Format(sound, sizeof(sound), "dh/npc/zombie/Hit_%2d.mp3", GetRandomInt(1, 5));
	EmitAmbientSound(sound, NULL_VECTOR, entity.Id, SNDLEVEL_WHISPER, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
}

public void OnMapStart() {
	Precache_Model(g_szModel);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}
