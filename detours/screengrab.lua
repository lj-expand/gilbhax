-- Hooks render.Capture to determine if anyone is trying to take a screenshot

local screengrab = {}
local origCapture = render.Capture

screengrab.last_screengrab_time = 0
screengrab.threshold = 10 -- seconds

function screengrab.is_screengrab_recent()
  return (SysTime() - screengrab.last_screengrab_time) <= screengrab.threshold
end

function screengrab.get_time_since_last_screengrab()
  return SysTime() - screengrab.last_screengrab_time
end

local function captureHk(tbl)
  screengrab.last_screengrab_time = os.clock()
  return origCapture(tbl)
end

_G.render.Capture = lje.detour(origCapture, captureHk)

return screengrab
