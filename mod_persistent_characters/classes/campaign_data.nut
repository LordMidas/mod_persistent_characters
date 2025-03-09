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
		this.Name = ::World.Assets.getName();
		this.Banner = ::World.Assets.getBanner();
		this.BannerID = ::World.Assets.getBannerID();
		this.BusinessReputation = ::World.Assets.getBusinessReputation();
		this.BroUIDs = [];
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

	function validateRequiredMods()
	{
		if (this.BroUIDs.len() != 0)
			return ::ModPersistentCharacters.getDataManager().getBro(this.BroUIDs[0]).validateRequiredMods();
	}

	function hasUnblockedBro()
	{
		local blockedBros = ::ModPersistentCharacters.getBlockedBros();
		foreach (broData in this.BroUIDs)
		{
			if (blockedBros.find(broData.getUID()) == null)
				return true;
		}
		return false;
	}

	function hasBro( _uid )
	{
		return this.BroUIDs.find(_uid) != null;
	}

	function getBro( _uid )
	{
		foreach (uid in this.BroUIDs)
		{
			if (uid == _uid)
				return ::ModPersistentCharacters.getDataManager().getBro(uid);
		}
	}

	function getRandomBro( _filterFunc = null )
	{
		local dataManager = ::ModPersistentCharacters.getDataManager();
		local ret = ::MSU.Array.rand(_filterFunc == null ? this.BroUIDs : this.BroUIDs.filter(@(_, _uid) dataManager.hasBro(_uid) && _filterFunc(dataManager.getBro(_uid))));
		if (ret != null)
		{
			return dataManager.getBro(ret);
		}
	}

	function addBro( _uid )
	{
		this.BroUIDs.push(_uid);
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
		_out.writeU32(this.BusinessReputation);
		::MSU.Serialization.serialize(this.BroUIDs, _out);
	}

	function onDeserialize( _in )
	{
		this.UID = _in.readString();
		this.Name = _in.readString();
		this.Banner = _in.readString();
		this.BannerID = _in.readU8();
		this.BusinessReputation = _in.readU32();
		this.BroUIDs = ::MSU.Serialization.deserialize(_in);
	}
}
