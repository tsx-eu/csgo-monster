#ifndef _NAVIGATION_H_
#define _NAVIGATION_H_

#include "../Struct/HVector.h"
#include "../Struct/HashMap.h"
#include "../Struct/Heap.h"
#include "NavAttribute.h"
#include "NavDirType.h"
#include "NavMeshLoader.h"

#include <stddef.h>

extern NavMesh* gNavMesh;
inline bool NavMeshAreaGreater(NavMeshArea* a, NavMeshArea* b)
{
    return a->fCost() > b->fCost();
}
inline HVector* AddDirectionVector(HVector* v, NavDirType dir, float amount)
{
    switch (dir) {
    case NAV_DIR_NORTH:
        v->y -= amount;
        break;
    case NAV_DIR_SOUTH:
        v->y += amount;
        break;
    case NAV_DIR_EAST:
        v->x += amount;
        break;
    case NAV_DIR_WEST:
        v->x -= amount;
        break;
    }

    return v;
}
inline NavDirType OppositeDirection(NavDirType dir)
{
    switch (dir) {
    case NAV_DIR_NORTH:
        return NAV_DIR_SOUTH;
    case NAV_DIR_SOUTH:
        return NAV_DIR_NORTH;
    case NAV_DIR_EAST:
        return NAV_DIR_WEST;
    case NAV_DIR_WEST:
        return NAV_DIR_EAST;
    }

    return NAV_DIR_COUNT;
}
NavDirType GetDirectionBetween(NavMeshArea* a, NavMeshArea* b);
bool Load();
unsigned int GetAreaIdFromWorldPosition(float pos[3]);
List<NavMeshArea*>* GetAreaIdFromWorldMinMax(float min[3], float max[3]);
List<NavMeshArea*>* NavAreaBuildPath(unsigned int src, unsigned int dst);
List<NavMeshArea*>* RetracePath(NavMeshArea* start, NavMeshArea* end);
List<HVector*>* SmoothPath(List<NavMeshArea*>* path, float threshold, int maxstep);
bool GetAreaPosition(unsigned int areaID, float dir[]);
NavMeshArea* GetArea(unsigned int areaID);
float getAdjacent(NavMeshArea* a, NavMeshArea* b, float dir[3]);
float GetDistance(NavMeshArea* a, NavMeshArea* b);
float GetPenality(NavMeshArea* a);
float GetSize(NavMeshArea* a);
float Q_rsqrt(float number);

#endif
