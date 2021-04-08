#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>
#include <phun>
#include <sendproxy>
#include <cstrike>

#define HIDEHUD_HEALTH_AND_WEAPON 	(1<<4)
#define HIDEHUD_THE_CHAT			(1<<7)
#define HIDEHUD_RADAR	 			(1<<12)

//#define HIDEHUD_MOD					(HIDEHUD_HEALTH_AND_WEAPON|HIDEHUD_THE_CHAT|HIDEHUD_RADAR)
#define HIDEHUD_MOD					(1<<0)


int g_iLowLifeParticle[65];

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
	
	RegAdminCmd("sm_effect_particles", Effect_Particle, 	ADMFLAG_BAN, 	"sm_effect_particles [player] [name] [delay]");
}

public Action Effect_Particle(int client, int args) {
	int target = GetCmdArgInt(1);
	char arg2[32], arg4[32];
	GetCmdArg(2, arg2, sizeof(arg2));
	float delay = GetCmdArgFloat(3);
	
	if( IsValidEdict(target) && IsValidEntity(target) ) {
		int particles = AttachParticle(target, arg2, delay);
		
		if( args == 4 ) {
			GetCmdArg(4, arg4, sizeof(arg4));
			SetVariantString(arg4);
			AcceptEntityInput(particles, "SetParentAttachment", particles, particles, 0);
		}
	}
	
	return Plugin_Handled;
}
public void OnMapStart() {
	PrecacheGeneric("particles/blood_impact_gore.pcf", true);
	PrecacheGeneric("particles/kosso_1.pcf", true);
	
	PrecacheMaterial("dh/hud/WeaponSwitch/active.vmt");
	PrecacheMaterial("dh/hud/WeaponSwitch/inactive.vmt");
}
public void OnConfigsExecuted() {
	ServerCommand("mp_playercashawards 0");
	ServerCommand("mp_teamcashawards 0");
}
public void OnClientPutInServer(int client) {
	g_iLowLifeParticle[client] = INVALID_ENT_REFERENCE;

	SDKHook(client, SDKHook_OnTakeDamagePost, OnDamage);
	CreateTimer(1.0, Task_Client, GetClientUserId(client), TIMER_REPEAT);	
	HUD_Update(client);
}
public void OnClientDisconnect(int client) {
	int ref = EntRefToEntIndex(g_iLowLifeParticle[client]);
	if( ref > 0 )
		AcceptEntityInput(ref, "Kill");
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
	int img = RoundToCeil(ratio * 19.0) * 5;
	if( img > 95 )
		img = 95;
	if( img < 0 )
		img = 0;
	
	ClientCommand(client, "r_screenoverlay dh/hud/HP/%d", img);
	
	int hud1 = GetEntProp(client, Prop_Send, "m_iHideHUD");
	int hud2 = hud1;
	hud1 |= HIDEHUD_MOD;
	hud1 = 0;
	if( hud1 != hud2 )
		SetEntProp(client, Prop_Send, "m_iHideHUD", hud1);
	
	if( img <= 25 )
		AttachParticle(client, "blood_pool", 0.1);
	
	int ref = EntRefToEntIndex(g_iLowLifeParticle[client]);
	
	if( img <= 10 && ref <= 0 && IsPlayerAlive(client) )
		g_iLowLifeParticle[client] = EntIndexToEntRef(AttachParticle(client, "danger_in_zone", 99999.9));
	if( img > 10 && ref > 0 )
		AcceptEntityInput(ref, "Kill");
}
