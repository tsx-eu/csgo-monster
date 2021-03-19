#include "NavMeshEncounterPath.h"

NavMeshEncounterPath::NavMeshEncounterPath(unsigned int fromAreaID, NavDirType fromDirection, unsigned int toAreaID, NavDirType toDirection, List<NavMeshEncounterSpot*>* encounterSpots)
{
    this->fromAreaID = fromAreaID;
    this->fromDirection = fromDirection;
    this->toAreaID = toAreaID;
    this->toDirection = toDirection;
    this->encounterSpots = encounterSpots;
}

NavMeshEncounterPath::~NavMeshEncounterPath()
{
    unsigned int encounterSpotCount = this->encounterSpots->Size();

    for (unsigned int encounterSpotIndex = 0; encounterSpotIndex < encounterSpotCount; encounterSpotIndex++) {
        NavMeshEncounterSpot* encounterSpot = this->encounterSpots->At(encounterSpotIndex);

        encounterSpot->Destroy();
    }

    this->encounterSpots->Destroy();
}

void NavMeshEncounterPath::Destroy()
{
    delete this;
}

unsigned int NavMeshEncounterPath::GetFromAreaID()
{
    return this->fromAreaID;
}

NavDirType NavMeshEncounterPath::GetFromDirection()
{
    return this->fromDirection;
}

unsigned int NavMeshEncounterPath::GetToAreaID()
{
    return this->toAreaID;
}

NavDirType NavMeshEncounterPath::GetToDirection()
{
    return this->toDirection;
}

List<NavMeshEncounterSpot*>* NavMeshEncounterPath::GetEncounterSpots()
{
    return this->encounterSpots;
}
