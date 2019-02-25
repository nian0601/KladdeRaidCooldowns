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
KRC_Display.myPaladinAuras = {}
KRC_Display.myEnableDebugPrinting = false

function KRC_Display:Init()
	self.LibRaidCooldowns = LibStub("LibRaidCooldowns")
	self.LibRaidCooldowns:Register(self)

	self.GroupTalents = LibStub("LibGroupTalents-1.0")

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

function KRC_Display:SetLockedMode(aStatus)
	KRC_Core.db.profile.myIsLocked = aStatus

	for groupName, group in pairs(self.myGroups) do
		self:SetGroupLockedStatus(groupName, aStatus)
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

	if(settings.myIconOnLeft == nil) then
		settings.myIconOnLeft = false
	end

	if(settings.myHideSpellName == nil) then
		settings.myHideSpellName = false
	end

	if(settings.myExtraDetailsLableWidth == nil) then
		settings.myExtraDetailsLableWidth = 20
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

--
-- Config Functions
--

function KRC_Display:SetGroupLockedStatus(aGroupName, aStatus)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	realGroup.myMainFrame:SetMovable(aStatus)
	realGroup.myMainFrame:EnableMouse(aStatus)
end

function KRC_Display:SetSpeccStatusForGroup(aGroupName, aClass, aSpecc, aStatus)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	local classSpells = KRC_Spells.mySpells[aClass]
	for spellID, spellInfo in pairs(classSpells) do
		self:SetSpeccStatusForSpellInGroup(aGroupName, spellID, aSpecc, aStatus)
	end
end

function KRC_Display:SetSpeccStatusForSpellInGroup(aGroupName, aSpellID, aSpecc, aStatus)
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

	self.LibRaidCooldowns:Unregister(self)
	self.LibRaidCooldowns:Register(self)
end

function KRC_Display:IsSpeccActiveForSpellInGroup(aGroupName, aSpellID, aSpecc)
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

function KRC_Display:CreateCasterLable(aFrame, aColor, aCasterName)
	if(aFrame.myCasterLable == nil) then
		aFrame.myCasterLable = self:CreateText(aFrame:GetName() .. "_CasterLable", aFrame)
	end

	aFrame.myCasterLable.Text:ClearAllPoints()
	aFrame.myCasterLable.Text:SetHeight(self.myTextHeight)
	aFrame.myCasterLable.Text:SetTextColor(aColor.r, aColor.g, aColor.b)
	aFrame.myCasterLable.Text:SetText(aCasterName)
end

function KRC_Display:CreateSpellIcon(aFrame, aSpellID)
	if(aFrame.icon == nil) then
		aFrame.icon = aFrame:CreateTexture(nil, "LOW")
	end

	local _, _, spellIcon = GetSpellInfo(aSpellID)
	aFrame.icon:SetWidth(self.myTextHeight)
	aFrame.icon:SetHeight(self.myTextHeight)
	aFrame.icon:SetTexture(spellIcon)
end

function KRC_Display:CreateSpellLable(aFrame, aColor, aCasterClass, aSpellID)
	if(aFrame.mySpellLabel == nil) then
		aFrame.mySpellLabel = self:CreateText(aFrame:GetName() .. "_CasterLable", aFrame)
	end
	aFrame.mySpellLabel.Text:ClearAllPoints()
	aFrame.mySpellLabel.Text:SetHeight(self.myTextHeight)
	aFrame.mySpellLabel.Text:SetTextColor(aColor.r, aColor.g, aColor.b)
	aFrame.mySpellLabel.Text:SetText(KRC_Spells:GetShortName(aCasterClass, aSpellID))
end

function KRC_Display:CreateExtraDetailsLable(aFrame, aColor)
	if(aFrame.myExtraDetailsLable == nil) then
		aFrame.myExtraDetailsLable = self:CreateText(aFrame:GetName() .. "_ExtraDetailsLable", aFrame)
	end
	aFrame.myExtraDetailsLable.Text:ClearAllPoints()
	aFrame.myExtraDetailsLable.Text:SetHeight(self.myTextHeight)
	aFrame.myExtraDetailsLable.Text:SetTextColor(aColor.r, aColor.g, aColor.b)
	aFrame.myExtraDetailsLable.Text:SetText("")
end

function KRC_Display:CreateCooldownLable(aFrame)
	if(aFrame.myCooldownLabel == nil) then
		aFrame.myCooldownLabel = self:CreateText(aFrame:GetName() .. "_CasterLable", aFrame)
	end

	aFrame.myCooldownLabel.Text:ClearAllPoints()
	aFrame.myCooldownLabel.Text:SetHeight(self.myTextHeight)
	aFrame.myCooldownLabel.Text:SetTextColor(0.85, 0.1, 0.1)
	aFrame.myCooldownLabel.Text:SetText(0)
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

	self:CreateCasterLable(frame, color, aCasterName)
	self:CreateSpellIcon(frame, aSpellID)
	self:CreateSpellLable(frame, color, aCasterClass, aSpellID)
	self:CreateExtraDetailsLable(frame, color)
	self:CreateCooldownLable(frame)
	

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

