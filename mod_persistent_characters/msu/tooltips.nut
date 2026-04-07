::ModPersistentCharacters.Mod.Tooltips.setTooltips({
	CampaignEntry = ::MSU.Class.CustomTooltip(function( _data ) {
		_data = _data.ExtraData;

		local arr = split(_data, ",");
		::MSU.Log.printData(arr);
		local info = {};
		for (local i = 0; i < arr.len(); i++) // start at idx 1 because 0 is filename and already added
		{
			local pair = split(arr[i], ":");
			info[pair[0]] <- pair[1] == "null" ? null : pair[1];
		}

		local ret = [
			{ id = 1, type = "title", text = info.Name }
		];

		if ("MissingMods" in info)
		{
			ret.push({
				id = 10,	type = "text",	icon = "ui/icons/warning.png",
				text = "Missing Mods: ",
				children = split(info.MissingMods, "%%").map(@(_modID) {
					id = 10,	type = "text",	text = _modID
				})
			});
		}

		return ret;
	})
});
