local Major, Minor = "LibUnitAura", 11
local Lib, OldMinor = LibStub:NewLibrary(Major, Minor)

if not Lib then return end

Lib.auras = Lib.auras or {}

--[[-----------------------------------------------------------------------------------------------
 Constants
-------------------------------------------------------------------------------------------------]]

local AllowedFilter = {["HELPFUL"] = true, ["HARMFUL"] = true}

local Events = {
  ["UNIT_AURA"] = {
    units = {
      ["player"]        = true,
      ["playertarget"]  = true,
      ["pet"]           = true,
      ["pettarget"]     = true,
      ["target"]        = true,
      ["targettarget"]  = true,
      ["focus"]         = true,
      ["focustarget"]   = true,
      ["vehicle"]       = true,
      ["vehicletarget"] = true,
    }
  },
  ["PLAYER_TARGET_CHANGED"] = {
    units = {
      ["player"]        = true,
      ["playertarget"]  = true,
    }
  },
  ["PLAYER_FOCUS_CHANGED"] = {
    units = {
      ["focus"]       = true,
      ["focustarget"] = true,
    }
  },
  ["PLAYER_ALIVE"] = {
    units = {
      ["player"] = true,
    }
  },
  ["PLAYER_DEAD"] = {
    units = {
      ["player"] = true,
    }
  },
  ["PLAYER_UNGHOST"] = {
    units = {
      ["player"] = true,
    }
  },
  ["UNIT_TARGET"] = {
    units = {
      ["pettarget"]     = true,
      ["targettarget"]  = true,
      ["focustarget"]   = true,
      ["vehicletarget"] = true,
    }
  },
  ["UNIT_PET"] = {
    units = {
      ["pet"]        = true,
      ["pettarget"]  = true,
    }
  },
  ["UNIT_ENTERED_VEHICLE"] = {
     units = {
      ["player"] = true,
      ["vehicle"]        = true,
      ["vehicletarget"]  = true,
     }
  },
  ["UNIT_EXITED_VEHICLE"] = {
    units = {
      ["player"] = true,
      ["vehicle"]        = true,
      ["vehicletarget"]  = true,
    },
  },
  ["PARTY_MEMBERS_CHANGED"] = {
    units = {}
  },
  ["ARENA_OPPONENT_UPDATE"] = {
    units = {}
  },
  ["RAID_ROSTER_UPDATE"] = {
    units = {}
  },
}

for i = 1, 4 do
  Events["UNIT_AURA"].units["party"..i] = true
  Events["UNIT_AURA"].units["party"..i .. "target"] = true
  Events["UNIT_AURA"].units["party"..i .. "pet"] = true

  Events["PARTY_MEMBERS_CHANGED"].units["party"..i] = true
  Events["PARTY_MEMBERS_CHANGED"].units["party"..i.."target"] = true
  Events["PARTY_MEMBERS_CHANGED"].units["party"..i.."pet"] = true

  Events["UNIT_TARGET"].units["party"..i.."target"] = true
  Events["UNIT_TARGET"].units["arena"..i.."target"] = true

  Events["UNIT_PET"].units["party"..i.."pet"] = true

  Events["ARENA_OPPONENT_UPDATE"].units["arena"..i] = true
  Events["ARENA_OPPONENT_UPDATE"].units["arena"..i.."target"] = true
end

for i = 1, 40 do
  Events["UNIT_AURA"].units["raid"..i] = true
  Events["UNIT_AURA"].units["raid"..i .. "target"] = true
  Events["UNIT_AURA"].units["raidpet"..i] = true

  Events["RAID_ROSTER_UPDATE"].units["raid"..i] = true
  Events["RAID_ROSTER_UPDATE"].units["raid"..i.."target"] = true
  Events["RAID_ROSTER_UPDATE"].units["raidpet"..i] = true

  Events["UNIT_PET"].units["raidpet"..i] = true
end

--[[-----------------------------------------------------------------------------------------------
 Interface
-------------------------------------------------------------------------------------------------]]

