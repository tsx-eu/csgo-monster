#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <smlib>

#include <dh>

char g_szModel[PLATFORM_MAX_PATH] =	"models/npc/tsx/zombie/zombie.mdl";
char g_szMaterials[][PLATFORM_MAX_PATH] = {
	"materials/models/npc/tsx/zombie/ZombieTexture_Basic.vtf",
	"materials/models/npc/tsx/zombie/ZombieTexture_Basic.vmt",
};
char g_szSounds[][PLATFORM_MAX_PATH] = {
	"weapons/knife/knife_hit1.wav",
	"weapons/knife/knife_hit2.wav",
	"weapons/knife/knife_hit3.wav",
	"weapons/knife/knife_hit4.wav"
};

NPCClass g_Class;
public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "DH-CORE") ) {
		g_Class = NPCClass("Zombie", "zombie", g_szModel);
		g_Class.Health = 250;
		g_Class.Speed = 260.0;
		g_Class.Gravity = 1.0;
		g_Class.MinBody = 0;
		g_Class.MaxBody = 18;
		g_Class.MinSkin = 0;
		g_Class.MaxSkin = 0;
		
		g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
		
		g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		200, 	35.0);
		g_Class.AddAnimation(NPC_ANIM_WALK,     3, 		210, 	28.0);
		g_Class.AddAnimation(NPC_ANIM_RUN, 		6, 		30, 	35.0);
		
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	9, 		40, 	50.0);
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	10,		40, 	50.0);
		g_Class.AddAnimation(NPC_ANIM_DYING, 	11, 	55, 	35.0);
		g_Class.AddAnimation(NPC_ANIM_DEAD, 	12, 	1, 		35.0);
		
		g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
		g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
		g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
	}
}
public void OnAttack(NPCInstance entity, int attack_id) {	
	entity.Animate(NPC_ANIM_ATTACK);
}
public void OnSpawn(NPCInstance entity) {
	entity.Animate(NPC_ANIM_RUN);
}
public void OnDead(NPCInstance entity) {
	
}

public void OnMapStart() {
	PrecacheModel(g_szModel);
	AddModelToDownloadsTable(g_szModel);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		AddSoundToDownloadsTable(g_szSounds[i]);
		PrecacheSound(g_szSounds[i]);
	}
	
	for (int i = 0; i < sizeof(g_szMaterials); i++) {
		AddFileToDownloadsTable(g_szMaterials[i]);
	}
}
