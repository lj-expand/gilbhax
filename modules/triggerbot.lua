local triggerbot = {}
local config = lje.require("config/triggerbot.lua")
triggerbot.locked = false

function triggerbot.run(cmd, target)
    if not config.enabled then return end

    local eyeTraceData = {
        start = LocalPlayer():EyePos(),
        endpos = LocalPlayer():EyePos() + (LocalPlayer():GetAimVector() * 32768),
        filter = LocalPlayer(),
        mask = MASK_SHOT_HULL
    }

    local eyeTrace = util.TraceLine(eyeTraceData)
    if eyeTrace.Hit and eyeTrace.Entity == target then
        cmd:AddKey(IN_ATTACK)
        triggerbot.locked = true
    else
        triggerbot.locked = false
    end
end

return triggerbot