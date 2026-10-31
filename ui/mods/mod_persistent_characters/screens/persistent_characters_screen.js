"use strict";

var ModPersistentCharactersScreen = function ()
{
	MSUUIScreen.call(this);
	this.mModID = "mod_persistent_characters";
	this.mID = "ModPersistentCharactersScreen";

	// containers
	this.mContainer = null;
	this.mDialogContainer = null;
	this.mCampaignListContainer = null;
	this.mCampaignListScrollContainer = null;
	this.mBroListContainer = null;
	this.mBroListScrollContainer = null;

	// left column buttons
	this.mRequiredModsButton = null;
	this.mDeleteCampaignButton = null;
	this.mSavingCheckbox = null;
	this.mSavingRow = null;
	this.mIgnoreSavingEvent = false;
	this.mCurrentCampaignName = '';

	// footer
	this.mImportFileButton = null;
	this.mCloseButton = null;
	this.mStatusLabel = null;

	// details panel
	this.mDetails = {
		Container: null,
		Slots: null,
		BagSlots: null,
		BagLayout: null,
		Paperdoll: null,

		StatRows: null,
		PerksContainer: null,
		ServiceList: null,
		ServiceScroll: null,
		ServiceHeader: null,
		Buttons: null
	};

	// state
	this.mCurrentCampaignUID = null;
	this.mLooseUID = null;
	this.mCampaigns = [];
	this.mBros = [];
	this.mSelectedCampaign = null;
	this.mSelectedBroUID = null;
	this.mBroData = null;
	this.mCampaignRequest = 0;
	this.mBroRequest = 0;
	this.mLoadRequest = 0;
};

ModPersistentCharactersScreen.prototype = Object.create(MSUUIScreen.prototype);
Object.defineProperty(ModPersistentCharactersScreen.prototype, "constructor", {
	value: ModPersistentCharactersScreen,
	enumerable: false,
	writable: true
});

// Definitions of the stat rows. Key is the key of the value in the stats data.
ModPersistentCharactersScreen.StatDefinitions = [
	[
		{ Key: 'armorHead', Max: 'armorHeadMax', Both: true, Icon: Asset.ICON_ARMOR_HEAD, Style: ProgressbarStyleIdentifier.ArmorHead, Tooltip: TooltipIdentifier.CharacterStats.ArmorHead },
		{ Key: 'armorBody', Max: 'armorBodyMax', Both: true, Icon: Asset.ICON_ARMOR_BODY, Style: ProgressbarStyleIdentifier.ArmorBody, Tooltip: TooltipIdentifier.CharacterStats.ArmorBody },
		{ Key: 'hitpoints', Max: 'hitpointsMax', Both: true, Talent: 'hitpointsTalent', Icon: Asset.ICON_HEALTH, Style: ProgressbarStyleIdentifier.Hitpoints, Tooltip: TooltipIdentifier.CharacterStats.Hitpoints },
		{ Key: 'actionPoints', Max: 'actionPointsMax', Both: true, Icon: Asset.ICON_ACTION_POINTS, Style: ProgressbarStyleIdentifier.ActionPoints, Tooltip: TooltipIdentifier.CharacterStats.ActionPoints },
		{ Key: 'fatigue', Max: 'fatigueMax', Both: true, Talent: 'fatigueTalent', Icon: Asset.ICON_FATIGUE, Style: ProgressbarStyleIdentifier.Fatigue, Tooltip: TooltipIdentifier.CharacterStats.Fatigue },
		{ Key: 'morale', Max: 'moraleMax', Label: 'moraleLabel', Icon: Asset.ICON_MORALE, Style: ProgressbarStyleIdentifier.Morale, Tooltip: TooltipIdentifier.CharacterStats.Morale },
		{ Key: 'bravery', Max: 'braveryMax', Talent: 'braveryTalent', Icon: Asset.ICON_BRAVERY, Style: ProgressbarStyleIdentifier.Bravery, Tooltip: TooltipIdentifier.CharacterStats.Bravery },
		{ Key: 'initiative', Max: 'initiativeMax', Talent: 'initiativeTalent', Icon: Asset.ICON_INITIATIVE, Style: ProgressbarStyleIdentifier.Initiative, Tooltip: TooltipIdentifier.CharacterStats.Initiative }
	],
	[
		{ Key: 'meleeSkill', Max: 'meleeSkillMax', Talent: 'meleeSkillTalent', Icon: Asset.ICON_MELEE_SKILL, Style: ProgressbarStyleIdentifier.MeleeSkill, Tooltip: TooltipIdentifier.CharacterStats.MeleeSkill },
		{ Key: 'rangeSkill', Max: 'rangeSkillMax', Talent: 'rangeSkillTalent', Icon: Asset.ICON_RANGE_SKILL, Style: ProgressbarStyleIdentifier.RangeSkill, Tooltip: TooltipIdentifier.CharacterStats.RangeSkill },
		{ Key: 'meleeDefense', Max: 'meleeDefenseMax', Talent: 'meleeDefenseTalent', Icon: Asset.ICON_MELEE_DEFENCE, Style: ProgressbarStyleIdentifier.MeleeDefense, Tooltip: TooltipIdentifier.CharacterStats.MeleeDefense },
		{ Key: 'rangeDefense', Max: 'rangeDefenseMax', Talent: 'rangeDefenseTalent', Icon: Asset.ICON_RANGE_DEFENCE, Style: ProgressbarStyleIdentifier.RangeDefense, Tooltip: TooltipIdentifier.CharacterStats.RangeDefense },
		{ Key: 'regularDamage', Max: 'regularDamageMax', Label: 'regularDamageLabel', Icon: Asset.ICON_REGULAR_DAMAGE, Style: ProgressbarStyleIdentifier.RegularDamage, Tooltip: TooltipIdentifier.CharacterStats.RegularDamage },
		{ Key: 'crushingDamage', Max: 'crushingDamageMax', Label: 'crushingDamageLabel', Icon: Asset.ICON_CRUSHING_DAMAGE, Style: ProgressbarStyleIdentifier.CrushingDamage, Tooltip: TooltipIdentifier.CharacterStats.CrushingDamage },
		{ Key: 'chanceToHitHead', Max: 'chanceToHitHeadMax', Label: 'chanceToHitHeadLabel', Icon: Asset.ICON_CHANCE_TO_HIT_HEAD, Style: ProgressbarStyleIdentifier.ChanceToHitHead, Tooltip: TooltipIdentifier.CharacterStats.ChanceToHitHead },
		{ Key: 'sightDistance', Max: 'sightDistanceMax', Icon: Asset.ICON_SIGHT_DISTANCE, Style: ProgressbarStyleIdentifier.SightDistance, Tooltip: TooltipIdentifier.CharacterStats.SightDistance }
	]
];

ModPersistentCharactersScreen.escapeHTML = function (_text)
{
	return $('<div/>').text(_text === null || _text === undefined ? '' : '' + _text).html();
};

// ---------------------------------------------------------------------------------------------
// Creation / destruction
// ---------------------------------------------------------------------------------------------

