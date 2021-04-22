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
	
	
	SetEntProp(ent, Prop_Data, "m_iHealth", 100);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	SetEntityModel(ent, g_szPModel);
	SetEntityMoveType(ent, MOVETYPE_FLY);
	Entity_SetOwner(ent, owner);
	Entity_SetSolidType(ent, SOLID_NONE);
	Entity_SetSolidFlags(ent, FSOLID_NOT_SOLID);
	Entity_SetCollisionGroup(ent, COLLISION_GROUP_NONE);
	
	AcceptEntityInput(ent, "FireUser1");
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	
	RequestFrame(OnThink, EntIndexToEntRef(ent));
	CreateTimer(0.25, OnProjectileThink, EntIndexToEntRef(ent), TIMER_REPEAT);
	
	int part = AttachParticle(ent, "hk22_seek", 30.0);
	SetVariantString("booster");
	AcceptEntityInput(part, "SetParentAttachment");
	
	return ent;
}

public Action OnProjectileThink(Handle timer, any ref) {
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;
	
	int old = GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity");
	
	if( old == -1 || DH_UTIL_IsInSightRange(ent, old, 512.0, 45.0) == false ) {
		int proposal = findNearestEnemy(ent, 1024.0, 90.0);
		
		if( old > 0 && proposal > 0 ) {
			float src[3][3], ang[3][3];
			Entity_GetAbsAngles(ent, ang[0]);
			
			Entity_GetAbsOrigin(ent, src[0]);
			Entity_GetAbsOrigin(old, src[1]);
			Entity_GetAbsOrigin(proposal, src[2]);
			
			SubtractVectors(src[1], src[0], src[1]);
			SubtractVectors(src[2], src[0], src[2]);
			
			GetVectorAngles(src[1], ang[1]);
			GetVectorAngles(src[2], ang[2]);
			
			if( FloatAbs(Math_AngleDiff(ang[0][1], ang[2][1])) < FloatAbs(Math_AngleDiff(ang[0][1], ang[1][1])) ) {
				old = proposal;
			}
		}
		else {
			old = proposal;
		}
		
		SetEntPropEnt(ent, Prop_Data, "m_hEffectEntity", proposal);
	}
		
	return Plugin_Continue;
}

public void OnThink(any ref) {
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return;
	
	int owner = Entity_GetOwner(ent);
	if( !IsValidClient(owner) || Entity_GetHealth(ent) <= 0 ) {
		AcceptEntityInput(ent, "Kill");
		return;
	}
	
	float last = GetEntPropFloat(ent, Prop_Data, "m_flWarnAITime");
	float fire = 0.5;
	
	float src[3], dst[3], ang[3], dir[3], tmp[3];
	Entity_GetAbsOrigin(ent, src);
	Entity_GetAbsOrigin(owner, dst);
	
	int enemy = GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity");
	if( enemy > 0 ) {
		Entity_GetAbsOrigin(enemy, tmp);
		SubtractVectors(tmp, src, tmp);
		GetVectorAngles(tmp, ang);
		
		if( last+fire < GetGameTime() ) {
			SetEntPropFloat(ent, Prop_Data, "m_flWarnAITime", GetGameTime());
			
			float vecOrigin[3], vecAngles[3], vecDir[3];
			DH_UTIL_GetAttachment(ent, "weapon", vecOrigin, vecAngles);
			
			GetAngleVectors(vecAngles, vecDir, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(vecDir, -2048.0);
			
			int projectil = CreateEntityByName("hegrenade_projectile");
			DispatchKeyValue(projectil, "classname", "zurkon_gunfire");
			DispatchSpawn(projectil);
			
			SetEntPropEnt(projectil, Prop_Send, "m_hOwnerEntity", owner);
			SetEntPropEnt(projectil, Prop_Data, "m_hThrower", ent);
			SetEntityMoveType(projectil, MOVETYPE_FLY);
			
			Entity_SetSolidType(projectil, SOLID_VPHYSICS);
			Entity_SetSolidFlags(projectil, FSOLID_TRIGGER);
			Entity_SetCollisionGroup(projectil, COLLISION_GROUP_PLAYER);
			
			SetEntityRenderMode(projectil, RENDER_NONE);
			
			TeleportEntity(projectil, vecOrigin, vecAngles, vecDir);
			SDKHook(projectil, SDKHook_StartTouch, CWM_ProjectileTouch);
			AttachParticle(projectil, "turret_gunfire", 5.0);
			
			EmitAmbientSound("dh/weapons/sentry_attack.mp3", NULL_VECTOR, projectil, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 0.25, GetRandomInt(90, 110));
		}
	}
	else {
		GetClientEyeAngles(owner, ang);
	}
	
	{	// Velocity:
		GetClientEyeAngles(owner, tmp);
		Math_RotateVector(view_as<float>({48.0, 48.0, 64.0}), tmp, dir);
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
		Entity_GetAbsAngles(ent, dir);
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
	
	TeleportEntity(ent, NULL_VECTOR, dir, dst);
	RequestFrame(OnThink, ref);
}
public Action CWM_ProjectileTouch(int ent, int target) {
	int owner = GetEntPropEnt(ent, Prop_Data, "m_hThrower");
	if( owner > 0 )
		Entity_SetHealth(owner, Entity_GetHealth(owner) - 1);
	AcceptEntityInput(ent, "KillHierarchy");
	return Plugin_Handled;
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

int findNearestEnemy(int entity, float dist=128.0, float ang=180.0) {
	int best = -1;
	
	for(int i=1; i<=2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		if( HasEntProp(i, Prop_Send, "m_nHostageState") == false )
			continue;
		
		float tmp = Entity_GetDistance(entity, i);
		if( tmp < dist && DH_UTIL_IsInSightRange(entity, i, ang, dist) ) {
			dist = tmp;
			best = i;
		}
	}
	
	return best;
}