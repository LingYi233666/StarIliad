local assets =
{
    Asset("ANIM", "anim/statue_ruins_small.zip"),
    Asset("ANIM", "anim/statue_ruins_small_gem.zip"),
    Asset("ANIM", "anim/statue_ruins.zip"),
    Asset("ANIM", "anim/statue_ruins_gem.zip"),
    Asset("ANIM", "anim/stariliad_alien_statue_chozo.zip"),
    Asset("ANIM", "anim/stariliad_alien_statue_chozo_dodge.zip"),

    Asset("ANIM", "anim/lavaarena_portal.zip"),
    Asset("ANIM", "anim/lavaarena_keyhole.zip"),
    Asset("ANIM", "anim/lavaarena_portal_fx.zip"),

    Asset("ANIM", "anim/atrium_floor.zip"),

    Asset("IMAGE", "images/map_icons/stariliad_alien_statue_chozo_dodge.tex"), --小地图
    Asset("ATLAS", "images/map_icons/stariliad_alien_statue_chozo_dodge.xml"),
}



local function AlwaysRecoil(inst, worker, tool, numworks)
    return true, numworks
end

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        inst.components.workable:SetWorkLeft(1)
        -- worker:PushEvent("tooltooweak", { workaction = ACTIONS.MINE })
    end
end

local function OnEntitySleep(inst)
    if inst.SoundEmitter:PlayingSound("hoverloop") then
        inst.SoundEmitter:KillSound("hoverloop")
    end
end

local function OnEntityWake(inst)
    if not inst.SoundEmitter:PlayingSound("hoverloop") and inst.loop_sound then
        inst.SoundEmitter:PlaySound(inst.loop_sound, "hoverloop")
    end
end


local function common_fn(bank, build, anim, radius, item_prefab, regenerate_time, loop_sound, workable)
    radius = radius or 0.66

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    if radius > 0 then
        MakeObstaclePhysics(inst, radius)
    end

    if bank and build and anim then
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(anim, true)
    end

    inst:AddTag("structure")
    inst:AddTag("statue")

    if not TheNet:IsDedicated() then
        inst:AddComponent("stariliad_important_scan_target")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("savedrotation")

    if item_prefab and regenerate_time then
        inst:AddComponent("pickable")
        -- inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
        inst.components.pickable:SetUp(item_prefab, regenerate_time)
    end

    if workable == nil or workable == true then
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.MINE)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(OnWork)
        inst.components.workable:SetShouldRecoilFn(AlwaysRecoil)
    end

    if loop_sound then
        inst.loop_sound = loop_sound
        inst.OnEntityWake = OnEntityWake
        inst.OnEntitySleep = OnEntitySleep
    end

    return inst
end

------------------------------------------------------------------------------------

local function OnPickedNormalChozo(inst, picker)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/key_in")
    -- inst.AnimState:ClearOverrideSymbol("swap_gem")

    inst.AnimState:HideSymbol("swap_object")
end

local function OnRegenNormalChozo(inst)
    inst.AnimState:ShowSymbol("swap_object")
end

local function MakeEmptyNormalChozo(inst)
    inst.AnimState:HideSymbol("swap_object")
end

local function wrapper_normal_chozo(item_prefab)
    local function fn()
        local inst = common_fn("stariliad_alien_statue_chozo", "stariliad_alien_statue_chozo", "idle", nil,
            item_prefab, 10,
            "dontstarve/common/floating_statue_hum")

        inst.Transform:SetTwoFaced()

        inst.AnimState:ShowSymbol("swap_object")

        inst:AddTag("stariliad_pick_high")
        inst:AddTag("stariliad_alien_statue_chozo")

        inst:SetPrefabNameOverride("stariliad_alien_statue_normal_chozo")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.pickable.onpickedfn = OnPickedNormalChozo
        inst.components.pickable.onregenfn = OnRegenNormalChozo
        inst.components.pickable.makeemptyfn = MakeEmptyNormalChozo

        return inst
    end

    return fn
end

------------------------------------------------------------------------------------

local function OnPickedDodgeChozo(inst, picker)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/key_in")
    -- inst.AnimState:ClearOverrideSymbol("swap_gem")

    inst.AnimState:HideSymbol("swap_object")
end

local function OnRegenDodgeChozo(inst)
    inst.AnimState:ShowSymbol("swap_object")
end

local function MakeEmptyDodgeChozo(inst)
    inst.AnimState:HideSymbol("swap_object")
end

