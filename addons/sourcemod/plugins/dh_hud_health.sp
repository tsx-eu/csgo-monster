#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>

#define HIDEHUD_HEALTH_AND_WEAPON 	(1<<4)
#define HIDEHUD_THE_CHAT			(1<<7)
#define HIDEHUD_RADAR	 			(1<<12)

#define HIDEHUD_MOD					(HIDEHUD_HEALTH_AND_WEAPON|HIDEHUD_THE_CHAT|HIDEHUD_RADAR)

public Plugin myinfo = {
	name = "DH: HUD",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};

public void OnPluginStart() {
	for(int i=1; i<=MaxClients; i++) {
		if( IsClientInGame(i) )
			OnClientPutInServer(i);
	}
}
public void OnConfigsExecuted() {
	ServerCommand("mp_playercashawards 0");
	ServerCommand("mp_teamcashawards 0");
}
public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_OnTakeDamagePost, OnDamage);
	CreateTimer(1.0, Task_Client, GetClientUserId(client), TIMER_REPEAT);
	HUD_Update(client);
}

public Action OnDamage(int victim, int& attacker, int& inflictor, float& damage, int& damageType) {
	HUD_Update(victim);
	CreateTimer(0.1, Task_UpdateHUD, victim);
}
public Action Task_Client(Handle timer, any userid) {
	int client = GetClientOfUserId(userid);
	if( client <= 0 )
		return Plugin_Stop;
	
	HUD_Update(client);
	return Plugin_Continue;
}

public Action Task_UpdateHUD(Handle timer, any victim) {
	HUD_Update(victim);
	return Plugin_Continue;
}


void HUD_Update(int client) {
	float ratio = float(Entity_GetHealth(client)) / float(Entity_GetMaxHealth(client));
	int img = RoundToCeil(ratio * 20.0) * 5;
	if( img > 95 )
		img = 95;
	if( img < 0 )
		img = 0;
	
	ClientCommand(client, "r_screenoverlay dh/hud/HP/%d", img);
	
	int hud1 = GetEntProp(client, Prop_Send, "m_iHideHUD");
	int hud2 = hud1;
	hud1 |= HIDEHUD_MOD;
	
	if( hud1 != hud2 )
		SetEntProp(client, Prop_Send, "m_iHideHUD", hud1);
}