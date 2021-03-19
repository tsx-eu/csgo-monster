#ifndef __Navigation_navmeshencounterspot_h__
#define __Navigation_navmeshencounterspot_h__

#include "NavMeshEncounterSpot.h"

class NavMeshEncounterSpot {
public:
    NavMeshEncounterSpot(unsigned int orderID, float parametricDistance);
    ~NavMeshEncounterSpot();

    void Destroy();

    unsigned int GetOrderID();
    float GetParametricDistance();

private:
    unsigned int orderID;
    float parametricDistance;
};

#endif