local function wrapper_dodge_chozo(item_prefab)
    local function fn()
        local inst = common_fn("stariliad_alien_statue_chozo_dodge", "stariliad_alien_statue_chozo_dodge", "idle", nil,
            item_prefab, 10,
            "dontstarve/common/floating_statue_hum")

        inst.MiniMapEntity:SetIcon("stariliad_alien_statue_chozo_dodge.tex")

        -- inst.Transform:SetTwoFaced()

        inst.AnimState:ShowSymbol("swap_object")

        -- inst:AddTag("stariliad_pick_high")
        -- inst:AddTag("stariliad_alien_statue_chozo")

        inst:SetPrefabNameOverride("stariliad_alien_statue_normal_chozo")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.pickable.onpickedfn = OnPickedDodgeChozo
        inst.components.pickable.onregenfn = OnRegenDodgeChozo
        inst.components.pickable.makeemptyfn = MakeEmptyDodgeChozo

        return inst
    end

    return fn
end

------------------------------------------------------------------------------------

local function OnPickedBrokenChozo(inst, picker)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/key_in")
    inst.AnimState:ClearOverrideSymbol("swap_gem")
end

local function OnRegenBrokenChozo(inst)
    inst.AnimState:OverrideSymbol("swap_gem", "statue_ruins_small_gem", "greengem")
end

local function MakeEmptyBrokenChozo(inst)
    inst.AnimState:ClearOverrideSymbol("swap_gem")
end


local function wrapper_broken_chozo(item_prefab)
    local function fn()
        local inst = common_fn("statue_ruins_small", "statue_ruins_small", "hit_med", nil, item_prefab,
            10,
            "dontstarve/common/floating_statue_hum")

        inst.AnimState:OverrideSymbol("swap_gem", "statue_ruins_small_gem", "greengem")


        inst:SetPrefabNameOverride("stariliad_alien_statue_broken_chozo")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.pickable.onpickedfn = OnPickedBrokenChozo
        inst.components.pickable.onregenfn = OnRegenBrokenChozo
        inst.components.pickable.makeemptyfn = MakeEmptyBrokenChozo

        return inst
    end

    return fn
end

------------------------------------------------------------------------------------

local function OnSaveAltar(inst, data)
    data.init_spawn = inst.init_spawn
end

local function OnLoadAltar(inst, data)
    if data ~= nil then
        if data.init_spawn ~= nil then
            inst.init_spawn = data.init_spawn
        end
    end
end


local function wrapper_altar(item_prefab)
    local function fn()
        -- local inst = common_fn("lavaarena_portal", "lavaarena_portal", "idle", -1, nil, nil, nil, false)
        -- local inst = common_fn("atrium_floor", "atrium_floor", "idle_active")
        local inst = common_fn(nil, nil, nil, -1, nil, nil, nil, false)

        -- RemovePhysicsColliders(inst)

        -- inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        -- inst.AnimState:SetLayer(LAYER_BACKGROUND)
        -- inst.AnimState:SetSortOrder(1)
        -- inst.AnimState:SetFinalOffset(2)

        inst:SetPrefabNameOverride("stariliad_alien_statue_altar")

        inst:AddTag("NOCLICK")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.init_spawn = false

        inst.OnSave = OnSaveAltar
        inst.OnLoad = OnLoadAltar

        inst:DoTaskInTime(1, function()
            -- print(inst, "Try run init spawn code.")
            if inst.init_spawn then
                -- print(inst, "Init spawn code already processed, so we don't run it again.")
                return
            end

            local item = SpawnAt(item_prefab, inst)

            local num_pillars = 8
            local radius = 10

            local angle_step = 360 / num_pillars
            for i = 0, num_pillars - 1 do
                local theta = angle_step * i * DEGREES
                local offset = Vector3FromTheta(theta, radius)

                local pillar = SpawnAt("stariliad_alien_ruins_pillar", inst, nil, offset)
                pillar:ForceFacePoint(inst.Transform:GetWorldPosition())
            end

            inst.init_spawn = true

            -- print(inst, "Init spawn code finish successful.")
        end)

        return inst
    end

    return fn
end

------------------------------------------------------------------------------------

------------------------------------------------------------------------------------

-- Custom statues
local custom_rets = {}

-- TODO: Add custom statues


------------------------------------------------------------------------------------

local rets = {}
for _, data in pairs(BLYTHE_SKILL_DEFINES) do
    if not data.root and data.statue_type then
        local statue_prefab = "stariliad_alien_statue_" .. data.name
        local item_prefab = "blythe_unlock_skill_item_" .. data.name

        -- TODO: Finish ALTAR and MERMAID
        if data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.NORMAL_CHOZO then
            table.insert(rets, Prefab(statue_prefab, wrapper_normal_chozo(item_prefab), assets))
        elseif data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.DODGE_CHOZO then
            table.insert(rets, Prefab(statue_prefab, wrapper_dodge_chozo(item_prefab), assets))
        elseif data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.BROKEN_CHOZO then
            table.insert(rets, Prefab(statue_prefab, wrapper_broken_chozo(item_prefab), assets))
        elseif data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.ALTAR then
            table.insert(rets, Prefab(statue_prefab, wrapper_altar(item_prefab), assets))
        elseif data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.MERMAID then
            print("MERMAID not IMP !")
        end
    end
end


return unpack(JoinArrays(rets, custom_rets))
