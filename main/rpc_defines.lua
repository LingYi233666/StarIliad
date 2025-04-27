AddModRPCHandler("stariliad_rpc", "usurper_shot_teleport", function(player, target1, target2)
    StarIliadUsurper.SwapPositionPst(target1, target2)
end)

AddClientModRPCHandler("stariliad_rpc", "show_usurper_shot_screen", function(target1, target2)
    local StarIliadUsurperShotScreen = require("screens/stariliad_usurper_shot_screen")

    TheFrontEnd:PushScreen(StarIliadUsurperShotScreen(target1, target2))
end)

-- SendModRPCToClient(MOD_RPC["stariliad_rpc"]["show_usurper_shot_screen"],ThePlayer.userid,ThePlayer,c_findnext("dummytarget"))
