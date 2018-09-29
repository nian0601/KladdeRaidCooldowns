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
mySpells[SPELLID].myEnabled, Should this SPELLID be tracked at all?
mySpells[SPELLID].myAlwaysShow, Should this SPELLID only be visible while its on cooldown?
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
KRC_Display.myFreeFrames = {}
KRC_Display.myEnableDebugPrinting = false

function KRC_Display:Init()
	self.myMediaPath = "Interface\\Addons\\KladdeRaidCooldowns_V2\\Media\\"

	self:InitializeGlobalDBVariables()

	for groupName, groupSettings in pairs(KRC_Core.db.profile.myGroups) do 
		self:CreateEmptyGroup(groupName)
		self:ApplyGroupSettings(self.myGroups[groupName], groupSettings)
	end
	
	--self:CreateEmptyGroup("Raid CDs")
end	

function KRC_Display:DebugPrint(aMessage)
	if(self.myEnableDebugPrinting == true) then
		self:Print(aMessage)
	end
end

function KRC_Display:IsInLockedMode()
	return KRC_Core.db.profile.myIsLocked
end

function KRC_Display:SetLockedMode(aStatus)
	KRC_Core.db.profile.myIsLocked = aStatus

	for groupName, group in pairs(self.myGroups) do 
		self:SetGroupLockedStatus(group, aStatus)
	end
end

function KRC_Display:GetPlayerSpecc(aPlayerName)
	local settings = KRC_Core.db.profile

	return settings.myPlayerSpeccs[aPlayerName]
end

function KRC_Display:SetPlayerSpecc(aPlayerName, aSpecc, aShouldSet)
	local settings = KRC_Core.db.profile

	if(aShouldSet == false and settings.myPlayerSpeccs[aPlayerName] == aSpecc) then
		settings.myPlayerSpeccs[aPlayerName] = nil
	elseif(aShouldSet == true) then
		settings.myPlayerSpeccs[aPlayerName] = aSpecc
	end
end
--
-- Group Management
--

function KRC_Display:InitializeGlobalDBVariables()
	local settings = KRC_Core.db.profile
	if(settings.myIsLocked == nil) then
		settings.myIsLocked = false
	end
end

function KRC_Display:InitializeGroupDBVariables(aGroupName)
	if(KRC_Core.db.profile.myGroups[aGroupName] == nil) then
		KRC_Core.db.profile.myGroups[aGroupName] = {}

	end
	local settings = KRC_Core.db.profile.myGroups[aGroupName]
	if (settings.mySpells == nil) then
		settings.mySpells = {}
	end

	if (settings.mySpeccs == nil) then
		settings.mySpeccs = {}

		for class, speccInfo in pairs(KRC_Spells.mySpeccs) do
			settings.mySpeccs[class] = {}

			for speccName, active in pairs(speccInfo) do
				settings.mySpeccs[class][speccName] = true	
			end
		end
	end

	if(settings.myGrowBarsUp == nil) then
		settings.myGrowBarsUp = false
	end

	if(settings.myBarSpacing == nil) then
		settings.myBarSpacing = 2
	end

	if(settings.myIsLocked == nil) then
		settings.myIsLocked = true
	end
end

