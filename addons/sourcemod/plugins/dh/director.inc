enum struct SDirector {
	ArrayList NPC;
	
	ArrayList WaitingMelee;
	ArrayList Melee;
	int maxMelee;

	ArrayList WaitingDistant;
	ArrayList Distant;	
	int maxDistant;
	
	float DifficultyDamage;
}
SDirector Director_Data;

methodmap CDirector < Handle {
	public CDirector(int melee, int distant, float damage) {
		Director_Data.NPC = new ArrayList();
		
		Director_Data.Melee = new ArrayList();
		Director_Data.WaitingMelee = new ArrayList();
		Director_Data.maxMelee = melee;
		
		Director_Data.Distant = new ArrayList();
		Director_Data.WaitingDistant = new ArrayList();
		Director_Data.maxDistant = distant;
		
		Director_Data.DifficultyDamage = damage;
		
		return view_as<CDirector>(0);
	}
	
	public void Register(NPCInstance entity) {
		Director_Data.NPC.Push(entity);
		if( entity.Class.IsMelee )
			Director_Data.WaitingMelee.Push(entity);
		if( entity.Class.IsDistant )
			Director_Data.WaitingDistant.Push(entity);
		
		entity.IsWaiting = true;
	}
	public void Unregister(NPCInstance entity) {
		int index;
		
		index = Director_Data.NPC.FindValue(entity);
		if( index >= 0 )
			Director_Data.NPC.Erase(index);
		
		// ---
		
		index = Director_Data.Melee.FindValue(entity);
		if( index >= 0 )
			Director_Data.Melee.Erase(index);
		
		index = Director_Data.WaitingMelee.FindValue(entity);
		if( index >= 0 )
			Director_Data.WaitingMelee.Erase(index);
		
		// ---
		
		index = Director_Data.Distant.FindValue(entity);
		if( index >= 0 )
			Director_Data.Distant.Erase(index);
		
		index = Director_Data.WaitingDistant.FindValue(entity);
		if( index >= 0 )
			Director_Data.WaitingDistant.Erase(index);
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
	property float DifficultyDamage {
		public get() { return Director_Data.DifficultyDamage; } 
		public set(const float value) { Director_Data.DifficultyDamage = value; } 
	}
	

	public void Update() {
		// Place inactive NPC to active state.
		if( this.NPC.Length > 0 ) {
			if( this.maxMelee > this.Melee.Length && Director_Data.WaitingMelee.Length > 0 ) {
				int nearest = findNearestInactiveNPC(Director_Data.WaitingMelee);
				if( nearest > 0 ) {
					this.Melee.Push(nearest);
					g_iInstance[nearest][NPC_isWaiting] = 0;
				}
			}
			
			if( this.maxDistant > this.Distant.Length && Director_Data.WaitingDistant.Length > 0 ) {
				int nearest = findNearestInactiveNPC(Director_Data.WaitingDistant);
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
	Director = new CDirector(3, 6, 1.0);
	CreateTimer(0.25, FRAME_Director, 0, TIMER_REPEAT);
}
public Action FRAME_Director(Handle timer, any none) {
	Director.Update();
}

 
int findNearestInactiveNPC(ArrayList npc) {
	int nearest = 0;
	int index = -1;
	float dist = 99999999.9;
	
	for(int i=0; i<npc.Length; i++) {
		int entity = npc.Get(i);
		
		if( g_iInstance[entity][NPC_isWaiting] == 1 && g_iInstance[entity][NPC_iLeader] > 0 ) {
			
			float tmp = Entity_GetDistance(entity, g_iInstance[entity][NPC_iLeader]);
			if( tmp < dist ) {
				tmp = dist;
				nearest = entity;
				index = i;
			}
		}
	}
	
	if( index >= 0 )
		npc.Erase(index);
	
	return nearest;
}