function Lib:Register(object, unit, filter)
  if not object then return end

  if not object.AURA_GAINED or not object.AURA_CHANGED or not object.AURA_LOST then
    print("LibUnitAura: Tried to register an object, but it misses at least one of the following methods:")
    print("AURA_GAINED, AURA_CHANGED or AURA_LOST")
    return
  end

  if not unit then return end

  if not filter then
    self:Register(object, unit, "HELPFUL")
    self:Register(object, unit, "HARMFUL")
    return
  end

  if not AllowedFilter[filter] then return end

  self.listeners = self.listeners or {}
  self.listeners[object] = self.listeners[object] or {}
  self.listeners[object][unit] = self.listeners[object][unit] or {}
  self.listeners[object][unit][filter] = true

  if not self.units or not self.units[unit] or not self.units[unit][filter] then
    self:UpdateEvents()
    self:ScanUnit(unit, filter)
  else
    self:UpdateEvents()

    for _, aura in ipairs(self.auras[unit][filter]) do
      object:AURA_GAINED(aura)
    end
  end
end

function Lib:Unregister(object, unit, filter)
  if not unit then
    self:UnregisterAll(object)
    return
  end

  if not filter then
    self:Unregister(object, unit, "HELPFUL")
    self:Unregister(object, unit, "HARMFUL")
    return
  end

  if not AllowedFilter[filter] then return end

  self.listeners = self.listeners or {}
  if not self.listeners[object] then return end
  if not self.listeners[object][unit] then return end
  self.listeners[object][unit][filter] = nil

  if not self.listeners[object][unit]["HELPFUL"] and not self.listeners[object][unit]["HARMFUL"] then
    self.listeners[object][unit] = nil
  end

  local anyUnit = false
  for k,_ in pairs(self.listeners[object]) do
    anyUnit = true
  end

  if not anyUnit then
    self.listeners[object] = nil
  end

  self:UpdateEvents()
end

function Lib:UnregisterAll(object)
  self.listeners = self.listeners or {}
  self.listeners[object] = nil

  self:UpdateEvents()
end

function Lib:Feed(object, unit, filter)
  if not self.listeners[object] then return end

  if not unit then
    for unit, _ in pairs(self.listeners[object]) do
      self:Feed(object, unit, filter)
    end
    return
  end

  if not self.listeners[object][unit] then return end

  if not filter then
    if self.listeners[object][unit]["HELPFUL"] then
      self:Feed(object, unit, "HELPFUL")
    end

    if self.listeners[object][unit]["HARMFUL"] then
      self:Feed(object, unit, "HARMFUL")
    end

    return
  end

  if not self.units or not self.units[unit] or not self.units[unit][filter] then
    self:ScanUnit(unit, filter)
  else
    for _, aura in ipairs(self.auras[unit][filter]) do
      object:AURA_GAINED(aura)
    end
  end
end

--[[-----------------------------------------------------------------------------------------------
 Functionality
-------------------------------------------------------------------------------------------------]]

local function OnEvent(frame, event, ...)
  Lib[event](Lib, ...)
end

Lib.eventFrame = Lib.eventFrame or CreateFrame("frame")

Lib.eventFrame:SetScript("OnEvent", OnEvent)
Lib.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
Lib.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

function Lib:UpdateEvents()
  self.units = {}

  for _, info in pairs(self.listeners) do
    for unit, unitInfo in pairs(info) do
      self.units[unit] =  self.units[unit] or {}
      self.units[unit]["HELPFUL"] = self.units[unit]["HELPFUL"] or unitInfo["HELPFUL"]
      self.units[unit]["HARMFUL"] = self.units[unit]["HARMFUL"] or unitInfo["HARMFUL"]

      self.auras[unit] = self.auras[unit] or {}
      self.auras[unit]["HELPFUL"] = self.auras[unit]["HELPFUL"] or {}
      self.auras[unit]["HARMFUL"] = self.auras[unit]["HARMFUL"] or {}
    end
  end

  for event, info in pairs(Events) do
    local anyFound = false
    for unit, _ in pairs(info.units) do
      anyFound = anyFound or self.units[unit]
    end

    if anyFound then
      self.eventFrame:RegisterEvent(event)
    else
      self.eventFrame:UnregisterEvent(event)
    end
  end
end

--[[-----------------------------------------------------------------------------------------------
 Table pooling
-------------------------------------------------------------------------------------------------]]

-- Imported Globals
local table_insert = table.insert
local table_remove = table.remove

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

