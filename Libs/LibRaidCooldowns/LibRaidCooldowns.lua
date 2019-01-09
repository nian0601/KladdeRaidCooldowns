--[[ Usage:

  local LibRaidCooldowns = LibStub("LibRaidCooldowns")

  LibRaidCooldowns:Register(my_object) -- Notify my_object about cooldown informations through the functions
  -- my_object:RAID_COOLDOWN_START(cooldown)          when the cooldown of the spell cooldown.name starts
  -- my_object:RAID_COOLDOWN_CHANGED(cooldown)        when the cooldown of the spell cooldown.name changes
  -- my_object:RAID_COOLDOWN_READY(cooldown)          when the cooldown of the spell cooldown.name ends
  -- my_object:RAID_COOLDOWN_AVAILABLE(cooldown)      when a cooldown becomes available (a druid joins the party, innervate becomes available)
  -- my_object:RAID_COOLDOWN_UNAVAILABLE(cooldown)    when a cooldown becomes unavailable (a druid leaves the party, innervate becomes unavailable)

  --Example :
  function my_object:RAID_COOLDOWN_READY(info)
    print("My Object: Cooldown for spell", info.name, "is ready!")
  end

  LibRaidCooldowns:Unregister(my_object)     -- Stops notifying my_object for any cooldown state change
--]]

local Major, Minor = "LibRaidCooldowns", 1;
local LRC, OldMinor = LibStub:NewLibrary(Major, Minor);

if not LRC then return end

local LUA     = LibStub("LibUnitAura")
local C_Timer = LibStub("C_Timer")
local LGT     = LibStub("LibGroupTalents-1.0")

--[[-----------------------------------------------------------------------------------------------
 Locals & declarations
-------------------------------------------------------------------------------------------------]]

local TalentInfo

local RosterInfo = {}

local TalentUpdate
local UnitAvailable, UnitUnavailable

local CombatLogEventFrame, EventFrame

local CheckSoulstone

-- Imported Globals
local table_insert  = table.insert
local table_remove  = table.remove
local GetTime       = GetTime

--[[-----------------------------------------------------------------------------------------------
 Helper
-------------------------------------------------------------------------------------------------]]

--[[ Note:
  List of raid units ("raid1", ..., "raid40") 
--]]
local RaidUnits = {}

do for i = 1, 40 do
  RaidUnits[i] = "raid" .. i
end end

--[[ Note:
  List of party units ("party1", ..., "party4")
--]]
local PartyUnits = {}

do for i = 1, 4 do
  PartyUnits[i] = "party" .. i
end end

--[[ Note:
  Ensures RosterInfo tables are following the correct scheme
--]]
local function ValidateRosterInfo(guid)
  RosterInfo[guid] = RosterInfo[guid] or {}
  
  RosterInfo[guid].cooldownModels = RosterInfo[guid].cooldownModels or {}
  RosterInfo[guid].cooldowns      = RosterInfo[guid].cooldowns or {}
end

local function FindCooldown(list, spellId)
  if type(spellId) == "table" then
    for _, cooldown in pairs(list) do
      if spellId[cooldown.spellId] then
        return cooldown
      end
    end
  else
    for _, cooldown in pairs(list) do
      if cooldown.spellId == spellId then
        return cooldown
      end
    end
  end
end
  
--[[-----------------------------------------------------------------------------------------------
 Table pooling
-------------------------------------------------------------------------------------------------]]

-- TODO: That's lame, we should merge all libraries into one and have one unique table pool

local AuraTablePool = {}
local function GetAuraTable()
  if #AuraTablePool > 0 then return table_remove(AuraTablePool, #AuraTablePool) end

  local table = {
    blizzardIndex   = nil,
    filter          = nil,
    uniqueId        = nil,
    spellId         = nil,
    unit            = nil,
    unitName        = nil,
    unitGUID        = nil,
    casterUnit      = nil,
    casterName      = nil,
    casterGUID      = nil,
    name            = nil,
    count           = nil,
    creation        = nil,
    duration        = nil,
    expirationTime  = nil,
    icon            = nil,
    classification  = nil,
    isStealable     = nil,
  }

  return table
end

local function FreeAura(auraList, index)
  table_insert(AuraTablePool, auraList[index])
  
  auraList[index] = nil
end

--[[-----------------------------------------------------------------------------------------------
 Cooldown Informations
-------------------------------------------------------------------------------------------------]]

-- TODO: Make aura mastery appear as available only if the player has a usefull aura for the raid (and with the icon of the the aura)

