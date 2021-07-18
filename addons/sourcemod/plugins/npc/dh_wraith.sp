#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <phun>

#include <dh>
#include <precache>

char g_szModel[PLATFORM_MAX_PATH] =	"models/dh/wraith/wraith.mdl";

char g_szSounds[][PLATFORM_MAX_PATH] = {
	
};

int g_cBeam;

public void OnLibraryAdded(const char[] sLibrary) {
	if( StrEqual(sLibrary, "DH-CORE") ) {
		// ---- fire
		{
			NPCClass g_Class = NPCClass("Fire Wraith", "wraith_fire", g_szModel);
			g_Class.Health = 250;
			g_Class.Speed = 250.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 634+2048;
			g_Class.MaxBody = 634+2048;
			g_Class.MinSkin = 4;
			g_Class.MaxSkin = 4;
			g_Class.NearRange = 300.0;
			g_Class.WaitRange = 1024.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			g_Class.AddAttack(NPC_ATTACK_WEAPON, 	1024.0);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	1, 		100, 	30.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     0, 		80, 	40.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		0, 		80, 	40.0);
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	5,		30, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK2, 	3,		30, 	30.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	7, 		50, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_DYING, 	8, 		30, 	30.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
		// ---- snow
		{
			NPCClass g_Class = NPCClass("Snow Wraith", "wraith_snow", g_szModel);
			g_Class.Health = 250;
			g_Class.Speed = 250.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 634+2048;
			g_Class.MaxBody = 634+2048;
			g_Class.MinSkin = 5;
			g_Class.MaxSkin = 5;
			g_Class.NearRange = 300.0;
			g_Class.WaitRange = 1024.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			g_Class.AddAttack(NPC_ATTACK_WEAPON, 	1024.0);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	1, 		100, 	30.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     0, 		80, 	40.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		0, 		80, 	40.0);
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	5,		30, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK2, 	3,		30, 	30.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	7, 		50, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_DYING, 	8, 		30, 	30.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
		// ---- bolt
		{
			NPCClass g_Class = NPCClass("Bolt Wraith", "wraith_bolt", g_szModel);
			g_Class.Health = 250;
			g_Class.Speed = 250.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 634+2048;
			g_Class.MaxBody = 634+2048;
			g_Class.MinSkin = 6;
			g_Class.MaxSkin = 6;
			g_Class.NearRange = 300.0;
			g_Class.WaitRange = 1024.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			g_Class.AddAttack(NPC_ATTACK_WEAPON, 	1024.0);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	1, 		100, 	30.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     0, 		80, 	40.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		0, 		80, 	40.0);
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	5,		30, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK2, 	3,		30, 	30.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	7, 		50, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_DYING, 	8, 		30, 	30.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
		// ---- dark
		{
			NPCClass g_Class = NPCClass("Dark Wraith", "wraith_dark", g_szModel);
			g_Class.Health = 250;
			g_Class.Speed = 250.0;
			g_Class.Gravity = 1.0;
			g_Class.MinBody = 634+2048;
			g_Class.MaxBody = 634+2048;
			g_Class.MinSkin = 7;
			g_Class.MaxSkin = 7;
			g_Class.NearRange = 300.0;
			g_Class.WaitRange = 1024.0;
			
			g_Class.AddAttack(NPC_ATTACK_MELEE, 	NPC_RANGE_MELEE);
			g_Class.AddAttack(NPC_ATTACK_WEAPON, 	1024.0);
			
			g_Class.AddAnimation(NPC_ANIM_IDLE, 	1, 		100, 	30.0);
			
			g_Class.AddAnimation(NPC_ANIM_WALK,     0, 		80, 	40.0);
			g_Class.AddAnimation(NPC_ANIM_RUN, 		0, 		80, 	40.0);
			
			g_Class.AddAnimation(NPC_ANIM_ATTACK, 	5,		30, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_ATTACK2, 	3,		30, 	30.0);
			
			g_Class.AddAnimation(NPC_ANIM_DYING, 	7, 		50, 	30.0);
			g_Class.AddAnimation(NPC_ANIM_DYING, 	8, 		30, 	30.0);
			
			g_Class.AddEvent(NPC_EVENT_SPAWN,	OnSpawn);
			g_Class.AddEvent(NPC_EVENT_ATTACK,	OnAttack);
			g_Class.AddEvent(NPC_EVENT_DEAD,	OnDead);
			g_Class.AddEvent(NPC_EVENT_DAMAGE,	OnDamage);
		}
	}
}
public float OnAttack(NPCInstance entity, int attack_id) {
	static char sound[PLATFORM_MAX_PATH];
	
	float time = 0.0;
	
	switch(attack_id) {
		case 0: {
			entity.Melee(10, NPC_RANGE_MELEE, 10 / 50.0);
			time = entity.Animate(NPC_ANIM_ATTACK);
		}
		case 1: {
			entity.Projectile(NULL_STRING, 5 / 30.0, 0.0, 380.0, 0.0001, OnProjectileCreate, OnProjectileHit);
			time = entity.Animate(NPC_ANIM_ATTACK2);
			entity.Freeze = GetGameTime() + time;
		}
	}
	
	return time;
}
public void OnProjectileCreate(NPCInstance entity, int inflictor) {
	char type[64];
	getWraithType(entity, type, sizeof(type));
	Format(type, sizeof(type), "elementary_%s", type);
	
	int particle = AttachParticle(inflictor, type, 30.0);
	SetVariantString("fireball");
	AcceptEntityInput(particle, "SetParentAttachment");
	
	if( entity.Skin == 4 )
		TE_SetupBeamFollow(inflictor, g_cBeam, g_cBeam, 1.0, 1.0, 0.0, 1, {200,   0,   0, 50} );
	else if( entity.Skin == 5 )
		TE_SetupBeamFollow(inflictor, g_cBeam, g_cBeam, 1.0, 1.0, 0.0, 1, {200, 200, 200, 50} );
	else if( entity.Skin == 6 )
		TE_SetupBeamFollow(inflictor, g_cBeam, g_cBeam, 1.0, 1.0, 0.0, 1, {200, 200,   0, 50} );
	else if( entity.Skin == 7 )
		TE_SetupBeamFollow(inflictor, g_cBeam, g_cBeam, 1.0, 1.0, 0.0, 1, {  0, 200, 200, 50} );
	else
		TE_SetupBeamFollow(inflictor, g_cBeam, g_cBeam, 1.0, 1.0, 0.0, 1, {200, 200, 200, 50} );
	TE_SendToAll();
}
public void OnProjectileHit(NPCInstance entity, int inflictor, int victim) {
	
}
public void OnSpawn(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
	
	int animator = EntRefToEntIndex(DH_GetInstanceInt(entity, NPC_iAnimator));
	if( animator > 0 ) {
		
		//int particle = AttachParticle(animator, "wraith", 999999.9);
		//SetVariantString("smoky");
		//AcceptEntityInput(particle, "SetParentAttachment");
		
		char type[64];
		getWraithType(entity, type, sizeof(type));
		Format(type, sizeof(type), "elementary_%s", type);
		
		int particle = AttachParticle(animator, type, 999999.9);
		SetVariantString("fireball");
		AcceptEntityInput(particle, "SetParentAttachment");
	}
	
}
public void OnDead(NPCInstance entity) {
	static char sound[PLATFORM_MAX_PATH];
}
public void OnDamage(NPCInstance entity, int attacker, int damage) {
	static char sound[PLATFORM_MAX_PATH];
}

