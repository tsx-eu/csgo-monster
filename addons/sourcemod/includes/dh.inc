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


native int 		DH_Create(char fullname[PLATFORM_MAX_PATH], char name[PLATFORM_MAX_PATH], char model[PLATFORM_MAX_PATH]);

native void 	DH_SetClassInt(int id, NPCData_Int data, int value);
native int 		DH_GetClassInt(int id, NPCData_Int data);
native void 	DH_SetClassFloat(int id, NPCData_Float data, float value);
native float 	DH_GetClassFloat(int id, NPCData_Float data);
native void		DH_SetClassString(int id, NPCData_String data, const char[] value);
native void 	DH_GetClassString(int id, NPCData_String data, char[] value, length);

native void 	DH_SetInstanceInt(int id, NPCData_Int data, int value);
native int 		DH_GetInstanceInt(int id, NPCData_Int data);
native void 	DH_SetInstanceFloat(int id, NPCData_Float data, float value);
native float 	DH_GetInstanceFloat(int id, NPCData_Float data);
native void 	DH_SetInstanceString(int id, NPCData_String data, const char[] value);
native void 	DH_GetInstanceString(int id, NPCData_String data, char[] value, length);

enum NPCData_Int {
	NPC_iHealth,
	NPC_iLeader,
	
	NPCData_max_Int
}
enum NPCData_Float {
	NPC_fSpeed,
	
	NPCData_max_Float
};
enum NPCData_String {
	NPC_szFullName,
	NPC_szName,
	NPC_szModel,
	
	NPCData_max_String
};

methodmap NPCClass {
    public NPCClass(const char[] fullname, const char[] name, const char[] model) {
    	return view_as<NPCClass>(DH_Create(fullname, name, model));
    }
    
    property int Health {
    	public get() {
    		return DH_GetClassInt(view_as<int>(this), NPC_iHealth);	
    	}
    	public set(const int value) {
    		DH_SetClassInt(view_as<int>(this), NPC_iHealth, value);
    	}
    }
}
methodmap NPCInstance {
    public NPCInstance(int entity) {
    	return view_as<NPCInstance>(entity));
    }
    
    property int Health {
    	public get() {
    		return DH_GetInstanceInt(view_as<int>(this), NPC_iHealth);	
    	}
    	public set(const int value) {
    		DH_SetInstanceInt(view_as<int>(this), NPC_iHealth, value);
    	}
    }
}

public Extension __ext_sample =  {
	name = "DH",
	file = "dh.ext",
	autoload = 1,
	required = 1
};