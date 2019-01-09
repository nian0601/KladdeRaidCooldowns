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
		self:SetGroupLockedStatus(groupName, aStatus)
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

	if(settings.myGrowBarsUp == nil) then
		settings.myGrowBarsUp = false
	end

	if(settings.myGeneralSpacing == nil) then
		settings.myGeneralSpacing = 2
	end

	if(settings.mySpellSpacing == nil) then
		settings.mySpellSpacing = 0
	end

	if(settings.myClassSpacing == nil) then
		settings.myClassSpacing = 0
	end

	if(settings.myIsLocked == nil) then
		settings.myIsLocked = true
	end

	if(settings.myIsHidden == nil) then
		settings.myIsHidden = false
	end

	if(settings.myShouldShowExtraInfo == nil) then
		settings.myShouldShowExtraInfo = false
	end

	if(settings.myCasterLableWidth == nil) then
		settings.myCasterLableWidth = 50
		settings.mySpellLableWidth = 45
		settings.myCooldownLableWidth = 40
	end
end

function KRC_Display:CreateEmptyGroup(aGroupName)
	if(aGroupName == nil or aGroupName == "") then
		return false
	end

	if(self.myGroups[aGroupName] ~= nil) then
		-- We allready have a group with this name.. output error?
		return false
	end

	self:InitializeGroupDBVariables(aGroupName)

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
		KRC_Core.db.profile.myGroups[aGroupName].myBottomLeftX = aWidget:GetLeft()
		KRC_Core.db.profile.myGroups[aGroupName].myBottomLeftY = aWidget:GetTop()
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
	return true
end

function KRC_Display:DeleteGroup(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if(realGroup == nil) then
		return false
	end

	if (realGroup ~= nil) then
		while(table.getn(realGroup.myFrames) > 0) do
			self:RemoveFrameFromGroup(realGroup.myFrames[1], 1, realGroup)
		end
	end

	self.myGroups[aGroupName].myMainFrame:Hide()
	self.myGroups[aGroupName].myMainFrame = nil
	self.myGroups[aGroupName] = nil
	KRC_Core.db.profile.myGroups[aGroupName] = nil

	return true
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

			aGroup.mySpells[spellID].mySpeccs = {}
		end
	end

	if(someSettings.myIsHidden ~= nil) then
		self:SetGroupIsHidden(aGroup.myTitle, someSettings.myIsHidden)
	end

	self:SetGroupLockedStatus(aGroup.myTitle, KRC_Core.db.profile.myIsLocked)

	self:RepositionFramesInGroup(aGroup)
end

function KRC_Display:SetGroupLockedStatus(aGroupName, aStatus)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	realGroup.myMainFrame:SetMovable(aStatus)
	realGroup.myMainFrame:EnableMouse(aStatus)
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

function KRC_Display:SetSpeccStatusForGroup(aGroupName, aClass, aSpecc, aStatus)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local classSpells = KRC_Spells.mySpells[aClass]
	for spellID, spellInfo in pairs(classSpells) do
		self:SetSpeccStatusForSpellInGroup(aGroupName, aClass, spellID, aSpecc, aStatus)
	end
end

function KRC_Display:SetSpeccStatusForSpellInGroup(aGroupName, aClass, aSpellID, aSpecc, aStatus)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)

	if(groupSettings.mySpells[aSpellID] == nil) then
		groupSettings.mySpells[aSpellID] = {}
	end

	if(groupSettings.mySpells[aSpellID].mySpeccs == nil) then
		groupSettings.mySpells[aSpellID].mySpeccs = {}
	end

	groupSettings.mySpells[aSpellID].mySpeccs[aSpecc] = aStatus
end

function KRC_Display:IsSpeccActiveForSpellInGroup(aGroupName, aClass, aSpellID, aSpecc)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return false
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	local spell = groupSettings.mySpells[aSpellID]
	if(spell == nil) then
		return false
	end

	local speccs = spell.mySpeccs
	if(speccs == nil) then
		return false
	end

	return speccs[aSpecc] == true
end

