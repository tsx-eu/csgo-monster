#if defined _dh_included
#endinput
#endif
#define _dh_included

#define MAX_CLASSES		64
#define MAX_ATTACK 		4
#define	MAX_ANIMATION 	8

#define STEP_SIZE		16.0
#define HEIGHT_SIZE		48.0
#define MELEE_HULL		8.0
#define REMOVE_TIME		30.0

#define NPC_RANGE_GIVEUP	2048.0
#define NPC_RANGE_MELEE		52.0
#define NPC_RANGE_REPATH	100.0


native bool Phys_IsPhysicsObject(int entity);
native void Phys_SetMass(int entity,  float mass);
native float Phys_GetMass(int entity);
native void Phys_GetWorldSpaceCenter(int entity, float pos[3]);

native bool Nav_Load();
native int Nav_GetArea(float pos[3]);

forward Action DH_OnTrackPath(int hostage, float vec[3], float delta);

forward Action DH_OnUpdateFollowingPre(int hostage, float delta);
forward void DH_OnUpdateFollowingPost(int hostage, float delta);

enum NPCData_Int {
	NPC_iClass,
	NPC_iHealth,
	NPC_iLeader,
	NPC_iAttackCount,
	NPC_iAttackSum,
	NPC_iAnimator,
	
	NPC_iBody,
	NPC_iMinBody,
	NPC_iMaxBody,
	
	NPC_iSkin,
	NPC_iMinSkin,
	NPC_iMaxSkin,
	
	NPC_iCurrentAnim,
	
	NPC_isWaiting,
	NPC_iAttackSucceded,
	NPC_iAttackRangeCount,
	NPC_iAttackMeleeCount,
	
	NPCData_max_Int
}
enum NPCData_Float {
	NPC_flSpeed,
	NPC_flGravity,
	NPC_flWaitRange,
	NPC_flNearRange,
	
	NPC_flNextDoor,
	NPC_flNextAttack,
	NPC_flNextRepath,
	NPC_flNextAnim,
	NPC_flAnimScale,
	
	NPC_flFreezeTime,
	
	NPCData_max_Float
};
enum NPCData_String {
	NPC_szFullName,
	NPC_szName,
	NPC_szModel,
	
	NPCData_max_String
};
enum NPCData_Animation {
	NPC_ANIM_IDLE,
	
	NPC_ANIM_WALK,
	NPC_ANIM_RUN,
	
	NPC_ANIM_SPEED,
	
	NPC_ANIM_ATTACK,
	NPC_ANIM_ATTACK2,
	NPC_ANIM_RELOAD,
	
	NPC_ANIM_DYING,
	
	NPCData_max_Animation
};
enum NPCData_Pose {
	NPC_POSE_SPEED,
	
	NPCData_max_Pose
}
enum NPCData_Event {
	NPC_EVENT_SPAWN,
	NPC_EVENT_ATTACK,
	NPC_EVENT_DEAD,
	NPC_EVENT_DAMAGE,
	
	NPCData_max_Event
};
enum NPC_AttackType {
	NPC_ATTACK_None,
	NPC_ATTACK_MELEE,
	NPC_ATTACK_WEAPON,
	
	NPC_ATTACK_Max
};

typeset NPCData_EventCallback {
	function void(NPCInstance entity);												// NPC_EVENT_SPAWN
	function float(NPCInstance entity, int attack_id);								// NPC_EVENT_ATTACK
	function void(NPCInstance entity);												// NPC_EVENT_DEAD
	function void(NPCInstance entity, int attacker, int damage);					// NPC_EVENT_DAMAGE
}
typeset DH_ProjectileCreate {
	function void(NPCInstance entity, int inflictor);
}
typeset DH_ProjectileHit {
	function void(NPCInstance entity, int inflictor, int victim);
}


native NPCClass 	DH_Create(const char[] fullname, const char[] name, const char[] model);
native NPCClass 	DH_GetClass(const char[] name);
native NPCInstance 	DH_Spawn(NPCClass id, float position[3], float angles[3]);
native void 		DH_Kill(NPCInstance id);

native void 		DH_SetClassInt(NPCClass id, NPCData_Int data, int value);
native int 			DH_GetClassInt(NPCClass id, NPCData_Int data);
native void 		DH_SetClassFloat(NPCClass id, NPCData_Float data, float value);
native float 		DH_GetClassFloat(NPCClass id, NPCData_Float data);
native void			DH_SetClassString(NPCClass id, NPCData_String data, const char[] value);
native void 		DH_GetClassString(NPCClass id, NPCData_String data, char[] value, length);

