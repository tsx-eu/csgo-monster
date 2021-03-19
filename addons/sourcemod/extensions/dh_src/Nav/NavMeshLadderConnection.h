#ifndef __Navigation_navmeshladderconnection_h__
#define __Navigation_navmeshladderconnection_h__

#include "NavLadderDirType.h"
#include "NavMeshLadderConnection.h"

class NavMeshLadderConnection {
public:
    NavMeshLadderConnection(unsigned int connectingLadderID, NavLadderDirType direction);
    ~NavMeshLadderConnection();

    void Destroy();

    unsigned int GetConnectingLadderID();
    NavLadderDirType GetDirection();

private:
    unsigned int connectingLadderID;
    NavLadderDirType direction;
};

#endif