function KRC_Display:PlaceIconAndCasterNameInFrame(aFrame, someSettings)
	aFrame.myCasterLable.Text:SetWidth(someSettings.myCasterLableWidth)

	local endPosition = 0
	if someSettings.myIconOnLeft == true then
		aFrame.icon:SetPoint("TOPLEFT", aFrame, "TOPLEFT", 0, 0)

		local casterPosition = aFrame.icon:GetWidth() + 2
		aFrame.myCasterLable.Text:SetPoint("TOPLEFT", aFrame, "TOPLEFT", casterPosition, 0)

		endPosition = casterPosition + aFrame.myCasterLable.Text:GetWidth() + 5
	else
		aFrame.myCasterLable.Text:SetPoint("TOPLEFT", aFrame, "TOPLEFT", 0, 0)

		local iconPosition = aFrame.myCasterLable.Text:GetWidth() + 5
		aFrame.icon:SetPoint("TOPLEFT", aFrame, "TOPLEFT", iconPosition, -1)

		endPosition = iconPosition + aFrame.icon:GetWidth() + 5
	end

	return endPosition
end

function KRC_Display:PlaceExtraInfoInFrame(aFrame, someSettings, aStartPosition)
	local endPosition = 0
	if someSettings.myShouldShowExtraInfo == true then
		aFrame.myExtraDetailsLable.Text:Show()
		aFrame.myExtraDetailsLable.Text:SetPoint("TOPLEFT", aFrame, "TOPLEFT", aStartPosition, 0)
		aFrame.myExtraDetailsLable.Text:SetWidth(someSettings.myExtraDetailsLableWidth)

		endPosition = aStartPosition + aFrame.myExtraDetailsLable.Text:GetWidth() + 5
	else
		aFrame.myExtraDetailsLable.Text:Hide()
		endPosition = aStartPosition + 5
	end

	return endPosition
end

function KRC_Display:PlaceSpellNameInFrame(aFrame, someSettings, aStartPosition)
	local endPosition = 0
	if someSettings.myHideSpellName == true then
		aFrame.mySpellLabel.Text:Hide()
		endPosition = aStartPosition + 5
	else
		aFrame.mySpellLabel.Text:Show()
		aFrame.mySpellLabel.Text:SetPoint("TOPLEFT", aFrame, "TOPLEFT", aStartPosition, 0)
		aFrame.mySpellLabel.Text:SetWidth(someSettings.mySpellLableWidth)

		endPosition = aStartPosition + aFrame.mySpellLabel.Text:GetWidth() + 5
	end

	return endPosition
end

function KRC_Display:RepositionFramesInGroup(aGroup)
	table.sort(aGroup.myFrames, CompareFrames)

	local groupSettings = self:GetGroupSettings(aGroup.myTitle)

	local spellSpacing = groupSettings.mySpellSpacing
	local classSpacing = groupSettings.myClassSpacing
	local frameMovement = groupSettings.myGeneralSpacing + self.myTextHeight
	if(groupSettings.myGrowBarsUp == true) then
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

		local extraInfoPosition = self:PlaceIconAndCasterNameInFrame(frame, groupSettings)
		local spellPosition = self:PlaceExtraInfoInFrame(frame, groupSettings, extraInfoPosition)
		local cooldownPosition = self:PlaceSpellNameInFrame(frame, groupSettings, spellPosition)
		
		
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
	if(groupSettings.myGrowBarsUp == true) then
		aGroup.myMainFrame.myBackground:SetPoint("BOTTOMLEFT", aGroup.myMainFrame, "TOPLEFT", 0, -self.myTextHeight)
	else
		aGroup.myMainFrame.myBackground:SetPoint("TOPLEFT", aGroup.myMainFrame, "TOPLEFT", 0, 0)
	end
end

function KRC_Display:RepositionFramesInGroupWithName(aGroupName)
	local realGroup = self.myGroups[aGroupName]
	if (realGroup == nil) then
		return
	end

	self:RepositionFramesInGroup(realGroup)
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
function KRC_Display:TranslateRoleToSpecc(aRole)
	if(aRole == "tank") then
		return "Tank"
	end

	if(aRole == "melee" or aRole == "caster") then
		return "DPS"
	end

	return "Heal"
end

