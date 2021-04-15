#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>

char g_szFullName[PLATFORM_MAX_PATH] =	"Blitz Cannon";
char g_szName[PLATFORM_MAX_PATH] 	 =	"blitz";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/v_pist_tec9.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/w_pist_tec9.mdl";
int g_cModel;

char g_szMaterials[][PLATFORM_MAX_PATH] = {
};

char g_szSounds[][PLATFORM_MAX_PATH] = {
	"dh/weapons/blitz_attack.mp3",
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
		CWM_SetFloat(id, WSF_AttackSpeed,	1.0);
		CWM_SetFloat(id, WSF_AttackRange,	512.0);
		CWM_SetFloat(id, WSF_Spread, 		30.0);
		
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
	float hit[3];
	
	for(int i=0; i<12; i++) {
		int target = CWM_ShootRay(client, entity, false, hit);
		
		if( target >= 0 )
			ShowParticle(hit, "blitzcannon_explode", 1.0);
		
		CWM_RemoveClientParticle(CWM_CreateClientParticle(client, true,  "blitzcannon", false, hit), 1.0);
		CWM_RemoveClientParticle(CWM_CreateClientParticle(client, false, "blitzcannon", false, hit), 1.0);
	}
	
	CWM_ShellOut(client, entity, WMT_AutoShotgun, WST_Shotgun, WTT_None);
	SetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", view_as<float>({-200.0, -50.0, 0.0}));
	EmitAmbientSound("dh/weapons/blitz_attack.mp3", NULL_VECTOR, entity, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
	
	return Plugin_Continue;
}

public void OnMapStart() {
	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	
	g_cModel = PrecacheModel("materials/particle/smoker_tongue_beam.vmt");
	
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
