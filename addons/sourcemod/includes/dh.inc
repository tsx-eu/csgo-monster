#if defined _dh_included
#endinput
#endif
#define _dh_included

native bool Phys_IsPhysicsObject(int entity);
native void Phys_SetMass(int entity,  float mass);
native float Phys_GetMass(int entity);


forward Action DH_OnUpdateFollowingPre(int hostage, float delta);
forward void DH_OnUpdateFollowingPost(int hostage, float delta);


public Extension __ext_sample =  {
	name = "DH",
	file = "dh.ext",
	autoload = 1,
	required = 1
};