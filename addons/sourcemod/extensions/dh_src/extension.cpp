#include "extension.h"

#include "amtl/am-string.h"
#include "CDetour/detours.h"
#include "asm/asm.h"
#include "sourcehook.h"

#ifdef _LINUX
#include <link.h>
#endif

/**
 * @file extension.cpp
 * @brief Implement extension code here.
 */

DH g_sglExtInterface;		/**< Global singleton for extension's main interface */
SMEXT_LINK(&g_sglExtInterface);
CGlobalVars *gpGlobals;
IPhysics *iphysics = NULL;

IForward *g_pIsFollowingSomeoneForwardPre = NULL;
IForward *g_pTrackPathForwardPre = NULL;
IForward *g_pWiggleForwardPre = NULL;

IForward *g_pUpdateFollowingForwardPre = NULL;
IForward *g_pUpdateFollowingForwardPost = NULL;

IForward *g_pCalcMainActivityForwardPre = NULL;
IForward *g_pCalcMainActivityForwardPost = NULL;

/*
size_t UTIL_DecodeHexString(unsigned char *buffer, size_t maxlength, const char *hexstr) {
	size_t written = 0;
	size_t length = strlen(hexstr);

	for (size_t i = 0; i < length; i++)
	{
		if (written >= maxlength)
			break;
		buffer[written++] = hexstr[i];
		if (hexstr[i] == '\\' && hexstr[i + 1] == 'x')
		{
			if (i + 3 >= length)
				continue;

			char s_byte[3];
			int r_byte;
			s_byte[0] = hexstr[i + 2];
			s_byte[1] = hexstr[i + 3];
			s_byte[2] = '\0';

			sscanf(s_byte, "%x", &r_byte);

			buffer[written - 1] = r_byte;

			i += 3;
		}
	}

	return written;
}
void *GetAddressFromKeyValues(void *pBaseAddr, IGameConfig *pGameConfig, const char *key)
{
	const char *value = pGameConfig->GetKeyValue(key);
	if (!value)
		return nullptr;

	if (value[0] == '@')
		return memutils->ResolveSymbol(pBaseAddr, &value[1]);

	unsigned char signature[200];
	size_t real_bytes = UTIL_DecodeHexString(signature, sizeof(signature), value);
	if (real_bytes < 1)
		return nullptr;

#ifdef _LINUX
	struct link_map *dlmap = (struct link_map *)pBaseAddr;
	pBaseAddr = (void *)dlmap->l_addr;
#endif

	return memutils->FindPattern(pBaseAddr, (char *)signature, real_bytes);
}
*/


typedef void (*TrackPath_func)(CBaseEntity* pEntity, const Vector& pos, float deltaT);
void TrackPath(CBaseEntity* pEntity, const Vector& pos, float deltaT) {

	cell_t vec[3] = {sp_ftoc(pos.x), sp_ftoc(pos.y), sp_ftoc(pos.z)};
	Vector vec2 = pos;

	cell_t result = Pl_Continue;

	g_pTrackPathForwardPre->PushCell(gamehelpers->EntityToBCompatRef(pEntity));
	g_pTrackPathForwardPre->PushArray(vec, 3, SM_PARAM_COPYBACK);
	g_pTrackPathForwardPre->PushCell(deltaT);
	g_pTrackPathForwardPre->Execute(&result);

	if( result == Pl_Changed ) {
		vec2.x = sp_ctof(vec[0]);
		vec2.y = sp_ctof(vec[1]);
		vec2.z = sp_ctof(vec[2]);
	}

	if( result == Pl_Continue || result == Pl_Changed ) {
		((TrackPath_func)g_sglExtInterface.g_hTrackPath->GetTrampoline())(pEntity, vec2, deltaT);
	}
}

typedef bool (*IsFollowingSomeone_func)(CBaseEntity* pEntity);
bool IsFollowingSomeone(CBaseEntity* pEntity) {
	cell_t result = Pl_Continue;
	g_pIsFollowingSomeoneForwardPre->PushCell(gamehelpers->EntityToBCompatRef(pEntity));
	g_pIsFollowingSomeoneForwardPre->Execute(&result);

	if( result == Pl_Continue ) {
		return ((IsFollowingSomeone_func)g_sglExtInterface.g_hIsFollowingSomeone->GetTrampoline())(pEntity);
	}

	return false;
}