function KRC_Display:ShouldGroupShowSpell(aCasterRole, aSpellID, aGroup)
	if(self:IsGroupHidden(aGroup.myTitle) == true) then
		return false
	end

	if (aGroup.mySpells[aSpellID] == nil or aGroup.mySpells[aSpellID].myEnabled == false or aGroup.mySpells[aSpellID].myEnabled == nil) then
		self:DebugPrint("Spell " .. GetSpellInfo(aSpellID) .. " is not enabled in group " .. aGroup.myTitle .. ", hiding it.")
		return false
	end

	local specc = self:TranslateRoleToSpecc(aCasterRole)
	if (self:IsSpeccActiveForSpellInGroup(aGroup.myTitle, aSpellID, specc) == false) then
		self:DebugPrint("Specc " .. specc .. " for spell " .. GetSpellInfo(aSpellID) .. " is not enabled in group " .. aGroup.myTitle .. ", hiding it.")
		return false
	end

	return true
end

function KRC_Display:AddExtraInformation(aGroupName, aFrame, aCasterClass, aCooldown)
	local groupSettings = self:GetGroupSettings(aGroupName)
	if(groupSettings.myShouldShowExtraInfo == false) then
		return
	end

	local spellShortName = KRC_Spells:GetShortName(aCasterClass, aCooldown.spellId)

	if(KRC_Spells:IsAuraMastery(aCooldown.spellId) == true) then
		local auraShortName = self:GetPaladinAuraShortName(aCooldown.name)
		aFrame.myExtraDetailsLable.Text:SetText("(" .. auraShortName .. ")")
		return
	end

	if(aCooldown.targetName ~= nil and aFrame.myRemainingCD ~= nil) then
		aFrame.myExtraDetailsLable.Text:SetText("(" .. aCooldown.targetName .. ")")
	end
end

function KRC_Display:Update()
	self:UpdatePaladinAuras()

	for groupName, group in pairs(self.myGroups) do
		if(self:IsGroupHidden(groupName) == false) then
			for _, frame in pairs(group.myFrames) do
				
				if(frame.myRemainingCD == nil) then
					frame.myRemainingCD = 0
				elseif(frame.myRemainingCD > 0) then
					frame.myRemainingCD = frame.myRemainingCD - 1
				end

				if (frame.myRemainingCD > 0) then
					frame.myCooldownLabel.Text:SetTextColor(0.85, 0.1, 0.1)
					frame.myCooldownLabel.Text:SetFormattedText(SecondsToTimeDetail(frame.myRemainingCD))
				else
					frame.myCooldownLabel.Text:SetTextColor(0.1, 0.85, 0.1)
					frame.myCooldownLabel.Text:SetText("READY")
				end
			end
		end
	end
end

function KRC_Display:CooldownStarted(aGroup, aCooldown)
	local _, casterClass = GetPlayerInfoByGUID(aCooldown.casterGUID)
	if(casterClass == nil) then
		return
	end

	local casterRole = self.GroupTalents:GetGUIDRole(aCooldown.casterGUID)
	local frame, frameIndex = self:FindFrameInGroup(aGroup, aCooldown.spellId, aCooldown.casterName)

	if(self:ShouldGroupShowSpell(casterRole, aCooldown.spellId, aGroup) == false) then
		self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		return
	end

	if(frame == nil) then
		frame, frameIndex = self:CreateFrameAndAddToGroup(aGroup, aCooldown.spellId, aCooldown.casterName, casterClass)
	end

	frame.myRemainingCD = aCooldown.duration
	frame.myCooldownLabel.Text:SetTextColor(0.85, 0.1, 0.1)
	frame.myCooldownLabel.Text:SetFormattedText(SecondsToTimeDetail(frame.myRemainingCD))

	self:AddExtraInformation(aGroup.myTitle, frame, casterClass, aCooldown)
end

function KRC_Display:CooldownReady(aGroup, aCooldown)
	local _, casterClass = GetPlayerInfoByGUID(aCooldown.casterGUID)
	if(casterClass == nil) then
		return
	end

	local casterRole = self.GroupTalents:GetGUIDRole(aCooldown.casterGUID)
	local frame, frameIndex = self:FindFrameInGroup(aGroup, aCooldown.spellId, aCooldown.casterName)

	if(self:ShouldGroupShowSpell(casterRole, aCooldown.spellId, aGroup) == false) then
		self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		return
	end

	if(frame ~= nil) then
		frame.myRemainingCD = 0

		if(aGroup.mySpells[aCooldown.spellId].myAlwaysShow == false) then
			self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		end
	end
end

