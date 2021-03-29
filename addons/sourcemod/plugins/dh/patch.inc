
bool PatchRefIfValue(Address addr, int fromValue, int toValue, int byte = 4) {
	NumberType type = NumberType_Int32;
	
	switch( byte ) {
		case 4: type = NumberType_Int32;
		case 2: type = NumberType_Int16;
		case 1: type = NumberType_Int8;
		default: return false;
	}
	
	int read = byte;
	Address ref = view_as<Address>(LoadFromAddress(addr, type));	
	if( IsValidAddress(ref, read) && read == byte ) {
		int value = LoadFromAddress(ref, type);
		if( value == fromValue ) {
			StoreToAddress(ref, toValue, type);
			return true;
		}
	}
	
	return false;
}

void Memory_Patch() {
	GameData hGameConfg = LoadGameConfigFile("test.gamedata");
	Address addr;

	addr = hGameConfg.GetAddress("CHostage::UpdateFollowing");
	for(int offset=0; offset<1536; offset++) {
		
		if( offset >= 0x1C && offset < 0x22 ) { // Search for a jump to https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L915-L924
			Address ref = addr + view_as<Address>(offset);
			StoreToAddress(ref, 0x90, NumberType_Int8);
		}
		
		if( offset == 0x4CB ) {
			int H8 = LoadFromAddress(addr + view_as<Address>(offset), NumberType_Int8);
			if( H8 == 0xE8 ) { // Search for a call to: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L977
				Address ptr = addr + view_as<Address>(offset + 1);
				Address ref = addr + view_as<Address>(offset + 5 + LoadFromAddress(ptr, NumberType_Int32)); // +5 is really used?
				
				StartPrepSDKCall(SDKCall_Raw);
				PrepSDKCall_SetAddress(ref);
				PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
				PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
				PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer);
				PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
				
				if ((hSDKCallCompute = EndPrepSDKCall()) == null)
					SetFailState("Failed to load SDK call \"Compute\".");
				else
					PrintToServer("Compute is ready at: %u", ref);
				
			}
		}
		
		int H16 = LoadFromAddress(addr + view_as<Address>(offset), NumberType_Int16);
		
		if( H16 == 0x2F0F ) { // Search for COMISS
			// Search for a reference to giveUpRange=2000x2000: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L983
			if( PatchRefIfValue(addr + view_as<Address>(offset+3), view_as<int>(2000.0*2000.0), view_as<int>(4096.0 * 4096.0)) ) {
				PrintToServer("giveUpRange has been patched at offset %d", offset);
			}
			// Search for a reference to maxPathLength=4000: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L984
			if( PatchRefIfValue(addr + view_as<Address>(offset+3), view_as<int>(4000.0), view_as<int>(8192.0)) ) {
				PrintToServer("maxPathLength has been patched at offset %d", offset);
			}
			// Search for a reference to waitRang=150x150: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L1000
			if( PatchRefIfValue(addr + view_as<Address>(offset+3), view_as<int>(150.0*150.0), view_as<int>(48.0*48.0)) ) {
				PrintToServer("waitRang has been patched at offset %d", offset);
			}
		}
		
		if( H16 == 0x0FF3 ) { // Search for MOVSS
			// Search for a reference to nearRange=125x125: https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L1013
			if( PatchRefIfValue(addr + view_as<Address>(offset+4), view_as<int>(125.0*125.0), view_as<int>(32.0*32.0)) ) {
				PrintToServer("nearRange has been patched at offset %d", offset);
			}
		}
		
		if( H16 == 0x5500 ) { // break loop if we find a new fct
			break;
		}

			
	}

	
	addr = hGameConfg.GetAddress("CHostage::CHostage");
	for(int offset=0; offset<0x3BB; offset++) {
		if( offset >= 0x2F0 && offset < 0x2F9 ) { // Search for a jump to https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/cstrike15/hostage/cs_simple_hostage.cpp#L162-L171
			Address ref = addr + view_as<Address>(offset);
			StoreToAddress(ref, 0x90, NumberType_Int8);
		}
	}

	delete hGameConfg;
	
	ServerCommand("cash_player_killed_hostage 0");
	ServerCommand("cash_player_damage_hostage 0");
	ServerCommand("mp_playerid 1"); // maybe 2? 
}
