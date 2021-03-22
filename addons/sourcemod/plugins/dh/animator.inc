void INIT_Animator() {
	Handle hConfig = LoadGameConfigFile("plugin.turret"); 
	
	if ((AnimatingOverlay_Count = GameConfGetOffset(hConfig, "CBaseAnimatingOverlay::Count")) == -1)
		SetFailState("Failed to get offset: \"CBaseAnimatingOverlay::Count\". Update offset in \"plugin.turret\""); 
	

	StartPrepSDKCall(SDKCall_Entity); 
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CBaseAnimatingOverlay::StudioFrameAdvance"); 
	if ((hSDKCallStudioFrameAdvance = EndPrepSDKCall()) == null)
		SetFailState("Failed to load SDK call \"CBaseAnimatingOverlay::StudioFrameAdvance\". Update signature in \"plugin.turret\"");      
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CBaseAnimatingOverlay::AddLayeredSequence"); 
	
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((hSDKCallAddLayeredSequence = EndPrepSDKCall()) == null)
		SetFailState("Failed to load SDK call \"CBaseAnimatingOverlay::AddLayeredSequence\". Update signature in \"plugin.turret\""); 
	
	// ----------------------------------------------------------------------------------------------------------------------------------------------
	delete hConfig;
}

#define ANIM_LAYER_ACTIVE        0x0001 
#define ANIM_LAYER_AUTOKILL      0x0002 
#define ANIM_LAYER_KILLME        0x0004 
#define ANIM_LAYER_DONTRESTORE   0x0008 
#define ANIM_LAYER_CHECKACCESS   0x0010 
#define ANIM_LAYER_DYING         0x0020
#define ANIM_LAYER_NOEVENTS      0x0040

enum { //CAnimationLayer
	m_fFlags = 0,
	m_bSequenceFinished = 4,
	m_bLooping = 5,
	m_nSequence = 8,
	m_flCycle = 12,
	m_flPlaybackRate = 16,
	m_flPrevCycle = 20,
	m_flWeight = 24,
	m_flWeightDeltaRate = 28,
	m_flBlendIn = 32,
	m_flBlendOut = 36,
	m_flKillRate = 40,
	m_flKillDelay = 44,
	m_flLayerAnimtime = 48,
	m_flLayerFadeOuttime = 52,
	/*	??? = 56,
		??? = 60,
		??? = 64, */
	m_nActivity = 68,
	m_nPriority = 72,
	m_nOrder = 76,
	m_flLastEventCheck = 80,
	m_flLastAccess = 84,
	m_pOwnerEntity = 88,
	CAnimationLayer_Size = 92
};

