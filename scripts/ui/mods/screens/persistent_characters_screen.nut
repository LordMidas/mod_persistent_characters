this.persistent_characters_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "ModPersistentCharactersScreen",
		RosterID = ::toHash("ModPersistentCharactersRoster"),
		Roster = null,
		// broUID -> preview entity, only for bros who are loadable
		BroEntities = {}
	},

	function toggle()
	{
		if (this.m.Animating)
			return false;

		if (this.isVisible())
		{
			// The MenuStack calls hide
			::MSU.Utils.getActiveState().m.MenuStack.pop();
		}
		else
		{
			this.show(null);
		}
		return true;
	}

	// The MSU ui_screen class can't be used for show/hide as it doesn't integrate with the MenuStack
	// so we do our own overwrites.
	function show( _data )
	{
		if (this.m.JSHandle == null || this.isVisible() || this.m.Animating)
			return false;

		local activeState = ::MSU.Utils.getActiveState();
		// Opening on top of other menus e.g. a town or the inventory would break their MenuStack handling
		if (activeState.ClassName != "world_state" || activeState.m.MenuStack.hasBacksteps() || activeState.m.EventScreen.isVisible() || ::ModPersistentCharacters.getDataManager() == null)
			return false;

		if (this.m.Roster != null)
			::World.deleteRoster(this.m.RosterID);
		this.m.Roster = ::World.createRoster(this.m.RosterID);
		this.m.BroEntities = {};

		activeState.onHide();
		::Cursor.setCursor(::Const.UI.Cursor.Hand);
		activeState.setAutoPause(true);
		activeState.m.MenuStack.push(function ()
		{
			::ModPersistentCharacters.Screen.hide();
			this.onShow();
			this.setAutoPause(false);
		}, function ()
		{
			// Escape closes an open popup (handled by JS) before it closes the screen
			return !::ModPersistentCharacters.Screen.isPopupVisible();
		});

		this.m.JSHandle.asyncCall("show", null);
		return false;
	}

	// Called by the MenuStack
	function hide()
	{
		this.m.BroEntities = {};
		this.m.Roster = null;
		::World.deleteRoster(this.m.RosterID);

		if ((this.isVisible() || this.m.Animating) && this.m.JSHandle != null)
		{
			this.m.PopupVisible = false;
			this.m.JSHandle.asyncCall("hide", null);
		}
		return false;
	}

	function onClosePressed()
	{
		::MSU.Utils.getActiveState().m.MenuStack.pop();
	}

	function clearPreview()
	{
		this.m.BroEntities = {};
		if (this.m.Roster != null)
			this.m.Roster.clear();
	}

	function queryData()
	{
		local dataManager = ::ModPersistentCharacters.getDataManager();
		local helper = ::ModPersistentCharacters.UIDataHelper;
		local campaigns = dataManager.getCampaigns().map(@(_c) helper.convertCampaignToUIData(_c));
		local loose = dataManager.getLooseBros();
		if (loose.len() != 0)
			campaigns.push(helper.convertLooseToUIData(loose));

		return {
			CurrentCampaignUID = ::ModPersistentCharacters.getCampaignUID(),
			CurrentCampaignName = ::World.Assets.getName(),
			IsSavingEnabled = ::ModPersistentCharacters.isSavingEnabled(),
			LooseCampaignUID = ::ModPersistentCharacters.LooseCampaignUID,
			Campaigns = campaigns
		};
	}

	// Returns the list of bros of the campaign. Entities are created only for loadable bros.
	function onCampaignSelected( _campaignUID )
	{
		this.clearPreview();
		if (this.m.Roster == null)
			return [];

		local dataManager = ::ModPersistentCharacters.getDataManager();
		local broDatas;
		if (_campaignUID == ::ModPersistentCharacters.LooseCampaignUID)
		{
			broDatas = dataManager.getLooseBros();
		}
		else
		{
			local campaign = dataManager.getCampaign(_campaignUID);
			if (campaign == null)
				return [];
			broDatas = campaign.getBros();
		}

		local helper = ::ModPersistentCharacters.UIDataHelper;
		local ret = [];
		foreach (broData in broDatas)
		{
			local entity = null;
			if (broData.isLoadable())
			{
				entity = broData.createBro(this.m.Roster, false);
				this.m.BroEntities[broData.getUID()] <- entity;
			}
			ret.push(helper.convertBroToUIData(broData, entity));
		}
		return ret;
	}

	function onBroSelected( _broUID )
	{
		local broData = ::ModPersistentCharacters.getDataManager().getBro(_broUID);
		if (broData == null || !(_broUID in this.m.BroEntities))
			return null;

		return ::ModPersistentCharacters.UIDataHelper.convertBroDetailsToUIData(broData, this.m.BroEntities[_broUID]);
	}

	function errorResult( _error )
	{
		return { Error = _error };
	}

	function onImportBro( _broUID )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.importBro(_broUID));
	}

	function onMakeHome( _broUID )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.makeHome(_broUID));
	}

	// _data is [broUID, isRaw]
	function onExportBro( _data )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.exportBro(_data[0], _data[1]));
	}

	function onDeleteBro( _broUID )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.deleteBro(_broUID));
	}

	// _data is [campaignUID, deleteBros]
	function onDeleteCampaign( _data )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.deleteCampaign(_data[0], _data[1]));
	}

	function onDeleteLooseBros()
	{
		return this.errorResult(::ModPersistentCharacters.Actions.deleteLooseBros());
	}

	// _data is [broUID, campaignUID, isDead]
	function onSetDead( _data )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.setDead(_data[0], _data[1], _data[2]));
	}

	// _data is [enabled, mode]
	function onSetSavingEnabled( _data )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.setSavingEnabled(_data[0], _data[1]));
	}

	function queryRequiredMods()
	{
		local required = ::ModPersistentCharacters.getRequiredModIDs();
		local ret = [];
		foreach (mod in ::ModPersistentCharacters.getSelectableMods())
		{
			local id = mod.getID();
			local isLocked = ::ModPersistentCharacters.isModLocked(id);
			ret.push({
				ID = id,
				Name = mod.getName(),
				IsLocked = isLocked,
				IsRequired = isLocked || required.find(id) != null
			});
		}
		return ret;
	}

	function onSetRequiredMods( _modIDs )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.setRequiredMods(_modIDs));
	}

	function queryImportFiles()
	{
		return ::ModPersistentCharacters.Actions.getImportFiles();
	}

	function onImportFile( _filename )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.importFile(_filename));
	}

	function onDeleteFile( _filename )
	{
		return this.errorResult(::ModPersistentCharacters.Actions.deleteFile(_filename));
	}
});
