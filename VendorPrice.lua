VendorPrice = {}
local VP = VendorPrice

local isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local ContainerIDToInventoryID = ContainerIDToInventoryID or C_Container.ContainerIDToInventoryID

local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)
local overridePrice

local CharacterBags = {}
for i = CONTAINER_BAG_OFFSET+1, 23 do
	CharacterBags[i] = true
end

local firstBankBag = ContainerIDToInventoryID(NUM_BAG_SLOTS + 1)
local lastBankBag = ContainerIDToInventoryID(NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
for i = firstBankBag, lastBankBag do
	CharacterBags[i] = true
end

local FIRST_KEYRING_INVSLOT = 107

local function IsMerchant(tt)
	if MerchantFrame:IsShown() then
		local name = tt:GetOwner():GetName()
		if name then
			return not (name:find("Character") or name:find("TradeSkill"))
		end
	end
end

-- source was only really used for auctionator
local function ShouldShowPrice(tt, source)
	return not IsMerchant(tt)
end

-- OnTooltipSetItem fires twice for recipes
local function CheckRecipe(tt, classID, isOnTooltipSetItem)
	if classID == Enum.ItemClass.Recipe and isOnTooltipSetItem then
		tt.isFirstMoneyLine = not tt.isFirstMoneyLine
		return tt.isFirstMoneyLine
	end
end

-- modify the tooltip when pressing shift, has a small delay
local _SetTooltipMoney = SetTooltipMoney
function SetTooltipMoney(frame, money, ...)
	if IsShiftKeyDown() and overridePrice then
		_SetTooltipMoney(frame, overridePrice, ...)
	else
		_SetTooltipMoney(frame, money, ...)
		overridePrice = nil
	end
end

GameTooltip:HookScript("OnHide", function()
	overridePrice = nil
end)

function VP:SetPrice(tt, hasWrathTooltip, source, count, item, isOnTooltipSetItem)
	if ShouldShowPrice(tt, source) then
		count = count or 1
		item = item or select(2, tt:GetItem())
		if item then
			local sellPrice, classID = select(11, GetItemInfo(item))
			if sellPrice and sellPrice > 0 and not CheckRecipe(tt, classID, isOnTooltipSetItem) then
				local isShift = IsShiftKeyDown() and count > 1
				local displayPrice = isShift and sellPrice or sellPrice * count
				if isVanilla then
					SetTooltipMoney(tt, displayPrice, nil, SELL_PRICE_TEXT)
				elseif isWrath then
					if hasWrathTooltip then
						if isShift then
							overridePrice = displayPrice
						end
					else
						SetTooltipMoney(tt, displayPrice, nil, SELL_PRICE_TEXT)
					end
				end
				tt:Show()
			end
		end
	end
end

local SetItem = {
	SetAction = function(tt, slot)
		if GetActionInfo(slot) == "item" then
			VP:SetPrice(tt, true, "SetAction", GetActionCount(slot))
		end
	end,
	SetAuctionItem = function(tt, auctionType, index)
		local _, _, count = GetAuctionItemInfo(auctionType, index)
		VP:SetPrice(tt, false, "SetAuctionItem", count)
	end,
	SetAuctionSellItem = function(tt)
		local _, _, count = GetAuctionSellItemInfo()
		VP:SetPrice(tt, true, "SetAuctionSellItem", count)
	end,
	SetBagItem = function(tt, bag, slot)
		local count
		if GetContainerItemInfo then
			count = select(2, GetContainerItemInfo(bag, slot))
		else
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info then
				count = info.stackCount
			end
		end
		if count then
			VP:SetPrice(tt, true, "SetBagItem", count)
		end
	end,
	--SetBagItemChild
	--SetBuybackItem -- already shown
	--SetCompareItem
	SetCraftItem = function(tt, index, reagent)
		local _, _, count = GetCraftReagentInfo(index, reagent)
		 -- otherwise returns an empty link
		local itemLink = GetCraftReagentItemLink(index, reagent)
		VP:SetPrice(tt, true, "SetCraftItem", count, itemLink)
	end,
	SetCraftSpell = function(tt)
		VP:SetPrice(tt, true, "SetCraftSpell")
	end,
	--SetHyperlink -- item information is not readily available
	SetInboxItem = function(tt, messageIndex, attachIndex)
		local count, itemID
		if attachIndex then
			count = select(4, GetInboxItem(messageIndex, attachIndex))
		else
			count, itemID = select(14, GetInboxHeaderInfo(messageIndex))
		end
		VP:SetPrice(tt, false, "SetInboxItem", count, itemID)
	end,
	SetInventoryItem = function(tt, unit, slot)
		local count
		if not CharacterBags[slot] then
			count = GetInventoryItemCount(unit, slot)
		end
		if slot < FIRST_KEYRING_INVSLOT then
			VP:SetPrice(tt, VP:IsShown(BankFrame), "SetInventoryItem", count)
		end
	end,
	--SetInventoryItemByID
	--SetItemByID
	SetLootItem = function(tt, slot)
		local _, _, count = GetLootSlotInfo(slot)
		VP:SetPrice(tt, false, "SetLootItem", count)
	end,
	SetLootRollItem = function(tt, rollID)
		local _, _, count = GetLootRollItemInfo(rollID)
		VP:SetPrice(tt, false, "SetLootRollItem", count)
	end,
	--SetMerchantCostItem -- alternate currency
	--SetMerchantItem -- already shown
	SetQuestItem = function(tt, questType, index)
		local _, _, count = GetQuestItemInfo(questType, index)
		VP:SetPrice(tt, false, "SetQuestItem", count)
	end,
	SetQuestLogItem = function(tt, _, index)
		local _, _, count = GetQuestLogRewardInfo(index)
		VP:SetPrice(tt, false, "SetQuestLogItem", count)
	end,
	--SetRecipeReagentItem -- retail
	--SetRecipeResultItem -- retail
	SetSendMailItem = function(tt, index)
		local count = select(4, GetSendMailItem(index))
		VP:SetPrice(tt, true, "SetSendMailItem", count)
	end,
	SetTradePlayerItem = function(tt, index)
		local _, _, count = GetTradePlayerItemInfo(index)
		VP:SetPrice(tt, true, "SetTradePlayerItem", count)
	end,
	SetTradeSkillItem = function(tt, index, reagent)
		local count
		if reagent then
			count = select(3, GetTradeSkillReagentInfo(index, reagent))
		else -- show minimum instead of maximum count
			count = GetTradeSkillNumMade(index)
		end
		VP:SetPrice(tt, false, "SetTradeSkillItem", count)
	end,
	SetTradeTargetItem = function(tt, index)
		local _, _, count = GetTradeTargetItemInfo(index)
		VP:SetPrice(tt, false, "SetTradeTargetItem", count)
	end,
	SetTrainerService = function(tt, index)
		VP:SetPrice(tt, true, "SetTrainerService")
	end,
}

for method, func in pairs(SetItem) do
	hooksecurefunc(GameTooltip, method, func)
end

ItemRefTooltip:HookScript("OnTooltipSetItem", function(tt)
	local item = select(2, tt:GetItem())
	if item then
		local sellPrice, classID = select(11, GetItemInfo(item))
		if sellPrice and sellPrice > 0 and not CheckRecipe(tt, classID, true) then
			SetTooltipMoney(tt, sellPrice, nil, SELL_PRICE_TEXT)
		end
	end
end)
