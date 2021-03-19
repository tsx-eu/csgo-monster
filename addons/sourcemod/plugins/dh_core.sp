#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <MemoryEx>
#include <smlib>
#include <dh>
#include <cstrike>

#pragma newdecls required

#include "dh/variables.inc"
#include "dh/functions.inc"

#include "dh/hostages.inc"
#include "dh/natives.inc"
#include "dh/patch.inc"

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
	
	m_accel = FindSendPropInfo("CHostage", "m_leader") + 24;
	
	g_hNamedIdentified = new StringMap();
	
	
	char classname[128];
	for(int i=1; i<=2048; i++) {
		if( IsValidEdict(i) && IsValidEntity(i) ) {
			GetEdictClassname(i, classname, sizeof(classname));
			OnEntityCreated(i, classname);
		}
	}
}
// ---------------------------------------------------------------------------------------------------------
public APLRes AskPluginLoad2(Handle hPlugin, bool isAfterMapLoaded, char[] error, int err_max) {
	Native_REGISTER();
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
public Action block(int client, int args) {
	
	PrecacheModel("models/npc/tsx/zombie/zombie.mdl");
	PrecacheModel("models/npc/tsx/skeleton/skeleton.mdl");
	
	int hostage = 0;
	while( (hostage = FindEntityByClassname(hostage, "hostage_entity")) && hostage > 0 ) {		
		float pos[3];
		Entity_GetAbsOrigin(hostage, pos);
		pos[2] += 16.0;
		AcceptEntityInput(hostage, "Kill");
		
		NPCInstance bot = NPCInstance(DH_GetClass("zombie"), pos);
		bot.Target = client;
		break;
	}
	
	//CS_SwitchTeam(client, CS_TEAM_CT);
	return Plugin_Handled;
}
