local assets =
{
    Asset("ANIM", "anim/knight.zip"),
    Asset("ANIM", "anim/knight_yoth_build.zip"),
    Asset("ANIM", "anim/knight_yoth_conquest_build.zip"),
    Asset("ANIM", "anim/knight_yoth_famine_build.zip"),
    Asset("ANIM", "anim/knight_yoth_death_build.zip"),
    Asset("SOUND", "sound/chess.fsb"),
    Asset("SCRIPT", "scripts/prefabs/clockwork_common.lua"),
}

SetSharedLootTable("stariliad_event_joust_knight_red",
    {
        { "gears", 1.0 },
    }
)

SetSharedLootTable("stariliad_event_joust_knight_blue",
    {
        { "gears", 1.0 },
    }
)

local function StartIntro(inst)
    local start_delay = 0
    local line_duration = 5

    for _, v in pairs(inst.intro_tasks) do
        v:Cancel()
    end
    inst.intro_tasks = {}

    local line_durations = {
        2, 5, 5, 5, 5
    }

    local t = start_delay
    for i = 1, #STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED.INTRO do
        local task = inst:DoTaskInTime(t, function()
            inst.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED.INTRO[i],
                line_duration)
        end)
        t = t + line_durations[i]

        table.insert(inst.intro_tasks, task)
    end
end

local function OnNear(inst)
    -- local knight_red = inst.components.entitytracker:GetEntity("knight_red")

    -- local start_delay = 2
    -- local line_duration = 5
    -- for i = 1, #STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED.INTRO do
    --     knight_red:DoTaskInTime(start_delay + (i - 1) * 6, function()
    --         knight_red.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED.INTRO[i],
    --             line_duration)
    --     end)
    -- end

    inst:StartIntro()
end

local function OnFar(inst)
    -- if not inst.knights_collide then
    --     local knight_red = inst.components.entitytracker:GetEntity("knight_red")
    --     local knight_blue = inst.components.entitytracker:GetEntity("knight_blue")

    --     SpawnAt("gears", inst)

    --     knight_red:Remove()
    --     knight_blue:Remove()

    --     inst:Remove()
    -- end
end

local function client_fn_red(inst)
    inst.AnimState:SetBuild("knight_yoth_build")
end

local function server_fn_red(inst)
    inst.intro_tasks = {}
    inst.StartIntro = StartIntro

    inst.components.lootdropper:SetChanceLootTable("stariliad_event_joust_knight_red")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(4, 40)
    inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)
    inst.components.playerprox.onnear = OnNear
    inst.components.playerprox.onfar = OnFar
end

----------------------------------------------------------------

local function client_fn_blue(inst)
    inst.AnimState:SetBuild("knight_yoth_death_build")

    -- inst.components.talker.colour = Vector3(0 / 255, 69 / 255, 175 / 255)
    inst.components.talker.colour = Vector3(79 / 255, 117 / 255, 192 / 255)
end

local function server_fn_blue(inst)
    inst.components.lootdropper:SetChanceLootTable("stariliad_event_joust_knight_blue")
end

----------------------------------------------------------------

local function PostUpdateFacing(inst)
    local facing = inst.AnimState:GetCurrentFacing()
    if facing == FACING_LEFT or facing == FACING_UPLEFT or facing == FACING_DOWNLEFT then
        if not inst.lanceflip then
            inst.lanceflip = true
            inst.AnimState:Show("LANCE_L")
            inst.AnimState:Hide("LANCE_R")
        end
    elseif inst.lanceflip then
        inst.lanceflip = false
        inst.AnimState:Show("LANCE_R")
        inst.AnimState:Hide("LANCE_L")
    end
end

local function StartTrackingFacing(inst)
    if not inst._trackingfacing then
        inst._trackingfacing = true
        inst.components.updatelooper:AddPostUpdateFn(PostUpdateFacing)
    end
end

local function StopTrackingFacing(inst)
    if inst._trackingfacing then
        inst._trackingfacing = nil
        inst.components.updatelooper:RemovePostUpdateFn(PostUpdateFacing)
    end
end

local function AbleToAcceptTest(inst, item, giver)
    return item.prefab == "gears"
end

local function AcceptTest(inst, item, giver)
    return item.prefab == "gears"
