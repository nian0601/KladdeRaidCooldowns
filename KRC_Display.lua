local tformat1 = "%d:%02d"
local tformat2 = "%1.1f"
local tformat3 = "%.0f"

local function SecondsToTimeDetail( t )
	if t >= 3600 then -- > 1 hour
		local h = floor(t/3600)
		local m = t - (h*3600)
		return tformat1, h, m
	elseif t >= 60 then -- 1 minute to 1 hour
		local m = floor(t/60)
		local s = t - (m*60)
		return tformat1, m, s
	elseif t < 10 then -- 0 to 10 seconds
		return tformat2, t
	else -- 10 seconds to one minute
		return tformat3, floor(t + .5)
	end
end

--[[

We'll be organizing things in "Groups".
Each groups will contain the following info:

myTitle, The title of the group, will be displayed ingame (OPTIONAL)
mySpells, Table of all spells to track, each entry will have two booleans
mySpells[SPELLID].myEnable, Should this SPELLID be tracked at all?
mySpells[SPELLID].myHideWhenReady, Should this SPELLID only be visible while its on cooldown?
myPositionX/Y, Where on the screen is the group positioned
myMainFrame, Containerframe for all the stuff in the group, that we use to move the group around

myFrames, A list of all the currently active frames
Each frame contains the following:
myCaster, The name of the caster
mySpellID, The ID of the spell
myCasterLabel, Textwidget containing the name of the caster
mySpellLabel, Textwiget containing the name of the spell, abbreviated where possible
myCooldownLabel, Textwidget containing the remaining cooldown, or "Ready"-text if shown even when ready

]]

KRC_Display = LibStub("AceAddon-3.0"):NewAddon("KRC_Display", "AceConsole-3.0", "AceEvent-3.0")
KRC_Display.myTextHeight = 10
KRC_Display.myGroups = {}

function KRC_Display:OnInitialize()
	self:CreateEmptyGroup("Default")
end	

function KRC_Display:CreateEmptyGroup(aGroupName)
	if(self.myGroups[aGroupName] ~= nil) then
		-- We allready have a group with this name.. output error?
		return
	end

	self.myGroups[aGroupName] = {}
	local group = self.myGroups[aGroupName]
	group.myTitle = aGroupName
	group.mySpells = {}
	group.myFrames = {}
	group.myPositionX = 0
	group.myPositionY = 0

	group.myMainFrame = CreateFrame("Frame", "KRC_Display_" .. aGroupName)
	group.myMainFrame:SetFrameStrata("BACKGROUND")
	group.myMainFrame:SetFrameLevel(1)
	group.myMainFrame:SetWidth(100)
	group.myMainFrame:SetHeight(100)
	group.myMainFrame:ClearAllPoints()
	group.myMainFrame:SetPoint("CENTER", UIParent, "CENTER", group.myPositionX, group.myPositionY)
end

function KRC_Display:FindFrameInGroup(aGroup, aSpellID, aCasterName)
	local numFrames = table.getn(aGroup.myFrames)
	for i = 1, numFrames do
		local frame = aGroup.myFrames[i]

		if (frame.mySpellID == aSpellID and frame.myCaster == aCasterName) then
			return frame
		end
	end

	return nil
end

function KRC_Display:CreateText(aName, aParent)
	local frame = CreateFrame("Frame", aName, aParent)
	frame:SetFrameStrata("LOW")
	frame:SetFrameLevel(1)

	frame.Text = frame:CreateFontString(frame:GetName(), "LODW", "GameFontHighlightSmallOutline")
	frame.Text:SetFontObject("GameFontHighlightSmallOutline")
	frame.Text:SetTextColor(1, 1, 1)
	frame.Text:SetJustifyH("LEFT")
	frame.Text:SetText("")

	return frame
end

function KRC_Display:RepositionFramesInGroup(aGroup)
	local numFrames = table.getn(aGroup.myFrames)
	for i = 1, numFrames do
		local frame = aGroup.myFrames[i]

		frame:ClearAllPoints()
		frame:SetPoint("CENTER", aGroup.myMainFrame, "CENTER", 0, i * -10 - 10)
	end
end

