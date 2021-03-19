#ifndef __Navigation_navmeshcornerlightintensity_h__
#define __Navigation_navmeshcornerlightintensity_h__

#include "NavCornerType.h"
#include "NavMeshCornerLightIntensity.h"

class NavMeshCornerLightIntensity {
public:
    NavMeshCornerLightIntensity(NavCornerType cornerType, float lightIntensity);
    ~NavMeshCornerLightIntensity();

    void Destroy();

    NavCornerType GetCornerType();
    float GetLightIntensity();

private:
    NavCornerType cornerType;
    float lightIntensity;
};

#endif