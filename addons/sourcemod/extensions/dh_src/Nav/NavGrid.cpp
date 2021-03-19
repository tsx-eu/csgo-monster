#include "NavGrid.h"

NavGrid::NavGrid(float min[2], float max[2], float cellSize)
{
    this->cellSize = cellSize;
    this->min[0] = min[0];
    this->min[1] = min[1];
    this->max[0] = max[0];
    this->max[1] = max[1];

    this->gridSize[0] = (unsigned int)((max[0] - min[0]) / cellSize) + 1;
    this->gridSize[1] = (unsigned int)((max[1] - min[1]) / cellSize) + 1;
    this->items = new std::vector<List<NavMeshArea*>*>(this->gridSize[0] * this->gridSize[1]);
    for (unsigned int i = 0; i < this->gridSize[0] * this->gridSize[1]; i++)
        this->items->at(i) = new List<NavMeshArea*>();
}

void NavGrid::Push(NavMeshArea* area)
{
    unsigned int loX = WorldToGrid(area->GetNWExtentX(), 0);
    unsigned int loY = WorldToGrid(area->GetNWExtentY(), 1);
    unsigned int hiX = WorldToGrid(area->GetSEExtentX(), 0);
    unsigned int hiY = WorldToGrid(area->GetSEExtentY(), 1);

    for (unsigned int x = loX; x <= hiX; x++) {
        for (unsigned int y = loY; y <= hiY; y++) {
            this->items->at(x + y * this->gridSize[0])->Append(area);
        }
    }
}
NavMeshArea* NavGrid::Pop(float position[3], float tollerence)
{
    unsigned int X = WorldToGrid(position[0], 0);
    unsigned int Y = WorldToGrid(position[1], 1);

    float nearZ = -999999.9;
    float tmp;
    NavMeshArea* best = NULL;

    List<NavMeshArea*>* areas = this->items->at(X + Y * this->gridSize[0]);

    // 1 Celui qu'on est dedans.
    for (unsigned int i = 0; i < areas->Size(); i++) {
        if (NavMeshAreaInside(areas->At(i), position, tollerence)) {
            float z = areas->At(i)->getZ(position);
            if (z > (position[2] + tollerence))
                continue;
            if (z < (position[2] - 120.0))
                continue;

            if (z > nearZ) {
                nearZ = z;
                best = areas->At(i);
            }
        }
    }
    // Le plus proche
    if (best == NULL) {
        nearZ = 999999999.9;
        for (unsigned int i = 0; i < areas->Size(); i++) {
            float z = areas->At(i)->getZ(position);

            if (z > (position[2] + tollerence))
                continue;

            tmp = GetDistance(position, areas->At(i));
            if (tmp < nearZ) {
                nearZ = tmp;
                best = areas->At(i);
            }
        }

        if (best == NULL) {
            nearZ = 999999999.9;
            for (unsigned int i = 0; i < areas->Size(); i++) {
                float z = areas->At(i)->getZ(position);

                if (z < (position[2] - 120.0))
                    continue;

                tmp = GetDistance(position, areas->At(i));
                if (tmp < nearZ) {
                    nearZ = tmp;
                    best = areas->At(i);
                }
            }
        }
    }

    return best;
}
List<NavMeshArea*>* NavGrid::Pop(float min[3], float max[3])
{
    unsigned int fromX = WorldToGrid(min[0], 0);
    unsigned int fromY = WorldToGrid(min[1], 1);
    unsigned int toX = WorldToGrid(max[0], 0);
    unsigned int toY = WorldToGrid(max[1], 1);

    List<NavMeshArea*>* result = new List<NavMeshArea*>();

    for (unsigned X = fromX; X < toX; X++) {
        for (unsigned Y = fromY; Y < toY; Y++) {
            List<NavMeshArea*>* areas = this->items->at(X + Y * this->gridSize[0]);
            for (unsigned int i = 0; i < areas->Size(); i++) {
                NavMeshArea* area = areas->At(i);
                if (area->GetNWExtentX() >= min[0] && area->GetNWExtentY() >= min[1] && area->GetNWExtentZ() >= min[2])
                    if (area->GetSEExtentX() <= max[0] && area->GetSEExtentY() <= max[1] && area->GetSEExtentZ() <= max[2])
                        result->Append(area);
            }
        }
    }

    return result;
}

float NavGrid::GetDistance(float pos[3], NavMeshArea* a)
{
    float dir[3];

    dir[0] = pos[0] - ((a->GetNWExtentX() + a->GetSEExtentX()) / 2.0);
    dir[1] = pos[1] - ((a->GetNWExtentY() + a->GetSEExtentY()) / 2.0);
    dir[2] = pos[2] - ((a->GetNWExtentZ() + a->GetSEExtentZ()) / 2.0);

    return (dir[0] * dir[0] + dir[1] * dir[1] + dir[2] * dir[2]);
}

unsigned int NavGrid::WorldToGrid(float p, int xy)
{
    int x = (unsigned int)((p - this->min[xy]) / this->cellSize);
    if (x < 0)
        x = 0;
    else if (x >= gridSize[xy])
        x = gridSize[xy] - 1;
    return x;
}
bool NavGrid::NavMeshAreaInside(NavMeshArea* a, float point[3], float tollerence)
{
    return (
        point[0] + tollerence >= a->GetNWExtentX() && point[1] + tollerence >= a->GetNWExtentY() && point[0] - tollerence <= a->GetSEExtentX() && point[1] - tollerence <= a->GetSEExtentY());
}
bool NavGrid::Finalize()
{
    return true;
}