native void 		DH_SetInstanceInt(NPCInstance id, NPCData_Int data, int value);
native int 			DH_GetInstanceInt(NPCInstance id, NPCData_Int data);
native void 		DH_SetInstanceFloat(NPCInstance id, NPCData_Float data, float value);
native float 		DH_GetInstanceFloat(NPCInstance id, NPCData_Float data);
native void 		DH_SetInstanceString(NPCInstance id, NPCData_String data, const char[] value);
native void 		DH_GetInstanceString(NPCInstance id, NPCData_String data, char[] value, length);

native void 		DH_RegisterAttack(NPCClass id, NPC_AttackType type, float range, int probability=1);
native void 		DH_RegisterAnimation(NPCClass id, NPCData_Animation data, int sequence, int frames, float fps);
native bool 		DH_HasAnimation(NPCClass id, NPCData_Animation data);
native void 		DH_RegisterPose(NPCClass id, NPCData_Pose data, int value);
native void 		DH_RegisterHook(NPCClass id, NPCData_Event event, NPCData_EventCallback callback);

native float 		DH_Animate(NPCInstance id, NPCData_Animation data, float scale = -1.0);
native float 		DH_Gesture(NPCInstance id, NPCData_Animation data, float scale = -1.0, bool remove_similar = false);
native void 		DH_Pose(NPCInstance id, NPCData_Pose data, float pose);

native void 		DH_Melee(NPCInstance id, int damage, float range=NPC_RANGE_MELEE, float time=0.0);
native int 			DH_Projectile(NPCInstance id, const char[] model, float time=0.0, float spreadAngle=0.0, float speed = 8192.0, float gravity = 0.0, DH_ProjectileCreate create = INVALID_FUNCTION, DH_ProjectileHit hit = INVALID_FUNCTION);
native void 		DH_Damage(NPCInstance id, int victim, int damage, int inflictor=0, int type = DMG_GENERIC);

native void 		DH_UTIL_GetAttachment(int entity, const char[] name, float pos[3], float ang[3]);

