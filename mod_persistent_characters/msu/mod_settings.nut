// GENERAL PAGE

local generalPage = ::ModPersistentCharacters.Mod.ModSettings.addPage("General");

generalPage.addRangeSetting("SpawnChance", 10, 0, 100, 1, "Spawn Chance (%)", "The chance that persistent characters from a campaigns will spawn in another campaign every time a settlement gets fresh recruits.");

generalPage.addRangeSetting("MinLevelToSpawn", 11, 1, 33, 1, "Min Level to Spawn", "Persistent characters from other campaigns below this level will not spawn.");

generalPage.addRangeSetting("MinLevelToSave", 11, 1, 33, 1, "Min Level to Save", "Characters below this level in their original campaign will not be saved as persistent characters.");

generalPage.addRangeSetting("RequiredRenown", 25, 1, 100, 1, "Renown Required (%)", "Persistent characters will only spawn in another campaign which has at least this much percentage of renown compared to their original campaign.");

generalPage.addRangeSetting("MaxSavedCampaigns", 10, 1, 25, 1, "Max Saved Campaigns", "Persistent characters will only be saved for this many most recently saved campaigns. Higher numbers may lead to higher memory and performance impact.");

generalPage.addEnumSetting("SpawnWithPermanentInjuries", "None", ["None", "All", "Original", "Disallowed"], "Spawn with Permanent Injuries", "None: Persistent characters spawning in new campaigns will not carry over their permanent injuries.\nAll: Persistent characters will spawn with all the permanent injuries they have accumulated in all of their campaigns.\nOriginal: Persistent characters will spawn only with the permanent injuries that they received in their original campaign.\nDisallowed: Persistent characters who have received a permanent injury in any of their campaigns will not spawn in a new campaign.");

generalPage.addBooleanSetting("PermaDeath", false, "Perma Death", "If enabled, then persistent characters who have died in any of their campaigns will not spawn in new campaigns. Don\'t worry, this setting is reversible i.e. if you disable it then characters who have died previously will be allowed to spawn again.");

generalPage.addButtonSetting("DeleteFile", "Delete File", "Delete File", "Delete the file that stores the permanent data. This may be helpful in resolving issues with corrupt data or when a newer version is not save compatible." + ::MSU.Text.colorNegative("Warning: The file will be deleted permanently!")).addCallback(@( _data = null ) ::ModPersistentCharacters.deleteFile());

generalPage.addDivider("generalPage_divider1");

generalPage.addTitle("RequiredMods_Title", "Mods Required for Spawning", "Mods required for persistent characters saved from this campaign to spawn in another. Note: Set this up DURING your game, not on the main menu. It is saved on a per-campaign basis.");

generalPage.addTitle("RequiredMods_Hint", "Set this up during your game, not on the main menu", "Mods required for persistent characters saved from this campaign to spawn in another. Note: Set this up DURING your game, not on the main menu. It is saved on a per-campaign basis.");

local suffix;
foreach (mod in ::Hooks.getMods())
{
	switch (mod.getID())
	{
		case ::ModPersistentCharacters.ID:
		case "vanilla":
			continue;
	}

	suffix = "";
	local enabled = false;
	local locked = false;
	// if (::ModPersistentCharacters.IgnoredMods.find(mod.getID()) != null)
	// {
	// 	enabled = false;
	// 	suffix = " This is a popularly known " + ::MSU.Text.colorPositive("save-compatible") + " mod, so it is probably fine to leave it as not required.";
	// }
	if (::ModPersistentCharacters.LockedMods.find(mod.getID()) != null)
	{
		locked = true;
		enabled = true;
		suffix = " This is a popularly known " + ::MSU.Text.colorNegative("save-incompatible") + " mod, so it is locked as required.";
	}
	local s = generalPage.addBooleanSetting(mod.getID(), enabled, mod.getName(), "If enabled then characters who were persistently saved with this mod active will only spawn in campaigns where this mod is active." + suffix)
	s.addAfterChangeCallback(function( _oldValue ) {
		if (_oldValue)
		{
			::MSU.Array.removeByValue(::ModPersistentCharacters.RequiredMods, this.getID());
		}
		else
		{
			::ModPersistentCharacters.RequiredMods.push(this.getID());
		}
	});
	if (locked)
	{
		s.lock();
	}
}

// IMPORT PAGE

local importPage = ::ModPersistentCharacters.Mod.ModSettings.addPage("Import", "Import/Export");

