local VP = VendorPrice

local function SetPrice(tt, count, item)
	VP:SetPrice(tt, "Compat", count, item, true)
end

local function IsShown(frame)
	return frame and frame:IsShown() and frame:IsMouseOver()
end

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

GameTooltip:HookScript("OnTooltipSetItem", function(tt)
	if AucAdvanced and IsShown(AuctionFrame) then
		for frame, func in pairs(Auctioneer) do
			if IsShown(_G[frame]) then
				func(tt)
				break
			end
		end
	elseif Auctionator and IsShown(Atr_Main_Panel) then
		SetPrice(tt)
	elseif AuctionFaster and IsShown(AuctionFrame) and AuctionFrame.selectedTab >= 4 then
		local count
		if AuctionFrame.selectedTab == 4 then -- sell
			local item = tt:GetOwner().item
			count = item and item.count
		elseif AuctionFrame.selectedTab == 5 then -- buy
			local hoverRowData = AuctionFaster.hoverRowData
			count = hoverRowData and hoverRowData.count -- provided by AuctionFaster
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

-- give auctionator precedence
local AuctionatorTips = {
	Compat = true,
	OnTooltipSetItem = true,
	SetAuctionItem = true,
	SetAuctionSellItem = true,
	SetBagItem = true,
	SetInboxItem = true, -- AUCTIONATOR_SHOW_MAILBOX_TIPS
	SetInventoryItem = true,
	SetLootItem = true,
	SetLootRollItem = true,
	SetQuestItem = true,
	SetQuestLogItem = true,
	SetSendMailItem = true,
	SetTradePlayerItem = true,
	SetTradeTargetItem = true,
	--SetAction
	--SetCraftItem
	--SetCraftSpell
	--SetTradeSkillItem
	--SetTrainerService
}

function VP:HasAuctionator(source)
	return AUCTIONATOR_V_TIPS == 1 and AuctionatorTips[source]
end
