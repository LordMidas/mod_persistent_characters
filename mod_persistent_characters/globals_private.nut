::MSU.Table.merge(::ModPersistentCharacters, {
	Filename = "Data",
	BackupFilename = "DataBackup",
	// Every file written by this mod starts with this header so that files from incompatible versions can be detected
	FileMagic = "ModPersistentCharacters",
	FormatVersion = 2,
	LooseCampaignUID = "__loose__",
	FlagID = {
		BlockedBros = ::ModPersistentCharacters.ID + ".BlockedBros",
		CampaignUID = ::ModPersistentCharacters.ID + ".CampaignUID",
		BroUID = ::ModPersistentCharacters.ID + ".BroUID",
		RequiredMods = ::ModPersistentCharacters.ID + ".RequiredMods",
		SavingDisabled = ::ModPersistentCharacters.ID + ".SavingDisabled",
		LastSeenVersion = ::ModPersistentCharacters.ID + ".LastSeenVersion"
	},
	// Mods which are never offered as required
	IgnoredMods = [
		"vanilla",
		"mod_persistent_characters",
		"mod_msu",
		"mod_hooks",
		"mod_modern_hooks"
	],
	// Popularly known save-incompatible mods. These are always required when installed.
	LockedMods = [
		"dlc_unhold",
		"dlc_wildmen",
		"dlc_desert",
		"dlc_lindwurm",
		"mod_legends",
		"mod_legends_PTR",
		"mod_reforged",
		"mod_dynamic_perks"
	],
	PlayerFieldsToClean = {},
	DataManager = null,

	function getDataManager()
	{
		return this.DataManager;
	}

	function writeHeader( _out )
	{
		_out.writeString(this.FileMagic);
		_out.writeU8(this.FormatVersion);
	}

	// Returns true if the header is valid. The magic string is read first because MSU returns
	// whatever type is stored, so an old file's first value can never be equal to it.
	function readHeader( _in )
	{
		return _in.readString() == this.FileMagic && _in.readU8() == this.FormatVersion;
	}

	function writeToFile()
	{
		if (this.DataManager == null)
			return;

		local data = ::MSU.Class.SerializationData();
		this.DataManager.onSerialize(data.getSerializationEmulator());
		::ModPersistentCharacters.Mod.PersistentData.createFile(this.Filename, data);
	}

	function readFromFile()
	{
		this.DataManager = ::ModPersistentCharacters.Class.DataManager();
		if (!::ModPersistentCharacters.Mod.PersistentData.hasFile(this.Filename))
			return;

		local data = null;
		try
		{
			data = ::ModPersistentCharacters.Mod.PersistentData.readFile(this.Filename);
			local dataManager = ::ModPersistentCharacters.Class.DataManager();
			if (dataManager.onDeserialize(data.getDeserializationEmulator()))
			{
				this.DataManager = dataManager;
				return;
			}
		}
		catch (error)
		{
			::logError(this.Name + ": exception while reading the data file: " + error);
		}

		// Keep a copy of the unreadable data as the data file is overwritten on the next save
		local backupInfo = "";
		if (data != null)
		{
			::ModPersistentCharacters.Mod.PersistentData.createFile(this.BackupFilename, data);
			backupInfo = " A copy was saved as " + this.BackupFilename + ".";
		}
		::logWarning(this.Name + ": the data file could not be read e.g. because it was written by an incompatible version of the mod and was ignored. It will be overwritten when you save." + backupInfo);
	}

	function deleteFile()
	{
		::ModPersistentCharacters.Mod.PersistentData.deleteFile(this.Filename);
		if (this.DataManager != null)
			this.DataManager.clear();
	}

	function hasFile()
	{
		return ::ModPersistentCharacters.Mod.PersistentData.hasFile(this.Filename);
	}

	function getCampaignUID()
	{
		if (::World.Flags.has(this.FlagID.CampaignUID))
			return ::World.Flags.get(this.FlagID.CampaignUID);
	}

	function setCampaignUID( _uid )
	{
		::World.Flags.set(this.FlagID.CampaignUID, _uid);
	}

	// Whether characters whose home is the current campaign are saved/updated. Stored per campaign.
	function isSavingEnabled()
	{
		return !::World.Flags.has(this.FlagID.SavingDisabled);
	}

	function setSavingEnabled( _enabled )
	{
		if (_enabled)
			::World.Flags.remove(this.FlagID.SavingDisabled);
		else
			::World.Flags.set(this.FlagID.SavingDisabled, true);
	}

	function hasSeenCurrentVersion()
	{
		return ::World.Flags.has(this.FlagID.LastSeenVersion) && ::World.Flags.get(this.FlagID.LastSeenVersion) == this.Version;
	}

	// Shows the info event once per campaign for each new version of the mod. It is retried until
	// an event can be fired e.g. after the scenario intro event of a new campaign.
	function showInfoEventIfNewVersion()
	{
		if (!this.hasSeenCurrentVersion())
			::Time.scheduleEvent(::TimeUnit.Real, 2000, this.__tryShowInfoEvent.bindenv(this), null);
	}

	function __tryShowInfoEvent( _tag )
	{
		local activeState = ::MSU.Utils.getActiveState();
		if (activeState == null || activeState.ClassName != "world_state" || this.hasSeenCurrentVersion())
			return;

		if (::World.Events.canFireEvent(true, true) && ::World.Events.fire("event.mod_persistent_characters_info"))
		{
			::World.Flags.set(this.FlagID.LastSeenVersion, this.Version);
			return;
		}

		::Time.scheduleEvent(::TimeUnit.Real, 2000, this.__tryShowInfoEvent.bindenv(this), null);
	}

	function hasBlockedBro( _uid )
	{
		return this.getBlockedBros().find(_uid) != null;
	}

	function getBlockedBros()
	{
		if (::World.Flags.has(this.FlagID.BlockedBros))
			return split(::World.Flags.get(this.FlagID.BlockedBros), ",");
		return [];
	}

	// each entry in _brosArray must be a stringified integer uid of bro
	function setBlockedBros( _brosArray )
	{
		if (_brosArray.len() == 0)
			::World.Flags.remove(this.FlagID.BlockedBros);
		else
			::World.Flags.set(this.FlagID.BlockedBros, _brosArray.reduce(@(_a, _b) _a + "," + _b));
	}

	function addBlockedBro( _uid )
	{
		local bros = this.getBlockedBros();
		if (bros.find(_uid) == null)
		{
			bros.push(_uid);
			this.setBlockedBros(bros);
		}
	}

	function removeBlockedBro( _uid )
	{
		local bros = this.getBlockedBros();
		if (::MSU.Array.removeByValue(bros, _uid) != null)
			this.setBlockedBros(bros);
	}

	// Required mods of the current campaign. Stored in World.Flags so that it is saved per campaign.
	function getRequiredModIDs()
	{
		local ret = ::World.Flags.has(this.FlagID.RequiredMods) ? split(::World.Flags.get(this.FlagID.RequiredMods), ",") : [];
		foreach (modID in this.LockedMods)
		{
			if (::Hooks.hasMod(modID) && ret.find(modID) == null)
				ret.push(modID);
		}
		return ret;
	}

	function setRequiredModIDs( _modIDs )
	{
		local ids = _modIDs.filter(@(_, _id) ::Hooks.hasMod(_id) && ::ModPersistentCharacters.IgnoredMods.find(_id) == null);
		::World.Flags.set(this.FlagID.RequiredMods, ids.len() == 0 ? "" : ids.reduce(@(_a, _b) _a + "," + _b));
		if (this.DataManager != null)
			this.DataManager.setDefaultRequiredMods(ids);
	}

	// Returns a table of modID -> modName of the required mods of the current campaign
	function getRequiredMods()
	{
		local ret = {};
		foreach (modID in this.getRequiredModIDs())
		{
			if (::Hooks.hasMod(modID))
				ret[modID] <- ::Hooks.getMod(modID).getName();
		}
		return ret;
	}

	// Called when a new campaign is started
	function initRequiredMods()
	{
		this.setRequiredModIDs(this.DataManager == null ? [] : this.DataManager.getDefaultRequiredMods());
	}

	// Returns an array of mods that can be marked as required in the current session
	function getSelectableMods()
	{
		local ret = [];
		foreach (mod in ::Hooks.getMods())
		{
			if (this.IgnoredMods.find(mod.getID()) == null)
				ret.push(mod);
		}
		return ret;
	}

	function isModLocked( _modID )
	{
		return this.LockedMods.find(_modID) != null;
	}

	// Returns a display name for the campaign with the given UID even if it no longer exists
	function getCampaignDisplayName( _campaignUID, _broData = null )
	{
		if (_campaignUID == this.getCampaignUID())
			return ::World.Assets.getName();

		local campaign = this.getDataManager().getCampaign(_campaignUID);
		if (campaign != null)
			return campaign.getName();

		if (_broData != null && _broData.isHome(_campaignUID) && _broData.getHomeName() != "")
			return _broData.getHomeName();

		return "Forgotten Company";
	}

	function generateUID()
	{
		local ret = ::Math.rand().tostring();
		ret += ::Math.rand().tostring();
		ret += ::Math.rand().tostring();
		return ret + ::Math.rand().tostring();
	}

	function getPersistentCharacterTooltip( _bro )
	{
		local str = "Persistent character from ";
		local bannerIcon = "ui/icons/special.png";

		local broData = this.getDataManager().getBro(_bro.ModPersistentCharacters_getUID());
		local homeUID = broData != null ? broData.getHomeCampaignUID() : _bro.ModPersistentCharacters_getCampaignUID();
		if (homeUID == this.getCampaignUID())
		{
			str += "this company";
			bannerIcon = "ui/banners/" + ::World.Assets.getBanner() + "s.png";
		}
		else if (broData != null && broData.getHomeName() != "")
		{
			str += "the " + broData.getHomeName();
			bannerIcon = "ui/banners/" + broData.getHomeBanner() + "s.png";
		}
		else
		{
			str += "a forgotten company";
		}

		if (broData != null)
		{
			local numCompanies = broData.getLifetimeStats().len();
			if (homeUID != this.getCampaignUID() || numCompanies > 1)
			{
				local stats = broData.getLifetimeStatsTotal();
				str += format(" who has served in %i companies for %i days, taking part in %i battles and making %i kills", numCompanies, stats.Days, stats.Battles, stats.Kills);
			}
			else
			{
				str += " who has not served in any other company so far";
			}
		}

		return {
			id = 100,
			type = "hint",
			icon = bannerIcon,
			text = str
		};
	}
});
