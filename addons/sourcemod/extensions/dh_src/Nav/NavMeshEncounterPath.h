#ifndef __Navigation_navmeshencounterpath_h__
#define __Navigation_navmeshencounterpath_h__

#include "NavDirType.h"
#include "NavMeshEncounterPath.h"
#include "NavMeshEncounterSpot.h"

#include "../Struct/List.h"

class NavMeshEncounterPath {
public:
    NavMeshEncounterPath(unsigned int fromAreaID, NavDirType fromDirection, unsigned int toAreaID, NavDirType toDirection, List<NavMeshEncounterSpot*>* encounterSpots);
    ~NavMeshEncounterPath();

    void Destroy();

    unsigned int GetFromAreaID();
    NavDirType GetFromDirection();
    unsigned int GetToAreaID();
    NavDirType GetToDirection();
    List<NavMeshEncounterSpot*>* GetEncounterSpots();

private:
    unsigned int fromAreaID;
    NavDirType fromDirection;
    unsigned int toAreaID;
    NavDirType toDirection;
    List<NavMeshEncounterSpot*>* encounterSpots;
};

#endif