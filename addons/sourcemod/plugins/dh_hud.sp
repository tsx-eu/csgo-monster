#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>
#include <cstrike>

#include <dh>
#include <phun>
#include <custom_weapon_mod.inc>

#define HIDEHUD_HEALTH_AND_WEAPON 	(1<<4)
#define HIDEHUD_THE_CHAT			(1<<7)
#define HIDEHUD_RADAR	 			(1<<12)

//#define HIDEHUD_MOD					(HIDEHUD_HEALTH_AND_WEAPON|HIDEHUD_THE_CHAT|HIDEHUD_RADAR)
#define HIDEHUD_MOD					(HIDEHUD_HEALTH_AND_WEAPON|HIDEHUD_RADAR)

int g_iLowLifeParticle[65];
int g_iPosition[65][5][3];

public Plugin myinfo = {
	name = "DH: HUD",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};

public void OnPluginStart() {
	for(int i=1; i<=MaxClients; i++) {
		if( IsValidClient(i) )
			OnClientPutInServer(i);
	}
}
public void OnMapStart() {
	char tmp[PLATFORM_MAX_PATH];
	PrecacheGeneric("particles/blood_impact_gore.pcf", true);
	PrecacheGeneric("particles/kosso_1.pcf", true);
	
	AddFileToDownloadsTable("particles/kosso_1.pcf");
	for(int i=0; i<20; i++) {
		Format(tmp, sizeof(tmp), "materials/dh/hud/HP/%d.vmt", i * 5);
		AddFileToDownloadsTable(tmp);
		Format(tmp, sizeof(tmp), "materials/dh/hud/HP/%d.vtf", i * 5);
		AddFileToDownloadsTable(tmp);
	}
}
public void OnConfigsExecuted() {
	ServerCommand("mp_playercashawards 0");
	ServerCommand("mp_teamcashawards 0");
}
// -----------------------------------------------------------------------
public void OnClientPutInServer(int client) {
	g_iLowLifeParticle[client] = INVALID_ENT_REFERENCE;

	SDKHook(client, SDKHook_OnTakeDamagePost, OnDamage);
	CreateTimer(1.0, OnClientSecond, GetClientUserId(client), TIMER_REPEAT);	
	HUD_Update(client);
}
public void OnClientDisconnect(int client) {
	int ref = EntRefToEntIndex(g_iLowLifeParticle[client]);
	if( ref > 0 )
		AcceptEntityInput(ref, "Kill");
}
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float ang[3], int& weapon, int& subtype, int& cmd, int&tick, int& seed, int mouse[2]) {
	static int oldButton[65];
	static int tablet[65];
	
	if( !(oldButton[client] & IN_SCORE) && (buttons & IN_SCORE) ) {
		tablet[client] = EntIndexToEntRef(CWM_Spawn(CWM_GetId("tablet"), client, NULL_VECTOR, NULL_VECTOR));
		SDKHook(client, SDKHook_PreThink, OnThink);
	}
	if( (oldButton[client] & IN_SCORE) && !(buttons & IN_SCORE) ) {
		int wep = EntRefToEntIndex(tablet[client]);
		
		if( wep > 0 ) {
			RemovePlayerItem(client, wep);
			AcceptEntityInput(wep, "Kill");
		}
		
		// prevent unhook if not hooked:
		SDKHook(client, SDKHook_PreThink, OnThink);
		SDKUnhook(client, SDKHook_PreThink, OnThink);
	}
	
	if( !(mouse[0] == 0 && mouse[1] == 0) ) {
		for(int i=0; i<sizeof(g_iPosition[]); i++) {
			for(int j=0; j<sizeof(g_iPosition[][]); j++) {
				if( g_iPosition[client][i][j] == 2 )
					g_iPosition[client][i][j] = 1;
			}
		}
				
		
		if( mouse[0] > 0 )
			mouse[0] = 1;
		if( mouse[0] < 0 )
			mouse[0] = -1;
		
		if( mouse[1] > 0 )
			mouse[1] = 1;
		if( mouse[1] < 0 )
			mouse[1] = -1;
		
		g_iPosition[client][ mouse[0] + 1 ][ mouse[1] + 1 ] = 2;
	}
	
	oldButton[client] = buttons;	
	return Plugin_Continue;
}

public void OnThink(int client) {
	int view = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	
	int val = 0;
	for(int p=0; p<15; p++) {
		val += RoundFloat(Pow(3.0, float(p)) * g_iPosition[client][p % 5][(p / 5 % 3)]);
	}
	
	SetEntProp(view, Prop_Send, "m_nBody", val);
}
// -----------------------------------------------------------------------
public Action OnDamage(int victim, int& attacker, int& inflictor, float& damage, int& damageType) {
	HUD_Update(victim);
	CreateTimer(0.1, Task_UpdateHUD, victim);
}
public Action OnClientSecond(Handle timer, any userid) {
	int client = GetClientOfUserId(userid);
	if( client <= 0 )
		return Plugin_Stop;
	
	if( GetClientTeam(client) != CS_TEAM_T )
		CS_SwitchTeam(client, CS_TEAM_T);
	if( !IsPlayerAlive(client) )
		CS_RespawnPlayer(client);
	
	HUD_Update(client);
	return Plugin_Continue;
}
// -----------------------------------------------------------------------
public Action Task_UpdateHUD(Handle timer, any victim) {
	HUD_Update(victim);
	return Plugin_Continue;
}
void HUD_Update(int client) {
	float ratio = float(Entity_GetHealth(client)) / float(Entity_GetMaxHealth(client));
	int img = RoundToCeil(ratio * 19.0) * 5;
	if( img > 95 )
		img = 95;
	if( img < 0 )
		img = 0;
	
	ClientCommand(client, "r_screenoverlay dh/hud/HP/%d", img);
	SendConVarValue(client, FindConVar("game_type"), "6");
	
	int hud1 = GetEntProp(client, Prop_Send, "m_iHideHUD");
	int hud2 = hud1;
	hud1 = HIDEHUD_MOD;
	if( hud1 != hud2 )
		SetEntProp(client, Prop_Send, "m_iHideHUD", hud1);
	
	if( img <= 25 )
		AttachParticle(client, "blood_pool", 0.1);
	
	int ref = EntRefToEntIndex(g_iLowLifeParticle[client]);
	if( img <= 10 && ref <= 0 && IsPlayerAlive(client) ) {
		int ent = AttachParticle(client, "danger_in_zone", 99999.9);
		
		g_iLowLifeParticle[client] = EntIndexToEntRef(ent);
		
		SetTransmitFlags(ent);
		Entity_SetOwner(ent, client);
		SDKHook(ent, SDKHook_SetTransmit, OnSetTransmitView);
	}
	if( img > 10 && ref > 0 )
		AcceptEntityInput(ref, "Kill");
}
// -----------------------------------------------------------------------
public Action OnSetTransmitView(int entity, int client) {
	SetTransmitFlags(entity);
	
	if( Entity_GetOwner(entity) == client )
		return Plugin_Continue;
	return Plugin_Stop;
}
public void SetTransmitFlags(int ent) {
    if( GetEdictFlags(ent) & FL_EDICT_ALWAYS )
    	SetEdictFlags(ent, (GetEdictFlags(ent) ^ FL_EDICT_ALWAYS)); 
}