#ifndef __Navigation_navmeshconnection_h__
#define __Navigation_navmeshconnection_h__

#include "NavDirType.h"
#include "NavMeshConnection.h"

class NavMeshConnection {
public:
    NavMeshConnection(unsigned int connectingAreaID, NavDirType direction);
    ~NavMeshConnection();

    void Destroy();

    unsigned int GetConnectingAreaID();
    NavDirType GetDirection();

private:
    unsigned int connectingAreaID;
    NavDirType direction;
};

#endif