local TalentInfo = {
  ["DEATHKNIGHT"] = {
  },
  ["DRUID"] = {
    [29166]   = {name = "Innervate", tree = nil, duration = 180, },
    [48477]   = {name = "Rebirth", tree = nil, duration = 600, },
    [48447]   = {name = "Tranquility", tree = 3, talent = 14, duration = 480, ranks = {[0] = 0, [1] = -144, [2] = -288, }, },
  },
  ["HUNTER"] = {
    [34477]   = {name = "Misdirection", tree = nil, duration = 30, noCombatLog = true, },
    [23989]   = {name = "Readiness", tree = 2, talent = 14, duration = 180, ranks = {[1] = 0, }, },
  },
  ["MAGE"] = {
    [45438]   = {name = "Iceblock", tree = 3, talent = 3, duration = 300, ranks = {[0] = 0, [1] = -21, [2] = -42, [3] = -60}, }, 
    [11958]   = {name = "Cold Snap", tree = 3, talent = 14, duration = 480, ranks = {[1] = 0, }, }, 
  },
  ["PALADIN"] = {
    [31821]   = {name = "Aura Mastery", tree = 1, talent = 6, duration = 120, ranks = {[1] = 0, }, },
    [498]     = {name = "Divine Protection", tree = 2, talent = 14, duration = 180, ranks = {[0] = 0, [1] = -30, [2] = -60, }, }, 
    [64205]   = {name = "Divine Sacrifice", tree = 2, talent = 9, duration = 120, ranks = {[1] = 0, [2] = 0, }, },
    [642]     = {name = "Divine Shield", tree = 2, talent = 14, duration = 300, ranks = {[0] = 0, [1] = -30, [2] = -60, }, }, 
    [1038]    = {name = "Hand of Salvation", tree = nil, duration = 120},
    [10278]   = {name = "Hand of Protection", tree = 2, talent = 4, duration = 300, ranks = {[0] = 0, [1] = -60, [2] = -120, }, },
    [6940]    = {name = "Hand of Sacrifice", tree = nil, duration = 120,}, 
    [48788]   = {name = "Lay on Hands", tree = 1, talent = 8, duration = 900, ranks = {[0] = 0, [1] = -120, [2] = -240,}, },
  },
  ["PRIEST"] = {
    [64843]   = {name = "Divine Hymn", tree = nil, duration = 480, },
    [6346]    = {name = "Fear Ward", tree = nil, duration = 180, }, 
    [47788]   = {name = "Guardian Spirit", tree = 2, talent = 27, duration = 180, ranks = {[1] = 0, }, }, 
    [64901]   = {name = "Hymn of Hope", tree = nil, duration = 360, }, 
    [33206]   = {name = "Pain Suppresion", tree = 1, talent = 25, duration = 180, ranks = {[1] = 0, }, }, 
    [54521]   = {name = "Power Infusion", tree = 1, talent = 19, duration = 120, ranks = {[1] = 0, }, }, 
  },
  ["ROGUE"] = {
    [57934]   = {name = "Tricks of the Trade", tree = nil, duration = 30, noCombatLog = true, }, 
    [14185]   = {name = "Preparation", tree = 3, talent = 14, duration = 480, ranks = {[1] = 0, }, },
  },
  ["SHAMAN"] = {
    [2825]    = {name = "Bloodlust", tree = nil, duration = 300, },  
    [32182]   = {name = "Heroism", tree = nil, duration = 300, },  
    [16190]   = {name = "Mana Tide Totem", tree = 3, talent = 17, duration = 300, ranks = {[1] = 0, }, }, 
    [20608]   = {name = "Reincarnation", tree = 3, talent = 3, duration = 1800, ranks = {[0] = 0, [1] = -420, [2] = -900, }, }, 
  },
  ["WARLOCK"] = {
    [29858]   = {name = "Soulshatter", tree = nil, duration = 180, },
    [47883]   = {name = "Soulstone Resurrection", tree = nil, duration = 900},
  },
  ["WARRIOR"] = {
  },
}

local PaladinAuras = {
  [31821] = true, 
  [48942] = true, 
  [54043] = true, 
  [48943] = true, 
  [48945] = true, 
  [48947] = true, 
  [19746] = true, 
  [32223] = true;
}

--[[-----------------------------------------------------------------------------------------------
 Roster Talent functions
-------------------------------------------------------------------------------------------------]]

