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
			foreach (item in actor.getItems().getAllItems())
			{
				if (item.isItemType(::Const.Items.ItemType.Named))
				{
					actor.m.HiringCost += item.getValue() * 3;
				}
			}
			actor.getBaseProperties().DailyWageMult *= 1.5;
			actor.getCurrentProperties().DailyWageMult *= 1.5;
			actor.m.HiringCost = ::Math.ceil(actor.m.HiringCost * 2 * 0.1) * 10;
		}
	}
});
