this.persistent_characters_screen <- ::inherit("scripts/mods/msu/ui_screen" {
	m = {
		ID = "ModPersistentCharactersScreen",
		RosterID = ::toHash("ModPersistentCharactersRoster"),
		Roster = null
	},

	function toggle()
	{
		if (this.m.Animating)
		{
			return false;
		}

		this.isVisible() ? this.hide() : this.show(null);
		return true;
	}

	function show( _data )
	{
		// this.ui_screen.show(_data);

		this.m.Roster = ::World.createRoster(this.m.RosterID);

		local activeState = ::MSU.Utils.getActiveState();
		activeState.onHide();
		::Cursor.setCursor(::Const.UI.Cursor.Hand);
		switch(activeState.ClassName)
		{
			case "world_state":
				activeState.setAutoPause(true);
				activeState.m.MenuStack.push(function ()
				{
					::ModPersistentCharacters.Screen.hide();
					this.onShow();
					this.setAutoPause(false);
				});
				break;

			case "main_menu_state":
				activeState.m.MenuStack.push(function ()
				{
					::ModPersistentCharacters.Screen.hide();
					this.onShow();
				});
				break;
		}
		// this.Tooltip.hide();
		// this.m.JSHandle.asyncCall("setData", this.queryData());
		this.m.JSHandle.asyncCall("show", null);
		this.m.JSHandle.asyncCall("loadFromData", this.queryCampaignData());
		return false;
	}

	function hide()
	{
		::World.deleteRoster(this.m.RosterID);
		if (this.isVisible())
		{
			local activeState = ::MSU.Utils.getActiveState();
			this.m.JSHandle.asyncCall("hide", null);
			activeState.m.MenuStack.pop();
			return false
		}
		// this.ui_screen.hide();
	}

	function queryCampaignData()
	{
		return ::ModPersistentCharacters.DataManager.CampaignsArray.map(@(_c) _c.toUIData());
	}

	function onCampaignSelected( _campaignUID )
	{
		local bros = [];
		foreach (broUID in ::ModPersistentCharacters.DataManager.getCampaign(_campaignUID).getBroUIDs())
		{
			local broData = ::ModPersistentCharacters.DataManager.getBro(broUID);
			local bro = broData.createBro(this.m.Roster);
			bros.push(bro);
		}
		local self = this;
		this.m.JSHandle.asyncCall("loadBroData", bros.map(@(_b) self.convertEntityToUIData(_b)));
	}

	function convertEntityToUIData( _entity )
	{
		local background = _entity.getBackground();
		return {
			ID = _entity.getID(),
			Name = _entity.getName(),
			Level = _entity.getLevel(),
			InitialMoneyCost = 90,
			DailyMoneyCost = _entity.getDailyCost(),
			DailyFoodCost = _entity.getDailyFood(),
			TryoutCost = 100,
			IsTryoutDone = true,
			ImagePath = _entity.getImagePath(),
			ImageOffsetX = _entity.getImageOffsetX(),
			ImageOffsetY = _entity.getImageOffsetY(),
			BackgroundImagePath = background.getIconColored(),
			BackgroundText = background.getDescription(),
			Traits = _entity.getHiringTraits(),
			perkTree = _entity.getPerkTree().toUIData()
		};
	}
});
