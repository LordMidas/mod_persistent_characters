::ModPersistentCharacters.MH.hookTree("scripts/entity/world/settlement", function(q) {
	q.updateRoster = @(__original) function( _force = false )
	{
		local campaignUID = ::ModPersistentCharacters.getCampaignUID();
		if (campaignUID == null)
			return __original(_force);

		// Collect all persistent bros before roster is updated, so that after roster update
		// if any are removed by the settlement, we can update their persistent data
		local myRoster = ::World.getRoster(this.getID());
		local persistentBros = myRoster.getAll().filter(@(_, _b) _b.ModPersistentCharacters_getID() != null);
		foreach (bro in persistentBros)
		{
			::World.getTemporaryRoster().add(bro);
		}

		local lastRosterUpdate = this.m.LastRosterUpdate;

		__original(_force);

		if (lastRosterUpdate == this.m.LastRosterUpdate)
		{
			::World.getTemporaryRoster().clear();
			return;
		}

		local dataManager = ::ModPersistentCharacters.getDataManager();
		if (persistentBros.len() != 0)
		{
			local newList = myRoster.getAll();
			local lostBros = persistentBros.filter(@(_, _b) newList.find(_b) == null);

			if (lostBros.len() == persistentBros.len())
			{
				::World.getTemporaryRoster().clear();
				return;
			}

			foreach (bro in lostBros)
			{
				::ModPersistentCharacters.removeBlockedBro(bro.ModPersistentCharacters_getUID());
			}
		}

		if (::Math.rand(1, 100) <= ::ModPersistentCharacters.Mod.ModSettings.getSetting("SpawnChance").getValue())
		{
			local renownThreshold = ::World.Assets.getBusinessReputation() / (::ModPersistentCharacters.Mod.ModSettings.getSetting("RequiredRenown").getValue() * 0.01);

			local campaign = dataManager.getRandomCampaign(@(_c) _c.getUID() != campaignUID && _c.getBusinessReputation() <= renownThreshold && _c.validateRequiredMods() == null);
			if (campaign != null)
			{
				local broData = campaign.getRandomBro(@(_b) _b.canSpawn());
				if (broData != null)
				{
					local bro = broData.createBro(myRoster);
					local weapon = bro.getMainhandItem();
					if (weapon != null && weapon.getID().find("banner") != null)
					{
						bro.getItems().unequip(weapon);
					}
					::ModPersistentCharacters.addBlockedBro(broData.getUID());
				}
			}
		}

		::World.getTemporaryRoster().clear();
	}
});
