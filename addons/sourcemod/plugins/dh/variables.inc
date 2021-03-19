
enum struct Animation {
	int seq;
	int frames;
	float fps;
}
enum struct Attack {
	int type;
	float range;
	int probability;
}

int g_iClassCount = 0;
int g_iClass[MAX_CLASSES][view_as<int>(NPCData_max_Int)], g_iInstance[MAX_CLASSES][view_as<int>(NPCData_max_Int)];
float g_flClass[MAX_CLASSES][view_as<int>(NPCData_max_Float)], g_flInstance[MAX_CLASSES][view_as<int>(NPCData_max_Float)];
char g_szClass[MAX_CLASSES][view_as<int>(NPCData_max_String)][PLATFORM_MAX_PATH], g_szInstance[MAX_CLASSES][view_as<int>(NPCData_max_String)][PLATFORM_MAX_PATH];
Animation g_anClass[MAX_CLASSES][NPCData_max_Animation][MAX_ANIMATION];
Attack g_atClass[MAX_CLASSES][MAX_ATTACK];
PrivateForward g_hClass[MAX_CLASSES][view_as<int>(NPCData_max_Event)];

float m_inhibitDoorTimer[2048];
ConVar sv_pushaway_hostage_force, sv_pushaway_max_hostage_force, sv_pushaway_force, sv_pushaway_max_force;

int m_accel = -1;
int g_cBeam;