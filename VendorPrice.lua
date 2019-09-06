local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)

local function ShouldShowPrice(tt)
	if MerchantFrame:IsShown() then
		local name = tt:GetOwner():GetName()
		return name:find("Character") or name:find("TradeSkill")
	end
	return true
end

local function SetPrice(tt, count, item)
	if ShouldShowPrice(tt) then
		item = item or select(2, tt:GetItem())
		if item then
			local sellPrice = select(11, GetItemInfo(item))
			local money = sellPrice * count
			if money > 0 then
				if IsShiftKeyDown() and count > 1 then
					SetTooltipMoney(tt, sellPrice, nil, SELL_PRICE_TEXT.." |cffAAAAFFx1|r")
				else
					SetTooltipMoney(tt, money, nil, SELL_PRICE_TEXT)
				end
				tt:Show()
			end
		end
	end
end

local SetItem = {
	SetAction = function(tt, slot)
		if GetActionInfo(slot) == "item" then
			SetPrice(tt, GetActionCount(slot))
		end
	end,
	SetAuctionItem = function(tt, auctionType, index)
		local _, _, count = GetAuctionItemInfo(auctionType, index)
		SetPrice(tt, count)
	end,
	SetAuctionSellItem = function(tt)
		local _, _, count = GetAuctionSellItemInfo()
		SetPrice(tt, count)
	end,
	SetBagItem = function(tt, bag, slot)
		local _, count = GetContainerItemInfo(bag, slot)
		SetPrice(tt, count)
	end,
	--SetBagItemChild
	--SetBuybackItem -- already shown
	--SetCompareItem
	SetCraftItem = function(tt, index, reagent)
		local _, _, count = GetCraftReagentInfo(index, reagent)
		 -- otherwise returns an empty link
		local itemLink = GetCraftReagentItemLink(index, reagent)
		SetPrice(tt, count, itemLink)
	end,
	SetInboxItem = function(tt, messageIndex, attachIndex)
		local count, itemID
		if attachIndex then
			count = select(4, GetInboxItem(messageIndex, attachIndex))
		else
			count, itemID = select(14, GetInboxHeaderInfo(messageIndex))
		end
		SetPrice(tt, count, itemID)
	end,
	SetInventoryItem = function(tt, unit, slot)
		local count = GetInventoryItemCount(unit, slot)
		SetPrice(tt, count == 0 and 1 or count) -- equipped bags return 0
	end,
	--SetInventoryItemByID
	--SetItemByID
	SetLootItem = function(tt, slot)
		local _, _, count = GetLootSlotInfo(slot)
		SetPrice(tt, count)
	end,
	SetLootRollItem = function(tt, rollID)
		local _, _, count = GetLootRollItemInfo(rollID)
		SetPrice(tt, count)
	end,
	--SetMerchantCostItem -- alternate currency
	--SetMerchantItem -- already shown
	SetQuestItem = function(tt, questType, index)
		local _, _, count = GetQuestItemInfo(questType, index)
		SetPrice(tt, count)
	end,
	SetQuestLogItem = function(tt, _, index)
		local _, _, count = GetQuestLogRewardInfo(index)
		SetPrice(tt, count)
	end,
	SetSendMailItem = function(tt, index)
		local count = select(4, GetSendMailItem(index))
		SetPrice(tt, count)
	end,
	SetTradePlayerItem = function(tt, index)
		local _, _, count = GetTradePlayerItemInfo(index)
		SetPrice(tt, count)
	end,
	SetTradeSkillItem = function(tt, index, reagent)
		local count
		if reagent then
			count = select(3, GetTradeSkillReagentInfo(index, reagent))
		else -- show minimum instead of maximum count
			count = GetTradeSkillNumMade(index)
		end
		SetPrice(tt, count)
	end,
	SetTradeTargetItem = function(tt, index)
		local _, _, count = GetTradeTargetItemInfo(index)
		SetPrice(tt, count)
	end,
}

for name, func in pairs(SetItem) do
	hooksecurefunc(GameTooltip, name, func)
end

-- item information is not readily available on tt:SetHyperlink()
ItemRefTooltip:HookScript("OnTooltipSetItem", function(tt)
	local item = select(2, tt:GetItem())
	if item then
		local itemSellPrice = select(11, GetItemInfo(item))
		if itemSellPrice and itemSellPrice > 0 then
			tt.shownMoneyFrames = nil -- OnTooltipSetItem fires twice for recipes
			SetTooltipMoney(tt, itemSellPrice, nil, SELL_PRICE_TEXT)
		end
	end
end)

local function OnEvent(self, event, isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		-- support bagnon /bank
		if Bagnon then
			GameTooltip:HookScript("OnTooltipSetItem", function(tt)
				if BagnonFramebank and BagnonFramebank:IsMouseOver() then
					local info = tt:GetOwner():GetParent().info
					if info then
						tt.shownMoneyFrames = nil
						SetPrice(tt, info.count or 1)
					end
				end
			end)
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)