end

local function OnGetItemFromPlayer(inst, giver, item)
    -- TODO: Duel start!
    local manager = inst.components.entitytracker:GetEntity("manager")
    if inst.prefab == "stariliad_event_joust_knight_red" then
        manager:StartJoust(true)
    else
        manager:StartJoust(false)
    end
end

local function OnRefuseItem(inst, giver, item)
    -- TODO: Add something?
end

local function MakeKnight(prefab, client_fn, server_fn)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        inst:SetPhysicsRadiusOverride(0.5)
        MakeCharacterPhysics(inst, 50, inst.physicsradiusoverride)

        inst.DynamicShadow:SetSize(1.5, .75)
        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("knight")
        inst.AnimState:SetBuild("knight_yoth_build")
        inst.AnimState:PlayAnimation("idle_loop", true)

        inst:AddTag("chess")
        inst:AddTag("hostile")
        inst:AddTag("knight")
        inst:AddTag("monster")

        inst:AddComponent("talker")
        inst.components.talker.fontsize = 40
        inst.components.talker.font = TALKINGFONT
        inst.components.talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
        inst.components.talker.offset = Vector3(0, -700, 0)

        -- inst.components.talker.offset = Vector3(0, -250, 0)
        -- inst.components.talker.symbol = "skull"

        if not TheNet:IsDedicated() then
            inst.lanceflip = false
            inst.AnimState:Hide("LANCE_L")

            inst:AddComponent("updatelooper")
            inst:ListenForEvent("entitysleep", StopTrackingFacing)
            inst:ListenForEvent("entitywake", StartTrackingFacing)
        end

        if client_fn then
            client_fn(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.override_combat_fx_height = "high"
        inst.kind = "_gilded"

        inst:AddComponent("entitytracker")

        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "spring"
        inst.components.combat:SetAttackPeriod(TUNING.KNIGHT_ATTACK_PERIOD)
        inst.components.combat:SetRange(TUNING.KNIGHT_ATTACK_RANGE, TUNING.KNIGHT_HIT_RANGE)
        inst.components.combat:SetDefaultDamage(TUNING.KNIGHT_DAMAGE)

        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)
        inst.components.trader:SetAcceptTest(AcceptTest)
        inst.components.trader.onaccept = OnGetItemFromPlayer
        inst.components.trader.onrefuse = OnRefuseItem

        inst:AddComponent("inspectable")

        inst:AddComponent("locomotor")
        inst.components.locomotor.walkspeed = TUNING.KNIGHT_WALK_SPEED

        inst:AddComponent("lootdropper")

        inst:AddComponent("savedrotation")


        inst:SetStateGraph("SGstariliad_event_joust_knight")

        if server_fn then
            server_fn(inst)
        end

        return inst
    end

    return Prefab(prefab, fn, assets)
end

-------------------------------------------------------------------------------