// https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/game/server/BaseAnimatingOverlay.cpp
methodmap CAnimationOverlay  { 
	public CAnimationOverlay(int address) {
		return view_as<CAnimationOverlay>(address);
	}
	property Address Address { 
		public get() { 
			return view_as<Address>(this); 
		} 
	} 
	property bool isNull {
		public get() { 
			return this.Address == Address_Null; 
		} 
	}
	public any Get(int iOffset, int iLayer) { 
		return LoadFromAddress(this.Address + view_as<Address>(iOffset + CAnimationLayer_Size * iLayer), NumberType_Int32); 
	}
	public void Set(int iOffset, int iLayer, any iValue) { 
		StoreToAddress(this.Address + view_as<Address>(iOffset + CAnimationLayer_Size * iLayer), iValue, NumberType_Int32); 
	}
	
	public bool IsActive(int iLayer)    { return ((this.Get(m_fFlags, iLayer) & ANIM_LAYER_ACTIVE)   != 0); } 
	public bool IsAutokill(int iLayer)  { return ((this.Get(m_fFlags, iLayer) & ANIM_LAYER_AUTOKILL) != 0); } 
	public bool IsKillMe(int iLayer)    { return ((this.Get(m_fFlags, iLayer) & ANIM_LAYER_KILLME)   != 0); } 
	public bool IsDying(int iLayer)     { return ((this.Get(m_fFlags, iLayer) & ANIM_LAYER_DYING)    != 0); } 
	public bool NoEvents(int iLayer)    { return ((this.Get(m_fFlags, iLayer) & ANIM_LAYER_NOEVENTS) != 0); }
	public void KillMe(int iLayer)      { int iFlags = this.Get(m_fFlags, iLayer); this.Set(m_fFlags, iLayer, (iFlags |= ANIM_LAYER_KILLME)); } 
	public void AutoKill(int iLayer)    { int iFlags = this.Get(m_fFlags, iLayer); this.Set(m_fFlags, iLayer, (iFlags |= ANIM_LAYER_AUTOKILL)); }
	public void Dying(int iLayer)       { int iFlags = this.Get(m_fFlags, iLayer); this.Set(m_fFlags, iLayer, (iFlags |= ANIM_LAYER_DYING));  } 
	public void Dead(int iLayer)        { int iFlags = this.Get(m_fFlags, iLayer); this.Set(m_fFlags, iLayer, (iFlags &= ~ANIM_LAYER_DYING)); }
	public void Loop(int iLayer)        { int iFlags = this.Get(m_fFlags, iLayer); this.Set(m_fFlags, iLayer, (iFlags &= ~ANIM_LAYER_AUTOKILL)); }
	
	public void RemoveLayer(int iLayer, float flKillRate, float flKillDelay) {
		this.Set(m_flKillRate, iLayer, flKillRate > 0.0 ? this.Get(m_flWeight, iLayer) / flKillRate : 100.0);
		this.Set(m_flKillDelay, iLayer, flKillDelay);
		this.KillMe(iLayer);
	}
	
	public void SetLayerAutokill(int iLayer, bool bAutokill) {
		if (bAutokill)
			this.AutoKill(iLayer);
		else
			this.Loop(iLayer);
	}
	
	public void SetLayerPlaybackRate(int iLayer, float rate) {
		this.Set(m_flPlaybackRate, iLayer, rate);
	}
	public void SetLayerWeight(int iLayer, float weight) {
		this.Set(m_flWeight, iLayer, weight);
	}
	public void SetLayerBlend(int iLayer, float blend_in, float blend_out) {
		this.Set(m_flBlendIn, iLayer, blend_in);
		this.Set(m_flBlendOut, iLayer, blend_out);
	}
	
	public bool IsAlive(int iLayer)         { int iFlags = this.Get(m_fFlags, iLayer); return (((iFlags & ANIM_LAYER_ACTIVE) != 0) || ((iFlags & ANIM_LAYER_KILLME) == 0)); }
	
	public int GetLayerSequence(int iLayer) { return (this.Get(m_nSequence, iLayer)); }
};


methodmap IAnimator {
	
	public IAnimator(int index) {
		return view_as<IAnimator>(index);
	}
	
	public CAnimationOverlay CBaseAnimatingOverlay()  { 
		static int iOffset;
		if (!iOffset) iOffset = FindDataMapInfo(view_as<int>(this), "m_AnimOverlay");
		return CAnimationOverlay(GetEntData(view_as<int>(this), iOffset));
	}

	public int AnimOverlayCount() {
		static int iOffset;
		if (!iOffset) iOffset = FindDataMapInfo(view_as<int>(this), "m_AnimOverlay") + AnimatingOverlay_Count;
		return GetEntData(view_as<int>(this), iOffset);
	}
	
	public int FindGestureLayer(int iSequence) {
		CAnimationOverlay pOverlay = this.CBaseAnimatingOverlay(); 
		if (pOverlay.isNull)
			return -1; 
		
		int iCount = this.AnimOverlayCount();
		for (int i = 0; i < iCount; i++) {
			if (!pOverlay.IsAlive(i))
				continue; 

			if (pOverlay.GetLayerSequence(i) == iSequence)
				return i; 
		} 
		
		return -1; 
	}

	public int AddGesture(int iSequence, bool bAutoKill = true) { 
		CAnimationOverlay pOverlay = this.CBaseAnimatingOverlay(); 
		if (pOverlay.isNull)
			return -1; 
		
		int iLayer = SDKCall(hSDKCallAddLayeredSequence, view_as<int>(this), iSequence, 0); 
		if (iLayer >= 0 && iLayer < this.AnimOverlayCount() && pOverlay.IsActive(iLayer)) {
			pOverlay.SetLayerAutokill(iLayer, bAutoKill);
		}
		
		
		return iLayer;
	}

	public bool IsPlayingGesture(int iSequence) { 
		return this.FindGestureLayer(iSequence) != -1 ? true : false; 
	} 

	public void RemoveGesture(int iSequence) { 
		int iLayer = this.FindGestureLayer(iSequence); 
		if (iLayer == -1)
			return; 

		CAnimationOverlay pOverlay = this.CBaseAnimatingOverlay(); 
		if (pOverlay.isNull)
			return;
		
		pOverlay.RemoveLayer(iLayer, 0.0, 0.0);
	}
};