function KRC_Display:GetGroupGeneralSpacing(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return 0
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.myGeneralSpacing
end

function KRC_Display:SetGroupGeneralSpacing(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.myGeneralSpacing = aValue
	self:RepositionFramesInGroup(realGroup)
end

function KRC_Display:GetGroupSpellSpacing(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return 0
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.mySpellSpacing
end

function KRC_Display:SetGroupSpellSpacing(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.mySpellSpacing = aValue
	self:RepositionFramesInGroup(realGroup)
end

function KRC_Display:GetGroupClassSpacing(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return 0
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.myClassSpacing
end

function KRC_Display:SetGroupClassSpacing(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.myClassSpacing = aValue
	self:RepositionFramesInGroup(realGroup)
end

function KRC_Display:IsGroupHidden(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return false
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.myIsHidden
end

function KRC_Display:SetGroupIsHidden(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.myIsHidden = aValue
	if(aValue == true) then
		realGroup.myMainFrame:Hide()
	else
		realGroup.myMainFrame:Show()
	end
end

function KRC_Display:IsGroupShowingExtraInfo(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return false
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.myShouldShowExtraInfo
end

function KRC_Display:SetGroupShowsExtraInfo(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.myShouldShowExtraInfo = aValue
end

function KRC_Display:GetGroupCasterWidth(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return 0
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.myCasterLableWidth
end

function KRC_Display:SetGroupCasterWidth(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.myCasterLableWidth = aValue
	self:RepositionFramesInGroup(realGroup)
end

function KRC_Display:GetGroupSpellWidth(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return 0
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.mySpellLableWidth
end

function KRC_Display:SetGroupSpellWidth(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.mySpellLableWidth = aValue
	self:RepositionFramesInGroup(realGroup)
end

function KRC_Display:GetGroupCooldownWidth(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return 0
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	return groupSettings.myCooldownLableWidth
end

function KRC_Display:SetGroupCooldownWidth(aGroupName, aValue)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	groupSettings.myCooldownLableWidth = aValue
	self:RepositionFramesInGroup(realGroup)
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
	if(aFrameIndex == -1) then
		return
	end

	aFrame:Hide()
	table.insert(self.myFreeFrames, aFrame)
	table.remove(aGroup.myFrames, aFrameIndex)

	self:RepositionFramesInGroup(aGroup)
end

function KRC_Display:RepositionFramesInGroup(aGroup)
	table.sort(aGroup.myFrames, CompareFrames)

	local groupSettings = self:GetGroupSettings(aGroup.myTitle)

	local generalSpacing = 2
	local spellSpacing = 2
	local classSpacing = 2
	local growUpwards = false
	if(groupSettings ~= nil) then
		generalSpacing = groupSettings.myGeneralSpacing
		spellSpacing = groupSettings.mySpellSpacing
		classSpacing = groupSettings.myClassSpacing
		growUpwards = groupSettings.myGrowBarsUp
	end

	local frameMovement = generalSpacing + self.myTextHeight
	if(growUpwards == true) then
		frameMovement = -frameMovement
		spellSpacing = -spellSpacing
		classSpacing = -classSpacing
	end

	local newY = 0
	local prevSpell = nil
	local prevClass = nil
	local numFrames = table.getn(aGroup.myFrames)

	for i = 1, numFrames do
		local frame = aGroup.myFrames[i]

		frame:ClearAllPoints()

		newY = newY - frameMovement

		if(prevSpell ~= nil and prevSpell ~= frame.mySpellID) then
			newY = newY - spellSpacing
		end

		if(prevClass ~= nil and prevClass ~= frame.myCasterClass) then
			newY = newY - classSpacing
		end

		prevSpell = frame.mySpellID
		prevClass = frame.myCasterClass

		frame:SetPoint("TOPLEFT", aGroup.myMainFrame, "TOPLEFT", 0, newY)
	end

	local width = 150
	local height = math.abs(newY) + self.myTextHeight

	for i = 1, table.getn(aGroup.myFrames) do
		local frame = aGroup.myFrames[i]

		frame.myCasterLable.Text:SetWidth(groupSettings.myCasterLableWidth)

		local iconPosition = frame.myCasterLable.Text:GetWidth() + 5
		frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", iconPosition, -1)

		local spellPosition = iconPosition + frame.icon:GetWidth() + 5
		frame.mySpellLabel.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", spellPosition, 0)
		frame.mySpellLabel.Text:SetWidth(groupSettings.mySpellLableWidth)

		local cooldownPosition = spellPosition + frame.mySpellLabel.Text:GetWidth() + 5
		frame.myCooldownLabel.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", cooldownPosition, 0)
		frame.myCooldownLabel.Text:SetWidth(groupSettings.myCooldownLableWidth)

		width = cooldownPosition + groupSettings.myCooldownLableWidth
		frame:SetWidth(width)
	end



	aGroup.myMainFrame:SetWidth(width)
	aGroup.myMainFrame:SetHeight(height)

	if (groupSettings.myBottomLeftX ~= nil) then
		aGroup.myMainFrame:ClearAllPoints()
		aGroup.myMainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", groupSettings.myBottomLeftX, groupSettings.myBottomLeftY)
	end

	aGroup.myMainFrame.myBackground:SetWidth(width)
	aGroup.myMainFrame.myBackground:SetHeight(height)

	aGroup.myMainFrame.myBackground:ClearAllPoints()
	if(growUpwards == true) then
		aGroup.myMainFrame.myBackground:SetPoint("BOTTOMLEFT", aGroup.myMainFrame, "TOPLEFT", 0, -self.myTextHeight)
	else
		aGroup.myMainFrame.myBackground:SetPoint("TOPLEFT", aGroup.myMainFrame, "TOPLEFT", 0, 0)
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
	if (aGroup.mySpells[aSpellID].myEnabled == false or aGroup.mySpells[aSpellID].myEnabled == nil) then
		self:DebugPrint("Spell " .. GetSpellInfo(aSpellID) .. " is not enabled in group " .. aGroup.myTitle .. ", hiding it.")
		return false
	end

	local casterSpecc = self:GetPlayerSpecc(aCasterName)
	if(casterSpecc == nil) then
		self:DebugPrint(aCasterName .. " has no specc set, wont show him/her in group " .. aGroup.myTitle)
		return false;
	end

	if (self:IsSpeccActiveForSpellInGroup(aGroup.myTitle, aCasterClass, aSpellID, casterSpecc) == false) then
		self:DebugPrint("Specc " .. casterSpecc .. " for spell " .. GetSpellInfo(aSpellID) .. " is not enabled in group " .. aGroup.myTitle .. ", hiding it.")
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

function KRC_Display:AddExtraInformation(aGroupName, aFrame, aSpellID, aCasterName, someCasterData)
	if(someCasterData.myHasNewData == false or someCasterData.myHasNewData == nil) then
		return
	end

	local groupSettings = self:GetGroupSettings(aGroupName)
	if(groupSettings.myShouldShowExtraInfo == false) then
		return
	end

	local spellShortName = KRC_Spells:GetShortName(someCasterData.myClass, aSpellID)


	if(KRC_Spells:IsAuraMastery(aSpellID) == true) then
		if(someCasterData.myRemainingCD == nil) then
			aFrame.mySpellLabel.Text:SetText(spellShortName)
		else
			local paladinAura = KRC_DataCollector:GetPaladinAura(aCasterName)
			local auraShortName = KRC_Spells:GetPaladinAuraShortName(paladinAura)
			aFrame.mySpellLabel.Text:SetText(spellShortName .. " (" .. auraShortName .. ")")
		end

		return
	end

	if(someCasterData.myTarget ~= nil) then
		if(someCasterData.myRemainingCD == nil) then
			aFrame.mySpellLabel.Text:SetText(spellShortName)
		else
			aFrame.mySpellLabel.Text:SetText(spellShortName .. " (" .. someCasterData.myTarget .. ")")
		end
	end
end

function KRC_Display:UpdateSpellForCasterInGroup(aSpellID, aCasterName, someCasterData, aGroup)
	if(aGroup.mySpells[aSpellID] == nil) then
		return
	end

	local frame, frameIndex = self:FindFrameInGroup(aGroup, aSpellID, aCasterName)
	if(self:IsUnitValid(aCasterName, someCasterData) == false) then
		self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		return
	end

	if(self:CanUnitCastSpell(aCasterName, aSpellID, someCasterData) == false) then
		self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		return
	end

	if(self:ShouldGroupShowSpell(aCasterName, someCasterData.myClass, aSpellID, aGroup) == false) then
		self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		return
	end

	-- If the spell is on cooldown, or we should always show this spell then we require a frame,
	-- which means we have to create one if we didnt have one allready
	local shouldAlwaysShow = aGroup.mySpells[aSpellID].myAlwaysShow
	local isOnCooldown = someCasterData.myRemainingCD ~= nil

	local frameRequired = isOnCooldown or shouldAlwaysShow
	if (frame == nil and frameRequired == true) then
		frame, frameIndex = self:CreateFrameAndAddToGroup(aGroup, aSpellID, aCasterName, someCasterData.myClass)
	end

	if(frame ~= nil) then
		if(frameRequired == false) then
			self:DebugPrint("Removing " .. GetSpellInfo(aSpellID) .. " from " .. aCasterName .. ", the frame is not required anymore")
			self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		else
			self:UpdateFrameProgress(frame, someCasterData, shouldAlwaysShow)
			self:AddExtraInformation(aGroup.myTitle, frame, aSpellID, aCasterName, someCasterData)
		end
	end
end

function KRC_Display:Update()
	for spellID, spellData in pairs(KRC_DataCollector.myData) do
		for casterName, casterData in pairs(spellData) do
			for groupName, group in pairs(self.myGroups) do
				if(self:IsGroupHidden(groupName) == false) then
					self:UpdateSpellForCasterInGroup(spellID, casterName, casterData, group)
				end
			end

			if(casterData.myHasNewData == true) then
				casterData.myHasNewData = false
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
