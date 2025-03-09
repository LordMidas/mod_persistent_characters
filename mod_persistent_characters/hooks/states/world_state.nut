::ModPersistentCharacters.MH.hook("scripts/states/world_state", function(q) {
	q.saveCampaign = @(__original) function( _campaignFileName, _campaignLabel = null )
	{
		::ModPersistentCharacters.getDataManager().onSaveCampaign();
		::ModPersistentCharacters.writeToFile();
		::ModPersistentCharacters.resetImportPage();
		__original(_campaignFileName, _campaignLabel);
	}

	q.loadCampaign = @(__original) function( _campaignFileName )
	{
		::ModPersistentCharacters.RequiredMods.clear();
		::ModPersistentCharacters.readFromFile();
		__original(_campaignFileName);

	}

	q.startNewCampaign = @(__original) function()
	{
		::ModPersistentCharacters.readFromFile();
		::ModPersistentCharacters.resetImportPage();
		__original();
	}
});
