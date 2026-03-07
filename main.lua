-- Hooks are always disabled during the execution of this script.
-- They re-enable as soon as this script finishes.

lje = lje or {}
local aimbot = lje.include("modules/aimbot.lua")
local esp = lje.include("modules/esp.lua")
local screengrab = lje.require("detours/screengrab.lua")
local bhop = lje.include("modules/bhop.lua")
local freecam = lje.include("modules/freecam.lua")
local triggerbot = lje.include("modules/triggerbot.lua")

hook.pre("ljeutil/render", "gilbhax.ui", function()
    lje.gc.begin_track()
    cam.Start2D()
    render.PushRenderTarget(lje.util.rendertarget)
        surface.SetFont("ChatFont")
        surface.SetTextPos(10, 10)
        surface.SetTextColor(100, 255, 100, 255)
        surface.DrawText("GILBHAX")

        local curY = 30
        if aimbot.target then
            surface.SetTextPos(10, curY)
            surface.DrawText("Aimbot Target: " .. aimbot.target:Nick())
            curY = curY + 20
        end

        if screengrab.is_screengrab_recent() then
            surface.SetTextPos(10, curY)
            surface.SetTextColor(255, math.sin(SysTime() * 15) * 127 + 128, 0, 255)
            surface.DrawText(string.format("Screengrabbed %.1f seconds ago!", screengrab.get_time_since_last_screengrab()))
            curY = curY + 20
        end

        if freecam.is_freecam_active() then
            surface.SetTextPos(10, curY)
            surface.SetTextColor(255, 0, 255, 255)
            surface.DrawText("Freecam Active")
            curY = curY + 20
        end

        surface.SetTextPos(10, curY)
        surface.SetTextColor(0, 255, 0, 255)
        surface.DrawText(string.format("GC Memory: %d B", lje.gc.get_total()))
        curY = curY + 20

        esp.run()
        
        -- Display a little red circular outline if triggerbot is locking
        if triggerbot.locked then
            surface.DrawCircle(ScrW() / 2, ScrH() / 2, 15, 255, 0, 0, 255)
        end
    
    render.PopRenderTarget()
    cam.End2D()
    lje.gc.end_track()
end)

hook.pre("CreateMove", "gilbhax.bhop", function(cmd)
    lje.gc.begin_track()
    if input.WasKeyPressed(KEY_P) then
        freecam.toggle()
    end
    
    bhop.run(cmd)
    aimbot.run(cmd)
    triggerbot.run(cmd, aimbot.target)
    lje.gc.end_track()
end)

lje.con_printf("$green{GILBHAX} initialized successfully!")