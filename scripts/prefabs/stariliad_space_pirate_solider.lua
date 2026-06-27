local brain = require("brains/stariliad_space_pirate_solider_brain")

local assets =
{
    Asset("ANIM", "anim/antman_actions.zip"),
    Asset("ANIM", "anim/antman_attacks.zip"),
    Asset("ANIM", "anim/antman_basic.zip"),

    Asset("ANIM", "anim/wx78_shield_fx.zip"),

    -- Asset("ANIM", "anim/antman_guard_build.zip"),
    -- Asset("ANIM", "anim/antman_translucent_build.zip"),
    -- Asset("ANIM", "anim/antman_warpaint_build.zip"),

    Asset("ANIM", "anim/stariliad_space_pirate_solider_lv1.zip"),
    Asset("ANIM", "anim/stariliad_space_pirate_solider_lv2.zip"),
    Asset("ANIM", "anim/stariliad_space_pirate_solider_lv3.zip"),

    Asset("ANIM", "anim/bearger_ring_fx.zip"),
}

SetSharedLootTable("stariliad_space_pirate_solider_lv1",
    {
        { "meat",       1.0 },
        { "goldnugget", 0.5 },
        { "transistor", 0.1 },
        { "trinket_6",  0.1 },
        { "gears",      0.05 },
        { "greengem",   0.01 },
    }
)

SetSharedLootTable("stariliad_space_pirate_solider_lv2",
    {
        { "meat",       1.0 },
        { "goldnugget", 0.6 },
        { "transistor", 0.1 },
        { "trinket_6",  0.1 },
        { "gears",      0.05 },
        { "greengem",   0.01 },
    }
)

SetSharedLootTable("stariliad_space_pirate_solider_lv3",
    {
        { "meat",       1.0 },
        { "goldnugget", 0.7 },
        { "transistor", 0.1 },
        { "trinket_6",  0.1 },
        { "gears",      0.1 },
        { "greengem",   0.01 },
    }
)

local function RetargetFn(inst)
    if not inst.components.health:IsDead() then
        return FindEntity(inst, 10, function(guy)
                return inst.components.combat:CanTarget(guy)
            end,
            { "_combat", "_health" },
            { "INLIMBO", "smallcreature", "prey", "stariliad_space_pirate" },
            { "character", "largecreature" }
        )
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnEnterWater(inst)
    inst._is_swimming:set(true)
end

local function OnExitWater(inst)
    inst._is_swimming:set(false)
end

local function OnHitOther(inst, data)
    inst.last_hit_other_time = GetTime()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        return dude:HasTag("stariliad_space_pirate")
            and not dude.components.health:IsDead()
    end, 10)
end

--------------------------------------------------------------------------------

