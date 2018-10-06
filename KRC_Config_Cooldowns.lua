local ourSelectedGroup = nil
local ourTopMostContainer = nil

local function DrawGeneralGroupSettings(aContainer, anEvent, aClass)
	aContainer:ReleaseChildren()

	local growUpwards = KRC_Config.myGUI:Create("CheckBox")
	growUpwards:SetValue(KRC_Display:IsGroupGrowUp(ourSelectedGroup))
	growUpwards:SetLabel("Grow Bars Up")
	growUpwards:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Display:SetGroupGrowUp(ourSelectedGroup, value)
	end)

	local unlockBox = KRC_Config.myGUI:Create("CheckBox")
	unlockBox:SetValue(KRC_Display:IsInLockedMode())
	unlockBox:SetLabel("Unlock")
	unlockBox:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Display:SetLockedMode(value)
	end)

	local newGroupGroup = KRC_Config.myGUI:Create("SimpleGroup")
	newGroupGroup:SetFullWidth(true)

	local newGroupEditBox = KRC_Config.myGUI:Create("EditBox")
	newGroupEditBox:SetWidth(250)
	newGroupEditBox:SetLabel("New Group")
	newGroupEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
		KRC_Display:CreateEmptyGroup(value)

		widget:SetText("")
		ourTopMostContainer:DoLayout()

	end)
	newGroupGroup:AddChild(newGroupEditBox)

	local deleteGroup = KRC_Config.myGUI:Create("SimpleGroup")
	deleteGroup:SetFullWidth(true)


	local deleteEditBox = KRC_Config.myGUI:Create("EditBox")
	deleteEditBox:SetWidth(250)
	deleteEditBox:SetLabel("Type DELETE and hit enter to delete this group")
	deleteEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
		if(value == "DELETE") then
			KRC_Display:DeleteGroup(ourSelectedGroup)
		end

		widget:SetText("")
		ourTopMostContainer:DoLayout()

	end)
	deleteGroup:AddChild(deleteEditBox)

	aContainer:AddChild(growUpwards)
	aContainer:AddChild(unlockBox)
	aContainer:AddChild(newGroupGroup)
	aContainer:AddChild(deleteGroup)
	
end

local function CreateSpeccGroup(aScrollFrame, aClass, someSpeccBoxes)
	local speccs = KRC_Spells.mySpeccs[aClass]
	if(speccs == nil) then
		return nil
	end

	local speccsHeading = KRC_Config.myGUI:Create("Heading")
	speccsHeading:SetText("Set Spec-value for all spells (Toggles all specc-buttons below)")
	speccsHeading:SetFullWidth(true)
	aScrollFrame:AddChild(speccsHeading)


	local createBox = function(aString)
		local box = KRC_Config.myGUI:Create("CheckBox")
		box:SetValue(false)
		box:SetLabel(aString)
		box:SetWidth(60)
		box:SetUserData("specc", aString)
		return box;
	end

	local speccGroup = KRC_Config.myGUI:Create("SimpleGroup")
	speccGroup:SetLayout("Flow")
	speccGroup:SetFullWidth(true)

	for specc, active in pairs(speccs) do
		local box = createBox(specc)
		speccGroup:AddChild(box)
		someSpeccBoxes[specc] = box
	end

	aScrollFrame:AddChild(speccGroup)
end

