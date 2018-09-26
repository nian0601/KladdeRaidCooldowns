local ourSelectedGroup = nil
local ourTopMostContainer = nil

local function DrawGeneralGroupSettings(aContainer, anEvent, aClass)
	aContainer:ReleaseChildren()

	local unlockBox = KRC_Config.myGUI:Create("CheckBox")
	unlockBox:SetValue(KRC_Display:IsGroupLocked(ourSelectedGroup))
	unlockBox:SetLabel("Unlock")
	unlockBox:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Display:ToggleGroupLock(ourSelectedGroup, value)
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

	aContainer:AddChild(unlockBox)
	aContainer:AddChild(newGroupGroup)
	aContainer:AddChild(deleteGroup)
	
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

local function DrawClassSettings(aContainer, anEvent, aClass)
	aContainer:ReleaseChildren()

	if(aClass == "GENERAL") then
		DrawGeneralGroupSettings(aContainer, anEvent, aClass)
	else
		local classSpells = KRC_Spells.mySpells[aClass]
		local temp = {}
		for spellID, spellInfo in pairs(classSpells) do
			temp[#temp + 1] = spellID
		end

		local scrollFrame = KRC_Config.myGUI:Create("ScrollFrame")
		scrollFrame:SetLayout("Flow")
		scrollFrame:SetFullWidth(true)

		for i, spellID in next, temp do

			local spellGroup = KRC_Config.myGUI:Create("SimpleGroup")
			spellGroup:SetLayout("Flow")
			spellGroup:SetFullWidth(true)

			local alwaysShowBox = CreateAlwaysShowBox(spellID)
			local enableBox = CreateEnableBox(spellID)
			spellGroup:AddChild(enableBox)
			spellGroup:AddChild(alwaysShowBox)

			scrollFrame:AddChild(spellGroup)
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
