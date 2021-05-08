#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>
#include <cstrike>

#include <dh>
#include <phun>
#include <custom_weapon_mod.inc>
#include <precache.inc>

public Plugin myinfo = {
	name = "DH: Waves",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};


enum struct s_challenge {
	char name[64];
	int difficulty;
	int waveCount;
	ArrayList waves;		
}

Database g_hDB;
StringMap g_hChallenges;
s_challenge g_hCurrent;
int g_iCurrentWave, g_iCurrentMonster, g_iCurrentMonsterKilled;

// ----------------------------------------------------------------------------------------------------------

public void OnPluginStart() {
	for(int i=1; i<=MaxClients; i++) {
		if( IsValidClient(i) )
			OnClientPutInServer(i);
	}
	
	RegConsoleCmd("sm_wave", Cmd_Wave);
	
	CreateTimer(0.1, OnFrame, 0, TIMER_REPEAT);	
	Database.Connect(OnDatabaseConnected, "dh");
}
public void OnClientPutInServer(int client) {
	CreateTimer(1.0, OnClientSecond, GetClientUserId(client), TIMER_REPEAT);
}
public Action OnFrame(Handle timer, any none) {
	static char name[PLATFORM_MAX_PATH], monster[64];
	
	if( g_hCurrent.waves == null || g_hCurrent.waves.Length <= g_iCurrentWave )
		return Plugin_Continue;
	
	ArrayList monsters = view_as<ArrayList>(g_hCurrent.waves.Get(g_iCurrentWave));
	if( g_iCurrentMonster >= monsters.Length )
		return Plugin_Continue;

	float pos[3];
	int ent = 0;
	int entities[64], count = 0;
	
	while( (ent=FindEntityByClassname(ent, "info_target")) != -1 ) {
		Entity_GetName(ent, name, sizeof(name));
		
		if( StrEqual(name, "@spawn_npc") || StrEqual(name, "spawn_npc") ) {
			Entity_GetAbsOrigin(ent, pos);
			
			Handle tr = TR_TraceHullEx(pos, pos, view_as<float>({ -8.0, -8.0, 0.0 }), view_as<float>({ 8.0, 8.0, 64.0 }), MASK_SHOT);
			if( !TR_DidHit(tr) && !TR_StartSolid(tr) && TR_GetFraction(tr) > 0.9  )
				entities[count++] = ent;
			delete tr;
		}
	}
	
	
	
	if( count > 0 ) {
		ent = entities[GetRandomInt(0, count - 1)];
		Entity_GetAbsOrigin(ent, pos);
		
		monsters.GetString(g_iCurrentMonster, monster, sizeof(monster));
		g_iCurrentMonster++;
		
		NPCInstance bot = NPCInstance(DH_GetClass(monster), pos);
		bot.Target = 1;
		
		CreateTimer(GetRandomFloat(0.5, 1.0), NPC_CheckKilled, EntIndexToEntRef(view_as<int>(bot)), TIMER_REPEAT);		
	}
	
	return Plugin_Continue;
}
public Action NPC_CheckKilled(Handle timer, any ref) {
	int ent = EntRefToEntIndex(ref);
	
	if( g_hCurrent.waves == null )
		return Plugin_Stop;
	
	
	
	if( ent <= 0 || view_as<NPCInstance>(ent).Health <= 0 ) {
		g_iCurrentMonsterKilled++;
		
		ArrayList monsters = view_as<ArrayList>(g_hCurrent.waves.Get(g_iCurrentWave));
		if( g_iCurrentMonsterKilled >= monsters.Length ) {
			g_iCurrentMonster = g_iCurrentMonsterKilled = 0;
			g_iCurrentWave++;
			
			if( g_hCurrent.waves.Length <= g_iCurrentWave ) {
				PrintToChatAll("Vous avez gagné!");
				
				g_hCurrent.waves = null;
			}
		}
		
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
public Action OnClientSecond(Handle timer, any userid) {
	int client = GetClientOfUserId(userid);
	if( client <= 0 )
		return Plugin_Stop;
	
	if( g_hCurrent.waves == null )
		return Plugin_Continue;
	
	ArrayList monsters = view_as<ArrayList>(g_hCurrent.waves.Get(g_iCurrentWave));
	
	SetHudTextParams(0.0125, 0.05, 2.0, 213, 19, 45, 255, 2, 0.0, 0.0, 0.0);
	ShowHudText(client, 1, "Vague: %d/%d - %s\nMonstres restant: %d", g_iCurrentWave+1, g_hCurrent.waveCount, g_hCurrent.name, monsters.Length - g_iCurrentMonsterKilled);
	
	return Plugin_Continue;
}
// ----------------------------------------------------------------------------------------------------------

public void OnDatabaseConnected(Database db, const char[] error, any data) {
	if( db == null || error[0] != 0 )
		SetFailState(error);
	g_hDB = db;
	
	if( g_hChallenges == null )
		g_hChallenges = new StringMap();
	
	g_hChallenges.Clear();
	
	g_hDB.Query(OnDatabaseResultChallenges, "SELECT C.`id` as `challenge`, C.`name`, C.`difficulty`, COUNT(W.`id`) `wave` FROM `dh_challenges` C INNER JOIN `dh_waves` W ON W.challenge = C.id GROUP BY C.`id` ORDER BY C.`id`;");
	g_hDB.Query(OnDatabaseResultMonster, 	"SELECT W.`challenge`, M.`wave`, M.`monster`, M.`count` FROM `dh_waves_monsters` M INNER JOIN `dh_waves` W ON W.id = M.wave ORDER BY W.`challenge`, M.`wave`, M.`id`;");
}
public void OnDatabaseResultChallenges(Database db, DBResultSet results, const char[] error, any none) {
	if( db == null || results == null )
		SetFailState(error);
	
	int colChallenge, colName, colWave, colDifficulty;
	char key[64];
	results.FieldNameToNum("challenge", colChallenge);
	results.FieldNameToNum("name", colName);
	results.FieldNameToNum("difficulty", colDifficulty);
	results.FieldNameToNum("wave", colWave);
	
	while( results.FetchRow() ) {		
		Format(key, sizeof(key), "%d", results.FetchInt(colChallenge));
		
		s_challenge data;
		g_hChallenges.GetArray(key, data, sizeof(data));
		
		results.FetchString(colName, data.name, sizeof(data.name));
		data.waveCount = results.FetchInt(colWave);
		data.difficulty = results.FetchInt(colDifficulty);
		
		g_hChallenges.SetArray(key, data, sizeof(data));
	}
}
public void OnDatabaseResultMonster(Database db, DBResultSet results, const char[] error, any none) {
	if( db == null || results == null )
		SetFailState(error);
	
	int colChallenge, colWave, colMonster, colCount;
	int challengeId, waveId, lastChallengeId, lastWaveId, count;
	char key[64], monster[64];
	results.FieldNameToNum("challenge", colChallenge);
	results.FieldNameToNum("wave", colWave);
	results.FieldNameToNum("monster", colMonster);
	results.FieldNameToNum("count", colCount);
	
	lastChallengeId = -1;
	lastWaveId = -1;
	
	while( results.FetchRow() ) {
		
		challengeId = results.FetchInt(colChallenge);
		waveId = results.FetchInt(colWave);
		count = results.FetchInt(colCount);
		
		Format(key, sizeof(key), "%d", results.FetchInt(colChallenge));
		
		s_challenge data;
		g_hChallenges.GetArray(key, data, sizeof(data));
		if( data.waves == null )
			data.waves = new ArrayList();
		
		if( lastWaveId != waveId || lastChallengeId != challengeId )
			data.waves.Push(new ArrayList(sizeof(monster)));
		
		results.FetchString(colMonster, monster, sizeof(monster));	
		for(int i = 0; i<count; i++)
			view_as<ArrayList>(data.waves.Get(data.waves.Length - 1)).PushString(monster);
		
		g_hChallenges.SetArray(key, data, sizeof(data));
		
		lastWaveId = waveId;
		lastChallengeId = challengeId;
	}
}

// ----------------------------------------------------------------------------------------------------------

public Action Cmd_Wave(int client, int args) {
	StringMapSnapshot keys = g_hChallenges.Snapshot();
	char key[64];
	
	Menu menu = new Menu(menu_Wave);
	menu.SetTitle("Choisir un match:");
	
	for(int i=0; i<keys.Length; i++) {
		keys.GetKey(i, key, sizeof(key));
		
		s_challenge data;
		g_hChallenges.GetArray(key, data, sizeof(data));
		
		menu.AddItem(key, data.name);
	}
	menu.Display(client, MENU_TIME_FOREVER);
	
	delete keys;
	
	return Plugin_Handled;
}
public int menu_Wave(Handle handler, MenuAction action, int client, int param) {
	if (action == MenuAction_Select) {
		char key[64];
		GetMenuItem(handler, param, key, sizeof(key));
		
		g_hChallenges.GetArray(key, g_hCurrent, sizeof(g_hCurrent));
		g_iCurrentWave = g_iCurrentMonster = g_iCurrentMonsterKilled = 0;
	}
	else if (action == MenuAction_End) {
		CloseHandle(handler);
	}
}
