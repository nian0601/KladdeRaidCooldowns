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
		cooldowns = {
			activeSpells = {},
			maxNumBars = 30,
			bottomLeftX = 10,
			bottomLeftY = 300,
			barSpacing = 1,
			barWidth = 150,
			barHeight = 10,
			classSpacing = 10,
			enableExtraDetails = true,
			enableGSGlyphCheck = false,
			numberOfRows = 10
		},
		pally_auras = {
			height = 15,
			bottomLeftX = 10,
			bottomLeftY = 300,
			isEnabled = true
		},
	},
}

local timeSinceLastUpdate = 0
local timeBetweenUpdates = 1

local enableDebuggning = false
local debuggingCasterName = "Kladdemaja"

function KRC_Core:OnInitialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("KRC_Core", options, {"KRC", "krc"})

	self.db = LibStub("AceDB-3.0"):New("KladdeRaidCooldownsDB", defaults, true)

	--self.db.profile.cooldowns = defaults.profile.cooldowns

	self.MediaPath = "Interface\\Addons\\KladdeRaidCooldowns\\Media\\"
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	KRC_Cooldowns:Initialize()
	KRC_PallyAuras:Init()

	--KRC_Config:OnEnable()
end

function KRC_Core:PrintCombatEventDebug(...)
	local timestamp, -- Time of the event
	 eventType, -- SPELL_AURA_REMOVED, SPELL_CAST_SUCCESS etc
	 casterGUID, -- GUID of the unit that generated the event
	 casterName, -- Name of the unit that generated the event 
	 sourceFlags, -- Flags about the unit that generated the event
	 targetGUID, -- GUID of the unit that was the target of the event, if there is one(?)
	 targetName, -- Name of the unit that was the target of the event, if there is one(?)
	 targetFlags -- Flags of the unit that was the target of the event, if there is one(?)
	  = ...

	self:Print("--- NEW INFO ---")

	self:Print("timestamp: " .. timestamp)
	self:Print("event: " .. eventType)
	self:Print("casterGUID: " .. casterGUID)
	self:Print("casterName: " .. casterName)
	self:Print("sourceFlags: " .. sourceFlags)

	if(targetName ~= nil) then
		self:Print("targetGUID: " .. targetGUID)
		self:Print("targetName: " .. targetName)
		self:Print("targetFlags: " .. targetFlags)
	end

	local className, classId, raceName, raceId, gender, name, realm = GetPlayerInfoByGUID(casterGUID)
	self:Print("CasterNameFromGUID: " .. name)

	local _className, _classId, _raceName, _raceId, _gender, _name, _realm = GetPlayerInfoByGUID(targetGUID)
	if(_name ~= nil) then
		self:Print("Target:")
		self:Print("Class: " .. _className)
		self:Print("ClassID: " .. _classId)
		self:Print("Name: " .. _name)
	end

	local spellId, spellName, spellSchool = select(9, ...)
	self:Print(spellId .. " : " .. spellName .. " : " .. spellSchool)

	self:Print("--- INFO END ---")
end

function KRC_Core:UnitIsInOurRaidOrParty(aUnitName)
	local numRaidMembers = GetNumRaidMembers()
	for i = 1, numRaidMembers do
		local memberName = UnitName("raid" .. i)
		if(memberName == aUnitName) then
			return true
		end
	end

	local numPartyMembers = GetNumPartyMembers()
	for i = 1, numPartyMembers do
		local memberName = UnitName("party" .. i)
		if(memberName == aUnitName) then
			return true
		end
	end

	return false
end

function KRC_Core:COMBAT_LOG_EVENT_UNFILTERED(aEventName, ...)
	local timestamp, -- Time of the event
	 eventType, -- SPELL_AURA_REMOVED, SPELL_CAST_SUCCESS etc
	 casterGUID, -- GUID of the unit that generated the event
	 casterName, -- Name of the unit that generated the event 
	 sourceFlags, -- Flags about the unit that generated the event
	 targetGUID, -- GUID of the unit that was the target of the event, if there is one(?)
	 targetName, -- Name of the unit that was the target of the event, if there is one(?)
	 targetFlags -- Flags of the unit that was the target of the event, if there is one(?)
	  = ...

	local playerName = UnitName("player")
	if(playerName ~= casterName) then
		if(self:UnitIsInOurRaidOrParty(casterName) == false) then
			return
		end
	end

	local isSpellCast = string.find(eventType, "SPELL_")
	if(isSpellCast == nil) then
		return
	end

	local spellId, spellName, spellSchool = select(9, ...)
	local className, classId = GetPlayerInfoByGUID(casterGUID)

	local isAuraRemoval = eventType == "SPELL_AURA_REMOVED"
	local isSpellCastSuccess = eventType == "SPELL_CAST_SUCCESS"
	local isAuraApplied = eventType == "SPELL_AURA_APPLIED"
	local isResurrection = eventType == "SPELL_RESURRECT"
	local isHeal = eventType == "SPELL_HEAL"
	
	if(isAuraApplied == true or isSpellCastSuccess == true or isResurrection == true or isAuraRemoval == true or isHeal == true) then
		KRC_Cooldowns:OnSpellEvent(eventType, casterName, classId, spellId, spellName, targetName, isAuraApplied)
	end


	-- Just debugging, safe to ignore this..
	if enableDebuggning == true and debuggingCasterName == casterName then
		self:PrintCombatEventDebug(...)
	end
end

local function localOnUpdate(self, aElapsed)
	timeSinceLastUpdate = timeSinceLastUpdate + aElapsed
	if(timeSinceLastUpdate > timeBetweenUpdates) then
		KRC_Cooldowns:UpdateBars(aElapsed)
		KRC_PallyAuras:Update()
		timeSinceLastUpdate = timeSinceLastUpdate - timeBetweenUpdates
	end
end

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", localOnUpdate)