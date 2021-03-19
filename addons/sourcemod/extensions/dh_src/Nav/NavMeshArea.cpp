#include "NavMeshArea.h"

NavMeshArea::NavMeshArea(unsigned int id, unsigned int flags, unsigned int placeID,
    float nwExtentX, float nwExtentY, float nwExtentZ,
    float seExtentX, float seExtentY, float seExtentZ,
    float neCornerZ, float swCornerZ,
    List<NavMeshConnection*>* connections, List<NavMeshHidingSpot*>* hidingSpots, List<NavMeshEncounterPath*>* encounterPaths,
    List<NavMeshLadderConnection*>* ladderConnections, List<NavMeshCornerLightIntensity*>* cornerLightIntensities,
    List<NavMeshVisibleArea*>* visibleAreas, unsigned int inheritVisibilityFromAreaID,
    float earliestOccupyTimeFirstTeam, float earliestOccupyTimeSecondTeam, unsigned char unk01)
{
    this->id = id;
    this->flags = flags;
    this->placeID = placeID;
    this->nwExtentX = nwExtentX;
    this->nwExtentY = nwExtentY;
    this->nwExtentZ = nwExtentZ;
    this->seExtentX = seExtentX;
    this->seExtentY = seExtentY;
    this->seExtentZ = seExtentZ;
    this->neCornerZ = neCornerZ;
    this->swCornerZ = swCornerZ;
    this->connections = connections;
    this->hidingSpots = hidingSpots;
    this->encounterPaths = encounterPaths;
    this->ladderConnections = ladderConnections;
    this->cornerLightIntensities = cornerLightIntensities;
    this->visibleAreas = visibleAreas;
    this->inheritVisibilityFromAreaID = inheritVisibilityFromAreaID;
    this->earliestOccupyTimeFirstTeam = earliestOccupyTimeFirstTeam;
    this->earliestOccupyTimeSecondTeam = earliestOccupyTimeSecondTeam;
    this->unk01 = unk01;
    this->gCost = 0.0;
    this->hCost = 0.0;
}

NavMeshArea::~NavMeshArea()
{
    unsigned int connectionCount = this->connections->Size();

    for (unsigned int connectionIndex = 0; connectionIndex < connectionCount; connectionIndex++) {
        NavMeshConnection* connection = this->connections->At(connectionIndex);

        connection->Destroy();
    }

    this->connections->Destroy();

    unsigned int hidingSpotCount = this->hidingSpots->Size();

    for (unsigned int hidingSpotIndex = 0; hidingSpotIndex < hidingSpotCount; hidingSpotIndex++) {
        NavMeshHidingSpot* hidingSpot = this->hidingSpots->At(hidingSpotIndex);

        hidingSpot->Destroy();
    }

    this->hidingSpots->Destroy();

    unsigned int encounterPathCount = this->encounterPaths->Size();

    for (unsigned int encounterPathIndex = 0; encounterPathIndex < encounterPathCount; encounterPathIndex++) {
        NavMeshEncounterPath* encounterPath = this->encounterPaths->At(encounterPathIndex);

        encounterPath->Destroy();
    }

    this->encounterPaths->Destroy();

    unsigned int ladderConnectionCount = this->ladderConnections->Size();

    for (unsigned int ladderConnectionIndex = 0; ladderConnectionIndex < ladderConnectionCount; ladderConnectionIndex++) {
        NavMeshLadderConnection* ladderConnection = this->ladderConnections->At(ladderConnectionIndex);

        ladderConnection->Destroy();
    }

    this->ladderConnections->Destroy();

    unsigned int cornerLightIntensityCount = this->cornerLightIntensities->Size();

    for (unsigned int cornerLightIntensityIndex = 0; cornerLightIntensityIndex < cornerLightIntensityCount; cornerLightIntensityIndex++) {
        NavMeshCornerLightIntensity* cornerLightIntensity = this->cornerLightIntensities->At(cornerLightIntensityIndex);

        cornerLightIntensity->Destroy();
    }

    this->cornerLightIntensities->Destroy();

    unsigned int visibleAreaCount = this->visibleAreas->Size();

    for (unsigned int visibleAreaIndex = 0; visibleAreaIndex < visibleAreaCount; visibleAreaIndex++) {
        NavMeshVisibleArea* visibleArea = this->visibleAreas->At(visibleAreaIndex);

        visibleArea->Destroy();
    }

    this->visibleAreas->Destroy();
}

