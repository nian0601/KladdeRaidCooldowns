KRC_Config_RaidScan = {}

local function DrawClassSettings(aContainer, anEvent, aClass)
	aContainer:ReleaseChildren()

	local speccs = KRC_Spells.mySpeccs[aClass]

	local scrollFrame = KRC_Config.myGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")
	scrollFrame:SetFullWidth(true)
		
	aContainer:AddChild(scrollFrame)
end

function KRC_Config_RaidScan:OnEnable()
	if(self.myIsOpen == nil) then
		self.myIsOpen = true

		self.myGUI = LibStub("AceGUI-3.0")

		local frame = self.myGUI:Create("Frame")
		frame:SetTitle("KRC Config")
		frame:SetStatusText("Configuration for KladdeRaidCooldowns")
		frame:SetCallback("OnClose", function(widget) self.myGUI:Release(widget) self.myIsOpen = nil end)
		frame:SetLayout("Fill")

		local tabGroup = KRC_Config.myGUI:Create("TabGroup")
		tabGroup:SetLayout("Flow")
		tabGroup:SetTabs(
		{
			{ text="Druids", value="DRUID" },
			{ text="Paladins", value="PALADIN" },
			{ text="Priests", value="PRIEST" },
			{ text="Shamans", value="SHAMAN" },
			{ text="Warriors", value="WARRIOR" },
			{ text="Death Knights", value="DEATHKNIGHT" }
		})
		tabGroup:SetCallback("OnGroupSelected", DrawClassSettings)
		tabGroup:SelectTab("DRUID")
		frame:AddChild(tabGroup)
	end
end