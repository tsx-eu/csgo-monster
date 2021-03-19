#include "NavMesh.h"

NavMesh::NavMesh(unsigned int magicNumber, unsigned int version, unsigned int subVersion, unsigned int saveBSPSize, bool isMeshAnalyzed,
    List<NavMeshPlace*>* places,
    HashMap<unsigned int, NavMeshArea*>* areas,
    HashMap<unsigned int, NavMeshLadder*>* ladders,
    NavGrid* grid)
{
    this->magicNumber = magicNumber;
    this->version = version;
    this->subVersion = subVersion;
    this->saveBSPSize = saveBSPSize;
    this->isMeshAnalyzed = isMeshAnalyzed;
    this->places = places;
    this->ladders = ladders;
    this->areas = areas;
    this->grid = grid;
}
NavGrid* NavMesh::GetGrid()
{
    return this->grid;
}
NavMesh::~NavMesh()
{
    unsigned int placeCount = this->places->Size();

    for (unsigned int placeIndex = 0; placeIndex < placeCount; placeIndex++) {
        NavMeshPlace* place = this->places->At(placeIndex);

        place->Destroy();
    }

    this->places->Destroy();
    this->areas->Destroy();
    this->ladders->Destroy();
}

void NavMesh::Destroy()
{
    delete this;
}

unsigned int NavMesh::GetMagicNumber()
{
    return this->magicNumber;
}

unsigned int NavMesh::GetVersion()
{
    return this->version;
}

unsigned int NavMesh::GetSubVersion()
{
    return this->subVersion;
}

unsigned int NavMesh::GetSaveBSPSize()
{
    return this->saveBSPSize;
}

bool NavMesh::IsMeshAnalyzed()
{
    return this->isMeshAnalyzed;
}

List<NavMeshPlace*>* NavMesh::GetPlaces()
{
    return this->places;
}

HashMap<unsigned int, NavMeshArea*>* NavMesh::GetAreas()
{
    return this->areas;
}

HashMap<unsigned int, NavMeshLadder*>* NavMesh::GetLadders()
{
    return this->ladders;
}
