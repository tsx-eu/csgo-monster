#include "Navigation.h"

NavMesh* gNavMesh = NULL;

bool Load()
{
    const char* mapname = gamehelpers->GetCurrentMap();
    const char* gamepath = g_pSM->GetGamePath();
    const char* game = g_pSM->GetGameFolderName();

    printf("Loading... %s %s %s\n\n", mapname, gamepath, game);

    if (gNavMesh) { // Already loaded? Maybe a new map?
        delete gNavMesh;
        gNavMesh = NULL;
    }
    std::string absolutePath = gamepath;
    absolutePath += "/maps/";
    absolutePath += mapname;
    absolutePath += ".nav";

    printf("Loading file..\n");

    NavMeshLoader* nav = new NavMeshLoader(mapname);
    printf("Loaded.\n");
    char error[1024];
    gNavMesh = nav->Load(error, sizeof(error));
    printf("Analyzed\n");

    if (gNavMesh == NULL)
        return false;

    return true;
}
NavDirType GetDirectionBetween(NavMeshArea* a, NavMeshArea* b)
{
    List<NavMeshConnection*>* list = a->GetConnections();
    for (int i = 0; i < list->Size(); i++) {
        NavMeshConnection* toto = list->At(i);
        if (toto->GetConnectingAreaID() == b->GetID())
            return toto->GetDirection();
    }

    printf("dir not found between %d and %d, trying to guess.\n", a->GetID(), b->GetID());
    float src[3], dst[3];
    a->getCenter(src);
    b->getCenter(dst);
    dst[0] -= src[0];
    dst[1] -= src[1];

    float angle = atan2(dst[1], dst[0]);

    while (angle < 0.0f)
        angle += 2 * M_PI;

    while (angle > 2 * M_PI)
        angle -= 2 * M_PI;

    if (angle < M_PI / 4 || angle > (7 * M_PI) / 4)
        return NAV_DIR_EAST;

    if (angle >= M_PI / 4 && angle < (3 * M_PI) / 4)
        return NAV_DIR_SOUTH;

    if (angle >= (3 * M_PI) / 4 && angle < (5 * M_PI) / 4)
        return NAV_DIR_WEST;

    return NAV_DIR_NORTH;
}
List<NavMeshArea*>* NavAreaBuildPath(unsigned int src, unsigned int dst)
{
    NavMeshArea* current;
    NavMeshArea* source = gNavMesh->GetAreas()->Get(src);
    NavMeshArea* destination = gNavMesh->GetAreas()->Get(dst);

    QueueMap<NavMeshArea*>* openSet = new QueueMap<NavMeshArea*>(NavMeshAreaGreater);
    HashMap<unsigned int, NavMeshArea*>* closedSet = new HashMap<unsigned int, NavMeshArea*>();
    List<NavMeshConnection*>* neightbours;
    List<NavMeshLadderConnection*>* ladders;

    openSet->Push(source);

    while (openSet->Empty() == false) {
        current = openSet->Pop();
        closedSet->Add(current->GetID(), current);

        if (current == destination) {
            delete openSet, closedSet;
            return RetracePath(source, destination);
        }

        neightbours = current->GetConnections();
        for (unsigned int i = 0; i < neightbours->Size(); i++) {
            unsigned int areaID = neightbours->At(i)->GetConnectingAreaID();
            NavMeshArea* neightbour = gNavMesh->GetAreas()->Get(areaID);
            if (closedSet->Get(areaID))
                continue;

            float cost = current->getCostG() + GetDistance(current, neightbour) * GetPenality(neightbour);
            if (cost < neightbour->getCostG() || !openSet->Has(neightbour)) {
                neightbour->setCostG(cost);
                neightbour->setCostH(GetDistance(neightbour, destination));
                neightbour->setParent(current);

                if (!openSet->Has(neightbour))
                    openSet->Push(neightbour);
                else
                    openSet->Update(neightbour);
            }
        }

        ladders = current->GetLadderConnections();
        for (unsigned int i = 0; i < ladders->Size(); i++) {
            unsigned int ladderID = ladders->At(i)->GetConnectingLadderID();
            NavMeshLadder* ladder = gNavMesh->GetLadders()->Get(ladderID);
            List<unsigned int>* areas = new List<unsigned int>();

            switch (ladders->At(i)->GetDirection()) {
            case NAV_LADDER_DIR_UP: {
                if (ladder->GetTopBehindAreaID() > 0)
                    areas->Append(ladder->GetTopBehindAreaID());
                if (ladder->GetTopForwardAreaID() > 0)
                    areas->Append(ladder->GetTopForwardAreaID());
                if (ladder->GetTopRightAreaID() > 0)
                    areas->Append(ladder->GetTopRightAreaID());
                if (ladder->GetTopLeftAreaID() > 0)
                    areas->Append(ladder->GetTopLeftAreaID());

                break;
            }
            case NAV_LADDER_DIR_DOWN: {
                if (ladder->GetBottomAreaID())
                    areas->Append(ladder->GetBottomAreaID());
                break;
            }
            }

            for (unsigned int j = 0; j < areas->Size(); j++) {
                unsigned int areaID = areas->At(j);
                if (closedSet->Get(areaID))
                    continue;

                NavMeshArea* neightbour = gNavMesh->GetAreas()->Get(areaID);
                float cost = current->getCostG() + GetDistance(current, neightbour) * GetPenality(neightbour);
                if (cost < neightbour->getCostG() || !openSet->Has(neightbour)) {
                    neightbour->setCostG(cost);
                    neightbour->setCostH(GetDistance(neightbour, destination));
                    neightbour->setParent(current);

                    if (!openSet->Has(neightbour))
                        openSet->Push(neightbour);
                    else
                        openSet->Update(neightbour);
                }
            }
            delete areas;
        }
    }

    delete openSet, closedSet;
    return NULL;
}

