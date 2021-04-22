#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>

char g_szFullName[PLATFORM_MAX_PATH] =	"Mr. Zurkon";
char g_szName[PLATFORM_MAX_PATH] 	 =	"zurkon";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/v_pist_tec9.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/w_pist_tec9.mdl";
char g_szPModel[PLATFORM_MAX_PATH] =	"models/dh/weapons/zurkon.mdl";

int g_cModel;

char g_szMaterials[][PLATFORM_MAX_PATH] = {
	"dh/weapons/zurkon/albedo.vtf",
	"dh/weapons/zurkon/mrzurkon_color.vmt",
	"dh/weapons/zurkon/mrzurkon_color.vtf",
	"dh/weapons/zurkon/mrzurkon_light.vtf"
};

char g_szSounds[][PLATFORM_MAX_PATH] = {	
	"dh/weapons/sentry_attack.mp3"
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
	
	float pos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	CreateZurkon(client, pos, ang);
	return Plugin_Continue;
}
// ------------------------------------------------------------------------------------------------
public void OnMapStart() {
	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	AddModelToDownloadsTable(g_szPModel);
	
	PrecacheModel(g_szPModel);
	
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
public void OnEntityDestroyed(int entity) {
	static char classname[128];
	if( entity > 0 ) {
		GetEdictClassname(entity, classname, sizeof(classname));
		if( StrEqual(classname, "zurkon") ) {
			float pos[3];
			Entity_GetAbsOrigin(entity, pos);
			ShowParticle(pos, "combustor_explode", 5.0);
		}
	}
}
Handle test;
// ------------------------------------------------------------------------------------------------
int CreateZurkon(int owner, float pos[3], float ang[3]) {
	
	int ent = CreateEntityByName("hegrenade_projectile");
	DispatchKeyValue(ent, "OnUser1", "!self,KillHierarchy,,30.0,-1");
	DispatchKeyValue(ent, "classname", "zurkon");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntityModel(ent, g_szPModel);
	SetEntityMoveType(ent, MOVETYPE_FLY);
	Entity_SetOwner(ent, owner);
	AcceptEntityInput(ent, "FireUser1");
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	
	RequestFrame(OnThink, EntIndexToEntRef(ent));
	
	int part = AttachParticle(ent, "hk22_seek", 99999.0);
	SetVariantString("booster");
	AcceptEntityInput(part, "SetParentAttachment");
	
	return ent;
}
public void OnThink(any ref) {
	int entity = EntRefToEntIndex(ref);
	if( entity <= 0 )
		return;
	
	int client = Entity_GetOwner(entity);
	if( !IsValidClient(client) ) {
		AcceptEntityInput(entity, "Kill");
		return;
	}
	
	float src[3], dst[3], ang[3], dir[3];
	Entity_GetAbsOrigin(entity, src);
	Entity_GetAbsOrigin(client, dst);
	GetClientEyeAngles(client, ang);
	
	{	// Velocity:
		dir = view_as<float>({48.0, 48.0, 64.0});
		Math_RotateVector(dir, ang, dir);
		AddVectors(dir, dst, dst);
		
		SubtractVectors(dst, src, dst);
		
		float speed = Math_InvLerp(0.0, 64.0, GetVectorLength(dst));
		if( speed > 1.0 )
			speed = 1.0;
		if( speed < 0.0 )
			speed = 0.0;
		
		NormalizeVector(dst, dst);
		ScaleVector(dst, speed * 256.0);
	}
	{ 	// Ang:
		Entity_GetAbsAngles(entity, dir);
		float interval = GetTickInterval();
		
		for(int i=0; i<2; i++) {
			float diff = Math_AngleDiff(ang[i], dir[i]);
			float speed = Math_InvLerp(0.0, 4.0, FloatAbs(diff)) * interval * 22.5;
			
			if( diff < -speed )
				dir[i] -= speed;
			else if( diff > speed )
				dir[i] += speed;
			else
				dir[i] = ang[i];
		}
	}
	
	TeleportEntity(entity, NULL_VECTOR, dir, dst);
	RequestFrame(OnThink, ref);
}
// ------------------------------------------------------------------------------------------------
stock float Math_Lerp(float a, float b, float n) {
	return (1 - n) * a + n * b;
}
stock float Math_InvLerp(float a, float b, float v) {
	return (v - a) / (b - a);
}
stock float Math_AngleDiff(float destAngle, float srcAngle) { 
	float delta = destAngle - srcAngle;
	
	if( destAngle > srcAngle ) {
		while (delta >= 180.0 )
			delta -= 360.0;
	}
	else {
		while (delta <= -180.0 )
			delta += 360.0;
	}
	return delta;
}
