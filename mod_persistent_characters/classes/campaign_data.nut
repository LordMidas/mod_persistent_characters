::ModPersistentCharacters.Class.CampaignData <- class
{
	UID = null;
	BroUIDs = null;
	Name = null;
	Banner = null;
	BannerID = null;
	BusinessReputation = null;

	constructor( _uid = null )
	{
		this.UID = _uid;
		this.BroUIDs = [];
		if (_uid != null)
			this.refresh();
	}

	// Updates the campaign information from the currently loaded campaign
	function refresh()
	{
		this.Name = ::World.Assets.getName();
		this.Banner = ::World.Assets.getBanner();
		this.BannerID = ::World.Assets.getBannerID();
		this.BusinessReputation = ::World.Assets.getBusinessReputation();
	}

	function getUID()
	{
		return this.UID;
	}

	function getBroUIDs()
	{
		return this.BroUIDs;
	}

	function getName()
	{
		return this.Name;
	}

	function getBanner()
	{
		return this.Banner;
	}

	function getBannerID()
	{
		return this.BannerID;
	}

	function getBusinessReputation()
	{
		return this.BusinessReputation;
	}

	// Returns an array of { ID, Name } of the mods required by any bro of this campaign which are not installed.
	// All bros of a campaign share the same required mods as their snapshots are captured together.
	function getMissingMods()
	{
		local ret = [];
		local seen = {};
		local dataManager = ::ModPersistentCharacters.getDataManager();
		foreach (broUID in this.BroUIDs)
		{
			local broData = dataManager.getBro(broUID);
			if (broData == null)
				continue;

			foreach (mod in broData.getMissingMods())
			{
				if (!(mod.ID in seen))
				{
					seen[mod.ID] <- true;
					ret.push(mod);
				}
			}
		}
		return ret;
	}

	function isLoadable()
	{
		local dataManager = ::ModPersistentCharacters.getDataManager();
		foreach (broUID in this.BroUIDs)
		{
			local broData = dataManager.getBro(broUID);
			if (broData != null && !broData.isLoadable())
				return false;
		}
		return true;
	}

	function hasBro( _uid )
	{
		return this.BroUIDs.find(_uid) != null;
	}

	function getBros()
	{
		local dataManager = ::ModPersistentCharacters.getDataManager();
		local ret = [];
		foreach (uid in this.BroUIDs)
		{
			local broData = dataManager.getBro(uid);
			if (broData != null)
				ret.push(broData);
		}
		return ret;
	}

	function addBro( _uid )
	{
		if (!this.hasBro(_uid))
			this.BroUIDs.push(_uid);
	}

	function removeBro( _uid )
	{
		return ::MSU.Array.removeByValue(this.BroUIDs, _uid);
	}

	function clear()
	{
		this.BroUIDs.clear();
	}

	function onSerialize( _out )
	{
		_out.writeString(this.UID);
		_out.writeString(this.Name);
		_out.writeString(this.Banner);
		_out.writeU8(this.BannerID);
		_out.writeI32(this.BusinessReputation);
		::MSU.Serialization.serialize(this.BroUIDs, _out);
	}

	function onDeserialize( _in )
	{
		this.UID = _in.readString();
		this.Name = _in.readString();
		this.Banner = _in.readString();
		this.BannerID = _in.readU8();
		this.BusinessReputation = _in.readI32();
		this.BroUIDs = ::MSU.Serialization.deserialize(_in);
	}
}
