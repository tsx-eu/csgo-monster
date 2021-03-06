#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>
#include <cstrike>

#include <dh>
#include <phun>
#include <custom_weapon_mod.inc>
#include <precache>

#define HIDEHUD_HEALTH_AND_WEAPON 	(1<<4)
#define HIDEHUD_THE_CHAT			(1<<7)
#define HIDEHUD_RADAR	 			(1<<12)

//#define HIDEHUD_MOD					(HIDEHUD_HEALTH_AND_WEAPON|HIDEHUD_THE_CHAT|HIDEHUD_RADAR)
#define HIDEHUD_MOD					(HIDEHUD_HEALTH_AND_WEAPON|HIDEHUD_RADAR)

int g_iLowLifeParticle[65];
int g_iPosition[65][5][3];
int g_iPositionTablette[65][2];
bool g_TabletteActive[65];


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
	Precache_Particles("particles/kosso_1.pcf");
	Precache_Particles("particles/kosso_2.pcf");
	
	for(int i=0; i<20; i++) {
		Format(tmp, sizeof(tmp), "materials/dh/hud/HP/%d.vmt", i * 5);
		Precache_Texture(tmp);
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
	static float lastTest[65];
	static float dir[3];
	
	if( !(oldButton[client] & IN_SCORE) && (buttons & IN_SCORE) ) {
		tablet[client] = EntIndexToEntRef(CWM_Spawn(CWM_GetId("tablet"), client, NULL_VECTOR, NULL_VECTOR));
		SDKHook(client, SDKHook_PreThink, OnThink);
		g_TabletteActive[client] = true;
	}
	if( (oldButton[client] & IN_SCORE) && !(buttons & IN_SCORE) ) {
		int wep = EntRefToEntIndex(tablet[client]);
		
		g_TabletteActive[client] = false;
		
		if( wep > 0 ) {
			RemovePlayerItem(client, wep);
			AcceptEntityInput(wep, "Kill");
		}
		
		// prevent unhook if not hooked:
		SDKHook(client, SDKHook_PreThink, OnThink);
		SDKUnhook(client, SDKHook_PreThink, OnThink);
	}
	

	dir[0] += float(mouse[0]);
	dir[1] += float(mouse[1]);		
	
	if( !( mouse[0] == 0 && mouse[1] == 0) && lastTest[client] < GetGameTime() && g_TabletteActive[client] ) {
		
		float an2g[3];
		float min = 999.0;
		int DirectionFinale;
		
		GetVectorAngles(dir, an2g);
		
		
		
		g_iPosition[client][ g_iPositionTablette[client][0] ][ g_iPositionTablette[client][1] ] = 0;
		
		for(int i = 0; i<= 360 ; i += 45){
			if(FloatAbs(an2g[1] - i) < min){
				min = FloatAbs(an2g[1] - i);
				DirectionFinale = i;
			}
		}
	
		switch(DirectionFinale){
			case 0,360:
			{
				PrintToChatAll("Droite");
				if(g_iPositionTablette[client][0] < 4){
					g_iPositionTablette[client][0] += 1;
				}
			}
			case 45:
			{ 
				PrintToChatAll("Bas Droite");
				if(g_iPositionTablette[client][0] < 4 ){
					g_iPositionTablette[client][0] += 1;
				}
				if(g_iPositionTablette[client][1] < 2 ){
					g_iPositionTablette[client][1] += 1;
				}
			}
			case 90:
			{
				PrintToChatAll("Bas");
				if(g_iPositionTablette[client][1] < 2 ){
					g_iPositionTablette[client][1] += 1;
				}
			}
			case 135:
			{
				PrintToChatAll("Gauche Bas");
				if(g_iPositionTablette[client][0] > 0 ){
					g_iPositionTablette[client][0] -= 1;
				}
				if(g_iPositionTablette[client][1] < 2 ){
					g_iPositionTablette[client][1] += 1;
				}
			}
			case 180:
			{
				PrintToChatAll("Gauche");
				if(g_iPositionTablette[client][0] > 0){
					g_iPositionTablette[client][0] -= 1;
				}
			}
			case 225:
			{
				PrintToChatAll("Haut Gauche");
				if(g_iPositionTablette[client][0] > 0){
					g_iPositionTablette[client][0] -= 1;
				}
				if(g_iPositionTablette[client][1] > 0){
					g_iPositionTablette[client][1] -= 1;
				}
			}
			case 270:
			{
				PrintToChatAll("Haut");
				if(g_iPositionTablette[client][1] > 0){
					g_iPositionTablette[client][1] -= 1;
				}
			}
			case 315:
			{
				PrintToChatAll("Droite Haut");
				if(g_iPositionTablette[client][0] < 4 && g_iPositionTablette[client][1] > 0){
					g_iPositionTablette[client][0] += 1;
					g_iPositionTablette[client][1] -= 1;
				}
			}
			
		}
		
		g_iPosition[client][ g_iPositionTablette[client][0] ][ g_iPositionTablette[client][1] ] = 2;
		
		lastTest[client] = GetGameTime() + 0.1;
		
		dir[0] = 0.0;
		dir[1] = 0.0;
		
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
	SetEntProp(client, Prop_Send, "m_nSurvivalTeam", 0);
	
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
