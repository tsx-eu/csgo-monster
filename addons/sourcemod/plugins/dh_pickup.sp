#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <smlib>
#include <cstrike>

#include <dh>
#include <phun>
#include <custom_weapon_mod.inc>
#include <precache.inc>

#define BOLT_DIST	256.0
#define BOLD_SPEED	2048.0


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
	"models/dh/crate/nanotech.mdl"	
};
char g_szSounds[][PLATFORM_MAX_PATH] = {	
	"dh/ambiant/bolt1.mp3",
	"dh/ambiant/bolt2.mp3",
	"dh/ambiant/bolt3.mp3",
	"dh/ambiant/heal.mp3"	
};
public void OnPluginStart() {
	CreateTimer(1.0, Spawn, _, TIMER_REPEAT);
}
public Action Spawn(Handle timer, any none) {
	static char name[PLATFORM_MAX_PATH];
	
	float pos[3];
	int ent = 0;
	int entities[64], count = 0;
	
	while( (ent=FindEntityByClassname(ent, "trigger_multiple")) != -1 ) {
		SetEntProp(ent, Prop_Data, "m_spawnflags", 64); 
	}
	ent = 0;
	
	while( (ent=FindEntityByClassname(ent, "info_target")) != -1 ) {
		Entity_GetName(ent, name, sizeof(name));
		
		if( StrEqual(name, "@spawn_crate") ) {
			Entity_GetAbsOrigin(ent, pos);
			
			Handle tr = TR_TraceHullEx(pos, pos, view_as<float>({ -4.0, -4.0, 0.0 }), view_as<float>({ 4.0, 4.0, 16.0 }), MASK_SHOT);
			if( !TR_DidHit(tr) && !TR_StartSolid(tr) && TR_GetFraction(tr) > 0.9  )
				entities[count++] = ent;
			delete tr;
		}		
	}
	
	if( count > 0 ) {
		ent = entities[GetRandomInt(0, count - 1)];
		Entity_GetAbsOrigin(ent, pos);
		
		SpawnCrate(pos, GetRandomInt(1, 2));
	}
	return Plugin_Continue;
}
void SpawnCrate(float pos[3], int type) {
	int ent = CreateEntityByName("prop_physics");
	switch(type) {
		case 1: {
			DispatchKeyValue(ent, "classname", "crate_bolt");
			DispatchKeyValue(ent, "model", "models/dh/crate/bolt.mdl");
		}
		case 2: {
			DispatchKeyValue(ent, "classname", "crate_nanotech");
			DispatchKeyValue(ent, "model", "models/dh/crate/nanotech.mdl");
		}
	}
	
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	Entity_SetTakeDamage(ent, DAMAGE_YES);
	Entity_SetHealth(ent, 10);
	Entity_SetMaxHealth(ent, 10);
	TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
	
	
	if( type == 2 ) {
		SpawnEffect(pos, "nanotech", ent);
	}
	else {
		SpawnEffect(pos, "crate", ent);
	}
}
public void OnEntityDestroyed(int entity) {
	static char classname[PLATFORM_MAX_PATH];
	
	if( entity > 0 ) {
		float pos[3];
		GetEdictClassname(entity, classname, sizeof(classname));
		
		if( StrEqual(classname, "crate_bolt") ) {
			Entity_GetAbsOrigin(entity, pos);
			pos[2] += 8.0;
			
			ShowParticle(pos, "crate", 2.0);
			SpawnEffect(pos, "bolt");
		}
		if( StrEqual(classname, "crate_nanotech") ) {
			Entity_GetAbsOrigin(entity, pos);
			
			int ent = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
			int src = GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity");
			AcceptEntityInput(ent, "ClearParent");
			AcceptEntityInput(src, "ClearParent");
			
			TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		}
	}
}
void SpawnEffect(float pos[3], const char[] name, int parent=-1) {
	static char tmp[PLATFORM_MAX_PATH];
	
	int ent = CreateEntityByName("hegrenade_projectile");
	DispatchKeyValue(ent, "classname", name);
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
	DispatchKeyValue(src, "effect_name", name);
	DispatchSpawn(src);
	
	TeleportEntity(src, pos, NULL_VECTOR, NULL_VECTOR);
	
	if( parent > 0 ) {
		SetEntityMoveType(ent, MOVETYPE_NONE);
		SetVariantString("!activator");
		AcceptEntityInput(ent, "SetParent", parent);
		
		SetVariantString("!activator");
		AcceptEntityInput(src, "SetParent", ent);
		
		if( GetEntPropEnt(parent, Prop_Data, "m_hEffectEntity") > 0 )
			AcceptEntityInput(GetEntPropEnt(parent, Prop_Data, "m_hEffectEntity"), "Kill");
			
		
		SetEntPropEnt(parent, Prop_Data, "m_hEffectEntity", ent);
	}
	
	ActivateEntity(src); 
	AcceptEntityInput(src, "Start");
	
	int prev = GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity");
	
	if( prev > 0 ) {
		if( GetEntPropEnt(prev, Prop_Data, "m_hEffectEntity") )
			AcceptEntityInput(GetEntPropEnt(prev, Prop_Data, "m_hEffectEntity"), "Kill");
		AcceptEntityInput(prev, "Kill");
	}
	
	SetEntPropEnt(ent, Prop_Data, "m_hEffectEntity", src);
	SetEntPropEnt(src, Prop_Data, "m_hEffectEntity", dst);
	
	CreateTimer(0.1, OnProjectileThink, EntIndexToEntRef(ent), TIMER_REPEAT);
}
public Action OnProjectileThink(Handle timer, any ref) {
	static char classname[PLATFORM_MAX_PATH];
	
	int ent = EntRefToEntIndex(ref);
	if( ent <= 0 )
		return Plugin_Stop;
	
	if( Entity_GetParent(ent) > 0 )
		return Plugin_Continue;

	float dist = BOLT_DIST;
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
		GetEdictClassname(ent, classname, sizeof(classname));
		PrintToChatAll(classname);
		
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
		
		if( StrEqual(classname, "bolt") ) {
			CreateTimer(Entity_GetDistance(ent, nearest) / BOLD_SPEED, SendSoundBolt, nearest);
		}
		else if( StrEqual(classname, "nanotech") ) {
			CreateTimer(Entity_GetDistance(ent, nearest) / BOLD_SPEED, SendSoundHeal, nearest);
		}
			
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action SendSoundBolt(Handle timer, any client) {
	static char sound[PLATFORM_MAX_PATH];
	Format(sound, sizeof(sound), "dh/ambiant/bolt%d.mp3", GetRandomInt(1, 3));

	EmitSoundToAll(sound, client, _, _, _, _, GetRandomInt(90, 110));
}
public Action SendSoundHeal(Handle timer, any client) {
	EmitSoundToAll("dh/ambiant/heal.mp3", client, _, _, _, _, GetRandomInt(90, 110));
}
public void OnMapStart() {
	for (int i = 0; i < sizeof(g_szModels); i++) {
		Precache_Model(g_szModels[i]);
	}
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}
