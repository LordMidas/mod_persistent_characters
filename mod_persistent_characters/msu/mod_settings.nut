// GENERAL PAGE

local generalPage = ::ModPersistentCharacters.Mod.ModSettings.addPage("General");

generalPage.addTitle("ScreenHint", "Press Ctrl+P during a campaign to open the Persistent Characters screen", "View, import, export and delete persistent characters and choose the mods required for the current campaign in the Persistent Characters screen. The keybind can be changed in the Keybinds page.");

generalPage.addRangeSetting("SpawnChance", 10, 0, 100, 1, "Spawn Chance (%)", "The chance that persistent characters from a campaigns will spawn in another campaign every time a settlement gets fresh recruits.");

generalPage.addRangeSetting("MinLevelToSpawn", 11, 1, 33, 1, "Min Level to Spawn", "Persistent characters from other campaigns below this level will not spawn.");

generalPage.addRangeSetting("MinLevelToSave", 11, 1, 33, 1, "Min Level to Save", "Characters below this level in their original campaign will not be saved as persistent characters.");

generalPage.addRangeSetting("RequiredRenown", 25, 1, 100, 1, "Renown Required (%)", "Persistent characters will only spawn in another campaign which has at least this much percentage of renown compared to their original campaign.");

generalPage.addRangeSetting("MaxSavedCampaigns", 10, 1, 25, 1, "Max Saved Campaigns", "Persistent characters will only be saved for this many most recently saved campaigns. Once this number is reached, when you save a new campaign, the oldest one\'s data will be deleted. Higher numbers may lead to higher memory and performance impact.");

generalPage.addRangeSetting("MaxLooseBros", 50, 0, 200, 1, "Max Loose Characters", "Characters whose original campaign was removed (e.g. due to Max Saved Campaigns or deleted via the Persistent Characters screen) are kept as loose characters. Only this many are kept. When this number is exceeded, the oldest ones are deleted. If set to 0, characters are deleted instead of becoming loose.");

generalPage.addRangeSetting("CostMult_Hire", 3.0, 1.0, 5.0, 0.1, "Hiring Cost Mult", "The hiring cost of persistent characters in settlements is multiplied by this number.");
generalPage.addRangeSetting("CostMult_EventHire", 2.0, 1.0, 5.0, 0.1, "Event Cost Mult", "The one time payment demand of persistent characters that offer to join you via event is multiplied by this number.");
generalPage.addRangeSetting("CostMult_Wage", 1.5, 1.0, 5.0, 0.1, "Daily Wage Mult", "The daily wage of recruited persistent characters is multiplied by this number.");

generalPage.addEnumSetting("SpawnWithPermanentInjuries", "None", ["None", "All", "Original", "Disallowed"], "Spawn with Permanent Injuries", "None: Persistent characters spawning in new campaigns will not carry over their permanent injuries.\nAll: Persistent characters will spawn with all the permanent injuries they have accumulated in all of their campaigns.\nOriginal: Persistent characters will spawn only with the permanent injuries that they received in their home campaign (by default the campaign in which they were first saved).\nDisallowed: Persistent characters who have received a permanent injury in any of their campaigns will not spawn in a new campaign.");

generalPage.addBooleanSetting("PermaDeath", false, "Perma Death", "If enabled, then persistent characters who have died in any of their campaigns will not spawn in new campaigns. Don\'t worry, this setting is reversible i.e. if you disable it then characters who have died previously will be allowed to spawn again.");

generalPage.addButtonSetting("DeleteFile", "Delete File", "Delete File", "Delete the file that stores the permanent data. This may be helpful in resolving issues with corrupt data or when a newer version is not save compatible. " + ::MSU.Text.colorNegative("Warning: The file will be deleted permanently!")).addCallback(@( _data = null ) ::ModPersistentCharacters.deleteFile());
