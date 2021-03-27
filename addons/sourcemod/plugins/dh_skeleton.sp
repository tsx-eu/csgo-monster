#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <smlib>

#include <dh>

char g_szModel1[PLATFORM_MAX_PATH] =	"models/npc/tsx/skeleton/skeleton.mdl";
char g_szModel2[PLATFORM_MAX_PATH] =	"models/npc/tsx/skeleton/skeleton_arrow.mdl";

char g_szMaterials[][PLATFORM_MAX_PATH] = {
	"materials/models/npc/tsx/skeleton/DS_equipment_standard.vtf",
	"materials/models/npc/tsx/skeleton/DS_equipment_standard.vmt",
	"materials/models/npc/tsx/skeleton/DS_skeleton_standard.vtf",
	"materials/models/npc/tsx/skeleton/DS_skeleton_standard.vmt"
};
char g_szSounds[][PLATFORM_MAX_PATH] = {
	"weapons/knife/knife_hit1.wav",
	"weapons/knife/knife_hit2.wav",
	"weapons/knife/knife_hit3.wav",
	"weapons/knife/knife_hit4.wav"
};

int g_cBeam;

NPCClass g_Class;
public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "DH-CORE") ) {
		g_Class = NPCClass("Bow Skeleton", "skeleton_bow", g_szModel1);
		g_Class.Health = 250;
		g_Class.Speed = 250.0;
		g_Class.Gravity = 1.0;
		g_Class.MinBody = 0;
		g_Class.MaxBody = 0;
		g_Class.MinSkin = 0;
		g_Class.MaxSkin = 0;
		
		//g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
		g_Class.AddAttack(NPC_ATTACK_WEAPON, 	1024.0);
		
		g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		100, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_IDLE,		15, 	100, 	35.0);
		
		g_Class.AddAnimation(NPC_ANIM_WALK,     1, 		35, 	28.0);
		g_Class.AddAnimation(NPC_ANIM_RUN, 		16,		30, 	35.0);
		
		
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	3, 		100, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_ATTACK, 	4, 		100, 	30.0);
		g_Class.AddAnimation(NPC_ANIM_ATTACK2, 	17, 	50, 	35.0);
		
		g_Class.AddAnimation(NPC_ANIM_DYING, 	5, 		45, 	35.0);
		g_Class.AddAnimation(NPC_ANIM_DEAD, 	6, 		1, 		35.0);
		
		g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
		g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
		g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
		g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
	}
}
public float OnAttack(NPCInstance entity, int attack_id) {
	entity.Projectile(g_szModel2, 15 / 35.0, 5.0, 1024.0, 1.0, OnProjectileCreate, OnProjectileHit);
	return entity.Gesture(NPC_ANIM_ATTACK2);
}
public void OnProjectileCreate(NPCInstance entity, int inflictor) {
	TE_SetupBeamFollow(inflictor, g_cBeam, g_cBeam, 1.0, 1.0, 0.0, 1, {200, 200, 200, 50} );
	TE_SendToAll();
}
public void OnProjectileHit(NPCInstance entity, int inflictor, int victim) {
	if( victim > 0 && victim < 65 )
		SlapPlayer(victim);
}
public void OnSpawn(NPCInstance entity) {
	// No
}
public void OnDead(NPCInstance entity) {
	// No
}
public void OnDamage(NPCInstance entity, int attacker, int damage) {
	// No
}

public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	PrecacheModel(g_szModel1);
	PrecacheModel(g_szModel2);
	AddModelToDownloadsTable(g_szModel1);
	AddModelToDownloadsTable(g_szModel2);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		AddSoundToDownloadsTable(g_szSounds[i]);
		PrecacheSound(g_szSounds[i]);
	}
	
	for (int i = 0; i < sizeof(g_szMaterials); i++) {
		AddFileToDownloadsTable(g_szMaterials[i]);
	}
}