ModPersistentCharactersScreen.prototype.createDIV = function (_parentDiv)
{
	var self = this;

	this.mContainer = $('<div class="mod_persistent_characters_screen display-none opacity-none"/>');
	_parentDiv.append(this.mContainer);
	this.mDialogContainer = this.mContainer.createDialog('Persistent Characters', ' ', '', false, 'rf-dialog-max');

	var content = this.mDialogContainer.findDialogContentContainer();

	// left column: campaigns
	var column = $('<div class="column is-left"/>');
	content.append(column);
	var listLayout = $('<div class="l-list-container"/>');
	column.append(listLayout);
	this.mCampaignListContainer = listLayout.createList(1.77);
	this.mCampaignListScrollContainer = this.mCampaignListContainer.findListScrollContainer();

	var buttonLayout = $('<div class="l-left-buttons"/>');
	column.append(buttonLayout);

	this.mSavingRow = $('<div class="l-save-row"/>');
	buttonLayout.append(this.mSavingRow);
	this.mSavingCheckbox = this.createCheckbox(true, false);
	var savingCheckLayout = $('<div class="l-save-check"/>');
	savingCheckLayout.append(this.mSavingCheckbox);
	this.mSavingRow.append(savingCheckLayout);
	var savingLabel = $('<div class="l-save-label text-font-small font-color-subtitle">Save characters of current campaign</div>');
	this.mSavingRow.append(savingLabel);
	this.initCheckbox(this.mSavingCheckbox);
	this.updateSavingTooltip();
	savingLabel.click(function ()
	{
		self.mSavingCheckbox.iCheck('toggle');
	});
	this.mSavingCheckbox.on('ifChecked ifUnchecked', null, this, function (_event)
	{
		if (self.mIgnoreSavingEvent)
			return;

		if (_event.type === 'ifChecked')
			self.mutate('onSetSavingEnabled', [true, 'keep'], 'Saving characters of the current campaign is enabled.', self.mSelectedCampaign, self.mSelectedBroUID);
		else
			self.openStopSavingPopup();
	});
	var layout = $('<div class="l-column-button"/>');
	buttonLayout.append(layout);
	this.mRequiredModsButton = layout.createTextButton('Required Mods...', function ()
	{
		self.openRequiredModsPopup();
	}, '', 1);
	this.mRequiredModsButton.bindTooltip(this.getTextTooltip('Required Mods', 'Choose which mods are required by characters saved from this company. Characters can only be loaded when all of their required mods are installed.'));
	layout = $('<div class="l-column-button"/>');
	buttonLayout.append(layout);
	this.mDeleteCampaignButton = layout.createTextButton('Delete Company', function ()
	{
		self.onDeleteCampaignPressed();
	}, '', 1);

	// middle column: bros
	column = $('<div class="column is-middle"/>');
	content.append(column);
	listLayout = $('<div class="l-list-container"/>');
	column.append(listLayout);
	this.mBroListContainer = listLayout.createList(1.77);
	this.mBroListScrollContainer = this.mBroListContainer.findListScrollContainer();

	// right column: details
	column = $('<div class="column is-right"/>');
	content.append(column);
	this.createDetailsDIV(column);

	// footer
	var footer = this.mDialogContainer.findDialogFooterContainer();
	var footerBar = $('<div class="l-button-bar"/>');
	footer.append(footerBar);

	layout = $('<div class="l-import-file-button"/>');
	footerBar.append(layout);
	this.mImportFileButton = layout.createTextButton('Import from File...', function ()
	{
		self.openImportFilePopup();
	}, '', 1);
	this.mImportFileButton.bindTooltip(this.getTextTooltip('Import from File', 'Import a character which was exported to a file into your company.'));

	this.mStatusLabel = $('<div class="status-label text-font-normal font-color-description"/>');
	footerBar.append(this.mStatusLabel);

	layout = $('<div class="l-close-button"/>');
	footerBar.append(layout);
	this.mCloseButton = layout.createTextButton('Close', function ()
	{
		self.notifyBackendClosePressed();
	}, '', 1);

	this.mIsVisible = false;

};

ModPersistentCharactersScreen.prototype.createDetailsDIV = function (_column)
{
	var self = this;
	var d = this.mDetails;

	var frame = $('<div class="l-details-frame"/>');
	_column.append(frame);
	d.Container = $('<div class="details-container display-none"/>');
	frame.append(d.Container);

	// paperdoll
	var gearCell = $('<div class="pc-cell pc-cell-tl"/>');
	d.Container.append(gearCell);
	// same structure and classes as the vanilla character screen paperdoll module
	var paperdoll = $('<div class="paperdoll-module"/>');
	gearCell.append(paperdoll);
	d.Paperdoll = paperdoll;

	var columns = [
		{ Class: 'equipment-column', Layout: 'l-equipment-column is-left', Slots: [
			{ Key: 'accessory', Big: false, Classes: 'is-top-big-offset', Background: Asset.SLOT_BACKGROUND_ACCESSORY },
			{ Key: 'mainhand', Big: true, Classes: 'is-big is-in-between-offset', Background: Asset.SLOT_BACKGROUND_MAINHAND }
		] },
		{ Class: 'equipment-column is-middle', Layout: 'l-equipment-column', Slots: [
			{ Key: 'head', Big: false, Classes: 'is-top-small-offset', Background: Asset.SLOT_BACKGROUND_HELMET },
			{ Key: 'body', Big: true, Classes: 'is-big is-in-between-offset', Background: Asset.SLOT_BACKGROUND_BODY }
		] },
		{ Class: 'equipment-column', Layout: 'l-equipment-column is-right', Slots: [
			{ Key: 'ammo', Big: false, Classes: 'is-top-big-offset', Background: Asset.SLOT_BACKGROUND_AMMO },
			{ Key: 'offhand', Big: true, Classes: 'is-big is-in-between-offset', Background: Asset.SLOT_BACKGROUND_OFFHAND }
		] }
	];
	d.Slots = {};
	$.each(columns, function (_i, _column)
	{
		var column = $('<div class="' + _column.Class + '"/>');
		paperdoll.append(column);
		var layout = $('<div class="' + _column.Layout + '"/>');
		column.append(layout);
		$.each(_column.Slots, function (_j, _def)
		{
			var slotLayout = $('<div class="l-slot-container ' + _def.Classes + '"/>');
			layout.append(slotLayout);
			d.Slots[_def.Key] = { Container: slotLayout.createPaperdollItem(_def.Big, Path.GFX + _def.Background), IsBig: _def.Big };
		});
	});

	var backpackRow = $('<div class="backpack-row"/>');
	paperdoll.append(backpackRow);
	d.BagLayout = $('<div class="l-backpack-row has-slot-4"/>');
	backpackRow.append(d.BagLayout);
	d.BagSlots = [];
	for (var i = 0; i < Constants.Game.MAX_BACKPACK_SLOTS; ++i)
	{
		var bagLayout = $('<div class="l-slot-container is-backpack"/>');
		d.BagLayout.append(bagLayout);
		d.BagSlots.push({ Container: bagLayout.createPaperdollItem(false, Path.GFX + Asset.SLOT_BACKGROUND_BAG), IsBig: false });
	}

	// stats
	var statsCell = $('<div class="pc-cell pc-cell-bl"/>');
	d.Container.append(statsCell);
	var stats = $('<div class="pc-stats"/>');
	statsCell.append(stats);
	d.StatRows = [];
	$.each(ModPersistentCharactersScreen.StatDefinitions, function (_index, _definitions)
	{
		var statColumn = $('<div class="pc-stat-column"/>');
		stats.append(statColumn);
		$.each(_definitions, function (_i, _def)
		{
			var row = $('<div class="pc-stat-row"/>');
			statColumn.append(row);
			var iconColumn = $('<div class="pc-stat-icon"/>');
			row.append(iconColumn);
			var icon = $('<img/>');
			icon.attr('src', Path.GFX + _def.Icon);
			iconColumn.append(icon);
			var talent = $('<img class="pc-talent"/>');
			iconColumn.append(talent);
			var barColumn = $('<div class="pc-stat-bar"/>');
			row.append(barColumn);
			var bar = barColumn.createProgressbar(true, _def.Style);
			row.bindTooltip({ contentType: 'ui-element', elementId: _def.Tooltip });
			d.StatRows.push({ Definition: _def, Row: row, Bar: bar, Talent: talent });
		});
	});

	// perks
	var perks = $('<div class="pc-cell pc-cell-tr pc-perks"/>');
	d.Container.append(perks);
	d.PerksContainer = $('<div class="pc-perk-tree"/>');
	perks.append(d.PerksContainer);

	// service record
	var service = $('<div class="pc-cell pc-cell-br pc-service"/>');
	d.Container.append(service);
	service.append($('<div class="pc-section-title title-font-normal font-bold font-color-title">Service Record</div>'));
	d.ServiceHeader = $('<div class="pc-service-row is-header text-font-small font-bold font-color-title"><div class="c-name">Company</div><div class="c-num c-days">Days</div><div class="c-num c-battles">Battles</div><div class="c-num c-kills">Kills</div><div class="c-dead">Dead</div></div>');
	service.append(d.ServiceHeader);
	var serviceListLayout = $('<div class="pc-service-list"/>');
	service.append(serviceListLayout);
	d.ServiceList = serviceListLayout.createList(1.77, null, true);
	d.ServiceScroll = d.ServiceList.findListScrollContainer();

	// buttons
	var buttons = $('<div class="pc-buttons"/>');
	d.Container.append(buttons);
	d.Buttons = {};
	var buttonDefinitions = [
		{ Key: 'Import', Label: 'Import', Handler: function () { self.onImportPressed(); } },
		{ Key: 'MakeHome', Label: 'Make Home', Handler: function () { self.onMakeHomePressed(); } },
		{ Key: 'Export', Label: 'Export', Handler: function () { self.onExportPressed(false); } },
		{ Key: 'ExportRaw', Label: 'Export Raw', Handler: function () { self.onExportPressed(true); } },
		{ Key: 'Delete', Label: 'Delete Character', Handler: function () { self.onDeleteBroPressed(); } }
	];
	$.each(buttonDefinitions, function (_i, _def)
	{
		var layout = $('<div class="l-detail-button"/>');
		buttons.append(layout);
		d.Buttons[_def.Key] = { Label: _def.Label, Button: layout.createTextButton(_def.Label, _def.Handler, '', 1) };
	});
};