local function CreateFadeShadow(build_name)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(1.15, 1.15, 1.15)

    inst.AnimState:SetBank("antman")
    inst.AnimState:SetBuild(build_name)
    inst.AnimState:PlayAnimation("idle")
    -- inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:UsePointFiltering(true)
    -- inst.AnimState:SetSortOrder(-1)
    inst.AnimState:SetLightOverride(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst:AddComponent("updatelooper")

    inst.persists = false

    inst.FadeOut = function(inst, duration, start_mult_colour, end_mult_colour, start_add_colour, end_add_colour)
        inst.start_time = GetTime()

        local delta_mult_r, delta_mult_g, delta_mult_b, delta_mult_a
        local delta_add_r, delta_add_g, delta_add_b, delta_add_a

        if start_mult_colour and end_mult_colour then
            delta_mult_r = end_mult_colour[1] - start_mult_colour[1]
            delta_mult_g = end_mult_colour[2] - start_mult_colour[2]
            delta_mult_b = end_mult_colour[3] - start_mult_colour[3]
            delta_mult_a = end_mult_colour[4] - start_mult_colour[4]

            inst.AnimState:SetMultColour(start_mult_colour[1], start_mult_colour[2], start_mult_colour[3],
                start_mult_colour[4])
        end

        if start_add_colour and end_add_colour then
            delta_add_r = end_add_colour[1] - start_add_colour[1]
            delta_add_g = end_add_colour[2] - start_add_colour[2]
            delta_add_b = end_add_colour[3] - start_add_colour[3]
            delta_add_a = end_add_colour[4] - start_add_colour[4]

            inst.AnimState:SetAddColour(start_add_colour[1], start_add_colour[2], start_add_colour[3],
                start_add_colour[4])
        end


        -- inst.last_facing = inst.AnimState:GetCurrentFacing()
        -- if inst.last_facing == FACING_RIGHT or inst.last_facing == FACING_LEFT then
        --     inst.AnimState:SetSortOrder(-3)
        -- else
        --     inst.AnimState:SetSortOrder(0)
        -- end

        local facing = inst.AnimState:GetCurrentFacing()
        if facing == FACING_RIGHT or facing == FACING_LEFT or facing == FACING_DOWN then
            inst.AnimState:SetSortOrder(-1)
        else
            inst.AnimState:SetSortOrder(1)
        end

        inst.components.updatelooper:AddOnUpdateFn(function(inst, dt)
            local percent = (GetTime() - inst.start_time) / duration

            if percent > 1 then
                inst:Remove()
                return
            end

            -- local facing = inst.AnimState:GetCurrentFacing()
            -- if inst.last_facing ~= facing then
            --     if facing == FACING_RIGHT or facing == FACING_LEFT then
            --         inst.AnimState:SetSortOrder(-3)
            --     else
            --         inst.AnimState:SetSortOrder(0)
            --     end
            -- end
            -- inst.last_facing = facing

            local facing = inst.AnimState:GetCurrentFacing()
            if facing == FACING_RIGHT or facing == FACING_LEFT or facing == FACING_DOWN then
                inst.AnimState:SetSortOrder(-1)
            else
                inst.AnimState:SetSortOrder(1)
            end

            if start_mult_colour and end_mult_colour then
                local r = start_mult_colour[1] + delta_mult_r * percent
                local g = start_mult_colour[2] + delta_mult_g * percent
                local b = start_mult_colour[3] + delta_mult_b * percent
                local a = start_mult_colour[4] + delta_mult_a * percent
                inst.AnimState:SetMultColour(r, g, b, a)
            end

            if start_add_colour and end_add_colour then
                local r = start_add_colour[1] + delta_add_r * percent
                local g = start_add_colour[2] + delta_add_g * percent
                local b = start_add_colour[3] + delta_add_b * percent
                local a = start_add_colour[4] + delta_add_a * percent
                inst.AnimState:SetAddColour(r, g, b, a)
            end
        end)
    end

    return inst
end

local function SpawnFadeShadowTask(inst, dt)
    local valid_anims = {
        "run_pre",
        "run_loop",
        -- "run_pst",
        { "atk",  0, 0.5 },
        { "atk2", 0, 0.5 },
    }

    local anim
    local min_percent
    local max_percent
    for _, v in pairs(valid_anims) do
        local cur_anim_name
        local cur_min_percent
        local cur_max_percent

        if type(v) == "string" then
            cur_anim_name = v
        elseif type(v) == "table" then
            cur_anim_name = v[1]
            cur_min_percent = v[2]
            cur_max_percent = v[3]
        end

        if inst.AnimState:IsCurrentAnimation(cur_anim_name) then
            anim = cur_anim_name
            min_percent = cur_min_percent
            max_percent = cur_max_percent
            break
        end
    end

    if not anim then
        return
    end

    local percent = inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()

    if min_percent and percent < min_percent then
        return
    end

    if max_percent and percent > max_percent then
        return
    end

    local fade_shadow_builds = {
        stariliad_space_pirate_solider_lv1 = "stariliad_space_pirate_solider_lv1",
        stariliad_space_pirate_solider_lv2 = "stariliad_space_pirate_solider_lv2",
        stariliad_space_pirate_solider_lv3 = "stariliad_space_pirate_solider_lv3",
    }

    -- print("1")

    local build_name = fade_shadow_builds[inst.prefab]
    if not build_name then
        return
    end

    -- print("build_name", build_name)


    --  local shadow = SpawnAt(inst.prefab .. "_fade_shadow", inst)
    local shadow = CreateFadeShadow(build_name)
    shadow.Transform:SetPosition(inst.Transform:GetWorldPosition())
    shadow.Transform:SetRotation(inst.Transform:GetRotation())
    shadow.Transform:SetScale(inst.Transform:GetScale())
    shadow.AnimState:SetPercent(anim, percent)
    shadow:FadeOut(0.3,
        { 1, 1, 1, 0.3 },
        { 1, 1, 1, 0 },
        { 1, 1, 0, 1 },
        { 1, 1, 0, 1 }
    )
    -- local facing = shadow.AnimState:GetCurrentFacing()
    -- if facing == FACING_RIGHT or facing == FACING_LEFT then
    --     shadow.AnimState:SetSortOrder(-1)
    -- else
    --     shadow.AnimState:SetSortOrder(0)
    -- end
end

local function EnableFadeShadow(inst, enable)
    inst._fade_shadow_enable:set(enable)

    if enable and not inst.charge_vfx then
        inst.charge_vfx = inst:SpawnChild("stariliad_space_pirate_solider_charge_particle")
    elseif not enable and inst.charge_vfx then
        inst.charge_vfx:Remove()
        inst.charge_vfx = nil
    end
end

--------------------------------------------------------------------------------

local function UpdateLeader(inst)
    local leader = inst.components.follower:GetLeader()
    local leader_level = 0

    if leader then
        if #inst.search_leader_propriety == 1 then
            -- Keep exists leader
            return
        end

        for level, v in pairs(inst.search_leader_propriety) do
            if v == leader then
                leader_level = level
                break
            end
        end
    end

    if leader_level == #inst.search_leader_propriety then
        -- Keep exists leader
        return
    end

    local new_leader = nil
    local new_leader_level = leader_level
    local x, y, z = inst.Transform:GetWorldPosition()
    local possible_leaders = TheSim:FindEntities(x, y, z, 10, { "stariliad_space_pirate" }, { "INLIMBO" })

    for _, ent in pairs(possible_leaders) do
        if not IsEntityDead(ent, true) then
            for level, prefab in pairs(inst.search_leader_propriety) do
                if ent.prefab == prefab and level > new_leader_level then
                    new_leader = ent
                    new_leader_level = level
                    break
                end
            end
        end
    end

    if new_leader then
        inst.components.follower:SetLeader(new_leader)
    end
end

local function HealTask_Lv3(inst)
    inst.components.health:DoDelta(10, true)
end

local function OnHealthDelta_Lv3(inst, data)
    if data.oldpercent
        and data.newpercent
        and data.oldpercent >= inst.shield_percent
        and data.newpercent < inst.shield_percent
    then
        inst:SpawnChild("stariliad_space_pirate_solider_shield_break_fx")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/trails/hide_hit")

        inst:DoTaskInTime(11 * FRAMES, function()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/glass_break")
        end)
    end
end

--------------------------------------------------------------------------------

local function CommonFn(build_name)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(1.15, 1.15, 1.15)

    inst.AnimState:SetBank("antman")
    inst.AnimState:SetBuild(build_name)
    inst.AnimState:PlayAnimation("idle")

    inst.DynamicShadow:SetSize(1.5, .75)

    inst:AddTag("scarytoprey")
    inst:AddTag("character")
    inst:AddTag("hostile")
    inst:AddTag("stariliad_space_pirate")

    inst:AddComponent("updatelooper")

    inst._fade_shadow_enable = net_bool(inst.GUID, "inst._fade_shadow_enable", "fade_shadow_enable_dirty")
    inst._fade_shadow_enable:set(false)

    -- inst._is_swimming = net_bool(inst.GUID, "inst._is_swimming", "is_swimming_dirty")
    -- inst._is_swimming:set(false)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("fade_shadow_enable_dirty", function()
            local enable = inst._fade_shadow_enable:value()
            if enable then
                inst.components.updatelooper:AddOnUpdateFn(SpawnFadeShadowTask)
            else
                inst.components.updatelooper:RemoveOnUpdateFn(SpawnFadeShadowTask)
            end
        end)

        -- inst:ListenForEvent("is_swimming_dirty", function()
        --     local enable = inst._is_swimming:value()
        --     if enable then
        --         local vert_offset = 1

        --         inst.DynamicShadow:Enable(false)
        --         inst.AnimState:SetFloatParams(0.45, 1.0, 0.5)
        --         -- inst.AnimState:SetFloatParams(0.15, 1.0, 0.5)


        --         if inst._swim_front_fx == nil then
        --             inst._swim_front_fx = inst:SpawnChild("float_fx_front")
        --             inst._swim_front_fx.Transform:SetPosition(0, vert_offset, 0)
        --             inst._swim_front_fx.AnimState:PlayAnimation("idle_front_med", true)
        --         end

        --         if inst._swim_back_fx == nil then
        --             inst._swim_back_fx = inst:SpawnChild("float_fx_back")
        --             inst._swim_back_fx.Transform:SetPosition(0, vert_offset, 0)
        --             inst._swim_back_fx.AnimState:PlayAnimation("idle_back_med", true)
        --         end

        --         if inst._swim_shadow_fx == nil then
        --             inst._swim_shadow_fx = inst:SpawnChild("float_fx_back")
        --             inst._swim_shadow_fx.Transform:SetPosition(0, 0.5, 0)
        --             inst._swim_shadow_fx.Transform:SetScale(0.6, 1, 0.6)
        --             -- ThePlayer.replica.stariliad_ocean_land_jump.shadow_fx.Transform:SetScale(0.6, 1.2, 0.6)
        --             -- inst._swim_shadow_fx.AnimState:SetLayer(LAYER_BACKGROUND)
        --             -- inst._swim_shadow_fx.AnimState:SetSortOrder(3)

        --             inst._swim_shadow_fx.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
        --             inst._swim_shadow_fx.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)

        --             inst._swim_shadow_fx.AnimState:PlayAnimation("idle_back_med", true)
        --             inst._swim_shadow_fx.AnimState:HideSymbol("back_water_large")
        --             inst._swim_shadow_fx.AnimState:HideSymbol("water_ripple_front")
        --         end
        --     else
        --         inst.DynamicShadow:Enable(true)
        --         inst.AnimState:SetFloatParams(0, 0, 0)

        --         if inst._swim_shadow_fx and inst._swim_shadow_fx:IsValid() then
        --             inst._swim_shadow_fx:Remove()
        --         end
        --         inst._swim_shadow_fx = nil

        --         if inst._swim_shadow_fx and inst._swim_shadow_fx:IsValid() then
        --             inst._swim_shadow_fx:Remove()
        --         end
        --         inst._swim_shadow_fx = nil

        --         if inst._swim_shadow_fx and inst._swim_shadow_fx:IsValid() then
        --             inst._swim_shadow_fx:Remove()
        --         end
        --         inst._swim_shadow_fx = nil
        --     end
        -- end)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.emote_percent = 1.0

    inst.EnableFadeShadow = EnableFadeShadow

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetAllowPlatformHopping(true)

    inst:AddComponent("embarker")

    inst:AddComponent("drownable")

    inst:AddComponent("health")
    inst.components.health.destroytime = 5

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst:AddComponent("lootdropper")

    -- inst:AddComponent("amphibiouscreature")
    -- inst.components.amphibiouscreature:SetBanks("antman", "antman")
    -- inst.components.amphibiouscreature:SetEnterWaterFn(OnEnterWater)
    -- inst.components.amphibiouscreature:SetExitWaterFn(OnExitWater)

    MakeMediumFreezableCharacter(inst, "antman_torso")

    inst:SetStateGraph("SGstariliad_space_pirate_solider")
    inst:SetBrain(brain)

    inst:ListenForEvent("onhit", OnHitOther)
    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

