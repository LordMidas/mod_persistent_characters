::ModPersistentCharacters <- {
	Version = "0.1.8",
	ID = "mod_persistent_characters",
	Name = "Persistent Characters",
	Class = {}
};

::ModPersistentCharacters.MH <- ::Hooks.register(::ModPersistentCharacters.ID, ::ModPersistentCharacters.Version, ::ModPersistentCharacters.Name);
::ModPersistentCharacters.MH.require([
	"mod_msu",
]);

::ModPersistentCharacters.MH.queue(">mod_msu", function() {
	::ModPersistentCharacters.Mod <- ::MSU.Class.Mod(::ModPersistentCharacters.ID, ::ModPersistentCharacters.Version, ::ModPersistentCharacters.Name);

	::ModPersistentCharacters.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/LordMidas/mod_persistent_characters");
	::ModPersistentCharacters.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
	::ModPersistentCharacters.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/927");

	foreach (file in ::IO.enumerateFiles("mod_persistent_characters"))
	{
		::include(file);
	}

	::Hooks.registerJS("ui/mods/mod_persistent_characters/screens/persistent_characters_screen.js");
	::Hooks.registerCSS("ui/mods/mod_persistent_characters/screens/persistent_characters_screen.css");
});

::ModPersistentCharacters.MH.queue(function() {
	local player = ::new("scripts/entity/tactical/player");
	::ModPersistentCharacters.PlayerFieldsToClean = {
		Mood = player.m.Mood,
		MoodChanges = clone player.m.MoodChanges,
		LastDrinkTime = player.m.LastDrinkTime,
		LifetimeStats = clone player.m.LifetimeStats
	};

	::ModPersistentCharacters.Screen <- ::new("scripts/ui/mods/screens/persistent_characters_screen");
	::MSU.UI.registerConnection(::ModPersistentCharacters.Screen);

	::ModPersistentCharacters.Mod.Keybinds.addSQKeybind("toggleScreen", "ctrl+p", ::MSU.Key.State.All, ::ModPersistentCharacters.Screen.toggle.bindenv(::ModPersistentCharacters.Screen));
}, ::Hooks.QueueBucket.AfterHooks);