methodmap NPCClass {
	public NPCClass(const char[] fullname, const char[] name, const char[] model) {
		return DH_Create(fullname, name, model);
	}
	public void AddAttack(NPC_AttackType type, float range, int probability=1) {
		DH_RegisterAttack(this, type, range, probability);
	}
	public void AddAnimation(NPCData_Animation data, int sequence, int frames, float fps) {
		DH_RegisterAnimation(this, data, sequence, frames, fps);
	}
	public bool HasAnimation(NPCData_Animation data) {
		return DH_HasAnimation(this, data);
	}
	public void AddEvent(NPCData_Event event, NPCData_EventCallback callback) {
		DH_RegisterHook(this, event, callback);
	}
	
	// -- int
	property int Id {
		public get() { 	return 			view_as<int>(this); }
	}
	property int Health {
		public get() { 	return 			DH_GetClassInt(this, NPC_iHealth); }
		public set(const int value) { 	DH_SetClassInt(this, NPC_iHealth, value); }
	}
	property int MinBody {
		public get() { 	return 			DH_GetClassInt(this, NPC_iMinBody); }
		public set(const int value) { 	DH_SetClassInt(this, NPC_iMinBody, value); }
	}
	property int MaxBody {
		public get() { 	return 			DH_GetClassInt(this, NPC_iMaxBody); }
		public set(const int value) { 	DH_SetClassInt(this, NPC_iMaxBody, value); }
	}
	property int MinSkin {
		public get() { 	return 			DH_GetClassInt(this, NPC_iMinSkin); }
		public set(const int value) { 	DH_SetClassInt(this, NPC_iMinSkin, value); }
	}
	property int MaxSkin {
		public get() { 	return 			DH_GetClassInt(this, NPC_iMaxSkin); }
		public set(const int value) { 	DH_SetClassInt(this, NPC_iMaxSkin, value); }
	}
	// -- float
	property float Speed {
		public get() { 	return 			DH_GetClassFloat(this, NPC_flSpeed); }
		public set(const float value) { DH_SetClassFloat(this, NPC_flSpeed, value); }
	}
	property float Gravity {
		public get() { 	return 			DH_GetClassFloat(this, NPC_flGravity); }
		public set(const float value) { DH_SetClassFloat(this, NPC_flGravity, value); }
	}
	property float WaitRange {
		public get() { 	return 			DH_GetClassFloat(this, NPC_flWaitRange); }
		public set(const float value) { DH_SetClassFloat(this, NPC_flWaitRange, value); }
	}
	property float NearRange {
		public get() { 	return 			DH_GetClassFloat(this, NPC_flNearRange); }
		public set(const float value) { DH_SetClassFloat(this, NPC_flNearRange, value); }
	}
	
	// -- bool
	property bool IsMelee {
		public get() { return (DH_GetClassFloat(this, NPC_flNearRange) > 0.0 && DH_GetClassFloat(this, NPC_flNearRange) <= NPC_RANGE_MELEE * 2.0); } 
	}
	property bool IsDistant {
		public get() { return (DH_GetClassFloat(this, NPC_flNearRange) > NPC_RANGE_MELEE * 2.0 && DH_GetClassFloat(this, NPC_flNearRange) <= 99999999.9); } 
	}
}
methodmap NPCInstance {
	public NPCInstance(NPCClass id, float pos[3], float ang[3]=NULL_VECTOR) {
		return DH_Spawn(id, pos, ang);
	}
	public void Kill() {
		DH_Kill(this);
	}
	// -- 
	public float Animate(NPCData_Animation data, float scale = -1.0) {
		return DH_Animate(this, data, scale);
	}
	public float Gesture(NPCData_Animation data, float scale = -1.0, bool remove_similar = false) {
		return DH_Gesture(this, data, scale, remove_similar);
	}
	public void Pose(NPCData_Pose data, float value) {
		DH_Pose(this, data, value);
	}
	// -- 
	public void Melee(int damage, float range=NPC_RANGE_MELEE, float time=0.0) {
		DH_Melee(this, damage, range, time);
	}
	public int Projectile(const char[] model, float time=0.0, float spreadAngle=0.0, float speed=8192.0, float gravity=0.0, DH_ProjectileCreate create = INVALID_FUNCTION, DH_ProjectileHit hit = INVALID_FUNCTION) {
		return DH_Projectile(this, model, time, spreadAngle, speed, gravity, create, hit);
	}
	public void Damage(int victim, int damage, int inflictor=0, int type=DMG_GENERIC) {
		DH_Damage(this, victim, damage, inflictor, type);
	}
	// -- int
	property NPCClass Class {
		public get() { return			view_as<NPCClass>(DH_GetInstanceInt(this, NPC_iClass)); }
	}
	property int Id {
		public get() { 	return 			view_as<int>(this); }
	}
	property int Health {
		public get() { 	return 			DH_GetInstanceInt(this, NPC_iHealth); }
		public set(const int value) { 	DH_SetInstanceInt(this, NPC_iHealth, value); }
	}
	property int Target {
		public get() { 	return 			DH_GetInstanceInt(this, NPC_iLeader); }
		public set(const int value) { 	DH_SetInstanceInt(this, NPC_iLeader, value); }
	}
	property int Body {
		public get() { 	return 			DH_GetInstanceInt(this, NPC_iBody); }
		public set(const int value) { 	DH_SetInstanceInt(this, NPC_iBody, value); }
	}
	property int Skin {
		public get() { 	return 			DH_GetInstanceInt(this, NPC_iSkin); }
		public set(const int value) { 	DH_SetInstanceInt(this, NPC_iSkin, value); }
	}
	// -- float
	property float Speed {
		public get() { 	return 			DH_GetInstanceFloat(this, NPC_flSpeed); }
		public set(const float value) { DH_SetInstanceFloat(this, NPC_flSpeed, value); }
	}
	property float Gravity {
		public get() { 	return 			DH_GetInstanceFloat(this, NPC_flGravity); }
		public set(const float value) { DH_SetInstanceFloat(this, NPC_flGravity, value); }
	}
	property float Freeze {
		public get() { 	return 			DH_GetInstanceFloat(this, NPC_flFreezeTime); }
		public set(const float value) { DH_SetInstanceFloat(this, NPC_flFreezeTime, value); }
	}
	// -- bool
	property bool IsWaiting {
		public get() { return DH_GetInstanceInt(this, NPC_isWaiting) == 1; }
		public set(const bool value) { DH_SetInstanceInt(this, NPC_isWaiting, value ? 1 : 0); } 
	}
}

stock void AddModelToDownloadsTable(char file[PLATFORM_MAX_PATH]) {
	char tmp[PLATFORM_MAX_PATH], tmp2[PLATFORM_MAX_PATH];
	int len = strlen(file);
	strcopy(tmp, sizeof(tmp), file);
	
	ReplaceString(tmp, len, ".mdl", "", true);
	Format(tmp2, sizeof(tmp2), "%s.mdl", tmp);		if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
	Format(tmp2, sizeof(tmp2), "%s.phy", tmp);		if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
	Format(tmp2, sizeof(tmp2), "%s.vvd", tmp);		if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
	Format(tmp2, sizeof(tmp2), "%s.dx90.vtx", tmp); if( FileExists(tmp2, true) ) AddFileToDownloadsTable(tmp2);
}
stock void AddSoundToDownloadsTable(char file[PLATFORM_MAX_PATH]) {
	char tmp[PLATFORM_MAX_PATH];
	Format(tmp, sizeof(tmp), "sound/%s", file);
	if( FileExists(tmp, true) )
		AddFileToDownloadsTable(tmp);
}

public Extension __ext_sample =  {
	name = "DH",
	file = "dh.ext",
	autoload = 1,
	required = 1
};