#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>

char g_szFullName[PLATFORM_MAX_PATH] =	"Black-Hole Thrower";
char g_szName[PLATFORM_MAX_PATH] 	 =	"blackhole";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/v_pist_tec9.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/w_pist_tec9.mdl";
int g_cModel;


enum struct EntityData {
	float time;
	float size;
	int src;
	int dst;
}
EntityData g_hData[2049];
ArrayList g_hPtr;

char g_szMaterials[][PLATFORM_MAX_PATH] = {
};
char g_szSounds[][PLATFORM_MAX_PATH] = {	
	"weapons/hegrenade/explode3.wav",
	"weapons/hegrenade/explode4.wav",
	"weapons/hegrenade/explode5.wav"
};
public void OnPluginStart() {
	g_hPtr = new ArrayList();
}
public void OnEntityDestroyed(int entity) {
	int index = g_hPtr.FindValue(entity);
	if( index >= 0 )
		g_hPtr.Erase(index);
}
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
	static char tmp[PLATFORM_MAX_PATH];
	CWM_RunAnimation(entity, WAA_Attack, 10/30.0);
	
	int ent = CWM_ShootProjectile(client, entity, NULL_MODEL, "blackhole", 0.0, 0.0, OnProjectileHit);
	DispatchKeyValue(ent, "OnUser1", "!self,KillHierarchy,,30.0,-1");
	AcceptEntityInput(ent, "FireUser1");
	SetEntityMoveType(ent, MOVETYPE_FLY);
	
	int dst = CreateEntityByName("info_particle_system");
	Format(tmp, sizeof(tmp), "target_%d_%d", dst, GetRandomInt(-99999, 99999));

	DispatchKeyValue(dst, "OnUser1", "!self,KillHierarchy,,30.0,-1");
	DispatchKeyValue(dst, "targetname", tmp);
	DispatchSpawn(dst);
	ActivateEntity(dst);
	AcceptEntityInput(dst, "FireUser1");
	
	int src = CreateEntityByName("info_particle_system");
	DispatchKeyValue(src, "OnUser1", "!self,KillHierarchy,,30.0,-1");
	DispatchKeyValue(src, "OnUser1", "!self,DestroyImmediately,,30.0,-1");
	DispatchKeyValue(src, "cpoint1", tmp);
	DispatchKeyValue(src, "effect_name", "blackhole");
	DispatchSpawn(src);
	ActivateEntity(src); 
	
	SetVariantString("!activator");
	AcceptEntityInput(dst, "SetParent", ent);
	
	SetVariantString("!activator");
	AcceptEntityInput(src, "SetParent", ent);
	
	float size[3] = { 0.25, 0.0, 8.0 };
	TeleportEntity(dst, size, NULL_VECTOR, NULL_VECTOR);
	TeleportEntity(src, view_as<float>({ 0.0, 0.0, 8.0 }), NULL_VECTOR, NULL_VECTOR);
	
	AcceptEntityInput(src, "start");
	AcceptEntityInput(src, "FireUser1");
	AcceptEntityInput(src, "FireUser2");
	
	g_hData[ent].size = size[0];
	g_hData[ent].time = GetGameTime();
	g_hData[ent].src = src;
	g_hData[ent].dst = dst;
	g_hPtr.Push(ent);
	
	CreateTimer(0.25, OnThink, EntIndexToEntRef(ent), TIMER_REPEAT);
	return Plugin_Continue;
}
public Action OnThink(Handle timer, any ref) {	
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;

	float size[3];
	int len = g_hPtr.Length;
	
	for(int j=0; j<len; j++) {
		int i = g_hPtr.Get(j);
		if( i == ent )
			continue;
		
		if( g_hData[i].time > g_hData[ent].time && Entity_GetDistance(i, ent) < 16.0 ) {
			AcceptEntityInput(g_hData[ent].src, "DestroyImmediately");
			DispatchKeyValue(ent, "classname", "removing");
			DispatchKeyValue(ent, "OnUser1", "!self,KillHierarchy,,0.1,-1");
			AcceptEntityInput(ent, "FireUser1");
			g_hPtr.Erase(g_hPtr.FindValue(ent));
			
			g_hData[i].size += g_hData[ent].size;
			size[0] = g_hData[i].size;
			size[2] = 8.0;
			TeleportEntity(g_hData[i].dst, size, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, view_as<float>({ 0.0, 0.0, 0.0 }));
			return Plugin_Stop;
		}
	}
	
	return Plugin_Handled;
}
public Action OnProjectileHit(int client, int wpnid, int entity, int target) {
	return Plugin_Handled;
}

public void OnGameFrame() {
	static float src[3], dst[3], vel[3];
	static char classname[128];
	float dist = 0.0, delta = 0.0;
	bool changed = false;
	int len = g_hPtr.Length;
	
	if( len > 0 ) {
		for(int i=1; i<2049; i++) {
			if( !IsMoveAble(i) )
				continue;
			
			Entity_GetAbsOrigin(i, src);
			Entity_GetAbsVelocity(i, vel);
			changed = false;
			
			for(int j=0; j<len; j++) {
				int ent = g_hPtr.Get(j);
				if( ent == i )
					continue;
				
				Entity_GetAbsOrigin(ent, dst);
				dist = (256.0 * g_hData[ent].size);
				delta = GetVectorDistance(src, dst);
				
				if( delta < dist ) {
					SubtractVectors(dst, src, dst);
					NormalizeVector(dst, dst);
					ScaleVector(dst, (1.0 - (delta/ dist)) * 32.0);
					
					AddVectors(dst, vel, vel);
					changed = true;
				}
			}
			
			if( changed ) {
				SetEntityFlags(i, (GetEntityFlags(i)&~FL_ONGROUND) );
				if( HasEntProp(i, Prop_Send, "m_hGroundEntity") )
					SetEntPropEnt(i, Prop_Send, "m_hGroundEntity", -1);
				TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vel);
			}
		}
	} 
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