ModPersistentCharactersScreen.prototype.destroyDIV = function ()
{
	this.destroyPopupDialog();

	var d = this.mDetails;

	$.each(d.StatRows || [], function (_i, _row)
	{
		_row.Row.unbindTooltip();
		_row.Bar.empty();
		_row.Bar.remove();
		_row.Row.empty();
		_row.Row.remove();
	});
	d.StatRows = null;

	$.each(d.Slots || {}, function (_key, _slot)
	{
		_slot.Container.unbindTooltip();
		_slot.Container.empty();
		_slot.Container.remove();
	});
	d.Slots = null;

	$.each(d.BagSlots || [], function (_i, _slot)
	{
		_slot.Container.unbindTooltip();
		_slot.Container.empty();
		_slot.Container.remove();
	});
	d.BagSlots = null;
	d.BagLayout = null;
	d.Paperdoll.empty();
	d.Paperdoll.remove();
	d.Paperdoll = null;

	$.each(d.Buttons || {}, function (_key, _entry)
	{
		_entry.Button.unbindTooltip();
		_entry.Button.remove();
	});
	d.Buttons = null;

	d.ServiceScroll.empty();
	d.ServiceScroll = null;
	d.ServiceList.destroyList();
	d.ServiceList.remove();
	d.ServiceList = null;
	d.ServiceHeader.remove();
	d.ServiceHeader = null;

	d.PerksContainer.empty();
	d.PerksContainer.remove();
	d.PerksContainer = null;

	d.Container.empty();
	d.Container.remove();
	d.Container = null;

	this.mSavingCheckbox.off('ifChecked ifUnchecked');
	this.mSavingRow.unbindTooltip();
	this.mSavingRow.empty();
	this.mSavingRow.remove();
	this.mSavingRow = null;
	this.mSavingCheckbox = null;

	this.mRequiredModsButton.unbindTooltip();
	this.mRequiredModsButton.remove();
	this.mRequiredModsButton = null;
	this.mDeleteCampaignButton.unbindTooltip();
	this.mDeleteCampaignButton.remove();
	this.mDeleteCampaignButton = null;
	this.mImportFileButton.unbindTooltip();
	this.mImportFileButton.remove();
	this.mImportFileButton = null;
	this.mCloseButton.remove();
	this.mCloseButton = null;
	this.mStatusLabel.remove();
	this.mStatusLabel = null;

	this.mBroListScrollContainer.empty();
	this.mBroListScrollContainer = null;
	this.mBroListContainer.destroyList();
	this.mBroListContainer.remove();
	this.mBroListContainer = null;

	this.mCampaignListScrollContainer.empty();
	this.mCampaignListScrollContainer = null;
	this.mCampaignListContainer.destroyList();
	this.mCampaignListContainer.remove();
	this.mCampaignListContainer = null;

	this.mDialogContainer.empty();
	this.mDialogContainer.remove();
	this.mDialogContainer = null;

	this.mContainer.empty();
	this.mContainer.remove();
	this.mContainer = null;

	this.mCampaigns = [];
	this.mBros = [];
	this.mBroData = null;
	this.mSelectedCampaign = null;
	this.mSelectedBroUID = null;
};

// ---------------------------------------------------------------------------------------------
// Show / hide
// ---------------------------------------------------------------------------------------------

ModPersistentCharactersScreen.prototype.show = function (_moveLeftRight, _considerParent)
{
	MSUUIScreen.prototype.show.call(this, _moveLeftRight, _considerParent);
	this.mSelectedCampaign = null;
	this.mSelectedBroUID = null;
	this.mBroData = null;
	this.setStatus('', false);
	this.loadAll(null, null);
};

ModPersistentCharactersScreen.prototype.hide = function (_moveLeftRight, _considerParent)
{
	this.destroyPopupDialog();
	this.mLoadRequest++;
	this.mCampaignRequest++;
	this.mBroRequest++;
	MSUUIScreen.prototype.hide.call(this, _moveLeftRight, _considerParent);
};

// ---------------------------------------------------------------------------------------------
// Backend communication
// ---------------------------------------------------------------------------------------------

ModPersistentCharactersScreen.prototype.notifyBackendPopupVisible = function (_data)
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onPopupVisible', _data);
	}
};

ModPersistentCharactersScreen.prototype.notifyBackendClosePressed = function ()
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onClosePressed');
	}
};

ModPersistentCharactersScreen.prototype.call = function (_function, _args, _callback)
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, _function, _args, _callback);
	}
};