importPage.addArraySetting("CampaignsList", [[1, "Start/Load a campaign first."]], "Campaigns List", "View campaigns and their UIDs.");

importPage.addArraySetting("CharactersList", [[1, "Enter a valid Campaign UID."]], "Characters List", "View characters from the selected campaign and their UIDs.");

importPage.addStringSetting("CampaignUID", "", "Campaign UID", "Enter the UID of the campaign you want to enlist characters from and " + ::MSU.Text.colorRed("click Submit.") + ".");

importPage.addStringSetting("CharacterUID", "", "Character UID", "Enter the UID of the character to import/export and " + ::MSU.Text.colorRed("click Submit.") + ".");

// importPage.addSpacer("imporpage_spacer1", 150, 0);

importPage.addButtonSetting("SubmitUIDs", "Submit UIDs", "Submit UIDs", "Submit the Campaign and Character UIDs.").addBeforeChangeCallback(function( _ = null) {
	::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").reset();
	if (::ModPersistentCharacters.getDataManager() == null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Cannot Import/Export from Main Menu. Load into a game first.");
		return;
	}

	::MSU.SettingsScreen.m.JSHandle.asyncCall("notifyBackendApplyButtonPressed", null);

	if (!::ModPersistentCharacters.getDataManager().hasCampaign(::ModPersistentCharacters.Mod.ModSettings.getSetting("CampaignUID").getValue()))
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Invalid Campaign UID");
		return;
	}

	local campaign = ::ModPersistentCharacters.getDataManager().getCampaign(::ModPersistentCharacters.Mod.ModSettings.getSetting("CampaignUID").getValue());
	local dataManager = ::ModPersistentCharacters.getDataManager();
	local charList = campaign.getBroUIDs().map(@(_uid) [dataManager.getBro(_uid).getName(), _uid]);
	::ModPersistentCharacters.Mod.ModSettings.getSetting("CharactersList").set(charList.len() == 0 ? [[1, "This campaign is empty."]] : charList);

	if (!::ModPersistentCharacters.getDataManager().hasBro(::ModPersistentCharacters.Mod.ModSettings.getSetting("CharacterUID").getValue()))
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Invalid Character UID");
	}
});

importPage.addButtonSetting("ImportBro_Button", "Import", "Import by UID", "Import the character with the UID from the campaign with the UID specified. [mb]Make sure to " + ::MSU.Text.colorRed("click Submit.") + " after entring the UIDs.[/mb]").addBeforeChangeCallback(function( _ = null ) {
	::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").reset();
	if (::ModPersistentCharacters.getDataManager() == null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Cannot Import/Export from Main Menu. Load into a game first.");
		return;
	}

	if (::World.getPlayerRoster().getAll().len() >= ::World.Assets.getBrothersMax())
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Cannot Import. Roster full.");
		return;
	}

	if (!::ModPersistentCharacters.getDataManager().hasCampaign(::ModPersistentCharacters.Mod.ModSettings.getSetting("CampaignUID").getValue()))
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Invalid Campaign UID. Click Submit UIDs.");
		return;
	}

	local broData = ::ModPersistentCharacters.getDataManager().getBro(::ModPersistentCharacters.Mod.ModSettings.getSetting("CharacterUID").getValue());
	if (broData == null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Invalid Character UID. Click Submit UIDs.");
		return;
	}

	local missingMods = broData.validateRequiredMods();
	if (missingMods != null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Canont Import. Missing Mods: " + missingMods);
	}
	else
	{
		broData.createBro(::World.getPlayerRoster()).onHired();
	}
});;

importPage.addButtonSetting("ExportBro_Button", "Export to File", "Export to File", "Export the character with the UID from the campaign with the UID specified to a file. [mb]Make sure to " + ::MSU.Text.colorRed("click Submit.") + " after entring the UIDs.[/mb]").addBeforeChangeCallback(function( _ = null ) {
	::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").reset();
	if (::ModPersistentCharacters.getDataManager() == null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Cannot Import/Export from Main Menu. Load into a game first.");
		return;
	}

	local broData = ::ModPersistentCharacters.getDataManager().getBro(::ModPersistentCharacters.Mod.ModSettings.getSetting("CharacterUID").getValue());
	if (broData == null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Invalid Character UID. Click Submit UIDs.");
		return;
	}

	local data = ::MSU.Class.SerializationData();
	broData.onSerialize(data.getSerializationEmulator());
	::ModPersistentCharacters.Mod.PersistentData.createFile(broData.getName() + broData.getUID(), data);
});

