::ModPersistentCharacters.MH.hook("scripts/entity/tactical/player", function(q) {
	q.onHired = @(__original) function()
	{
		__original();

		local myUID = this.ModPersistentCharacters_getUID();
		if (myUID != null)
		{
			::ModPersistentCharacters.addBlockedBro(myUID);
		}
	}

	q.onDeath = @(__original) function( _killer, _skill, _tile, _fatalityType )
	{
		__original(_killer, _skill, _tile, _fatalityType);

		if (_fatalityType != ::Const.FatalityType.Unconscious)
		{
			local myUID = this.ModPersistentCharacters_getUID();
			if (myUID != null && ::ModPersistentCharacters.getDataManager().hasBro(myUID))
			{
				local stats = ::ModPersistentCharacters.getDataManager().getBro(myUID).getLifetimeStats(::ModPersistentCharacters.getCampaignUID());
				if (stats != null)
				{
					stats.setDead(true);
				}
			}
		}
	}

	q.getRosterTooltip = @(__original) function()
	{
		local ret = __original();
		if (this.ModPersistentCharacters_getUID() != null)
		{
			ret.push(::ModPersistentCharacters.getPersistentCharacterTooltip(this));
		}
		return ret;
	}

	q.ModPersistentCharacters_getUID <- function()
	{
		if (this.getFlags().has(::ModPersistentCharacters.FlagID.BroUID))
			return this.getFlags().get(::ModPersistentCharacters.FlagID.BroUID);
	}

	q.ModPersistentCharacters_setUID <- function( _id )
	{
		this.getFlags().set(::ModPersistentCharacters.FlagID.BroUID, _id);
	}

	q.ModPersistentCharacters_getCampaignUID <- function()
	{
		if (this.getFlags().has(::ModPersistentCharacters.FlagID.CampaignUID))
			return this.getFlags().get(::ModPersistentCharacters.FlagID.CampaignUID);
	}

	q.ModPersistentCharacters_setCampaignUID <- function( _id )
	{
		this.getFlags().set(::ModPersistentCharacters.FlagID.CampaignUID, _id);
	}
});
