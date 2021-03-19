// =============================================================
//
// Entcontrol (HLLibWrapper.cpp)
// Copyright Raffael Holz aka. LeGone. All rights reserved.
// http://www.legone.name
// HLLib: Copyright (C) 2006-2010 Ryan Gregg
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License, version 3.0, as published by the
// Free Software Foundation.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <http://www.gnu.org/licenses/>.
//
// =============================================================

#include "HLLib/HLLibWrapper.hpp"

#include "HLLib/HLLib.h"
#include "HLLib/Wrapper.h"

namespace HLLib
{
	hlUInt uiPackage;

	bool Open(const char *file)
	{
		hlInitialize();

		HLPackageType ePackageType = hlGetPackageTypeFromName(file);

		// Create a package element, the element is allocated by the library and cleaned
		// up by the library.  An ID is generated which must be bound to apply operations
		// to the package.
		if (!hlCreatePackage(ePackageType, &uiPackage))
		{
			printf("Error loading %s:\n%s\n", file, hlGetString(HL_ERROR_SHORT_FORMATED));

			hlShutdown();
			return (false);
		}

		hlBindPackage(uiPackage);

		// Open the package.
		// Of the above modes, only HL_MODE_READ is required.  HL_MODE_WRITE is present
		// only for future use.  File mapping is recommended as an efficient way to load
		// packages.  Quick file mapping maps the entire file (instead of bits as they are
		// needed) and thus should only be used in Windows 2000 and up (older versions of
		// Windows have poor virtual memory management which means large files won't be able
		// to find a continues block and will fail to load).  Volatile access allows HLLib
		// to share files with other applications that have those file open for writing.
		// This is useful for, say, loading .gcf files while Steam is running.
		if (!hlPackageOpenFile(file, HL_MODE_READ))
		{
			printf("Error loading %s:\n%s\n", file, hlGetString(HL_ERROR_SHORT_FORMATED));

			hlShutdown();
			return (false);
		}

		return (true);
	}

	bool FindItem(const char *file)
	{
		if (hlFolderGetItemByPath(hlPackageGetRoot(), file, HL_FIND_ALL))
			return (true);

		return (false);
	}

	bool ExtractItem(const char *file, const char *destination)
	{
		// Find the item.
		HLDirectoryItem *pItem = hlFolderGetItemByPath(hlPackageGetRoot(), file, HL_FIND_ALL);

		if (pItem != 0 && hlItemExtract(pItem, destination))
			return (true);

		return (false);
	}

	void Close()
	{
		// Close the package.
		hlPackageClose();

		// Free up the allocated memory.
		hlDeletePackage(uiPackage);

		hlShutdown();
	}
}