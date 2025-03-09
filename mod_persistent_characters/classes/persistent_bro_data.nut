::ModPersistentCharacters.Class.PersistentBroData <- class extends ::ModPersistentCharacters.Class.BroData
{
	UID = null;
	CampaignUID = null;
	Name = null;
	Level = 1;
	RequiredMods = null;
	LifetimeStats = null;
	LifetimeStatsTotal = null;

	constructor( _bro = null )
	{
		if (::MSU.isNull(_bro))
		{
			base.constructor(_bro);
			return;
		}

		this.UID = _bro.ModPersistentCharacters_getUID();
		this.CampaignUID = _bro.ModPersistentCharacters_getCampaignUID();
		this.Name = _bro.getName();
		this.Level = _bro.getLevel();
		this.RequiredMods = clone ::ModPersistentCharacters.RequiredMods;
		this.LifetimeStats = {};
		this.LifetimeStatsTotal = {
			Kills = 0,
			Battles = 0,
			Days = 0,
			Deaths = 0,
			PermanentInjuries = []
		};
		this.updateLifetimeStats(_bro, this.CampaignUID);

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

		base.constructor(_bro);

		foreach (s in skills)
		{
			s.m.IsSerialized = true;
		}

		foreach (k, v in backup)
		{
			_bro.m[k] = v;
		}
	}

	function update( _bro )
	{
		this.Name = _bro.getName();
		this.Level = _bro.getLevel();
		this.RequiredMods = clone ::ModPersistentCharacters.RequiredMods;
		this.updateLifetimeStats(_bro, this.CampaignUID);
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
		local stats;
		if (_campaignUID in this.getLifetimeStats())
		{
			stats = this.getLifetimeStats(_campaignUID);
			this.LifetimeStatsTotal.Kills -= stats.Kills;
			this.LifetimeStatsTotal.Battles -= stats.Battles;
			this.LifetimeStatsTotal.Days -= stats.Days;
			this.LifetimeStatsTotal.Deaths -= stats.IsDead ? 1 : 0;
		}

		stats = ::ModPersistentCharacters.Class.LifetimeStats(_bro);
		this.LifetimeStats[_campaignUID] <- stats;
		this.LifetimeStatsTotal.Kills += stats.Kills;
		this.LifetimeStatsTotal.Battles += stats.Battles;
		this.LifetimeStatsTotal.Days += stats.Days;
		this.LifetimeStatsTotal.Deaths += stats.IsDead ? 1 : 0;

		this.LifetimeStatsTotal.PermanentInjuries.clear();
		foreach (s in this.getLifetimeStats())
		{
			this.LifetimeStatsTotal.PermanentInjuries.extend(s.getPermanentInjuries());
		}
		this.LifetimeStatsTotal.PermanentInjuries = ::MSU.Array.uniques(this.LifetimeStatsTotal.PermanentInjuries);

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
		return this.LifetimeStatsTotal;
	}

	function validateRequiredMods()
	{
		local ret = "";
		foreach (modID in this.getRequiredMods())
		{
			if (!::Hooks.hasMod(modID))
			{
				ret += modID + ", ";
			}
		}
		if (ret != "")
			return ret.slice(0, -2);
	}

	function canSpawn()
	{
		if (this.getLevel() < ::ModPersistentCharacters.Mod.ModSettings.getSetting("MinLevelToSpawn").getValue())
			return false;

		if (::ModPersistentCharacters.hasBlockedBro(this.getUID()))
			return false;

		switch (::ModPersistentCharacters.Mod.ModSettings.getSetting("SpawnWithPermanentInjuries").getValue())
		{
			case "Original":
				if (this.getLifetimeStats(this.getCampaignUID()) != null && this.getLifetimeStats(this.getCampaignUID()).getPermanentInjuries().len() != 0)
					return false;

			case "Disallowed":
				if (this.hasPermanentInjury())
					return false;
		}

		if (::ModPersistentCharacters.Mod.ModSettings.getSetting("PermaDeath").getValue() && this.getLifetimeStatsTotal().Deaths > 0)
			return false;

		if (this.validateRequiredMods() != null)
			return false;

		return true;
	}

	function hasPermanentInjury()
	{
		return this.LifetimeStatsTotal.PermanentInjuries.len() != 0;
	}

	function createBro( _roster = null )
	{
		return this.cleanUpCreatedBro(base.createBro(_roster));
	}

	function cleanUpCreatedBro( _bro )
	{
		_bro.getFlags().remove("IsPlayerCharacter");

		switch (::ModPersistentCharacters.Mod.ModSettings.getSetting("SpawnWithPermanentInjuries").getValue())
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

		return _bro;
	}

	function onSerialize( _out )
	{
		base.onSerialize(_out);
		_out.writeString(this.UID);
		_out.writeString(this.CampaignUID);
		_out.writeString(this.Name);
		_out.writeU8(this.Level);
		::MSU.Serialization.serialize(this.RequiredMods, _out);

		_out.writeU32(this.LifetimeStats.len());
		foreach (campaignUID, stats in this.LifetimeStats)
		{
			stats.onSerialize(_out);
			_out.writeString(campaignUID);
		}

		::MSU.Serialization.serialize(this.LifetimeStatsTotal, _out);
	}

	function onDeserialize( _in )
	{
		base.onDeserialize(_in)
		this.UID = _in.readString();
		this.CampaignUID = _in.readString();
		this.Name = _in.readString();
		this.Level = _in.readU8();
		this.RequiredMods = ::MSU.Serialization.deserialize(_in);

		this.LifetimeStats = {};
		local len = _in.readU32();
		for (local i = 0; i < len; i++)
		{
			local stats = ::ModPersistentCharacters.Class.LifetimeStats();
			stats.onDeserialize(_in);
			this.LifetimeStats[_in.readString()] <- stats;
		}

		this.LifetimeStatsTotal = ::MSU.Serialization.deserialize(_in);
	}
}
