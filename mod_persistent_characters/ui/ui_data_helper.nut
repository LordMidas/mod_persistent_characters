// Conversion of the persistent data into tables which are sent to the Persistent Characters screen
::ModPersistentCharacters.UIDataHelper <- {
	function convertCampaignToUIData( _campaign )
	{
		return {
			UID = _campaign.getUID(),
			Name = _campaign.getName(),
			Banner = _campaign.getBanner(),
			NumBros = _campaign.getBroUIDs().len(),
			Renown = _campaign.getBusinessReputation(),
			IsLoadable = _campaign.isLoadable(),
			IsCurrent = _campaign.getUID() == ::ModPersistentCharacters.getCampaignUID(),
			DeleteReason = ::ModPersistentCharacters.Actions.getCannotDeleteCampaignReason(_campaign.getUID())
		};
	}

	function convertLooseToUIData( _looseBros )
	{
		return {
			UID = ::ModPersistentCharacters.LooseCampaignUID,
			Name = "Loose Characters",
			Banner = "",
			NumBros = _looseBros.len(),
			Renown = null,
			IsLoadable = true,
			IsCurrent = false,
			DeleteReason = null
		};
	}

	// Returns an array of { id, icon } of the traits and permanent injuries of _entity
	function convertTraitsToUIData( _entity )
	{
		local ret = [];
		foreach (s in _entity.getSkills().query(::Const.SkillType.Trait | ::Const.SkillType.PermanentInjury))
		{
			// The background is also a Trait but is shown separately
			if (s.isType(::Const.SkillType.Background))
				continue;

			ret.push({
				id = s.getID(),
				icon = s.getIconColored()
			});
		}
		return ret;
	}

	function isDeadInAnyCampaign( _broData )
	{
		foreach (stats in _broData.getLifetimeStats())
		{
			if (stats.isDead())
				return true;
		}
		return false;
	}

	// Entry of the list of bros. _entity is null if the bro isn't loadable.
	function convertBroToUIData( _broData, _entity )
	{
		local ret = {
			UID = _broData.getUID(),
			Name = _broData.getName(),
			Level = _broData.getLevel(),
			IsLoadable = _entity != null
		};

		if (_entity == null)
			return ret;

		local currentCampaignUID = ::ModPersistentCharacters.getCampaignUID();
		local inCompany = ::ModPersistentCharacters.Actions.findInPlayerRoster(_broData.getUID()) != null;
		local isHome = _broData.isHome(currentCampaignUID);

		ret.ID <- _entity.getID();
		ret.ImagePath <- _entity.getImagePath();
		ret.ImageOffsetX <- _entity.getImageOffsetX();
		ret.ImageOffsetY <- _entity.getImageOffsetY();
		ret.BackgroundImagePath <- _entity.getBackground().getIconColored();
		ret.Traits <- this.convertTraitsToUIData(_entity);
		ret.IsDead <- this.isDeadInAnyCampaign(_broData);
		ret.IsInCompany <- inCompany;
		ret.IsHome <- isHome;
		ret.IsOnLoan <- inCompany && !isHome;
		ret.CannotSpawn <- !_broData.canSpawn();
		return ret;
	}

	// Returns the perk tree of _entity as rows of perks. DynamicPerks and Legends give each character his own tree.
	function getPerkTree( _entity )
	{
		if (::Hooks.hasMod("mod_dynamic_perks"))
			return _entity.getPerkTree().toUIData();

		local background = _entity.getBackground();
		if (::MSU.isIn("getPerkTree", background, true))
			return background.getPerkTree();

		return ::Const.Perks.Perks;
	}

	// Sends only what the screen needs: ID, Icon and IconDisabled of each perk
	function convertPerkTreeToUIData( _entity )
	{
		local tree = this.getPerkTree(_entity);
		local ret = [];
		foreach (row in tree)
		{
			local uiRow = [];
			foreach (perk in row)
			{
				uiRow.push({
					ID = perk.ID,
					Icon = perk.Icon,
					IconDisabled = perk.IconDisabled
				});
			}
			ret.push(uiRow);
		}
		return ret;
	}

	function convertServiceRecordToUIData( _broData )
	{
		local ret = [];
		foreach (campaignUID, stats in _broData.getLifetimeStats())
		{
			ret.push({
				CampaignUID = campaignUID,
				Name = ::ModPersistentCharacters.getCampaignDisplayName(campaignUID, _broData),
				Days = stats.getDays(),
				Battles = stats.getBattles(),
				Kills = stats.getKills(),
				IsDead = stats.isDead(),
				IsHome = _broData.isHome(campaignUID),
				IsCurrent = campaignUID == ::ModPersistentCharacters.getCampaignUID(),
				DeadReason = ::ModPersistentCharacters.Actions.getCannotSetDeadReason(_broData, campaignUID)
			});
		}
		return ret;
	}

	// Details of a single bro. _entity is his preview entity.
	function convertBroDetailsToUIData( _broData, _entity )
	{
		local actions = ::ModPersistentCharacters.Actions;
		local ret = {
			UID = _broData.getUID(),
			ID = _entity.getID(),
			Name = _entity.getNameOnly(),
			Title = _entity.getTitle(),
			Level = _entity.getLevel(),
			ImagePath = _entity.getImagePath(),
			ImageOffsetX = _entity.getImageOffsetX(),
			ImageOffsetY = _entity.getImageOffsetY(),
			BackgroundImagePath = _entity.getBackground().getIconColored(),
			Traits = this.convertTraitsToUIData(_entity),
			Stats = {},
			Paperdoll = {},
			Bag = [],
			Tree = this.convertPerkTreeToUIData(_entity),
			LearnedPerks = [],
			ServiceRecord = this.convertServiceRecordToUIData(_broData),
			ImportReason = actions.getCannotImportReason(_broData),
			MakeHomeReason = actions.getCannotMakeHomeReason(_broData),
			DeleteReason = actions.getCannotDeleteBroReason(_broData),
			ExportReason = null
		};

		::UIDataHelper.addStatsToUIData(_entity, ret.Stats);
		::UIDataHelper.convertPaperdollEquipmentToUIData(_entity.getItems(), ret.Paperdoll);
		::UIDataHelper.convertBagItemsToUIData(_entity.getItems(), ret.Bag);
		::UIDataHelper.addPerksToUIData(_entity, _entity.getSkills().query(::Const.SkillType.Perk, true), ret.LearnedPerks);
		return ret;
	}
};