local function SoliderLv1Fn()
    local inst = CommonFn("stariliad_space_pirate_solider_lv1")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.can_place_bomb = true
    inst.search_leader_propriety = { "stariliad_space_pirate_solider_lv2", "stariliad_space_pirate_solider_lv3" }

    inst:AddComponent("follower")

    inst.components.locomotor.walkspeed = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV1_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV1_RUNSPEED

    inst.components.health:SetMaxHealth(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV1_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV1_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV1_ATTACK_PERIOD)

    inst.components.lootdropper:SetChanceLootTable("stariliad_space_pirate_solider_lv1")

    inst:DoPeriodicTask(5, UpdateLeader)

    return inst
end


local function SoliderLv2Fn()
    local inst = CommonFn("stariliad_space_pirate_solider_lv2")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.can_use_attack2 = true
    inst.can_charge = true
    inst.emote_percent = 0.75
    inst.search_leader_propriety = { "stariliad_space_pirate_solider_lv3" }

    inst:AddComponent("follower")

    inst:AddComponent("leader")

    inst.components.locomotor.walkspeed = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV2_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV2_RUNSPEED

    inst.components.health:SetMaxHealth(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV2_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV2_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV2_ATTACK_PERIOD)

    inst.components.lootdropper:SetChanceLootTable("stariliad_space_pirate_solider_lv2")

    inst:DoPeriodicTask(5, UpdateLeader)

    return inst
