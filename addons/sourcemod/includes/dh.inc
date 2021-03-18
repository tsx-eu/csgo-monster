#if defined _dh_included
#endinput
#endif
#define _dh_included

#define MAX_CLASSES	64
#define STEP_SIZE	16.0


native bool Phys_IsPhysicsObject(int entity);
native void Phys_SetMass(int entity,  float mass);
native float Phys_GetMass(int entity);
native void Phys_GetWorldSpaceCenter(int entity, float pos[3]);

forward Action DH_OnIsFollowingSomeoneForwardPre(int hostage);
forward Action DH_OnWigglePre(int hostage);

forward Action DH_OnUpdateFollowingPre(int hostage, float delta);
forward void DH_OnUpdateFollowingPost(int hostage, float delta);

enum NPCData_Int {
	NPC_iHealth,
	NPC_iLeader,
	
	NPCData_max_Int
}
enum NPCData_Float {
	NPC_flSpeed,
	
	NPCData_max_Float
};
enum NPCData_String {
	NPC_szFullName,
	NPC_szName,
	NPC_szModel,
	
	NPCData_max_String
};


native NPCClass 		DH_Create(char fullname[PLATFORM_MAX_PATH], char name[PLATFORM_MAX_PATH], char model[PLATFORM_MAX_PATH]);
native NPCInstance 		DH_Spawn(NPCClass id, float position[3], float angles[3]);

native void 			DH_SetClassInt(NPCClass id, NPCData_Int data, int value);
native int 				DH_GetClassInt(NPCClass id, NPCData_Int data);
native void 			DH_SetClassFloat(NPCClass id, NPCData_Float data, float value);
native float 			DH_GetClassFloat(NPCClass id, NPCData_Float data);
native void				DH_SetClassString(NPCClass id, NPCData_String data, const char[] value);
native void 			DH_GetClassString(NPCClass id, NPCData_String data, char[] value, length);

native void 			DH_SetInstanceInt(NPCInstance id, NPCData_Int data, int value);
native int 				DH_GetInstanceInt(NPCInstance id, NPCData_Int data);
native void 			DH_SetInstanceFloat(NPCInstance id, NPCData_Float data, float value);
native float 			DH_GetInstanceFloat(NPCInstance id, NPCData_Float data);
native void 			DH_SetInstanceString(NPCInstance id, NPCData_String data, const char[] value);
native void 			DH_GetInstanceString(NPCInstance id, NPCData_String data, char[] value, length);

methodmap NPCClass {
	public NPCClass(const char[] fullname, const char[] name, const char[] model) {
		return DH_Create(fullname, name, model);
	}
	
	property int Health {
		public get() { 	return 			DH_GetClassInt(this, NPC_iHealth); }
		public set(const int value) { 	DH_SetClassInt(this, NPC_iHealth, value); }
	}
	
	property float Speed {
		public get() { 	return 			DH_GetClassFloat(this, NPC_flSpeed); }
		public set(const float value) { DH_SetClassFloat(this, NPC_flSpeed, value); }
	}
}
methodmap NPCInstance {
	public NPCInstance(NPCClass id, float pos[3], float ang[3]) {
		return DH_Spawn(id, pos, ang);
	}
	
	property int Health {
		public get() { 	return 			DH_GetInstanceInt(this, NPC_iHealth); }
		public set(const int value) { 	DH_SetInstanceInt(this, NPC_iHealth, value); }
	}
	property int Target {
		public get() { 	return 			DH_GetInstanceInt(this, NPC_iLeader); }
		public set(const int value) { 	DH_SetInstanceInt(this, NPC_iLeader, value); }
	}
	
	property float Speed {
		public get() { 	return 			DH_GetInstanceFloat(this, NPC_flSpeed); }
		public set(const float value) { DH_SetInstanceFloat(this, NPC_flSpeed, value); }
	}
}

public Extension __ext_sample =  {
	name = "DH",
	file = "dh.ext",
	autoload = 1,
	required = 1
};