::ModPersistentCharacters.MH.hookTree("scripts/skills/backgrounds/character_background", function(q) {
	q.getGenericTooltip = @(__original) function()
	{
		local ret = __original();
		local actor = this.getContainer().getActor();
		if (actor.ModPersistentCharacters_getUID() != null)
		{
			ret.push(::ModPersistentCharacters.getPersistentCharacterTooltip(actor));
		}
		return ret;
	}

	q.adjustHiringCostBasedOnEquipment = @(__original) function()
	{
		__original();

		if (this.getContainer().getActor().ModPersistentCharacters_getUID() != null)
		{
			local actor = this.getContainer().getActor();
			actor.m.HiringCost = ::Math.ceil(actor.m.HiringCost * ::ModPersistentCharacters.Mod.ModSettings.getSetting("CostMult_Hire").getValue() * 0.1) * 10;
		}
	}

	q.onUpdate = @(__original) function( _properties )
	{
		__original(_properties);

		if (this.getContainer().getActor().ModPersistentCharacters_getUID() != null)
		{
			_properties.DailyWageMult *= ::ModPersistentCharacters.Mod.ModSettings.getSetting("CostMult_Wage").getValue();
		}
	}
});