function KRC_Display:CreateEmptyGroup(aGroupName)
	self:InitializeGroupDBVariables(aGroupName)
		

	if(self.myGroups[aGroupName] ~= nil) then
		-- We allready have a group with this name.. output error?
		return
	end

	self.myGroups[aGroupName] = {}
	local group = self.myGroups[aGroupName]
	group.myTitle = aGroupName
	group.mySpells = {}
	group.myFrames = {}
	local x = (GetScreenWidth() * UIParent:GetEffectiveScale()) / 2
	local y = (GetScreenHeight() * UIParent:GetEffectiveScale()) / 2

	group.myMainFrame = CreateFrame("Frame", "KRC_Display_" .. aGroupName)
	local mainFrame = group.myMainFrame;
	mainFrame:SetFrameStrata("BACKGROUND")
	mainFrame:SetFrameLevel(1)
	mainFrame:SetWidth(125)
	mainFrame:SetHeight(self.myTextHeight + 5)
	mainFrame:ClearAllPoints()
	mainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	mainFrame:RegisterForDrag("LeftButton")
	mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
	mainFrame:SetScript("OnDragStop", function(aWidget)
		aWidget:StopMovingOrSizing()
		KRC_Core.db.profile.myGroups[aGroupName].myBottomLeftX = aWidget:GetLeft() * UIParent:GetEffectiveScale()
		KRC_Core.db.profile.myGroups[aGroupName].myBottomLeftY = aWidget:GetBottom() * UIParent:GetEffectiveScale()
	end)

	mainFrame.myBackground = mainFrame:CreateTexture(nil, "LOW")
	mainFrame.myBackground:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
	mainFrame.myBackground:SetTexture(0.1, 0.07, 0.08, 0.8)
	mainFrame.myBackground:SetWidth(mainFrame:GetWidth())
	mainFrame.myBackground:SetHeight(mainFrame:GetHeight())

	mainFrame.myLabel = self:CreateText(mainFrame:GetName() .. "_Label", mainFrame)
	mainFrame.myLabel.Text:ClearAllPoints()
	mainFrame.myLabel.Text:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
	mainFrame.myLabel.Text:SetWidth(100)
	mainFrame.myLabel.Text:SetHeight(self.myTextHeight)
	mainFrame.myLabel.Text:SetTextColor(0.9, 0.9, 0.9)
	mainFrame.myLabel.Text:SetText("[" .. aGroupName .. "]")

	self:ApplyGroupSettings(group, KRC_Core.db.profile.myGroups[aGroupName])
end

function KRC_Display:DeleteGroup(aGroupName)
	local realGroup = self.myGroups[aGroup]
	if (realGroup ~= nil) then
		while(table.getn(realGroup.myFrames) > 0) do
			self:RemoveFrameFromGroup(realGroup.myFrames[1], 1, realGroup)
		end
	end

	self.myGroups[aGroupName].myMainFrame:Hide()
	self.myGroups[aGroupName].myMainFrame = nil
	self.myGroups[aGroupName] = nil
	KRC_Core.db.profile.myGroups[aGroupName] = nil
end

function KRC_Display:GetGroupSettings(aGroupName)
	return KRC_Core.db.profile.myGroups[aGroupName]
end

function KRC_Display:ApplyGroupSettings(aGroup, someSettings)

	if (someSettings.mySpells ~= nil) then
		for spellID, spellInfo in pairs(someSettings.mySpells) do 
			aGroup.mySpells[spellID] = {}
			aGroup.mySpells[spellID].myEnabled = spellInfo.myEnabled
			aGroup.mySpells[spellID].myAlwaysShow = spellInfo.myAlwaysShow
		end
	end

	if (someSettings.myBottomLeftX ~= nil) then
		aGroup.myMainFrame:ClearAllPoints()
		aGroup.myMainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", someSettings.myBottomLeftX, someSettings.myBottomLeftY)
	end

	self:SetGroupLockedStatus(aGroup, KRC_Core.db.profile.myIsLocked)
end

function KRC_Display:SetGroupLockedStatus(aGroup, aStatus)
	aGroup.myMainFrame:SetMovable(aStatus)
	aGroup.myMainFrame:EnableMouse(aStatus)
end

