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

    // Got a symbol here.
    if (value[0] == '@')
        return memutils->ResolveSymbol(pBaseAddr, &value[1]);

    // Convert hex signature to byte pattern
    unsigned char signature[200];
    size_t real_bytes = UTIL_DecodeHexString(signature, sizeof(signature), value);
    if (real_bytes < 1)
        return nullptr;

#ifdef _LINUX
    // The pointer returned by dlopen is not inside the loaded librarys memory region.
    struct link_map *dlmap = (struct link_map *)pBaseAddr;
    pBaseAddr = (void *)dlmap->l_addr;
#endif

    // Find that pattern in the pointed module.
    return memutils->FindPattern(pBaseAddr, (char *)signature, real_bytes);
}
*/

int IsFollowingSomeone(void* self) {
	return 0;
}

bool DH::SDK_OnLoad(char *error, size_t maxlength, bool late) {
	IGameConfig *g_pGameConf;

	if (!gameconfs->LoadGameConfigFile("test.gamedata", &g_pGameConf, error, maxlength))
		return false;

	void *addr;
	if ( !g_pGameConf->GetMemSig("IsFollowingSomeone", &addr) || !addr ) {
		snprintf(error, maxlength, "Failed to lookup signature: IsFollowingSomeone");
	}
	g_hIsFollowingSomeone = new subhook::Hook(addr, (void *)IsFollowingSomeone);
	g_hIsFollowingSomeone->Install();
	
	
	sharesys->RegisterLibrary(myself, "dh");
	plsys->AddPluginsListener(this);

	return true;
}

void DH::SDK_OnUnload() {
	plsys->RemovePluginsListener(this);

	g_hIsFollowingSomeone->Remove();
	delete g_hIsFollowingSomeone;
}

void DH::OnPluginLoaded(IPlugin *plugin) {
	// TBD
}

void DH::OnPluginUnloaded(IPlugin *plugin) {
	// TBD
}
