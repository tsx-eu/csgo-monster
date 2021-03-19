#if defined _dh_included
#endinput
#endif
#define _dh_included

#define MAX_CLASSES		64
#define MAX_ATTACK 		4
#define	MAX_ANIMATION 	8
#define STEP_SIZE		16.0

native bool Phys_IsPhysicsObject(int entity);
native void Phys_SetMass(int entity,  float mass);
native float Phys_GetMass(int entity);
native void Phys_GetWorldSpaceCenter(int entity, float pos[3]);

forward Action DH_OnIsFollowingSomeoneForwardPre(int hostage);
forward Action DH_OnWigglePre(int hostage);

forward Action DH_OnUpdateFollowingPre(int hostage, float delta);
forward void DH_OnUpdateFollowingPost(int hostage, float delta);

enum NPCData_Int {
	NPC_iClass,
	NPC_iHealth,
	NPC_iLeader,
	NPC_iAttackCount,
	
	NPCData_max_Int
}
enum NPCData_Float {
	NPC_flSpeed,
	NPC_flGravity,
	
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
	
	NPC_ANIM_ATTACK,
	NPC_ANIM_ATTACK2,
	NPC_ANIM_RELOAD,
	
	NPC_ANIM_DYING,
	NPC_ANIM_DEAD,
	NPCData_max_Animation
};
enum NPCData_Event {
	NPC_EVENT_SPAWN,
	NPC_EVENT_ATTACK,
	NPC_EVENT_DEAD,
	
	NPCData_max_Event
};
enum NPC_AttackType {
	NPC_ATTACK_None,
	NPC_ATTACK_MELEE,
	NPC_ATTACK_WEAPON,
	
	NPC_ATTACK_Max
};

typeset NPCData_EventCallback {
	function void(NPCInstance entity);					// NPC_EVENT_SPAWN
	function void(NPCInstance entity, int attack_id);	// NPC_EVENT_ATTACK
	function void(NPCInstance entity);					// NPC_EVENT_DEAD
}

#define NPC_RANGE_MELEE		52.0

native NPCClass 	DH_Create(const char[] fullname, const char[] name, const char[] model);
native NPCInstance 	DH_Spawn(NPCClass id, float position[3], float angles[3]);

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
native void 		DH_RegisterAnimation(NPCClass id, NPCData_Animation data, int sequence, int frames, int fps);
native void 		DH_RegisterHook(NPCClass id, NPCData_Event event, NPCData_EventCallback callback);

native float 		DH_Animate(NPCInstance id, NPCData_Animation data);

methodmap NPCClass {
	public NPCClass(const char[] fullname, const char[] name, const char[] model) {
		return DH_Create(fullname, name, model);
	}
	public void AddAttack(NPC_AttackType type, float range, int probability=1) {
		DH_RegisterAttack(this, type, range, probability);
	}
	public void AddAnimation(NPCData_Animation data, int sequence, int frames, int fps) {
		DH_RegisterAnimation(this, data, sequence, frames, fps);
	}
	public void AddEvent(NPCData_Event event, NPCData_EventCallback callback) {
		DH_RegisterHook(this, event, callback);
	}
	// -- int
	property int Health {
		public get() { 	return 			DH_GetClassInt(this, NPC_iHealth); }
		public set(const int value) { 	DH_SetClassInt(this, NPC_iHealth, value); }
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
}
methodmap NPCInstance {
	public NPCInstance(NPCClass id, float pos[3], float ang[3]) {
		return DH_Spawn(id, pos, ang);
	}
	public float Animate(NPCData_Animation data) {
		return DH_Animate(this, data);
	}
	// -- int
	property int Health {
		public get() { 	return 			DH_GetInstanceInt(this, NPC_iHealth); }
		public set(const int value) { 	DH_SetInstanceInt(this, NPC_iHealth, value); }
	}
	property int Target {
		public get() { 	return 			DH_GetInstanceInt(this, NPC_iLeader); }
		public set(const int value) { 	DH_SetInstanceInt(this, NPC_iLeader, value); }
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