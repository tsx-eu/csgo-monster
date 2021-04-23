#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>
#include <precache>

char g_szFullName[PLATFORM_MAX_PATH] =	"Bouncer";
char g_szName[PLATFORM_MAX_PATH] 	 =	"bouncer";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/v_pist_tec9.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/w_pist_tec9.mdl";
char g_szTModel[PLATFORM_MAX_PATH] =	"models/grenades/mirv/mirv.mdl";
char g_szPModel[PLATFORM_MAX_PATH] =	"models/grenades/mirv/mirvlet.mdl";
int g_cModel;

char g_szSounds[][PLATFORM_MAX_PATH] = {	
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
		
		CWM_AddAnimation(id, WAA_Idle, 		0,	1, 30);
		CWM_AddAnimation(id, WAA_Attack, 	1,  12, 30);
		CWM_AddAnimation(id, WAA_Attack, 	2,  12, 30);
		CWM_AddAnimation(id, WAA_Reload, 	3,	77, 30);
		CWM_AddAnimation(id, WAA_Draw, 		5,	30, 30);
		
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
	
	int ent = CWM_ShootProjectile(client, entity, g_szTModel, "mirv", 1.0, 1024.0, OnProjectileHit);
	
	TE_SetupBeamFollow(ent, g_cModel, g_cModel, 0.25, 2.0, 0.0, 0, {255, 255, 255, 64});
	TE_SendToAll();
	return Plugin_Continue;
}

public Action OnProjectileHit(int client, int wpnid, int entity, int target) {
	static char sound[PLATFORM_MAX_PATH];
	float pos[3], vel[3];
	Entity_GetAbsOrigin(entity, pos);
	
	Format(sound, sizeof(sound), "weapons/hegrenade/explode%d.wav", GetRandomInt(3, 5));
	EmitAmbientSound(sound, NULL_VECTOR, entity, SNDLEVEL_ROCKET, SND_NOFLAGS, 1.0, GetRandomInt(150, 175));
	ShowParticle(pos, "combustor_explode", 5.0);
	
	for(int i=0; i<8; i++) {
		int ent = CWM_ShootProjectile(client, wpnid, g_szPModel, "mirvlet", 0.1, 0.0, OnProjectileHit2);
		SetEntPropFloat(ent, Prop_Send, "m_flElasticity", GetRandomFloat(0.8, 1.2));
		TE_SetupBeamFollow(ent, g_cModel, g_cModel, 0.25, 1.0, 0.0, 0, {255, 255, 255, 64});
		TE_SendToAll();
		
		vel[0] = GetRandomFloat(-1.0, 1.0);
		vel[1] = GetRandomFloat(-1.0, 1.0);
		vel[2] = 0.0;
		
		NormalizeVector(vel, vel);
		ScaleVector(vel, 128.0);
		
		vel[2] = GetRandomFloat(256.0, 256+128.0);
		TeleportEntity(ent, pos, NULL_VECTOR, vel);
		CreateTimer(0.1, OnProjectileThink, EntIndexToEntRef(ent), TIMER_REPEAT);
	}
	
	return Plugin_Handled;
}
public Action OnProjectileHit2(int client, int wpnid, int entity, int target) {
	float pos[3];
	Entity_GetAbsOrigin(entity, pos);
	
	float speed = GetEntPropFloat(entity, Prop_Send, "m_flElasticity") * 0.8;
	SetEntPropFloat(entity, Prop_Send, "m_flElasticity", speed);
	
	return Plugin_Stop;
}
public Action OnProjectileThink(Handle timer, any ref) {
	static char sound[PLATFORM_MAX_PATH];
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;
	
	float pos[3], vel[3];
	Entity_GetAbsOrigin(ent, pos);
	Entity_GetAbsVelocity(ent, vel);
	
	if( GetVectorLength(vel) < 8.0 ) {
		Format(sound, sizeof(sound), "weapons/hegrenade/explode%d.wav", GetRandomInt(3, 5));
		EmitAmbientSound(sound, NULL_VECTOR, ent, SNDLEVEL_ROCKET, SND_NOFLAGS, 0.5, GetRandomInt(150, 175));
		ShowParticle(pos, "combustor_explode", 5.0);
		AcceptEntityInput(ent, "Kill");
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
public void OnMapStart() {
	Precache_Model(g_szVModel);
	Precache_Model(g_szWModel);
	Precache_Model(g_szTModel);
	Precache_Model(g_szPModel);
	
	g_cModel = Precache_Model("materials/sprites/laserbeam.vmt");
	if( g_cModel ) { }
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}