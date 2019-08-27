local VERSION = "0.05"
local SELLVALUE_COST = "|cffFFFFFFSell Price:"

print(format("[Vendor Price] ver: (%s) loaded.", VERSION))

local function SetPrice(tip)
	local _, itemLink = tip:GetItem()
    local itemSellPrice = select(11, GetItemInfo(itemLink))
    if itemSellPrice and itemSellPrice > 0 then -- sellable item
        local container = GetMouseFocus()
        local count = container and container:IsObjectType("Button") and container.count
        local cost = (type(count) == "number" and count or 1) * itemSellPrice
		SetTooltipMoney(tip, cost, nil, SELLVALUE_COST)
    end
end

GameTooltip:HookScript("OnTooltipSetItem", SetPrice)
ItemRefTooltip:HookScript("OnTooltipSetItem", SetPrice)