typedef void (*Wiggle_func)(CBaseEntity* pEntity);
void Wiggle(CBaseEntity* pEntity) {
	cell_t result = Pl_Continue;
	g_pWiggleForwardPre->PushCell(gamehelpers->EntityToBCompatRef(pEntity));
	g_pWiggleForwardPre->Execute(&result);

	if( result == Pl_Continue ) {
		((Wiggle_func)g_sglExtInterface.g_hWiggle->GetTrampoline())(pEntity);
	}
}

typedef void (*UpdateFollowing_func)(CBaseEntity* pEntity, float deltaT);
void UpdateFollowing(CBaseEntity* pEntity, float deltaT) {
	cell_t result = Pl_Continue;
	g_pUpdateFollowingForwardPre->PushCell(gamehelpers->EntityToBCompatRef(pEntity));
	g_pUpdateFollowingForwardPre->Execute(&result);

	if( result == Pl_Continue ) {
		((UpdateFollowing_func)g_sglExtInterface.g_hUpdateFollowing->GetTrampoline())(pEntity, deltaT);
	}

	g_pUpdateFollowingForwardPost->PushCell(gamehelpers->EntityToBCompatRef(pEntity));
	g_pUpdateFollowingForwardPost->Execute();
}

typedef int (*CalcMainActivity_func)(CBaseEntity* pEntity);
int CalcMainActivity(CBaseEntity* pEntity) {
	cell_t result = Pl_Continue;
	cell_t data = -1;

	g_pCalcMainActivityForwardPre->PushCell(42);
	g_pCalcMainActivityForwardPre->PushCellByRef(&data);
	g_pCalcMainActivityForwardPre->Execute(&result);

	if( result == Pl_Continue ) {
		data = ((CalcMainActivity_func)g_sglExtInterface.g_hCalcMainActivity->GetTrampoline())(pEntity);
	}

	g_pCalcMainActivityForwardPost->PushCell(42);
	g_pCalcMainActivityForwardPost->PushCell(data);
	g_pCalcMainActivityForwardPost->Execute();

	return result;
}



