::ModPersistentCharacters.Class.BroData <- class
{
	static Sprites = ["head", "body", "hair", "beard", "beard_top", "injury_body", "tattoo_body", "tattoo_head", "scar_body", "scar_head", "socket", "miniboss"];

	Script = null;
	SerData = null;
	SpriteData = null;

	constructor( _bro = null )
	{
		if (!::MSU.isNull(_bro))
		{
			this.capture(_bro instanceof ::WeakTableRef ? _bro.get() : _bro);
		}
	}

	// Takes a snapshot of the bro which is used to recreate him via createBro
	function capture( _bro )
	{
		this.Script = ::IO.scriptFilenameByHash(_bro.ClassNameHash);

		this.SerData = ::MSU.Class.SerializationData();
		_bro.onSerialize(this.SerData.getSerializationEmulator());

		this.SpriteData = {};
		foreach (spriteName in this.getSpritesToSave())
		{
			if (_bro.hasSprite(spriteName))
			{
				this.SpriteData[spriteName] <- ::ModPersistentCharacters.Class.SpriteData(_bro.getSprite(spriteName));
			}
		}
	}

	function getScript()
	{
		return this.Script;
	}

	function getSpritesToSave()
	{
		return this.Sprites;
	}

	function createBro( _roster = null )
	{
		if (_roster == null)
			_roster = ::World.getTemporaryRoster();

		local bro = _roster.create(this.Script);
		bro.onDeserialize(this.SerData.getDeserializationEmulator());

		foreach (spriteName, spriteData in this.SpriteData)
		{
			if (bro.hasSprite(spriteName))
			{
				spriteData.setupSprite(bro.getSprite(spriteName));
			}
		}

		return bro;
	}

	function onSerialize( _out )
	{
		_out.writeString(this.Script);
		::MSU.Serialization.serialize(this.SerData, _out);

		_out.writeU32(this.SpriteData.len());
		foreach (spriteName, spriteData in this.SpriteData)
		{
			_out.writeString(spriteName);
			spriteData.onSerialize(_out);
		}
	}

	function onDeserialize( _in )
	{
		this.Script = _in.readString();
		this.SerData = ::MSU.Serialization.deserialize(_in);

		local len = _in.readU32();
		this.SpriteData = {};
		for (local i = 0; i < len; i++)
		{
			local spriteName = _in.readString();
			local s = ::ModPersistentCharacters.Class.SpriteData();
			s.onDeserialize(_in);
			this.SpriteData[spriteName] <- s;
		}
	}
}
