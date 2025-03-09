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
});
