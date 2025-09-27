AddModRPCHandler("stariliad_rpc", "cast_skill", function(inst, name, pressed, x, y, z, ent)
    local data = StarIliadBasic.GetSkillDefine(name)
    local is_learned = inst.components.blythe_skiller:IsLearned(name)

    if is_learned then
        if pressed then
            if data.on_pressed then
                data.on_pressed(inst, x, y, z, ent)
            end
        else
            if data.on_released then
                data.on_released(inst, x, y, z, ent)
            end
        end
    end
end)


AddModRPCHandler("stariliad_rpc", "usurper_shot_teleport", function(player, target1, target2)
    StarIliadUsurper.SwapPositionPst(target1, target2)
end)

AddModRPCHandler("stariliad_rpc", "set_projectile_prefab", function(player, prefab)
    if player.components.blythe_powersuit_configure and prefab then
        player.components.blythe_powersuit_configure:SetProjectilePrefab(prefab)
    end
end)

AddModRPCHandler("stariliad_rpc", "enable_skill", function(player, skill_name, enable)
    if skill_name and player.components.blythe_skiller and player.components.blythe_skiller:IsLearned(skill_name) then
        player.components.blythe_skiller:Enable(skill_name, enable)
    end
end)

-- AddModRPCHandler("stariliad_rpc", "remote_pause_control", function(player, num_frames)
--     if player and player.components.playercontroller then
--         player.components.playercontroller:RemotePausePrediction(num_frames)
--     end
-- end)

AddModRPCHandler("stariliad_rpc", "switch_enable_skill", function(player, skill_name)
    if skill_name and player.components.blythe_skiller and player.components.blythe_skiller:IsLearned(skill_name) then
        local enabled = player.components.blythe_skiller:IsEnabled(skill_name)
        player.components.blythe_skiller:Enable(skill_name, not enabled)
    end
end)

-- AddModRPCHandler("stariliad_rpc", "set_shoot_action_data", function(player, x, y, z, target)
--     if player and player.sg.statemem.action then
--         if x and y and z then
--             player.sg.statemem.action:SetActionPoint(Vector3(x, y, z))
--         else
--             player.sg.statemem.action.pos = nil
--         end
--         player.sg.statemem.action.target = target
--     end
-- end)

AddModRPCHandler("stariliad_rpc", "rectify_shoot_buffaction", function(player, x, y, z, target)
    if player and player:IsValid() and player.components.playercontroller then
        player.components.playercontroller:OnRemoteRectifyStarIliadShootAction(x, y, z, target)
    end
end)

-- AddModRPCHandler("stariliad_rpc", "set_ice_fog_aoe_action_pos", function(player, x, y, z)
--     if player and player.sg and player.sg.currentstate and player.sg.currentstate.name == "blythe_release_ice_fog_castaoe2" and player.sg.statemem.action then
--         player.sg.statemem.action.pos = DynamicPosition(Vector3(x, y, z))
--     end
-- end)

AddModRPCHandler("stariliad_rpc", "goto_parry_sg", function(player, x, y, z)
    if player and player:IsValid() and player.components.blythe_skill_parry and player.components.blythe_skill_parry:CanCast(x, y, z) then
        player.sg:GoToState("blythe_parry", { pos = Vector3(x, y, z) })
    end
end)

AddClientModRPCHandler("stariliad_rpc", "show_usurper_shot_screen", function(target1, target2)
    local StarIliadUsurperShotScreen = require("screens/stariliad_usurper_shot_screen")

    TheFrontEnd:PushScreen(StarIliadUsurperShotScreen(target1, target2))
end)



AddClientModRPCHandler("stariliad_rpc", "play_skill_learning_anim",
    function(title, desc, sound, duration, ...)
        local skill_names = { ... }

        if ThePlayer.HUD.controls.StarIliadMainMenu then
            TheFrontEnd:PopScreen(ThePlayer.HUD.controls.StarIliadMainMenu)
        end

        local BlytheItemAcquired = require("screens/blythe_item_acquired")
        TheFrontEnd:PushScreen(BlytheItemAcquired(ThePlayer, title, desc, sound, duration, skill_names))
    end
)

-- AddClientModRPCHandler("stariliad_rpc", "make_facing_dirty", function()
--     if ThePlayer and ThePlayer:IsValid() and ThePlayer.AnimState then
--         ThePlayer.AnimState:MakeFacingDirty()
--     end
-- end)

AddClientModRPCHandler("stariliad_rpc", "goto_parry_sg", function(x, y, z)
    if ThePlayer and ThePlayer:IsValid() and ThePlayer.sg and ThePlayer.sg.sg and ThePlayer.sg.sg.name == "wilson_client" then
        ThePlayer.sg:GoToState("blythe_parry", { pos = Vector3(x, y, z) })
    end
end)

-- AddClientModRPCHandler("stariliad_rpc", "set_root_skill_key", function()
--     if ThePlayer and ThePlayer:IsValid() and ThePlayer.replica.blythe_skiller then
--         ThePlayer.replica.blythe_skiller:SetRootInputHandler()
--     end
-- end)

AddClientModRPCHandler("stariliad_rpc", "set_skill_key", function(key, name, save_to_file)
    if ThePlayer and ThePlayer:IsValid() and ThePlayer.replica.blythe_skiller then
        ThePlayer.replica.blythe_skiller:SetInputHandler(key, name, save_to_file)
    end
end)


-- SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["show_usurper_shot_screen"],ThePlayer.userid,ThePlayer,c_findnext("dummytarget"))

-- SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["missile_status_spawn_fx"],ThePlayer.userid,true)
AddClientModRPCHandler("stariliad_rpc", "missile_status_spawn_fx",
    function(is_super)
        if ThePlayer
            and ThePlayer:IsValid()
            and ThePlayer.HUD
            and ThePlayer.HUD.controls
            and ThePlayer.HUD.controls.secondary_status
            and ThePlayer.HUD.controls.secondary_status.blythe_missile_status then
            ThePlayer.HUD.controls.secondary_status.blythe_missile_status:SpawnFX(is_super)
        end
    end
)

-- x, y, z, damage_colour_1, damage_number_1,damage_colour_2, damage_number_2,...
AddClientModRPCHandler("stariliad_rpc", "show_damage_number", function(x, y, z, ...)
    -- local PopupNumber = require "widgets/popupnumber"
    local StarIliadPopupNumber = require("widgets/stariliad_popupnumber")

    local dmg_array = { ... }
    local len_array = #dmg_array
    if len_array <= 0 then
        print("Empty damage array !")
        return
    end


    if len_array % 2 ~= 0 then
        print("Error damage array length:", len_array)
        return
    end

    if not (ThePlayer and ThePlayer.HUD) then
        return
    end

    local function FineTuneNumber(val)
        -- if val >= 1 then
        --     return tostring(math.floor(val + 0.5))
        -- end

        -- return string.format("%.1f", val)

        local floor_val = math.floor(val)
        if math.abs(floor_val - val) < 0.1 then
            return tostring(floor_val)
        end

        return string.format("%.1f", val)
    end

    local half_len_array = len_array / 2
    local angle_step = 360 / half_len_array
    local angle_start = math.random() < 0.5 and 180 or 0

    for i = 1, len_array - 1, 2 do
        local colour_name = dmg_array[i]
        local damage = dmg_array[i + 1]
        local r, g, b = unpack(STARILIAD_DAMAGE_NUMBER_COLOURS[colour_name])

        local height = math.random(30, 50)

        -- ThePlayer.HUD:ShowPopupNumber(FineTuneNumber(damage), large and 48 or 32, Vector3(x, y, z), height,
        --     { r, g, b, 1 },
        --     large)

        -- local popup_number = ThePlayer.HUD.popupstats_root:AddChild(
        --     PopupNumber(ThePlayer,
        --         FineTuneNumber(damage),
        --         32,
        --         Vector3(x, y, z),
        --         height,
        --         { r, g, b, 1 },
        --         false)
        -- )
        -- popup_number.dir = cur_dir
        -- popup_number.rise = GetRandomMinMax(8, 24)
        -- popup_number.drop = GetRandomMinMax(12, 36)
        -- popup_number.speed = GetRandomMinMax(34, 102)


        local angle = (angle_start + angle_step * (i - 1) * 0.5 + GetRandomMinMax(-10, 10)) * DEGREES

        local popup_number = ThePlayer.HUD.popupstats_root:AddChild(
            StarIliadPopupNumber(ThePlayer,
                FineTuneNumber(damage),
                -- damage,
                32,
                Vector3(x, y, z),
                Vector3(math.cos(angle), math.sin(angle), 0),
                height,
                { r, g, b, 1 },
                false)
        )
        -- popup_number.rise = GetRandomMinMax(8, 24)
        -- popup_number.drop = GetRandomMinMax(12, 36)
        -- popup_number.speed = GetRandomMinMax(34, 102)
    end
end)

AddClientModRPCHandler("stariliad_rpc", "show_tip", function(key, duration)
    -- if ThePlayer and ThePlayer.HUD and ThePlayer.HUD.controls and ThePlayer.HUD.controls.StarIliadTipUI then
    --     ThePlayer.HUD.controls.StarIliadTipUI:ShowTip(str, duration)
    -- end

    if ThePlayer and ThePlayer.replica.stariliad_tip_manager then
        ThePlayer.replica.stariliad_tip_manager:Process(key, duration)
    end
end)

local StariliadShakingText = require "widgets/stariliad_shaking_text"
AddClientModRPCHandler("stariliad_rpc", "show_destroy3_text", function(guardian)
    if ThePlayer and ThePlayer:IsValid() and ThePlayer.HUD then
        local ui = ThePlayer.HUD:AddChild(StariliadShakingText(TALKINGFONT, 45,
            STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_BOSS_GUARDIAN.DESTROY3, { 238 / 255, 69 / 255, 105 / 255, 1 }))
        -- ui:SetTarget(guardian, "head", Vector3(0, -250, 0))
        ui:SetTarget(guardian, nil, Vector3(0, -800, 0))
        ui:Hide()
        ui.inst:DoTaskInTime(3, function()
            ui:Kill()
        end)
        ui.inst:DoStaticPeriodicTask(0, function()
            local facing = ui.target.Transform:GetFacing()
            if facing == FACING_RIGHT or facing == FACING_UPRIGHT or facing == FACING_DOWNRIGHT
                or facing == FACING_LEFT or facing == FACING_UPLEFT or facing == FACING_DOWNLEFT then
                ui.offset = Vector3(200, -800, 0)
            else
                ui.offset = Vector3(0, -800, 0)
            end
        end)
    end
end)
