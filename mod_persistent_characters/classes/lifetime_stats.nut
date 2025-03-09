::ModPersistentCharacters.Class.LifetimeStats <- class
{
	Kills = 0;
	Battles = 0;
	Days = 0;
	IsDead = false;
	PermanentInjuries = null;

	constructor( _bro = null )
	{
		this.PermanentInjuries = [];

		if (!::MSU.isNull(_bro))
		{
			local stats = _bro.getLifetimeStats();
			this.Kills = stats.Kills;
			this.Battles = stats.Battles;
			this.Days = _bro.getDaysWithCompany();
			this.PermanentInjuries = _bro.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).map(@(_p) _p.ClassNameHash);
		}
	}

	function getKills()
	{
		return this.Kills;
	}

	function getBattles()
	{
		return this.Battles;
	}

	function getDays()
	{
		return this.Days;
	}

	function isDead()
	{
		return this.Isdead;
	}

	function setDead( _bool )
	{
		this.IsDead = _bool;
	}

	function getPermanentInjuries()
	{
		return this.PermanentInjuries;
	}

	function onSerialize( _out )
	{
		_out.writeU32(this.Kills);
		_out.writeU32(this.Battles);
		_out.writeU32(this.Days);
		_out.writeBool(this.IsDead);
		::MSU.Serialization.serialize(this.PermanentInjuries, _out);
	}

	function onDeserialize( _in )
	{
		this.Kills = _in.readU32();
		this.Battles = _in.readU32();
		this.Days = _in.readU32();
		this.IsDead = _in.readBool();
		this.PermanentInjuries = ::MSU.Serialization.deserialize(_in);
	}
}
