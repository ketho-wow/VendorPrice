local VERSION = "0.04"
local SELLVALUE_COST = "|cffFFFFFFSell Price:   %s|r"
local NOTSELLABLE = "This item can not be sold."

print(format("[Vendor Price] ver: (%s) loaded.", VERSION))

GameTooltip:HookScript("OnTooltipSetItem", function(tip)
    local _, itemLink = tip:GetItem()
    local itemSellPrice = select(11, GetItemInfo(itemLink))
    if itemSellPrice and itemSellPrice > 0 then -- sellable item
        local count
        local container = GetMouseFocus()
        if container and container:GetObjectType() == "Button" and container.count then
            count = container.count
        end
        local cost = (count and type(count) == "number" and count > 1) and itemSellPrice * count or itemSellPrice
        tip:AddLine(format(SELLVALUE_COST, GetMoneyString(cost)))
    else -- quest/unsellable item
        tip:AddLine(NOTSELLABLE)
    end
    tip:Show()
end)