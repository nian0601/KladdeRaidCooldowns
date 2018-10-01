local function CreateSpeccButtons(aName, aClass, someSpeccs)

	local createBox = function(aString)
		local box = KRC_Config.myGUI:Create("CheckBox")
		box:SetUserData("specc", aString)
		local currentSpecc = KRC_Display:GetPlayerSpecc(aName)
		if(currentSpecc ~= nil and currentSpecc == aString) then
			box:SetValue(true)
		end

		box:SetLabel(aString)
		box:SetWidth(100)
		return box;
	end

	local speccGroup = KRC_Config.myGUI:Create("SimpleGroup")
	speccGroup:SetLayout("Flow")
	speccGroup:SetFullWidth(true)

	local color = RAID_CLASS_COLORS[aClass]
	local nameLabel = KRC_Config.myGUI:Create("Label")
	nameLabel:SetText(aName)
	nameLabel:SetWidth(100)
	nameLabel:SetColor(color.r, color.g, color.b)
	speccGroup:AddChild(nameLabel)

	local boxes = {}
	local function checkboxCallback(widget, event, value)
		KRC_Display:SetPlayerSpecc(aName, widget:GetUserData("specc"), value)

		if(value == true) then
			local numBoxes = table.getn(boxes)
			for i = 1, numBoxes do
				if (widget ~= boxes[i]) then
					boxes[i]:SetValue(false)
				end
			end
		end
	end

	for specc, active in pairs(someSpeccs) do
		local box = createBox(specc)
		box:SetCallback("OnValueChanged", checkboxCallback)
		speccGroup:AddChild(box)
		table.insert(boxes, box)
	end
	
	return speccGroup
end

local function DrawClassSettings(aContainer, anEvent, aClass)
	aContainer:ReleaseChildren()

	local speccs = KRC_Spells.mySpeccs[aClass]

	local scrollFrame = KRC_Config.myGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")
	scrollFrame:SetFullWidth(true)

	local numRaidMembers = GetNumRaidMembers()
	for i = 1, MAX_RAID_MEMBERS do
		local id = "raid" .. i
		local name = UnitName(id)
		local _, class = UnitClass(id)

		if(name ~= nil and class == aClass) then
			scrollFrame:AddChild(CreateSpeccButtons(name, aClass, speccs))
		end
	end

	aContainer:AddChild(scrollFrame)
end

function KRC_Config_DrawSpeccs(aContainer)
	local tabGroup = KRC_Config.myGUI:Create("TabGroup")
	tabGroup:SetLayout("Flow")
	tabGroup:SetTabs(
	{
		{ text="Druids", value="DRUID" },
		{ text="Hunters", value="HUNTER" },
		{ text="Mages", value="MAGE" },
		{ text="Paladins", value="PALADIN" },
		{ text="Priests", value="PRIEST" },
		{ text="Rogues", value="ROGUE" },
		{ text="Shamans", value="SHAMAN" },
		{ text="Warlocks", value="WARLOCK" },
		{ text="Warriors", value="WARRIOR" },
		{ text="Death Knights", value="DEATHKNIGHT" }
	})
	tabGroup:SetCallback("OnGroupSelected", DrawClassSettings)
	tabGroup:SelectTab("DRUID")

	aContainer:AddChild(tabGroup)
end