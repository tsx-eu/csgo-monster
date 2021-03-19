#include "NavMeshLadderConnection.h"

NavMeshLadderConnection::NavMeshLadderConnection(unsigned int connectingLadderID, NavLadderDirType direction)
{
    this->connectingLadderID = connectingLadderID;
    this->direction = direction;
}

NavMeshLadderConnection::~NavMeshLadderConnection()
{
}

void NavMeshLadderConnection::Destroy()
{
    delete this;
}

unsigned int NavMeshLadderConnection::GetConnectingLadderID()
{
    return this->connectingLadderID;
}

NavLadderDirType NavMeshLadderConnection::GetDirection()
{
    return this->direction;
}
