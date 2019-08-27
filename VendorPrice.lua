local SELLVALUE_COST = "|cffFFFFFFSell Price:"

print(format("[Vendor Price] ver: (%s) loaded.", GetAddOnMetadata("VendorPrice", "Version")))

local function SetPrice(tip)
    local _, itemLink = tip:GetItem()
    local itemSellPrice = select(11, GetItemInfo(itemLink))
    if itemSellPrice and itemSellPrice > 0 then -- sellable item
        local container = GetMouseFocus()
        local object = container:GetObjectType()
        local count
		
        if object == "Button" then
            count = container.count
        elseif object == "CheckButton" then -- ActionButton
            count = tonumber(container.Count:GetText())
        end
        
        local cost = (type(count) == "number" and count or 1) * itemSellPrice
        SetTooltipMoney(tip, cost, nil, SELLVALUE_COST)
    end
end

GameTooltip:HookScript("OnTooltipSetItem", SetPrice)
ItemRefTooltip:HookScript("OnTooltipSetItem", SetPrice)