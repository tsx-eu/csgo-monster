enum struct SDirector {
	ArrayList NPC;
	
	ArrayList Melee;
	int maxMelee;

	ArrayList Distant;	
	int maxDistant;
}
SDirector Director_Data;

methodmap CDirector < Handle {
	public CDirector(int melee, int distant) {
		Director_Data.NPC = new ArrayList();
		
		Director_Data.Melee = new ArrayList();
		Director_Data.maxMelee = melee;
		
		Director_Data.Distant = new ArrayList();
		Director_Data.maxDistant = distant;
		
		return view_as<CDirector>(0);
	}
	
	public void Register(NPCInstance entity) {
		Director_Data.NPC.Push(entity);
		entity.IsWaiting = true;
	}
	public void Unregister(NPCInstance entity) {
		int index;
		
		index = Director_Data.NPC.FindValue(entity);
		if( index >= 0 )
			Director_Data.NPC.Erase(index);
		
		index = Director_Data.Melee.FindValue(entity);
		if( index >= 0 )
			Director_Data.Melee.Erase(index);
		
		index = Director_Data.Distant.FindValue(entity);
		if( index >= 0 )
			Director_Data.Distant.Erase(index);
	}
	
	property ArrayList NPC {
		public get() { return Director_Data.NPC; }
	}
	property ArrayList Melee {
		public get() { return Director_Data.Melee; }
	}
	property int maxMelee {
		public get() { return Director_Data.maxMelee; }
	}
	property ArrayList Distant {
		public get() { return Director_Data.Distant; }
	}
	property int maxDistant {
		public get() { return Director_Data.maxDistant; }
	}
	

	public void Update() {
		// TODO place this.NPC as "uncategorized"
		// TODO this.WaitingMelee / WaitingDistant
		
		// Place inactive NPC to active state.
		if( this.NPC.Length > 0 ) {
			if( this.maxMelee > this.Melee.Length ) {
				int nearest = findNearestInactiveNPC(0.0, NPC_RANGE_MELEE * 2.0);
				if( nearest > 0 ) {
					this.Melee.Push(nearest);
					g_iInstance[nearest][NPC_isWaiting] = 0;
				}
			}
			
			if( this.maxDistant > this.Distant.Length ) {
				int nearest = findNearestInactiveNPC(NPC_RANGE_MELEE * 2.0, 9999999.9);
				if( nearest > 0 ) {
					this.Distant.Push(nearest);
					g_iInstance[nearest][NPC_isWaiting] = 0;
				}
			}
		}
	}
};


CDirector Director;
void INIT_Director() {
	Director = new CDirector(2, 2);
	CreateTimer(0.25, FRAME_Director, 0, TIMER_REPEAT);
}
public Action FRAME_Director(Handle timer, any none) {
	Director.Update();
}

 
int findNearestInactiveNPC(float min, float max) {
	int nearest = 0;
	float dist = 99999999.9;
	
	for(int i=0; i<Director.NPC.Length; i++) {
		int entity = Director.NPC.Get(i);
		
		if( g_iInstance[entity][NPC_isWaiting] == 1 && g_iInstance[entity][NPC_iLeader] > 0 && 
			view_as<float>(g_flInstance[entity][NPC_flNearRange]) < max && view_as<float>(g_flInstance[entity][NPC_flNearRange]) >= min ) {
			
			float tmp = Entity_GetDistance(entity, g_iInstance[entity][NPC_iLeader]);
			if( tmp < dist ) {
				tmp = dist;
				nearest = entity;
			}
		}
	}
	
	return nearest;
}