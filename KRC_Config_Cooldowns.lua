local ourSelectedGroup = nil
local ourSelectedGroupSettings = nil
local ourGroupsDropdown = nil
local ourGroups = {}

local function PopulateGroupsTable()
	for k in pairs (ourGroups) do
	    ourGroups[k] = nil
	end

	local firstGroup = nil
	for groupName, group in pairs(KRC_Display.myGroups) do
		ourGroups[groupName] = groupName

		if(firstGroup == nil) then
			firstGroup = groupName
		end
	end

	return firstGroup
end

local function ApplySettings()
	KRC_Display:RepositionFramesInGroupWithName(ourSelectedGroup)
end

local function CreateGeneralGroup(aContainer)
	local generalHeading = KRC_Config.myGUI:Create("Heading")
	generalHeading:SetText("General")
	generalHeading:SetFullWidth(true)

	local unlockBox = KRC_Config.myGUI:Create("CheckBox")
	unlockBox:SetValue(KRC_Core.db.profile.myIsLocked)
	unlockBox:SetLabel("Unlock")
	unlockBox:SetWidth(100)
	unlockBox:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Display:SetLockedMode(value)
	end)

	local hideGroupBox = KRC_Config.myGUI:Create("CheckBox")
	hideGroupBox:SetValue(ourSelectedGroupSettings.myIsHidden)
	hideGroupBox:SetLabel("Hide Group")
	hideGroupBox:SetWidth(100)
	hideGroupBox:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Display:SetGroupIsHidden(ourSelectedGroup, value)
	end)

	local extraInfoBox = KRC_Config.myGUI:Create("CheckBox")
	extraInfoBox:SetValue(ourSelectedGroupSettings.myShouldShowExtraInfo)
	extraInfoBox:SetLabel("Show Extra Info (Target etc)")
	extraInfoBox:SetWidth(200)
	extraInfoBox:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myShouldShowExtraInfo = value
		ApplySettings()
	end)

	aContainer:AddChild(generalHeading)
	aContainer:AddChild(unlockBox)
	aContainer:AddChild(hideGroupBox)
	aContainer:AddChild(extraInfoBox)
end

local function CreateBarSettingsGroup(aContainer)
	local heading = KRC_Config.myGUI:Create("Heading")
	heading:SetText("Bar Settings")
	heading:SetFullWidth(true)

	local casterNameSlider = KRC_Config.myGUI:Create("Slider")
	casterNameSlider:SetValue(ourSelectedGroupSettings.myCasterLableWidth)
	casterNameSlider:SetLabel("Name Width")
	casterNameSlider:SetWidth(160)
	casterNameSlider:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myCasterLableWidth = value
		ApplySettings()
	end)

	local spellNameSlider = KRC_Config.myGUI:Create("Slider")
	spellNameSlider:SetValue(ourSelectedGroupSettings.mySpellLableWidth)
	spellNameSlider:SetLabel("Spell Width")
	spellNameSlider:SetWidth(160)
	spellNameSlider:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.mySpellLableWidth = value;
		ApplySettings()
	end)

	local cooldownSlider = KRC_Config.myGUI:Create("Slider")
	cooldownSlider:SetValue(ourSelectedGroupSettings.myCooldownLableWidth)
	cooldownSlider:SetLabel("CD Width")
	cooldownSlider:SetWidth(160)
	cooldownSlider:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myCooldownLableWidth = value
		ApplySettings()
	end)

	local extraWidthSlider = KRC_Config.myGUI:Create("Slider")
	extraWidthSlider:SetValue(ourSelectedGroupSettings.myExtraDetailsLableWidth)
	extraWidthSlider:SetLabel("Extra Info Width")
	extraWidthSlider:SetWidth(160)
	extraWidthSlider:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myExtraDetailsLableWidth = value
		ApplySettings()
	end)

	local iconOnLeftSide = KRC_Config.myGUI:Create("CheckBox")
	iconOnLeftSide:SetValue(ourSelectedGroupSettings.myIconOnLeft)
	iconOnLeftSide:SetLabel("Icon On Left Side")
	iconOnLeftSide:SetWidth(130)
	iconOnLeftSide:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myIconOnLeft = value;
		ApplySettings()
	end)

	local hideSpellName = KRC_Config.myGUI:Create("CheckBox")
	hideSpellName:SetValue(ourSelectedGroupSettings.myHideSpellName)
	hideSpellName:SetLabel("Hide Spell Name")
	hideSpellName:SetWidth(130)
	hideSpellName:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myHideSpellName = value;
		ApplySettings()
	end)

	aContainer:AddChild(heading)
	aContainer:AddChild(casterNameSlider)
	aContainer:AddChild(spellNameSlider)
	aContainer:AddChild(cooldownSlider)
	aContainer:AddChild(extraWidthSlider)
	aContainer:AddChild(iconOnLeftSide)
	aContainer:AddChild(hideSpellName)
end

