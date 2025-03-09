::ModPersistentCharacters.Class.SpriteData <- class
{
	Data = null;

	constructor( _sprite = null )
	{
		this.Data = {};

		if (_sprite != null)
		{
			this.setupDataFromSprite(_sprite);
		}
	}

	function setupSprite( _sprite )
	{
		foreach (k, v in this.Data)
		{
			switch (k)
			{
				case "Color":
				case "Highlight":
					local color = ::createColor("#ffffff");
					foreach (k2, v2 in v)
					{
						color[k2] = v2;
					}
					_sprite[k] = color;
					break;

				case "Brush":
					if (v != null)
						_sprite.setBrush(v);
					break;

				default:
					_sprite[k] = v;
			}
		}
	}

	function setupDataFromSprite( _sprite )
	{
		this.Data = {
			Brush = _sprite.HasBrush ? _sprite.getBrush().Name : null
		};

		foreach (k, _ in _sprite.__setTable)
		{
			switch (k)
			{
				case "Color":
				case "Highlight":
					local t = {};
					foreach (k2, _ in _sprite[k].__setTable)
					{
						t[k2] <- _sprite[k][k2];
					}
					this.Data[k] <- t;
					break;

				default:
					this.Data[k] <- _sprite[k];
			}
		}
	}

	function onSerialize( _out )
	{
		::MSU.Serialization.serialize(this.Data, _out);
	}

	function onDeserialize( _in )
	{
		this.Data = ::MSU.Serialization.deserialize(_in);
	}
}
