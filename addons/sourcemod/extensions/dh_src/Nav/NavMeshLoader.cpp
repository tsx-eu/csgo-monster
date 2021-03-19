#include "NavMeshLoader.h"

NavMeshLoader::NavMeshLoader(const char* mapName)
{
    strcpy(this->mapName, mapName);
    this->bytesRead = 0;
}

NavMeshLoader::~NavMeshLoader()
{
}

void NavMeshLoader::Destroy()
{
    delete this;
}

NavMesh* NavMeshLoader::Load(char* error, int errorMaxlen)
{
    strcpy(error, "");

    char navPath[1024];
    g_pSM->BuildPath(Path_Game, navPath, sizeof(navPath), "maps\\%s.nav", this->mapName);

    FILE* fileHandle = fopen(navPath, "rb");

    if (!fileHandle) {
        sprintf(error, "Unable to find navigation mesh: %s", navPath);
        return NULL;
    }

    unsigned int magicNumber;
    int elementsRead = this->ReadData(&magicNumber, sizeof(unsigned int), 1, fileHandle);

    if (elementsRead != 1) {
        fclose(fileHandle);
        sprintf(error, "Error reading magic number value from navigation mesh: %s", navPath);
        return NULL;
    }

    if (magicNumber != 0xFEEDFACE) {
        fclose(fileHandle);
        sprintf(error, "Invalid magic number value from navigation mesh: %s [%p]", navPath, reinterpret_cast<void*>(magicNumber));
        return NULL;
    }

    unsigned int version;
    elementsRead = this->ReadData(&version, sizeof(unsigned int), 1, fileHandle);

    if (elementsRead != 1) {
        fclose(fileHandle);
        sprintf(error, "Error reading version number from navigation mesh: %s", navPath);
        return NULL;
    }

    if (version < 6 || version > 16) {
        fclose(fileHandle);
        sprintf(error, "Invalid version number value from navigation mesh: %s [%d]", navPath, version);
        return NULL;
    }

    unsigned int navMeshSubVersion = 0;

    if (version >= 10) {
        this->ReadData(&navMeshSubVersion, sizeof(unsigned int), 1, fileHandle);
    }

    unsigned int saveBspSize;
    this->ReadData(&saveBspSize, sizeof(unsigned int), 1, fileHandle);

    char bspPath[1024];
    g_pSM->BuildPath(Path_Game, bspPath, sizeof(bspPath), "maps\\%s.bsp", this->mapName);

    unsigned int actualBspSize = 0;

#ifdef PLATFORM_WINDOWS
    struct _stat s;
    _stat(bspPath, &s);
    actualBspSize = s.st_size;
#elif defined PLATFORM_POSIX
    struct stat s;
    stat(bspPath, &s);
    actualBspSize = s.st_size;
#endif

    unsigned char meshAnalyzed = 0;

    if (version >= 14) {
        this->ReadData(&meshAnalyzed, sizeof(unsigned char), 1, fileHandle);
    }

    bool isMeshAnalyzed = meshAnalyzed != 0;

    printf("Is mesh analyzed: %s\n", isMeshAnalyzed ? "yes" : "no");

    unsigned short placeCount;
    this->ReadData(&placeCount, sizeof(unsigned short), 1, fileHandle);

    printf("Nav version: %d; BSPSize: %d; MagicNumber: %d; SubVersion: %d [v10+only]; Place Count: %d\n", version, saveBspSize, magicNumber, navMeshSubVersion, placeCount);

    List<NavMeshPlace*>* places = new List<NavMeshPlace*>();

    for (unsigned int placeIndex = 0; placeIndex < placeCount; placeIndex++) {
        unsigned short placeSize;

        this->ReadData(&placeSize, sizeof(unsigned short), 1, fileHandle);

        char placeName[256];
        this->ReadData(placeName, sizeof(unsigned char), placeSize, fileHandle);

        places->Append(new NavMeshPlace(placeIndex + 1, placeName));
    }

    unsigned char unnamedAreas = 0;
    if (version > 11) {
        this->ReadData(&unnamedAreas, sizeof(unsigned char), 1, fileHandle);
    }

    bool hasUnnamedAreas = unnamedAreas != 0;

    printf("Has unnamed areas: %s\n", hasUnnamedAreas ? "yes" : "no");

    //		List<NavMeshArea*> *areas = new List<NavMeshArea*>();
    HashMap<unsigned int, NavMeshArea*>* areas = new HashMap<unsigned int, NavMeshArea*>();
    HashMap<unsigned int, NavMeshLadder*>* ladders = new HashMap<unsigned int, NavMeshLadder*>();
    float min[2], max[2];
    min[0] = min[1] = 999999.9;
    max[0] = max[1] = -999999.9;

    unsigned int areaCount;
    this->ReadData(&areaCount, sizeof(unsigned int), 1, fileHandle);

    printf("Area count: %d\n", areaCount);

    for (unsigned int areaIndex = 0; areaIndex < areaCount; areaIndex++) {
        unsigned int areaID;
        float x1, y1, z1, x2, y2, z2;
        unsigned int areaFlags = 0;
        List<NavMeshConnection*>* connections = new List<NavMeshConnection*>();
        List<NavMeshHidingSpot*>* hidingSpots = new List<NavMeshHidingSpot*>();
        List<NavMeshEncounterPath*>* encounterPaths = new List<NavMeshEncounterPath*>();
        List<NavMeshLadderConnection*>* ladderConnections = new List<NavMeshLadderConnection*>();
        List<NavMeshCornerLightIntensity*>* cornerLightIntensities = new List<NavMeshCornerLightIntensity*>();
        List<NavMeshVisibleArea*>* visibleAreas = new List<NavMeshVisibleArea*>();
        unsigned int inheritVisibilityFrom = 0;
        unsigned char hidingSpotCount = 0;
        unsigned int visibleAreaCount = 0;
        float earliestOccupyTimeFirstTeam = 0.0f;
        float earliestOccupyTimeSecondTeam = 0.0f;
        float northEastCornerZ;
        float southWestCornerZ;
        unsigned short placeID = 0;
        unsigned int unk01 = 0;

        this->ReadData(&areaID, sizeof(unsigned int), 1, fileHandle);

        if (version <= 8) {
            this->ReadData(&areaFlags, sizeof(unsigned char), 1, fileHandle);
        } else if (version < 13) {
            this->ReadData(&areaFlags, sizeof(unsigned short), 1, fileHandle);
        } else {
            this->ReadData(&areaFlags, sizeof(unsigned int), 1, fileHandle);
        }

        //printf("Area Flags: %d\n", areaFlags);
        this->ReadData(&x1, sizeof(float), 1, fileHandle);
        this->ReadData(&y1, sizeof(float), 1, fileHandle);
        this->ReadData(&z1, sizeof(float), 1, fileHandle);
        this->ReadData(&x2, sizeof(float), 1, fileHandle);
        this->ReadData(&y2, sizeof(float), 1, fileHandle);
        this->ReadData(&z2, sizeof(float), 1, fileHandle);
        //printf("Area extent: (%f, %f, %f), (%f, %f, %f)\n", x1, y1, z1, x2, y2, z2);

        this->ReadData(&northEastCornerZ, sizeof(float), 1, fileHandle);
        this->ReadData(&southWestCornerZ, sizeof(float), 1, fileHandle);

        //printf("Corners: NW(%f), SW(%f)\n", northEastCornerZ, southWestCornerZ);

        // CheckWaterLevel() are we underwater in this area?

        for (unsigned int direction = 0; direction < NAV_DIR_COUNT; direction++) {
            unsigned int connectionCount;
            this->ReadData(&connectionCount, sizeof(unsigned int), 1, fileHandle);

            for (unsigned int connectionIndex = 0; connectionIndex < connectionCount; connectionIndex++) {
                unsigned int connectingAreaID;
                this->ReadData(&connectingAreaID, sizeof(unsigned int), 1, fileHandle);

                NavMeshConnection* connection = new NavMeshConnection(connectingAreaID, (NavDirType)direction);
                connections->Append(connection);
            }
        }

        this->ReadData(&hidingSpotCount, sizeof(unsigned char), 1, fileHandle);
        //printf("Hiding Spot Count: %d\n", hidingSpotCount);

        for (unsigned int hidingSpotIndex = 0; hidingSpotIndex < hidingSpotCount; hidingSpotIndex++) {
            unsigned int hidingSpotID;
            this->ReadData(&hidingSpotID, sizeof(unsigned int), 1, fileHandle);

            float hidingSpotX, hidingSpotY, hidingSpotZ;
            this->ReadData(&hidingSpotX, sizeof(float), 1, fileHandle);
            this->ReadData(&hidingSpotY, sizeof(float), 1, fileHandle);
            this->ReadData(&hidingSpotZ, sizeof(float), 1, fileHandle);

            unsigned char hidingSpotFlags;
            this->ReadData(&hidingSpotFlags, sizeof(unsigned char), 1, fileHandle);

            NavMeshHidingSpot* hidingSpot = new NavMeshHidingSpot(hidingSpotID, hidingSpotX, hidingSpotY, hidingSpotZ, hidingSpotFlags);
            hidingSpots->Append(hidingSpot);
            //printf("Parsed hiding spot (%f, %f, %f) with ID [%p] and flags [%p]\n", hidingSpotX, hidingSpotY, hidingSpotZ, hidingSpotID, hidingSpotFlags);
        }

        // These are old but we just need to read the data.
        if (version < 15) {
            unsigned char approachAreaCount;
            this->ReadData(&approachAreaCount, sizeof(unsigned char), 1, fileHandle);

            for (unsigned int approachAreaIndex = 0; approachAreaIndex < approachAreaCount; approachAreaIndex++) {
                unsigned int approachHereID;
                this->ReadData(&approachHereID, sizeof(unsigned int), 1, fileHandle);

                unsigned int approachPrevID;
                this->ReadData(&approachPrevID, sizeof(unsigned int), 1, fileHandle);

                unsigned char approachType;
                this->ReadData(&approachType, sizeof(unsigned char), 1, fileHandle);

                unsigned int approachNextID;
                this->ReadData(&approachNextID, sizeof(unsigned int), 1, fileHandle);

                unsigned char approachHow;
                this->ReadData(&approachHow, sizeof(unsigned char), 1, fileHandle);
            }
        }

        unsigned int encounterPathCount;
        this->ReadData(&encounterPathCount, sizeof(unsigned int), 1, fileHandle);
        //printf("Encounter Path Count: %d\n", encounterPathCount);

        for (unsigned int encounterPathIndex = 0; encounterPathIndex < encounterPathCount; encounterPathIndex++) {
            unsigned int encounterFromID;
            this->ReadData(&encounterFromID, sizeof(unsigned int), 1, fileHandle);

            unsigned char encounterFromDirection;
            this->ReadData(&encounterFromDirection, sizeof(unsigned char), 1, fileHandle);

            unsigned int encounterToID;
            this->ReadData(&encounterToID, sizeof(unsigned int), 1, fileHandle);

            unsigned char encounterToDirection;
            this->ReadData(&encounterToDirection, sizeof(unsigned char), 1, fileHandle);

            unsigned char encounterSpotCount;
            this->ReadData(&encounterSpotCount, sizeof(unsigned char), 1, fileHandle);

            //printf("Encounter [from ID %d] [from dir %p] [to ID %d] [to dir %p] [spot count %d]\n", encounterFromID, encounterFromDirection, encounterToID, encounterToDirection, encounterSpotCount);
            List<NavMeshEncounterSpot*>* encounterSpots = new List<NavMeshEncounterSpot*>();

            for (int encounterSpotIndex = 0; encounterSpotIndex < encounterSpotCount; encounterSpotIndex++) {
                unsigned int encounterSpotOrderId;
                this->ReadData(&encounterSpotOrderId, sizeof(unsigned int), 1, fileHandle);

                unsigned char encounterSpotT;
                this->ReadData(&encounterSpotT, sizeof(unsigned char), 1, fileHandle);

                float encounterSpotParametricDistance = (float)encounterSpotT / 255.0f;

                NavMeshEncounterSpot* encounterSpot = new NavMeshEncounterSpot(encounterSpotOrderId, encounterSpotParametricDistance);
                encounterSpots->Append(encounterSpot);
                //printf("Encounter spot [order id %d] and [T %p]\n", encounterSpotOrderId, encounterSpotT);
            }

            NavMeshEncounterPath* encounterPath = new NavMeshEncounterPath(
                encounterFromID, (NavDirType)encounterFromDirection,
                encounterToID, (NavDirType)encounterToDirection,
                encounterSpots);
            encounterPaths->Append(encounterPath);
        }

        this->ReadData(&placeID, sizeof(unsigned short), 1, fileHandle);

        //printf("Place ID: %d\n", placeID);

        for (unsigned int ladderDirection = 0; ladderDirection < NAV_LADDER_DIR_COUNT; ladderDirection++) {
            unsigned int ladderConnectionCount;
            this->ReadData(&ladderConnectionCount, sizeof(unsigned int), 1, fileHandle);

            //printf("Ladder Connection Count: %d\n", ladderConnectionCount);

            for (unsigned int ladderConnectionIndex = 0; ladderConnectionIndex < ladderConnectionCount; ladderConnectionIndex++) {
                unsigned int ladderConnectID;
                this->ReadData(&ladderConnectID, sizeof(unsigned int), 1, fileHandle);

                NavMeshLadderConnection* ladderConnection = new NavMeshLadderConnection(ladderConnectID, (NavLadderDirType)ladderDirection);
                ladderConnections->Append(ladderConnection);
                //printf("Parsed ladder connect [ID %d]\n", ladderConnectID);
            }
        }

        this->ReadData(&earliestOccupyTimeFirstTeam, sizeof(float), 1, fileHandle);
        this->ReadData(&earliestOccupyTimeSecondTeam, sizeof(float), 1, fileHandle);

        if (version >= 11) {
            for (int navCornerIndex = 0; navCornerIndex < NAV_CORNER_COUNT; navCornerIndex++) {
                float navCornerLightIntensity;
                this->ReadData(&navCornerLightIntensity, sizeof(float), 1, fileHandle);

                NavMeshCornerLightIntensity* cornerLightIntensity = new NavMeshCornerLightIntensity((NavCornerType)navCornerIndex, navCornerLightIntensity);
                cornerLightIntensities->Append(cornerLightIntensity);
                //printf("Light intensity: [%f] [idx %d]\n", navCornerLightIntensity, navCornerIndex);
            }

            if (version >= 16) {
                this->ReadData(&visibleAreaCount, sizeof(unsigned int), 1, fileHandle);

                //printf("Visible area count: %d\n", visibleAreaCount);

                for (unsigned int visibleAreaIndex = 0; visibleAreaIndex < visibleAreaCount; visibleAreaIndex++) {
                    unsigned int visibleAreaID;
                    this->ReadData(&visibleAreaID, sizeof(unsigned int), 1, fileHandle);

                    unsigned char visibleAreaAttributes;
                    this->ReadData(&visibleAreaAttributes, sizeof(unsigned char), 1, fileHandle);

                    NavMeshVisibleArea* visibleArea = new NavMeshVisibleArea(visibleAreaID, visibleAreaAttributes);
                    visibleAreas->Append(visibleArea);
                    //printf("Parsed visible area [%d] with attr [%p]\n", visibleAreaID, visibleAreaAttributes);
                }

                this->ReadData(&inheritVisibilityFrom, sizeof(unsigned int), 1, fileHandle);

                //printf("Inherit visibilty from: %d\n", inheritVisibilityFrom);

                this->ReadData(&unk01, sizeof(unsigned char), 1, fileHandle);
                char trash[14];
                this->ReadData(&trash, sizeof(unsigned char), (int)unk01 * 14, fileHandle);
            }
        }

        NavMeshArea* area = new NavMeshArea(areaID, areaFlags, placeID, x1, y1, z1, x2, y2, z2,
            northEastCornerZ, southWestCornerZ, connections, hidingSpots, encounterPaths, ladderConnections,
            cornerLightIntensities, visibleAreas, inheritVisibilityFrom, earliestOccupyTimeFirstTeam, earliestOccupyTimeSecondTeam, unk01);

        areas->Add(areaID, area);

        if (x1 < min[0])
            min[0] = x1;
        if (y1 < min[1])
            min[1] = y1;
        if (x2 > max[0])
            max[0] = x2;
        if (y2 > max[1])
            max[1] = y2;
    }

    NavGrid* grid = new NavGrid(min, max, 300.0);
    for (auto it = areas->items->begin(); it != areas->items->end(); ++it)
        grid->Push(it->second);
    grid->Finalize();

    unsigned int ladderCount;
    this->ReadData(&ladderCount, sizeof(unsigned int), 1, fileHandle);

    for (unsigned int ladderIndex = 0; ladderIndex < ladderCount; ladderIndex++) {
        unsigned int ladderID;
        this->ReadData(&ladderID, sizeof(unsigned int), 1, fileHandle);

        float ladderWidth;
        this->ReadData(&ladderWidth, sizeof(float), 1, fileHandle);

        float ladderTopX, ladderTopY, ladderTopZ, ladderBottomX, ladderBottomY, ladderBottomZ;

        this->ReadData(&ladderTopX, sizeof(float), 1, fileHandle);
        this->ReadData(&ladderTopY, sizeof(float), 1, fileHandle);
        this->ReadData(&ladderTopZ, sizeof(float), 1, fileHandle);
        this->ReadData(&ladderBottomX, sizeof(float), 1, fileHandle);
        this->ReadData(&ladderBottomY, sizeof(float), 1, fileHandle);
        this->ReadData(&ladderBottomZ, sizeof(float), 1, fileHandle);

        float ladderLength;
        this->ReadData(&ladderLength, sizeof(float), 1, fileHandle);

        unsigned int ladderDirection;
        this->ReadData(&ladderDirection, sizeof(unsigned int), 1, fileHandle);

        unsigned int ladderTopForwardAreaID;
        this->ReadData(&ladderTopForwardAreaID, sizeof(unsigned int), 1, fileHandle);

        unsigned int ladderTopLeftAreaID;
        this->ReadData(&ladderTopLeftAreaID, sizeof(unsigned int), 1, fileHandle);

        unsigned int ladderTopRightAreaID;
        this->ReadData(&ladderTopRightAreaID, sizeof(unsigned int), 1, fileHandle);

        unsigned int ladderTopBehindAreaID;
        this->ReadData(&ladderTopBehindAreaID, sizeof(unsigned int), 1, fileHandle);

        unsigned int ladderBottomAreaID;
        this->ReadData(&ladderBottomAreaID, sizeof(unsigned int), 1, fileHandle);

        NavMeshLadder* ladder = new NavMeshLadder(ladderID, ladderWidth, ladderLength, ladderTopX, ladderTopY, ladderTopZ,
            ladderBottomX, ladderBottomY, ladderBottomZ, (NavDirType)ladderDirection,
            ladderTopForwardAreaID, ladderTopLeftAreaID, ladderTopRightAreaID, ladderTopBehindAreaID, ladderBottomAreaID);

        ladders->Add(ladderID, ladder);
    }

    fclose(fileHandle);
    NavMesh* mesh = new NavMesh(magicNumber, version, navMeshSubVersion, saveBspSize, isMeshAnalyzed, places, areas, ladders, grid);
    return mesh;
}

unsigned int NavMeshLoader::ReadData(void* output, unsigned int elementSize, unsigned int elementCount, FILE* fileHandle)
{
    unsigned int count = fread(output, elementSize, elementCount, fileHandle);

    unsigned int byteCount = elementCount * elementSize;

    this->bytesRead += byteCount;

    return count;
}
