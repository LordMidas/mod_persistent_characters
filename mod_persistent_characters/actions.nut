// Player actions on the persistent data, used by the Persistent Characters screen.
// Each function returns null on success or a string describing the error.
// Functions which change the persistent data write it to the file immediately.
::ModPersistentCharacters.Actions <- {
	ExportPrefix = "Export_",
	ExportRawPrefix = "ExportRaw_",

	function findInPlayerRoster( _broUID )
	{
		if (_broUID == null)
			return null;

		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			if (bro.ModPersistentCharacters_getUID() == _broUID)
				return bro;
		}
		return null;
	}

	// Returns null if the bro can be imported into the current company, otherwise the reason
	function getCannotImportReason( _broData )
	{
		if (!_broData.isLoadable())
			return "Missing required mods";

		if (::World.getPlayerRoster().getSize() >= ::World.Assets.getBrothersMax())
			return "Your roster is full";

		if (this.findInPlayerRoster(_broData.getUID()) != null)
			return "Already in your company";

		if (_broData.isHome(::ModPersistentCharacters.getCampaignUID()))
			return "He belongs to this company";

		if (_broData.getUID() != null && ::ModPersistentCharacters.hasBlockedBro(_broData.getUID()))
			return "Already present in this campaign e.g. as a recruit in a settlement";

		return null;
	}

	function importBro( _broUID )
	{
		local broData = ::ModPersistentCharacters.getDataManager().getBro(_broUID);
		if (broData == null)
			return "Character not found";

		local reason = this.getCannotImportReason(broData);
		if (reason != null)
			return reason;

		broData.createBro(::World.getPlayerRoster()).onHired();
		return null;
	}

	// Returns null if the bro can be made a part of the current company, otherwise the reason
	function getCannotMakeHomeReason( _broData )
	{
		if (!::ModPersistentCharacters.isSavingEnabled())
			return "Saving characters is disabled for this company";

		if (_broData.isHome(::ModPersistentCharacters.getCampaignUID()))
			return "This is already his home company";

		if (this.findInPlayerRoster(_broData.getUID()) == null)
			return "He must be in your company";

		return null;
	}

	function makeHome( _broUID )
	{
		local dataManager = ::ModPersistentCharacters.getDataManager();
		local broData = dataManager.getBro(_broUID);
		if (broData == null)
			return "Character not found";

		local reason = this.getCannotMakeHomeReason(broData);
		if (reason != null)
			return reason;

		dataManager.makeHome(this.findInPlayerRoster(_broUID));
		::ModPersistentCharacters.writeToFile();
		return null;
	}

	function getCannotDeleteBroReason( _broData )
	{
		if (this.findInPlayerRoster(_broData.getUID()) != null && _broData.isHome(::ModPersistentCharacters.getCampaignUID()))
			return "He is in your company and would be saved again the next time you save";

		return null;
	}

	function deleteBro( _broUID )
	{
		local dataManager = ::ModPersistentCharacters.getDataManager();
		local broData = dataManager.getBro(_broUID);
		if (broData == null)
			return "Character not found";

		local reason = this.getCannotDeleteBroReason(broData);
		if (reason != null)
			return reason;

		dataManager.removeBro(_broUID);
		::ModPersistentCharacters.writeToFile();
		return null;
	}

	function getCannotDeleteCampaignReason( _campaignUID )
	{
		if (_campaignUID == ::ModPersistentCharacters.getCampaignUID())
			return "Cannot delete your current company";

		return null;
	}

	// The bros of the campaign become loose bros unless _deleteBros is true
	function deleteCampaign( _campaignUID, _deleteBros = false )
	{
		local dataManager = ::ModPersistentCharacters.getDataManager();
		if (!dataManager.hasCampaign(_campaignUID))
			return "Campaign not found";

		local reason = this.getCannotDeleteCampaignReason(_campaignUID);
		if (reason != null)
			return reason;

		dataManager.removeCampaign(_campaignUID, _deleteBros);
		::ModPersistentCharacters.writeToFile();
		return null;
	}

	// _mode is only used when disabling: "keep" keeps the existing data of this campaign as is,
	// "loose" turns its bros into loose bros and "delete" deletes its bros
	function setSavingEnabled( _enabled, _mode = "keep" )
	{
		::ModPersistentCharacters.setSavingEnabled(_enabled);
		if (_enabled)
			return null;

		local dataManager = ::ModPersistentCharacters.getDataManager();
		local campaignUID = ::ModPersistentCharacters.getCampaignUID();
		switch (_mode)
		{
			case "loose":
				dataManager.removeCampaign(campaignUID);
				break;

			case "delete":
				dataManager.removeCampaign(campaignUID, true);
				break;
		}

		::ModPersistentCharacters.writeToFile();
		return null;
	}

	function deleteLooseBros()
	{
		::ModPersistentCharacters.getDataManager().removeLooseBros();
		::ModPersistentCharacters.writeToFile();
		return null;
	}

	function getCannotSetDeadReason( _broData, _campaignUID )
	{
		if (_campaignUID == ::ModPersistentCharacters.getCampaignUID() && this.findInPlayerRoster(_broData.getUID()) != null)
			return "He is alive in your current company";

		return null;
	}

	function setDead( _broUID, _campaignUID, _isDead )
	{
		local broData = ::ModPersistentCharacters.getDataManager().getBro(_broUID);
		if (broData == null)
			return "Character not found";

		local stats = broData.getLifetimeStats(_campaignUID);
		if (stats == null)
			return "No record for that company";

		local reason = this.getCannotSetDeadReason(broData, _campaignUID);
		if (reason != null)
			return reason;

		stats.setDead(_isDead);
		::ModPersistentCharacters.writeToFile();
		return null;
	}

	function setRequiredMods( _modIDs )
	{
		::ModPersistentCharacters.setRequiredModIDs(_modIDs);
		::ModPersistentCharacters.writeToFile();
		return null;
	}

	// Battle Brothers filenames can only contain the characters 'a-zA-Z0-9_,-+# '
	function sanitizeFilename( _string )
	{
		local allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
		local ret = "";
		foreach (c in _string)
		{
			local ch = c.tochar();
			if (allowed.find(ch) != null)
				ret += ch;
			else if (ch == " ")
				ret += "_";
		}
		return ret;
	}

	// If _raw is true, the bro is exported without the persistence data so that he becomes
	// a new persistent character of whichever campaign he is imported into
	function exportBro( _broUID, _raw = false )
	{
		local broData = ::ModPersistentCharacters.getDataManager().getBro(_broUID);
		if (broData == null)
			return "Character not found";

		if (!broData.isLoadable())
			return "Missing required mods";

		local filename = (_raw ? this.ExportRawPrefix : this.ExportPrefix) + this.sanitizeFilename(broData.getName()) + "_" + broData.getUID();

		if (_raw)
		{
			local requiredMods = clone broData.getRequiredMods();
			local bro = broData.createBro(::World.getTemporaryRoster(), false);
			bro.getFlags().remove(::ModPersistentCharacters.FlagID.BroUID);
			bro.getFlags().remove(::ModPersistentCharacters.FlagID.CampaignUID);
			broData = ::ModPersistentCharacters.Class.PersistentBroData(bro);
			::World.getTemporaryRoster().remove(bro);

			// He is serialized again with the mods of this session, so the mods required by
			// the current campaign are needed in addition to the ones he originally required
			foreach (modID, modName in broData.getRequiredMods())
			{
				requiredMods[modID] <- modName;
			}
			broData.RequiredMods = requiredMods;
		}

		local data = ::MSU.Class.SerializationData();
		local out = data.getSerializationEmulator();
		::ModPersistentCharacters.writeHeader(out);
		broData.onSerialize(out);
		::ModPersistentCharacters.Mod.PersistentData.createFile(filename, data);
		return null;
	}

	// Returns the PersistentBroData stored in the file or null if the file is invalid
	function readExportFile( _filename )
	{
		if (!::ModPersistentCharacters.Mod.PersistentData.hasFile(_filename))
			return null;

		try
		{
			local data = ::ModPersistentCharacters.Mod.PersistentData.readFile(_filename);
			local inp = data.getDeserializationEmulator();
			if (!::ModPersistentCharacters.readHeader(inp))
				return null;

			local broData = ::ModPersistentCharacters.Class.PersistentBroData();
			broData.onDeserialize(inp);
			return broData;
		}
		catch (error)
		{
			::logError(::ModPersistentCharacters.Name + ": failed to read file " + _filename + ": " + error);
			return null;
		}
	}

	// Returns an array of tables with information about each file in the savegames folder which may be imported
	function getImportFiles()
	{
		local ret = [];
		foreach (filename in ::ModPersistentCharacters.Mod.PersistentData.getFiles())
		{
			if (filename == ::ModPersistentCharacters.Filename || filename == ::ModPersistentCharacters.BackupFilename)
				continue;

			local broData = this.readExportFile(filename);
			if (broData == null)
			{
				ret.push({
					Filename = filename,
					Name = filename,
					Level = 0,
					Error = "Exported by an incompatible version of the mod"
				});
				continue;
			}

			local reason = this.getCannotImportFileReason(broData);
			ret.push({
				Filename = filename,
				Name = broData.getName(),
				Level = broData.getLevel(),
				Info = this.getExportFileInfo(broData),
				MissingMods = broData.getMissingMods(),
				Error = reason
			});
		}
		return ret;
	}

	// Returns an array of { icon, text } describing the persistence data of the bro in an export file
	function getExportFileInfo( _broData )
	{
		if (_broData.getUID() == null)
			return [{ icon = "ui/icons/special.png", text = "Exported without persistence data" }];

		local hasHome = _broData.getHomeName() != "";
		return [
			{
				icon = hasHome ? "ui/banners/" + _broData.getHomeBanner() + "s.png" : "ui/icons/special.png",
				text = "Home company: " + (hasHome ? _broData.getHomeName() : "Forgotten Company")
			},
			{ icon = "ui/icons/days_wounded.png", text = _broData.getServiceSummary() }
		];
	}

	function getCannotImportFileReason( _broData )
	{
		if (!_broData.isLoadable())
			return "Missing required mods";

		if (::World.getPlayerRoster().getSize() >= ::World.Assets.getBrothersMax())
			return "Your roster is full";

		if (this.findInPlayerRoster(_broData.getUID()) != null)
			return "Already in your company";

		if (_broData.getUID() != null && ::ModPersistentCharacters.hasBlockedBro(_broData.getUID()))
			return "Already present in this campaign e.g. as a recruit in a settlement";

		return null;
	}

	function importFile( _filename )
	{
		local broData = this.readExportFile(_filename);
		if (broData == null)
			return "Invalid file or exported by an incompatible version of the mod";

		local reason = this.getCannotImportFileReason(broData);
		if (reason != null)
			return reason;

		// Bros exported with persistence data who are not known yet are added to the persistent data
		local dataManager = ::ModPersistentCharacters.getDataManager();
		if (broData.getUID() != null && !dataManager.hasBro(broData.getUID()))
		{
			dataManager.addBroData(broData);
			::ModPersistentCharacters.writeToFile();
		}

		broData.createBro(::World.getPlayerRoster()).onHired();
		return null;
	}

	function deleteFile( _filename )
	{
		if (_filename == ::ModPersistentCharacters.Filename)
			return "Cannot delete the main data file from here";

		::ModPersistentCharacters.Mod.PersistentData.deleteFile(_filename);
		return null;
	}
};
