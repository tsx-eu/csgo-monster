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
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/v_tablet.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/v_tablet.mdl";
int g_cModel;


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
	SDKHook(client, SDKHook_PreThink, OnThink);
	return Plugin_Handled;
}
public Action OnPull(int client , int entity) {
	SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD")&~HIDEHUD_CROSSHAIR);
	SDKUnhook(client, SDKHook_PreThink, OnThink);
	return Plugin_Continue;
}
public void OnIdle(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Idle);
}
public void OnReload(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Reload);
}
public void OnThink(int client) {
	static int buttons[65][16];
	
	buttons[client][3] = 1;
	buttons[client][4] = 1;
	buttons[client][5] = 1;
	buttons[client][6] = 1;
	buttons[client][7] = 1;
	buttons[client][8] = 2;
	buttons[client][9] = 1;
	
	
	int view = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	int val = 0;
	for(int i=0; i<15; i++)
		val += RoundFloat(Pow(3.0, float(i)) * buttons[client][i]);
	
	SetEntProp(view, Prop_Send, "m_nBody", val);
}
public Action OnAttack(int client, int entity) {
	return Plugin_Continue;
}
public void OnMapStart() {
	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	
	g_cModel = PrecacheModel("materials/particle/smoker_tongue_beam.vmt");
	
	/*
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		AddSoundToDownloadsTable(g_szSounds[i]);
		PrecacheSound(g_szSounds[i]);
	}

	for (int i = 0; i < sizeof(g_szMaterials); i++) {
		AddFileToDownloadsTable(g_szMaterials[i]);
	}
	*/
}
