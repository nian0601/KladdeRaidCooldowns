KRC_Config = {}

local function SelectGroup(container, event, group)
	container:ReleaseChildren()

	if group == "cooldowns" then
		KRC_Config_DrawCooldowns(container)
	--elseif group == "pally_auras" then
	--	KRC_Config_DrawPallyAuras(container)
	end
end

function KRC_Config:OnEnable()
	if(self.myIsOpen == nil) then
		self.myIsOpen = true

		self.myGUI = LibStub("AceGUI-3.0")

		local frame = self.myGUI:Create("Frame")
		frame:SetTitle("KRC Config")
		frame:SetStatusText("Configuration for KladdeRaidCooldowns")
		frame:SetCallback("OnClose", function(widget) self.myGUI:Release(widget) self.myIsOpen = nil end)
		frame:SetLayout("Fill")


		local tabGroup = self.myGUI:Create("TabGroup")
		tabGroup:SetLayout("Fill")
		tabGroup:SetTabs(
		{
			{ text="Cooldowns", value="cooldowns" },
			{ text="Pally Auras", value="pally_auras" }
		})
		tabGroup:SetCallback("OnGroupSelected", SelectGroup)
		tabGroup:SelectTab("cooldowns")

		frame:AddChild(tabGroup)
	end
end