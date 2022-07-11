class UIBlackMarket_Sell_TR extends UIBlackMarket_Sell;

simulated function BuildScreen()
{
	History = `XCOMHISTORY;
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	ListBG = Spawn(class'UIPanel', self);
	ListBG.InitPanel('InventoryListBG');
	ListBG.Show();

	List = Spawn(class'UIList', self);
	List.bAnimateOnInit = false;
	List.ScrollbarPadding = 10;
	List.InitList('inventoryListMC');
	List.ShrinkToFit();
	List.bStickyHighlight = true;
	List.OnSelectionChanged = SelectedItemChanged;

	Navigator.SetSelected(List);

	// send mouse scroll events to the list
	ListBG.ProcessMouseEvents(List.OnChildMouseEvent);

	UpdateNavHelp();

	MC.BeginFunctionOp("SetGreeble");
	MC.QueueString(class'UIAlert'.default.m_strBlackMarketFooterLeft);
	MC.QueueString(class'UIAlert'.default.m_strBlackMarketFooterRight);
	MC.QueueString(class'UIAlert'.default.m_strBlackMarketLogoString);
	MC.EndOp();

	//---------------------
	
	// Move and resize list to accommodate label
	List.SetHeight(class'UIBlackMarket_SellItem'.default.Height * 16);

	UpdateSellInfo();

	ConfirmButton = Spawn(class'UIButton', self).InitButton('ConfirmButton', m_strConfirmButtonLabel, OnConfirmButtonClicked, eUIButtonStyle_HOTLINK_BUTTON);
	ConfirmButton.SetGamepadIcon(class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_X_SQUARE);

	PopulateData();
	UpdateTotalValue();
	List.SetSelectedIndex(0, true);
}

simulated function PopulateItemCard(X2ItemTemplate ItemTemplate, StateObjectReference ItemRef, optional string ItemPrice = "")
{
	local string strImage, strTitle, strInterest;
	local XComGameState_Item Item;
	local array<string> ItemsFriendlyNames;
	local string strTemp;
	local array<X2WeaponUpgradeTemplate> WUTemplates;	
	local int i;

	if( ItemTemplate.strImage != "" )
		strImage = ItemTemplate.strImage;
	else
		strImage = "img:///UILibrary_StrategyImages.GeneMods.GeneMods_MimeticSkin"; //Temp cool image

	strTitle = class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(ItemTemplate.GetItemFriendlyName());	
	
	strInterest = IsInterested(ItemTemplate) ? m_strInterestedLabel : "";

	// Grab the item state of the item to be sold
	// Then get the friendly names of the weapon upgrades currently attached
	Item = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));

	if (Item != none)
	{
		if (Item.GetMyWeaponUpgradeCount() > 0)
		{
			WUTemplates = Item.GetMyWeaponUpgradeTemplates();

			for (i = 0; i < WUTemplates.Length; i++)
			{
				ItemsFriendlyNames.AddItem(WUTemplates[i].GetItemFriendlyName());
			}
			
			class'Object'.static.JoinArray(ItemsFriendlyNames, strTemp, ", ");
			strTemp @= "\n\n";
		}

		// Add nickname of the item
		if (Item.Nickname != "")
		{
			strTitle @= "(" $Item.Nickname $")";
		}
	}

	strTemp $= ItemTemplate.GetItemBriefSummary(ItemRef.ObjectID);	

	MC.BeginFunctionOp("UpdateItemCard");
	MC.QueueString(strImage);
	MC.QueueString(strTitle);
	MC.QueueString(m_strCostLabel);
	MC.QueueString(ItemPrice);
	MC.QueueString(strInterest);
	MC.QueueString(""); // TODO: what warning string goes here? 
	MC.QueueString(strTemp);
	MC.EndOp();
}