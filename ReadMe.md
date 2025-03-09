## DESCRIPTION
This mod allows characters to persist across campaigns. Several mod settings are available for the player to tailor their experience to their liking.

### Key Features
- Characters can persist across campaigns. Persistence data for characters is only saved/updated when you Save Game.
- Persistent stats such as total number of kills, battles, days and permanent injuries are tracked.
- Characters from one campaign can appear as recruits in settlements in your future campaigns, with all their perks, items and levels intact.
- A unique event where a character from one of your older campaigns offers to join you in your current campaign.
- Import/Export feature to allow you to share your characters with others or save them for importing them later into another campaign at will

## HOW TO USE
### Installation
Download the .zip file attached to the latest [release](https://github.com/LordMidas/mod_persistent_characters/releases) and place it in your Battle Brothers game data folder. Do not Unzip the file.

### Mod Settings
All the mod settings are self-explanatory or have useful tooltips to describe their effect. Various mod settings such as Spawn Chance, Min Level to Spawn, Min Level to Save, Required Renown, Permanent Injuries, Perma Death etc. are available.

### Import/Export
Until the day that a more convenient UI to view all the saved campaigns and characters is created, we are using the MSU Mod Settings system as a poor man's Import/Export system.

Import/Export can only be done while you are in a game i.e. it cannot be done from the Main Menu. But once you are in a game, you can import/export from any saved campaign.

During this entire process, remember to check the Error Message box to view any errors.

#### Selecting a character to import/export
- Click on Campaigns List to view the names of your saved campaigns and their UIDs.
- Copy the UID of the campaign you want to import/export a character from.
- Paste it in the Campaign UID.
- Click Submit UIDs.
- Click on Characters List to view the names of the saved characters from that campaign and their UIDs.
- Copy the UID of the character you want to import/export.
- Paste it in the Character UID.
- Click Submit UIDs.

Now this character can be imported into your current campaign by clicking "Import by UID". Or you can export it to a file by clicking "Export to File". In both of these cases the persistent data attached to that character will be maintained. If you want to export without the persistent data, you should click "Export to File (Raw)". This may be useful when sharing your characters with other players.

DO NOT rename exported files. Their filename is important for reading them during import.

If you want to import a character from a file:

- Put the file in your savegames folder.
- Do NOT rename the file.
- Enter the filename in the Filename box in the Import from File section.
- Click Import from File button to import the character into your current campaign.
