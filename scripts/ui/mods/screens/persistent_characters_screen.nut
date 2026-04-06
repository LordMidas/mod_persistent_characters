this.persistent_characters_screen <- ::inherit("scripts/mods/msu/ui_screen" {
	m = {
		ID = "ModPersistentCharactersScreen",
		RosterID = ::toHash("ModPersistentCharactersRoster")
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
		::logInfo("show");
		this.ui_screen.show(_data);
		this.m.JSHandle.asyncCall("loadFromData", this.queryCampaignData());
	}

	function hide()
	{
		::World.deleteRoster(this.m.RosterID);
		this.ui_screen.hide();
	}

	function queryCampaignData()
	{
		return ::ModPersistentCharacters.DataManager.CampaignsArray.map(@(_c) _c.toUIData());
	}

	function queryHireInformation()
	{
		local r = ::World.createRoster(this.m.RosterID);
		foreach (broData in ::ModPersistentCharacters.DataManager.getBros())
		{
			broData.createBro(r);
		}
		return this.convertHireRosterToUIData(this.m.RosterID);
	}

	function convertHireRosterToUIData( _rosterID )
	{
		local result = [];
		local roster = this.World.getRoster(_rosterID);
		// local roster = ::World.getPlayerRoster();

		if (roster == null)
		{
			return null;
		}

		local entities = roster.getAll();

		if (entities != null)
		{
			local result = [];

			foreach( entity in entities )
			{
				result.push(this.convertEntityToUIData(entity));
			}

			return result;
		}

		return null;
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
			IsTryoutDone = false,
			ImagePath = _entity.getImagePath(),
			ImageOffsetX = _entity.getImageOffsetX(),
			ImageOffsetY = _entity.getImageOffsetY(),
			BackgroundImagePath = background.getIconColored(),
			BackgroundText = background.getDescription(),
			Traits = _entity.getHiringTraits()
		};
	}
});