end

local function SoliderLv3Fn()
    local inst = CommonFn("stariliad_space_pirate_solider_lv3")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.can_use_attack2 = true
    inst.can_charge = true
    inst.emote_percent = 0.2
    inst.shield_percent = 0.5

    inst:AddComponent("leader")

    inst.components.locomotor.walkspeed = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV3_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV3_RUNSPEED

    inst.components.health:SetMaxHealth(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV3_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV3_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV3_ATTACK_PERIOD)

    inst.components.lootdropper:SetChanceLootTable("stariliad_space_pirate_solider_lv3")

    inst.heal_task = inst:DoPeriodicTask(5, HealTask_Lv3)

    inst:ListenForEvent("healthdelta", OnHealthDelta_Lv3)

    return inst
end

--------------------------------------------------------------------------------------

-- local fade_shadow_builds = {
--     stariliad_space_pirate_solider_lv1 = "stariliad_space_pirate_solider_lv1",
--     stariliad_space_pirate_solider_lv2 = "stariliad_space_pirate_solider_lv2",
--     stariliad_space_pirate_solider_lv3 = "stariliad_space_pirate_solider_lv3",
-- }

-- local function FadeShadowFn(prefab_name, build_name)
--     local function fn()
--         local inst = AnimFn(build_name)

--         inst:AddTag("FX")
--         inst:AddTag("NOCLICK")

