
enum struct Animation {
	int seq;
	int frames;
	float fps;
}
enum struct Attack {
	NPC_AttackType type;
	float range;
	int probability;
}

int g_iClassCount = 0;
int g_iClass[MAX_CLASSES][view_as<int>(NPCData_max_Int)], g_iInstance[2048][view_as<int>(NPCData_max_Int)];
float g_flClass[MAX_CLASSES][view_as<int>(NPCData_max_Float)], g_flInstance[2048][view_as<int>(NPCData_max_Float)];
char g_szClass[MAX_CLASSES][view_as<int>(NPCData_max_String)][PLATFORM_MAX_PATH], g_szInstance[2048][view_as<int>(NPCData_max_String)][PLATFORM_MAX_PATH];

int g_iPose[MAX_CLASSES][view_as<int>(NPCData_max_Pose)];
Animation g_anClass[MAX_CLASSES][NPCData_max_Animation][MAX_ANIMATION];
Attack g_atClass[MAX_CLASSES][MAX_ATTACK];
PrivateForward g_hClass[MAX_CLASSES][view_as<int>(NPCData_max_Event)];

ConVar sv_pushaway_hostage_force, sv_pushaway_max_hostage_force, sv_pushaway_force, sv_pushaway_max_force;

StringMap g_hNamedIdentified;

int m_accel = -1;
int g_cBeam;