importPage.addButtonSetting("ExportBroRaw_Button", "Export to File (Raw)", "Export to File (Raw)", "Export the character with the UID from the campaign with the UID specified to a file. [mb]Make sure to " + ::MSU.Text.colorRed("click Submit.") + " after entring the UIDs.[/mb]. This will export WITHOUT the persistence flags attached.").addBeforeChangeCallback(function( _ = null ) {
	::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").reset();
	if (::ModPersistentCharacters.getDataManager() == null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Cannot Import/Export from Main Menu. Load into a game first.");
		return;
	}

	local broData = ::ModPersistentCharacters.getDataManager().getBro(::ModPersistentCharacters.Mod.ModSettings.getSetting("CharacterUID").getValue());
	if (broData == null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Invalid Character UID. Click Submit UIDs.");
		return;
	}

	local bro = broData.createBro(::World.getTemporaryRoster());
	bro.getFlags().remove(::ModPersistentCharacters.FlagID.BroUID);
	bro.getFlags().remove(::ModPersistentCharacters.FlagID.CampaignUID);
	broData = ::ModPersistentCharacters.Class.PersistentBroData(bro);
	local data = ::MSU.Class.SerializationData();
	broData.onSerialize(data.getSerializationEmulator());
	::ModPersistentCharacters.Mod.PersistentData.createFile(broData.getName() + broData.getUID(), data);
});

importPage.addDivider("importpage_divider1");

importPage.addTitle("importpage_title_ImportFile", "Import from file");

importPage.addStringSetting("CharacterToImportFromFile", "", "Filename", "Enter the filename of the character to import into your campaign and " + ::MSU.Text.colorRed("click Submit.") + ". Then press the Import from File button.");

importPage.addButtonSetting("ImportBroFromFile_Button", "Import from File", "Import from File", "Import the character with the filename specified. [mb]Make sure to " + ::MSU.Text.colorRed("click Submit.") + " after entring the filename.[/mb]").addBeforeChangeCallback(function( _ = null ) {
	::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").reset();
	if (::ModPersistentCharacters.getDataManager() == null)
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Cannot Import/Export from Main Menu. Load into a game first.");
		return;
	}

	if (::World.getPlayerRoster().getAll().len() >= ::World.Assets.getBrothersMax())
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Cannot Import. Roster full.");
		return;
	}

	::MSU.SettingsScreen.m.JSHandle.asyncCall("notifyBackendApplyButtonPressed", null);

	local filename = ::String.replace(::ModPersistentCharacters.Mod.ModSettings.getSetting("CharacterToImportFromFile").getValue(), format("MSU#%s#", ::ModPersistentCharacters.ID), "");
	if (::ModPersistentCharacters.Mod.PersistentData.hasFile(filename))
	{
		local data = ::ModPersistentCharacters.Mod.PersistentData.readFile(filename);
		local broData = ::ModPersistentCharacters.Class.PersistentBroData();
		broData.onDeserialize(data.getDeserializationEmulator());
		local missingMods = broData.validateRequiredMods();
		if (!missingMods)
		{
			::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Canont Import. Missing Mods: " + missingMods);
		}
		else
		{
			broData.createBro(::World.getPlayerRoster()).onHired();
		}
	}
	else
	{
		::ModPersistentCharacters.Mod.ModSettings.getSetting("ErrorMessage").set("Invalid Filename");
	}
});

importPage.addDivider("importpage_divider2");

importPage.addStringSetting("ErrorMessage", "", "Error Message");


foreach (setting in importPage.getAllElementsAsArray(::MSU.Class.AbstractSetting))
{
	setting.setPersistence(false);
}

// importPage.addButtonSetting("ReadFile", "Read File", "Read File", "Read the file that stores the permanent data.").addCallback(function( _data = null ) {
// 	if (::ModPersistentCharacters.getDataManager() == null)
// 		return;
// 	::ModPersistentCharacters.readFromFile();
// 	::ModPersistentCharacters.Mod.ModSettings.getSetting("CampaignsList").set(::ModPersistentCharacters.getDataManager().CampaignUIDs.map(@(_c) [::ModPersistentCharacters.getDataManager().getCampaign(_c).getName(), ::ModPersistentCharacters.getDataManager().getCampaign(_c).getUID()]));
// });
