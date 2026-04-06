var ModPersistentCharactersScreen = function (_parent)
{
	MSUUIScreen.call(this);
	this.mModID = "mod_persistent_characters";
	this.mID = "ModPersistentCharactersScreen";
	this.mCampaigns = null;
	this.mRoster = null;

    // event listener
    this.mEventListener = null;

	// generic containers
	this.mContainer = null;
	this.mDialogContainer = null;
	this.mCampaignListContainer = null;
	this.mCampaignListScrollContainer = null;
    this.mListContainer = null;
    this.mListScrollContainer = null;
    this.mDetailsPanel =
    {
        Container: null,
        CharacterImage: null,
        CharacterName: null,
        CharacterTraitsContainer: null,
        CharacterBackgroundTextContainer: null,
        CharacterBackgroundTextScrollContainer: null,
        CharacterBackgroundImage: null,
        InitialMoneyCostsText: null,
        TryoutMoneyCostsText: null,
        TryoutCostsContainer: null,
        DailyMoneyCostsText: null,
        HireButton: null,
        TryoutButton: null
    };

    // assets labels
	this.mAssets = new WorldTownScreenAssets(_parent);

    // buttons
    this.mLeaveButton = null;

    // generics
    this.mIsVisible = false;

    // selected entry
    this.mSelectedEntry = null;
}

ModPersistentCharactersScreen.prototype = Object.create(MSUUIScreen.prototype);
Object.defineProperty(ModPersistentCharactersScreen.prototype, "constructor", {
	value: ModPersistentCharactersScreen,
	enumerable: false,
	writable: true
});

