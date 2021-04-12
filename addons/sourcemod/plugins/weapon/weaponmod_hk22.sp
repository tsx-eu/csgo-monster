#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>

char g_szFullName[PLATFORM_MAX_PATH] =	"HK22";
char g_szName[PLATFORM_MAX_PATH] 	 =	"HK22";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/v_pist_tec9.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/w_pist_tec9.mdl";
char g_szTModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/p_hk22.mdl";
int g_cModel;

char g_szMaterials[][PLATFORM_MAX_PATH] = {
};
char g_szSounds[][PLATFORM_MAX_PATH] = {	
	"dh/weapons/hk22_attack.mp3",
	"dh/weapons/hk22_flying.mp3",
	"dh/weapons/hk22_explod.mp3"
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
	
	EmitAmbientSound("dh/weapons/hk22_attack.mp3", NULL_VECTOR, entity, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
	CWM_RunAnimation(entity, WAA_Attack, 10/30.0);
	
	int ent = CWM_ShootProjectile(client, entity, g_szTModel, "rocket", 0.0, 400.0, OnProjectileHit);
	SetEntityMoveType(ent, MOVETYPE_FLY);
	SetEntPropEnt(ent, Prop_Send, "m_hEffectEntity", AttachParticle(ent, "hk22_seek", 30.0));
	
	TE_SetupBeamFollow(ent, g_cModel, g_cModel, 0.25, 1.0, 0.0, 0, {0, 128, 255, 64});
	TE_SendToAll();
	
	
	EmitAmbientSound("dh/weapons/hk22_flying.mp3", NULL_VECTOR, entity, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
	CreateTimer(0.1, OnProjectileThink, EntIndexToEntRef(ent), TIMER_REPEAT);
	CreateTimer(1.5, OnProjectileFlying, EntIndexToEntRef(ent), TIMER_REPEAT);
	
	return Plugin_Continue;
}
public Action OnProjectileFlying(Handle timer, any ref) {
	int entity = EntRefToEntIndex(ref);
	if( entity <= 0 )
		return Plugin_Stop;
	
	EmitAmbientSound("dh/weapons/hk22_flying.mp3", NULL_VECTOR, entity, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 0.2, GetRandomInt(90, 110));
	return Plugin_Continue;
}
int findNearestEnemy(int entity, float dist=128.0) {
	int best = 0;
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
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
public Action OnProjectileThink(Handle timer, any ref) {
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;
	
	int best = findNearestEnemy(ent, 128.0);
	if( best > 0 ) {
		float src[3], dst[3];
		Entity_GetAbsOrigin(ent, src);
		Entity_GetAbsOrigin(best, dst);
		dst[2] += 16.0;
		
		SubtractVectors(dst, src, src);
		GetVectorAngles(src, dst);
		NormalizeVector(src, src);
		ScaleVector(src, -256.0);
		
		TeleportEntity(ent, NULL_VECTOR, dst, src);
		CreateTimer(0.1, OnProjectileThink2, EntIndexToEntRef(ent));
		CreateTimer(0.30, OnProjectileThink3, EntIndexToEntRef(ent));
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
public Action OnProjectileThink2(Handle timer, any ref) {
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;
	
	float vel[3];
	Entity_GetAbsVelocity(ent, vel);
	NormalizeVector(vel, vel);
	ScaleVector(vel, 64.0);
	Entity_SetAbsVelocity(ent, vel);

	int child = GetEntPropEnt(ent, Prop_Send, "m_hEffectEntity");
	if( IsValidEdict(child) && IsValidEntity(child) )
		AcceptEntityInput(child, "Kill");
	SetEntPropEnt(ent, Prop_Send, "m_hEffectEntity", AttachParticle(ent, "hk22_attack", 5.0));

	return Plugin_Continue;
}

public Action OnProjectileThink3(Handle timer, any ref) {
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;
	
	float vel[3];
	Entity_GetAbsVelocity(ent, vel);
	NormalizeVector(vel, vel);
	ScaleVector(vel, -2048.0);
	Entity_SetAbsVelocity(ent, vel);
	TE_SetupBeamFollow(ent, g_cModel, g_cModel, 0.25, 1.0, 0.0, 0, {255, 0, 0, 64});
	TE_SendToAll();

	return Plugin_Continue;
}
public Action OnProjectileHit(int client, int wpnid, int entity, int target) {
	float pos[3];
	Entity_GetAbsOrigin(entity, pos);
	
	EmitAmbientSound("dh/weapons/hk22_explod.mp3", pos, SOUND_FROM_WORLD, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
	
	ShowParticle(pos, "combustor_explode", 5.0);
	return Plugin_Handled;
}

public void OnMapStart() {
	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	
	g_cModel = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		AddSoundToDownloadsTable(g_szSounds[i]);
		PrecacheSound(g_szSounds[i]);
	}
	
	/*
	for (int i = 0; i < sizeof(g_szMaterials); i++) {
		AddFileToDownloadsTable(g_szMaterials[i]);
	}
	*/
}