--         -- inst.Transform:SetOrientation(ANIM_ORIENTATION.OnGround)
--         -- inst.Transform:SetLayer(LAYER_BACKGROUND)
--         -- inst.Transform:SetSortOrder(3)

--         inst.AnimState:SetFinalOffset(-1)
--         inst.AnimState:UsePointFiltering(true)

--         if not TheWorld.ismastersim then
--             return inst
--         end

--         inst.persists = false

--         inst:AddComponent("updatelooper")

--         inst.FadeOut = function(inst, duration, start_mult_colour, end_mult_colour, start_add_colour, end_add_colour)
--             inst.start_time = GetTime()

--             local delta_mult_r, delta_mult_g, delta_mult_b, delta_mult_a
--             local delta_add_r, delta_add_g, delta_add_b, delta_add_a

--             if start_mult_colour and end_mult_colour then
--                 delta_mult_r = end_mult_colour[1] - start_mult_colour[1]
--                 delta_mult_g = end_mult_colour[2] - start_mult_colour[2]
--                 delta_mult_b = end_mult_colour[3] - start_mult_colour[3]
--                 delta_mult_a = end_mult_colour[4] - start_mult_colour[4]

--                 inst.AnimState:SetMultColour(start_mult_colour[1], start_mult_colour[2], start_mult_colour[3],
--                     start_mult_colour[4])
--             end