ModPersistentCharactersScreen.prototype.createDIV = function (_parentDiv)
{
    var self = this;

	// create: containers (init hidden!)
	this.mContainer = $('<div class="mod_persistent_characters_screen display-none opacity-none"/>');
    _parentDiv.append(this.mContainer);
    this.mDialogContainer = this.mContainer.createDialog('Persistent Characters', null, '', true, 'rf-dialog-max');

    // create tabs
    var tabButtonsContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabButtonsContainer);

	// create assets
	this.mAssets.createDIV(tabButtonsContainer);

    // create content
    var content = this.mDialogContainer.findDialogContentContainer();

    // left column
    var column = $('<div class="column is-left"/>');
	content.append(column);
	var listContainerLayout = $('<div class="l-list-container"/>');
    column.append(listContainerLayout);
    this.mCampaignListContainer = listContainerLayout.createList(1.77/*8.85*/);
	this.mCampaignListScrollContainer = this.mCampaignListContainer.findListScrollContainer();

	column = $('<div class="column is-middle"/>');
    content.append(column);
    listContainerLayout = $('<div class="l-list-container"/>');
    column.append(listContainerLayout);
    this.mListContainer = listContainerLayout.createList(1.77/*8.85*/);
	this.mListScrollContainer = this.mListContainer.findListScrollContainer();

    // right column
    column = $('<div class="column is-right"/>');
    content.append(column);

    // details container
    var detailsFrame = $('<div class="l-details-frame"/>');
    column.append(detailsFrame);
    this.mDetailsPanel.Container = $('<div class="details-container display-none"/>');
    detailsFrame.append(this.mDetailsPanel.Container);

    // details: character container
    var detailsRow = $('<div class="row is-character-container"/>');
    this.mDetailsPanel.Container.append(detailsRow);
    var detailsColumn = $('<div class="column is-character-portrait-container"/>');
    detailsRow.append(detailsColumn);
    this.mDetailsPanel.CharacterImage = detailsColumn.createImage(null, function (_image)
	{
        var offsetX = 0;
        var offsetY = 0;

        if(self.mSelectedEntry !== null)
        {
            var data = self.mSelectedEntry.data('entry');
            if('ImageOffsetX' in data && data['ImageOffsetX'] !== null &&
                'ImageOffsetY' in data && data['ImageOffsetY'] !== null)
            {
                offsetX = data['ImageOffsetX'];
                offsetY = data['ImageOffsetY'];
            }
        }

        _image.centerImageWithinParent(offsetX, offsetY, 1.0);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');
    detailsColumn = $('<div class="column is-character-background-container"/>');
    detailsRow.append(detailsColumn);

    // details: background
    var backgroundRow = $('<div class="row is-top"/>');
    detailsColumn.append(backgroundRow);
	var backgroundRowBorder = $('<div class="row is-top border"/>');
	backgroundRow.append(backgroundRowBorder);

    this.mDetailsPanel.CharacterBackgroundImage = $('<img />');
    detailsColumn.append(this.mDetailsPanel.CharacterBackgroundImage);
    this.mDetailsPanel.CharacterName = $('<div class="name title-font-normal font-bold font-color-brother-name"/>');
    backgroundRow.append(this.mDetailsPanel.CharacterName);

    this.mDetailsPanel.CharacterTraitsContainer = $('<div class="traits-container"/>');
    backgroundRow.append(this.mDetailsPanel.CharacterTraitsContainer);

    backgroundRow = $('<div class="row is-bottom"/>');
    detailsColumn.append(backgroundRow);
    this.mDetailsPanel.CharacterBackgroundTextContainer = backgroundRow.createList(20, 'description-font-medium font-bottom-shadow font-color-description', true);
    this.mDetailsPanel.CharacterBackgroundTextScrollContainer = this.mDetailsPanel.CharacterBackgroundTextContainer.findListScrollContainer();

    // details: costs
    detailsRow = $('<div class="row is-costs-container"/>');
    this.mDetailsPanel.Container.append(detailsRow);
    var costsHeader = $('<div class="row is-header"/>');
    detailsRow.append(costsHeader);
    var costsHeaderLabel = $('<div class="label title-font-normal font-bold font-bottom-shadow font-color-title">Costs</div>');
    costsHeader.append(costsHeaderLabel);
    var costsInitial = $('<div class="row is-initial-costs"/>');
    detailsRow.append(costsInitial);
    var costsLabel = $('<div class="costs-label title-font-normal font-bold font-bottom-shadow font-color-title">Up Front</div>');
    costsInitial.append(costsLabel);
    var costsContainer = $('<div class="l-costs-container"/>');
    costsInitial.append(costsContainer);
    var costsImage = $('<img/>');
    costsImage.attr('src', Path.GFX + Asset.ICON_ASSET_MONEY);
    costsContainer.append(costsImage);
    costsImage.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Assets.InitialMoney });
    this.mDetailsPanel.InitialMoneyCostsText = $('<div class="label text-font-normal font-bottom-shadow font-color-description"/>');
    costsContainer.append(this.mDetailsPanel.InitialMoneyCostsText);

    var costsDaily = $('<div class="row is-daily-costs"/>');
    detailsRow.append(costsDaily);
    costsLabel = $('<div class="costs-label title-font-normal font-bold font-bottom-shadow font-color-title">Daily</div>');
    costsDaily.append(costsLabel);
    costsContainer = $('<div class="l-costs-container"/>');
    costsDaily.append(costsContainer);
    costsImage = $('<img/>');
    costsImage.attr('src', Path.GFX + Asset.ICON_ASSET_DAILY_MONEY);
    costsContainer.append(costsImage);
    costsImage.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Assets.DailyMoney });
    this.mDetailsPanel.DailyMoneyCostsText = $('<div class="label text-font-normal font-bottom-shadow font-color-description"/>');
    costsContainer.append(this.mDetailsPanel.DailyMoneyCostsText);

    costsContainer = $('<div class="l-costs-container l-tryout-costs-container"/>');
    this.mDetailsPanel.TryoutCostsContainer = costsContainer;
    costsInitial.append(costsContainer);
    var costsImage = $('<img/>');
    costsImage.attr('src', Path.GFX + Asset.ICON_ASSET_MONEY);
    costsContainer.append(costsImage);
    costsImage.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Assets.TryoutMoney });
    this.mDetailsPanel.TryoutMoneyCostsText = $('<div class="label text-font-normal font-bottom-shadow font-color-description"/>');
    costsContainer.append(this.mDetailsPanel.TryoutMoneyCostsText);

    // details: buttons
    detailsRow = $('<div class="row is-button-container"/>');
    this.mDetailsPanel.Container.append(detailsRow);
    var hireButtonLayout = $('<div class="l-hire-button"/>');
    detailsRow.append(hireButtonLayout);
    this.mDetailsPanel.HireButton = hireButtonLayout.createTextButton("Hire", function()
	{
        if(self.mSelectedEntry !== null)
        {
            var data = self.mSelectedEntry.data('entry');
            if('ID' in data && data['ID'] !== null)
            {
                self.hireRosterEntry(data['ID']);
            }
        }
    }, '', 1);

    var tryoutButtonLayout = $('<div class="l-tryout-button"/>');
    detailsRow.append(tryoutButtonLayout);
    this.mDetailsPanel.TryoutButton = tryoutButtonLayout.createTextButton("Try out", function()
	{
        if(self.mSelectedEntry !== null)
        {
            var data = self.mSelectedEntry.data('entry');
            if('ID' in data && data['ID'] !== null)
            {
                self.tryoutRosterEntry(data['ID']);
            }
        }
    }, '', 1);

    // create footer button bar
    var footerButtonBar = $('<div class="l-button-bar"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);

    // create: buttons
    var layout = $('<div class="l-leave-button"/>');
    footerButtonBar.append(layout);
    this.mLeaveButton = layout.createTextButton("Leave", function ()
    {
        self.notifyBackendLeaveButtonPressed();
    }, '', 1);

    this.mIsVisible = false;
};

