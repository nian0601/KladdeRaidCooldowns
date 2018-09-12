KRC_PallyAuras = {}

KRC_PallyAuras.myAuras =
{
	{ ["SpellID"] = 48942, ["Name"] = "Devotion Aura"},
	{ ["SpellID"] = 54043, ["Name"] = "Retribution Aura"},
	{ ["SpellID"] = 19746, ["Name"] = "Concentration Aura"},
	{ ["SpellID"] = 48943, ["Name"] = "Shadow Resistance Aura"},
	{ ["SpellID"] = 48947, ["Name"] = "Fire Resistance Aura"},
	{ ["SpellID"] = 48945, ["Name"] = "Frost Resistance Aura"},
	{ ["SpellID"] = 32223, ["Name"] = "Crusader Aura"}
}

KRC_PallyAuras.myFrames = {}
local pallyNameWidth = 100

function KRC_PallyAuras:GetAuraNameForPally(aPally)
	for i = 1, 7 do
		local name,_,_,_,_,_,_, source = UnitBuff("player", self.myAuras[i].Name)
		if (name ~= nil) then
			if UnitName(source) == aPally then
				return self.myAuras[i].Name
			end
		end
	end

	return nil
end

function KRC_PallyAuras:ToggleVisibility(aValue)
	KRC_Core.db.profile.pally_auras.isEnabled = aValue

	for i = 1, 7 do
		if aValue == true then
			self.myFrames[i]:Show()
		else
			self.myFrames[i]:Hide()
		end
	end
end

function KRC_PallyAuras:ToggleDragableFrame(aValue)
	self.DragableFrame:SetMovable(aValue)
	self.DragableFrame:EnableMouse(aValue)
end

function KRC_PallyAuras:CreateDragableFrame()
	self.DragableFrame = CreateFrame("Frame")
	self.DragableFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", KRC_Core.db.profile.pally_auras.bottomLeftX, KRC_Core.db.profile.pally_auras.bottomLeftY)
	self.DragableFrame:SetWidth(self.myTotalWidth)
	self.DragableFrame:SetHeight(self.myTotalHeight)

	self.DragableFrame:RegisterForDrag("LeftButton")
	self.DragableFrame:SetScript("OnDragStart", self.DragableFrame.StartMoving)
	self.DragableFrame:SetScript("OnDragStop", function(aWidget)
		aWidget:StopMovingOrSizing()
		KRC_Core.db.profile.pally_auras.bottomLeftX = aWidget:GetLeft()
		KRC_Core.db.profile.pally_auras.bottomLeftY = aWidget:GetBottom()
	end)
end

function KRC_PallyAuras:CreateText(aName, aParent)
	local frame = CreateFrame("Frame", aName, aParent)
	frame:SetFrameStrata("LOW")
	frame:SetFrameLevel(1)

	frame.Text = frame:CreateFontString(frame:GetName(), "LODW", "GameFontHighlightSmallOutline")
	frame.Text:SetFontObject("GameFontHighlightSmallOutline")
	frame.Text:SetTextColor(1, 1, 1)
	frame.Text:SetText("")
	return frame
end

function KRC_PallyAuras:Init()
	self.myTotalWidth = KRC_Core.db.profile.pally_auras.height + pallyNameWidth
	self.myBarHeigth = KRC_Core.db.profile.pally_auras.height
	self.myTotalHeight = KRC_Core.db.profile.pally_auras.height * 7

	self:CreateDragableFrame()

	for i = 1, 7 do
		local frame = CreateFrame("Frame", "KRC_PallyAura" .. i, self.DragableFrame)

		frame:SetFrameStrata("BACKGROUND")
		frame:SetFrameLevel(2)
		frame:SetWidth(self.myTotalWidth)
		frame:SetHeight(self.myBarHeigth)
		frame:SetPoint("TOPLEFT", self.DragableFrame, "TOPLEFT", 0, -self.myBarHeigth * i - 3)

		frame.icon = frame:CreateTexture(nil, "LOW")
		frame.icon:SetWidth(self.myBarHeigth)
		frame.icon:SetHeight(self.myBarHeigth)
		frame.icon:SetTexture(KRC_Core.MediaPath .. "Texture\\statusbar")
		frame.icon:SetVertexColor(1, 1, 1)
		frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

		local _, _, icon = GetSpellInfo(self.myAuras[i].SpellID)
		frame.icon:SetTexture(icon)

		frame.lable = self:CreateText(frame:GetName() .. "_Label", frame)
		frame.lable.Text:ClearAllPoints()
		frame.lable.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", self.myBarHeigth+2, 0)
		frame.lable.Text:SetWidth(pallyNameWidth)
		frame.lable.Text:SetHeight(self.myBarHeigth)
		frame.lable.Text:SetJustifyH("LEFT")
		frame.lable.Text:SetText(self.myAuras[i])

		frame:Show()
		table.insert(self.myFrames, frame)
	end
end

function KRC_PallyAuras:Update()
	if(KRC_Core.db.profile.pally_auras.isEnabled == true) then
		for i = 1, 7 do
			local name,_,_,_,_,_,_, source = UnitBuff("player", self.myAuras[i].Name)
			if (name ~= nil) then
				self.myFrames[i]:Show()
				self.myFrames[i].lable.Text:SetText(UnitName(source))
			else
				self.myFrames[i]:Hide()
			end
		end

		local count = 1
		for i = 1, 7 do
			if(self.myFrames[i]:IsVisible()) then
				self.myFrames[i]:SetPoint("TOPLEFT", self.DragableFrame, "TOPLEFT", 0, -self.myBarHeigth * count - 3)
				count = count + 1
			end
		end
	end
end