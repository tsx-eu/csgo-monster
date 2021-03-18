#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <smlib>

#include <dh>

char g_szFullname[PLATFORM_MAX_PATH] =	"Zombie";
char g_szName[PLATFORM_MAX_PATH] =	"zombie";
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
public void OnAllPluginsLoaded() {
	NPCClass zombie = NPCClass(g_szFullname, g_szName, g_szModel);
	zombie.Health = 250;
	zombie.Speed = 260.0;
	zombie.Gravity = 1.0;
	
	zombie.AddAttack(NPC_ATTACK_MELEE, 25, NPC_RANGE_MELEE);
	
	zombie.AddAnimation(NPC_ANIM_IDLE, 		0, 		200, 	35);
	zombie.AddAnimation(NPC_ANIM_RUN, 		2, 		30, 	35);
	zombie.AddAnimation(NPC_ANIM_ATTACK, 	7, 		40, 	50);
	zombie.AddAnimation(NPC_ANIM_ATTACK, 	9, 		40, 	50);
	zombie.AddAnimation(NPC_ANIM_DYING, 	38, 	55, 	35);
	zombie.AddAnimation(NPC_ANIM_DEAD, 		39, 	1, 		35);
	
	zombie.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
	zombie.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
	zombie.AddEvent(NPC_EVENT_DEAD,		OnDead);
}
public void OnAttack(NPCInstance entity) {	
	entity.Animate(NPC_ANIM_ATTACK);
}
public void OnSpawn(NPCInstance entity) {
	
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
