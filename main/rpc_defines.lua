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

AddClientModRPCHandler("stariliad_rpc", "show_usurper_shot_screen", function(target1, target2)
    local StarIliadUsurperShotScreen = require("screens/stariliad_usurper_shot_screen")

    TheFrontEnd:PushScreen(StarIliadUsurperShotScreen(target1, target2))
end)

-- SendModRPCToClient(MOD_RPC["stariliad_rpc"]["show_usurper_shot_screen"],ThePlayer.userid,ThePlayer,c_findnext("dummytarget"))
