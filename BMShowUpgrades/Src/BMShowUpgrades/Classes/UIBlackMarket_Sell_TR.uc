class UIBlackMarket_Sell_TR extends UIBlackMarket_Sell;

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