local function getMissingModsEntry( _missingMods )
{
	return {
		id = 10,	type = "text",	icon = "ui/icons/warning.png",
		text = ::MSU.Text.colorNegative("Missing required mods:"),
		children = _missingMods.map(@(_mod) {
			id = 11,	type = "text",	text = _mod.Name + " (" + _mod.ID + ")"
		})
	};
}

::ModPersistentCharacters.Mod.Tooltips.setTooltips({
	// Generic tooltip with _data.title, _data.text and optionally _data.lines which is an
	// array of { icon, text } shown as separate rows e.g. to show why a button is disabled
	Text = ::MSU.Class.CustomTooltip(function( _data ) {
		local ret = [{ id = 1, type = "title", text = _data.title }];
		if ("text" in _data && _data.text != null && _data.text != "")
			ret.push({ id = 2, type = "description", text = _data.text });
		if ("lines" in _data && _data.lines != null)
		{
			foreach (i, line in _data.lines)
			{
				ret.push({ id = 10 + i, type = "text", icon = line.icon, text = line.text });
			}
		}
		return ret;
	}),

	// _data.campaignUID is the UID of the campaign (or LooseCampaignUID)
	CampaignEntry = ::MSU.Class.CustomTooltip(function( _data ) {
		local dataManager = ::ModPersistentCharacters.getDataManager();
		if (_data.campaignUID == ::ModPersistentCharacters.LooseCampaignUID)
		{
			return [
				{ id = 1, type = "title", text = "Loose Characters" },
				{ id = 2, type = "description", text = "Characters whose home campaign was removed from the persistent data. They can still spawn in your campaigns." },
				{ id = 3, type = "text", icon = "ui/icons/asset_brothers.png", text = dataManager.getLooseBros().len() + " characters" }
			];
		}

		local campaign = dataManager.getCampaign(_data.campaignUID);
		if (campaign == null)
			return null;

		local ret = [
			{ id = 1, type = "title", text = campaign.getName() },
			{ id = 3, type = "text", icon = "ui/icons/asset_brothers.png", text = campaign.getBroUIDs().len() + " characters" },
			{ id = 4, type = "text", icon = "ui/icons/special.png", text = "Renown: " + campaign.getBusinessReputation() }
		];

		if (campaign.getUID() == ::ModPersistentCharacters.getCampaignUID())
		{
			ret.push({ id = 5, type = "hint", icon = "ui/banners/" + campaign.getBanner() + "s.png", text = "This is your current company" });
		}

		local missingMods = campaign.getMissingMods();
		if (missingMods.len() != 0)
		{
			ret.push(getMissingModsEntry(missingMods));
		}

		return ret;
	}),

	// _data.broUID is the UID of the bro
	BroEntry = ::MSU.Class.CustomTooltip(function( _data ) {
		local broData = ::ModPersistentCharacters.getDataManager().getBro(_data.broUID);
		if (broData == null)
			return null;

		local ret = [
			{ id = 1, type = "title", text = broData.getName() },
			{ id = 2, type = "text", icon = "ui/icons/level.png", text = "Level " + broData.getLevel() },
			{ id = 3, type = "text", icon = "ui/icons/special.png", text = "Home company: " + ::ModPersistentCharacters.getCampaignDisplayName(broData.getHomeCampaignUID(), broData) }
		];

		local missingMods = broData.getMissingMods();
		if (missingMods.len() != 0)
		{
			ret.push(getMissingModsEntry(missingMods));
			return ret;
		}

		local cannotSpawnReason = broData.getCannotSpawnReason();
		if (cannotSpawnReason != null)
		{
			ret.push({ id = 4, type = "text", icon = "ui/icons/warning.png", text = "Cannot spawn: " + cannotSpawnReason });
		}

		ret.push({ id = 5, type = "text", icon = "ui/icons/days_wounded.png", text = broData.getServiceSummary() });

		return ret;
	}),

	// _data.modID is the ID of the mod
	ModEntry = ::MSU.Class.CustomTooltip(function( _data ) {
		local modID = _data.modID;
		if (!::Hooks.hasMod(modID))
			return null;

		local mod = ::Hooks.getMod(modID);
		local ret = [
			{ id = 1, type = "title", text = mod.getName() },
			{ id = 2, type = "description", text = "ID: " + modID + "\nVersion: " + mod.getVersionString() },
			{ id = 3, type = "text", icon = "ui/icons/special.png", text = "If required, characters saved from this campaign will only spawn or be importable in sessions where this mod is installed." }
		];

		if (::ModPersistentCharacters.isModLocked(modID))
		{
			ret.push({ id = 4, type = "text", icon = "ui/icons/warning.png", text = "This is a popularly known " + ::MSU.Text.colorNegative("save-incompatible") + " mod, so it is always required." });
		}

		return ret;
	})
});
