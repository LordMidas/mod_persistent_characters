::MSU.Table.merge(::ModPersistentCharacters, {
	Filename = "Data",
	FlagID = {
		BlockedBros = ::ModPersistentCharacters.ID + ".BlockedBros",
		CampaignUID = ::ModPersistentCharacters.ID + ".CampaignUID",
		BroUID = ::ModPersistentCharacters.ID + ".BroUID"
	},
	RequiredMods = [], // populated via mod settings by user
	// IgnoredMods = [
	// 	"dlc_unhold_supporter",
	// 	"dlc_wildmen_supporter",
	// 	"dlc_desert_supporter",
	// 	"mod_EIMO",
	// 	"mod_plan_perks",
	// 	"mod_swifter",
	// 	"mod_combat_simulator",
	// 	"mod_dev_console",
	// 	"mod_extra_keybinds",
	// 	"mod_breditor",
	// 	"mod_stack_based_skills",
	// 	"mod_upd",
	// 	"mod_msu_launcher",
	// 	"mod_dynamic_spawns",
	// 	"mod_nested_tooltips",
	// 	"mod_item_tables"
	// ],
	LockedMods = [
		"dlc_unhold",
		"dlc_wildmen",
		"dlc_desert",
		"dlc_lindwurm",
		"mod_msu",
		"mod_hooks",
		"mod_modern_hooks",
		"mod_legends",
		"mod_legends_PTR",
		"mod_reforged",
		"mod_dynamic_perks"
	],
	PlayerFieldsToClean = {},
	DataManager = null,

	function getDataManager()
	{
		return this.DataManager;
	}

	function writeToFile()
	{
		local data = ::MSU.Class.SerializationData();
		this.DataManager.onSerialize(data.getSerializationEmulator());
		::ModPersistentCharacters.Mod.PersistentData.createFile(this.Filename, data);
	}

	function readFromFile()
	{
		if (::ModPersistentCharacters.Mod.PersistentData.hasFile(this.Filename))
		{
			this.DataManager = ::ModPersistentCharacters.Class.DataManager();
			this.DataManager.onDeserialize(::ModPersistentCharacters.Mod.PersistentData.readFile(this.Filename).getDeserializationEmulator());
		}
		else
		{
			this.DataManager = ::ModPersistentCharacters.Class.DataManager();
		}
	}

	function deleteFile()
	{
		::ModPersistentCharacters.Mod.PersistentData.deleteFile(this.Filename);
	}

	function hasFile()
	{
		return ::ModPersistentCharacters.Mod.PersistentData.hasFile(this.Filename);
	}

	function getCampaignUID()
	{
		if (::World.Flags.has(this.FlagID.CampaignUID))
			return ::World.Flags.get(this.FlagID.CampaignUID);
	}

	function setCampaignUID( _uid )
	{
		::World.Flags.set(this.FlagID.CampaignUID, _uid);
	}

	function hasBlockedBro( _uid )
	{
		return this.getBlockedBros().find(_uid) != null;
	}

	function getBlockedBros()
	{
		if (::World.Flags.has(this.FlagID.BlockedBros))
			return split(::World.Flags.get(this.FlagID.BlockedBros), ",");
		return [];
	}

	// each entry in _brosArray must be a stringified integer uid of bro
	function setBlockedBros( _brosArray )
	{
		::World.Flags.set(this.FlagID.BlockedBros, _brosArray.reduce(@(_a, _b) _a + "," + _b));
	}

	function addBlockedBro( _uid )
	{
		local bros = this.getBlockedBros();
		if (bros.find(_uid) == null)
		{
			bros.push(_uid);
			this.setBlockedBros(bros);
		}
	}

	function removeBlockedBro( _uid )
	{
		local bros = this.getBlockedBros();
		if (bros.len() == 0)
			return;

		if (::MSU.Array.removeByValue(bros, _uid) != null)
			this.setBlockedBros(bros);
	}

	function generateUID()
	{
		local ret = ::Math.rand().tostring();
		ret += ::Math.rand().tostring();
		ret += ::Math.rand().tostring();
		return ret + ::Math.rand().tostring();
	}

	function getPersistentCharacterTooltip( _bro )
	{
		local str = "Persistent character from ";
		local bannerIcon = "ui/icons/special.png";

		local campaignUID = _bro.ModPersistentCharacters_getCampaignUID();
		if (campaignUID == ::ModPersistentCharacters.getCampaignUID())
		{
			str += "this company";
			bannerIcon = "ui/banners/" + ::World.Assets.getBanner() + "s.png";
		}
		else if (::ModPersistentCharacters.getDataManager().hasCampaign(campaignUID))
		{
			local campaign = ::ModPersistentCharacters.getDataManager().getCampaign(campaignUID);
			str += "the " + campaign.getName();
			bannerIcon = "ui/banners/" + campaign.getBanner() + "s.png";
		}
		else
		{
			str += "a forgotten company";
		}

		local broData = ::ModPersistentCharacters.getDataManager().getBro(_bro.ModPersistentCharacters_getUID());
		if (broData != null)
		{
			if (broData.getCampaignUID() != ::ModPersistentCharacters.getCampaignUID() || broData.getLifetimeStats().len() > 1)
			{
				local stats = broData.getLifetimeStatsTotal();
				str += format(" who has been on %i campaigns over the course of %i days, taking part in %i battles and making %i kills", broData.getLifetimeStats().len(), stats.Days, stats.Battles, stats.Kills)
			}
			else
			{
				str += " who has not been on any other campaign so far";
			}
		}

		return {
			id = 100,
			type = "hint",
			icon = bannerIcon,
			text = str
		};
	}

	function resetImportPage()
	{
		::ModPersistentCharacters.Mod.ModSettings.getPage("Import").resetSettings();
		::ModPersistentCharacters.Mod.ModSettings.getSetting("CampaignsList").set(this.getDataManager().getCampaigns().map(@(_c) [_c.getName(), _c.getUID()]));
	}
});
