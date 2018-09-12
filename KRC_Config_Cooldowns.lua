local scrollFrame = nil

local function CreateGeneralConfig(container)
	local heightSlider = KRC_Config.GUI:Create("Slider")
	heightSlider:SetSliderValues(1, 128, 1)
	heightSlider:SetValue(KRC_Core.db.profile.cooldowns.barHeight)
	heightSlider:SetLabel("Bar Height")

	heightSlider:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Core.db.profile.cooldowns.barHeight = value
		KRC_Cooldowns:UpdateBarSizes()
		KRC_Cooldowns:RepositionBars()
	end)

	local widthSlider = KRC_Config.GUI:Create("Slider")
	widthSlider:SetSliderValues(1, 512, 1)
	widthSlider:SetValue(KRC_Core.db.profile.cooldowns.barWidth)
	widthSlider:SetLabel("Bar Width")

	widthSlider:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Core.db.profile.cooldowns.barWidth = value
		KRC_Cooldowns:UpdateBarSizes()
		KRC_Cooldowns:RepositionBars()
	end)

	local spacingSlider = KRC_Config.GUI:Create("Slider")
	spacingSlider:SetSliderValues(1, 32, 1)
	spacingSlider:SetValue(KRC_Core.db.profile.cooldowns.barSpacing)
	spacingSlider:SetLabel("Bar Spacing")

	spacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Core.db.profile.cooldowns.barSpacing = value
		KRC_Cooldowns:RepositionBars()
	end)

	local classSpacingSlider = KRC_Config.GUI:Create("Slider")
	classSpacingSlider:SetSliderValues(1, 32, 1)
	classSpacingSlider:SetValue(KRC_Core.db.profile.cooldowns.classSpacing)
	classSpacingSlider:SetLabel("Class Spacing")

	classSpacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Core.db.profile.cooldowns.classSpacing = value
		KRC_Cooldowns:RepositionBars()
	end)

	local numberOfBarsSlider = KRC_Config.GUI:Create("Slider")
	numberOfBarsSlider:SetSliderValues(1, 50, 1)
	numberOfBarsSlider:SetValue(KRC_Core.db.profile.cooldowns.maxNumBars)
	numberOfBarsSlider:SetLabel("Num Bars")

	numberOfBarsSlider:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Core.db.profile.cooldowns.maxNumBars = value
	end)


	local numberOfRowsSlider = KRC_Config.GUI:Create("Slider")
	numberOfRowsSlider:SetSliderValues(1, 10, 1)
	numberOfRowsSlider:SetValue(KRC_Core.db.profile.cooldowns.numberOfRows)
	numberOfRowsSlider:SetLabel("Num Rows")

	numberOfRowsSlider:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Core.db.profile.cooldowns.numberOfRows = value
		KRC_Cooldowns:RepositionBars()
	end)

	local unlockBars = KRC_Config.GUI:Create("CheckBox")
	unlockBars:SetLabel("Move Bars")
	unlockBars:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Cooldowns:ToggleDragableFrame(value)
	end)

	local checkForGSGlyph = KRC_Config.GUI:Create("CheckBox")
	checkForGSGlyph:SetValue(KRC_Core.db.profile.cooldowns.enableGSGlyphCheck)
	checkForGSGlyph:SetLabel("Guardian Spirit Glyph check Bars")
	checkForGSGlyph:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Core.db.profile.cooldowns.enableGSGlyphCheck = value
	end)

	local extraDetails = KRC_Config.GUI:Create("CheckBox")
	extraDetails:SetValue(KRC_Core.db.profile.cooldowns.enableExtraDetails)
	extraDetails:SetLabel("Extra Details (Targets / AM-Aura)")
	extraDetails:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_Core.db.profile.cooldowns.enableExtraDetails = value
	end)

	local resetPosition = KRC_Config.GUI:Create("Button")
	resetPosition:SetText("Reset Position")
	resetPosition:SetCallback("OnClick", function(widget, event, value)
		KRC_Cooldowns:ResetPosition()
	end)

	local testBars = KRC_Config.GUI:Create("Button")
	testBars:SetText("Test Bars")
	testBars:SetCallback("OnClick", function(widget, event, value)
		KRC_Cooldowns:FillWithTestBars()
	end)

	container:AddChild(heightSlider)
	container:AddChild(widthSlider)
	container:AddChild(spacingSlider)
	container:AddChild(classSpacingSlider)
	container:AddChild(numberOfBarsSlider)
	container:AddChild(numberOfRowsSlider)
	container:AddChild(checkForGSGlyph)
	container:AddChild(extraDetails)
	container:AddChild(unlockBars)
	container:AddChild(resetPosition)
	container:AddChild(testBars)
end

local function SelectClassConfig(container, event, class)
	container:ReleaseChildren()
	container:PauseLayout()

	local classSpells = KRC_Cooldowns.mySpells[class]
	local temp = {}
	for id in pairs(classSpells) do
		temp[#temp + 1] = id
	end

	for i, spellID in next, temp do
		local checkbox = KRC_Config.GUI:Create("CheckBox")
		local spellName, _, spellIcon = GetSpellInfo(spellID)

		checkbox:SetLabel(spellName)
		checkbox:SetImage(spellIcon)

		local checkboxValue = KRC_Core.db.profile.cooldowns.activeSpells[spellID] ~= nil
		if checkboxValue == true then
			checkboxValue = KRC_Core.db.profile.cooldowns.activeSpells[spellID]
		end
		checkbox:SetValue(checkboxValue)

		checkbox:SetUserData("id", spellID)
		checkbox:SetCallback("OnValueChanged", function(widget, event, value)
			local id = widget:GetUserData("id")
			if not id then return end

			KRC_Core.db.profile.cooldowns.activeSpells[id] = value
		end)

		container:AddChild(checkbox)
	end
	container:ResumeLayout()
	scrollFrame:DoLayout()
end

function KRC_Config_DrawCooldowns(container)
	if scrollFrame then 
		scrollFrame:ReleaseChildren() 
		scrollFrame = nil
	end
	local hexColors = {}
	for k, v in pairs(RAID_CLASS_COLORS) do
		hexColors[k] = "|cff" .. string.format("%02x%02x%02x", v.r * 255, v.g * 255, v.b * 255)
	end
	local classes = {}
	for class in pairs(KRC_Cooldowns.mySpells) do
		classes[class] = hexColors[class] .. LOCALIZED_CLASS_NAMES_MALE[class] .. "|r"
	end

	scrollFrame = KRC_Config.GUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")

	CreateGeneralConfig(scrollFrame)

	local dropdown = KRC_Config.GUI:Create("DropdownGroup")
	dropdown:SetLayout("List")
	dropdown:SetTitle("Select Class")
	dropdown:SetGroupList(classes)
	dropdown:SetCallback("OnGroupSelected", SelectClassConfig)
	dropdown:SetGroup("PALADIN")
	dropdown:SetFullWidth(true)

	scrollFrame:AddChild(dropdown)
	container:AddChild(scrollFrame)
end