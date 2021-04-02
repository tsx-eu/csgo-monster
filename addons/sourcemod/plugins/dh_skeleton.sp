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

public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "DH-CORE") ) {
		// ---- Bow
		{
			NPCClass g_Class = NPCClass("Bow Skeleton", "skeleton_bow", g_szModel1);
			g_Class.Health = 250;
			g_Class.Speed = 220.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 0;
			g_Class.MaxBody = 0;
			g_Class.MinSkin = 0;
			g_Class.MaxSkin = 0;
			g_Class.NearRange = 512.0;
			g_Class.WaitRange = 1024.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			g_Class.AddAttack(NPC_ATTACK_WEAPON, 	1024.0);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		100, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_IDLE,		15, 	100, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     1, 		35, 	28.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		16,		30, 	35.0);
			
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	3, 		100, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	4, 		100, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK2, 	17, 	50, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	5, 		45, 	25.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack_BOW);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
		// ---- Two handed axe
		{
			NPCClass g_Class = NPCClass("Berzerk Skeleton", "skeleton_berzerk", g_szModel1);
			g_Class.Health = 250;
			g_Class.Speed = 200.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 15;
			g_Class.MaxBody = 15;
			g_Class.MinSkin = 0;
			g_Class.MaxSkin = 0;
			g_Class.NearRange = NPC_RANGE_MELEE - 16.0;
			g_Class.WaitRange = NPC_RANGE_MELEE * 4.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE, 2);
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		100, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_IDLE,		11, 	210, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     1, 		35, 	28.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		12,		30, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	13, 	70, 	35.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK2, 	14, 	70, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	5, 		45, 	25.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack_AXE);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
		// ---- Shield & Sword/Mace/Axe
		{
			NPCClass g_Class = NPCClass("Axe Skeleton", "skeleton_axe", g_szModel1);
			g_Class.Health = 250;
			g_Class.Speed = 250.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 30;
			g_Class.MaxBody = 30;
			g_Class.MinSkin = 0;
			g_Class.MaxSkin = 0;
			g_Class.NearRange = NPC_RANGE_MELEE - 16.0;
			g_Class.WaitRange = NPC_RANGE_MELEE * 4.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		100, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_IDLE,		7, 		100, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     1, 		35, 	28.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		12,		30, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	9, 		45, 	35.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	10, 	45, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	5, 		45, 	25.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack_SHIELD);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
		{
			NPCClass g_Class = NPCClass("Mace Skeleton", "skeleton_mace", g_szModel1);
			g_Class.Health = 250;
			g_Class.Speed = 250.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 45;
			g_Class.MaxBody = 45;
			g_Class.MinSkin = 0;
			g_Class.MaxSkin = 0;
			g_Class.NearRange = NPC_RANGE_MELEE - 16.0;
			g_Class.WaitRange = NPC_RANGE_MELEE * 4.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		100, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_IDLE,		7, 		100, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     1, 		35, 	28.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		12,		30, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	9, 		45, 	35.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	10, 	45, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	5, 		45, 	25.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack_SHIELD);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
		{
			NPCClass g_Class = NPCClass("Sword Skeleton", "skeleton_sword", g_szModel1);
			g_Class.Health = 250;
			g_Class.Speed = 250.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 60;
			g_Class.MaxBody = 60;
			g_Class.MinSkin = 0;
			g_Class.MaxSkin = 0;
			g_Class.NearRange = NPC_RANGE_MELEE - 16.0;
			g_Class.WaitRange = NPC_RANGE_MELEE * 4.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	0, 		100, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_IDLE,		7, 		100, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     1, 		35, 	28.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		12,		30, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	9, 		45, 	35.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	10, 	45, 	35.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	5, 		45, 	25.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack_SHIELD);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
	}
}
public float OnAttack_BOW(NPCInstance entity, int attack_id) {
	float time = 0.0;
	switch(attack_id) {
		case 0: {
			entity.Melee(10, NPC_RANGE_MELEE, 10 / 50.0);
			time = entity.Gesture(NPC_ANIM_ATTACK);
		}
		case 1: {
			entity.Projectile(g_szModel2, 15 / 35.0, 2.5, 1024.0, 1.0, OnProjectileCreate, OnProjectileHit);
			time = entity.Gesture(NPC_ANIM_ATTACK2);
			entity.Freeze = GetGameTime() + time;
		}
	}
	return time;
}
public float OnAttack_AXE(NPCInstance entity, int attack_id) {
	float time = 0.0;
	switch(attack_id) {
		case 0: {
			entity.Melee(20, NPC_RANGE_MELEE, 10 / 35.0);
			time = entity.Gesture(NPC_ANIM_ATTACK);
		}
		case 1: {
			entity.Melee(50, NPC_RANGE_MELEE, 10 / 35.0);
			time = entity.Gesture(NPC_ANIM_ATTACK2);
			entity.Freeze = GetGameTime() + time;
		}
	}
	return time;
}
public float OnAttack_SHIELD(NPCInstance entity, int attack_id) {
	entity.Melee(10, NPC_RANGE_MELEE, 10 / 35.0);
	return entity.Gesture(NPC_ANIM_ATTACK);
}
public void OnProjectileCreate(NPCInstance entity, int inflictor) {
	TE_SetupBeamFollow(inflictor, g_cBeam, g_cBeam, 1.0, 1.0, 0.0, 1, {200, 200, 200, 50} );
	TE_SendToAll();
}
public void OnProjectileHit(NPCInstance entity, int inflictor, int victim) {
	float vel[3], ang[3], pos[3];
	char model[PLATFORM_MAX_PATH];
	
	Entity_GetModel(inflictor, model, sizeof(model));
	Entity_GetAbsOrigin(inflictor, pos);
	Entity_GetAbsVelocity(inflictor, vel);
	GetVectorAngles(vel, ang);
	
	int ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(ent, "model", model);
	DispatchKeyValue(ent, "OnUser1", "!self,Kill,,5.0,-1");
	DispatchKeyValue(ent, "solid", "0");
	DispatchSpawn(ent);
	
	if( victim > 0 ) {
		entity.Damage(victim, 10, inflictor, DMG_BULLET|DMG_SLASH);
		
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", victim);
	}
	
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	AcceptEntityInput(ent, "FireUser1");
}
public void OnSpawn(NPCInstance entity) {
	int animator = EntRefToEntIndex(DH_GetInstanceInt(entity, NPC_iAnimator));
	if( animator > 0 ) {		
		int head = GetRandomInt(0, 4);
		int torso = GetRandomInt(0, 2);
		int weapon = GetEntProp(animator, Prop_Send, "m_nBody");
		
		int body = head + (3 * torso) + weapon;
		SetEntProp(animator, Prop_Send, "m_nBody", body);
	}
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
