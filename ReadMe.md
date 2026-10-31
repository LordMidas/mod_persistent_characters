## DESCRIPTION
This mod allows characters to persist across campaigns. Several mod settings are available for the player to tailor their experience to their liking.

### Key Features
- Characters can persist across campaigns. Persistence data for characters is only saved/updated when you Save Game.
- Persistent stats such as total number of kills, battles, days and permanent injuries are tracked per campaign.
- Characters from one campaign can appear as recruits in settlements in your future campaigns, with all their perks, items and levels intact.
- A unique event where a character from one of your older campaigns offers to join you in your current campaign.
- A Persistent Characters screen (Ctrl+P during a campaign) to browse saved campaigns and characters, view their gear, stats and perks, import/export/delete them and choose the mods required for the current campaign.

## HOW TO USE
### Installation
Download the .zip file attached to the latest [release](https://github.com/LordMidas/mod_persistent_characters/releases) and place it in your Battle Brothers game data folder. Do not Unzip the file.

### Mod Settings
All the mod settings are self-explanatory or have useful tooltips to describe their effect. Various mod settings such as Spawn Chance, Min Level to Spawn, Min Level to Save, Required Renown, Permanent Injuries, Perma Death etc. are available.

### Persistent Characters screen
Press Ctrl+P during a campaign to open the screen (the keybind can be changed in the mod settings). It is not available on the Main Menu.

- **Campaigns**: the list of campaigns with saved characters. Campaigns that need mods which are not installed are greyed out; hover over them to see the missing mods.
- **Loose Characters**: characters whose campaign was removed (via Max Saved Campaigns or deleted in the screen). They can still spawn in your campaigns. Their number is limited by the Max Loose Characters setting.
- **Characters**: click a campaign to see its characters, and click a character to see his gear, stats, perks and service record.
- **Import to Company**: adds the character to your current company.
- **Make Home Company**: a character's saved version is only updated by his home company (by default the campaign in which he was first saved). In other campaigns he is on loan: his service there is recorded but his saved version does not change. Use this button on a character in your company to make your current campaign his home company.
- **Export / Export Raw**: writes the character to a file in your savegames folder. Raw exports do not carry the persistence data, so the character becomes a new persistent character of whichever campaign imports him. Use **Import from File** to import exported characters.
- **Required Mods**: choose which installed mods are required by the characters saved from the current campaign. Characters are only spawned or importable in sessions where all their required mods are installed. Popular save-incompatible mods are always required. Your choice is remembered for new campaigns.
- **Save characters of current campaign**: untick to stop characters whose home is the campaign you are currently playing from being saved or updated as persistent characters (e.g. for test runs). You can choose to keep, loosen or delete the existing data of the campaign.
- You can also delete characters and campaigns (choosing whether the characters of a deleted campaign become loose or are deleted too) and mark characters as dead or alive in each campaign of their service record.

### Updating from 0.1.x
Version 0.2.0 changes the format of the persistent data. Delete the old data file via the "Delete File" button in the mod settings before or after updating. Your savegames are not affected, but previously saved and exported characters cannot be loaded.
