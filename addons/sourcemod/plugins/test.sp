#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <smlib>

#pragma newdecls required

public Plugin myinfo = {
	name = "Les test de kosso",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};

public void OnPluginStart() {
	RegConsoleCmd("hostage", block);
}
public Action block(int client, int args) {
	
	int hostage = 0;
	while( (hostage = FindEntityByClassname(hostage, "hostage_entity")) && hostage > 0 ) {
		SetEntPropEnt(hostage, Prop_Send, "m_leader", client);
	}
	
	return Plugin_Handled;
}