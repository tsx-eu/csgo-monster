#include "NavMeshCornerLightIntensity.h"

NavMeshCornerLightIntensity::NavMeshCornerLightIntensity(NavCornerType cornerType, float lightIntensity)
{
    this->cornerType = cornerType;
    this->lightIntensity = lightIntensity;
}

NavMeshCornerLightIntensity::~NavMeshCornerLightIntensity()
{
}

void NavMeshCornerLightIntensity::Destroy()
{
    delete this;
}

NavCornerType NavMeshCornerLightIntensity::GetCornerType()
{
    return this->cornerType;
}

float NavMeshCornerLightIntensity::GetLightIntensity()
{
    return this->lightIntensity;
}
