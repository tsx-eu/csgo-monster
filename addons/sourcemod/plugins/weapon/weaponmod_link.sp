#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>

char g_szFullName[PLATFORM_MAX_PATH] =	"Link Gun";
char g_szName[PLATFORM_MAX_PATH] 	 =	"link";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/v_pist_tec9.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/w_pist_tec9.mdl";
int g_cModel;

char g_szMaterials[][PLATFORM_MAX_PATH] = {
};
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
	CWM_RunAnimation(entity, WAA_Attack, 10/30.0);
	
	int view = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	int world = GetEntPropEnt(entity, Prop_Send, "m_hWeaponWorldModel");
	float vecSrc[3], vecDst[3], vecAngles[3];
	char tmp1[128], tmp2[128];
	
	GetClientEyePosition(client, vecSrc);
	GetClientEyeAngles(client, vecAngles);
	GetAngleVectors(vecAngles, vecDst, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(vecDst, 1024.0);
	AddVectors(vecSrc, vecDst, vecDst);
	
	int dst = CreateEntityByName("info_particle_system");
	Format(tmp1, sizeof(tmp1), "target1_%d", GetRandomInt(-99999, 99999));
	Format(tmp2, sizeof(tmp2), "target2_%d", GetRandomInt(-99999, 99999));

	DispatchKeyValue(dst, "OnUser1", "!self,KillHierarchy,,1.0,-1");
	DispatchKeyValue(dst, "targetname", tmp1);
	DispatchSpawn(dst);
	ActivateEntity(dst);
	AcceptEntityInput(dst, "FireUser1");
	
	SetVariantString("!activator");
	AcceptEntityInput(dst, "SetParent", view);
	
	TeleportEntity(dst, view_as<float>({1024.0, 0.0, 0.0}), NULL_VECTOR, NULL_VECTOR);
	
	int src = CreateEntityByName("info_particle_system");
	DispatchKeyValue(src, "OnUser1", "!self,KillHierarchy,,1.0,-1");
	DispatchKeyValue(src, "cpoint1", tmp1);
	DispatchKeyValue(src, "effect_name", "smoker_tongue");
	DispatchSpawn(src);
	ActivateEntity(src); 
	AcceptEntityInput(src, "FireUser1");
	AcceptEntityInput(src, "start");
	
	SetVariantString("!activator");
	AcceptEntityInput(src, "SetParent", view);
	
	SetVariantString("1");
	AcceptEntityInput(src, "SetParentAttachment");
	
	return Plugin_Continue;
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
