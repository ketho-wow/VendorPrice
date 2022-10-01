local VP = VendorPrice

local function SetPrice(tt, count, item)
	VP:SetPrice(tt, false, "Compat", count, item, true)
end

function VP:IsShown(frame)
	return frame and frame:IsVisible() and frame:IsMouseOver()
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
	if AucAdvanced and VP:IsShown(AuctionFrame) then
		for frame, func in pairs(Auctioneer) do
			if VP:IsShown(_G[frame]) then
				func(tt)
				break
			end
		end
	elseif AuctionFaster and VP:IsShown(AuctionFrame) and AuctionFrame.selectedTab >= 4 then
		local count
		if AuctionFrame.selectedTab == 4 then -- sell
			local item = tt:GetOwner().item
			count = item and item.count
		elseif AuctionFrame.selectedTab == 5 then -- buy
			local hoverRowData = AuctionFaster.hoverRowData
			count = hoverRowData and hoverRowData.count -- provided by AuctionFaster
		end
		SetPrice(tt, count)
	elseif AtlasLoot and VP:IsShown(_G["AtlasLoot_GUI-Frame"]) then
		SetPrice(tt)
	else -- Chatter, Prat: check for active chat windows
		local mouseFocus = GetMouseFocus()
		if mouseFocus and mouseFocus:GetObjectType() == "FontString" then
			for i = 1, FCF_GetNumActiveChatFrames() do
				if _G["ChatFrame"..i]:IsMouseOver() then
					SetPrice(tt)
					break
				end
			end
		end
	end
end)
