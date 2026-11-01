# Persistent Characters - notes

If this repo is cloned into a larger modding workspace, also read that workspace's shared CLAUDE.md (in the parent folder) and any local UI-screen skill, if present.

Build with [BBBuilder](https://github.com/TaroEld/BBbuilder): `BBbuilder build <path to this repo>` (`-rebuild` for a full rebuild) to confirm the Squirrel scripts compile; it does not check JS, so also run `node --check` on the screen JS. Requires only MSU + Modern Hooks; DynamicPerks, Legends and Reforged must stay optional (no hard references in JS; `::Hooks.hasMod` / `::MSU.isIn` checks in Squirrel).

Git: Conventional Commits as in the history (`feat:`, `fix:`, `docs:`, `chore: bump version to x.y.z`, `!` for data format breaks), first line at most 72 characters, lower-case summary. Files use CRLF (`core.autocrlf=true`).

Reference sources for vanilla behavior: the decompiled vanilla scripts/UI and the MSU, Modern Hooks, DynamicPerks and Legends repos.

## Layout
- `scripts/!mods_preload/mod_persistent_characters.nut` - registration, JS/CSS, screen instance `::ModPersistentCharacters.Screen`, keybind `toggleScreen` (Ctrl+P, `State.World`), `PlayerFieldsToClean` (fields reset before a snapshot).
- `mod_persistent_characters/` (auto-included): `globals_private.nut` (file I/O, world flags, required mods, info event trigger, tooltip helper), `actions.nut` (`::ModPersistentCharacters.Actions`: every player action + its `getCannot...Reason`, returning null or an error string, writing the file on change), `classes/` (data model), `hooks/`, `msu/` (mod settings, tooltips), `ui/ui_data_helper.nut` (conversion for the screen).
- `scripts/ui/mods/screens/persistent_characters_screen.nut` + `ui/mods/mod_persistent_characters/screens/*.js|css` - the screen. `scripts/events/events/` - join offer event and the version info event.

## Data model
- One global file (`Filename = "Data"`) holding a `DataManager`: campaigns (`CampaignData`: UID, name, banner, renown, `BroUIDs`) and bros (`PersistentBroData` extends `BroData`: snapshot = script + `SerData` (the bro's own `onSerialize`) + sprites). Every file this mod writes (data, exports) starts with `writeHeader` (magic string + `FormatVersion`); `readFromFile` ignores a mismatching/broken file, backs it up as `DataBackup` and starts empty. Bump `FormatVersion` on any format change; old data is not migrated (breaking release).
- **Home campaign**: `PersistentBroData.CampaignUID` (`getHomeCampaignUID`). Only the home campaign refreshes the snapshot (`update` -> `capture` on save); other campaigns only write their own `LifetimeStats[campaignUID]` entry. Data is authoritative over the entity flag `FlagID.CampaignUID` (old savegames of a former home must not reclaim him). Make Home moves the bro between `BroUIDs` and recaptures immediately.
- `CampaignData.BroUIDs` must agree with each bro's home. A recreated campaign (same UID) adopts bros whose home it is (`addNewCampaign`). Empty non-current campaigns are removed.
- **Loose bros**: home UID not in `Campaigns` (derived, not stored). Created when a campaign is pruned (Max Saved Campaigns) or deleted with "Make Loose"; limited by `MaxLooseBros` (oldest first). They spawn normally; renown check uses `HomeRenown`. `HomeName/Banner/Renown` are copied onto each bro on home saves.
- Save (`DataManager.onSaveCampaign`, called before vanilla save): creates/refreshes the current campaign, updates or adds roster bros (>= MinLevelToSave for new ones), removes home bros no longer in the roster (dismissed/dead are deleted, not loosened), blocks saved UIDs. With saving disabled (`FlagID.SavingDisabled`) only loaned bros' stats are updated.
- Spawning (settlements, join event): `DataManager.getRandomSpawnableBro()` picks a pool uniformly (eligible campaigns + loose pool) then a bro passing `canSpawn()` / `getCannotSpawnReason()`. Blocked bros (`FlagID.BlockedBros`, per campaign) are present in this campaign already.
- `createBro(roster, applySpawnSettings = true)`: spawn settings (permanent injury option) only for spawns/import; the screen preview and raw export pass `false`.

## Required mods
- Current campaign's choice: world flag `FlagID.RequiredMods` (`getRequiredModIDs` always adds installed `LockedMods`); edited in the screen; last choice kept in `DataManager.DefaultRequiredMods` and used for new campaigns.
- A bro stores `RequiredMods` (`modID -> name`, names so missing mods can be shown) captured together with his snapshot; a campaign's requirements are the union over its bros. Not loadable = some required mod not installed: never create such bros (greyed, name/level only in the UI).
- Raw export writes the union of the bro's mods and the current campaign's (he is re-serialized under the current session's mods).

## Screen
- In-game only: `show()` refuses unless `world_state`, empty MenuStack, no event screen, DataManager present. Backstep validator blocks Esc while a popup is open.
- Preview: a World roster created on show, deleted on hide; entities created only for loadable bros (`BroEntities` broUID -> entity). JS calls `SQ.call(handle, fn, args, cb)`; mutations return `{ Error }` and the JS re-queries. Disabled buttons get a `Text` tooltip with the `Actions.getCannot...Reason`.
- Tooltips (`msu/tooltips.nut`): `CampaignEntry` (`campaignUID`), `BroEntry` (`broUID`), `ModEntry` (`modID`), `Text` (`title`, `text`, optional `lines: [{icon, text}]`).
- Perk tree source: DynamicPerks tree, else background `getPerkTree()` (Legends), else `::Const.Perks.Perks`; scaled down in JS (from rem sizes) when too wide/tall.
- Layout is fixed rem (dialog 184rem x 98rem) so it scales with the game's UI scale: no % of screen, no JS pixel measuring. Only exception: `fitToScreen` (on show) scales the whole dialog down with a transform when the window is smaller than 184 x 98rem (e.g. 1600x900 at 100% = 160 x 90rem). Coherent draws no native scrollbars: use vanilla `createList` (create it after its parent is in the DOM, then `list.trigger('update', true)`).

## Settings / misc
- Mod settings: General page only (spawn chance, levels, renown %, max campaigns, max loose, cost mults, permanent injuries, perma death, delete file). Import/export and required mods live in the screen.
- Version info event: shown once per campaign per mod version (`FlagID.LastSeenVersion`), fired with a retry loop after load/start.
- Version bump = `chore: bump version to x.y.z` (`Version` in the preload); a bump re-shows the info event.

## Manual test checklist
Home authority (level in home A, loan to B, reload old A save, Make Home in B); loose bros spawn and come back when their campaign is saved again; missing-mod campaigns/bros greyed with no errors in log.html; required mods survive save/load and default for new campaigns; export/import (normal, raw, other machine without your data); saving toggle (keep/loose/delete); screen at UI scale 100% and 170%; with Legends and with DynamicPerks/Reforged.
