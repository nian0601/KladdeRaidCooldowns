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
	},
}

function KRC_Core:OnInitialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("KRC_Core", options, {"KRC", "krc"})
	self.db = LibStub("AceDB-3.0"):New("KladdeRaidCooldownsV2DB", defaults, true)

	self.LibRaidCooldowns = LibStub("LibRaidCooldowns")
	self.LibRaidCooldowns:Register(self) -- Notify my_object about cooldown informations through the functions
	KRC_Display:Init()
	--KRC_Config:OnEnable()
end

function KRC_Core:Update()
	KRC_DataCollector:Update()
	KRC_Display:Update()
end

function KRC_Core:RAID_COOLDOWN_STARTED(cooldown)          --when the cooldown of the spell cooldown.name starts
	--self:Print("Cooldown for " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " started!")
end

function KRC_Core:RAID_COOLDOWN_CHANGED(cooldown)        --when the cooldown of the spell cooldown.name changes
	--self:Print("Cooldown for " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " changed!")
end

function KRC_Core:RAID_COOLDOWN_READY(cooldown)          --when the cooldown of the spell cooldown.name ends
	--self:Print("Cooldown for " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " ended!")
end

function KRC_Core:RAID_COOLDOWN_AVAILABLE(cooldown)      --when a cooldown becomes available (a druid joins the party, innervate becomes available)
	--self:Print("Spell " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " is available!")
end

function KRC_Core:RAID_COOLDOWN_UNAVAILABLE(cooldown)    --when a cooldown becomes unavailable (a druid leaves the party, innervate becomes unavailable)
	--self:Print("Spell " .. GetSpellInfo(cooldown.spellId) .. " from " .. cooldown.name .. " is unavailable!")
end

local ourTimeSinceLastUpdate = 0
local ourTimeBetweenUpdates = 1
local function localOnUpdate(self, aElapsed)
	ourTimeSinceLastUpdate = ourTimeSinceLastUpdate + aElapsed
	if(ourTimeSinceLastUpdate > ourTimeBetweenUpdates) then
		KRC_Core:Update()
		ourTimeSinceLastUpdate = ourTimeSinceLastUpdate - ourTimeBetweenUpdates
		CombatLogClearEntries()
	end
end

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", localOnUpdate)