// Calls a mutating backend function and then reloads everything keeping the selection if possible.
ModPersistentCharactersScreen.prototype.mutate = function (_function, _args, _successText, _keepCampaignUID, _keepBroUID)
{
	var self = this;
	this.call(_function, _args, function (_result)
	{
		if (self.mContainer === null)
			return;

		if (_result !== null && _result !== undefined && _result.Error !== null && _result.Error !== undefined)
		{
			self.setStatus(_result.Error, true);
		}
		else
		{
			self.setStatus(_successText, false);
		}
		self.loadAll(_keepCampaignUID, _keepBroUID);
	});
};

ModPersistentCharactersScreen.prototype.setStatus = function (_text, _isError)
{
	if (this.mStatusLabel === null)
		return;

	this.mStatusLabel.removeClass('font-color-description font-color-assets-negative-value');
	this.mStatusLabel.addClass(_isError === true ? 'font-color-assets-negative-value' : 'font-color-description');
	this.mStatusLabel.text(_text === null || _text === undefined ? '' : _text);
};

ModPersistentCharactersScreen.prototype.getTextTooltip = function (_title, _text)
{
	return { contentType: 'msu-generic', modId: this.mModID, elementId: 'Text', title: _title, text: _text };
};

// Enables _button if _reason is null, otherwise disables it. The tooltip shows either the reason or the description.
ModPersistentCharactersScreen.prototype.setButtonState = function (_button, _title, _description, _reason)
{
	_button.enableButton(_reason === null || _reason === undefined);
	_button.unbindTooltip();
	var text = (_reason === null || _reason === undefined) ? _description : _reason;
	if (text !== null && text !== undefined && text !== '')
	{
		_button.bindTooltip(this.getTextTooltip(_title, text));
	}
};

// ---------------------------------------------------------------------------------------------
// Campaigns
// ---------------------------------------------------------------------------------------------

ModPersistentCharactersScreen.prototype.loadAll = function (_campaignUID, _broUID)
{
	var self = this;
	var request = ++this.mLoadRequest;

	this.call('queryData', null, function (_data)
	{
		if (self.mContainer === null || request !== self.mLoadRequest || _data === null || _data === undefined)
			return;

		self.mCurrentCampaignUID = _data.CurrentCampaignUID;
		self.mCurrentCampaignName = _data.CurrentCampaignName;
		self.updateSavingTooltip();
		self.setSavingChecked(_data.IsSavingEnabled !== false);
		self.mLooseUID = _data.LooseCampaignUID;
		self.mCampaigns = _data.Campaigns;
		self.mDialogContainer.findDialogSubTitle().text(_data.CurrentCampaignName);
		self.populateCampaigns();

		var wanted = _campaignUID !== null && _campaignUID !== undefined ? _campaignUID : self.mCurrentCampaignUID;
		var campaign = self.findCampaign(wanted);
		if (campaign === null || !campaign.IsLoadable)
		{
			campaign = null;
			for (var i = 0; i < self.mCampaigns.length; ++i)
			{
				if (self.mCampaigns[i].IsLoadable)
				{
					campaign = self.mCampaigns[i];
					break;
				}
			}
		}

		self.selectCampaign(campaign === null ? null : campaign.UID, _broUID);
	});
};

ModPersistentCharactersScreen.prototype.findCampaign = function (_uid)
{
	for (var i = 0; i < this.mCampaigns.length; ++i)
	{
		if (this.mCampaigns[i].UID === _uid)
			return this.mCampaigns[i];
	}
	return null;
};

ModPersistentCharactersScreen.prototype.populateCampaigns = function ()
{
	this.mCampaignListScrollContainer.empty();
	for (var i = 0; i < this.mCampaigns.length; ++i)
	{
		this.addCampaignEntry(this.mCampaigns[i]);
	}
};

ModPersistentCharactersScreen.prototype.addCampaignEntry = function (_data)
{
	var self = this;
	var esc = ModPersistentCharactersScreen.escapeHTML;
	var isLoose = _data.UID === this.mLooseUID;

	var entry = this.mCampaignListScrollContainer.createListCampaign(_data);
	entry.attr('data-uid', _data.UID);
	entry.assignListCampaignName(esc(_data.Name));
	entry.assignListImage(isLoose ? 'ui/icons/asset_brothers.png' : 'ui/banners/' + _data.Banner + '.png');
	if (isLoose)
		entry.addClass('is-loose');
	entry.bindTooltip({ contentType: 'msu-generic', modId: this.mModID, elementId: 'CampaignEntry', campaignUID: _data.UID });

	if (!_data.IsLoadable)
	{
		entry.assignListCampaignGroupName('');
		entry.assignListCampaignDayName('Missing mods');
		entry.addClass('is-disabled');
		return;
	}

	entry.assignListCampaignGroupName(_data.NumBros + (_data.NumBros === 1 ? ' character' : ' characters'));
	entry.assignListCampaignDayName(_data.Renown !== null ? 'Renown: ' + _data.Renown : '');
	if (_data.IsCurrent)
	{
		entry.assignListCampaignDateTime('(This company)');
	}

	entry.assignListCampaignClickHandler(function (_entry, _event)
	{
		if (self.mSelectedCampaign !== _data.UID)
		{
			self.selectCampaign(_data.UID, null);
		}
	});
};

ModPersistentCharactersScreen.prototype.selectCampaign = function (_uid, _keepBroUID)
{
	var self = this;
	var request = ++this.mCampaignRequest;

	this.mSelectedCampaign = _uid;
	this.mCampaignListScrollContainer.find('.is-selected').removeClass('is-selected');
	if (_uid !== null)
	{
		this.mCampaignListScrollContainer.find('.ui-control.campaign').each(function (_index, _element)
		{
			if ($(_element).attr('data-uid') === _uid)
				$(_element).addClass('is-selected');
		});
	}
	this.updateCampaignButtons();

	this.mBroListScrollContainer.empty();
	this.mBros = [];
	this.mSelectedBroUID = null;
	this.showDetails(null);

	if (_uid === null)
		return;

	this.call('onCampaignSelected', _uid, function (_bros)
	{
		if (self.mContainer === null || request !== self.mCampaignRequest || _bros === null || _bros === undefined)
			return;

		self.mBros = _bros;
		self.populateBros();

		var bro = null;
		for (var i = 0; i < _bros.length; ++i)
		{
			if (_bros[i].IsLoadable && (bro === null || _bros[i].UID === _keepBroUID))
			{
				bro = _bros[i];
				if (_bros[i].UID === _keepBroUID)
					break;
			}
		}
		self.selectBro(bro === null ? null : bro.UID);
	});
};

ModPersistentCharactersScreen.prototype.updateCampaignButtons = function ()
{
	var self = this;
	var button = this.mDeleteCampaignButton;
	var campaign = this.mSelectedCampaign === null ? null : this.findCampaign(this.mSelectedCampaign);

	if (campaign === null)
	{
		button.changeButtonText('Delete Company');
		this.setButtonState(button, 'Delete Company', '', 'No company selected');
	}
	else if (campaign.UID === this.mLooseUID)
	{
		button.changeButtonText('Delete All Loose');
		this.setButtonState(button, 'Delete All Loose Characters', 'Permanently delete all loose characters from the persistent data.', campaign.NumBros === 0 ? 'There are no loose characters' : null);
	}
	else
	{
		button.changeButtonText('Delete Company');
		this.setButtonState(button, 'Delete Company', 'Remove this company from the persistent data. Its characters become loose characters.', campaign.DeleteReason);
	}
};

