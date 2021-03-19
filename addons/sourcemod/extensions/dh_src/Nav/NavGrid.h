#ifndef __Navigation_hnavgrid_h__
#define __Navigation_hnavgrid_h__

#include <vector>

#include <unistd.h>

#include "../Struct/List.h"
#include "NavGrid.h"
#include "NavMeshArea.h"

class NavGrid {

public:
    NavGrid(float min[2], float max[2], float cellSize);

    void Push(NavMeshArea* area);
    NavMeshArea* Pop(float position[3], float tollerence);
    List<NavMeshArea*>* Pop(float min[3], float max[3]);
    float GetDistance(float pos[3], NavMeshArea* a);
    unsigned int WorldToGrid(float p, int xy);
    bool NavMeshAreaInside(NavMeshArea* a, float point[3], float tollerence);
    bool Finalize();

private:
    float cellSize;
    float min[2], max[2];
    unsigned int gridSize[2];
    std::vector<List<NavMeshArea*>*>* items;
};

#endif