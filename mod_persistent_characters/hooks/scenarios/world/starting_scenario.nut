// ::ModPersistentCharacters.MH.hookTree("scripts/scenarios/world/starting_scenario", function(q) {
// 	q.onUpdateHiringRoster = @(__original) function( _roster )
// 	{
// 		__original(_roster);
// 		local data = ::ModPersistentCharacters.Mod.PersistentData.readFile("PersistentBros");
// 		local campaignUID = ::World.Flags.get("ModPersistentCharacters.CampaignUID");
// 		foreach (uid, bros in data.Campaign)
// 		{
// 			if (uid != campaignUID)
// 			{
// 				foreach (bro in bros)
// 				{
// 					::ModPersistentCharacters.generateBroFromData(bro, _roster);
// 				}
// 			}
// 		}
// 	}
// });