// ---------------------------------------------------------------------------------------------
// Bros
// ---------------------------------------------------------------------------------------------

ModPersistentCharactersScreen.prototype.populateBros = function ()
{
	this.mBroListScrollContainer.empty();
	for (var i = 0; i < this.mBros.length; ++i)
	{
		this.addBroEntry(this.mBros[i]);
	}
};

ModPersistentCharactersScreen.prototype.addBroEntry = function (_data)
{
	var self = this;
	var esc = ModPersistentCharactersScreen.escapeHTML;

	var result = $('<div class="l-row"/>');
	this.mBroListScrollContainer.append(result);

	var entry = $('<div class="ui-control list-entry"/>');
	result.append(entry);
	entry.data('entry', _data);
	entry.attr('data-uid', _data.UID);
	entry.bindTooltip({ contentType: 'msu-generic', modId: this.mModID, elementId: 'BroEntry', broUID: _data.UID });

	// left column
	var column = $('<div class="column is-left"/>');
	entry.append(column);

	// right column
	var rightColumn = $('<div class="column is-right"/>');
	entry.append(rightColumn);

	var row = $('<div class="row is-top"/>');
	rightColumn.append(row);

	if (!_data.IsLoadable)
	{
		entry.addClass('is-disabled');
		row.append($('<div class="name title-font-normal font-bold font-color-disabled no-icon">' + esc(_data.Name) + '</div>'));
		var disabledLevelContainer = $('<div class="l-level-container"/>');
		row.append(disabledLevelContainer);
		var disabledLevelImage = $('<img class="is-grayscale"/>');
		disabledLevelImage.attr('src', Path.GFX + Asset.ICON_LEVEL);
		disabledLevelContainer.append(disabledLevelImage);
		disabledLevelContainer.append($('<div class="level text-font-normal font-bold font-color-disabled">' + _data.Level + '</div>'));
		var bottom = $('<div class="row is-bottom"/>');
		rightColumn.append(bottom);
		bottom.append($('<div class="is-badges text-font-small font-color-disabled">Missing required mods</div>'));
		return;
	}

	entry.click(this, function (_event)
	{
		self.selectBro(_data.UID);
	});

	column.createImage(Path.PROCEDURAL + _data.ImagePath, function (_image)
	{
		_image.centerImageWithinParent(_data.ImageOffsetX, _data.ImageOffsetY, 0.64, false);
		_image.removeClass('opacity-none');
	}, null, 'opacity-none');

	var icon = $('<img/>');
	icon.attr('src', Path.GFX + _data.BackgroundImagePath);
	row.append(icon);
	icon.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.CharacterBackgrounds.Generic, elementOwner: TooltipIdentifier.ElementOwner.HireScreen, entityId: _data.ID });

	row.append($('<div class="name title-font-normal font-bold font-color-title">' + esc(_data.Name) + '</div>'));

	var levelContainer = $('<div class="l-level-container"/>');
	row.append(levelContainer);
	var levelImage = $('<img/>');
	levelImage.attr('src', Path.GFX + Asset.ICON_LEVEL);
	levelContainer.append(levelImage);
	levelContainer.append($('<div class="level text-font-normal font-bold font-color-subtitle">' + _data.Level + '</div>'));

	var bottomRow = $('<div class="row is-bottom"/>');
	rightColumn.append(bottomRow);
	var traits = $('<div class="is-traits-container"/>');
	bottomRow.append(traits);
	for (var i = 0; i < _data.Traits.length; ++i)
	{
		var trait = $('<img/>');
		trait.attr('src', Path.GFX + _data.Traits[i].icon);
		trait.bindTooltip({ contentType: 'status-effect', entityId: _data.ID, statusEffectId: _data.Traits[i].id });
		traits.append(trait);
	}

	var badges = $('<div class="is-badges text-font-small"/>');
	bottomRow.append(badges);
	var addBadge = function (_text, _class)
	{
		badges.append($('<span class="badge ' + _class + '">' + _text + '</span>'));
	};
	if (_data.IsDead)
		addBadge('Dead', 'font-color-assets-negative-value');
	if (_data.IsInCompany)
		addBadge('In your company', 'font-color-assets-positive-value');
	if (_data.IsHome)
		addBadge('Home: this company', 'font-color-assets-positive-value');
	if (_data.IsOnLoan)
		addBadge('On loan', 'font-color-subtitle');
	if (_data.CannotSpawn)
		addBadge('Cannot spawn', 'font-color-assets-negative-value');
};

ModPersistentCharactersScreen.prototype.selectBro = function (_uid)
{
	var self = this;
	var request = ++this.mBroRequest;

	this.mSelectedBroUID = _uid;
	this.mBroListContainer.deselectListEntries();
	if (_uid === null)
	{
		this.showDetails(null);
		return;
	}

	this.mBroListScrollContainer.find('.list-entry').each(function (_index, _element)
	{
		if ($(_element).attr('data-uid') === _uid)
		{
			$(_element).addClass('is-selected');
			self.mBroListContainer.scrollListToElement($(_element));
		}
	});

	this.call('onBroSelected', _uid, function (_data)
	{
		if (self.mContainer === null || request !== self.mBroRequest)
			return;

		self.showDetails(_data === undefined ? null : _data);
	});
};

// ---------------------------------------------------------------------------------------------
// Details
// ---------------------------------------------------------------------------------------------

ModPersistentCharactersScreen.prototype.showDetails = function (_data)
{
	var d = this.mDetails;
	this.mBroData = _data;

	if (_data === null)
	{
		d.Container.removeClass('display-block').addClass('display-none');
		return;
	}

	d.Container.removeClass('display-none').addClass('display-block');

	this.showEquipment(_data);
	this.showStats(_data.Stats);
	this.showPerks(_data);
	this.showServiceRecord(_data);
	this.updateDetailButtons(_data);
};

ModPersistentCharactersScreen.prototype.fillSlot = function (_slot, _item, _entityId)
{
	var container = _slot.Container;
	if (_item === null || _item === undefined || !('id' in _item))
	{
		container.assignPaperdollItemImage();
		container.assignPaperdollItemOverlayImage();
		container.assignPaperdollItemAmount();
		container.setPaperdollRepairImageVisible(false);
		return;
	}

	var isSmall = _slot.IsBig && _item.isLarge === false;
	container.assignPaperdollItemImage(Path.ITEMS + _item.imagePath, isSmall, false);
	if (_item.imageOverlayPath)
		container.assignPaperdollItemOverlayImage(Path.ITEMS + _item.imageOverlayPath, isSmall, false);
	else
		container.assignPaperdollItemOverlayImage('', isSmall, false);

	if (_item.showAmount === true && _item.amount !== '')
		container.assignPaperdollItemAmount('' + _item.amount, _item.amountColor);
	else
		container.assignPaperdollItemAmount();

	container.setPaperdollRepairImageVisible(false);
	container.assignPaperdollItemTooltip(_item.id, 'entity', _entityId);
};

