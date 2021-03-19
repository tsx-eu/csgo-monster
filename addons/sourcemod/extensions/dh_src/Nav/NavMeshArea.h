#ifndef __Navigation_navmesharea_h__
#define __Navigation_navmesharea_h__

#include "NavMeshConnection.h"
#include "NavMeshCornerLightIntensity.h"
#include "NavMeshEncounterPath.h"
#include "NavMeshHidingSpot.h"
#include "NavMeshLadderConnection.h"
#include "NavMeshVisibleArea.h"

#include "../Struct/List.h"

class NavMeshArea {
public:
    NavMeshArea(unsigned int id, unsigned int flags, unsigned int placeID,
        float nwExtentX, float nwExtentY, float nwExtentZ,
        float seExtentX, float seExtentY, float seExtentZ,
        float neCornerZ, float swCornerZ,
        List<NavMeshConnection*>* connections, List<NavMeshHidingSpot*>* hidingSpots, List<NavMeshEncounterPath*>* encounterPaths,
        List<NavMeshLadderConnection*>* ladderConnections, List<NavMeshCornerLightIntensity*>* cornerLightIntensities,
        List<NavMeshVisibleArea*>* visibleAreas, unsigned int inheritVisibilityFromAreaID,
        float earliestOccupyTimeFirstTeam, float earliestOccupyTimeSecondTeam, unsigned char unk01);

    ~NavMeshArea();

    void Destroy();

    unsigned int GetID();
    unsigned int GetFlags();
    unsigned int GetPlaceID();

    float GetNWExtentX();
    float GetNWExtentY();
    float GetNWExtentZ();

    float GetSEExtentX();
    float GetSEExtentY();
    float GetSEExtentZ();

    float GetEarliestOccupyTimeFirstTeam();
    float GetEarliestOccupyTimeSecondTeam();

    float GetNECornerZ();
    float GetSWCornerZ();

    List<NavMeshConnection*>* GetConnections();
    List<NavMeshHidingSpot*>* GetHidingSpots();
    List<NavMeshEncounterPath*>* GetEncounterPaths();
    List<NavMeshLadderConnection*>* GetLadderConnections();
    List<NavMeshCornerLightIntensity*>* GetCornerLightIntensities();
    List<NavMeshVisibleArea*>* GetVisibleAreas();

    unsigned int GetInheritVisibilityFromAreaID();

    unsigned char GetUnk01();
    float fCost();
    float getCostG();
    void setCostG(float);
    float getCostH();
    void setCostH(float);
    NavMeshArea* getParent();
    void setParent(NavMeshArea*);
    void getCenter(float dir[3]);
    float getZ(float dir[3]);

private:
    float gCost;
    float hCost;
    NavMeshArea* parent;

    unsigned int id;
    unsigned int flags;
    unsigned int placeID;

    float nwExtentX;
    float nwExtentY;
    float nwExtentZ;

    float seExtentX;
    float seExtentY;
    float seExtentZ;

    float neCornerZ;
    float swCornerZ;

    List<NavMeshConnection*>* connections;
    List<NavMeshHidingSpot*>* hidingSpots;
    List<NavMeshEncounterPath*>* encounterPaths;
    List<NavMeshLadderConnection*>* ladderConnections;
    List<NavMeshCornerLightIntensity*>* cornerLightIntensities;
    List<NavMeshVisibleArea*>* visibleAreas;

    float earliestOccupyTimeFirstTeam;
    float earliestOccupyTimeSecondTeam;

    unsigned int inheritVisibilityFromAreaID;

    unsigned char unk01;
};

#endif