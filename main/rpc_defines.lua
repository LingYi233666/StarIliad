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

AddModRPCHandler("stariliad_rpc", "switch_enable_skill", function(player, skill_name)
    if skill_name and player.components.blythe_skiller and player.components.blythe_skiller:IsLearned(skill_name) then
        local enabled = player.components.blythe_skiller:IsEnabled(skill_name)
        player.components.blythe_skiller:Enable(skill_name, not enabled)
    end
end)

AddModRPCHandler("stariliad_rpc", "set_ice_fog_aoe_action_pos", function(player, x, y, z)
    if player and player.sg and player.sg.currentstate and player.sg.currentstate.name == "blythe_release_ice_fog_castaoe2" and player.sg.statemem.action then
        player.sg.statemem.action.pos = DynamicPosition(Vector3(x, y, z))
    end
end)

AddClientModRPCHandler("stariliad_rpc", "show_usurper_shot_screen", function(target1, target2)
    local StarIliadUsurperShotScreen = require("screens/stariliad_usurper_shot_screen")

    TheFrontEnd:PushScreen(StarIliadUsurperShotScreen(target1, target2))
end)

-- SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["play_skill_learning_anim"],ThePlayer.userid, "stariliad_sfx/hud/item_acquired_dread","missile")
AddClientModRPCHandler("stariliad_rpc", "play_skill_learning_anim",
    function(sound, skill_name1, skill_name2, skill_name3)
        local BlytheItemAcquired = require("screens/blythe_item_acquired")

        local skill_names = {}
        for _, v in pairs({ skill_name1, skill_name2, skill_name3 }) do
            if v ~= nil then
                table.insert(skill_names, v)
            end
        end

        if #skill_names <= 0 then
            return
        end

        local title = STRINGS.STARILIAD_UI.ITEM_ACQUIRED.FOUND ..
            STRINGS.STARILIAD_UI.SKILL_DETAIL[skill_names[1]:upper()].NAME

        TheFrontEnd:PushScreen(BlytheItemAcquired(ThePlayer, title, nil, sound, nil, skill_names))
    end)


-- SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["show_usurper_shot_screen"],ThePlayer.userid,ThePlayer,c_findnext("dummytarget"))
