local players = lje.require("util/players.lua")
local esp = {}
esp.max_distance = 1000 -- in units
esp.player_mat = Material("models/shiny")
esp.studiorender_flags = bit.bor(STUDIO_RENDER, STUDIO_NOSHADOWS, STUDIO_STATIC_LIGHTING)

local function getScreenBounds(ply)
    local mins, maxs = ply:OBBMins(), ply:OBBMaxs()
    
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    
    -- Project all 8 corners
    for i = 0, 7 do
        local corner = Vector(
            bit.band(i, 1) == 0 and mins[1] or maxs[1],
            bit.band(i, 2) == 0 and mins[2] or maxs[2],
            bit.band(i, 4) == 0 and mins[3] or maxs[3]
        )
        
        local screen = ply:LocalToWorld(corner):ToScreen()
        
        if screen.visible then
            minX = math.min(minX, screen.x)
            minY = math.min(minY, screen.y)
            maxX = math.max(maxX, screen.x)
            maxY = math.max(maxY, screen.y)
        end
    end
    
    return minX, minY, maxX, maxY
end


function esp.run()
    for _, ply in ipairs(players.getOthers()) do
        local hitboxBoneId = ply:GetHitBoxBone(0, 0)
        local plyPos = ply:GetPos()
        if hitboxBoneId then
            plyPos = ply:GetBonePosition(hitboxBoneId)
        end

        -- Same check for error models, if its equal to their origin, we have no bones, so lift it
        if plyPos == ply:GetPos() then
            plyPos = ply:GetPos() + Vector(0, 0, 50)
        end
        
        local localMin, localMax = ply:OBBMins(), ply:OBBMaxs()
        local x1, y1, x2, y2 = getScreenBounds(ply)

        cam.Start({type = "3D"})
            render.DrawWireframeBox(
                ply:GetPos(),
                Angle(0, 0, 0),
                localMin,
                localMax,
                Color(0, 255, 0, 100),
                false
            )

            render.SuppressEngineLighting(true)
            render.MaterialOverride(esp.player_mat)
            local oldR, oldG, oldB = render.GetColorModulation()
            local r = LocalPlayer():GetPos():Distance(ply:GetPos()) / esp.max_distance
            render.SetColorModulation(1 - (r * r * r), 1, 0)
            lje.util.safe_draw_model(ply, esp.studiorender_flags)
            render.MaterialOverride(nil)
            render.SetColorModulation(oldR, oldG, oldB)
            render.SuppressEngineLighting(false)
        cam.End()


        surface.SetFont("BudgetLabel")
        surface.SetTextPos(x1, y1 - 24)
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(ply:Nick())

        -- Draw their health bar, going from left to right
        -- according to the screen-space bounding box of their model
        -- (aka, from x1 to x2)
        local width = x2 - x1

        local healthBarX = x1
        local healthBarY = y1 - 10  -- Above the box now

        local frac = math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1)
        local healthBarWidth = width * frac

        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(healthBarX - 1, healthBarY - 1, width + 2, 6)
        surface.SetDrawColor(255 * (1 - frac), 255 * frac, 0, 255)
        surface.DrawRect(healthBarX, healthBarY, healthBarWidth, 4)
    end
end

return esp