local function FreeAuraTable(auraList, index)
  if index then
    table_insert(AuraTablePool, table_remove(auraList, index))
  else while #auraList > 0 do
    table_insert(AuraTablePool, table_remove(auraList, #auraList))
  end end
end

--[[-----------------------------------------------------------------------------------------------
 Events
-------------------------------------------------------------------------------------------------]]

function Lib:UNIT_AURA(unit)
  self:ScanUnit(unit);
end

function Lib:PARTY_MEMBERS_CHANGED()
  for i = 1, 4 do
    self:ScanUnit("party"..i);
    self:ScanUnit("party"..i.."pet");
    self:ScanUnit("party"..i.."target");
  end
end

function Lib:PLAYER_FOCUS_CHANGED()
  self:ScanUnit("focus");
  self:ScanUnit("focustarget");
end

function Lib:PLAYER_TARGET_CHANGED()
  self:ScanUnit("target");
  self:ScanUnit("targettarget");
end

function Lib:PLAYER_ALIVE()
  --print("PLAYER_ALIVE")
  self:ScanUnit("player")
end

function Lib:PLAYER_DEAD()
  --print("PLAYER_DEAD")
  self:ScanUnit("player")
end

function Lib:PLAYER_UNGHOST()
  --print("PLAYER_UNGHOST")
  self:ScanUnit("player")
end

function Lib:RAID_ROSTER_UPDATE()
  for i = 1, 40 do
    self:ScanUnit("raid"..i);
    self:ScanUnit("raid"..i.."pet");
    self:ScanUnit("raid"..i.."target");
  end
end

function Lib:UNIT_ENTERED_VEHICLE(unit)
  if UnitIsUnit(unit, "player") then
    self:ScanUnit("vehicle")
    self:ScanUnit("player")
  end
end

function Lib:UNIT_EXITED_VEHICLE(unit)
  if UnitIsUnit(unit, "player") then
    -- Wiping all the vehicle auras
    if self.units["vehicle"] then
      local vehicle = self.auras["vehicle"]
      -- Helpful auras
      if self.units["vehicle"]["HELPFUL"] then
        for _, aura in ipairs(vehicle["HELPFUL"]) do
          self:FireAuraLostEvent(aura.unit, "HELPFUL", aura)
        end
        FreeAuraTable(vehicle["HELPFUL"])
      end
      -- Harmful auras
      if self.units["vehicle"]["HARMFUL"] then
        for _, aura in ipairs(vehicle["HARMFUL"]) do
          self:FireAuraLostEvent(aura.unit, "HARMFUL", aura)
        end
        FreeAuraTable(vehicle["HARMFUL"])
      end
      -- Safeguard, who knows?
      if UnitExists("vehicle") then self:ScanUnit("vehicle") end
    end
    self:ScanUnit("player")
  end
end

function Lib:UNIT_PET(unit)
  self:ScanUnit(unit.."pet")
end

function Lib:UNIT_TARGET(unit)
  self:ScanUnit(unit.."target")
end

function Lib:UPDATE_MOUSEOVER_UNIT()
  self:ScanUnit("mouseover")
end

function Lib:PLAYER_ENTERING_WORLD()
  self:ScanAllUnits()
end

function Lib:ZONE_CHANGED()
  self:ScanAllUnits()
end

function Lib:ZONE_CHANGED_NEW_AREA()
  self:ScanAllUnits()
end

function Lib:ARENA_OPPONENT_UPDATE()
  for i = 1, 5 do
    self:ScanUnit("arena"..i)
    self:ScanUnit("arena"..i.."pet")
    self:ScanUnit("arena"..i.."target")
  end
end


--[[-----------------------------------------------------------------------------------------------
 Scans
-------------------------------------------------------------------------------------------------]]

function Lib:PLAYER_REGEN_DISABLED()
end

function Lib:PLAYER_REGEN_ENABLED()
end

function Lib:GetUnitAuras(unit, filter)
  if self.units[unit] and self.units[unit][filter] then
    return self.auras[unit][filter]
  end
end

function Lib:ScanAllUnits()
  for unit, _ in pairs(self.units) do
    self:ScanUnit(unit)
  end
end

function Lib:ScanUnit(unit, filter)
  if not unit then return end

  if not filter then
     if self.units[unit] and self.units[unit]["HELPFUL"] then
       self:ScanUnit(unit, "HELPFUL")
     end

     if self.units[unit] and self.units[unit]["HARMFUL"] then
       self:ScanUnit(unit, "HARMFUL")
     end

     return
  end

  if not AllowedFilter[filter] then return end

  local oldAuras = self.auras[unit][filter]
  local newAuras = {}

  local i = 1
  while true do
    local name, _, icon, count, classification, duration, expirationTime, casterUnit, isStealable, _, spellId = UnitAura(unit, i, filter)

    if not name then break end

    local aura = GetAuraTable()
    table_insert(newAuras, aura)

    aura.blizzardIndex   = i
    aura.filter          = filter
    aura.spellId         = spellId
    aura.unit            = unit
    aura.unitName        = UnitName(unit)
    aura.unitGUID        = UnitGUID(unit)
    aura.casterUnit      = casterUnit
    aura.casterName      = nil
    aura.casterGUID      = nil
    aura.name            = name
    aura.count           = count
    aura.creation        = nil
    aura.duration        = duration or 0
    aura.expirationTime  = expirationTime
    aura.icon            = icon
    aura.classification  = classification or "none"
    aura.isStealable     = IsStealable == 1 and true or false

    if casterUnit then aura.casterName = UnitName(casterUnit) end
    if casterUnit then aura.casterGUID = UnitGUID(casterUnit) end

    if duration and expirationTime then aura.creation =  expirationTime - duration end

    if aura.classification == "" then aura.classification = "none" end

    i = i + 1
  end

  --self:ConsolidateDuplicates(newAuras)
  self:FireEvents(unit, filter, oldAuras, newAuras)
end

-- The assumption that new buffs are added to the end of the blizzard buff list is wrong.
--[[function Lib:ScanUnitChanges(unit, filter)
  if not unit then return end

  if not filter then
     if self.units[unit]["HELPFUL"] then
       self:ScanUnitChanges(unit, "HELPFUL")
       return
     end

     if self.units[unit]["HARMFUL"] then
       self:ScanUnitChanges(unit, "HARMFUL")
       return
     end
  end

  if not AllowedFilter[filter] then return end

  self.auras = self.auras or {}
  self.auras[unit] = self.auras[unit] or {}
  self.auras[unit][filter] = self.auras[unit][filter] or {}

  local oldAuras = self.auras[unit][filter]
  local newAuras = {}

  local ii = 1
  while true do
    local name, _ = UnitAura(unit, ii, filter)

    if not name then break end

    print("Index:", ii, "aura:", name)

    ii = ii + 1
  end

  local i = #oldAuras
  while i > 0 do -- We find the minimun of (index of the end of the blizzard aura list, index of the end of oldAuras)
    local name, _ = UnitAura(unit, i, filter)

    if not name then
      i = i - 1
    else
      break
    end
  end

  while i > 0 do -- We find the maximun index where the blizzard aura list and the oldAuras list match
    local name, _, _, _, _, _, _, casterUnit, _, _, spellId = UnitAura(unit, i, filter)

    if oldAuras[i].spellId ~= spellId or (oldAuras[i].casterGUID and not casterUnit) or (casterUnit and oldAuras[i].casterGUID ~= UnitGUID(casterUnit)) then
      i = i - 1
    else
      break
    end
  end

  i = i + 1
  print("Reached index:", i)

  local startIndex = i

  while true do -- All the aura past this index are different
    local name, _, icon, count, classification, duration, expirationTime, casterUnit, isStealable, _, spellId = UnitAura(unit, i, filter)

    if not name then break end

    table.insert(newAuras, {
      spellId         = spellId,
      unit            = unit,
      unitName        = UnitName(unit),
      casterUnit      = casterUnit,
      casterName      = casterUnit and UnitName(casterUnit) or "",
      name            = name,
      count           = count or 1,
      duration        = duration or 0,
      expirationTime  = expirationTime,
      icon            = icon,
      classification  = classification or "none",
      isStealable     = IsStealable == 1 and true or false,
    })

    if duration and expirationTime then
      newAuras[#newAuras].creation =  expirationTime - duration
    end

    if casterUnit then
      newAuras[#newAuras].casterGUID = UnitGUID(casterUnit)
    end

    i = i + 1
  end

  self:ConsolidateDuplicates(newAuras)
  self:FireEvents(unit, filter, oldAuras, newAuras, startIndex)
end--]]

-- Maybe we sort using some order before consolidation
function Lib:ConsolidateDuplicates(auras)
  local i = 1
  while i < #auras do
    local j = i + 1

    while j <= #auras do
      if auras[i].spellId == auras[j].spellId  and (not auras[i].casterGUID and not auras[j].casterGUID or auras[i].casterGUID == auras[j].casterGUID) then
        auras[i].count = auras[i].count + 1
        FreeAuraTable(auras, j)
      else
        j = j + 1
      end
    end

    i = i + 1
  end
end

function Lib:CompareAura(unit, filter, oldAura, newAura)
  if oldAura.spellId ~= newAura.spellId then return false end
  if oldAura.unitGUID ~= newAura.unitGUID then return false end

  if (oldAura.casterGUID or newAura.casterGUID) and oldAura.casterGUID ~= newAura.casterGUID then return false end

  -- The aura are the same, therefore the newAura uniqueId is the oldAura uniqueId
  newAura.uniqueId = oldAura.uniqueId
  
  if newAura.name ~= oldAura.name then
    print("Assigning same uniqueID but name differ!", newAura.name, oldAura.name)
  end

  if oldAura.count ~= newAura.count or oldAura.expirationTime ~= newAura.expirationTime or oldAura.blizzardIndex ~= newAura.blizzardIndex then
    self:FireAuraChangedEvent(unit, filter, newAura, oldAura)
  end

  return true
end

function Lib:FireEvents(unit, filter, oldAuras, newAuras)
  local oldIndex = 1
  local newIndex = 1

  while true do
    local i, j = oldIndex, newIndex

    if not oldAuras[i] or not newAuras[j] then break end

    if self:CompareAura(unit, filter, oldAuras[i], newAuras[j]) then
      oldIndex = oldIndex + 1
      newIndex = newIndex + 1
    else
      local found = false
      while i < #oldAuras and not found do
        i = i + 1

        if self:CompareAura(unit, filter,oldAuras[i], newAuras[j]) then
          found = true
          FreeAuraTable(oldAuras, i)
        end
      end

      if not found then
        self:FireAuraGainedEvent(unit, filter, newAuras[j])
      end

      newIndex = newIndex + 1
    end
  end

  while oldIndex <= #oldAuras do
    self:FireAuraLostEvent(unit, filter, oldAuras[oldIndex])
    oldIndex = oldIndex + 1
  end

  while newIndex <= #newAuras do
    self:FireAuraGainedEvent(unit, filter, newAuras[newIndex])
    newIndex = newIndex + 1
  end

  FreeAuraTable(self.auras[unit][filter])
  self.auras[unit][filter] = newAuras
end

local UniqueIdCounter = 0
function Lib:AssignUniqueId(aura)
  UniqueIdCounter = UniqueIdCounter + 1
  aura.uniqueId   = UniqueIdCounter
end

function Lib:FireAuraGainedEvent(unit, filter, aura)
  self:AssignUniqueId(aura)

  for listener, info in pairs(self.listeners) do
    if info[unit] and info[unit][filter] then
      listener:AURA_GAINED(aura)
    end
  end
end

function Lib:FireAuraChangedEvent(unit, filter, aura, oldAura)
  for listener, info in pairs(self.listeners) do
    if info[unit] and info[unit][filter] then
      listener:AURA_CHANGED(aura, oldAura)
    end
  end
end

function Lib:FireAuraLostEvent(unit, filter, aura)
  for listener, info in pairs(self.listeners) do
    if info[unit] and info[unit][filter] then
      listener:AURA_LOST(aura)
    end
  end
end

--[[-----------------------------------------------------------------------------------------------
 COMBAT_LOG_EVENT_UNFILTERED
-------------------------------------------------------------------------------------------------]]
local CombatLogEvents = {}

-- TODO: Keep a table GUID > blizzUnit
-- TODO: keep a table GUID > Auras
-- TODO: Implement a OnUpdate loop that will try to find the aura marked for updates

--[[function Lib:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, targetGUID, targetName, targetFlags, ...)
  if CombatLogEvents[event] then
    CombatLogEvents[event](self, timestamp, sourceName, sourceGUID, sourceFlags, targetNamen targetGUID, targetFlags, ...)
  end
end

function CombatLogEvents.SPELL_AURA_APPLIED(self, time, sGUID, sName, sFlags, tGUID, tName, tFlags, spellId, spellName, spellSchool, auraType)
  local blizzUnit = GetBlizzUnitFromGUID(tGUID)

  if not blizzUnit or not IsUnitTracked(blizzUnit) then
    return
  else
    MarkForUpdate(blizzUnit, sGUID, tGUID, spId, auraType)
  end
end

function CombatLogEvents.SPELL_AURA_REFRESH(self, timestamp, sGUID, sName, sFlags, tGUID, tName, tFlags, spId, spName, spSchool, auraType)
  local blizzUnit = GetBlizzUnitFromGUID(tGUID)

  if not blizzUnit or not IsUnitTracked(blizzUnit) then
    local IncompleteAura = FromPool("IncompleteAura")

    IncompleteAura.unitName   = tName
    IncompleteAura.unitGUID   = tGUID
    IncompleteAura.caster     = GetBlizzUnitFromGUID(sGUID)
    IncompleteAura.casterName = sName
    IncompleteAura.casterGUID = sGUID
    IncompleteAura.spellId    = spId
    IncompleteAura.name       = spName
    IncompleteAura.filter     = (auraType == "BUFF" and "HELPFUL") or (auraType == "DEBUFF" and "HARMFUL")

    FireIncompleteAuraChanged(IncompleteAura)
  else
    MarkForUpdate(blizzUnit, sGUID, tGUID, spId, auraType)
  end
end

function CombatLogEvents.SPELL_AURA_REMOVED(self, time, sGUID, sName, sFlags, tGUID, tName, tFlags, spId, spName, spSchool, auraType)
  local blizzUnit = GetBlizzUnitFromGUID(tGUID)

  if not blizzUnit or not IsUnitTracked(blizzUnit) then
    local IncompleteAura = FromPool("IncompleteAura")

    IncompleteAura.unitName   = tName
    IncompleteAura.unitGUID   = tGUID
    IncompleteAura.spellId    = spId
    IncompleteAura.name       = spName
    IncompleteAura.filter     = (auraType == "BUFF" and "HELPFUL") or (auraType == "DEBUFF" and "HARMFUL")

    FireIncompleteAuraRemoved(IncompleteAura)
  else
    local Aura = FromBlizzUnit(blizzUnit, sGUID, tGUID, spId, auraType)

    if Aura then
      FireAuraLost(Aura)
    else
      -- ?! the aura got removed from a tracked blizz unit but we couldn't find it?
    end
  end
end

function CombatLogEvents.SPELL_AURA_BROKEN        = CombatLogEvents.SPELL_AURA_REMOVED
function CombatLogEvents.SPELL_AURA_BROKEN_SPELL  = CombatLogEvents.SPELL_AURA_REMOVED

function CombatLogEvents.SPELL_AURA_APPLIED_DOSE  = CombatLogEvents.SPELL_AURA_REFRESH
function CombatLogEvents.SPELL_AURA_REMOVED_DOSE  = CombatLogEvents.SPELL_AURA_REFRESH

function Lib.CombatLogEvents.SPELL_AURA_STOLEN(self, timestamp, sGUID, sName, sFlags, tGUID, tName, tFlags, spId, spName, spSchool, eSpId, eSpName, eSpSchool, auraType)
  CombatLogEvents.SPELL_AURA_APPLIED(self, timestamp, sGUID, sName, sFlags, sGUID, sName, sFlags, spId, spName, spSchool, auraType)
  CombatLogEvents.SPELL_AURA_REMOVED(self, timestamp, sGUID, sName, sFlags, tGUID, tName, tFlags, spId, spName, spSchool, auraType)
end

function Lib.CombatLogEvents.SPELL_DISPEL(self, timestamp, sGUID, sName, sFlags, tGUID, tName, tFlags, spId, spName, spSchool, eSpId, eSpName, eSpSchool, auraType)
  CombatLogEvents.SPELL_AURA_REMOVED(self, timestamp, sGUID, sName, sFlags, tGUID, tName, tFlags, spId, spName, spSchool, auraType)
end

function Lib.CombatLogEvents.UNIT_DIED(self, ...)
end

function Lib.CombatLogEvents.UNIT_DESTROYED(self, ...)
end--]]
