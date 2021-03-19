#ifndef __Navigation_navmeshvisiblearea_h__
#define __Navigation_navmeshvisiblearea_h__

class NavMeshVisibleArea {
public:
    NavMeshVisibleArea(unsigned int visibleAreaID, unsigned char attributes);
    ~NavMeshVisibleArea();

    void Destroy();

    unsigned int GetVisibleAreaID();
    unsigned char GetAttributes();

private:
    unsigned int visibleAreaID;
    unsigned char attributes;
};

#endif