public void OnMapStart() {
	g_cBeam = Precache_Model("materials/sprites/laserbeam.vmt");
	Precache_Model(g_szModel);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		Precache_Sound(g_szSounds[i]);
	}
}

stock void getWraithType(NPCInstance entity, char[] type, int max) {
	if( entity.Skin == 4 )
		Format(type, max, "fire");
	else if( entity.Skin == 5 )
		Format(type, max, "snow");
	else if( entity.Skin == 6 )
		Format(type, max, "bolt");
	else if( entity.Skin == 7 )
		Format(type, max, "dark");
}
stock int getRandomBody() {
	int body = 0;
	bool cloth = GetRandomInt(0, 1) == 0;
	
	if( GetRandomInt(0, 1) == 0 ) // wristband
		body += 1;
	
	if( cloth && GetRandomInt(0, 1) == 0 ) // sleeve
		body += 2;
		
	if( !cloth && GetRandomInt(0, 1) == 0 ) // shoulderpad
		body += 4;
	
	if( GetRandomInt(0, 1) == 0 ) // scarf
		body += 8;
	
	if( GetRandomInt(0, 1) == 0 ) // necklace
		body += 16;
	
	if( cloth && GetRandomInt(0, 1) == 0 ) // hood
		body += 32;
	
	if( GetRandomInt(0, 1) == 0 ) // hair
		body += 64;
	
	if( GetRandomInt(0, 1) == 0 ) // eye
		body += 128;
	
	if( !cloth && GetRandomInt(0, 1) == 0 ) // dress
		body += 256;
	
	if( cloth ) // cloth
		body += 512;
	
	int weapon = GetRandomInt(0, 2);
	switch(weapon) {
		case 1: {
			body += 1024;
		}
		case 2: {
			body += 2048;
		}
	}
	
	return body;
}