ModPersistentCharactersScreen.prototype.destroyDIV = function ()
{
	this.mAssets.destroyDIV();

	this.mSelectedEntry = null;

    this.mDetailsPanel.HireButton.remove();
    this.mDetailsPanel.HireButton = null;

    /*
    this.mDetailsPanel.DailyFoodCostsText.empty();
    this.mDetailsPanel.DailyFoodCostsText.remove();
    this.mDetailsPanel.DailyFoodCostsText = null;
    */

    this.mDetailsPanel.DailyMoneyCostsText.empty();
    this.mDetailsPanel.DailyMoneyCostsText.remove();
    this.mDetailsPanel.DailyMoneyCostsText = null;

    this.mDetailsPanel.InitialMoneyCostsText.empty();
    this.mDetailsPanel.InitialMoneyCostsText.remove();
    this.mDetailsPanel.InitialMoneyCostsText = null;

    this.mDetailsPanel.CharacterBackgroundImage.empty();
    this.mDetailsPanel.CharacterBackgroundImage.remove();
    this.mDetailsPanel.CharacterBackgroundImage = null;

    this.mDetailsPanel.CharacterBackgroundTextScrollContainer.empty();
    this.mDetailsPanel.CharacterBackgroundTextScrollContainer = null;
    this.mDetailsPanel.CharacterBackgroundTextContainer.destroyList();
    this.mDetailsPanel.CharacterBackgroundTextContainer.remove();
    this.mDetailsPanel.CharacterBackgroundTextContainer = null;

    this.mDetailsPanel.CharacterName.empty();
    this.mDetailsPanel.CharacterName.remove();
    this.mDetailsPanel.CharacterName = null;

    this.mDetailsPanel.CharacterImage.empty();
    this.mDetailsPanel.CharacterImage.remove();
    this.mDetailsPanel.CharacterImage = null;

    this.mDetailsPanel.Container.empty();
    this.mDetailsPanel.Container.remove();
    this.mDetailsPanel.Container = null;

    this.mListScrollContainer.empty();
    this.mListScrollContainer = null;
    this.mListContainer.destroyList();
    this.mListContainer.remove();
    this.mListContainer = null;

	this.mLeaveButton.remove();
    this.mLeaveButton = null;

    this.mDialogContainer.empty();
    this.mDialogContainer.remove();
    this.mDialogContainer = null;

    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
};

ModPersistentCharactersScreen.prototype.loadFromData = function (_data)
{
    if (_data === undefined || _data === null || !jQuery.isArray(_data))
    {
        return;
    }

	this.mCampaigns = _data;

    this.mCampaignListScrollContainer.empty();

    for(var i = 0; i < _data.length; ++i)
    {
        this.addCampaignListEntry(_data[i]);
    }

    // this.selectListEntry(this.mCampaignListContainer.findListEntryByIndex(0), true);
};

ModPersistentCharactersScreen.prototype.addCampaignListEntry = function (_data)
{
	var self = this;

    var entry = this.mCampaignListScrollContainer.createListCampaign(_data);
    entry.assignListCampaignName(_data.Name);
	entry.assignListImage('ui/banners/' + _data.Banner + '.png');
	entry.assignListCampaignGroupName(_data.Name);
	if (_data.MissingMods !== null)
	{
		entry.assignListCampaignDayName("Missing Mods: " + _data.MissingMods);
    	entry.addClass('is-disabled');
	}
    else
    {
    	entry.assignListCampaignDayName("Renown: " + _data.BusinessReputation);
    }

    // if (CampaignMenuModulesIdentifier.Campaign.CreationDate in _data)
    // {
    //     entry.assignListCampaignDateTime(_data[CampaignMenuModulesIdentifier.Campaign.CreationDate]);
    // }

    // entry.assignListCampaignClickHandler(function (_entry, _event)
    // {
    //     // check if this is already selected
    //     if (_entry.hasClass('is-selected') !== true)
    //     {
    //         // deselect all entries first
    //         self.mListScrollContainer.find('.is-selected:first').each(function (index, el)
    //         {
    //             $(el).removeClass('is-selected');
    //         });

    //         _entry.addClass('is-selected');

	// 		self.mIsNewSavegame = false;

    //         self.mSaveButton.enableButton(true);
    //         self.mDeleteButton.enableButton(true);
    //     }
    // });
}