function TalentUpdate(unitGUID, unit, spec, t1, t2, t3)
  ValidateRosterInfo(unitGUID)
  
  local unitInfo  = RosterInfo[unitGUID]
  local _, class  = UnitClass(unit)
  local name, _   = UnitName(unit)
  
  unitInfo.name       = name
  unitInfo.class      = class
  unitInfo.unitGUID   = unitGUID
  unitInfo.unit       = unit
  
  if not name or name == "Unknown" then
    C_Timer.NewTimer(5, function() TalentUpdate(unitGUID, unit, spec, t1, t2, t3) end)
    return
  end
  
  local cooldownModels = unitInfo.cooldownModels
  
  for spellId, info in pairs(TalentInfo[class]) do
    local duration = info.duration
    
    if info.tree then
      local _, _, _, _, rank, _ = LGT:GetTalentInfo(unit, info.tree, info.talent)
      
      if info.ranks[rank] then -- ranks[rank] contains the duration increase (almost always negative since it's a reduction)
        duration = duration + info.ranks[rank]
      else -- if ranks[rank] is nil then then unit doesn't have the cooldown in their spec
        duration = nil
      end
    end
    
    if duration then
      cooldownModels[spellId] = cooldownModels[spellId] or {}
    
      local model         = cooldownModels[spellId]
      local _, _, icon, _ = GetSpellInfo(spellId)
      
      model.duration      = duration
      model.spellId       = spellId
      model.icon          = icon
      model.noCombatLog   = info.noCombatLog
    end
  end
  
  -- Special case: Shaman: Bloodlust or Heroism depends on the race
  if class == "SHAMAN" then
    local _, race = UnitRace(unit) 
    
    if race == "Draenei" then
      cooldownModels[2825] = nil -- No Bloodlust on Alliance side
    else
      cooldownModels[32182] = nil -- No Heroism on Horde side
    end
  end
  
  -- Special case: Priest: Power Infusion and Pain Suppression are depending on multiple talents
  if class == "Priest" then
    local _, _, _, _, rank_Aspiration, _  = LGT:GetTalentInfo(unit, 1, 23)
    
    if rank_Aspiration == 1 then
      cooldownModels[33206].duration = 162
      cooldownModels[54521].duration = 108
    elseif rank_Aspiration == 2 then
      cooldownModels[33206].duration = 144
      cooldownModels[54521].duration = 96
    end
  end
  
  -- Special Case: Paladin tank
  if class == "PALADIN" then
    local role = LGT:GetGUIDRole(unitGUID)
    
    if role == "tank" then cooldownModels[642] = nil end
  end
  
  if class == "WARLOCK" then CheckSoulstone() end
  
  UnitAvailable(unitGUID, unit)
end

function LRC:GROUP_TALENT_UPDATE(event, unitGUID, unit, spec, t1, t2, t3)
  TalentUpdate(unitGUID, unit, spec, t1, t2, t3)
end

LGT.RegisterCallback(LRC, "LibGroupTalents_RoleChange", "GROUP_TALENT_UPDATE")

function UnitAvailable(unitGUID, unit)
  ValidateRosterInfo(unitGUID)

  local unitInfo  = RosterInfo[unitGUID]
  local models    = unitInfo.cooldownModels
  local cooldowns = unitInfo.cooldowns
  
  unitInfo.flagFound  = true
  
  for _, info in pairs(models) do
    --[[if info.available and not info.wasAvailable then
      LRC:NotifyCooldownAvailable(info)
      local spellName, _ = GetSpellInfo(info.spellId)
      print("LRC: +", info.name, spellName)
    elseif not info.available then
      LRC:NotifyCooldownUnavailable(info)
      local spellName, _ = GetSpellInfo(info.spellId)
      print("LRC: -", info.name, spellName)
    end
    
    info.wasAvailable = info.available--]]
  end
  
  for _, cooldown in pairs(cooldowns) do
    if not models[cooldown.spellId] then
      if cooldown.timer then cooldown.timer:Candel(); cooldown.timer = nil end
      
      LRC:NotifyCooldownUnavailable(cooldown)
      
      local spellName, _ = GetSpellInfo(cooldown.spellId)
      --print("LRC: -", cooldown.name, spellName)
      
      FreeAura(cooldowns, cooldown.uniqueId)
    end
  end
  
  for _, model in pairs(models) do
    local cooldown = FindCooldown(cooldowns, model.spellId)
    
    if not cooldown then
      cooldown = GetAuraTable()
  
      cooldown.blizzardIndex   = nil
      cooldown.filter          = "RAID_COOLDOWN"
      cooldown.spellId         = model.spellId
      cooldown.unit            = unitInfo.unit
      cooldown.unitName        = unitInfo.name
      cooldown.unitGUID        = unitInfo.unitGUID
      cooldown.casterUnit      = unitInfo.unit
      cooldown.casterName      = unitInfo.name
      cooldown.casterGUID      = unitInfo.unitGUID
      cooldown.name            = unitInfo.name
      cooldown.count           = 1
      cooldown.creation        = 0
      cooldown.duration        = 0
      cooldown.expirationTime  = 0
      cooldown.icon            = model.icon
      cooldown.classification  = "none"
      cooldown.isStealable     = false  
      
      LUA:AssignUniqueId(cooldown)
      
      unitInfo.cooldowns[cooldown.uniqueId] = cooldown
      
      LRC:NotifyCooldownAvailable(cooldown)
      
      local spellName, _ = GetSpellInfo(cooldown.spellId)
      --print("LRC: +", cooldown.name, spellName)
    else
      if cooldown.duration == 0 then
        LRC:NotifyCooldownAvailable(cooldown)
      else
        LRC:NotifyCooldownStarted(cooldown)
      end
    end
  end
  
  if unitInfo.unit ~= unit then
    print("LRC: Unit *unit* property changed!")
  end
end

function UnitUnavailable(unitGUID)
  ValidateRosterInfo(unitGUID)
  
  local unitInfo  = RosterInfo[unitGUID]
  local models    = unitInfo.cooldownModels
  local cooldowns = unitInfo.cooldowns
  
  for _, info in pairs(cooldowns) do
    LRC:NotifyCooldownUnavailable(info)
  end
end

--[[-----------------------------------------------------------------------------------------------
 Cooldown Starting & ending functions
-------------------------------------------------------------------------------------------------]]

local function EndCooldown(unitInfo, model, oldCooldown)
  -- Notify the cooldown is ready
  if oldCooldown.timer then oldCooldown.timer:Cancel(); oldCooldown.timer = nil end
  
  LRC:NotifyCooldownReady(oldCooldown)
  
  FreeAura(unitInfo.cooldowns, oldCooldown.uniqueId)

  -- Make the cooldown available
  local cooldown = GetAuraTable()
  
  cooldown.blizzardIndex   = nil
  cooldown.filter          = "RAID_COOLDOWN"
  cooldown.spellId         = model.spellId
  cooldown.unit            = unitInfo.unit
  cooldown.unitName        = unitInfo.name
  cooldown.unitGUID        = unitInfo.unitGUID
  cooldown.casterUnit      = unitInfo.unit
  cooldown.casterName      = unitInfo.name
  cooldown.casterGUID      = unitInfo.unitGUID
  cooldown.name            = unitInfo.name
  cooldown.count           = 1
  cooldown.creation        = 0
  cooldown.duration        = 0
  cooldown.expirationTime  = 0
  cooldown.icon            = model.icon
  cooldown.classification  = "none"
  cooldown.isStealable     = false  
  
  LUA:AssignUniqueId(cooldown)
  
  unitInfo.cooldowns[cooldown.uniqueId] = cooldown
  
  if unitInfo.flagFound then
    LRC:NotifyCooldownAvailable(cooldown)
  end
end

--[[ Note:
  duration overrides the model.duration value (usefull for special cases like Guardian Spirit)
--]]
local function StartCooldown(unitInfo, model, duration) 
  -- The cooldown was available/in progress, mark it as unavailable/ready
  for _, other in pairs(unitInfo.cooldowns) do
    if other.spellId == model.spellId then
      if other.timer then other.timer:Cancel(); other.timer = nil end
      
      if other.duration == 0 then
        LRC:NotifyCooldownUnavailable(other)
      else
        LRC:NotifyCooldownReady(other)
      end
      
      FreeAura(unitInfo.cooldowns, other.uniqueId)
    end
  end
  
  -- Start the cooldown
  local cooldown  = GetAuraTable()
  local now       = GetTime()
  
  cooldown.blizzardIndex   = nil
  cooldown.filter          = "RAID_COOLDOWN"
  cooldown.spellId         = model.spellId
  cooldown.unit            = unitInfo.unit
  cooldown.unitName        = unitInfo.name
  cooldown.unitGUID        = unitInfo.unitGUID
  cooldown.casterUnit      = unitInfo.unit
  cooldown.casterName      = unitInfo.name
  cooldown.casterGUID      = unitInfo.unitGUID
  cooldown.name            = unitInfo.name
  cooldown.count           = 1
  cooldown.creation        = now
  cooldown.duration        = duration or model.duration
  cooldown.expirationTime  = now + cooldown.duration
  cooldown.icon            = model.icon
  cooldown.classification  = "none"
  cooldown.isStealable     = false
  
  cooldown.timer           = C_Timer.NewTimer(cooldown.duration, function() EndCooldown(unitInfo, model, cooldown) end)

  LUA:AssignUniqueId(cooldown)
  
  unitInfo.cooldowns[cooldown.uniqueId] = cooldown
  
  if unitInfo.flagFound then
    LRC:NotifyCooldownStarted(cooldown)
  end
end

--[[ Note:
  when extendOnly is true then the cooldown duration cannot be lowered
--]]
local function ChangeCooldown(unitInfo, model, oldCooldown, newDuration, extendOnly)
  local now = GetTime()
  
  -- If the cooldown is available, it is not changed, it is started
  if oldCooldown.duration == 0 then
    StartCooldown(unitInfo, model, newDuration)
    return
  end
  
  -- The cooldown remaining duration is longer than the newDuration
  if extendOnly and now + newDuration <= oldCooldown.expirationTime then return end
  
  -- Start the cooldown
  local cooldown  = GetAuraTable()
  
  cooldown.blizzardIndex   = nil
  cooldown.filter          = "RAID_COOLDOWN"
  cooldown.spellId         = model.spellId
  cooldown.unit            = unitInfo.unit
  cooldown.unitName        = unitInfo.name
  cooldown.unitGUID        = unitInfo.unitGUID
  cooldown.casterUnit      = unitInfo.unit
  cooldown.casterName      = unitInfo.name
  cooldown.casterGUID      = unitInfo.unitGUID
  cooldown.name            = unitInfo.name
  cooldown.count           = 1
  cooldown.creation        = now
  cooldown.duration        = model.duration
  cooldown.expirationTime  = now + newDuration
  cooldown.icon            = model.icon
  cooldown.classification  = "none"
  cooldown.isStealable     = false
  
  cooldown.timer           = C_Timer.NewTimer(cooldown.duration, function() EndCooldown(unitInfo, model, cooldown) end)

  LUA:AssignUniqueId(cooldown)
  
  unitInfo.cooldowns[cooldown.uniqueId] = cooldown
  
  -- Change & stop the old cooldown
  if oldCooldown.timer then cooldown.timer:Cancel(); cooldown.timer = nil end
  
  if unitInfo.flagFound then
    LRC:NotifyCooldownChanged(cooldown, oldCooldown)
  end
  
  FreeAura(unitInfo.cooldowns, oldCooldown.uniqueId)
end

--[[-----------------------------------------------------------------------------------------------
 Event monitoring and Cooldown tracking
-------------------------------------------------------------------------------------------------]]

local CombatLogEventHandlers = {}

local function COMBAT_LOG_EVENT_UNFILTERED(frame, ignore, time, event, sourceGUID, sourceName, sourceFlags, targetGUID, targetName, targetFlags, ...)
  if CombatLogEventHandlers[event] then
    CombatLogEventHandlers[event](sourceGUID, sourceName, targetGUID, targetName, ...)
  end
end

CombatLogEventHandlers["SPELL_CAST_SUCCESS"] = function(sourceGUID, sourceName, targetGUID, targetName, spellId, spellName, i3, isPet)

  --[[if RosterInfo[sourceGUID] then
    print("LRC: COMBAT_LOG_EVENT: SPELL_CAST_SUCCESS", sourceName, spellName, spellId)
  end--]]
  
  local unitInfo = RosterInfo[sourceGUID]
  
  if not unitInfo then return end
  
  local models    = unitInfo.cooldownModels
  local cooldowns = unitInfo.cooldowns

  if models[spellId] and not models[spellId].noCombatLog then
    StartCooldown(unitInfo, models[spellId])
  end

  if unitInfo.class == "PALADIN" and spellId == 31884 then -- Avenging Wrath causes a 30s CD on Wall & Bubble
    local cooldownDivineProtection  = FindCooldown(unitInfo.cooldowns, 498)
    local cooldownDivineShield      = FindCooldown(unitInfo.cooldowns, 642)
    
    if cooldownDivineProtection then 
      ChangeCooldown(unitInfo, unitInfo.cooldownModels[498], cooldownDivineProtection, 30, true)
    end
    
    if cooldownDivineShield then
      ChangeCooldown(unitInfo, unitInfo.cooldownModels[642], cooldownDivineShield, 30, true)
    end
  end
  
  if unitInfo.class == "HUNTER" and spellId == 23989 then -- Readiness resets Misdirection
    local cooldown = FindCooldown(unitInfo.cooldowns, 34477)
    
    if cooldown then -- TODO: What if the cooldown was not started?
      EndCooldown(unitInfo, models[34477], cooldown)
    end
  end
  
  if unitInfo.class == "ROGUE" and spellId == 14185 then -- Preparation resets Tricks of the Trade
    local cooldown = FindCooldown(unitInfo.cooldowns, 57934)
    
    if cooldown then -- TODO: What if the cooldown was not started?
      EndCooldown(unitInfo, models[57934], cooldown)
    end
  end
  
  if unitInfo.class == "MAGE" and spellId == 11958 then -- Cold Snap resets Ice Block
    local cooldown = FindCooldown(unitInfo.cooldowns, 45438)
   
    if cooldown then -- TODO: What if the cooldown was not started?
      EndCooldown(unitInfo, models[45438], cooldown)
    end
  end
end

CombatLogEventHandlers["SPELL_RESURRECT"] = CombatLogEventHandlers["SPELL_CAST_SUCCESS"]

-- Pet and Totems
CombatLogEventHandlers["SPELL_SUMMON"] = function(sourceGUID, sourceName, targetGUID, targetName, ...)
end

-- Traps
CombatLogEventHandlers["SPELL_CREATE"] = CombatLogEventHandlers["SPELL_CAST_SUCCESS"]

-- Pet or totem died
CombatLogEventHandlers["PARTY_KILL"] = function(sourceGUID, sourceName, targetGUID, targetName, ...)
end

-- Pet or totem died
CombatLogEventHandlers["UNIT_DIED"] = function(sourceGUID, sourceName, targetGUID, targetName, ...)
end

--[[-----------------------------------------------------------------------------------------------
 Aura detection for spec detection
-------------------------------------------------------------------------------------------------]]

local AuraHandler = {}

AuraHandler["AURA_GAINED"] = function(self, aura)
  if aura.spellId == 25771 and aura.unitGUID and RosterInfo[aura.unitGUID] then -- Forbearance
    local unitInfo = RosterInfo[aura.unitGUID]
    
    local now = GetTime()
    
    local cooldownDivineProtection  = FindCooldown(unitInfo.cooldowns, 498)
    local cooldownDivineShield      = FindCooldown(unitInfo.cooldowns, 642)
    
    if cooldownDivineProtection then 
      ChangeCooldown(unitInfo, unitInfo.cooldownModels[498], cooldownDivineProtection, aura.expirationTime - now, true)
    end
    
    if cooldownDivineShield then
      ChangeCooldown(unitInfo, unitInfo.cooldownModels[642], cooldownDivineShield, aura.expirationTime - now, true)
    end
  end
  
  if aura.spellId == 47883 and aura.casterGUID and RosterInfo[aura.casterGUID] then -- Soulstone Resurrection
    local unitInfo  = RosterInfo[aura.casterGUID]
    local now       = GetTime()
    
    if unitInfo and unitInfo.cooldownModels[47883] then
      local models = unitInfo.cooldownModels
      
      local cooldown = FindCooldown(unitInfo.cooldowns, 47883)
      
      if currentSoulstoneCooldown then
        ChangeCooldown(unitInfo, models[47883], cooldown, aura.expirationTime - now)
      else
        StartCooldown(unitInfo, models[47883], aura.expirationTime - now)
      end
    end
  elseif aura.spellId == 47883 and UnitInRaid(aura.casterUnit) then -- We are detecting the soulstone upon loading, but the warlock is not yet added to the rooster
    print("LRC: Detected a Soulstone, but the warlock is not yet added to the roster")
  end
  
  if aura.casterUnit and aura.unit and UnitIsUnit(aura.casterUnit, aura.unit) and RosterInfo[aura.casterGUID] and RosterInfo[aura.casterGUID].class == "PALADIN" then
    local unitInfo = RosterInfo[aura.casterGUID] 
    local cooldown = FindCooldown(unitInfo.cooldowns, PaladinAuras)
    
    if PaladinAuras[aura.spellId] and cooldown then
      --[[if cooldown.duration == 0 then
        print("LRC: Paladin AURA!", aura.spellId)
        unitInfo.cooldownModels[31821].spellId = aura.spellId
        EndCooldown(unitInfo, unitInfo.cooldownModels[31821], cooldown)
        unitInfo.cooldownModels[31821].spellId = 31821        
      end--]]
    end
  end
end

AuraHandler["AURA_CHANGED"] = AuraHandler["AURA_GAINED"]

AuraHandler["AURA_LOST"] = function(self, aura)
  
  if aura.casterGUID and RosterInfo[aura.casterGUID] then
    -- Loosing the Tricks of the Trade buff causes its CD to start with a 30s timer (no matter the cause, triggered, canceled or expired)
    if aura.spellId == 57934 and RosterInfo[aura.casterGUID].cooldownModels[57934] then -- Tricks
      StartCooldown(RosterInfo[aura.casterGUID], RosterInfo[aura.casterGUID].cooldownModels[57934])
    end
    
    -- Loosing the Misdirection buff causes its CD to start with a 30s timer (no matter the cause, triggered, canceled or expired)
    if aura.spellId == 34477 and RosterInfo[aura.casterGUID].cooldownModels[34477] then -- Misdirection
      StartCooldown(RosterInfo[aura.casterGUID], RosterInfo[aura.casterGUID].cooldownModels[34477])
    end
    
    if aura.spellId == 47788 then -- Guardian Spirit expiring means that its cooldown gets reduced to 60s
      if aura.expirationTime <= GetTime() and aura.casterGUID and RosterInfo[aura.casterGUID] then
        local unitInfo  = RosterInfo[aura.casterGUID]
        local models    = unitInfo.cooldownModels
        
        local cooldown = FindCooldown(unitInfo.cooldowns, 47788)
        
        if not cooldown then
          -- If we don't find the cooldown, it (most likely) means that the priest talents are not known yet
          -- We know for sure that he's holy so we can safely add the "Guardian Spirit" as a coolown model
          if not models[47788] then
            models[47788] = {}
            
            local _, _, icon, _ = GetSpellInfo(47788)
      
            models[47788].duration      = TalentInfo["PRIEST"][47788].duration
            models[47788].spellId       = 47788
            models[47788].icon          = icon
          end
          StartCooldown(unitInfo, models[47788], 60)
        else
          ChangeCooldown(unitInfo, models[47788], cooldown, 60)
        end
      end
    end
  end
end

--[[-----------------------------------------------------------------------------------------------
 Soulstone
-------------------------------------------------------------------------------------------------]]

function CheckSoulstone()
  for _, unit in pairs(RaidUnits) do    
    if UnitExists(unit) then
      local i = 1
      while i > 0 do
        local name, _, _, count, debuffType, duration, expirationTime, caster, _, _, spellId = UnitBuff(unit, i)
        
        if not name then i = 0 else i = i+1 end
        
        if spellId == 47883 and expirationTime and caster then
          local unitInfo = RosterInfo[UnitGUID(caster)]
          
          if unitInfo then
            local models    = unitInfo.cooldownModels
            local cooldowns = unitInfo.cooldowns
            
            local cooldown = FindCooldown(unitInfo.cooldowns, 47883)
            local now      = GetTime()
            
            if cooldown then
              ChangeCooldown(unitInfo, models[47883], cooldown, expirationTime - now)
            else
              StartCooldown(unitInfo, models[47883], expirationTime - now)
            end
          end
        end
      end
    end
  end
end

--[[-----------------------------------------------------------------------------------------------
 Zone Change Detection
-------------------------------------------------------------------------------------------------]]

local EventHandlers = {}

--[[EventHandlers["ZONE_CHANGED_NEW_AREA"] = function()
  local _, zoneType = IsInInstance()
end--]]

--EventHandlers["PLAYER_ENTERING_WORLD"] = EventHandlers["ZONE_CHANGED_NEW_AREA"]

local function UpdateRosterAvailabilityHelper(units)
  for _, unit in pairs(units) do    
    if UnitExists(unit) and UnitIsConnected(unit) then
      local name, _   = UnitName(unit)
      local _, class  = UnitClass(unit)
      local unitGUID  = UnitGUID(unit)
      
      ValidateRosterInfo(unitGUID)
      
      local unitInfo = RosterInfo[unitGUID]
      
      if unitInfo.unit and unitInfo.unit ~= unit then
        for _, cooldown in pairs(unitInfo.cooldowns) do
          cooldown.unit       = unit
          cooldown.casterUnit = unit
        end
      end

      unitInfo.flagFound    = true

      unitInfo.name         = name
      unitInfo.unit         = unit
      unitInfo.unitGUID     = unitGUID
      unitInfo.class        = class
    end
  end
end

local function UpdateRosterAvailability()
  for _, info in pairs(RosterInfo) do info.flagFound = false end

  UpdateRosterAvailabilityHelper(RaidUnits)
  UpdateRosterAvailabilityHelper(PartyUnits)
  UpdateRosterAvailabilityHelper({"player"})

  for unitGUID, unitInfo in pairs(RosterInfo) do
    if not unitInfo.flagFound then
      UnitUnavailable(unitGUID, unitInfo.unit)
      
      unitInfo.flagWasFound = false
    elseif not unitInfo.flagWasFound then
      UnitAvailable(unitGUID, unitInfo.unit)
      
      unitInfo.flagWasFound = true
    end
  end
end

--[[ NOTE:
  Here, if a player gets removed from the raid, his cooldowns become unavailable, hence removed, but if he gets re-added to the raid, 
  we do not want to loose the info about his current ongoing cooldowns, hence the not so straightforward function
--]]

local timerUpdateRosterAvailability_1
local timerUpdateRosterAvailability_5

EventHandlers["RAID_ROSTER_UPDATE"] = function()
  if timerUpdateRosterAvailability_1 then
    timerUpdateRosterAvailability_1:Cancel()
  end
  
  timerUpdateRosterAvailability_1 = C_Timer.NewTimer(1, UpdateRosterAvailability)
  
  if timerUpdateRosterAvailability_5 then
    timerUpdateRosterAvailability_5:Cancel()
  end
  
  timerUpdateRosterAvailability_5 = C_Timer.NewTimer(5, UpdateRosterAvailability)
  --[[ NOTE:
    We delay the call to UpdateRosterAvailability() to prevent multiple calls when several related events are getting fired in a rapid succession
  --]]
end
EventHandlers["PARTY_CONVERTED_TO_RAID"]  = EventHandlers["RAID_ROSTER_UPDATE"]
EventHandlers["PARTY_MEMBERS_CHANGED"]    = EventHandlers["RAID_ROSTER_UPDATE"]
EventHandlers["GROUP_ROSTER_CHANGED"]     = EventHandlers["RAID_ROSTER_UPDATE"]
EventHandlers["PARTY_MEMBER_ENABLE"]      = EventHandlers["RAID_ROSTER_UPDATE"]
EventHandlers["PARTY_MEMBER_DISABLE"]     = EventHandlers["RAID_ROSTER_UPDATE"]
EventHandlers["READY_CHECK"]              = EventHandlers["RAID_ROSTER_UPDATE"]

EventHandlers["PLAYER_TALENT_UPDATE"] = function()
  local unitGUID = UnitGUID("player")
  
  if unitGUID then
    TalentUpdate(unitGUID, "player")
  end
end

--[[-----------------------------------------------------------------------------------------------
 Functionality
-------------------------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------------------------
 Interface
-------------------------------------------------------------------------------------------------]]

LRC.listeners = {}

function LRC:Register(listener)
  if not listener then return end

  if not listener.RAID_COOLDOWN_READY or not listener.RAID_COOLDOWN_CHANGED or not listener.RAID_COOLDOWN_STARTED or not listener.RAID_COOLDOWN_AVAILABLE or not listener.RAID_COOLDOWN_UNAVAILABLE then
    print("LibRaidCooldowns: Tried to register an object, but it misses at least one of the following methods:")
    print("RAID_COOLDOWN_READY, RAID_COOLDOWN_CHANGED, RAID_COOLDOWN_STARTED, RAID_COOLDOWN_AVAILABLE or RAID_COOLDOWN_UNAVAILABLE")
    return
  end

  if not self.listeners[listener] then
    self.listeners[listener] = true

    for _, unitInfo in pairs(RosterInfo) do
      if unitInfo.flagFound then
        for _, cooldown in pairs(unitInfo.cooldowns) do
          if cooldown.duration == 0 then
            listener:RAID_COOLDOWN_AVAILABLE(cooldown)
          else
            listener:RAID_COOLDOWN_STARTED(cooldown)
          end
        end
      end
    end
  end
  
  local count = 0
  
  for _, _ in pairs(self.listeners) do count = count + 1 end
  
  if count > 0 then 
    CombatLogEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    for event, _ in pairs(EventHandlers) do EventFrame:RegisterEvent(event) end
    
    for _, unit in pairs(RaidUnits) do LUA:Register(AuraHandler, unit) end
    for _, unit in pairs(PartyUnits) do LUA:Register(AuraHandler, unit) end
    for _, unit in pairs({"player"}) do LUA:Register(AuraHandler, unit) end
  end
end

function LRC:Unregister(listener)
  self.listeners[listener] = nil
  
  local count = 0
  
  for _, _ in pairs(self.listeners) do count = count + 1 end
  
  if count == 0 then
    --[[CombatLogEventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    for event, _ in pairs(EventHandlers) do EventFrame:UnregisterEvent(event) end
    
    for _, unit in pairs(RaidUnits) do LUA:Unregister(AuraHandler, unit) end
    for _, unit in pairs(PartyUnits) do LUA:Unregister(AuraHandler, unit) end
    for _, unit in pairs({"player"}) do LUA:Unregister(AuraHandler, unit) end--]]
  end
end

function LRC:NotifyCooldownReady(cooldown)      
  for listener, _ in pairs(self.listeners) do
    listener:RAID_COOLDOWN_READY(cooldown)
  end
end

function LRC:NotifyCooldownStarted(cooldown)  
  for listener, _ in pairs(self.listeners) do
    listener:RAID_COOLDOWN_STARTED(cooldown)
  end
end

function LRC:NotifyCooldownChanged(cooldown, oldCooldown)
  for listener, _ in pairs(self.listeners) do
    listener:RAID_COOLDOWN_CHANGED(cooldown, oldCooldown)
  end
end

function LRC:NotifyCooldownAvailable(cooldown)  
  for listener, _ in pairs(self.listeners) do
    listener:RAID_COOLDOWN_AVAILABLE(cooldown)
  end
end

function LRC:NotifyCooldownUnavailable(cooldown)  
  for listener, _ in pairs(self.listeners) do
    listener:RAID_COOLDOWN_UNAVAILABLE(cooldown)
  end
end

--[[-----------------------------------------------------------------------------------------------
 Setup goes last
-------------------------------------------------------------------------------------------------]]

EventFrame = CreateFrame("FRAME")

do
  local function OnEvent(frame, event, ...)
    EventHandlers[event](...)
  end

  EventFrame:SetScript("OnEvent", OnEvent)
end

CombatLogEventFrame = CreateFrame("FRAME")

do
  local function OnEvent(...)
    COMBAT_LOG_EVENT_UNFILTERED(...)
  end
  
  CombatLogEventFrame:SetScript("OnEvent", OnEvent)
end
