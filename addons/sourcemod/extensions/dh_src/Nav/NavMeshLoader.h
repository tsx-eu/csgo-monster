#ifndef __Navigation_navmeshloader_h__
#define __Navigation_navmeshloader_h__

#include <string.h>

#include <smsdk_ext.h>

#include "NavCornerType.h"
#include "NavDirType.h"
#include "NavLadderDirType.h"
#include "NavMesh.h"
#include "NavMeshArea.h"
#include "NavMeshConnection.h"
#include "NavMeshCornerLightIntensity.h"
#include "NavMeshEncounterPath.h"
#include "NavMeshEncounterSpot.h"
#include "NavMeshHidingSpot.h"
#include "NavMeshLadder.h"
#include "NavMeshLadderConnection.h"
#include "NavMeshPlace.h"
#include "NavMeshVisibleArea.h"

#include "NavGrid.h"

#include "Navigation.h"

#include "../Struct/HashMap.h"
#include "../Struct/List.h"

class NavMeshLoader {
public:
    NavMeshLoader(const char* mapName);
    ~NavMeshLoader();

    void Destroy();
    NavMesh* Load(char* error, int errorMaxlen);

private:
    unsigned int ReadData(void* output, unsigned int elementSize, unsigned int elementCount, FILE* fileHandle);

private:
    char mapName[100];
    unsigned int bytesRead;
};

#endif