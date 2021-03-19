#ifndef __Navigation_navmesh_h__
#define __Navigation_navmesh_h__

#include "NavMesh.h"
#include "NavMeshArea.h"
#include "NavMeshLadder.h"
#include "NavMeshPlace.h"

#include "NavGrid.h"

#include "../Struct/HashMap.h"
#include "../Struct/List.h"

class NavMesh {
public:
    NavMesh(unsigned int magicNumber, unsigned int version, unsigned int subVersion, unsigned int saveBSPSize, bool isMeshAnalyzed,
        List<NavMeshPlace*>* places,
        HashMap<unsigned int, NavMeshArea*>* areas,
        HashMap<unsigned int, NavMeshLadder*>* ladders,
        NavGrid* grid);

    ~NavMesh();
    void Destroy();

    unsigned int GetMagicNumber();
    unsigned int GetVersion();
    unsigned int GetSubVersion();
    unsigned int GetSaveBSPSize();
    bool IsMeshAnalyzed();
    List<NavMeshPlace*>* GetPlaces();
    HashMap<unsigned int, NavMeshArea*>* GetAreas();
    NavGrid* GetGrid();
    HashMap<unsigned int, NavMeshLadder*>* GetLadders();

private:
    unsigned int magicNumber;
    unsigned int version;
    unsigned int subVersion;
    unsigned int saveBSPSize;
    bool isMeshAnalyzed;
    List<NavMeshPlace*>* places;
    HashMap<unsigned int, NavMeshLadder*>* ladders;
    HashMap<unsigned int, NavMeshArea*>* areas;
    NavGrid* grid;
};

#endif