local function CreateEnableBox(aSpellID)
	local spellName, _, spellIcon = GetSpellInfo(aSpellID)

	local enableBox = KRC_Config.myGUI:Create("CheckBox")
	enableBox:SetLabel(spellName)
	enableBox:SetImage(spellIcon)

	dbGroup = KRC_Core.db.profile.myGroups[ourSelectedGroup]
	if(dbGroup.mySpells[aSpellID] ~= nil) then
		enableBox:SetValue(dbGroup.mySpells[aSpellID].myEnabled)
	end

	enableBox:SetUserData("spellID", aSpellID)
	enableBox:SetUserData("group", ourSelectedGroup)
	enableBox:SetCallback("OnValueChanged", function(widget, event, value)
		local spellID = widget:GetUserData("spellID")
		if not spellID then return end

		local group = widget:GetUserData("group")
		if not group then return end

		local dbGroup = KRC_Core.db.profile.myGroups[group]
		if(dbGroup.mySpells[spellID] == nil) then
			dbGroup.mySpells[spellID] = {}
			dbGroup.mySpells[spellID].myEnabled = false
			dbGroup.mySpells[spellID].myAlwaysShow = false
		end

		local spellInfo = dbGroup.mySpells[spellID]
		spellInfo.myEnabled = value

		local realGroup = KRC_Display.myGroups[group]
		if(realGroup.mySpells[spellID] == nil) then
			realGroup.mySpells[spellID] = {}
			realGroup.mySpells[spellID].myEnabled = false
			realGroup.mySpells[spellID].myAlwaysShow = false
		end
		
		realGroup.mySpells[spellID].myEnabled = value
	end)

	return enableBox
end

local function CreateAlwaysShowBox(aSpellID)
	local alwaysShowBox = KRC_Config.myGUI:Create("CheckBox")
	alwaysShowBox:SetLabel("Always Show")

	dbGroup = KRC_Core.db.profile.myGroups[ourSelectedGroup]
	if(dbGroup.mySpells[aSpellID] ~= nil) then
		alwaysShowBox:SetValue(dbGroup.mySpells[aSpellID].myAlwaysShow)
	end
	alwaysShowBox:SetWidth(120)
	alwaysShowBox:SetUserData("spellID", aSpellID)
	alwaysShowBox:SetUserData("group", ourSelectedGroup)
	alwaysShowBox:SetCallback("OnValueChanged", function(widget, event, value)
		local spellID = widget:GetUserData("spellID")
		if not spellID then return end

		local group = widget:GetUserData("group")
		if not group then return end

		dbGroup = KRC_Core.db.profile.myGroups[group]
		if(dbGroup.mySpells[spellID] == nil) then
			dbGroup.mySpells[spellID] = {}
			dbGroup.mySpells[spellID].myEnabled = false
			dbGroup.mySpells[spellID].myAlwaysShow = false
		end

		local spellInfo = dbGroup.mySpells[spellID]
		spellInfo.myAlwaysShow = value

		local realGroup = KRC_Display.myGroups[group]
		if(realGroup.mySpells[spellID] == nil) then
			realGroup.mySpells[spellID] = {}
			realGroup.mySpells[spellID].myEnabled = false
			realGroup.mySpells[spellID].myAlwaysShow = false
		end

		realGroup.mySpells[spellID].myAlwaysShow = value
	end)
	return alwaysShowBox
end