function KRC_Display:CreateFrameAndAddToGroup(aGroup, aSpellID, aCasterName, aCasterClass)
	self:Print("Trying to CreateFrameAndAddToGroup")
	self:Print("Need to create a frame for " .. aCasterName)
	local numFrames = table.getn(aGroup.myFrames)

	local frame = CreateFrame("Frame", "KRC_Display_" .. aGroup.myTitle .. numFrames + 1, aGroup.myMainFrame)
	frame.mySpellID = aSpellID
	frame.myCaster = aCasterName

	frame:ClearAllPoints()
	frame:SetPoint("CENTER", aGroup.myMainFrame, "CENTER", 0, 0)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetFrameLevel(2)
	frame:SetWidth(100)
	frame:SetHeight(10)

	frame.myCasterLable = self:CreateText(frame:GetName() .. "_CasterLable", frame)
	frame.myCasterLable.Text:ClearAllPoints()
	frame.myCasterLable.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	frame.myCasterLable.Text:SetWidth(50)
	frame.myCasterLable.Text:SetHeight(self.myTextHeight)
	frame.myCasterLable.Text:SetText(aCasterName)
	frame.myCasterLable.Text:Show()

	local iconPosition = frame.myCasterLable.Text:GetWidth() + 5
	local _, _, spellIcon = GetSpellInfo(aSpellID)
	frame.icon = frame:CreateTexture(nil, "LOW")
	frame.icon:SetWidth(self.myTextHeight)
	frame.icon:SetHeight(self.myTextHeight)
	frame.icon:SetTexture(spellIcon)
	frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", iconPosition, -1)

	local spellPosition = iconPosition + frame.icon:GetWidth() + 5
	frame.mySpellLabel = self:CreateText(frame:GetName() .. "_CasterLable", frame)
	frame.mySpellLabel.Text:ClearAllPoints()
	frame.mySpellLabel.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", spellPosition, 0)
	frame.mySpellLabel.Text:SetWidth(50)
	frame.mySpellLabel.Text:SetHeight(self.myTextHeight)
	frame.mySpellLabel.Text:SetText(KRC_Spells:GetShortName(aCasterClass, aSpellID))
	frame.mySpellLabel.Text:Show()

	local cooldownPosition = spellPosition + frame.mySpellLabel.Text:GetWidth() + 5
	frame.myCooldownLabel = self:CreateText(frame:GetName() .. "_CasterLable", frame)
	frame.myCooldownLabel.Text:ClearAllPoints()
	frame.myCooldownLabel.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", cooldownPosition, 0)
	frame.myCooldownLabel.Text:SetWidth(50)
	frame.myCooldownLabel.Text:SetHeight(self.myTextHeight)
	frame.myCooldownLabel.Text:SetText(0)
	frame.myCooldownLabel.Text:Show()

	table.insert(aGroup.myFrames, frame)
	self:RepositionFramesInGroup(aGroup)
	return frame
end

function KRC_Display:UpdateSpellDataInGroup(aSpellID, someSpellData, aGroup)
	-- We wont get to this function at all, if aSpellID isnt enabled for the group
	-- so no point in checking for myEnable here, just need to care about myHideWhenReady

	for casterName, casterData in pairs(someSpellData) do 
		local frame = self:FindFrameInGroup(aGroup, aSpellID, casterName)
		if (frame == nil) then
			frame = self:CreateFrameAndAddToGroup(aGroup, aSpellID, casterName, casterData.myClass)
		end
		if (casterData.myRemainingCD > 0) then
			frame.myCooldownLabel.Text:SetFormattedText(SecondsToTimeDetail(casterData.myRemainingCD))
		else
			frame.myCooldownLabel.Text:SetText("READY")
		end
		--elseif (aGroup.mySpells[aSpellID].myHideWhenReady == false) then
		--
		--end
	end
end

function KRC_Display:Update()
	local group = self.myGroups["Default"]

	for spellID, spellData in pairs(KRC_DataCollector.myData) do
		if (group.mySpells[spellID] == nil) then
			group.mySpells[spellID] = {}
		end

		-- Is this spell enabled at all in this group?
		--if (group.mySpells[spellID].myEnable == true) then
			self:UpdateSpellDataInGroup(spellID, spellData, group)
		--end
	end
end