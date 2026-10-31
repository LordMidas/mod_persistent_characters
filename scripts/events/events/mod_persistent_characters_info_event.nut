// Shown once per campaign for each new version of the mod. Never fires randomly.
this.mod_persistent_characters_info_event <- ::inherit("scripts/events/event", {
	m = {},
	function create()
	{
		this.m.ID = "event.mod_persistent_characters_info";
		this.m.Title = "Persistent Characters";
		this.m.Cooldown = 99999.0 * ::World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Banner = "",
			Options = [
				{
					Text = "Understood",
					function getResult( _event )
					{
						return 0;
					}
				}
			],
			function start( _event )
			{
				local keybind = ::ModPersistentCharacters.Mod.Keybinds.getKeybind("toggleScreen").getKeyCombinationsCapitalized();
				this.Text = ::ModPersistentCharacters.Name + " " + ::ModPersistentCharacters.Version + "\n\n"
					+ "Characters of this campaign are saved as persistent characters when you save the game, and can appear in your other campaigns.\n\n"
					+ "Press [color=" + ::Const.UI.Color.PositiveValue + "]" + keybind + "[/color] on the world map to open the Persistent Characters screen. "
					+ "There, set the [color=" + ::Const.UI.Color.PositiveValue + "]Required Mods[/color] of this campaign: characters saved from it will only appear in campaigns where all of these mods are installed. "
					+ "Remember to update that list whenever you add or remove mods.\n\n"
					+ "More settings can be found in the [color=" + ::Const.UI.Color.PositiveValue + "]Mod Options[/color] of " + ::ModPersistentCharacters.Name + ".";
			}
		});
	}

	function onUpdateScore()
	{
		// Only fired manually via ::ModPersistentCharacters.showInfoEventIfNewVersion
	}

	function onPrepare()
	{
	}

	function onPrepareVariables( _vars )
	{
	}

	function onClear()
	{
	}
});
