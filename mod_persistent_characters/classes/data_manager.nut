::ModPersistentCharacters.Class.DataManager <- class
{
	Campaigns = null;
	CampaignsArray = null;
	Bros = null;
	BrosArray = null;
	// IDs of the mods which were last chosen as required. Used as the default for new campaigns.
	DefaultRequiredMods = null;

	constructor()
	{
		this.Campaigns = {};
		this.CampaignsArray = [];
		this.Bros = {};
		this.BrosArray = [];
		this.DefaultRequiredMods = [];
	}

	function hasCampaign( _uid )
	{
		return _uid != null && _uid in this.Campaigns;
	}

	function getCampaign( _uid )
	{
		if (this.hasCampaign(_uid))
			return this.Campaigns[_uid];
	}

	function hasBro( _uid )
	{
		return _uid != null && _uid in this.Bros;
	}

	function getBro( _uid )
	{
		if (this.hasBro(_uid))
			return this.Bros[_uid];
	}

	function getDefaultRequiredMods()
	{
		return this.DefaultRequiredMods;
	}

	function setDefaultRequiredMods( _modIDs )
	{
		this.DefaultRequiredMods = clone _modIDs;
	}

	// Creates persistent data for _bro and adds it to its home campaign (if it exists)
	function addBro( _bro )
	{
		return this.addBroData(::ModPersistentCharacters.Class.PersistentBroData(_bro));
	}

	function addBroData( _broData )
	{
		this.Bros[_broData.getUID()] <- _broData;
		this.BrosArray.push(_broData);

		local home = this.getCampaign(_broData.getHomeCampaignUID());
		if (home != null)
		{
			home.addBro(_broData.getUID());
			_broData.setHomeInfo(home);
		}

		return _broData;
	}

	function removeBro( _uid )
	{
		local broData = this.getBro(_uid);
		if (broData == null)
			return null;

		local home = this.getCampaign(broData.getHomeCampaignUID());
		if (home != null)
			home.removeBro(_uid);

		local ret = this.__unregisterBro(_uid);
		this.removeEmptyCampaigns();
		return ret;
	}

	function __unregisterBro( _uid )
	{
		if (!this.hasBro(_uid))
			return null;

		return ::MSU.Array.removeByValue(this.BrosArray, delete this.Bros[_uid]);
	}

	// The bros of the removed campaign become loose bros unless _deleteBros is true
	function removeCampaign( _uid, _deleteBros = false )
	{
		if (!this.hasCampaign(_uid))
			return null;

		if (_deleteBros)
		{
			foreach (broData in this.BrosArray.filter(@(_, _b) _b.isHome(_uid)))
			{
				this.__unregisterBro(broData.getUID());
			}
		}

		local ret = ::MSU.Array.removeByValue(this.CampaignsArray, delete this.Campaigns[_uid]);
		this.pruneLooseBros();
		return ret;
	}

	// Campaigns without bros e.g. after all of them were claimed via Make Home are of no use.
	// The current campaign is kept as it is recreated anyway on the next save.
	function removeEmptyCampaigns()
	{
		local currentCampaignUID = ::ModPersistentCharacters.getCampaignUID();
		for (local i = this.CampaignsArray.len() - 1; i >= 0; i--)
		{
			local campaign = this.CampaignsArray[i];
			if (campaign.getBroUIDs().len() == 0 && campaign.getUID() != currentCampaignUID)
			{
				this.CampaignsArray.remove(i);
				delete this.Campaigns[campaign.getUID()];
			}
		}
	}

	function getCampaigns()
	{
		return this.CampaignsArray;
	}

	function getBros()
	{
		return this.BrosArray;
	}

	// Bros whose home campaign no longer exists. Ordered from oldest to newest.
	function getLooseBros()
	{
		local campaigns = this.Campaigns;
		return this.BrosArray.filter(@(_, _b) _b.getHomeCampaignUID() == null || !(_b.getHomeCampaignUID() in campaigns));
	}

	function removeLooseBros()
	{
		foreach (broData in this.getLooseBros())
		{
			this.__unregisterBro(broData.getUID());
		}
	}

	function pruneLooseBros()
	{
		local looseBros = this.getLooseBros();
		local max = ::ModPersistentCharacters.Mod.ModSettings.getSetting("MaxLooseBros").getValue();
		for (local i = 0; i < looseBros.len() - max; i++)
		{
			this.__unregisterBro(looseBros[i].getUID());
		}
	}

	// Picks a random bro who can spawn in the current campaign. First a pool is chosen uniformly from
	// the eligible campaigns and the loose bros, then a bro is chosen from that pool.
	function getRandomSpawnableBro()
	{
		local currentCampaignUID = ::ModPersistentCharacters.getCampaignUID();
		local renownThreshold = ::World.Assets.getBusinessReputation() / (::ModPersistentCharacters.Mod.ModSettings.getSetting("RequiredRenown").getValue() * 0.01);

		local pools = [];
		foreach (campaign in this.CampaignsArray)
		{
			if (campaign.getUID() == currentCampaignUID || campaign.getBusinessReputation() > renownThreshold || !campaign.isLoadable())
				continue;

			local bros = campaign.getBros().filter(@(_, _b) _b.canSpawn());
			if (bros.len() != 0)
				pools.push(bros);
		}

		local looseBros = this.getLooseBros().filter(@(_, _b) !_b.isHome(currentCampaignUID) && _b.getHomeRenown() <= renownThreshold && _b.canSpawn());
		if (looseBros.len() != 0)
			pools.push(looseBros);

		local pool = ::MSU.Array.rand(pools);
		return pool == null ? null : ::MSU.Array.rand(pool);
	}

	function addNewCampaign( _uid = null )
	{
		if (_uid == null)
			_uid = ::ModPersistentCharacters.generateUID();

		local ret = ::ModPersistentCharacters.Class.CampaignData(_uid);
		this.Campaigns[_uid] <- ret;
		this.CampaignsArray.push(ret);

		// When a campaign whose data was removed is saved again, its former (loose) bros belong to it again
		foreach (broData in this.BrosArray)
		{
			if (broData.isHome(_uid))
			{
				ret.addBro(broData.getUID());
				broData.setHomeInfo(ret);
			}
		}

		local maxCampaigns = ::ModPersistentCharacters.Mod.ModSettings.getSetting("MaxSavedCampaigns").getValue();
		while (this.CampaignsArray.len() > maxCampaigns)
		{
			this.removeCampaign(this.CampaignsArray[0].getUID());
		}

		return ret;
	}

	// Returns the data of the current campaign, creating it if necessary
	function getOrCreateCurrentCampaign()
	{
		local campaignUID = ::ModPersistentCharacters.getCampaignUID();
		local campaign = this.getCampaign(campaignUID);
		if (campaign == null)
		{
			campaign = this.addNewCampaign(campaignUID);
			if (campaignUID == null)
				::ModPersistentCharacters.setCampaignUID(campaign.getUID());
		}
		else
		{
			campaign.refresh();
		}
		return campaign;
	}

	// Makes the current campaign the home campaign of _bro who must be in the player roster
	function makeHome( _bro )
	{
		local broData = this.getBro(_bro.ModPersistentCharacters_getUID());
		if (broData == null)
			return;

		local campaign = this.getOrCreateCurrentCampaign();
		local oldHome = this.getCampaign(broData.getHomeCampaignUID());
		if (oldHome != null)
			oldHome.removeBro(broData.getUID());

		broData.setHomeCampaignUID(campaign.getUID());
		_bro.ModPersistentCharacters_setCampaignUID(campaign.getUID());
		campaign.addBro(broData.getUID());
		broData.setHomeInfo(campaign);
		broData.update(_bro);
		this.removeEmptyCampaigns();
	}

	function clear()
	{
		this.Campaigns.clear();
		this.CampaignsArray.clear();
		this.Bros.clear();
		this.BrosArray.clear();
	}

	// Called from world_state.saveCampaign
	function onSaveCampaign()
	{
		if (!::ModPersistentCharacters.isSavingEnabled())
		{
			this.onSaveCampaignWithSavingDisabled();
			return;
		}

		local campaign = this.getOrCreateCurrentCampaign();
		local campaignUID = campaign.getUID();
		local minLevelToSave = ::ModPersistentCharacters.Mod.ModSettings.getSetting("MinLevelToSave").getValue();
		local brosToKeep = [];

		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			local broUID = bro.ModPersistentCharacters_getUID();
			local broData = this.getBro(broUID);

			if (broData == null)
			{
				if (bro.getLevel() < minLevelToSave)
					continue;

				// Bros who have a UID but no data e.g. after the data file was deleted keep their home campaign
				if (broUID == null)
				{
					broUID = ::ModPersistentCharacters.generateUID();
					bro.ModPersistentCharacters_setUID(broUID);
					bro.ModPersistentCharacters_setCampaignUID(campaignUID);
				}

				broData = this.addBro(bro);
				broData.updateLifetimeStats(bro, campaignUID);
			}
			else
			{
				broData.update(bro);
			}

			if (broData.isHome(campaignUID))
			{
				campaign.addBro(broUID);
				broData.setHomeInfo(campaign);
				brosToKeep.push(broUID);
			}

			::ModPersistentCharacters.addBlockedBro(broUID);
		}

		// Bros of this campaign who are no longer in its roster e.g. dismissed or dead are removed
		local campaignBros = campaign.getBroUIDs();
		for (local i = campaignBros.len() - 1; i >= 0; i--)
		{
			if (brosToKeep.find(campaignBros[i]) == null)
			{
				this.__unregisterBro(campaignBros.remove(i));
			}
		}

		this.removeEmptyCampaigns();
		this.pruneLooseBros();
	}

	// Only bros from other campaigns serving in this campaign get their lifetime stats updated
	function onSaveCampaignWithSavingDisabled()
	{
		local campaignUID = ::ModPersistentCharacters.getCampaignUID();
		if (campaignUID == null)
		{
			campaignUID = ::ModPersistentCharacters.generateUID();
			::ModPersistentCharacters.setCampaignUID(campaignUID);
		}

		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			local broData = this.getBro(bro.ModPersistentCharacters_getUID());
			if (broData == null || broData.isHome(campaignUID))
				continue;

			broData.update(bro);
			::ModPersistentCharacters.addBlockedBro(broData.getUID());
		}
	}

	function onSerialize( _out )
	{
		::ModPersistentCharacters.writeHeader(_out);
		::MSU.Serialization.serialize(this.DefaultRequiredMods, _out);

		_out.writeU32(this.CampaignsArray.len());
		foreach (campaignData in this.CampaignsArray)
		{
			campaignData.onSerialize(_out);
		}

		_out.writeU32(this.BrosArray.len());
		foreach (broData in this.BrosArray)
		{
			broData.onSerialize(_out);
		}
	}

	// Returns false if the data was written by an incompatible version
	function onDeserialize( _in )
	{
		if (!::ModPersistentCharacters.readHeader(_in))
			return false;

		this.DefaultRequiredMods = ::MSU.Serialization.deserialize(_in);

		local len = _in.readU32();
		for (local i = 0; i < len; i++)
		{
			local c = ::ModPersistentCharacters.Class.CampaignData();
			c.onDeserialize(_in);
			this.CampaignsArray.push(c);
			this.Campaigns[c.getUID()] <- c;
		}

		len = _in.readU32();
		for (local i = 0; i < len; i++)
		{
			local b = ::ModPersistentCharacters.Class.PersistentBroData();
			b.onDeserialize(_in);
			this.BrosArray.push(b);
			this.Bros[b.getUID()] <- b;
		}

		return true;
	}
}
