#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>
#include <precache>

char g_szFullName[PLATFORM_MAX_PATH] =	"Shuriken";
char g_szName[PLATFORM_MAX_PATH] 	 =	"shuriken";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/v_shuriken.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/w_shuriken.mdl";
char g_szTModel[PLATFORM_MAX_PATH] =    "models/dh/weapons/p_shuriken.mdl";

int g_cModel;

char g_szSounds[][PLATFORM_MAX_PATH] = {
	/*
	"physics/metal/bullet_metal_solid_01.wav",
	"physics/metal/bullet_metal_solid_02.wav",
	"physics/metal/bullet_metal_solid_03.wav",
	"physics/metal/bullet_metal_solid_04.wav",
	"physics/metal/bullet_metal_solid_05.wav",
	"physics/metal/bullet_metal_solid_06.wav",
	
	"physics/metal/metal_solid_impact_bullet1.wav",
	"physics/metal/metal_solid_impact_bullet2.wav",
	"physics/metal/metal_solid_impact_bullet3.wav",
	"physics/metal/metal_solid_impact_bullet4.wav",
	*/
	"physics/shield/bullet_hit_shield_01.wav",
	"physics/shield/bullet_hit_shield_02.wav",
	"physics/shield/bullet_hit_shield_03.wav",
	"physics/shield/bullet_hit_shield_04.wav",
	"physics/shield/bullet_hit_shield_05.wav",
	"physics/shield/bullet_hit_shield_06.wav",
	"physics/shield/bullet_hit_shield_07.wav",
	
	"weapons/hegrenade/explode3.wav",
	"weapons/hegrenade/explode4.wav",
	"weapons/hegrenade/explode5.wav"
};

public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "CWM-CORE") ) {
		int id = CWM_Create(g_szFullName, g_szName, g_szReplace, g_szVModel, g_szWModel);
	
		CWM_SetInt(id, WSI_AttackType,		view_as<int>(WSA_Automatic));
		CWM_SetInt(id, WSI_ReloadType,		view_as<int>(WSR_Automatic));
		CWM_SetInt(id, WSI_AttackDamage, 	25);
		CWM_SetInt(id, WSI_AttackBullet, 	1);
		CWM_SetInt(id, WSI_MaxBullet, 		250);
		CWM_SetInt(id, WSI_MaxAmmunition, 	500);
		
		CWM_SetFloat(id, WSF_Speed,			250.0);
		CWM_SetFloat(id, WSF_ReloadSpeed,	77/30.0);
		CWM_SetFloat(id, WSF_AttackSpeed,	8/30.0);
		CWM_SetFloat(id, WSF_AttackRange,	2048.0);
		CWM_SetFloat(id, WSF_Spread, 		0.0);
		
		CWM_AddAnimation(id, WAA_Idle, 		0,	189, 30);
		CWM_AddAnimation(id, WAA_Draw, 		1,	25, 30);
		CWM_AddAnimation(id, WAA_Pull, 		2,	25, 30);
		CWM_AddAnimation(id, WAA_Attack, 	3,  20, 30);
		CWM_AddAnimation(id, WAA_Attack, 	4,  20, 30);
		CWM_AddAnimation(id, WAA_Attack2, 	5,  45, 40);
		
		CWM_RegHook(id, WSH_Draw,			OnDraw);
		CWM_RegHook(id, WSH_Attack,			OnAttack);
		CWM_RegHook(id, WSH_Idle,			OnIdle);
		CWM_RegHook(id, WSH_Reload,			OnReload);
	}
}
public void OnDraw(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Draw);
}
public void OnIdle(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Idle);
}
public void OnReload(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Reload);
}
public Action OnAttack(int client, int entity) {
	static char sound[PLATFORM_MAX_PATH];
	CWM_RunAnimation(entity, WAA_Attack, 10/30.0);
	
	Format(sound, sizeof(sound), "dh/weapons/combustor_attack%d.mp3", GetRandomInt(1, 2));
	//EmitAmbientSound(sound, NULL_VECTOR, entity, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 1.0, GetRandomInt(90, 110));
	
	int ent = CWM_ShootProjectile(client, entity, g_szTModel, "shuriken", 1.0, 1024.0, OnProjectileHit);
	SetEntPropFloat(ent, Prop_Send, "m_flElasticity", 1.0);
	SetEntityMoveType(ent, MOVETYPE_FLY);
	DispatchKeyValue(ent, "OnUser1", "!self,KillHierarchy,,3.0,-1");
	AcceptEntityInput(ent, "FireUser1");
	
	TE_SetupBeamFollow(ent, g_cModel, g_cModel, 0.25, 1.0, 0.0, 0, {255, 128, 0, 64});
	TE_SendToAll();
	
	CreateTimer(0.01, OnProjectileSearch, EntIndexToEntRef(ent));
	
	return Plugin_Continue;
}

public Action OnProjectileHit(int client, int wpnid, int entity, int target) {
	static char sound[PLATFORM_MAX_PATH];
	float pos[3], vel[3];
	Entity_GetAbsOrigin(entity, pos);
	
	Format(sound, sizeof(sound), "physics/shield/bullet_hit_shield_0%d.wav", GetRandomInt(1, 7));
	EmitAmbientSound(sound, NULL_VECTOR, entity, SNDLEVEL_ROCKET, SND_NOFLAGS, 1.0, GetRandomInt(150, 175));
	SetEntPropEnt(entity, Prop_Send, "m_hEffectEntity", target);
	
	CreateTimer(0.01, OnProjectileSearch, EntIndexToEntRef(entity));
	return Plugin_Stop;
}
public Action OnProjectileSearch(Handle timer, any ref) {
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;
	
	int best = findNearestEnemy(ent, 512.0);
	if( best > 0 ) {
		float src[3], dst[3];
		Entity_GetAbsOrigin(ent, src);
		Entity_GetAbsOrigin(best, dst);
		
		dst[2] += 16.0;
		
		SubtractVectors(dst, src, src);
		GetVectorAngles(src, dst);
		NormalizeVector(src, src);
		ScaleVector(src, 1024.0);
		
		TeleportEntity(ent, NULL_VECTOR, dst, src);
	}
	
	return Plugin_Continue;
}
int findNearestEnemy(int entity, float dist=128.0) {
	int best = 0;
	int skip = GetEntPropEnt(entity, Prop_Send, "m_hEffectEntity");
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		if( i == skip )
			continue;
		if( HasEntProp(i, Prop_Send, "m_nHostageState") == false )
			continue;
		
		float tmp = Entity_GetDistance(entity, i);
		if( tmp < dist && DH_UTIL_IsInSightRange(entity, i, 180.0, dist) ) {
			dist = tmp;
			best = i;
		}
	}
	
	return best;
}
public void OnMapStart() {
	Precache_Model(g_szVModel);
	Precache_Model(g_szWModel);
	Precache_Model(g_szTModel);
	
	g_cModel = Precache_Model("materials/sprites/laserbeam.vmt");
	if( g_cModel ) { }
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}
