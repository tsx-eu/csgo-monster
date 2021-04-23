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
	name = "DH: Bolt",
	author = "KoSSoLaX`",
	description = "",
	version = "1.0",
	url = "zaretti.be"
};

char g_szModels[][PLATFORM_MAX_PATH] = {
	"models/dh/bolt/bolt.mdl",
	"models/dh/bolt/gear.mdl",
//	"models/dh/bolt/goldbolt.mdl",
	"models/dh/bolt/nut.mdl",
//	"models/dh/bolt/platiniumbolt.mdl",
	"models/dh/bolt/washer.mdl",
	
//	"models/dh/crate/ammo.mdl",
	"models/dh/crate/bolt.mdl",
//	"models/dh/crate/explosive.mdl",
//	"models/dh/crate/iron.mdl",
//	"models/dh/crate/nanotech.mdl"	
};
char g_szSounds[][PLATFORM_MAX_PATH] = {	
	"sound/dh/ambiant/bolt1.mp3",
	"sound/dh/ambiant/bolt2.mp3",
	"sound/dh/ambiant/bolt3.mp3"	
};


public void OnPluginStart() {
	CreateTimer(1.0, Spawn);
}
public Action Spawn(Handle timer, any none) {
	float pos[3];
	Entity_GetAbsOrigin(1, pos);
	
	
	SpawnCrate(view_as<float>({ -256.0, 0.0, 64.0 }));
}
void SpawnCrate(float pos[3]) {
	int ent = CreateEntityByName("prop_physics");
	DispatchKeyValue(ent, "classname", "crate");
	DispatchKeyValue(ent, "model", "models/dh/crate/bolt.mdl");
	DispatchSpawn(ent);
	
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	SDKHook(ent, SDKHook_OnTakeDamage, OnTakeDamage);
}
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3]) {
	if( attacker != 0 ) {
		
		float pos[3];
		Entity_GetAbsOrigin(victim, pos);
		pos[2] += 8.0;
		
		ShowParticle(pos, "crate", 2.0);
		SpawnBolt(pos);
		
		AcceptEntityInput(victim, "Kill");
	}
}
void SpawnBolt(float pos[3]) {
	char tmp[PLATFORM_MAX_PATH];
	
	int ent = CreateEntityByName("hegrenade_projectile");
	DispatchKeyValue(ent, "classname", "bolt");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	SetEntPropFloat(ent, Prop_Send, "m_flElasticity", 0.0);
	
	SetEntityRenderMode(ent, RENDER_NONE);
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	
	int dst = CreateEntityByName("info_particle_system");
	DispatchKeyValue(dst, "OnUser1", "!self,KillHierarchy,,1.1,-1");
	Format(tmp, sizeof(tmp), "target_%d_%d", dst, GetRandomInt(-99999, 99999));
	
	DispatchKeyValue(dst, "targetname", tmp);
	DispatchSpawn(dst);
	ActivateEntity(dst);
	
	int src = CreateEntityByName("info_particle_system");
	DispatchKeyValue(src, "OnUser1", "!self,KillHierarchy,,1.1,-1");
	DispatchKeyValue(src, "OnUser2", "!self,DestroyImmediately,,1.0,-1");
	DispatchKeyValue(src, "cpoint1", tmp);
	DispatchKeyValue(src, "effect_name", "bolt");
	DispatchSpawn(src);
	
	TeleportEntity(src, pos, NULL_VECTOR, NULL_VECTOR);
	
	ActivateEntity(src); 
	AcceptEntityInput(src, "Start");
	
	SetEntPropEnt(ent, Prop_Data, "m_hEffectEntity", src);
	SetEntPropEnt(src, Prop_Data, "m_hEffectEntity", dst);
	
	CreateTimer(0.1, OnProjectileThink, EntIndexToEntRef(ent), TIMER_REPEAT);
}
public Action OnProjectileThink(Handle timer, any ref) {
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;

	float dist = 256.0;
	int nearest = -1;
	
	for(int i=1; i<MaxClients; i++) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		
		float tmp = Entity_GetDistance(ent, i);
		if( tmp < dist ) {
			tmp = dist;
			nearest = i;
		}
	}
	
	if( nearest > 0 ) {
		int src = GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity");
		int dst = GetEntPropEnt(src, Prop_Data, "m_hEffectEntity");
		
		SetVariantString("!activator");
		AcceptEntityInput(dst, "SetParent", nearest);
		TeleportEntity(dst, view_as<float>({ 0.0, 0.0, 32.0 }), NULL_VECTOR, NULL_VECTOR);
		
		AcceptEntityInput(src, "StopPlayEndCap");
		AcceptEntityInput(src, "FireUser1");
		AcceptEntityInput(src, "FireUser2");
		AcceptEntityInput(dst, "FireUser1");
		AcceptEntityInput(ent, "Kill");
		
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public void OnMapStart() {
	for (int i = 0; i < sizeof(g_szModels); i++) {
		Precache_Model(g_szModels[i]);
	}
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}
