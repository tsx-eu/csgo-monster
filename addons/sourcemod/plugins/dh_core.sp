#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <MemoryEx>
#include <smlib>
#include <dh>
#include <cstrike>

#pragma newdecls required

Handle hSDKCallStudioFrameAdvance, hSDKCallAddLayeredSequence;
Handle hSDKCallLookupAttachment, hSDKCallGetAttachment;
Handle hSDKCallUpdate, hSDKCallCompute, hSDKCallGetLength;
Handle hSDKCallFaceTowards, hSDKCallReset, hSDKCallWiggle;
int AnimatingOverlay_Count;

#include "dh/variables.inc"

public Plugin myinfo = {
	name = "Les test de kosso",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};


public void OnPluginStart() {
	RegConsoleCmd("hostage", block);
	
	sv_pushaway_hostage_force = FindConVar("sv_pushaway_hostage_force");
	sv_pushaway_max_hostage_force = FindConVar("sv_pushaway_max_hostage_force");
	
	sv_pushaway_force = FindConVar("sv_pushaway_force");
	sv_pushaway_max_force = FindConVar("sv_pushaway_max_force");
	
	sv_gravity = FindConVar("sv_gravity");
	
	m_accel = FindSendPropInfo("CHostage", "m_leader") + 24;
	m_path = FindSendPropInfo("CHostage", "m_nHostageState") + 60;
	m_isStuck = FindSendPropInfo("CHostage", "m_flGrabSuccessTime") - 144;
	m_pathFollower = FindSendPropInfo("CHostage", "m_flGrabSuccessTime") - 176;
	m_segmentCount = FindSendPropInfo("CHostage", "m_flGrabSuccessTime") - 204;
	
	g_hNamedIdentified = new StringMap();
	
	
	char classname[128];
	for(int i=1; i<=2048; i++) {
		if( IsValidEdict(i) && IsValidEntity(i) ) {
			GetEdictClassname(i, classname, sizeof(classname));
			OnEntityCreated(i, classname);
		}
	}

	INIT_Animator();
	INIT_NavPath();
}
// ---------------------------------------------------------------------------------------------------------
public APLRes AskPluginLoad2(Handle hPlugin, bool isAfterMapLoaded, char[] error, int err_max) {
	return Native_REGISTER();
}
// ---------------------------------------------------------------------------------------------------------
public void OnMapStart() {
	g_cBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	Memory_Patch();
}
public void OnEntityCreated(int entity, const char[] classname) {
	if( StrEqual(classname, "hostage_entity") ) {
		DH_OnEntityCreated(entity);
	}
}
public void OnEntityDestroyed(int entity) {
	if( entity > 0 && g_hProjectile[entity] != null ) {
		delete g_hProjectile[entity];
		g_hProjectile[entity] = null;
	}
}
public Action block(int client, int args) {
	
	PrecacheModel("models/npc/tsx/zombie/zombie.mdl");
	
	int hostage = 0;
	while( (hostage = FindEntityByClassname(hostage, "hostage_entity")) && hostage > 0 ) {		
		float pos[3];
		Entity_GetAbsOrigin(hostage, pos);
		pos[2] += 16.0;
		AcceptEntityInput(hostage, "Kill");
		
		NPCInstance bot = NPCInstance(DH_GetClass("skeleton_axe"), pos);
		bot.Target = client;
		break;
	}
	
	//CS_SwitchTeam(client, CS_TEAM_CT);
	return Plugin_Handled;
}

#include "dh/functions.inc"
#include "dh/animator.inc"
#include "dh/navpath.inc"
#include "dh/hostages.inc"
#include "dh/natives.inc"
#include "dh/patch.inc"
