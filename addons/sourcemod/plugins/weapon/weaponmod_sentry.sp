#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <custom_weapon_mod>

char g_szFullName[PLATFORM_MAX_PATH] =	"Sentry Gun";
char g_szName[PLATFORM_MAX_PATH] 	 =	"sentry";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_tec9";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/v_pist_tec9.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/w_pist_tec9.mdl";
char g_szPModel[PLATFORM_MAX_PATH] =	"models/props_survival/dronegun/dronegun.mdl";

#define SENTRY_ANGLE		0.5
#define	SENTRY_DIST			1024.0

enum {
	STATE_TURN_LEFT,
	STATE_TURN_RIGHT
};

int g_cModel;

char g_szMaterials[][PLATFORM_MAX_PATH] = {
};

char g_szSounds[][PLATFORM_MAX_PATH] = {
	"survival/turret_idle_01.wav",
	"survival/turret_sawplayer_01.wav",
	"survival/turret_lostplayer_03.wav",
	
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
	
	int ent = CWM_ShootProjectile(client, entity, g_szPModel, "rocket", 1.0, 400.0, OnProjectileHit);
	
	TE_SetupBeamFollow(ent, g_cModel, g_cModel, 0.25, 1.0, 0.0, 0, {0, 128, 255, 64});
	TE_SendToAll();
	
	return Plugin_Continue;
}
public Action OnProjectileHit(int client, int wpnid, int entity, int target) {
	float pos[3], ang[3];
	Entity_GetAbsOrigin(entity, pos);
	Entity_GetAbsAngles(entity, ang);
	
	ang[0] = ang[2] = 0.0;
	
	int sentry = CreateSentry(client, pos, ang);
	DispatchKeyValue(sentry, "OnUser1", "!self,KillHierarchy,,30.0,-1");
	AcceptEntityInput(sentry, "FireUser1");
	
	return Plugin_Handled;
}
// ------------------------------------------------------------------------------------------------
public void OnMapStart() {
	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	AddModelToDownloadsTable(g_szPModel);
	
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
		if( StrEqual(classname, "sentry") ) {
			float pos[3];
			Entity_GetAbsOrigin(entity, pos);
			ShowParticle(pos, "combustor_explode", 5.0);
		}
	}
}
// ------------------------------------------------------------------------------------------------
int CreateSentry(int owner, float pos[3], float ang[3]) {	
	int ent = CreateEntityByName("monster_generic");
	DispatchKeyValue(ent, "classname", "sentry");
	DispatchKeyValue(ent, "model", g_szPModel);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	Entity_SetOwner(ent, owner);
	SetEntityFlags(ent, 262144);
	SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
	SetEntProp(ent, Prop_Data, "m_lifeState", 0);
	SetEntProp(ent, Prop_Data, "m_iHealth", 10);
	Entity_SetMaxHealth(ent, Entity_GetHealth(ent));
	
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	SDKHook(ent, SDKHook_Think, OnThink);	
	return ent;
}
void getTargetAngle(int ent, int target, float& tilt, float& yaw) {
	float src[3], dst[3], dir[3], ang[3];
	Entity_GetAbsOrigin(ent, src);
	Entity_GetAbsAngles(ent, ang);
	Entity_GetAbsOrigin(target, dst);
	
	src[2] += 40.0;
	dst[2] += 40.0;

	MakeVectorFromPoints(dst, src, dir);
	GetVectorAngles(dir, dst);
	ang[0] = dst[0] - ang[0];
	ang[1] = dst[1] - ang[1];
	
	ang[1] = AngleMod(ang[1]);
	if( ang[0] < -180.0 )
		ang[0] += 360.0;
	if( ang[0] >  180.0 )
		ang[0] -= 360.0;

	if( ang[0] > 45.0 )
		ang[0] = 45.0;
	if( ang[0] < -45.0 )
		ang[0] = -45.0;
	
	yaw  = 0.5 - (ang[0] / 90.0);
	tilt = ang[1] / 360.0;
}
void moveToTarget(int ent, int enemy, float speed, float& tilt, float& yaw) {
	float tilt2, yaw2;
	getTargetAngle(ent, enemy, tilt2, yaw2);
	
	if( FloatAbs(tilt - tilt2) > speed ) {
		if( tilt2 > tilt )
			tilt += speed;
		else if( tilt2 < tilt )
			tilt -= speed;
	}
	else {
		tilt = tilt2;
	}
	
	if( FloatAbs(yaw - yaw2) > speed ) {
		if( yaw2 > yaw )
			yaw += speed;
		else if( yaw2 < yaw )
			yaw -= speed;
	}
	else {
		yaw = yaw2;
	}
}
int getEnemy(int ent, float src[3], float ang[3], float& tilt, float threshold) {
	float dst[3];
	
	if( false ) {
		Handle trace;
		ang[1] += threshold * 360.0;
		trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterSelf, ent);
		if( TR_DidHit(trace) ) {
			TR_GetEndPosition(dst, trace);
			
			TE_SetupBeamPoints(src, dst, g_cModel, 0, 0, 0, 1.0, 1.0, 1.0, 0, 0.0, { 0, 0, 250, 200 }, 0);
			TE_SendToAll();
		}
		delete trace;
		
		ang[1] -= threshold * 360.0;
		ang[1] -= threshold * 360.0;
		trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterSelf, ent);
		if( TR_DidHit(trace) ) {
			TR_GetEndPosition(dst, trace);
			
			TE_SetupBeamPoints(src, dst, g_cModel, 0, 0, 0, 1.0, 1.0, 1.0, 0, 0.0, { 0, 0, 250, 200 }, 0);
			TE_SendToAll();
		}
		delete trace;
		ang[1] += threshold * 360.0;
	}
	
	int nearest = 0;
	float dist = SENTRY_DIST*SENTRY_DIST;
	
	for (int i = 1; i <= 2048; i++) {
		if( !IsValidEdict(i) || !IsValidEntity(i) )
			continue;
		if( HasEntProp(i, Prop_Send, "m_nHostageState") == false )
			continue;
		
		Entity_GetAbsOrigin(i, dst);
		dst[2] += 40.0;
		float tmp = GetVectorDistance(src, dst, true);
					
		if( tmp < dist ) {
			float tilt2, yaw2;
			getTargetAngle(ent, i, tilt2, yaw2);
			if( tilt2 > 0.5 - SENTRY_ANGLE/2 && tilt2 < 0.5 + SENTRY_ANGLE/2 && FloatAbs(tilt-tilt2) <= threshold ) {
				
				Handle trace = TR_TraceRayFilterEx(src, dst, MASK_SHOT, RayType_EndPoint, TraceEntityFilterSelf, ent);

				if( TR_DidHit(trace) ) {
					int y = TR_GetEntityIndex(trace);
					
					if( y == i ) {
						dist = tmp;
						nearest = i;
					}
				}
				delete trace;
			}
		}
	}
	
	return nearest;
}
public Action CWM_ProjectileTouch(int ent, int target) {
	int owner = GetEntPropEnt(ent, Prop_Data, "m_hThrower");
	if( owner > 0 )
		Entity_SetHealth(owner, Entity_GetHealth(owner) - 1);
	AcceptEntityInput(ent, "KillHierarchy");
	
	return Plugin_Handled;
}
public void OnThink(int ent) {
	float tilt = GetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", 0);
	float yaw = GetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", 1);
	float last = GetEntPropFloat(ent, Prop_Data, "m_flLastAttackTime");
	int state = GetEntProp(ent, Prop_Data, "m_iInteractionState");
	int oldEnemy = GetEntPropEnt(ent, Prop_Data, "m_hInteractionPartner");
	int owner = Entity_GetOwner(ent);
	int heal = Entity_GetHealth(ent);

	int damage = 10;
	float push = 128.0;
	float fire = 0.125;
	float speed = (5.0/360.0);
	float threshold = (45.0/360.0)/2.0;

	float src[3], ang[3], dst[3], dir[3], vel[3];
	Entity_GetAbsOrigin(ent, src);
	Entity_GetAbsAngles(ent, ang);
	src[2] += 43.0; 
	
	if( heal <= 0 || !IsValidClient(owner) ) {
		AcceptEntityInput(ent, "Kill");
		return;
	}
	
	ang[0] = ang[0] + (yaw-0.5) * 90.0;
	ang[1] = ang[1] + AngleMod(180.0 + (tilt * 360.0));
	
	if( false ) {
		Handle trace = TR_TraceRayFilterEx(src, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterSelf, ent);
		if( TR_DidHit(trace) ) {
			TR_GetEndPosition(dst, trace);
			
			TE_SetupBeamPoints(src, dst, g_cModel, 0, 0, 0, 1.0, 1.0, 1.0, 0, 0.0, { 250, 0, 0, 200 }, 0);
			TE_SendToAll();
		}
		delete trace;
	}
	
	
	int newEnemy = getEnemy(ent, src, ang, tilt, threshold);
	if( newEnemy > 0 ) {
		if( oldEnemy == 0 )
			EmitSoundToAll("survival/turret_sawplayer_01.wav", ent);
		
		moveToTarget(ent, newEnemy, speed, tilt, yaw);
		if( last+fire < GetGameTime() ) {
			SetEntPropFloat(ent, Prop_Data, "m_flLastAttackTime", GetGameTime());
			
			float vecOrigin[3], vecAngles[3], vecDir[3];
			DH_UTIL_GetAttachment(ent, "muzzle", vecOrigin, vecAngles);
			GetAngleVectors(vecAngles, vecDir, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(vecDir, 2048.0);
			
			int projectil = CreateEntityByName("hegrenade_projectile");
			DispatchKeyValue(projectil, "classname", "sentry_gunfire");
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
			
			EmitAmbientSound("dh/weapons/sentry_attack.mp3", NULL_VECTOR, projectil, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 0.5, GetRandomInt(90, 110));
		}
	}
	else {
		if( oldEnemy > 0 )
			EmitSoundToAll("survival/turret_lostplayer_03.wav", ent);
		
		if( state == STATE_TURN_LEFT ) {
			tilt += speed;
			
			if( tilt > 0.5 + SENTRY_ANGLE/2 ) {
				tilt = 0.5 + SENTRY_ANGLE/2;
				state = STATE_TURN_RIGHT;
				EmitSoundToAll("survival/turret_idle_01.wav", ent);
			}
		}
		else {
			tilt -= speed;
			
			if( tilt < 0.5 - SENTRY_ANGLE/2 ) {
				tilt = 0.5 - SENTRY_ANGLE/2;
				state = STATE_TURN_LEFT;
				EmitAmbientSound("survival/turret_idle_01.wav", NULL_VECTOR, ent);
			}
		}
		
		if( yaw+speed > 0.5 && yaw-speed < 0.5 )
			yaw = 0.5;
		else if( yaw > 0.5 )
			yaw -= speed;
		else if( yaw < 0.5 )
			yaw += speed;
	}
	
	SetEntPropEnt(ent, Prop_Data, "m_hInteractionPartner", newEnemy);
	SetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", tilt, 0);
	SetEntPropFloat(ent, Prop_Send, "m_flPoseParameter", yaw, 1);
	SetEntProp(ent, Prop_Data, "m_iInteractionState", state);
}
// ------------------------------------------------------------------------------------------------
float AngleMod(float flAngle) { 
    flAngle = (360.0 / 65536) * (RoundToNearest(flAngle * (65536.0 / 360.0)) & 65535); 
    return flAngle; 
}
public bool TraceEntityFilterSelf(int entity, int contentsMask, any data) {
	if( entity > 0 && HasEntProp(entity, Prop_Data, "m_hThrower") && GetEntPropEnt(entity, Prop_Data, "m_hThrower") == data )
		return false;
	
	return entity != data;
}
public bool TraceEntityFilterSentry(int entity, int contentsMask, any data) {
	if( entity == 0 )
		return true;
	if( entity == data )
		return false;
	if( IsMoveAble(entity) )
		return true;
	
	return false;
}