ModPersistentCharactersScreen.prototype.updateListEntryValues = function()
{
    // var currentMoney = this.mAssets.getValues().Money;
    var container = this.mListContainer.findListScrollContainer();
    container.find('.list-entry').each(function(index, element)
	{
    	var entry = $(element);
        var initialMoneyCostElement = entry.find('.is-initial-money-cost');
        var traitsContainer = entry.find('.is-traits-container');
        var data = entry.data('entry');
        var initialMoneyCost = data['InitialMoneyCost'];
        initialMoneyCostElement.html(Helper.numberWithCommas(data[WorldTownScreenIdentifier.HireRosterEntry.InitialMoneyCost]));
        if (currentMoney < initialMoneyCost)
        {
        	initialMoneyCostElement.removeClass('font-color-subtitle').addClass('font-color-assets-negative-value');
        }
        else
        {
            initialMoneyCostElement.removeClass('font-color-assets-negative-value').addClass('font-color-subtitle');
        }

        traitsContainer.empty();
        if(data['IsTryoutDone'])
        {
            for(var i = 0; i < data.Traits.length; ++i)
            {
                var icon = $('<img src="' + Path.GFX + data.Traits[i].icon + '"/>');
                icon.bindTooltip({ contentType: 'status-effect', entityId: data.ID, statusEffectId: data.Traits[i].id });
                traitsContainer.append(icon);
            }
        }
        else
        {
            var icon = $('<img src="' + Path.GFX + Asset.ICON_UNKNOWN_TRAITS + '"/>');
            icon.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldTownScreen.HireDialogModule.UnknownTraits });
            traitsContainer.append(icon);
        }
    });
};

ModPersistentCharactersScreen.prototype.selectListEntry = function(_element, _scrollToEntry)
{
    if (_element !== null && _element.length > 0)
    {
        // check if this is already selected
        //if (_element.hasClass('is-selected') !== true)
        {
            this.mListContainer.deselectListEntries();
            _element.addClass('is-selected');

            // give the renderer some time to layout his shit...
            if (_scrollToEntry !== undefined && _scrollToEntry === true)
            {
            	this.mListContainer.scrollListToElement(_element);
            }

            this.mSelectedEntry = _element;
            // this.updateDetailsPanel(this.mSelectedEntry);
            this.updateListEntryValues();
        }
    }
    else
    {
        this.mSelectedEntry = null;
        // this.updateDetailsPanel(this.mSelectedEntry);
        this.updateListEntryValues();
    }
};

