#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <MemoryEx>
#include <smlib>
#include <dh>
#include <cstrike>

#pragma newdecls required
#define STEP_SIZE	16.0

public Plugin myinfo = {
	name = "Les test de kosso",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};

float m_inhibitDoorTimer[2048];
ConVar sv_pushaway_hostage_force;
ConVar sv_pushaway_max_hostage_force;
ConVar sv_pushaway_force;
ConVar sv_pushaway_max_force;

int m_accel = -1;
int g_cBeam;

public void OnPluginStart() {
	RegConsoleCmd("hostage", block);
	RegServerCmd("patch", patch);
	
	ServerCommand("patch");
	
	sv_pushaway_hostage_force = FindConVar("sv_pushaway_hostage_force");
	sv_pushaway_max_hostage_force = FindConVar("sv_pushaway_max_hostage_force");
	
	sv_pushaway_force = FindConVar("sv_pushaway_force");
	sv_pushaway_max_force = FindConVar("sv_pushaway_max_force");
	
	m_accel = FindSendPropInfo("CHostage", "m_leader") + 24;
	
	char classname[128];
	for(int i=1; i<=2048; i++) {
		if( IsValidEdict(i) && IsValidEntity(i) ) {
			GetEdictClassname(i, classname, sizeof(classname));
			OnEntityCreated(i, classname);
		}
	}
}
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
}
bool GetPushawayEnts_enumerator(int entity, any ref) {
	ArrayList data = view_as<ArrayList>(ref);
	data.Push(entity);
	
	return data.Length < data.BlockSize;
}
int GetPushawayEnts(int entity, int[] ents, int nMaxEnts, float flPlayerExpand, int PartitionMask) {
	static float src[3], min[3], max[3];
	
	Entity_GetAbsOrigin(entity, src);
	Entity_GetMinSize(entity, min);
	Entity_GetMaxSize(entity, max);
		
	if( flPlayerExpand > 0.0 ) {
		for(int i=0; i<3; i++) {
			min[i] -= flPlayerExpand;
			max[i] += flPlayerExpand;
		}
	}
	
	ArrayList data = new ArrayList(nMaxEnts);
	TR_EnumerateEntitiesHull(src, src, min, max, PartitionMask, GetPushawayEnts_enumerator, data);
	int size = nMaxEnts < data.Length ? nMaxEnts : data.Length;

	for(int i=0; i<size; i++) {
		ents[i] = data.Get(i);
	}
	
	delete data;
	return size;
}

public void OnEntityCreated(int entity, const char[] classname) {
	if( StrEqual(classname, "hostage_entity") ) {
		SDKHook(entity, SDKHook_Touch, OnTouch);
		SDKHook(entity, SDKHook_Think, OnThink);
		m_inhibitDoorTimer[entity] = 0.0;
	}
}
stock bool IsValidClient(int client) {
	if (client <= 0 || client > MaxClients)
		return false;
	
	if (!IsValidEdict(client) || !IsClientConnected(client))
		return false;
	
	return true;
}
stock float Math_Lerp(float a, float b, float n) {
	return (1 - n) * a + n * b;
}
stock float Math_InvLerp(float a, float b, float v) {
	return (v - a) / (b - a);
}

