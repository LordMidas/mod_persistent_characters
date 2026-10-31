::ModPersistentCharacters.Class.PersistentBroData <- class extends ::ModPersistentCharacters.Class.BroData
{
	UID = null;
	// UID of the home campaign of this bro. Only the home campaign refreshes his snapshot.
	// In other campaigns he is "on loan" and those campaigns only add to his lifetime stats.
	CampaignUID = null;
	Name = null;
	Level = 1;
	// modID -> modName of the mods which were required when the snapshot was captured
	RequiredMods = null;
	// Information about the home campaign so that it is available even after the campaign is removed
	HomeName = "";
	HomeBanner = "";
	HomeRenown = 0;
	// campaignUID -> LifetimeStats
	LifetimeStats = null;

	constructor( _bro = null )
	{
		this.RequiredMods = {};
		this.LifetimeStats = {};

		if (::MSU.isNull(_bro))
		{
			base.constructor(_bro);
			return;
		}

		if (_bro instanceof ::WeakTableRef)
			_bro = _bro.get();

		this.UID = _bro.ModPersistentCharacters_getUID();
		this.CampaignUID = _bro.ModPersistentCharacters_getCampaignUID();
		base.constructor(_bro);
	}

	function capture( _bro )
	{
		this.Name = _bro.getName();
		this.Level = _bro.getLevel();
		this.RequiredMods = ::ModPersistentCharacters.getRequiredMods();

		local backup = {};
		foreach (k, v in ::ModPersistentCharacters.PlayerFieldsToClean)
		{
			backup[k] <- _bro.m[k];
			_bro.m[k] = v;
		}

		local skills = this.getSkillsToPrevent(_bro);
		foreach (s in skills)
		{
			s.m.IsSerialized = false;
		}

		base.capture(_bro);

		foreach (s in skills)
		{
			s.m.IsSerialized = true;
		}

		foreach (k, v in backup)
		{
			_bro.m[k] = v;
		}
	}

	function setHomeInfo( _campaignData )
	{
		this.HomeName = _campaignData.getName();
		this.HomeBanner = _campaignData.getBanner();
		this.HomeRenown = _campaignData.getBusinessReputation();
	}

	// Called during saving of the current campaign for a bro who is in its roster
	function update( _bro )
	{
		local currentCampaignUID = ::ModPersistentCharacters.getCampaignUID();
		if (this.isHome(currentCampaignUID))
		{
			this.capture(_bro);
		}
		this.updateLifetimeStats(_bro, currentCampaignUID);
	}

	function getSkillsToPrevent( _bro )
	{
		return _bro.getSkills().getSkillsByFunction(function(_s) {
			if (_s.isType(::Const.SkillType.PermanentInjury))
				return false;

			return _s.isType(::Const.SkillType.Injury) || _s.getID() == "trait.player" || _s.getID().find("oath_of") != null;
		});
	}

	function updateLifetimeStats( _bro, _campaignUID )
	{
		local stats = ::ModPersistentCharacters.Class.LifetimeStats(_bro);
		this.LifetimeStats[_campaignUID] <- stats;
		return stats;
	}

	function getUID()
	{
		return this.UID;
	}

	function getCampaignUID()
	{
		return this.CampaignUID;
	}

	function getHomeCampaignUID()
	{
		return this.CampaignUID;
	}

	function setHomeCampaignUID( _uid )
	{
		this.CampaignUID = _uid;
	}

	function isHome( _campaignUID )
	{
		return _campaignUID != null && this.CampaignUID == _campaignUID;
	}

	function getHomeName()
	{
		return this.HomeName;
	}

	function getHomeBanner()
	{
		return this.HomeBanner;
	}

	function getHomeRenown()
	{
		return this.HomeRenown;
	}

	function getName()
	{
		return this.Name;
	}

	function getLevel()
	{
		return this.Level;
	}

	function getRequiredMods()
	{
		return this.RequiredMods;
	}

	// Returns an array of { ID, Name } of required mods which are not installed
	function getMissingMods()
	{
		local ret = [];
		foreach (modID, modName in this.RequiredMods)
		{
			if (!::Hooks.hasMod(modID))
				ret.push({ ID = modID, Name = modName });
		}
		return ret;
	}

	function isLoadable()
	{
		foreach (modID, _ in this.RequiredMods)
		{
			if (!::Hooks.hasMod(modID))
				return false;
		}
		return true;
	}

	function getLifetimeStats( _campaignUID = null )
	{
		if (_campaignUID == null)
		{
			return this.LifetimeStats;
		}

		return _campaignUID in this.LifetimeStats ? this.LifetimeStats[_campaignUID] : null;
	}

	function getLifetimeStatsTotal()
	{
		local ret = {
			Kills = 0,
			Battles = 0,
			Days = 0,
			Deaths = 0,
			PermanentInjuries = []
		};

		foreach (stats in this.LifetimeStats)
		{
			ret.Kills += stats.getKills();
			ret.Battles += stats.getBattles();
			ret.Days += stats.getDays();
			if (stats.isDead())
				ret.Deaths++;
			ret.PermanentInjuries.extend(stats.getPermanentInjuries());
		}
		ret.PermanentInjuries = ::MSU.Array.uniques(ret.PermanentInjuries);

		return ret;
	}

	// Returns a sentence summarizing the lifetime stats across all campaigns
	function getServiceSummary()
	{
		local stats = this.getLifetimeStatsTotal();
		local numCompanies = this.LifetimeStats.len();
		local ret = format("Has served in %i %s for %i days, taking part in %i battles and making %i kills", numCompanies, numCompanies == 1 ? "company" : "companies", stats.Days, stats.Battles, stats.Kills);
		if (stats.Deaths > 0)
			ret += ". " + ::MSU.Text.colorNegative(format("Died in %i %s", stats.Deaths, stats.Deaths == 1 ? "company" : "companies"));
		return ret;
	}

	// Returns null if the bro can spawn, otherwise a string with the reason
	function getCannotSpawnReason()
	{
		if (!this.isLoadable())
			return "Missing required mods";

		if (this.getLevel() < ::ModPersistentCharacters.Mod.ModSettings.getSetting("MinLevelToSpawn").getValue())
			return "Below the minimum level to spawn";

		if (::ModPersistentCharacters.hasBlockedBro(this.getUID()))
			return "Already present in this campaign";

		if (::ModPersistentCharacters.Mod.ModSettings.getSetting("SpawnWithPermanentInjuries").getValue() == "Disallowed" && this.hasPermanentInjury())
			return "Has a permanent injury and spawning with permanent injuries is disallowed";

		if (::ModPersistentCharacters.Mod.ModSettings.getSetting("PermaDeath").getValue() && this.getLifetimeStatsTotal().Deaths > 0)
			return "Has died and Perma Death is enabled";

		return null;
	}

	function canSpawn()
	{
		return this.getCannotSpawnReason() == null;
	}

	function hasPermanentInjury()
	{
		foreach (stats in this.LifetimeStats)
		{
			if (stats.getPermanentInjuries().len() != 0)
				return true;
		}
		return false;
	}

	// If _applySpawnSettings is false, the bro is created as he was saved e.g. for previewing him
	function createBro( _roster = null, _applySpawnSettings = true )
	{
		return this.cleanUpCreatedBro(base.createBro(_roster), _applySpawnSettings);
	}

	function cleanUpCreatedBro( _bro, _applySpawnSettings = true )
	{
		_bro.getFlags().remove("IsPlayerCharacter");

		switch (_applySpawnSettings ? ::ModPersistentCharacters.Mod.ModSettings.getSetting("SpawnWithPermanentInjuries").getValue() : null)
		{
			case "None":
				_bro.getSkills().removeByType(::Const.SkillType.PermanentInjury);
				break;

			case "All":
				foreach (classNameHash in this.getLifetimeStatsTotal().PermanentInjuries)
				{
					local inj = ::new(::IO.scriptFilenameByHash(classNameHash));
					if (!_bro.getSkills().hasSkill(inj.getID()))
					{
						_bro.getSkills().add(inj);
					}
				}
				break;
		}

		_bro.setHitpoints(_bro.getHitpointsMax());
		foreach (item in _bro.getItems().getAllItems())
		{
			item.setCondition(item.getConditionMax());
		}

		_bro.getSkills().update();

		return _bro;
	}

	function onSerialize( _out )
	{
		base.onSerialize(_out);
		// UIDs are null for bros exported without persistence data
		_out.writeString(this.UID == null ? "" : this.UID);
		_out.writeString(this.CampaignUID == null ? "" : this.CampaignUID);
		_out.writeString(this.Name);
		_out.writeU8(this.Level);
		::MSU.Serialization.serialize(this.RequiredMods, _out);
		_out.writeString(this.HomeName);
		_out.writeString(this.HomeBanner);
		_out.writeI32(this.HomeRenown);

		_out.writeU32(this.LifetimeStats.len());
		foreach (campaignUID, stats in this.LifetimeStats)
		{
			_out.writeString(campaignUID);
			stats.onSerialize(_out);
		}
	}

	function onDeserialize( _in )
	{
		base.onDeserialize(_in);
		this.UID = _in.readString();
		if (this.UID == "") this.UID = null;
		this.CampaignUID = _in.readString();
		if (this.CampaignUID == "") this.CampaignUID = null;
		this.Name = _in.readString();
		this.Level = _in.readU8();
		this.RequiredMods = ::MSU.Serialization.deserialize(_in);
		this.HomeName = _in.readString();
		this.HomeBanner = _in.readString();
		this.HomeRenown = _in.readI32();

		this.LifetimeStats = {};
		local len = _in.readU32();
		for (local i = 0; i < len; i++)
		{
			local campaignUID = _in.readString();
			local stats = ::ModPersistentCharacters.Class.LifetimeStats();
			stats.onDeserialize(_in);
			this.LifetimeStats[campaignUID] <- stats;
		}
	}
}