void NavMeshArea::Destroy()
{
    delete this;
}

unsigned int NavMeshArea::GetID()
{
    return this->id;
}

unsigned int NavMeshArea::GetFlags()
{
    return this->flags;
}

unsigned int NavMeshArea::GetPlaceID()
{
    return this->placeID;
}

float NavMeshArea::GetNWExtentX()
{
    return this->nwExtentX;
}

float NavMeshArea::GetNWExtentY()
{
    return this->nwExtentY;
}

float NavMeshArea::GetNWExtentZ()
{
    return this->nwExtentZ;
}

float NavMeshArea::GetSEExtentX()
{
    return this->seExtentX;
}

float NavMeshArea::GetSEExtentY()
{
    return this->seExtentY;
}

float NavMeshArea::GetSEExtentZ()
{
    return this->seExtentZ;
}

float NavMeshArea::GetEarliestOccupyTimeFirstTeam()
{
    return this->earliestOccupyTimeFirstTeam;
}

float NavMeshArea::GetEarliestOccupyTimeSecondTeam()
{
    return this->earliestOccupyTimeSecondTeam;
}

float NavMeshArea::GetNECornerZ()
{
    return this->neCornerZ;
}

float NavMeshArea::GetSWCornerZ()
{
    return this->swCornerZ;
}

List<NavMeshConnection*>* NavMeshArea::GetConnections()
{
    return this->connections;
}

List<NavMeshHidingSpot*>* NavMeshArea::GetHidingSpots()
{
    return this->hidingSpots;
}

List<NavMeshEncounterPath*>* NavMeshArea::GetEncounterPaths()
{
    return this->encounterPaths;
}

List<NavMeshLadderConnection*>* NavMeshArea::GetLadderConnections()
{
    return this->ladderConnections;
}

List<NavMeshCornerLightIntensity*>* NavMeshArea::GetCornerLightIntensities()
{
    return this->cornerLightIntensities;
}

List<NavMeshVisibleArea*>* NavMeshArea::GetVisibleAreas()
{
    return this->visibleAreas;
}

unsigned int NavMeshArea::GetInheritVisibilityFromAreaID()
{
    return this->inheritVisibilityFromAreaID;
}

unsigned char NavMeshArea::GetUnk01()
{
    return this->unk01;
}
float NavMeshArea::fCost()
{
    return gCost + hCost;
}
float NavMeshArea::getCostG()
{
    return gCost;
}
void NavMeshArea::setCostG(float cost)
{
    this->gCost = cost;
}
void NavMeshArea::setCostH(float cost)
{
    this->hCost = cost;
}
float NavMeshArea::getCostH()
{
    return hCost;
}
NavMeshArea* NavMeshArea::getParent()
{
    return this->parent;
}
void NavMeshArea::setParent(NavMeshArea* parent)
{
    this->parent = parent;
}
void NavMeshArea::getCenter(float dir[3])
{
    dir[0] = ((this->GetNWExtentX() + this->GetSEExtentX()) / 2.0);
    dir[1] = ((this->GetNWExtentY() + this->GetSEExtentY()) / 2.0);
    dir[2] = ((this->GetNWExtentZ() + this->GetSEExtentZ()) / 2.0);
}
float NavMeshArea::getZ(float dir[3])
{
    float dx = seExtentX - nwExtentX;
    float dy = seExtentY - nwExtentY;

    // guard against division by zero due to degenerate areas
    if (dx == 0.0f || dy == 0.0f) {
        return neCornerZ;
    }

    float u = (dir[0] - nwExtentX) / dx;
    float v = (dir[1] - nwExtentY) / dy;

    // clamp Z values to (x,y) volume
    if (u < 0.0f)
        u = 0.0f;
    else if (u > 1.0f)
        u = 1.0f;

    if (v < 0.0f)
        v = 0.0f;
    else if (v > 1.0f)
        v = 1.0f;

    float northZ = nwExtentZ + u * (neCornerZ - nwExtentZ);
    float southZ = swCornerZ + u * (seExtentZ - swCornerZ);

    return northZ + v * (southZ - northZ);
}
