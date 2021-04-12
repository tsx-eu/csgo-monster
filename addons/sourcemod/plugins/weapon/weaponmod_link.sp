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

enum struct PlayerData {
	Handle timer;
	int view;
	int world;
}

PlayerData g_pData[65];

char g_szMaterials[][PLATFORM_MAX_PATH] = {
};

char g_szSounds[][PLATFORM_MAX_PATH] = {
	"weapons/hegrenade/explode3.wav",
	"weapons/hegrenade/explode4.wav",
	"weapons/hegrenade/explode5.wav"
};

public void OnClientPostAdminCheck(int client) {
	g_pData[client].timer = null;
}
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
		
		CWM_AddAnimation(id, WAA_Idle, 		0,	1, 30);
		CWM_AddAnimation(id, WAA_Attack, 	1,  12, 30);
		CWM_AddAnimation(id, WAA_Attack, 	2,  12, 30);
		CWM_AddAnimation(id, WAA_Reload, 	3,	77, 30);
		CWM_AddAnimation(id, WAA_Draw, 		5,	30, 30);
		
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
	g_pData[client].view = createViewParticle(client);
	g_pData[client].world = createWorldParticle(client);
	
	// https://forums.alliedmods.net/showthread.php?p=2483070#post2483070
	SetFlags(g_pData[client].view);
	Entity_SetOwner(g_pData[client].view, client);
	SDKHook(g_pData[client].view, SDKHook_SetTransmit, OnSetTransmitView);
	
	SetFlags(g_pData[client].world);
	Entity_SetOwner(g_pData[client].world, client);
	SDKHook(g_pData[client].world, SDKHook_SetTransmit, OnSetTransmitWorld);
	
	
	SDKHook(client, SDKHook_PreThink, OnPreThink);
	return Plugin_Continue;
}
public Action OnAttackPost(int client, int entity) {
	AcceptEntityInput(GetEntPropEnt(g_pData[client].world, Prop_Data, "m_hEffectEntity"), "FireUser1");
	AcceptEntityInput(g_pData[client].world, "DestroyImmediately");
	AcceptEntityInput(g_pData[client].world, "FireUser1");
	
	AcceptEntityInput(GetEntPropEnt(g_pData[client].view,  Prop_Data, "m_hEffectEntity"), "FireUser1");
	AcceptEntityInput(g_pData[client].view,  "DestroyImmediately");
	AcceptEntityInput(g_pData[client].view,  "FireUser1");
	
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
int createWorldParticle(int client) {
	static char tmp[128];
	
	int entity = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	int world = GetEntPropEnt(entity, Prop_Send, "m_hWeaponWorldModel");
	
	int dst = CreateEntityByName("info_particle_system");
	Format(tmp, sizeof(tmp), "target_%d_%d", dst, GetRandomInt(-99999, 99999));

	DispatchKeyValue(dst, "OnUser1", "!self,KillHierarchy,,0.1,-1");
	DispatchKeyValue(dst, "targetname", tmp);
	DispatchSpawn(dst);
	ActivateEntity(dst);
	
	int src = CreateEntityByName("info_particle_system");
	DispatchKeyValue(src, "OnUser1", "!self,KillHierarchy,,0.1,-1");
	DispatchKeyValue(src, "cpoint1", tmp);
	DispatchKeyValue(src, "effect_name", "linkgun");
	DispatchSpawn(src);
	ActivateEntity(src); 

	AcceptEntityInput(src, "start");
	
	SetVariantString("!activator");
	AcceptEntityInput(src, "SetParent", world);
	
	SetVariantString("muzzle_flash");
	AcceptEntityInput(src, "SetParentAttachment");
	SetEntPropEnt(src, Prop_Data, "m_hEffectEntity", dst);
	
	return src;
	
}
int createViewParticle(int client) {
	static char tmp[128];
	
	int view = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	
	int dst = CreateEntityByName("info_particle_system");
	Format(tmp, sizeof(tmp), "target_%d_%d", dst, GetRandomInt(-99999, 99999));

	DispatchKeyValue(dst, "OnUser1", "!self,KillHierarchy,,0.1,-1");
	DispatchKeyValue(dst, "targetname", tmp);
	DispatchSpawn(dst);
	ActivateEntity(dst);
	
	SetVariantString("!activator");
	AcceptEntityInput(dst, "SetParent", view);
	
	TeleportEntity(dst, view_as<float>({256.0, 0.0, 0.0}), NULL_VECTOR, NULL_VECTOR);
	
	int src = CreateEntityByName("info_particle_system");
	DispatchKeyValue(src, "OnUser1", "!self,KillHierarchy,,0.1,-1");
	DispatchKeyValue(src, "cpoint1", tmp);
	DispatchKeyValue(src, "effect_name", "linkgun");
	DispatchSpawn(src);
	ActivateEntity(src); 

	AcceptEntityInput(src, "start");
	
	SetVariantString("!activator");
	AcceptEntityInput(src, "SetParent", view);
	
	SetVariantString("1");
	AcceptEntityInput(src, "SetParentAttachment");
	SetEntPropEnt(src, Prop_Data, "m_hEffectEntity", dst);
	
	return src;
}
public Action OnSetTransmitView(int entity, int client) {
	SetFlags(entity);
	
	if( Entity_GetOwner(entity) == client )
		return Plugin_Continue;
	return Plugin_Stop;
}
public Action OnSetTransmitWorld(int entity, int client) {
	SetFlags(entity);
	
	if( Entity_GetOwner(entity) != client )
		return Plugin_Continue;
	return Plugin_Stop;
}

public void SetFlags(int ent) {
    if( GetEdictFlags(ent) & FL_EDICT_ALWAYS )
    	SetEdictFlags(ent, (GetEdictFlags(ent) ^ FL_EDICT_ALWAYS)); 
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
