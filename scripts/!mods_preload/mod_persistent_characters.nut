::ModPersistentCharacters <- {
	Version = "0.1.1",
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

	foreach (file in ::IO.enumerateFiles("mod_persistent_characters"))
	{
		::include(file);
	}
});

::ModPersistentCharacters.MH.queue(function() {
	local player = ::new("scripts/entity/tactical/player");
	::ModPersistentCharacters.PlayerFieldsToClean = {
		Mood = player.m.Mood,
		MoodChanges = clone player.m.MoodChanges,
		LastDrinkTime = player.m.LastDrinkTime,
		LifetimeStats = clone player.m.LifetimeStats
	};
}, ::Hooks.QueueBucket.AfterHooks);
