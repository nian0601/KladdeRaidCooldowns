local scrollFrame = nil

local function CreateGeneralConfig(container)
	local enable = KRC_Config.myGUI:Create("CheckBox")
	enable:SetLabel("Enable")
	enable:SetValue(KRC_Core.db.profile.pally_auras.isEnabled)
	enable:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_PallyAuras:ToggleVisibility(value)
	end)

	local unlock = KRC_Config.myGUI:Create("CheckBox")
	unlock:SetLabel("Unlock")
	unlock:SetCallback("OnValueChanged", function(widget, event, value)
		KRC_PallyAuras:ToggleDragableFrame(value)
	end)

	container:AddChild(enable)
	container:AddChild(unlock)
end

function KRC_Config_DrawPallyAuras(container)
	if scrollFrame then 
		scrollFrame:ReleaseChildren() 
		scrollFrame = nil
	end
	
	scrollFrame = KRC_Config.myGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")

	CreateGeneralConfig(scrollFrame)

	container:AddChild(scrollFrame)
end