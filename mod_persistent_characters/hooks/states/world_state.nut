::ModPersistentCharacters.MH.hook("scripts/states/world_state", function(q) {
	q.saveCampaign = @(__original) function( _campaignFileName, _campaignLabel = null )
	{
		::ModPersistentCharacters.getDataManager().onSaveCampaign();
		::ModPersistentCharacters.writeToFile();
		__original(_campaignFileName, _campaignLabel);
	}

	q.loadCampaign = @(__original) function( _campaignFileName )
	{
		::ModPersistentCharacters.readFromFile();
		__original(_campaignFileName);
		// Campaigns saved before required mods were stored per campaign
		if (!::World.Flags.has(::ModPersistentCharacters.FlagID.RequiredMods))
			::ModPersistentCharacters.initRequiredMods();
		::ModPersistentCharacters.showInfoEventIfNewVersion();
	}

	q.startNewCampaign = @(__original) function()
	{
		::ModPersistentCharacters.readFromFile();
		__original();
		::ModPersistentCharacters.initRequiredMods();
		::ModPersistentCharacters.showInfoEventIfNewVersion();
	}
});
