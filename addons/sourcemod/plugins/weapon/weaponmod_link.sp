#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>
#include <precache>

char g_szFullName[PLATFORM_MAX_PATH] =	"Link Gun";
char g_szName[PLATFORM_MAX_PATH] 	 =	"link";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/v_linkgun.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/w_linkgun.mdl";
int g_cModel;

enum struct PlayerData {
	int view;
	int world;
}

PlayerData g_pData[65];

char g_szSounds[][PLATFORM_MAX_PATH] = {
	"weapons/hegrenade/explode3.wav",
	"weapons/hegrenade/explode4.wav",
	"weapons/hegrenade/explode5.wav"
};

public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "CWM-CORE") ) {
		int id = CWM_Create(g_szFullName, g_szName, g_szReplace, g_szVModel, g_szWModel);
	
		CWM_SetInt(id, WSI_AttackType,		view_as<int>(WSA_LockAndLoad));
		CWM_SetInt(id, WSI_ReloadType,		view_as<int>(WSR_Automatic));
		CWM_SetInt(id, WSI_AttackDamage, 	25);
		CWM_SetInt(id, WSI_AttackBullet, 	1);
		CWM_SetInt(id, WSI_MaxBullet, 		250);
		CWM_SetInt(id, WSI_MaxAmmunition, 	500);
		
		CWM_SetFloat(id, WSF_Speed,			250.0);
		CWM_SetFloat(id, WSF_ReloadSpeed,	77/30.0);
		CWM_SetFloat(id, WSF_AttackSpeed,	0.1);
		CWM_SetFloat(id, WSF_AttackRange,	2048.0);
		CWM_SetFloat(id, WSF_Spread, 		0.0);
		
		CWM_AddAnimation(id, WAA_Idle, 		0,	185, 30);
		CWM_AddAnimation(id, WAA_Draw, 		1,	15, 20);
		CWM_AddAnimation(id, WAA_Pull, 		2,	15, 20);
		CWM_AddAnimation(id, WAA_Attack, 	3,  32, 30);
		CWM_AddAnimation(id, WAA_Attack, 	4,  32, 30);
		CWM_AddAnimation(id, WAA_Attack2, 	5,  45, 40);
		
		CWM_RegHook(id, WSH_Draw,			OnDraw);
		CWM_RegHook(id, WSH_Attack,			OnAttack);
		CWM_RegHook(id, WSH_AttackPost,		OnAttackPost);
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
	g_pData[client].view = CWM_CreateClientParticle(client, true, "linkgun", true, view_as<float>({ 256.0, 0.0, 0.0 }));
	g_pData[client].world = CWM_CreateClientParticle(client, false, "linkgun", false, NULL_VECTOR);
	
	SDKHook(client, SDKHook_PreThink, OnPreThink);
	return Plugin_Continue;
}
public Action OnAttackPost(int client, int entity) {
	CWM_RemoveClientParticle(g_pData[client].view);
	CWM_RemoveClientParticle(g_pData[client].world);
	
	SDKUnhook(client, SDKHook_PreThink, OnPreThink);
	return Plugin_Continue;
}
public void OnPreThink(int client) {
	float pos[3], ang[3], dir[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(dir, 256.0);
	AddVectors(pos, dir, dir);
	
	int dst = GetEntPropEnt(g_pData[client].world, Prop_Data, "m_hEffectEntity");
	TeleportEntity(dst, dir, NULL_VECTOR, NULL_VECTOR);
}

public void OnMapStart() {
	Precache_Model(g_szVModel);
	Precache_Model(g_szWModel);
	
	g_cModel = Precache_Model("materials/sprites/laserbeam.vmt");
	if( g_cModel ) { }
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}