function KRC_Display:CooldownChanged(aGroup, aCooldown)
	local _, casterClass = GetPlayerInfoByGUID(aCooldown.casterGUID)
	if(casterClass == nil) then
		return
	end

	local casterRole = self.GroupTalents:GetGUIDRole(aCooldown.casterGUID)
	local frame, frameIndex = self:FindFrameInGroup(aGroup, aCooldown.spellId, aCooldown.casterName)

	if(self:ShouldGroupShowSpell(casterRole, aCooldown.spellId, aGroup) == false) then
		self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		return
	end

	if(frame ~= nil) then
		frame.myRemainingCD = aCooldown.expirationTime - aCooldown.creation
		frame.myCooldownLabel.Text:SetTextColor(0.85, 0.1, 0.1)
		frame.myCooldownLabel.Text:SetFormattedText(SecondsToTimeDetail(frame.myRemainingCD))

		if(frame.myRemainingCD == 0 and aGroup.mySpells[aCooldown.spellId].myAlwaysShow == false) then
			self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		end
	end
end

function KRC_Display:CooldownAvailable(aGroup, aCooldown)
	local _, casterClass = GetPlayerInfoByGUID(aCooldown.casterGUID)
	if(casterClass == nil) then
		return
	end

	local casterRole = self.GroupTalents:GetGUIDRole(aCooldown.casterGUID)
	local frame, frameIndex = self:FindFrameInGroup(aGroup, aCooldown.spellId, aCooldown.casterName)

	if(self:ShouldGroupShowSpell(casterRole, aCooldown.spellId, aGroup) == false) then
		self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
		return
	end

	if(frame == nil and aGroup.mySpells[aCooldown.spellId].myAlwaysShow == true) then
		frame, frameIndex = self:CreateFrameAndAddToGroup(aGroup, aCooldown.spellId, aCooldown.casterName, casterClass)
	end

	if(frame ~= nil) then
		frame.myRemainingCD = 0
		frame.myCooldownLabel.Text:SetTextColor(0.1, 0.85, 0.1)
		frame.myCooldownLabel.Text:SetText("READY")
	end
end

function KRC_Display:CooldownUnavailable(aGroup, aCooldown)
	local frame, frameIndex = self:FindFrameInGroup(aGroup, aCooldown.spellId, aCooldown.casterName)
	self:RemoveFrameFromGroup(frame, frameIndex, aGroup)
end

function KRC_Display:RAID_COOLDOWN_STARTED(cooldown)          --when the cooldown of the spell cooldown.name starts
	self:DebugPrint("Cooldown for " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " started!")

	for groupName, group in pairs(self.myGroups) do
		self:CooldownStarted(group, cooldown)
	end
end

function KRC_Display:RAID_COOLDOWN_CHANGED(cooldown)        --when the cooldown of the spell cooldown.name changes
	self:DebugPrint("Cooldown for " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " changed!")

	for groupName, group in pairs(self.myGroups) do
		self:CooldownChanged(group, cooldown)
	end
end

function KRC_Display:RAID_COOLDOWN_READY(cooldown)          --when the cooldown of the spell cooldown.name ends
	self:DebugPrint("Cooldown for " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " ended!")

	for groupName, group in pairs(self.myGroups) do
		self:CooldownReady(group, cooldown)
	end
end

function KRC_Display:RAID_COOLDOWN_AVAILABLE(cooldown)      --when a cooldown becomes available (a druid joins the party, innervate becomes available)
	self:DebugPrint("Spell " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " is available!")

	for groupName, group in pairs(self.myGroups) do
		self:CooldownAvailable(group, cooldown)
	end
end

function KRC_Display:RAID_COOLDOWN_UNAVAILABLE(cooldown)    --when a cooldown becomes unavailable (a druid leaves the party, innervate becomes unavailable)
	self:DebugPrint("Spell " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " is unavailable!")

	for groupName, group in pairs(self.myGroups) do
		self:CooldownUnavailable(group, cooldown)
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

function KRC_Display:GetPaladinAura(aPaladinName)
	local cachedAuras = KRC_Spells.myPaladinAuras

	for i = 1, 7 do
		local auraData = self.myPaladinAuras[cachedAuras[i].Name]
		if(auraData ~= nil) then
			if auraData == aPaladinName then
				return cachedAuras[i].Name
			end
		end
	end
	return nil
end

function KRC_Display:GetPaladinAuraShortName(aPaladinName)
	local longName = self:GetPaladinAura(aPaladinName)

	if(longName == nil) then
		return "N"
	end
	
	local cachedAuras = KRC_Spells.myPaladinAuras
	for i = 1, 7 do
		if(cachedAuras[i]["Name"] == longName) then
			return cachedAuras[i]["ShortName"]
		end
	end

	self:Print("Failed to find a shortname for " .. longName)
	return "N"
end

function KRC_Display:UpdatePaladinAuras()
	local cachedAuras = KRC_Spells.myPaladinAuras
	for i = 1, 7 do
		local auraName = cachedAuras[i]["Name"]
		local name,_,_,_,_,_,_, source = UnitBuff("player", auraName)
		if (name ~= nil) then
			local sourceName = UnitName(source)
			self.myPaladinAuras[auraName] = sourceName
		else
			self.myPaladinAuras[auraName] = nil
		end
	end
end