public Action DH_OnUpdateFollowingPre(int hostage, float delta) {
	return Plugin_Continue;
}
public void DH_OnUpdateFollowingPost(int entity, float delta) {
	AvoidPhysicsProps(entity);
}
void AvoidPhysicsProps(int entity) {
	static float src[3], dst[3], push[3], norm[3], min[3], max[3], vel[3];
	bool debugEnabled = false;
	GetEntDataVector(entity, m_accel, vel);
	
	Entity_GetAbsOrigin(entity, src);
	Phys_GetWorldSpaceCenter(entity, norm);
	
	int ents[8];
	int ret = GetPushawayEnts(entity, ents, sizeof(ents), 5.0, PARTITION_SOLID_EDICTS);
	for(int i=0; i<ret; i++) {
		int target = ents[i];
		if( target != entity ) {
			
			float mass = Phys_IsPhysicsObject(target) ? Phys_GetMass(target) : 30.0;			
			{
				float lerp = 0.0 + Math_Clamp(Math_InvLerp(10.0, 30.0, mass), 0.0, 1.0);
				if( lerp > 0.0 ) {
					Phys_GetWorldSpaceCenter(target, dst);
					SubtractVectors(norm, dst, push);
					
					float flDist = NormalizeVector(push, push);
					if( flDist < 1.0 ) flDist = 1.0;
					
					float flForce = sv_pushaway_hostage_force.FloatValue / flDist * lerp;
					if( flForce > sv_pushaway_max_hostage_force.FloatValue ) flForce = sv_pushaway_max_hostage_force.FloatValue;
									
					ScaleVector(push, flForce);
					AddVectors(vel, push, vel);
					
					if( debugEnabled ) {
						NormalizeVector(push, push);
						ScaleVector(push, 120.0);
						AddVectors(norm, push, dst);
						
						TE_SetupBeamPoints(norm, dst, g_cBeam, g_cBeam, 0, 0, 2.0, 2.0, 2.0, 0, 0.0, { 0, 255, 0, 250 }, 0);
						TE_SendToAll();
						
						TE_SetupBeamPoints(dst, norm, g_cBeam, g_cBeam, 0, 0, 2.0, 2.0, 2.0, 0, 0.0, { 0, 255, 0, 250 }, 0);
						TE_SendToAll();
					}
				}
			}
			
			if( target > 0 && IsValidEntity(target) && !IsValidClient(target) && (HasEntProp(target, Prop_Data, "m_bAwake")||HasEntProp(target, Prop_Data, "m_bCanBePickedUp")) ) {
				float lerp = 1.0 - Math_Clamp(Math_InvLerp(10.0, 30.0, mass), 0.0, 1.0);
				if( lerp > 0.0 ) {
					Entity_GetAbsOrigin(target, dst);
					SubtractVectors(dst, src, push);
					
					float flDist = NormalizeVector(push, push);
					if( flDist < 1.0 ) flDist = 1.0;
					
					float flForce = sv_pushaway_force.FloatValue / flDist * lerp * 0.25;
					if( flForce > sv_pushaway_max_force.FloatValue ) flForce = sv_pushaway_max_force.FloatValue;
					
					ScaleVector(push, flForce);
					
					if( GetVectorLength(push) > 0.0 ) {
						Entity_GetAbsVelocity(target, dst);
						AddVectors(dst, push, push);
						TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, push);
					}
					
					if( debugEnabled ) {					
						NormalizeVector(push, push);
						ScaleVector(push, 120.0);
						AddVectors(src, push, dst);
		
						TE_SetupBeamPoints(src, dst, g_cBeam, g_cBeam, 0, 0, 2.0, 2.0, 2.0, 0, 0.0, { 255, 0, 0, 250 }, 0);
						TE_SendToAll();
						
						TE_SetupBeamPoints(dst, src, g_cBeam, g_cBeam, 0, 0, 2.0, 2.0, 2.0, 0, 0.0, { 255, 0, 0, 250 }, 0);
						TE_SendToAll();
					}
				}
			}
		}
	}
	
	if( GetVectorLength(vel) > 0.0 ) {
		Entity_GetMinSize(entity, min);
		Entity_GetMaxSize(entity, max);

		NormalizeVector(vel, push);
		AddVectors(src, push, dst);
		
		if( debugEnabled ) {		
			TE_SetupBeamPoints(src, dst, g_cBeam, g_cBeam, 0, 0, 1.0, 2.0, 2.0, 0, 0.0, { 0, 0, 255, 250 }, 0);
			TE_SendToAll();
		}

		Handle ray1 = TR_TraceHullFilterEx(src, dst, min, max, MASK_PLAYERSOLID, FilterToOne, entity);
		if( !TR_StartSolid(ray1) && TR_GetFraction(ray1) < 1.0 ) {
			TR_GetPlaneNormal(ray1, norm);
			
			if( norm[2] < 0.7 ) {				
				TR_GetEndPosition(dst, ray1);				
				AddVectors(dst, push, dst);
				
				push[0] = dst[0];
				push[1] = dst[1];
				push[2] = dst[2] + STEP_SIZE;
				
				if( debugEnabled ) {
					TE_SetupBeamPoints(push, dst, g_cBeam, g_cBeam, 0, 0, 1.0, 2.0, 2.0, 0, 0.0, { 0, 255, 0, 250 }, 0);
					TE_SendToAll();
				}
				
				Handle ray2 = TR_TraceHullFilterEx(push, dst, min, max, MASK_PLAYERSOLID, FilterToOne, entity);
				if( !TR_StartSolid(ray2) && TR_GetFraction(ray2) > 0.0 ) {
					src[2] += (STEP_SIZE*(1.0-TR_GetFraction(ray2)) + 1.0);
					TeleportEntity(entity, src, NULL_VECTOR, NULL_VECTOR);
				}
				CloseHandle(ray2);
			}
		}
		CloseHandle(ray1);
	}
	
	SetEntDataVector(entity, m_accel, vel);
}
public void OnThink(int entity) {	
}
public bool FilterToOne(int entity, int mask, any data) {
	return (data != entity);
}
public Action OnTouch(int entity, int target) {
	static char classname[128];
	
	if( target > 0 ) {
		GetEdictClassname(target, classname, sizeof(classname));
		
		if( m_inhibitDoorTimer[entity] < GetGameTime() && (StrContains(classname, "func_door") == 0 || StrContains(classname, "prop_door") == 0) ) {
			AcceptEntityInput(target, "Use", entity, entity);
			m_inhibitDoorTimer[entity] = GetGameTime() + 3.0;
		}
		
		if( StrContains(classname, "func_breakable_surf") == 0 ) {
			SDKHooks_TakeDamage(target, entity, entity, 100.0, DMG_CRUSH);
		}
	}
}