--             if start_add_colour and end_add_colour then
--                 delta_add_r = end_add_colour[1] - start_add_colour[1]
--                 delta_add_g = end_add_colour[2] - start_add_colour[2]
--                 delta_add_b = end_add_colour[3] - start_add_colour[3]
--                 delta_add_a = end_add_colour[4] - start_add_colour[4]

--                 inst.AnimState:SetAddColour(start_add_colour[1], start_add_colour[2], start_add_colour[3],
--                     start_add_colour[4])
--             end

--             inst.components.updatelooper:AddOnUpdateFn(function(inst, dt)
--                 local percent = (GetTime() - inst.start_time) / duration

--                 if percent > 1 then
--                     inst:Remove()
--                     return
--                 end

--                 if start_mult_colour and end_mult_colour then
--                     local r = start_mult_colour[1] + delta_mult_r * percent
--                     local g = start_mult_colour[2] + delta_mult_g * percent
--                     local b = start_mult_colour[3] + delta_mult_b * percent
--                     local a = start_mult_colour[4] + delta_mult_a * percent
--                     inst.AnimState:SetMultColour(r, g, b, a)
--                 end

--                 if start_add_colour and end_add_colour then
--                     local r = start_add_colour[1] + delta_add_r * percent
--                     local g = start_add_colour[2] + delta_add_g * percent
--                     local b = start_add_colour[3] + delta_add_b * percent
--                     local a = start_add_colour[4] + delta_add_a * percent
--                     inst.AnimState:SetAddColour(r, g, b, a)
--                 end
--             end)
--         end

--         return inst
--     end

--     return Prefab(prefab_name, fn, assets)
-- end

-- local fade_shadow_prefabs = {}
-- for prefab_name, build_name in pairs(fade_shadow_builds) do
--     table.insert(fade_shadow_prefabs, FadeShadowFn(prefab_name .. "_fade_shadow", build_name))
-- end




local function CreateRing()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("bearger_ring_fx")
    inst.AnimState:SetBuild("bearger_ring_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFrame(5)
    inst.AnimState:SetMultColour(1, 1, 0, 1)

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetFinalOffset(1)

    local s = 0.2
    inst.Transform:SetScale(s, s, s)

    inst:AddTag("FX")

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end


local function RingFxFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")
    inst.AnimState:SetMultColour(0, 0, 0, 0)

    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst.entity:AddSoundEmitter()

        inst._anim = CreateRing()
        inst:AddChild(inst._anim)
        inst._anim.entity:AddFollower()
        inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -100, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

local function ShieldFullFxFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    inst.AnimState:SetBank("wx78_shield_fx")
    inst.AnimState:SetBuild("wx78_shield_fx")
    inst.AnimState:PlayAnimation("full")
    inst.AnimState:SetDeltaTimeMultiplier(1.33)
    inst.AnimState:SetMultColour(243 / 255, 187 / 255, 6 / 255, 1)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function ShieldBreakFxFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    inst.AnimState:SetBank("wx78_shield_fx")
    inst.AnimState:SetBuild("wx78_shield_fx")
    inst.AnimState:PlayAnimation("full_to_empty")
    inst.AnimState:SetMultColour(243 / 255, 187 / 255, 6 / 255, 1)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    inst:DoTaskInTime(11 * FRAMES, function()
        local parent = inst.entity:GetParent()
        if parent ~= nil then
            inst.Transform:SetPosition(inst.Transform:GetWorldPosition())
            parent:RemoveChild(inst)
        end
    end)

    return inst
end

return Prefab("stariliad_space_pirate_solider_lv1", SoliderLv1Fn, assets),
    Prefab("stariliad_space_pirate_solider_lv2", SoliderLv2Fn, assets),
    Prefab("stariliad_space_pirate_solider_lv3", SoliderLv3Fn, assets),
    Prefab("stariliad_space_pirate_solider_charge_start_ring", RingFxFn, assets),
    Prefab("stariliad_space_pirate_solider_shield_full_fx", ShieldFullFxFn, assets),
    Prefab("stariliad_space_pirate_solider_shield_break_fx", ShieldBreakFxFn, assets)