ModPersistentCharactersScreen.prototype.showEquipment = function (_data)
{
	var d = this.mDetails;
	var self = this;

	$.each(d.Slots, function (_key, _slot)
	{
		self.fillSlot(_slot, _data.Paperdoll[_key], _data.ID);
	});

	for (var i = 0; i < d.BagSlots.length; ++i)
	{
		d.BagLayout.removeClass('has-slot-' + (i + 1));
		if (i < _data.Bag.length)
		{
			d.BagSlots[i].Container.parent().removeClass('display-none');
			this.fillSlot(d.BagSlots[i], _data.Bag[i], _data.ID);
		}
		else
		{
			d.BagSlots[i].Container.parent().addClass('display-none');
		}
	}
	d.BagLayout.addClass('has-slot-' + Math.max(1, Math.min(_data.Bag.length, d.BagSlots.length)));
};

ModPersistentCharactersScreen.prototype.showStats = function (_stats)
{
	var d = this.mDetails;
	$.each(d.StatRows, function (_i, _row)
	{
		var def = _row.Definition;
		var value = _stats[def.Key];
		var max = _stats[def.Max];
		if (value === undefined || value === null || max === undefined || max === null)
			return;

		_row.Bar.changeProgressbarNormalWidth(value, max);
		var label;
		if (def.Label !== undefined && _stats[def.Label] !== undefined && _stats[def.Label] !== null)
			label = '' + _stats[def.Label];
		else if (def.Both === true)
			label = value + ' / ' + max;
		else
			label = '' + value;
		_row.Bar.changeProgressbarLabel(label);

		if (def.Talent !== undefined && _stats[def.Talent] !== undefined)
		{
			_row.Talent.attr('src', Path.GFX + 'ui/icons/talent_' + _stats[def.Talent] + '.png');
			_row.Talent.removeClass('display-none');
		}
		else
		{
			_row.Talent.addClass('display-none');
		}
	});
};

// Same sizes as the vanilla perk tree: 5.0rem per perk, 6.0rem per row, set in the CSS.
ModPersistentCharactersScreen.prototype.showPerks = function (_data)
{
	var container = this.mDetails.PerksContainer;
	container.empty();

	var learned = {};
	for (var i = 0; i < _data.LearnedPerks.length; ++i)
	{
		learned[_data.LearnedPerks[i]] = true;
	}

	for (var r = 0; r < _data.Tree.length; ++r)
	{
		var row = $('<div class="pc-perk-row"/>');
		container.append(row);
		for (var p = 0; p < _data.Tree[r].length; ++p)
		{
			var perk = _data.Tree[r][p];
			var isLearned = learned[perk.ID] === true;
			var perkContainer = $('<div class="l-perk-container"/>');
			row.append(perkContainer);
			if (isLearned)
			{
				var selection = $('<img class="selection-image-layer"/>');
				selection.attr('src', Path.GFX + Asset.PERK_SELECTION_FRAME);
				perkContainer.append(selection);
			}
			var image = $('<img class="perk-image-layer"/>');
			image.attr('src', Path.GFX + (isLearned ? perk.Icon : perk.IconDisabled));
			image.bindTooltip({ contentType: 'ui-perk', entityId: _data.ID, perkId: perk.ID });
			perkContainer.append(image);
		}
	}
};

ModPersistentCharactersScreen.prototype.showServiceRecord = function (_data)
{
	var self = this;
	var esc = ModPersistentCharactersScreen.escapeHTML;
	var scroll = this.mDetails.ServiceScroll;
	scroll.empty();

	$.each(_data.ServiceRecord, function (_i, _record)
	{
		var row = $('<div class="pc-service-row text-font-small font-color-description"/>');
		scroll.append(row);

		var nameCell = $('<div class="c-name"/>');
		row.append(nameCell);
		var hasTag = _record.IsHome || _record.IsCurrent;
		nameCell.append($('<span class="n' + (hasTag ? ' has-tag' : '') + '">' + esc(_record.Name) + '</span>'));
		if (_record.IsHome)
			nameCell.append($('<span class="t font-color-assets-positive-value">Home</span>'));
		else if (_record.IsCurrent)
			nameCell.append($('<span class="t font-color-subtitle">Current</span>'));
		nameCell.bindTooltip(self.getTextTooltip(_record.Name, _record.IsHome ? 'His home company.' : (_record.IsCurrent ? 'Your current company.' : '')));
		row.append($('<div class="c-num c-days">' + _record.Days + '</div>'));
		row.append($('<div class="c-num c-battles">' + _record.Battles + '</div>'));
		row.append($('<div class="c-num c-kills">' + _record.Kills + '</div>'));

		var deadCell = $('<div class="c-dead"/>');
		row.append(deadCell);
		var checkbox = $('<input type="checkbox"/>');
		deadCell.append(checkbox);
		if (_record.IsDead)
			checkbox.prop('checked', true);
		if (_record.DeadReason !== null)
			checkbox.prop('disabled', true);
		checkbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});

		if (_record.DeadReason !== null)
		{
			deadCell.bindTooltip(self.getTextTooltip('Cannot change', _record.DeadReason));
		}
		else
		{
			deadCell.bindTooltip(self.getTextTooltip('Dead', 'Mark whether he died while serving this company. If Perma Death is enabled in the settings, characters who died cannot spawn.'));
			checkbox.on('ifChecked ifUnchecked', null, self, function (_event)
			{
				var isDead = _event.type === 'ifChecked';
				self.mutate('onSetDead', [_data.UID, _record.CampaignUID, isDead], 'Updated the service record.', self.mSelectedCampaign, _data.UID);
			});
		}
	});
};

ModPersistentCharactersScreen.prototype.updateDetailButtons = function (_data)
{
	var b = this.mDetails.Buttons;
	this.setButtonState(b.Import.Button, 'Import to Company', 'Add him to your company for free.', _data.ImportReason);
	this.setButtonState(b.MakeHome.Button, 'Make Home Company', 'Make this company his home company. His saved version will follow this company from now on.', _data.MakeHomeReason);
	this.setButtonState(b.Export.Button, 'Export', 'Save him to a file in the savegames folder so that he can be imported again. He keeps his persistence data.', _data.ExportReason);
	this.setButtonState(b.ExportRaw.Button, 'Export Raw', 'Save him to a file without his persistence data. He becomes a new persistent character of whichever company imports him.', _data.ExportReason);
	this.setButtonState(b.Delete.Button, 'Delete Character', 'Permanently remove him from the persistent data.', _data.DeleteReason);
};

// ---------------------------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------------------------

ModPersistentCharactersScreen.prototype.onImportPressed = function ()
{
	if (this.mBroData === null)
		return;

	var data = this.mBroData;
	this.mutate('onImportBro', data.UID, data.Name + ' joined your company.', this.mSelectedCampaign, data.UID);
};

ModPersistentCharactersScreen.prototype.onMakeHomePressed = function ()
{
	var self = this;
	if (this.mBroData === null)
		return;

	var data = this.mBroData;
	this.confirm('Make Home Company', 'Make this company the home company of <span class="font-color-label-warning">' + ModPersistentCharactersScreen.escapeHTML(data.Name) + '</span>? His saved version will follow this company from now on and will no longer be updated by his previous home company.', function ()
	{
		self.mutate('onMakeHome', data.UID, 'This is now the home company of ' + data.Name + '.', self.mSelectedCampaign, data.UID);
	});
};

