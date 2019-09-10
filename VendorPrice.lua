local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)
local COUNT_TEXT = " |cffAAAAFFx%d|r"

local function ShouldShowPrice(tt)
	if MerchantFrame:IsShown() then
		local name = tt:GetOwner():GetName()
		if name then -- bagnon sanity check
			return name:find("Character") or name:find("TradeSkill")
		end
	end
	return true
end

local function GetAmountString(count, isShift)
	local spacing = count < 10 and "  " or ""
	return (count > 1 or isShift) and COUNT_TEXT:format(count)..spacing or ""
end

-- OnTooltipSetItem fires twice for recipes
local function CheckRecipe(tt, classID, isBagItem)
	if classID == LE_ITEM_CLASS_RECIPE and not isBagItem then
		tt.isFirstMoneyLine = not tt.isFirstMoneyLine
		return not tt.isFirstMoneyLine
	end
	return true
end

local function SetPrice(tt, count, item, isBagItem)
	if ShouldShowPrice(tt) then
		count = count or 1
		item = item or select(2, tt:GetItem())
		if item then
			local sellPrice, classID = select(11, GetItemInfo(item))
			if sellPrice and sellPrice > 0 and CheckRecipe(tt, classID, isBagItem) then
				if IsShiftKeyDown() and count > 1 then
					SetTooltipMoney(tt, sellPrice, nil, SELL_PRICE_TEXT..GetAmountString(1, true))
				else
					SetTooltipMoney(tt, sellPrice * count, nil, SELL_PRICE_TEXT..GetAmountString(count))
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
		SetPrice(tt, count, nil, true)
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
	SetCraftSpell = function(tt)
		SetPrice(tt)
	end,
	--SetHyperlink -- item information is not readily available
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

for method, func in pairs(SetItem) do
	hooksecurefunc(GameTooltip, method, func)
end

ItemRefTooltip:HookScript("OnTooltipSetItem", function(tt)
	local item = select(2, tt:GetItem())
	if item then
		local sellPrice, classID = select(11, GetItemInfo(item))
		if sellPrice and sellPrice > 0 and CheckRecipe(tt, classID) then
			SetTooltipMoney(tt, sellPrice, nil, SELL_PRICE_TEXT)
		end
	end
end)

local Auctioneer = {
	AucAdvAppraiserFrame = function(tt)
		local itemID = select(2, tt:GetItem()):match("item:(%d+)")
		for _, v in pairs(AucAdvAppraiserFrame.list) do
			if v[1] == itemID then
				SetPrice(tt, v[6])
				break
			end
		end
	end,
	AucAdvSearchUiAuctionFrame = function(tt)
		local row = tt:GetOwner():GetID()
		local count = AucAdvanced.Modules.Util.SearchUI.Private.gui.sheet.rows[row][4]
		SetPrice(tt, tonumber(count:GetText()))
	end,
	AucAdvSimpFrame = function(tt)
		SetPrice(tt, AucAdvSimpFrame.detail[1])
	end,
}

local function IsShown(frame)
	return frame and frame:IsShown() and frame:IsMouseOver()
end

GameTooltip:HookScript("OnTooltipSetItem", function(tt)
	if AucAdvanced and IsShown(AuctionFrame) then
		for frame, func in pairs(Auctioneer) do
			if IsShown(_G[frame]) then
				func(tt)
				break
			end
		end
	elseif AuctionFaster and IsShown(AuctionFrame) and AuctionFrame.selectedTab >= 4 then
		local count
		if AuctionFrame.selectedTab == 4 then
			count = tt:GetOwner().item.count
		elseif AuctionFrame.selectedTab == 5 then
			count = AuctionFaster.hoverRowData.count -- provided by AuctionFaster
		end
		SetPrice(tt, count)
	elseif Bagnon and IsShown(BagnonFramebank) then
		local info = tt:GetOwner():GetParent().info
		if info then -- /bagnon bank
			SetPrice(tt, info.count)
		end
	-- lazy check for any chat windows that are docked to ChatFrame1
	elseif DEFAULT_CHAT_FRAME:IsMouseOver() then -- Chatter, Prat
		SetPrice(tt)
	end
end)
