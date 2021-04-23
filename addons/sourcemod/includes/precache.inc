#if defined _precache_included_
	#endinput
#endif
#define _precache_included_

#define hasLength(%0)           (%0[0] != NULL_STRING[0]) 

stock int Precache_Model(char[] sModel) {
	if( !hasLength(sModel) ) {
		return 0;
	}
	
	if( !FileExists(sModel) ) { // Try to find file in .vpk
		if( FileExists(sModel, true) ) {
			return PrecacheModel(sModel, true);
		}
		
		PrintToServer("[PRECACHE] Invalid model path. File not found: \"%s\"", sModel);
		return 0;
	}
	
	if( !IsModelPrecached(sModel) )  {
		Precache_ModelSounds(sModel);
		Precache_ModelMaterials(sModel);
		Precache_ModelResources(sModel);
	}
	
	return PrecacheModel(sModel, true);
}

stock int Precache_Particles(char[] sModel) {
	if( !hasLength(sModel) ) {
		return 0;
	}
	
	// If model didn't exist, then
	if( !FileExists(sModel) ) { // Try to find file in .vpk
		if( FileExists(sModel, true) ) {
			return PrecacheModel(sModel, true);
		}
		
		PrintToServer("[PRECACHE] Invalid particle path. File not found: \"%s\"", sModel);
		return 0;
	}
	
	Precache_Effects(sModel);
	return PrecacheGeneric(sModel, true);
}

stock bool Precache_Effect(char[] sModel) {	
	AddFileToDownloadsTable(sModel);
	
	File hFile = OpenFile(sModel, "rb");
	if( hFile == null ) {
		PrintToServer("[PRECACHE] Invalid model path. File not found: \"%s\"", sModel);
		return false;
	}

	int iChar, iFormat;

	do {
		hFile.Seek(2, SEEK_CUR);
		hFile.ReadInt8(iChar);
	} 
	while( iChar == 0 );
	hFile.Seek(1, SEEK_CUR);

	do {
		hFile.Seek(2, SEEK_CUR);
		hFile.ReadInt8(iChar);
	} 
	while( iChar );

	while( !hFile.EndOfFile() ) {
		hFile.ReadString(sPath, sizeof(sPath));
		iFormat = FindCharInString(sPath, '.', true);

		if (iFormat != -1) {
			if (!strcmp(sPath[iFormat], ".vmt", false)) {
				Format(sPath, sizeof(sPath), "materials\\%s", sPath);
				Precache_Texture(sModel, sPath);
			}
		}
	}

	delete hFile;
	return true;
}

stock bool Precache_Texture(char[] sPath) {
	static char sTexture[PLATFORM_MAX_PATH];
	strcopy(sTexture, sizeof(sTexture), sPath);
	
	if( !FileExists(sTexture) ) {
		if( FileExists(sTexture, true) ) {
			return true;
		}

		PrintToServer("[PRECACHE] Invalid material path. File not found: \"%s\"", sTexture);
		return false;
	}

	AddFileToDownloadsTable(sTexture);
	
	static char sTypes[4][32] = { "$baseTexture", "$bumpmap", "$lightwarptexture", "$REFRACTTINTtexture" };
	bool bFound[sizeof(sTypes)];
	int iShift;
	
	File hFile = OpenFile(sTexture, "rt");
	if (hFile == null) {
		PrintToServer("[PRECACHE] Error opening file: \"%s\"", sTexture);
		return false;
	}
	
	while (hFile.ReadLine(sTexture, sizeof(sTexture))) {
		SplitString(sTexture, "//", sTexture, sizeof(sTexture));

		int iSize = sizeof(sTypes);
		for (int x = 0; x < iSize; x++) {
			if (bFound[x]) {
				continue;
			}
			
			if ((iShift = StrContains(sTexture, sTypes[x], false)) != -1) {
				iShift += strlen(sTypes[x]) + 1;

				int iQuotes = CountCharInString(sTexture[iShift], '"');
				if (iQuotes != 2) {
					PrintToServer("[PRECACHE] Error with parsing \"%s\" in file: \"%s\"", sTypes[x], sPath);
				}
				else {
					bFound[x] = true;
					strcopy(sTexture, sizeof(sTexture), sTexture[iShift]);
					TrimString(sTexture);
					StripQuotes(sTexture);

					if( !hasLength(sTexture) ) {
						continue;
					}
					
					Format(sTexture, sizeof(sTexture), "materials\\%s.vtf", sTexture);
					if( FileExists(sTexture) ) {
						AddFileToDownloadsTable(sTexture);
					}
					else {
						if( !FileExists(sTexture, true) ) {
							PrintToServer("[PRECACHE] Invalid texture path. File not found: \"%s\"", sTexture);
						}
				   }
				}
			}
		}
	}

	delete hFile; 
	return true;
}

stock bool Precache_Sound(char[] sFile) {
	
	if( !FileExists(sFile) ) { // Try to find file in .vpk
		if( FileExists(sFile, true) ) {
			return PrecacheSound(sFile, true);
		}
		
		PrintToServer("[PRECACHE] Invalid sound path. File not found: \"%s\"", sFile);
		return false;
	}
	
	AddFileToDownloadsTable(sFile);
	PrecacheSound(sFile);
	
	return true;
}