local function CreateSpellGroup(aScrollFrame, aClass, someSpellSpeccBoxes)
	-- Insert a heading first, to get a separationg between the Specc-boxes and the spells
	local spellsHeading = KRC_Config.myGUI:Create("Heading")
	spellsHeading:SetText("Spells")
	spellsHeading:SetFullWidth(true)
	aScrollFrame:AddChild(spellsHeading)

	-- The function for creating the Specc-filters for each spell
	local createSpeccBox = function(aString, aSpellID)
		local box = KRC_Config.myGUI:Create("CheckBox")
		box:SetValue(KRC_Display:IsSpeccActiveForSpellInGroup(ourSelectedGroup, aClass, aSpellID, aString))
		box:SetLabel(aString)

		box:SetCallback("OnValueChanged", function(widget, event, value)
			KRC_Display:Print("OnValueChanged: " .. GetSpellInfo(aSpellID))
			KRC_Display:SetSpeccStatusForSpellInGroup(ourSelectedGroup, aClass, aSpellID, aString, value)
		end)
		box:SetWidth(60)

		table.insert(someSpellSpeccBoxes[aString], box)
		return box;
	end

	-- Collapse all spells for this class into a more compact array instead of table
	local classSpells = KRC_Spells.mySpells[aClass]
	local temp = {}
	for spellID, spellInfo in pairs(classSpells) do
		temp[#temp + 1] = spellID
	end

	for i, spellID in next, temp do
		local spellGroup = KRC_Config.myGUI:Create("SimpleGroup")
		spellGroup:SetLayout("Flow")
		spellGroup:SetFullWidth(true)

		spellGroup:AddChild(CreateEnableBox(spellID))
		spellGroup:AddChild(CreateAlwaysShowBox(spellID))

		local speccs = KRC_Spells.mySpeccs[aClass]
		for specc, active in pairs(speccs) do
			if(someSpellSpeccBoxes[specc] == nil) then
				someSpellSpeccBoxes[specc] = {}
			end

			spellGroup:AddChild(createSpeccBox(specc, spellID))
		end

		aScrollFrame:AddChild(spellGroup)
	end
end

local function DrawClassSettings(aContainer, anEvent, aClass)
	aContainer:ReleaseChildren()

	if(aClass == "GENERAL") then
		DrawGeneralGroupSettings(aContainer, anEvent, aClass)
	else
		local scrollFrame = KRC_Config.myGUI:Create("ScrollFrame")
		scrollFrame:SetLayout("Flow")
		scrollFrame:SetFullWidth(true)
		scrollFrame:SetFullHeight(true)

		local speccBoxes = {}
		CreateSpeccGroup(scrollFrame, aClass, speccBoxes)

		local spellSpeccBoxes = {}
		CreateSpellGroup(scrollFrame, aClass, spellSpeccBoxes)

		local function classWideSpeccCallback(widget, event, value)
			local specc = widget:GetUserData("specc")
			for i = 1, table.getn(spellSpeccBoxes[specc]) do
				spellSpeccBoxes[specc][i]:SetValue(value)
			end

			KRC_Display:SetSpeccStatusForGroup(ourSelectedGroup, aClass, specc, value)
		end

		for specc, box in pairs(speccBoxes) do
			box:SetCallback("OnValueChanged", classWideSpeccCallback)
		end

		aContainer:AddChild(scrollFrame)
	end
end

local function DrawGroupSettings(aContainer, anEvent, aClass)
	ourSelectedGroup = aClass

	aContainer:ReleaseChildren()

	local tabGroup = KRC_Config.myGUI:Create("TabGroup")
	tabGroup:SetLayout("Flow")
	tabGroup:SetTabs(
	{
		{ text="General", value="GENERAL" },
		{ text="Druid", value="DRUID" },
		{ text="Hunter", value="HUNTER" },
		{ text="Mage", value="MAGE" },
		{ text="Paladin", value="PALADIN" },
		{ text="Priest", value="PRIEST" },
		{ text="Rogue", value="ROGUE" },
		{ text="Shaman", value="SHAMAN" },
		{ text="Warlock", value="WARLOCK" },
		{ text="Warrior", value="WARRIOR" },
		{ text="Death Knight", value="DEATHKNIGHT" }
	})
	tabGroup:SetCallback("OnGroupSelected", DrawClassSettings)
	tabGroup:SelectTab("GENERAL")
	aContainer:AddChild(tabGroup)
end

function KRC_Config_DrawCooldowns(aContainer)
	local groups = {}
	local firstGroup = nil
	for groupName, group in pairs(KRC_Display.myGroups) do 
		groups[groupName] = groupName

		if(firstGroup == nil) then
			firstGroup = groupName
		end
	end
	
	ourTopMostContainer = aContainer



	local dropdown = KRC_Config.myGUI:Create("DropdownGroup")
	dropdown:SetLayout("Fill")
	dropdown:SetTitle("Groups")
	dropdown:SetGroupList(groups)
	dropdown:SetCallback("OnGroupSelected", DrawGroupSettings)
	dropdown:SetGroup(firstGroup)
	dropdown:SetFullWidth(true)

	aContainer:AddChild(dropdown)
end