ModPersistentCharactersScreen.prototype.addListEntry = function (_data)
{
    var result = $('<div class="l-row"/>');
    this.mListScrollContainer.append(result);

    var entry = $('<div class="ui-control list-entry"/>');
    result.append(entry);
    entry.data('entry', _data);
    entry.click(this, function(_event)
	{
        var self = _event.data;
        self.selectListEntry($(this));
    });

    // left column
    var column = $('<div class="column is-left"/>');
    entry.append(column);

    var imageOffsetX = ('ImageOffsetX' in _data ? _data['ImageOffsetX'] : 0);
    var imageOffsetY = ('ImageOffsetY' in _data ? _data['ImageOffsetY'] : 0);
    column.createImage(Path.PROCEDURAL + _data['ImagePath'], function (_image)
	{
        _image.centerImageWithinParent(imageOffsetX, imageOffsetY, 0.64, false);
        _image.removeClass('opacity-none');
    }, null, 'opacity-none');

    // right column
    column = $('<div class="column is-right"/>');
    entry.append(column);

    // top row
    var row = $('<div class="row is-top"/>');
    column.append(row);

    var image = $('<img/>');
    image.attr('src', Path.GFX + _data['BackgroundImagePath']);
    row.append(image);

    // bind tooltip
	image.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.CharacterBackgrounds.Generic, elementOwner: TooltipIdentifier.ElementOwner.HireScreen, entityId: _data.ID });

    var name = $('<div class="name title-font-normal font-bold font-color-title">' + _data[WorldTownScreenIdentifier.HireRosterEntry.Name] + '</div>');
    row.append(name);

    // bind tooltip
    if(_data[WorldTownScreenIdentifier.HireRosterEntry.Level] > 1)
	{
		var levelContainer = $('<div class="l-level-container"/>');
		row.append(levelContainer);
		image = $('<img/>');
		image.attr('src', Path.GFX + Asset.ICON_LEVEL);
		levelContainer.append(image);

		//image.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.CharacterLevels.Generic, elementOwner: TooltipIdentifier.ElementOwner.HireScreen, entityId: _data[WorldTownScreenIdentifier.HireRosterEntry.Id] });
		image.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.CharacterLevels.Generic });
		var level = $('<div class="level text-font-normal font-bold font-color-subtitle">' + _data[WorldTownScreenIdentifier.HireRosterEntry.Level] + '</div>');
		levelContainer.append(level);
	}

    // bottom row
    row = $('<div class="row is-bottom"/>');
    column.append(row);

    var traitsContainer = $('<div class="is-traits-container"/>');
    row.append(traitsContainer);

    var assetsCenterContainer = $('<div class="l-assets-center-container"/>');
    row.append(assetsCenterContainer);

    // initial money
    var assetsContainer = $('<div class="l-assets-container"/>');
    assetsCenterContainer.append(assetsContainer);
    image = $('<img/>');
    image.attr('src', Path.GFX + Asset.ICON_ASSET_MONEY);
    assetsContainer.append(image);
    image.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Assets.InitialMoney });
    var text = $('<div class="label is-initial-money-cost text-font-normal font-color-subtitle">' + Helper.numberWithCommas(_data[WorldTownScreenIdentifier.HireRosterEntry.InitialMoneyCost]) + '</div>');
    assetsContainer.append(text);

    // daily money
    assetsContainer = $('<div class="l-assets-container"/>');
    assetsCenterContainer.append(assetsContainer);
    image = $('<img/>');
    image.attr('src', Path.GFX + Asset.ICON_ASSET_DAILY_MONEY);
    assetsContainer.append(image);
    image.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Assets.DailyMoney });
    text = $('<div class="label is-daily-money-cost text-font-normal font-color-subtitle">' + Helper.numberWithCommas(_data[WorldTownScreenIdentifier.HireRosterEntry.DailyMoneyCost]) + '</div>');
    assetsContainer.append(text);

    // daily food
    /* NOTE: (js) We dont want to show daily food anymore..
    assetsContainer = $('<div class="l-assets-container"/>');
    assetsCenterContainer.append(assetsContainer);
    image = $('<img/>');
    image.attr('src', Path.GFX + Asset.ICON_ASSET_DAILY_FOOD);
    assetsContainer.append(image);
    image.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Assets.DailyFood });
    text = $('<div class="label is-daily-food-cost text-font-normal font-color-assets-positive-value">' + Helper.numberWithCommas(_data[WorldTownScreenIdentifier.HireRosterEntry.DailyFoodCost]) + '</div>');
    assetsContainer.append(text);
    */
};

WorldTownScreenMainDialogModule.prototype.show = function (_withSlideAnimation)
{
	var self = this;

	var withAnimation = (_withSlideAnimation !== undefined && _withSlideAnimation !== null) ? _withSlideAnimation : true;
	if (withAnimation === true)
	{
		var offset = this.mContainer.parent().width() + this.mContainer.width();
		this.mContainer.css({ 'translateX': offset });
		this.mContainer.velocity("finish", true).velocity({ opacity: 1, translateX: 0 },
        {
        	duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
        	easing: 'swing',
        	begin: function ()
        	{
        		$(this).removeClass('display-none').addClass('display-block');
        		// self.notifyBackendModuleAnimating();
        	},
        	complete: function ()
        	{
        		self.mIsVisible = true;
        		// self.notifyBackendModuleShown();
        	}
        });
	}
	else
	{
		this.mContainer.css({ opacity: 0 });
		this.mContainer.velocity("finish", true).velocity({ opacity: 1 },
        {
        	duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
        	easing: 'swing',
        	begin: function ()
        	{
        		$(this).removeClass('display-none').addClass('display-block');
        		// self.notifyBackendModuleAnimating();
        	},
        	complete: function ()
        	{
        		self.mIsVisible = true;
        		// self.notifyBackendModuleShown();
        	}
        });
	}
};

WorldTownScreenMainDialogModule.prototype.hide = function ()
{
	var self = this;

	var offset = this.mContainer.parent().width() + this.mContainer.width();
	this.mContainer.velocity("finish", true).velocity({ opacity: 0, translateX: offset },
    {
    	duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
    	easing: 'swing',
    	begin: function ()
    	{
    		$(this).removeClass('is-center');
    		self.notifyBackendModuleAnimating();
    	},
    	complete: function ()
    	{
    		self.mIsVisible = false;
    		$(this).removeClass('display-block').addClass('display-none');
    		self.notifyBackendModuleHidden();
    	}
    });
};

 registerScreen("ModPersistentCharactersScreen", new ModPersistentCharactersScreen());