bool PatchRefIfValue(Address addr, int fromValue, int toValue, int byte = 4) {
	NumberType type = NumberType_Int32;
	
	switch( byte ) {
		case 4: type = NumberType_Int32;
		case 2: type = NumberType_Int16;
		case 1: type = NumberType_Int8;
		default: return false;
	}
	
	int read = byte;
	Address ref = view_as<Address>(LoadFromAddress(addr, type));	
	if( IsValidAddress(ref, read) && read == byte ) {
		int value = LoadFromAddress(ref, type);
		if( value == fromValue ) {
			StoreToAddress(ref, toValue, type);
			return true;
		}
	}
	
	return false;
}

public Action patch(int client) {
	GameData hGameConfg = LoadGameConfigFile("test.gamedata");
	Address addr;

	addr = hGameConfg.GetAddress("UpdateFollowing");
	for(int offset=0; offset<1536; offset++) {
		
		if( offset >= 0x1C && offset < 0x22 ) { // Search for a jump to https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L915-L924
			Address ref = addr + view_as<Address>(offset);
			StoreToAddress(ref, 0x90, NumberType_Int8);
		}
		
		int hexa = LoadFromAddress(addr + view_as<Address>(offset), NumberType_Int16);
		if( hexa == 0x2F0F ) { // Search for COMISS
			// Search for a reference to giveUpRange=2000x2000: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L983
			if( PatchRefIfValue(addr + view_as<Address>(offset+3), view_as<int>(2000.0*2000.0), view_as<int>(4096.0 * 4096.0)) ) {
				PrintToServer("giveUpRange has been patched at offset %d", offset);
			}
			// Search for a reference to maxPathLength=4000: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L984
			if( PatchRefIfValue(addr + view_as<Address>(offset+3), view_as<int>(4000.0), view_as<int>(8192.0)) ) {
				PrintToServer("maxPathLength has been patched at offset %d", offset);
			}
			// Search for a reference to waitRang=150x150: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L1000
			if( PatchRefIfValue(addr + view_as<Address>(offset+3), view_as<int>(150.0*150.0), view_as<int>(48.0*48.0)) ) {
				PrintToServer("waitRang has been patched at offset %d", offset);
			}
		}
		
		if( hexa == 0x0FF3 ) { // Search for MOVSS
			// Search for a reference to nearRange=125x125: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L1013
			if( PatchRefIfValue(addr + view_as<Address>(offset+4), view_as<int>(125.0*125.0), view_as<int>(32.0*32.0)) ) {
				PrintToServer("nearRange has been patched at offset %d", offset);
			}
		}
		
		if( hexa == 0x5500 ) { // break loop if we find a new fct
			break;
		}
	}

	
	addr = hGameConfg.GetAddress("CHostage");
	for(int offset=0; offset<0x3BB; offset++) {
		if( offset >= 0x2F0 && offset < 0x2F9 ) { // Search for a jump to https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L162-L171
			Address ref = addr + view_as<Address>(offset);
			StoreToAddress(ref, 0x90, NumberType_Int8);
		}
	}

	delete hGameConfg;
}
public Action block(int client, int args) {
	
	int hostage = 0;
	while( (hostage = FindEntityByClassname(hostage, "hostage_entity")) && hostage > 0 ) {
		/*
		Address addr = GetEntityAddress(hostage);
		for(int offset=GetEntSendPropOffs(hostage, "m_nHostageState"); offset<GetEntSendPropOffs(hostage, "m_flRescueStartTime"); offset++) {
			
			int read = 4;
			Address ref;
			
			read = 4;
			ref = addr + view_as<Address>(offset + 0);
			if( !(IsValidAddress(ref, read) && read == 4) )
				continue;
			
			read = 4;
			ref = addr + view_as<Address>(offset + 1);
			if( !(IsValidAddress(ref, read) && read == 4) )
				continue;
			
			read = 4;
			ref = addr + view_as<Address>(offset + 2);
			if( !(IsValidAddress(ref, read) && read == 4) )
				continue;
			
			
			int x = LoadFromAddress(addr + view_as<Address>(offset+0), NumberType_Int32);
			int y = LoadFromAddress(addr + view_as<Address>(offset+1), NumberType_Int32);
			int z = LoadFromAddress(addr + view_as<Address>(offset+2), NumberType_Int32);
			
			if( x != 0 && y != 0 && z != 0 && view_as<float>(x) == 0 && view_as<float>(y) == 0 && view_as<float>(z) == 0 ) {
				PrintToServer("%d,", offset);
			}
		}
		*/
		SetEntPropEnt(hostage, Prop_Send, "m_leader", client);
		
		PrecacheModel("models/npc/tsx/zombie/zombie.mdl");
		SetEntityModel(hostage, "models/npc/tsx/zombie/zombie.mdl")
	}
	
	return Plugin_Handled;
}