local function CreateGroupSpacingGroup(aContainer)
	local heading = KRC_Config.myGUI:Create("Heading")
	heading:SetText("Group Spacing")
	heading:SetFullWidth(true)

	local growUpwards = KRC_Config.myGUI:Create("CheckBox")
	growUpwards:SetValue(ourSelectedGroupSettings.myGrowBarsUp)
	growUpwards:SetLabel("Grow Bars Up")
	growUpwards:SetWidth(120)
	growUpwards:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myGrowBarsUp = value
		ApplySettings()
	end)

	local barSpacingSlider = KRC_Config.myGUI:Create("Slider")
	barSpacingSlider:SetValue(ourSelectedGroupSettings.myGeneralSpacing)
	barSpacingSlider:SetLabel("Bar Spacing")
	barSpacingSlider:SetWidth(160)
	barSpacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myGeneralSpacing = value
		ApplySettings()
	end)

	local spellSpacingSlider = KRC_Config.myGUI:Create("Slider")
	spellSpacingSlider:SetValue(ourSelectedGroupSettings.mySpellSpacing)
	spellSpacingSlider:SetLabel("Spell Spacing")
	spellSpacingSlider:SetWidth(160)
	spellSpacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.mySpellSpacing = value
		ApplySettings()
	end)

	local classSpacingSlider = KRC_Config.myGUI:Create("Slider")
	classSpacingSlider:SetValue(ourSelectedGroupSettings.myClassSpacing)
	classSpacingSlider:SetLabel("Class Spacing")
	classSpacingSlider:SetWidth(160)
	classSpacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
		ourSelectedGroupSettings.myClassSpacing = value
		ApplySettings()
	end)

	aContainer:AddChild(heading)
	aContainer:AddChild(growUpwards)
	aContainer:AddChild(barSpacingSlider)
	aContainer:AddChild(spellSpacingSlider)
	aContainer:AddChild(classSpacingSlider)
end

local function CreateAddAndDeleteExitBoxes(aContainer)
	local addDeleteHeading = KRC_Config.myGUI:Create("Heading")
	addDeleteHeading:SetText("Add or Delete Group")
	addDeleteHeading:SetFullWidth(true)

	local newGroupGroup = KRC_Config.myGUI:Create("SimpleGroup")
	newGroupGroup:SetFullWidth(true)

	local newGroupEditBox = KRC_Config.myGUI:Create("EditBox")
	newGroupEditBox:SetWidth(250)
	newGroupEditBox:SetLabel("New Group")
	newGroupEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
		if(KRC_Display:CreateEmptyGroup(value)) then
			widget:SetText("")
			ourGroupsDropdown.dropdown:AddItem(value, value)
			ourGroupsDropdown:SetGroup(value)
		end
	end)
	newGroupGroup:AddChild(newGroupEditBox)

	local deleteGroup = KRC_Config.myGUI:Create("SimpleGroup")
	deleteGroup:SetFullWidth(true)


	local deleteEditBox = KRC_Config.myGUI:Create("EditBox")
	deleteEditBox:SetWidth(250)
	deleteEditBox:SetLabel("Type DELETE and hit enter to delete this group")
	deleteEditBox:SetCallback("OnEnterPressed", function(widget, event, value)
		if(value == "DELETE") then
			if(KRC_Display:DeleteGroup(ourSelectedGroup) == true) then
				local firstGroup = PopulateGroupsTable()
				ourGroupsDropdown:SetGroupList(ourGroups)
				ourGroupsDropdown:SetGroup(firstGroup)
			end

			widget:SetText("")
		end
	end)
	deleteGroup:AddChild(deleteEditBox)

	aContainer:AddChild(addDeleteHeading)
	aContainer:AddChild(newGroupGroup)
	aContainer:AddChild(deleteGroup)
end

local function DrawGeneralGroupSettings(aContainer, anEvent, aClass)
	aContainer:ReleaseChildren()

	local scrollFrame = KRC_Config.myGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)

	CreateGeneralGroup(scrollFrame)
	CreateBarSettingsGroup(scrollFrame)
	CreateGroupSpacingGroup(scrollFrame)
	CreateAddAndDeleteExitBoxes(scrollFrame)

	aContainer:AddChild(scrollFrame)
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
		box:SetValue(KRC_Display:IsSpeccActiveForSpellInGroup(ourSelectedGroup, aSpellID, aString))
		box:SetLabel(aString)

		box:SetCallback("OnValueChanged", function(widget, event, value)
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
	ourSelectedGroupSettings = KRC_Display:GetGroupSettings(ourSelectedGroup)

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

	local firstGroup = PopulateGroupsTable()
	local dropdown = KRC_Config.myGUI:Create("DropdownGroup")
	dropdown:SetLayout("Fill")
	dropdown:SetTitle("Groups")
	dropdown:SetGroupList(ourGroups)
	dropdown:SetCallback("OnGroupSelected", DrawGroupSettings)
	dropdown:SetGroup(firstGroup)
	dropdown:SetFullWidth(true)

	ourGroupsDropdown = dropdown

	aContainer:AddChild(dropdown)
end