local function RemoveWithFX(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

    SpawnAt("statue_transition_2", inst, { 1, 2, 1 })
    SpawnAt("statue_transition", inst, { 1, 1.5, 1 })

    inst:Hide()
    inst:DoTaskInTime(1, inst.Remove)
end




-- local function AfterJoust(inst)
--     local knight_red = inst.components.entitytracker:GetEntity("knight_red")
--     local knight_blue = inst.components.entitytracker:GetEntity("knight_blue")
-- end

local function JoustUpdate(inst)
    local center = inst:GetPosition()
    local knight_red = inst.components.entitytracker:GetEntity("knight_red")
    local knight_blue = inst.components.entitytracker:GetEntity("knight_blue")

    if GetTime() - inst.joust_start_time > 10 then
        knight_red.Transform:SetPosition(center:Get())
        knight_blue.Transform:SetPosition(center:Get())
    end

    -- local p1 = knight_red:GetPosition()
    -- local p2 = knight_blue:GetPosition()

    -- local fx = SpawnPrefab((target:HasTag("largecreature") or target:HasTag("epic")) and "round_puff_fx_lg" or
    --     "round_puff_fx_sm")

    if knight_red:IsNear(knight_blue, 1) then
        if math.random() < 0.3 then
            -- red win!
            knight_blue.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. knight_blue.kind .. "/hurt")
            SpawnAt("round_puff_fx_lg", knight_blue)
            knight_blue.sg:GoToState("death2")

            inst.winner = knight_red
        else
            -- blue win!
            knight_red.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. knight_red.kind .. "/hurt")
            SpawnAt("round_puff_fx_lg", knight_red)
            knight_red.sg:GoToState("death2")

            inst.winner = knight_blue
        end

        inst.task:Cancel()

        inst:DoTaskInTime(1, function()
            inst.winner.sg:GoToState("joust_pst")
        end)
        inst:DoTaskInTime(2, function()
            local player = inst.winner:GetNearestPlayer(true)
            if player then
                inst.winner:ForceFacePoint(player:GetPosition())
            end

            if inst.trust_red then
                if inst.winner == knight_red then
                    knight_red.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED
                        .GAMBLE_WIN_RED)

                    inst:DoTaskInTime(1, function()
                        for i = 1, 3 do
                            knight_red.components.lootdropper:SpawnLootPrefab("blythe_unlock_skill_item_missile")
                        end
                    end)
                else
                    knight_blue.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED
                        .GAMBLE_FAILED)
                end
            elseif not inst.trust_red then
                if inst.winner == knight_blue then
                    knight_blue.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED
                        .GAMBLE_WIN_BLUE)
                    inst:DoTaskInTime(1, function()
                        knight_blue.components.lootdropper:SpawnLootPrefab("blythe_unlock_skill_item_missile")
                    end)
                else
                    knight_red.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED
                        .GAMBLE_FAILED)
                end
            end
        end)

        inst:DoTaskInTime(8, function()
            -- ErodeAway(knight_red)
            -- ErodeAway(knight_blue)

            --  RemoveWithFX(inst)

            RemoveWithFX(inst.winner)
            if inst.winner == knight_red then
                ErodeAway(knight_blue)
            else
                ErodeAway(knight_red)
            end
            inst:Remove()
        end)
    end
end

local function StartJoust(inst, trust_red)
    inst.trust_red = trust_red

    local knight_red = inst.components.entitytracker:GetEntity("knight_red")
    local knight_blue = inst.components.entitytracker:GetEntity("knight_blue")

    knight_red.persists = false
    knight_blue.persists = false
    inst.persists = false

    for _, v in pairs(knight_red.intro_tasks) do
        v:Cancel()
    end
    knight_red.intro_tasks = {}

    knight_red.sg:GoToState("taunt", knight_blue)
    knight_blue.sg:GoToState("taunt", knight_red)

    if trust_red == true then
        knight_red.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED.TRUST_RED)
    else
        knight_red.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_EVENT_JOUST_KNIGHT_RED.TRUST_BLUE)
    end

    inst.joust_start_time = GetTime()
    inst.task = inst:DoPeriodicTask(0, JoustUpdate)
end

local function OnSave(inst, data)
    data.initialized = inst.initialized
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.initialized ~= nil then
            inst.initialized = data.initialized
        end
    end
end

local function ManagerFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.StartJoust = StartJoust

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:AddComponent("entitytracker")

    inst:DoTaskInTime(1, function()
        if not inst.initialized then
            local center = inst:GetPosition()
            local offset_red = Vector3(-6, 0, 0)
            local offset_blue = Vector3(6, 0, 0)

            local knight_red = SpawnAt("stariliad_event_joust_knight_red", center, nil, offset_red)
            local knight_blue = SpawnAt("stariliad_event_joust_knight_blue", center, nil, offset_blue)

            knight_red:ForceFacePoint(knight_blue:GetPosition())
            knight_blue:ForceFacePoint(knight_red:GetPosition())

            inst.components.entitytracker:TrackEntity("knight_red", knight_red)
            inst.components.entitytracker:TrackEntity("knight_blue", knight_blue)

            knight_red.components.entitytracker:TrackEntity("manager", inst)
            knight_blue.components.entitytracker:TrackEntity("manager", inst)
        end

        inst.initialized = true
    end)


    return inst
end

return MakeKnight("stariliad_event_joust_knight_red", client_fn_red, server_fn_red),
    MakeKnight("stariliad_event_joust_knight_blue", client_fn_blue, server_fn_blue),
    Prefab("stariliad_event_joust", ManagerFn, assets)
