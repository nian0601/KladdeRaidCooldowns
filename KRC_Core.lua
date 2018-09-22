KRC_Core = LibStub("AceAddon-3.0"):NewAddon("KRC_Core", "AceConsole-3.0", "AceEvent-3.0")

local ourTimeSinceLastUpdate = 0
local ourTimeBetweenUpdates = 1

function KRC_Core:OnInitialize()
end

function KRC_Core:Update()
	KRC_DataCollector:Update()
	KRC_Display:Update()
end

local function localOnUpdate(self, aElapsed)
	ourTimeSinceLastUpdate = ourTimeSinceLastUpdate + aElapsed
	if(ourTimeSinceLastUpdate > ourTimeBetweenUpdates) then
		KRC_Core:Update()
		ourTimeSinceLastUpdate = ourTimeSinceLastUpdate - ourTimeBetweenUpdates
	end
end

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", localOnUpdate)