function KRC_Display:IsGroupGrowUp(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return false
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.myGrowBarsUp
end

function KRC_Display:SetGroupGrowUp(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return false
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.myGrowBarsUp = aValue

	self:RepositionFramesInGroup(realGroup)
end

function KRC_Display:IsSpeccActiveForGroup(aGroupName, aClass, aSpecc)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return false
	end

	if(aSpecc == nil) then
		return false
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.mySpeccs[aClass][aSpecc] == true
end

function KRC_Display:SetSpeccStatusForGroup(aGroupName, aClass, aSpecc, aStatus)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.mySpeccs[aClass][aSpecc] = aStatus
end

--
-- Frame management
--

local function CompareFrames(aFrame, bFrame)
	local a = aFrame
	local b = bFrame
	if(a.myCasterClass ~= b.myCasterClass) then
		return a.myCasterClass < b.myCasterClass
	end

	if(a.mySpellID ~= b.mySpellID) then
		return a.mySpellID < b.mySpellID
	end

	return a.myRemainingCD < b.myRemainingCD
end

function KRC_Display:CreateFrameAndAddToGroup(aGroup, aSpellID, aCasterName, aCasterClass)
	local frame

	local numFreeFrames = table.getn(self.myFreeFrames)
	if(numFreeFrames > 0) then
		frame = table.remove(self.myFreeFrames)
	else
		local numFrames = table.getn(aGroup.myFrames)
		frame = CreateFrame("Frame", "KRC_Display_" .. aGroup.myTitle .. numFrames + 1, aGroup.myMainFrame)	
	end

	frame.mySpellID = aSpellID
	frame.myCaster = aCasterName
	frame.myCasterClass = aCasterClass
	frame.myRemainingCD = 10000

	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", aGroup.myMainFrame, "TOPLEFT", 0, 0)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetFrameLevel(2)
	frame:SetHeight(10)

	local color = RAID_CLASS_COLORS[aCasterClass]
	local casterLableWidth = 50
	local spellLableWidth = 45
	local cooldownLableWidth = 40


	if(frame.myCasterLable == nil) then
		frame.myCasterLable = self:CreateText(frame:GetName() .. "_CasterLable", frame)
	end

	frame.myCasterLable.Text:ClearAllPoints()
	frame.myCasterLable.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	frame.myCasterLable.Text:SetWidth(casterLableWidth)
	frame.myCasterLable.Text:SetHeight(self.myTextHeight)
	frame.myCasterLable.Text:SetTextColor(color.r, color.g, color.b)
	frame.myCasterLable.Text:SetText(aCasterName)

	local iconPosition = frame.myCasterLable.Text:GetWidth() + 5
	local _, _, spellIcon = GetSpellInfo(aSpellID)

	if(frame.icon == nil) then
		frame.icon = frame:CreateTexture(nil, "LOW")
	end

	frame.icon:SetWidth(self.myTextHeight)
	frame.icon:SetHeight(self.myTextHeight)
	frame.icon:SetTexture(spellIcon)
	frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", iconPosition, -1)

	local spellPosition = iconPosition + frame.icon:GetWidth() + 5
	if(frame.mySpellLabel == nil) then
		frame.mySpellLabel = self:CreateText(frame:GetName() .. "_CasterLable", frame)
	end
	frame.mySpellLabel.Text:ClearAllPoints()
	frame.mySpellLabel.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", spellPosition, 0)
	frame.mySpellLabel.Text:SetWidth(spellLableWidth)
	frame.mySpellLabel.Text:SetHeight(self.myTextHeight)
	frame.mySpellLabel.Text:SetTextColor(color.r, color.g, color.b)
	frame.mySpellLabel.Text:SetText(KRC_Spells:GetShortName(aCasterClass, aSpellID))

	local cooldownPosition = spellPosition + frame.mySpellLabel.Text:GetWidth() + 5
	if(frame.myCooldownLabel == nil) then
		frame.myCooldownLabel = self:CreateText(frame:GetName() .. "_CasterLable", frame)
	end

	frame.myCooldownLabel.Text:ClearAllPoints()
	frame.myCooldownLabel.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", cooldownPosition, 0)
	frame.myCooldownLabel.Text:SetWidth(cooldownLableWidth)
	frame.myCooldownLabel.Text:SetHeight(self.myTextHeight)
	frame.myCooldownLabel.Text:SetTextColor(0.85, 0.1, 0.1)
	frame.myCooldownLabel.Text:SetText(0)

	frame:SetWidth(cooldownPosition + cooldownLableWidth)
	frame:Show()
	table.insert(aGroup.myFrames, frame)
	self:RepositionFramesInGroup(aGroup)
	return frame, table.getn(aGroup.myFrames)
end

function KRC_Display:RemoveFrameFromGroup(aFrame, aFrameIndex, aGroup)
	aFrame:Hide()
	table.insert(self.myFreeFrames, aFrame)
	table.remove(aGroup.myFrames, aFrameIndex)

	self:RepositionFramesInGroup(aGroup)
end

function KRC_Display:RepositionFramesInGroup(aGroup)
	table.sort(aGroup.myFrames, CompareFrames)

	local groupSettings = self:GetGroupSettings(aGroup.myTitle)

	local barSpacing = 2
	local growUpwards = false
	if(groupSettings ~= nil) then
		barSpacing = groupSettings.myBarSpacing
		growUpwards = groupSettings.myGrowBarsUp
	end

	local frameMovement = barSpacing + self.myTextHeight
	if(growUpwards == true) then
		frameMovement = -frameMovement
	end

	local numFrames = table.getn(aGroup.myFrames)
	if(numFrames > 0) then
		
		local width = aGroup.myFrames[1]:GetWidth()
		local height = numFrames * aGroup.myFrames[1]:GetHeight()
		-- Account for the GroupLable
		height = height + self.myTextHeight
		-- Add a some extra padding
		height = height + (barSpacing * numFrames) + 5
		aGroup.myMainFrame:SetWidth(width)
		aGroup.myMainFrame:SetHeight(height)

		aGroup.myMainFrame.myBackground:SetWidth(width)
		aGroup.myMainFrame.myBackground:SetHeight(height)

		aGroup.myMainFrame.myBackground:ClearAllPoints()
		if(growUpwards == true) then
			aGroup.myMainFrame.myBackground:SetPoint("BOTTOMLEFT", aGroup.myMainFrame, "TOPLEFT", 0, -self.myTextHeight - 5)
		else
			aGroup.myMainFrame.myBackground:SetPoint("TOPLEFT", aGroup.myMainFrame, "TOPLEFT", 0, 0)
		end
	end

	-- We dont want to overlap with the group-label
	local newY = -self.myTextHeight
	newY = newY	+ self.myTextHeight
	for i = 1, numFrames do
		local frame = aGroup.myFrames[i]

		frame:ClearAllPoints()

		newY = newY - frameMovement

		frame:SetPoint("TOPLEFT", aGroup.myMainFrame, "TOPLEFT", 0, newY)
	end
end

function KRC_Display:FindFrameInGroup(aGroup, aSpellID, aCasterName)
	local numFrames = table.getn(aGroup.myFrames)
	for i = 1, numFrames do
		local frame = aGroup.myFrames[i]

		if (frame.mySpellID == aSpellID and frame.myCaster == aCasterName) then
			return frame, i
		end
	end

	return nil, -1
end



--
-- Updates
--

function KRC_Display:IsUnitValid(aCasterName, someCasterData)
	if(someCasterData.myUnitID == nil) then
		self:DebugPrint("UnitID for " .. aCasterName .. " is invalid.")
		return false
	end

	if (UnitIsVisible(someCasterData.myUnitID) == nil) then
		self:DebugPrint(aCasterName .. " .. (" .. someCasterData.myUnitID .. ") is not visible.")
		return false
	end

	if (UnitExists(someCasterData.myUnitID) == nil) then
		self:DebugPrint(aCasterName .. " .. (" .. someCasterData.myUnitID .. ") doesnt exist.")
		return false
	end

	if (KRC_Helpers:UnitIsInOurRaidOrParty(aCasterName) == false) then
		self:DebugPrint(aCasterName .. " is not in our group or raid.")
		return false
	end

	return true
end

function KRC_Display:CanUnitCastSpell(aCasterName, aSpellID, someCasterData)
	local casterSpecc = self:GetPlayerSpecc(aCasterName)
	local spellRequirements = KRC_Spells:GetSpellTalentRequirements(someCasterData.myClass, aSpellID)
	if(spellRequirements ~= nil) then
		if(casterSpecc == nil) then
			self:DebugPrint(aCasterName .. " has no specc set, dont know if he/she can cast " .. GetSpellInfo(aSpellID) .. ", disabeling it.")
			return false
		end

		if(spellRequirements[casterSpecc] == nil) then
			self:DebugPrint(aCasterName .. " cant cast spell " .. GetSpellInfo(aSpellID) .. ", its not available to specc " .. casterSpecc)
			return false
		end
	end

	return true
end

function KRC_Display:ShouldGroupShowSpell(aCasterName, aCasterClass, aSpellID, aGroup)
	if (aGroup.mySpells[aSpellID].myEnabled == false) then
		self:DebugPrint("Spell " .. GetSpellInfo(aSpellID) .. " is not enabled in group " .. aGroup.myTitle .. ", hiding it.")
		return false
	end

	local casterSpecc = self:GetPlayerSpecc(aCasterName)
	if(casterSpecc == nil) then
		self:DebugPrint(aCasterName .. " has no specc set, wont show him/her in group " .. aGroup.myTitle)
		return false;
	end

	if (self:IsSpeccActiveForGroup(aGroup.myTitle, aCasterClass, casterSpecc) == false) then
		self:DebugPrint("Specc " .. casterSpecc .. " is not enabled in group " .. aGroup.myTitle .. ", hiding it.")
		return false
	end

	return true
end

function KRC_Display:UpdateFrameProgress(aFrame, someCasterData, aShouldAlwaysShow)
	local remainingTime = someCasterData.myRemainingCD

	aFrame.myRemainingCD = remainingTime
	if(remainingTime == nil) then
		aFrame.myRemainingCD = 0
	end

	if (aFrame.myRemainingCD > 0) then
		aFrame.myCooldownLabel.Text:SetTextColor(0.85, 0.1, 0.1)
		aFrame.myCooldownLabel.Text:SetFormattedText(SecondsToTimeDetail(aFrame.myRemainingCD))
	elseif (aShouldAlwaysShow == true) then
		aFrame.myCooldownLabel.Text:SetTextColor(0.1, 0.85, 0.1)
		aFrame.myCooldownLabel.Text:SetText("READY")
	end
end

function KRC_Display:UpdateSpellDataInGroup(aSpellID, someSpellData, aGroup)

	local isEnabled = aGroup.mySpells[aSpellID].myEnabled
	local shouldAlwaysShow = aGroup.mySpells[aSpellID].myAlwaysShow

	for casterName, casterData in pairs(someSpellData) do 
		local frame, frameIndex = self:FindFrameInGroup(aGroup, aSpellID, casterName)

		local casterIsValid = self:IsUnitValid(casterName, casterData)
		local casterCanCastSpell = self:CanUnitCastSpell(casterName, aSpellID, casterData)
		local shouldGroupShowSpell = self:ShouldGroupShowSpell(casterName, casterData.myClass, aSpellID, aGroup)
		-- If we have a frame, but it has been disabled,
		-- or the caster cannot cast the spell anymore, 
		-- then we should remove the frame

		local spellCannotBeShown = casterIsValid == false or casterCanCastSpell == false or shouldGroupShowSpell == false
		if(spellCannotBeShown == true) then
			if(frame ~= nil) then
				self:DebugPrint("Removing " .. GetSpellInfo(aSpellID) .. " from " .. casterName .. ", it cannot be shown anymore")
				self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
			end
		else
			-- If the spell is on cooldown, or we should always show this spell then we require a frame,
			-- which means we have to create one if we didnt have one allready
			local frameRequired = casterData.myRemainingCD ~= nil or shouldAlwaysShow
			if (frame == nil and frameRequired == true) then
				frame, frameIndex = self:CreateFrameAndAddToGroup(aGroup, aSpellID, casterName, casterData.myClass)
			end

			if(frame ~= nil) then
				if(frameRequired == false) then
					self:DebugPrint("Removing " .. GetSpellInfo(aSpellID) .. " from " .. casterName .. ", the frame is not required anymore")
					self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
				else
					self:UpdateFrameProgress(frame, casterData, shouldAlwaysShow)
				end
			end
		end
		
	end
end

function KRC_Display:Update()
	for groupName, group in pairs(self.myGroups) do 
		for spellID, spellData in pairs(KRC_DataCollector.myData) do
			if (group.mySpells[spellID] ~= nil) then
				self:UpdateSpellDataInGroup(spellID, spellData, group)
			end
		end
	end
end



--
-- Utilities
--

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