bool DH::SDK_OnLoad(char *error, size_t maxlength, bool late) {
	IGameConfig *g_pGameConf;

	if (!gameconfs->LoadGameConfigFile("test.gamedata", &g_pGameConf, error, maxlength))
		return false;

	// ----------------------------------------------------------------------------------------------------------
	void *addr_IsFollowingSomeone;
	if ( !g_pGameConf->GetMemSig("IsFollowingSomeone", &addr_IsFollowingSomeone) || !addr_IsFollowingSomeone ) {
		snprintf(error, maxlength, "Failed to lookup signature: IsFollowingSomeone");
		return false;
	}
	g_hIsFollowingSomeone = new subhook::Hook(addr_IsFollowingSomeone, (void *)IsFollowingSomeone);
	g_hIsFollowingSomeone->Install();
	//
	g_pIsFollowingSomeoneForwardPre = forwards->CreateForward("DH_OnIsFollowingSomeonePre", ET_Hook, 1, NULL, Param_Cell);
	// ----------------------------------------------------------------------------------------------------------
	void *addr_Wiggle;
	if ( !g_pGameConf->GetMemSig("Wiggle", &addr_Wiggle) || !addr_Wiggle ) {
		snprintf(error, maxlength, "Failed to lookup signature: Wiggle");
		return false;
	}
	g_hWiggle = new subhook::Hook(addr_Wiggle, (void *)Wiggle);
	g_hWiggle->Install();
	//
	g_pWiggleForwardPre = forwards->CreateForward("DH_OnWigglePre", ET_Hook, 1, NULL, Param_Cell);
	// ----------------------------------------------------------------------------------------------------------
	void *addr_UpdateFollowing;
	if ( !g_pGameConf->GetMemSig("UpdateFollowing", &addr_UpdateFollowing) || !addr_UpdateFollowing ) {
		snprintf(error, maxlength, "Failed to lookup signature: UpdateFollowing");
		return false;
	}
	g_hUpdateFollowing = new subhook::Hook(addr_UpdateFollowing, (void *)UpdateFollowing);
	g_hUpdateFollowing->Install();
	//
	g_pUpdateFollowingForwardPre = forwards->CreateForward("DH_OnUpdateFollowingPre", ET_Hook, 1, NULL, Param_Cell);
	g_pUpdateFollowingForwardPost = forwards->CreateForward("DH_OnUpdateFollowingPost", ET_Hook, 1, NULL, Param_Cell);
	// ----------------------------------------------------------------------------------------------------------
        void *addr_CalcMainActivity;
        if ( !g_pGameConf->GetMemSig("CalcMainActivity", &addr_CalcMainActivity) || !addr_CalcMainActivity ) {
                snprintf(error, maxlength, "Failed to lookup signature: CalcMainActivity");
                return false;
        }
        g_hCalcMainActivity = new subhook::Hook(addr_CalcMainActivity, (void *)CalcMainActivity);
        g_hCalcMainActivity->Install();
	g_pCalcMainActivityForwardPre = forwards->CreateForward("DH_OnCalcMainActivityPre", ET_Hook, 2, NULL, Param_Cell, Param_CellByRef);
	g_pCalcMainActivityForwardPost = forwards->CreateForward("DH_OnCalcMainActivityPost", ET_Hook, 2, NULL, Param_Cell, Param_Cell);
        // ----------------------------------------------------------------------------------------------------------
	void* addr_TrackPath;
	if ( !g_pGameConf->GetMemSig("TrackPath", &addr_TrackPath) || !addr_TrackPath ) {
		snprintf(error, maxlength, "Failed to lookup signature: TrackPath");
		return false;
	}
	g_hTrackPath = new subhook::Hook(addr_TrackPath, (void *)TrackPath);
	g_hTrackPath->Install();
	g_pTrackPathForwardPre = forwards->CreateForward("DH_OnTrackPath", ET_Hook, 3, NULL, Param_Cell, Param_Array, Param_Cell);
	// ----------------------------------------------------------------------------------------------------------

	sharesys->RegisterLibrary(myself, "dh");
	sharesys->AddNatives(myself, g_PhysNatives);
	sharesys->AddNatives(myself, g_NavNatives);

	plsys->AddPluginsListener(this);

	return true;
}

void DH::SDK_OnUnload() {
	plsys->RemovePluginsListener(this);

	forwards->ReleaseForward(g_pIsFollowingSomeoneForwardPre);
	g_hIsFollowingSomeone->Remove();
	delete g_hIsFollowingSomeone;

	forwards->ReleaseForward(g_pWiggleForwardPre);
        g_hWiggle->Remove();
        delete g_hWiggle;

	forwards->ReleaseForward(g_pUpdateFollowingForwardPre);
	forwards->ReleaseForward(g_pUpdateFollowingForwardPost);
	g_hUpdateFollowing->Remove();
	delete g_hUpdateFollowing;

        forwards->ReleaseForward(g_pCalcMainActivityForwardPre);
        forwards->ReleaseForward(g_pCalcMainActivityForwardPost);
        g_hCalcMainActivity->Remove();
        delete g_hCalcMainActivity;
}

void DH::OnPluginLoaded(IPlugin *plugin) {
	// TBD
}

void DH::OnPluginUnloaded(IPlugin *plugin) {
	// TBD
}
bool DH::SDK_OnMetamodLoad(ISmmAPI *ismm, char *error, size_t maxlen, bool late) {
	gpGlobals = g_SMAPI->GetCGlobals();
	GET_V_IFACE_CURRENT(GetPhysicsFactory, iphysics, IPhysics, VPHYSICS_INTERFACE_VERSION);

	g_SMAPI->AddListener(g_PLAPI, this);

	return true;
}
