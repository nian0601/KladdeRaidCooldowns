KRC_Core = LibStub("AceAddon-3.0"):NewAddon("KRC_Core", "AceConsole-3.0", "AceEvent-3.0")

local options = {
	name = "KRC",
	handler = KRC_Core,
	type = 'group',
	args = {
		config = {
			type = 'execute',
			name = 'config',
			desc = 'Opens the Configuration menu',
			func = function() KRC_Config:OnEnable() end
		},
	},
}

local defaults = {
	profile = {
		myGroups = {},
		myPlayerSpeccs = {},
		pally_auras = {
			height = 10,
			bottomLeftX = 10,
			bottomLeftY = 300,
			isEnabled = true
		},
	},
}

function KRC_Core:OnInitialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("KRC_Core", options, {"KRC", "krc"})
	self.db = LibStub("AceDB-3.0"):New("KladdeRaidCooldownsV2DB", defaults, true)
	
	KRC_Display:Init()
	KRC_PallyAuras:Init()
	--KRC_Config:OnEnable()
end

function KRC_Core:Update()
	KRC_Display:Update()
end

local ourTimeSinceLastUpdate = 0
local ourTimeBetweenUpdates = 1
local function localOnUpdate(self, aElapsed)
	ourTimeSinceLastUpdate = ourTimeSinceLastUpdate + aElapsed
	if(ourTimeSinceLastUpdate > ourTimeBetweenUpdates) then
		ourTimeSinceLastUpdate = ourTimeSinceLastUpdate - ourTimeBetweenUpdates

		KRC_Core:Update()
		KRC_PallyAuras:Update()
		CombatLogClearEntries()
	end
end

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", localOnUpdate)