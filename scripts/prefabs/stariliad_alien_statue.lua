local assets =
{
    Asset("ANIM", "anim/statue_ruins_small.zip"),
    Asset("ANIM", "anim/statue_ruins_small_gem.zip"),
    Asset("ANIM", "anim/statue_ruins.zip"),
    Asset("ANIM", "anim/statue_ruins_gem.zip"),

    Asset("ANIM", "anim/lavaarena_portal.zip"),
    Asset("ANIM", "anim/lavaarena_keyhole.zip"),
    Asset("ANIM", "anim/lavaarena_portal_fx.zip"),
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

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)

    inst:AddTag("structure")
    inst:AddTag("statue")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

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
    inst.AnimState:ClearOverrideSymbol("swap_gem")
end

local function OnRegenNormalChozo(inst)
    inst.AnimState:OverrideSymbol("swap_gem", "statue_ruins_gem", "yellowgem")
end

local function wrapper_normal_chozo(item_prefab)
    local function fn()
        local inst = common_fn("statue_ruins", "statue_ruins", "idle_full", nil, item_prefab, TUNING.TOTAL_DAY_TIME,
            "dontstarve/common/floating_statue_hum")

        inst:SetPrefabNameOverride("stariliad_alien_statue_normal_chozo")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.pickable.onpickedfn = OnPickedNormalChozo
        inst.components.pickable.onregenfn = OnRegenNormalChozo

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
    inst.AnimState:OverrideSymbol("swap_gem", "statue_ruins_small_gem", "yellowgem")
end

local function wrapper_broken_chozo(item_prefab)
    local function fn()
        local inst = common_fn("statue_ruins_small", "statue_ruins_small", "hit_med", nil, item_prefab,
            TUNING.TOTAL_DAY_TIME,
            "dontstarve/common/floating_statue_hum")

        inst:SetPrefabNameOverride("stariliad_alien_statue_broken_chozo")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.pickable.onpickedfn = OnPickedBrokenChozo
        inst.components.pickable.onregenfn = OnRegenBrokenChozo

        return inst
    end

    return fn
end

------------------------------------------------------------------------------------
local function wrapper_altar(item_prefab)
    local function fn()
        local inst = common_fn("statue_ruins_small", "statue_ruins_small", "hit_med")


        inst:AddTag("NOCLICK")

        if not TheWorld.ismastersim then
            return inst
        end



        return inst
    end

    return fn
end

------------------------------------------------------------------------------------

------------------------------------------------------------------------------------

-- Custom statues
local custom_rets = {}

local rets = {}
for _, data in pairs(BLYTHE_SKILL_DEFINES) do
    if not data.root and data.statue_type then
        local statue_prefab = "stariliad_alien_statue_" .. data.name
        local item_prefab = "blythe_unlock_skill_item_" .. data.name

        -- TODO: Finish ALTAR and MERMAID
        if data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.NORMAL_CHOZO then
            table.insert(rets, Prefab(statue_prefab, wrapper_normal_chozo(item_prefab), assets))
        elseif data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.BROKEN_CHOZO then
            table.insert(rets, Prefab(statue_prefab, wrapper_broken_chozo(item_prefab), assets))
        elseif data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.ALTAR then
            -- table.insert(rets, Prefab(statue_prefab, wrapper_altar(item_prefab), assets))
        elseif data.statue_type == STARILIAD_ALIEN_STATUE_TYPE.MERMAID then
            -- print("MERMAID not IMP !")
        end
    end
end


return unpack(JoinArrays(rets, custom_rets))