ModPersistentCharactersScreen.prototype.onExportPressed = function (_isRaw)
{
	if (this.mBroData === null)
		return;

	var data = this.mBroData;
	var self = this;
	this.call('onExportBro', [data.UID, _isRaw], function (_result)
	{
		if (self.mContainer === null)
			return;

		if (_result !== null && _result !== undefined && _result.Error !== null && _result.Error !== undefined)
			self.setStatus(_result.Error, true);
		else
			self.setStatus('Exported ' + data.Name + (_isRaw ? ' without persistence data.' : '.'), false);
	});
};

ModPersistentCharactersScreen.prototype.onDeleteBroPressed = function ()
{
	var self = this;
	if (this.mBroData === null)
		return;

	var data = this.mBroData;
	this.confirm('Delete Character', 'Permanently delete <span class="font-color-label-warning">' + ModPersistentCharactersScreen.escapeHTML(data.Name) + '</span> from the persistent data? He will no longer spawn or be importable.', function ()
	{
		self.mutate('onDeleteBro', data.UID, 'Deleted ' + data.Name + '.', self.mSelectedCampaign, null);
	});
};

ModPersistentCharactersScreen.prototype.onDeleteCampaignPressed = function ()
{
	var self = this;
	var campaign = this.mSelectedCampaign === null ? null : this.findCampaign(this.mSelectedCampaign);
	if (campaign === null)
		return;

	if (campaign.UID === this.mLooseUID)
	{
		this.confirm('Delete Loose Characters', 'Permanently delete all <span class="font-color-label-warning">' + campaign.NumBros + '</span> loose characters from the persistent data?', function ()
		{
			self.mutate('onDeleteLooseBros', null, 'Deleted all loose characters.', null, null);
		});
		return;
	}

	var popup = this.openPopup('Delete Company', 'pc-popup pc-stop-popup');
	var content = $('<div class="pc-popup-content pc-stop-content"/>');
	content.append($('<div class="pc-stop-text text-font-normal font-color-label">Remove <span class="font-color-label-warning">' + ModPersistentCharactersScreen.escapeHTML(campaign.Name) + '</span> from the persistent data? What should happen to its ' + campaign.NumBros + ' characters?</div>'));
	var buttonRow = $('<div class="pc-popup-buttons"/>');
	content.append(buttonRow);

	var addChoice = function (_label, _deleteBros, _description)
	{
		var layout = $('<div class="l-popup-button"/>');
		buttonRow.append(layout);
		var button = layout.createTextButton(_label, function ()
		{
			self.destroyPopupDialog();
			self.mutate('onDeleteCampaign', [campaign.UID, _deleteBros], 'Removed ' + campaign.Name + '.', null, null);
		}, '', 1);
		button.bindTooltip(self.getTextTooltip(_label, _description));
	};
	addChoice('Make Loose', false, 'The characters of this company become loose characters. They can still spawn in your campaigns.');
	addChoice('Delete Them', true, 'The characters of this company are permanently deleted.');

	popup.addPopupDialogCancelButton(function (_dialog)
	{
		self.destroyPopupDialog();
	});
	popup.addPopupDialogContent(content);
};

// ---------------------------------------------------------------------------------------------
// Popups
// ---------------------------------------------------------------------------------------------

ModPersistentCharactersScreen.prototype.openPopup = function (_title, _class)
{
	this.destroyPopupDialog();
	var popup = this.mContainer.createPopupDialog(_title, null, null, _class);
	this.setPopupDialog(popup);
	return popup;
};

ModPersistentCharactersScreen.prototype.confirm = function (_title, _html, _onOk)
{
	var self = this;
	var popup = this.openPopup(_title, 'pc-popup pc-confirm-popup');
	popup.addPopupDialogOkButton(function (_dialog)
	{
		self.destroyPopupDialog();
		_onOk();
	});
	popup.addPopupDialogCancelButton(function (_dialog)
	{
		self.destroyPopupDialog();
	});

	var content = $('<div class="pc-popup-content pc-confirm-content"/>');
	content.append($('<div class="text-font-normal font-color-label">' + _html + '</div>'));
	popup.addPopupDialogContent(content);
};

ModPersistentCharactersScreen.prototype.createCheckbox = function (_checked, _disabled)
{
	var checkbox = $('<input type="checkbox"/>');
	if (_checked)
		checkbox.prop('checked', true);
	if (_disabled)
		checkbox.prop('disabled', true);
	return checkbox;
};

ModPersistentCharactersScreen.prototype.initCheckbox = function (_checkbox)
{
	_checkbox.iCheck({
		checkboxClass: 'icheckbox_flat-orange',
		radioClass: 'iradio_flat-orange',
		increaseArea: '30%'
	});
};

ModPersistentCharactersScreen.prototype.updateSavingTooltip = function ()
{
	if (this.mSavingRow === null)
		return;

	this.mSavingRow.unbindTooltip();
	this.mSavingRow.bindTooltip(this.getTextTooltip('Save characters of current campaign', 'If unticked, characters whose home company is your current campaign (' + this.mCurrentCampaignName + ') are not saved or updated as persistent characters when you save. Characters from other companies serving in your current campaign still get their service record updated.'));
};

ModPersistentCharactersScreen.prototype.setSavingChecked = function (_checked)
{
	this.mIgnoreSavingEvent = true;
	this.mSavingCheckbox.iCheck(_checked ? 'check' : 'uncheck');
	this.mIgnoreSavingEvent = false;
};

ModPersistentCharactersScreen.prototype.openStopSavingPopup = function ()
{
	var self = this;
	var popup = this.openPopup('Stop saving characters of your current campaign (' + ModPersistentCharactersScreen.escapeHTML(this.mCurrentCampaignName) + ')?', 'pc-popup pc-stop-popup');
	var content = $('<div class="pc-popup-content pc-stop-content"/>');
	content.append($('<div class="pc-stop-text text-font-normal font-color-label">What should happen to the existing characters whose home company is your current campaign?</div>'));
	var buttonRow = $('<div class="pc-popup-buttons"/>');
	content.append(buttonRow);

	var addChoice = function (_label, _mode, _description)
	{
		var layout = $('<div class="l-popup-button"/>');
		buttonRow.append(layout);
		var button = layout.createTextButton(_label, function ()
		{
			self.destroyPopupDialog();
			self.mutate('onSetSavingEnabled', [false, _mode], 'Stopped saving characters of the current campaign.', self.mSelectedCampaign, self.mSelectedBroUID);
		}, '', 1);
		button.bindTooltip(self.getTextTooltip(_label, _description));
	};
	addChoice('Keep Data', 'keep', 'The existing characters of the current campaign stay in the persistent data but are no longer updated.');
	addChoice('Make Loose', 'loose', 'The existing characters of the current campaign become loose characters.');
	addChoice('Delete Data', 'delete', 'The existing characters of the current campaign are deleted.');

	popup.addPopupDialogCancelButton(function (_dialog)
	{
		self.destroyPopupDialog();
		self.setSavingChecked(true);
	});
	popup.addPopupDialogContent(content);
};

