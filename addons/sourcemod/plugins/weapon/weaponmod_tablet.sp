#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>

char g_szFullName[PLATFORM_MAX_PATH] =	"Tablet";
char g_szName[PLATFORM_MAX_PATH] 	 =	"tablet";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_fists";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/v_tablet.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/v_tablet.mdl";


char g_szMaterials[][PLATFORM_MAX_PATH] = {
};

char g_szSounds[][PLATFORM_MAX_PATH] = {
};

public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "CWM-CORE") ) {
		int id = CWM_Create(g_szFullName, g_szName, g_szReplace, g_szVModel, g_szWModel);
	
		CWM_SetInt(id, WSI_AttackType,		view_as<int>(WSA_Automatic));
		CWM_SetInt(id, WSI_ReloadType,		view_as<int>(WSR_Automatic));
		CWM_SetInt(id, WSI_AttackDamage, 	0);
		CWM_SetInt(id, WSI_AttackBullet, 	0);
		CWM_SetInt(id, WSI_MaxBullet, 		0);
		CWM_SetInt(id, WSI_MaxAmmunition, 	0);
		
		CWM_SetFloat(id, WSF_Speed,			250.0);
		CWM_SetFloat(id, WSF_ReloadSpeed,	77/30.0);
		CWM_SetFloat(id, WSF_AttackSpeed,	0.1);
		CWM_SetFloat(id, WSF_AttackRange,	2048.0);
		CWM_SetFloat(id, WSF_Spread, 		0.0);
		
		CWM_AddAnimation(id, WAA_Draw, 		0,	16, 30);
		CWM_AddAnimation(id, WAA_Pull, 		1,	16, 30);
		CWM_AddAnimation(id, WAA_Idle, 		2,	1, 30);
		
		CWM_RegHook(id, WSH_Draw,			OnDraw);
		CWM_RegHook(id, WSH_Pull,			OnPull);
		CWM_RegHook(id, WSH_Attack,			OnAttack);
		CWM_RegHook(id, WSH_Idle,			OnIdle);
	}
}
public Action OnDraw(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Draw);
	SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD")|HIDEHUD_CROSSHAIR);
	Entity_AddFlags(client, FL_ATCONTROLS);
	FakeClientCommand(client, "say !cwm");
	return Plugin_Handled;
}
public Action OnPull(int client , int entity) {
	SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD")&~HIDEHUD_CROSSHAIR);
	Entity_RemoveFlags(client, FL_ATCONTROLS);
	return Plugin_Continue;
}
public void OnIdle(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Idle);
}
public void OnReload(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Reload);
}

public Action OnAttack(int client, int entity) {
	return Plugin_Continue;
}
public void OnMapStart() {
	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	
	/*
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		AddSoundToDownloadsTable(g_szSounds[i]);
		PrecacheSound(g_szSounds[i]);
	}
	*/
	
	for (int i = 0; i < sizeof(g_szMaterials); i++) {
		AddFileToDownloadsTable(g_szMaterials[i]);
	}
}
