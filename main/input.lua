-- [1005] = "\238\132\131", --"Mouse Button 4",
-- [1006] = "\238\132\132", --"Mouse Button 5",~

local function IsHUDScreen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    if active_screen and active_screen.name and type(active_screen.name) == "string" and active_screen.name == "HUD" then
        return true
    end
end

-- TheInput:AddKeyHandler(function(key, down)
--     if not IsHUDScreen() then return end

--     -- HandleInputToCastSkills(key, down)
-- end)



TheInput:AddMouseButtonHandler(function(button, down, x, y)
    if not IsHUDScreen() then return end

    if button == 1006 and down then
        if ThePlayer and ThePlayer.replica.blythe_powersuit_configure then
            ThePlayer.replica.blythe_powersuit_configure:TryOpenWheel()
        end
    end
end)
