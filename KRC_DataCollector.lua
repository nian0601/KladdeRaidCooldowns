--[[
SpellID is outer-index
For each SpellID we'll store information specific to each playerthat has the spell.
We need to store the following for each player:
- Is it on CD?
- Remaining CD
- If its a targeted-spell, who was it used on?
- If its AuraMastery, which aura was active?
- If its GuardianSpirit, was it consumed or did it expire?

We dont care about filtering what should be visible or not here.
We'll just collect data for all spells specified in KRC_Spells.lua.
The display-module will later decide what to show or not


local rebirthInfo = KRC_DataCollector.myData[48477]
local shirubaInfo = rebirthInfo["Shiruba"]
shirubaInfo.myRemainingCD = 48
shirubaInfo.myTarget = "Froztitude"
shirubaInfo.myPaladinAura = NIL
shirubaInfo.myGuardianSpiritFaded
]]

KRC_DataCollector = LibStub("AceAddon-3.0"):NewAddon("KRC_DataCollector", "AceConsole-3.0", "AceEvent-3.0")
KRC_DataCollector.myData = {}
KRC_DataCollector.myPaladinAuras = {}
KRC_DataCollector.myNumTicksSinceLastGroupScan = 0
KRC_DataCollector.myEnableDebugPrinting = false

function KRC_DataCollector:OnInitialize()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	--self:RegisterEvent("PARTY_MEMBERS_CHANGED", "ScanGroupForSpells")
	--self:RegisterEvent("RAID_ROSTER_UPDATE", "ScanGroupForSpells")
	--self:RegisterEvent("RAID_TARGET_UPDATE", "ScanGroupForSpells")
	

	self:InitializeSpellsForPlayer("player")

	self:ScanGroupForSpells()
end	

function KRC_DataCollector:DebugPrint(aMessage)
	if(self.myEnableDebugPrinting == true) then
		self:Print(aMessage)
	end
end

function KRC_DataCollector:InitializeSpellsForPlayer(aUnitID)
	local name = UnitName(aUnitID)
	local _,class = UnitClass(aUnitID)

	local spells = KRC_Spells.mySpells[class]

	for spellID, spellData in pairs(spells) do
		if(self.myData[spellID] == nil) then
			self.myData[spellID] = {}
		end

		if(self.myData[spellID][name] == nil) then
			self.myData[spellID][name] = {}
			local casterData = self.myData[spellID][name]
			casterData.myClass = class
			casterData.myRemainingCD = nil
			casterData.myTarget = nil
		end

		self.myData[spellID][name].myUnitID = aUnitID
	end
end

function KRC_DataCollector:ScanGroupForSpells()
	local numRaidMembers = GetNumRaidMembers()
	for i = 1, numRaidMembers do
		self:InitializeSpellsForPlayer("raid" .. i)
	end

	local numPartyMembers = GetNumPartyMembers()
	for i = 1, numPartyMembers do
		self:InitializeSpellsForPlayer("party" .. i)
	end
end

function KRC_DataCollector:UpdatePaladinAuras()
	local cachedAuras = KRC_Spells.myPaladinAuras
	for i = 1, 7 do
		local name,_,_,_,_,_,_, source = UnitBuff("player", cachedAuras[i].Name)
		if (name ~= nil) then
			local sourceName = UnitName(source)
			self.myPaladinAuras[cachedAuras[i].Name] = sourceName
		else
			self.myPaladinAuras[cachedAuras[i].Name] = nil
		end
	end
end

function KRC_DataCollector:Update()

	self.myNumTicksSinceLastGroupScan = self.myNumTicksSinceLastGroupScan + 1
	if(self.myNumTicksSinceLastGroupScan > 10) then
		self:ScanGroupForSpells()
		self.myNumTicksSinceLastGroupScan = 0
	end

	self:UpdatePaladinAuras()
	self:InitializeSpellsForPlayer("player")
	for spellID, spellData in pairs(self.myData) do 
		for casterName, casterData in pairs(spellData) do 
			if(casterData.myRemainingCD ~= nil) then
				casterData.myRemainingCD = casterData.myRemainingCD - 1
				self:DebugPrint("CD On " .. GetSpellInfo(spellID) .. ": " .. casterData.myRemainingCD)
				if (casterData.myRemainingCD < 0) then
					casterData.myRemainingCD = nil
				end
			end
		end
	end
end

function KRC_DataCollector:GetPaladinAura(aPaladinName)
	local cachedAuras = KRC_Spells.myPaladinAuras

	for i = 1, 7 do
		local auraData = self.myPaladinAuras[cachedAuras[i].Name]
		if(auraData ~= nil) then
			if auraData == aPaladinName then
				return cachedAuras[i].Name
			end
		end
	end
	return nil
end

function KRC_DataCollector:AddData(aCasterName, aCasterClass, aSpellID, aTarget)
	-- This will be nil if we dont have any CD info for this spell, so just return in that case
	local spellCD = KRC_Spells:GetSpellCD(aCasterName, aCasterClass, aSpellID)
	if(spellCD == nil) then
		return
	end

	-- Make sure we have valid tables for the spell and caster
	-- The first time we see the spell being cast by each caster the respective tables
	-- would be nil if we dont do this...
	if(self.myData[aSpellID] == nil) then
		self.myData[aSpellID] = {}
	end

	if(self.myData[aSpellID][aCasterName] == nil) then
		self.myData[aSpellID][aCasterName] = {}
	end

	local casterData = self.myData[aSpellID][aCasterName]
	casterData.myClass = aCasterClass
	casterData.myRemainingCD = spellCD
	casterData.myTarget = nil
	casterData.myUnitID = KRC_Helpers:GetUnitID(aCasterName)
	if(KRC_Spells:SpellIsTargeted(aSpellID)) then
		casterData.myTarget = aTarget
	end

	casterData.myPaladinAura = nil
	if(KRC_Spells:IsAuraMastery(aSpellID)) then
		casterData.myPaladinAura = self:GetPaladinAura(aCasterName)
	end

	casterData.myGuardianSpiritFaded = nil
	if(KRC_Spells:IsGuardianSpirit(aSpellID)) then
		casterData.myGuardianSpiritFaded = false
	end
end

function KRC_DataCollector:COMBAT_LOG_EVENT_UNFILTERED(aEventName, ...)
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
		if(KRC_Helpers:UnitIsInOurRaidOrParty(casterName) == false) then
			return
		end
	end

	local isSpellCast = string.find(eventType, "SPELL_")
	if(isSpellCast == nil) then
		return
	end

	local isAuraRemoval = eventType == "SPELL_AURA_REMOVED"
	local isAuraApplied = eventType == "SPELL_AURA_APPLIED"
	local isSpellCastSuccess = eventType == "SPELL_CAST_SUCCESS"
	local isResurrection = eventType == "SPELL_RESURRECT"
	local isHeal = eventType == "SPELL_HEAL"
	if(isAuraRemoval == false and isAuraApplied == false and isSpellCastSuccess == false and isResurrection == false and isHeal == false) then
		return
	end	

	local spellID, spellName, spellSchool = select(9, ...)
	local _, casterClassID = GetPlayerInfoByGUID(casterGUID)

	if(isSpellCastSuccess or isResurrection or isAuraApplied) then
		self:AddData(casterName, casterClassID, spellID, targetName)
	end

	if(isAuraRemoval) then
		-- Handle GuardianSpirit logic here
	end
end