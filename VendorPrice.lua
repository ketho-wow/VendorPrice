local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)

local function SetPrice(tip)
    if not MerchantFrame:IsShown() then 
		local _, itemLink = tip:GetItem()
		local itemSellPrice = select(11, GetItemInfo(itemLink))
		if itemSellPrice and itemSellPrice > 0 then -- sellable item
			local container = GetMouseFocus()
			local object = container:GetObjectType()
			local count
			if object == "Button" then
				-- ContainerFrameItem, QuestInfoItem, PaperDollItem
				count = container.count
			elseif object == "CheckButton" then
				-- MailItemButton or ActionButton
				count = container.count or tonumber(container.Count:GetText())
			end
			local cost = (type(count) == "number" and count or 1) * itemSellPrice
			SetTooltipMoney(tip, cost, nil, SELL_PRICE_TEXT)
		end
    end
end

GameTooltip:HookScript("OnTooltipSetItem", SetPrice)
ItemRefTooltip:HookScript("OnTooltipSetItem", SetPrice)
print(format("[Vendor Price] ver: (%s) loaded.", GetAddOnMetadata("VendorPrice", "Version")))