ModPersistentCharactersScreen.prototype.openRequiredModsPopup = function ()
{
	var self = this;
	this.call('queryRequiredMods', null, function (_mods)
	{
		if (self.mContainer === null || _mods === null || _mods === undefined)
			return;

		var esc = ModPersistentCharactersScreen.escapeHTML;
		var popup = self.openPopup('Required Mods', 'pc-popup pc-big-popup');
		var content = $('<div class="pc-popup-content pc-big-content"/>');
		// The content must be in the DOM before the list is created so that its scrollbar is sized correctly
		popup.addPopupDialogContent(content);
		var inputs = [];

		content.append($('<div class="pc-popup-hint text-font-normal font-color-description">Characters saved from this company can only be loaded when all of the checked mods are installed.</div>'));
		var listLayout = $('<div class="pc-popup-list"/>');
		content.append(listLayout);
		var list = listLayout.createList(1.77);
		var scroll = list.findListScrollContainer();

		$.each(_mods, function (_i, _mod)
		{
			var row = $('<div class="pc-row"/>');
			scroll.append(row);
			var checkbox = self.createCheckbox(_mod.IsRequired, _mod.IsLocked);
			var checkboxLayout = $('<div class="pc-row-check"/>');
			checkboxLayout.append(checkbox);
			row.append(checkboxLayout);
			row.append($('<div class="pc-row-name text-font-normal font-color-subtitle">' + esc(_mod.Name) + ' <span class="font-color-description">(' + esc(_mod.ID) + ')</span></div>'));
			self.initCheckbox(checkbox);
			row.bindTooltip({ contentType: 'msu-generic', modId: self.mModID, elementId: 'ModEntry', modID: _mod.ID });
			inputs.push({ ID: _mod.ID, Checkbox: checkbox, IsLocked: _mod.IsLocked });
		});

		list.trigger('update', true);

		var buttonRow = $('<div class="pc-popup-buttons"/>');
		content.append(buttonRow);
		var layout = $('<div class="l-popup-button"/>');
		buttonRow.append(layout);
		layout.createTextButton('All', function ()
		{
			$.each(inputs, function (_i, _input) { _input.Checkbox.iCheck('check'); });
		}, '', 1);
		layout = $('<div class="l-popup-button"/>');
		buttonRow.append(layout);
		layout.createTextButton('None', function ()
		{
			$.each(inputs, function (_i, _input) { if (!_input.IsLocked) _input.Checkbox.iCheck('uncheck'); });
		}, '', 1);

		popup.addPopupDialogOkButton(function (_dialog)
		{
			var ids = [];
			$.each(inputs, function (_i, _input)
			{
				if (_input.IsLocked || _input.Checkbox.prop('checked'))
					ids.push(_input.ID);
			});
			self.destroyPopupDialog();
			self.call('onSetRequiredMods', ids, function (_result)
			{
				if (self.mContainer === null)
					return;
				if (_result !== null && _result !== undefined && _result.Error !== null && _result.Error !== undefined)
					self.setStatus(_result.Error, true);
				else
					self.setStatus('Saved the required mods.', false);
			});
		});
		popup.addPopupDialogCancelButton(function (_dialog)
		{
			self.destroyPopupDialog();
		});
	});
};

ModPersistentCharactersScreen.prototype.openImportFilePopup = function ()
{
	var self = this;
	this.call('queryImportFiles', null, function (_files)
	{
		if (self.mContainer === null || _files === null || _files === undefined)
			return;

		var esc = ModPersistentCharactersScreen.escapeHTML;
		var popup = self.openPopup('Import from File', 'pc-popup pc-big-popup');
		var content = $('<div class="pc-popup-content pc-big-content"/>');
		// The content must be in the DOM before the list is created so that its scrollbar is sized correctly
		popup.addPopupDialogContent(content);
		var selected = null;
		var importButton = null;
		var deleteButton = null;

		var updateButtons = function ()
		{
			if (selected === null)
			{
				self.setButtonState(importButton, 'Import', '', 'No file selected');
				self.setButtonState(deleteButton, 'Delete File', '', 'No file selected');
			}
			else
			{
				self.setButtonState(importButton, 'Import', 'Import this character into your company.', selected.Error);
				self.setButtonState(deleteButton, 'Delete File', 'Permanently delete this file.', null);
			}
		};

		if (_files.length === 0)
		{
			content.append($('<div class="pc-popup-hint text-font-normal font-color-description">There are no exported characters in the savegames folder.</div>'));
		}
		else
		{
			content.append($('<div class="pc-popup-hint text-font-normal font-color-description">Select a character to import.</div>'));
		}

		var listLayout = $('<div class="pc-popup-list"/>');
		content.append(listLayout);
		var list = listLayout.createList(1.77);
		var scroll = list.findListScrollContainer();

		$.each(_files, function (_i, _file)
		{
			var row = $('<div class="pc-row"/>');
			scroll.append(row);
			var label = esc(_file.Name) + (_file.Error !== null && _file.Level === 0 ? '' : ' <span class="font-color-description">(Level ' + _file.Level + ')</span>');
			var hasError = _file.Error !== null && _file.Error !== undefined;
			row.append($('<div class="pc-row-name text-font-normal ' + (hasError ? 'font-color-disabled' : 'font-color-subtitle') + '">' + label + '</div>'));
			if (hasError)
				row.addClass('is-disabled');

			var lines = (_file.Info !== undefined && _file.Info !== null) ? _file.Info.slice() : [];
			if (hasError)
			{
				lines.push({ icon: 'ui/icons/warning.png', text: _file.Error });
				if (_file.MissingMods !== undefined && _file.MissingMods.length > 0)
				{
					var names = [];
					for (var m = 0; m < _file.MissingMods.length; ++m)
						names.push(_file.MissingMods[m].Name + ' (' + _file.MissingMods[m].ID + ')');
					lines.push({ icon: 'ui/icons/warning.png', text: 'Missing mods: ' + names.join(', ') });
				}
			}
			var tooltip = self.getTextTooltip(_file.Name, _file.Filename);
			tooltip.lines = lines;
			row.bindTooltip(tooltip);

			row.click(function ()
			{
				scroll.find('.pc-row').removeClass('is-selected');
				row.addClass('is-selected');
				selected = _file;
				updateButtons();
			});
		});

		list.trigger('update', true);

		var buttonRow = $('<div class="pc-popup-buttons"/>');
		content.append(buttonRow);
		var layout = $('<div class="l-popup-button"/>');
		buttonRow.append(layout);
		importButton = layout.createTextButton('Import', function ()
		{
			if (selected === null || selected.Error !== null)
				return;
			var filename = selected.Filename;
			var name = selected.Name;
			self.destroyPopupDialog();
			self.mutate('onImportFile', filename, name + ' joined your company.', self.mSelectedCampaign, self.mSelectedBroUID);
		}, '', 1);
		layout = $('<div class="l-popup-button"/>');
		buttonRow.append(layout);
		deleteButton = layout.createTextButton('Delete File', function ()
		{
			if (selected === null)
				return;
			var filename = selected.Filename;
			self.call('onDeleteFile', filename, function (_result)
			{
				if (self.mContainer === null)
					return;
				if (_result !== null && _result !== undefined && _result.Error !== null && _result.Error !== undefined)
				{
					self.setStatus(_result.Error, true);
					return;
				}
				self.setStatus('Deleted the file.', false);
				self.openImportFilePopup();
			});
		}, '', 1);
		updateButtons();

		popup.addPopupDialogCancelButton(function (_dialog)
		{
			self.destroyPopupDialog();
		});
		popup.findPopupDialogCancelButton().changeButtonText('Close');
	});
};

registerScreen("ModPersistentCharactersScreen", new ModPersistentCharactersScreen());
