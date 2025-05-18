-- [1005] = "\238\132\131", --"Mouse Button 4",
-- [1006] = "\238\132\132", --"Mouse Button 5",~

local function IsHUDScreen()
    local active_screen = TheFrontEnd:GetActiveScreen()
    if active_screen and active_screen.name and type(active_screen.name) == "string" and active_screen.name == "HUD" then
        return true
    end
end


local function HandleInputToCastSkills(key_or_mouse_button, down, unused_x,
                                       unused_y)
    -- Handle normal skill casting
    if ThePlayer
        and ThePlayer:IsValid()
        and ThePlayer.replica and
        ThePlayer.replica.blythe_skiller then
        local name = ThePlayer.replica.blythe_skiller.input_handler[key_or_mouse_button]
        local skill_define = name and StarIliadBasic.GetSkillDefine(name)

        if skill_define and ThePlayer.replica.blythe_skiller:IsLearned(name) then
            local x, y, z = TheInput:GetWorldPosition():Get()
            local ent = TheInput:GetWorldEntityUnderMouse()

            if skill_define.on_pressed_client and down then
                skill_define.on_pressed_client(ThePlayer, x, y, z, ent)
            end
            if skill_define.on_released_client and not down then
                skill_define.on_released_client(ThePlayer, x, y, z, ent)
            end
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["cast_skill"], name, down, x, y, z, ent)
        end
    end
end

TheInput:AddKeyHandler(function(key, down)
    if not IsHUDScreen() then return end

    HandleInputToCastSkills(key, down)
end)

TheInput:AddMouseButtonHandler(function(button, down, x, y)
    if not IsHUDScreen() then return end

    HandleInputToCastSkills(button, down)
end)

-- TheInput:AddMouseButtonHandler(function(button, down, x, y)
--     if not IsHUDScreen() then return end

--     if button == 1006 and down then
--         if ThePlayer and ThePlayer.replica.blythe_powersuit_configure then
--             ThePlayer.replica.blythe_powersuit_configure:TryOpenWheel()
--         end
--     end
-- end)