List<NavMeshArea*>* RetracePath(NavMeshArea* start, NavMeshArea* end)
{
    List<NavMeshArea*>* link = new List<NavMeshArea*>();
    NavMeshArea* current = end;

    while (current != start) {
        link->Prepend(current);
        current = current->getParent();
    }
    link->Prepend(start);

    return link;
}
List<HVector*>* SmoothPath(List<NavMeshArea*>* path, float threshold, int maxstep)
{
    if (path == NULL)
        return NULL;

    float dir[3], ladder;

    List<HVector*>* smooth = new List<HVector*>();

    int size = path->Size();
    if (maxstep > 0 && size > maxstep)
        size = maxstep;

    for (unsigned int i = 1; i < size; i++) {
        NavMeshArea* src = path->At(i - 1);
        NavMeshArea* dst = path->At(i);

        ladder = getAdjacent(src, dst, dir);
        HVector* node1 = new HVector(dir[0], dir[1], dir[2]);
        HVector* node2 = new HVector(dir[0], dir[1], dir[2]);

        if (ladder != 0.0) {
            node2->y += ladder;
        } else {
            NavDirType direction = GetDirectionBetween(src, dst);
            AddDirectionVector(node1, direction, -threshold);
            AddDirectionVector(node2, direction, threshold);
        }
        smooth->Append(node1);
        smooth->Append(node2);
    }

    if (path->Size() <= size) {
        path->At(path->Size() - 1)->getCenter(dir);
        smooth->Append(new HVector(dir[0], dir[1], dir[2]));
    }

    return smooth;
}
float getAdjacent(NavMeshArea* a, NavMeshArea* b, float dir[3])
{
    static float min[3][2], max[3][2];
    static const int CURR = 0, NEXT = 1, TARG = 2;
    min[CURR][0] = a->GetNWExtentX();
    min[CURR][1] = a->GetNWExtentY();
    max[CURR][0] = a->GetSEExtentX();
    max[CURR][1] = a->GetSEExtentY();

    min[NEXT][0] = b->GetNWExtentX();
    min[NEXT][1] = b->GetNWExtentY();
    max[NEXT][0] = b->GetSEExtentX();
    max[NEXT][1] = b->GetSEExtentY();

    for (int j = 0; j <= 1; j++) {
        min[TARG][j] = min[CURR][j] >= min[NEXT][j] ? min[CURR][j] : min[NEXT][j];
        max[TARG][j] = max[CURR][j] <= max[NEXT][j] ? max[CURR][j] : max[NEXT][j];
        dir[j] = (min[TARG][j] + max[TARG][j]) / 2.0;
    }
    dir[2] = b->getZ(dir);
    float tmp = a->getZ(dir);

    if (tmp - dir[2] > 64.0)
        return (tmp - dir[2]);
    else if (dir[2] - tmp > 64.0)
        return -(dir[2] - tmp);

    return 0.0;
}
float GetPenality(NavMeshArea* a)
{
    float penality = 1.0;
    float sqs = Q_rsqrt(GetSize(a));

    if (a->GetFlags() & (NAV_MESH_CROUCH | NAV_MESH_JUMP))
        penality *= 2.0;
    if (a->GetFlags() & (NAV_MESH_AVOID))
        penality *= 2.0;

    if (sqs >= 0.01) {
        penality *= 1.125;
        if (sqs >= 0.1)
            penality *= 1.125;
    }

    return penality;
}
float Q_rsqrt(float number)
{
    long i;
    float x2, y;
    const float threehalfs = 1.5F;

    x2 = number * 0.5F;
    y = number;
    i = *(long*)&y; // evil floating point bit level hacking
    i = 0x5f3759df - (i >> 1); // what the fuck?
    y = *(float*)&i;
    y = y * (threehalfs - (x2 * y * y)); // 1st iteration
    //	y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

    return y;
}
float GetSize(NavMeshArea* a)
{
    return (a->GetSEExtentX() - a->GetNWExtentX()) * (a->GetSEExtentY() - a->GetNWExtentY());
}
float GetDistance(NavMeshArea* a, NavMeshArea* b)
{
    float dir[3];
    dir[0] = ((a->GetNWExtentX() + a->GetSEExtentX()) / 2.0) - ((b->GetNWExtentX() + b->GetSEExtentX()) / 2.0);
    dir[1] = ((a->GetNWExtentY() + a->GetSEExtentY()) / 2.0) - ((b->GetNWExtentY() + b->GetSEExtentY()) / 2.0);
    dir[2] = ((a->GetNWExtentZ() + a->GetSEExtentZ()) / 2.0) - ((b->GetNWExtentZ() + b->GetSEExtentZ()) / 2.0);
    return sqrt(dir[0] * dir[0] + dir[1] * dir[1] + dir[2] * dir[2]);
}
bool GetAreaPosition(unsigned int areaID, float dir[])
{
    NavMeshArea* a = gNavMesh->GetAreas()->Get(areaID);

    dir[0] = ((a->GetNWExtentX() + a->GetSEExtentX()) / 2.0);
    dir[1] = ((a->GetNWExtentY() + a->GetSEExtentY()) / 2.0);
    dir[2] = ((a->GetNWExtentZ() + a->GetSEExtentZ()) / 2.0);

    return true;
}
NavMeshArea* GetArea(unsigned int areaID)
{
    return gNavMesh->GetAreas()->Get(areaID);
}
unsigned int GetAreaIdFromWorldPosition(float position[3])
{
    NavMeshArea* a = gNavMesh->GetGrid()->Pop(position, 8.0);
    if (a != NULL)
        return a->GetID();
    return 0;
}

List<NavMeshArea*>* GetAreaIdFromWorldMinMax(float min[3], float max[3])
{
    return gNavMesh->GetGrid()->Pop(min, max);
}