stock void Precache_ModelResources(char[] sModel) {
	AddFileToDownloadsTable(sModel);

	static char sResource[PLATFORM_MAX_PATH];
	static char sTypes[3][32] = { ".dx90.vtx", ".phy", ".vvd" };

	int iFormat = FindCharInString(sModel, '.', true);
	int iSize = sizeof(sTypes);
	for (int i = 0; i < iSize; i++) {
		StrExtract(sResource, sModel, 0, iFormat);
		StrCat(sResource, sizeof(sResource), sTypes[i]);
		
		if( FileExists(sResource) ) {
			AddFileToDownloadsTable(sResource);
		}
	}
}

stock bool Precache_ModelSounds(char[] sModel) {
	static char sPath[PLATFORM_MAX_PATH];
	
	// Opens the file
	File hFile = OpenFile(sModel, "rb");
	if( hFile == null ) {
		PrintToServer("[PRECACHE] Invalid model path. File not found: \"%s\"", sModel);
		return false;
	}
	
	int iChar;
	do {
		hFile.Seek(2, SEEK_CUR);
		hFile.ReadInt8(iChar);
	} 
	while( iChar == 0 );
	hFile.Seek(1, SEEK_CUR);

	do {
		hFile.Seek(2, SEEK_CUR);
		hFile.ReadInt8(iChar);
	} 
	while( iChar );

	while( !hFile.EndOfFile() ) {
		hFile.ReadString(sPath, sizeof(sPath));
		
		int iFormat = FindCharInString(sPath, '.', true);
		if (iFormat != -1) {
			if (!strcmp(sPath[iFormat], ".mp3", false) || !strcmp(sPath[iFormat], ".wav", false)) {
				Format(sPath, sizeof(sPath), "sound/%s", sPath);
				Precache_Sound(sPath);
			}
		}
	}

	delete hFile;
	return true;
}

stock bool Precache_ModelMaterials(char[] sModel) {

	// Opens the file
	File hFile = OpenFile(sModel, "rb");
	if( hFile == null ) {
		PrintToServer("[PRECACHE] Invalid model path. File not found: \"%s\"", sModel);
		return false;
	}
	
	static char sMaterial[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH], sFile[PLATFORM_MAX_PATH];
	int iNumMat, iChar, iFormat;

	// Find the total materials amount
	hFile.Seek(204, SEEK_SET);
	hFile.ReadInt32(iNumMat);
	hFile.Seek(0, SEEK_END);
	
	do {
		hFile.Seek(-2, SEEK_CUR);
		hFile.ReadInt8(iChar);
	} 
	while (iChar == 0);
	hFile.Seek(-1, SEEK_CUR);

	do {
		hFile.Seek(-2, SEEK_CUR);
		hFile.ReadInt8(iChar);
	} 
	while (iChar);

	int iPosIndex = hFile.Position;
	hFile.ReadString(sMaterial, sizeof(sMaterial));
	hFile.Seek(iPosIndex, SEEK_SET);
	hFile.Seek(-1, SEEK_CUR);
	
	ArrayList hList = new ArrayList(32);

	// Reverse loop throught the binary
	while (hFile.Position > 1 && hList.Length < iNumMat) {
		do {
			hFile.Seek(-2, SEEK_CUR);
			hFile.ReadInt8(iChar);
		} 
		while( iChar );

		iPosIndex = hFile.Position;
		hFile.ReadString(sPath, sizeof(sPath));
		hFile.Seek(iPosIndex, SEEK_SET);
		hFile.Seek(-1, SEEK_CUR);

		if( !hasLength(sPath) ) {
			continue;
		}

		iFormat = FindCharInString(sPath, '\\', true);

		if (iFormat != -1) {
			Format(sPath, sizeof(sPath), "materials\\%s", sPath);
			DirectoryListing hDirectory = OpenDirectory(sPath);
			
			if (hDirectory == null) {
				PrintToServer("[PRECACHE] Error opening folder: \"%s\"", sPath);
				continue;
			}

			FileType hType;
			while (hDirectory.GetNext(sFile, sizeof(sFile), hType)) {
				if (hType == FileType_File) {
					iFormat = FindCharInString(sFile, '.', true);
					
					if (iFormat != -1) {
						if (!strcmp(sFile[iFormat], ".vmt", false)) {
							if (hList.FindString(sFile) == -1) {
								hList.PushString(sFile);
							}
							
							Format(sFile, sizeof(sFile), "%s%s", sPath, sFile);
							Precache_Texture(sFile);
						}
					}
				}
			}

			delete hDirectory;
		}
		else {
			StrCat(sPath, sizeof(sPath), ".vmt");
			if (hList.FindString(sPath) == -1) {
				hList.PushString(sPath);
			}
			
			Format(sPath, sizeof(sPath), "materials\\%s%s", sMaterial, sPath);
			Precache_Texture(sPath);
		}
	}

	// Close file
	delete hFile;
	delete hList;
	
	return true;
}

stock int StrExtract(char[] sBuffer, char[] sSource, int startPos, int endPos) {
	int iMaxLen = endPos - startPos + 1;
	if( iMaxLen < 0 ) {
		sBuffer[0] = NULL_STRING[0];
		return 0;
	}

	return strcopy(sBuffer, iMaxLen, sSource[startPos]);
}
stock int CountCharInString(char[] sBuffer, char cSymbol) {
	int iCount;
	
	int iLen = strlen(sBuffer);
	for( int i = 0; i < iLen; i++) {
		if (sBuffer[i] == cSymbol) {
			iCount++;
		}
	}

	return iCount ? iCount : -1;
}
