Handle hSDKCallFaceTowards, hSDKCallWiggle;
Handle hSDKCallUpdate, hSDKCallReset, hSDKCallGetLength;

void INIT_NavPath() {
	Handle hConfig = LoadGameConfigFile("test.gamedata"); 
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CHostage::FaceTowards"); 
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_ByValue);
	if ((hSDKCallFaceTowards = EndPrepSDKCall()) == null)
		SetFailState("Failed to load SDK call \"CHostage::FaceTowards\". Update signature in \"test\"");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CHostage::Wiggle"); 
	if ((hSDKCallWiggle = EndPrepSDKCall()) == null)
		SetFailState("Failed to load SDK call \"CHostage::Wiggle\". Update signature in \"test\"");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CNavPathFollower::Update");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_ByValue);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_ByValue);
	if ((hSDKCallUpdate = EndPrepSDKCall()) == null)
		SetFailState("Failed to load SDK call \"CNavPathFollower::Update\". Update signature in \"test\"");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CNavPathFollower::Reset");
	if ((hSDKCallReset = EndPrepSDKCall()) == null)
		SetFailState("Failed to load SDK call \"CNavPathFollower::Reset\". Update signature in \"test\"");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CCSNavPath::GetLength");
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain);
	if ((hSDKCallGetLength = EndPrepSDKCall()) == null)
		SetFailState("Failed to load SDK call \"CCSNavPath::GetLength\". Update signature in \"test\"");
		
	delete hConfig;
}

methodmap CCSNavPath {
	public CCSNavPath(int index) {
		return view_as<CCSNavPath>(index);
	}
	// ---
	property bool CanRepath {
		public get() { return view_as<float>(g_flInstance[view_as<int>(this)][NPC_flNextRepath]) < GetGameTime(); }
	}
	property bool IsStuck {
		public get() { return GetEntData(view_as<int>(this), m_isStuck, 1) > 0 ; }
	}
	property NPCInstance Instance {
		public get() { return view_as<NPCInstance>(this); } 
	}
	
	// ---
	public void Invalidate() {
		SetEntData(view_as<int>(this), m_segmentCount, 0);
	}
	public bool IsValid() {
		return GetEntData(view_as<int>(this), m_segmentCount) > 0 ;
	}
	// ---
	public float GetLength() {
		Address path = GetEntityAddress(view_as<int>(this)) + view_as<Address>(m_path);
		if( this.IsValid() )
			return SDKCall(hSDKCallGetLength, path);
		return 0.0;
	}
	public void GetEndpoint(float vec[3]) {
		int count = GetEntData(view_as<int>(this), m_segmentCount);
		GetEntDataVector(view_as<int>(this), m_path + 8 + (count-1) * 24, vec);
	}
	// ---
	public bool Compute(float src[3], float dst[3]) {
		view_as<float>(g_flInstance[view_as<int>(this)][NPC_flNextRepath]) = GetGameTime() + 0.5;
		
		Address pathFollower = GetEntityAddress(view_as<int>(this)) + view_as<Address>(m_pathFollower);
		Address path = GetEntityAddress(view_as<int>(this)) + view_as<Address>(m_path);
		
		SDKCall(hSDKCallReset, pathFollower);
		return SDKCall(hSDKCallCompute, path, src, dst, 1);
	}
	public void Track(float delta) {
		Address pathFollower = GetEntityAddress(view_as<int>(this)) + view_as<Address>(m_pathFollower);
		SDKCall(hSDKCallUpdate, pathFollower, delta, false);
		
		if( this.IsStuck )
			SDKCall(hSDKCallWiggle, view_as<int>(this));
	}
	public void FaceToward(float vec[3], float delta) {
		SDKCall(hSDKCallFaceTowards, view_as<int>(this), vec, delta); 
	}
};
