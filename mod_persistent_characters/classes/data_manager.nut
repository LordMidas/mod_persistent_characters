::ModPersistentCharacters.Class.DataManager <- class
{
	Campaigns = null;
	CampaignsArray = null;
	Bros = null;
	BrosArray = null;

	constructor()
	{
		this.Campaigns = {};
		this.CampaignsArray = [];
		this.Bros = {};
		this.BrosArray = [];
	}

	function hasCampaign( _uid )
	{
		return _uid in this.Campaigns;
	}

	function getCampaign( _uid )
	{
		if (this.hasCampaign(_uid))
			return this.Campaigns[_uid];
	}

	function hasBro( _uid )
	{
		return _uid in this.Bros;
	}

	function getBro( _uid )
	{
		if (this.hasBro(_uid))
			return this.Bros[_uid];
	}

	function addBro( _bro )
	{
		local broData = ::ModPersistentCharacters.Class.PersistentBroData(_bro);
		this.Bros[broData.getUID()] <- broData;
		this.BrosArray.push(broData);
	}

	function removeBro( _uid )
	{
		return ::MSU.Array.removeByValue(this.BrosArray, delete this.Bros[_uid]);
	}

	function removeCampaign( _uid )
	{
		// TODO: Currently we remove all bros of a campaign when a campaign is removed. This can be changed later.
		// Once we have a proper UI setup and the ability to put such bros under "Loose bros" in that, we can revert this
		foreach (broUID in this.getCampaign(_uid).getBroUIDs())
		{
			this.removeBro(broUID);
		}

		return ::MSU.Array.removeByValue(this.BrosArray, delete this.Campaigns[_uid]);
	}

	function getCampaigns()
	{
		return this.CampaignsArray;
	}

	function getBros()
	{
		return this.BrosArray;
	}

	function getRandomCampaign( _filterFunc = null )
	{
		return ::MSU.Array.rand(_filterFunc == null ? this.CampaignsArray : this.CampaignsArray.filter(@(_, _c) _filterFunc(_c)));
	}

	function getRandomBro( _filterFunc = null )
	{
		return ::MSU.Array.rand(_filterFunc == null ? this.BrosArray : this.BrosArray.filter(@(_, _c) _filterFunc(_c)));
	}

	function addNewCampaign( _uid = null )
	{
		if (_uid == null)
			_uid = ::ModPersistentCharacters.generateUID();

		local ret = ::ModPersistentCharacters.Class.CampaignData(_uid);
		this.Campaigns[_uid] <- ret;
		this.CampaignsArray.push(ret);

		local maxCampaigns = ::ModPersistentCharacters.Mod.ModSettings.getSetting("MaxSavedCampaigns").getValue();
		while (this.Campaigns.len() > maxCampaigns)
		{
			this.removeCampaign(this.CampaignsArray[0].getUID());
		}

		return ret;
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
		local campaignUID = ::ModPersistentCharacters.getCampaignUID();
		local campaign = this.getCampaign(campaignUID);
		if (campaign == null)
		{
			campaign = this.addNewCampaign(campaignUID);
			if (campaignUID == null)
			{
				::ModPersistentCharacters.setCampaignUID(campaign.getUID());
			}
			campaignUID = campaign.getUID();
		}

		local minLevelToSave = ::ModPersistentCharacters.Mod.ModSettings.getSetting("MinLevelToSave").getValue();
		local brosToKeep = [];

		foreach (bro in ::World.getPlayerRoster().getAll())
		{
			local broUID = bro.ModPersistentCharacters_getUID();
			if (this.hasBro(broUID))
			{
				this.getBro(broUID).update(bro);
			}

			if (bro.getLevel() < minLevelToSave)
				continue;

			if (broUID == null)
			{
				broUID = ::ModPersistentCharacters.generateUID();
				bro.ModPersistentCharacters_setUID(broUID);
				bro.ModPersistentCharacters_setCampaignUID(campaignUID);
				campaign.addBro(broUID);
			}

			if (!this.hasBro(broUID))
			{
				this.addBro(bro);
				if (!campaign.hasBro(broUID))
					campaign.addBro(broUID);
			}

			if (bro.ModPersistentCharacters_getCampaignUID() == campaignUID)
			{
				brosToKeep.push(broUID);
			}

			::ModPersistentCharacters.addBlockedBro(broUID);
		}

		// campaign.BroUIDs = campaign.BroUIDs.filter(@(_, _uid) brosToKeep.find(_uid) != null);

		// TODO: This is temporary. We remove bros OF THIS CAMPAIGN from our data if they have expired from this campaign
		// Once we have a proper UI setup and the ability to put such bros under "Loose bros" in that, we can revert this
		local campaignBros = campaign.getBroUIDs();
		for (local i = campaignBros.len() - 1; i >= 0; i--)
		{
			if (brosToKeep.find(campaignBros[i]) == null)
			{
				this.removeBro(campaignBros.remove(i));
			}
		}
	}

	function onSerialize( _out )
	{
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

	function onDeserialize( _in )
	{
		local len = _in.readU32();
		this.CampaignsArray = array(len);
		for (local i = 0; i < len; i++)
		{
			local c = ::ModPersistentCharacters.Class.CampaignData();
			c.onDeserialize(_in);
			this.CampaignsArray[i] = c;
			this.Campaigns[c.getUID()] <- c;
		}

		len = _in.readU32();
		this.BrosArray = array(len);
		for (local i = 0; i < len; i++)
		{
			local b = ::ModPersistentCharacters.Class.PersistentBroData();
			b.onDeserialize(_in);
			this.BrosArray[i] = b;
			this.Bros[b.getUID()] <- b;
		}
	}
}
