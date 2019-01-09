local MAJOR, MINOR = "C_Timer", 1
local C_Timer, _ = LibStub:NewLibrary(MAJOR, MINOR)

if not C_Timer then return end

C_Timer.timers = C_Timer.timers or {}

local frame = CreateFrame("FRAME")

frame:SetScript("OnUpdate", function()
  local time = GetTime()

  -- Fires & Remove expired & canceled
  for k,v in pairs(C_Timer.timers) do
    if v.next <= time then
      v._callback()
      v.next = v.next + v.duration
      if v._remainingIteration then
        v._remainingIteration = v._remainingIteration - 1
      end
    end

    if v._remainingIteration and v._remainingIteration <= 0 or v._canceled then
      table.remove(C_Timer.timers, k)
    end
  end
end)

function C_Timer.NewTicker(duration, callback, iteration)
  local timer = {
    _callback = callback,
    _remainingIteration = iteration,
    _canceled = false,
    duration = duration,
    next = GetTime() + duration
  }

  timer.Cancel = function(self)
    self._canceled = true
  end

  table.insert(C_Timer.timers, timer)

  return timer
end

function C_Timer.NewTimer(duration, callback)
  return C_Timer.NewTicker(duration, callback, 1)
end
