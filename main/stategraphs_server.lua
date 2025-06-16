require("stategraphs/commonstates")

-- attack
AddStategraphPostInit("wilson", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        local old_rets = old_ATTACK(inst, action)
        local weapon = inst.components.combat:GetWeapon()
        if old_rets ~= nil
            and weapon ~= nil
            and not (inst.components.rider and inst.components.rider:IsRiding()) then
            if weapon.prefab == "blythe_blaster" then
                local proj_data = weapon.components.stariliad_pistol:GetProjectileData()
                return proj_data.attack_sg
            end
        end

        return old_rets
    end
end)

-- castaoe
AddStategraphPostInit("wilson", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local old_rets = old_CASTAOE(inst, action)
        local weapon = inst.components.combat:GetWeapon()
        if old_rets ~= nil
            and weapon ~= nil
            and not (inst.components.rider and inst.components.rider:IsRiding()) then
            if weapon.prefab == "blythe_blaster" then
                -- StarIliadDebug.PrintStackTrace()

                local proj_data = weapon.components.stariliad_pistol:GetProjectileData()

                if inst.sg:HasStateTag("aoe") then
                    if proj_data.aoe_reject_fn then
                        proj_data.aoe_reject_fn(inst, action)
                    end
                    return
                else
                    return proj_data.castaoe_sg
                end
                -- local proj_data = weapon.components.stariliad_pistol:GetProjectileData()
                -- return proj_data.castaoe_sg
            end
        end

        return old_rets
    end
end)

-- locomote
AddStategraphPostInit("wilson", function(sg)
    local old_locomote = sg.events["locomote"].fn

    sg.events["locomote"].fn = function(inst, data, ...)
        if inst.sg:HasStateTag("busy") or
            inst.sg:HasStateTag("overridelocomote") then
            return
        end

        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local is_swimming = inst.components.stariliad_ocean_land_jump and
            inst.components.stariliad_ocean_land_jump:IsSwimming()

        local handle_by_old = true



        if inst:HasTag("ingym") then

        elseif inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent") or
            inst.sg:HasStateTag("waking") then -- wakeup on locomote

        elseif is_moving and not should_move then
            if inst:HasTag("acting") then

            else
                if not (inst.components.rider and inst.components.rider:IsRiding()) then
                    if is_swimming then
                        handle_by_old = false
                        inst.sg:GoToState("blythe_swim_stop")
                    end
                end
            end
        elseif not is_moving and should_move then
            if not (inst.components.rider and inst.components.rider:IsRiding()) then
                if is_swimming then
                    if data and data.dir then
                        inst.components.locomotor:SetMoveDir(data.dir)
                    end
                    handle_by_old = false
                    inst.sg:GoToState("blythe_swim_start")
                end
            end
        elseif data.force_idle_state and
            not (is_moving or should_move or inst.sg:HasStateTag("idle") or
                inst:HasTag("is_furling")) then

        end

        if handle_by_old then
            return old_locomote(inst, data)
        else

        end
    end
end)

-- attacked
AddStategraphPostInit("wilson", function(sg)
    local old_attacked = sg.events["attacked"].fn

    sg.events["attacked"].fn = function(inst, ...)
        if inst.sg.currentstate.name == "blythe_parry" then
            return
        end

        return old_attacked(inst, ...)
    end
end)


-- knockback
AddStategraphPostInit("wilson", function(sg)
    local old_knockback = sg.events["knockback"].fn

    sg.events["knockback"].fn = function(inst, data, ...)
        if inst.sg.currentstate.name == "blythe_parry" then
            inst.sg:GoToState("knockbacklanded", data)
            return
        end

        if inst.sg.currentstate.name == "blythe_dodge" and inst.components.health:IsInvincible() then
            return
        end

        return old_knockback(inst, data, ...)
    end
end)

local function PlayWaterSound(inst, volume)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small", nil, volume, true)
end

local function PlayRunWaterSound(inst)
    return PlayWaterSound(inst, 0.5)
end

local function DoEquipmentFoleySounds(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if v.foleysound ~= nil then
            inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
        end
    end
end

local function DoFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    if inst.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
    end
end


local function SpawnAimReticule(inst, equip, buffaction)
    if equip
        and equip.components.stariliad_pistol
        and buffaction
        and buffaction.target
        and buffaction.target:IsValid() then
        local proj_data = equip.components.stariliad_pistol:GetProjectileData()
        local aim_reticule = proj_data and proj_data.aim_reticule
        if aim_reticule then
            inst.sg.statemem.aim_reticule = SpawnPrefab(aim_reticule)
            inst.sg.statemem.aim_reticule:AttachTarget(buffaction.target)
        end
    end
end

local function KillAimReticule(inst)
    if inst.sg.statemem.aim_reticule and inst.sg.statemem.aim_reticule:IsValid() then
        inst.sg.statemem.aim_reticule:KillFX()
    end
end

local function IsShootChained(inst)
    if inst.sg.laststate == inst.sg.currentstate then
        return true
    end

    if inst:HasTag("blythe_can_counter") then
        print("is counter !")
        return true
    end

    return false
end

local function CreateShootAttackState(name, enter_bonus, shoot_time, free_time, chain_bonus)
    local state = State {
        name = name,
        tags = { "attack", "abouttoattack", "notalking", "autopredict" },

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            if buffaction and buffaction.action == ACTIONS.ATTACK then
                inst.components.combat:SetTarget(target)
                inst.components.combat:StartAttack()
            end

            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("hand_shoot")
            inst.sg.statemem.chained = IsShootChained(inst)

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(chain_bonus + enter_bonus)
                inst.sg:SetTimeout(math.max(
                    free_time - enter_bonus - chain_bonus,
                    inst.components.combat.min_attack_period))
            else
                inst.AnimState:SetTime(enter_bonus)
                inst.sg:SetTimeout(math.max(free_time - enter_bonus,
                    inst.components.combat.min_attack_period))
            end

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
            end

            inst.sg.statemem.weapon = equip
            inst.sg.statemem.action = buffaction

            SpawnAimReticule(inst, equip, buffaction)
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("shoot_at")
            inst.sg:AddStateTag("idle")
        end,

        timeline =
        {
            TimeEvent(shoot_time - enter_bonus - chain_bonus, function(inst)
                if inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)
                    -- print("inst.bufferedaction = ", inst.bufferedaction)

                    inst.bufferedaction = inst.sg.statemem.action
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    -- print("inst.bufferedaction = ", inst.bufferedaction)

                    inst.bufferedaction = inst.sg.statemem.action
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end

            KillAimReticule(inst)
        end,
    }

    return state
end

local function CreateShootCastAoeState(name, enter_bonus, shoot_time, free_time, chain_bonus)
    local state = State {
        name = name,
        tags = { "notalking", "aoe", "stariliad_no_face_point" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")
            inst.sg.statemem.chained = IsShootChained(inst)

            inst.components.locomotor:Stop()

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(chain_bonus + enter_bonus)
                inst.sg:SetTimeout(free_time - enter_bonus - chain_bonus)
            else
                inst.AnimState:SetTime(enter_bonus)
                inst.sg:SetTimeout(free_time - enter_bonus)
            end

            inst.sg.statemem.weapon = equip
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("aoe")
            inst.sg:RemoveStateTag("stariliad_no_face_point")
            inst.sg:AddStateTag("idle")
        end,

        timeline =
        {
            TimeEvent(shoot_time - enter_bonus - chain_bonus, function(inst)
                if inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
                end
            end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)

        end,
    }

    return state
end

local function CreateShootAtState(name, enter_bonus, shoot_time, free_time, chain_bonus)
    local state = State {
        name = name,
        tags = { "notalking", "busy", },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")
            inst.sg.statemem.chained = IsShootChained(inst)

            inst.components.locomotor:Stop()

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(chain_bonus + enter_bonus)
                inst.sg:SetTimeout(free_time - enter_bonus - chain_bonus)
            else
                inst.AnimState:SetTime(enter_bonus)
                inst.sg:SetTimeout(free_time - enter_bonus)
            end

            inst.sg.statemem.weapon = equip

            SpawnAimReticule(inst, equip, buffaction)
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:AddStateTag("idle")
        end,

        timeline =
        {
            TimeEvent(shoot_time - enter_bonus - chain_bonus, function(inst)
                if inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
                end
            end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            KillAimReticule(inst)
        end,
    }

    return state
end

AddStategraphState("wilson",
    CreateShootAttackState("blythe_shoot_beam",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)

-- AddStategraphState("wilson",
--     CreateShootAttackState("blythe_shoot_beam2",
--         { "shoot_at", "notalking", "autopredict" },
--         TUNING.BLYTHE_BEAM_ENTER_BONUS,
--         TUNING.BLYTHE_BEAM_SHOOT_TIME,
--         TUNING.BLYTHE_BEAM_FREE_TIME,
--         TUNING.BLYTHE_BEAM_CHAIN_BONUS)
-- )

-- AddStategraphState("wilson",
--     CreateShootCastAoeState("blythe_shoot_beam_castaoe",
--         TUNING.BLYTHE_BEAM_ENTER_BONUS,
--         TUNING.BLYTHE_BEAM_SHOOT_TIME,
--         TUNING.BLYTHE_BEAM_FREE_TIME,
--         TUNING.BLYTHE_BEAM_CHAIN_BONUS)
-- )

-- AddStategraphState("wilson",
--     CreateShootAtState("blythe_shoot_beam_shoot_at",
--         TUNING.BLYTHE_BEAM_ENTER_BONUS,
--         TUNING.BLYTHE_BEAM_SHOOT_TIME,
--         TUNING.BLYTHE_BEAM_FREE_TIME,
--         TUNING.BLYTHE_BEAM_CHAIN_BONUS)
-- )

------------------------------------------------------

AddStategraphState("wilson",
    CreateShootAttackState("blythe_shoot_missile",
        TUNING.BLYTHE_MISSILE_ENTER_BONUS,
        TUNING.BLYTHE_MISSILE_SHOOT_TIME,
        TUNING.BLYTHE_MISSILE_FREE_TIME,
        TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
)

-- AddStategraphState("wilson",
--     CreateShootAttackState("blythe_shoot_missile2",
--         { "shoot_at", "notalking", "autopredict" },
--         TUNING.BLYTHE_MISSILE_ENTER_BONUS,
--         TUNING.BLYTHE_MISSILE_SHOOT_TIME,
--         TUNING.BLYTHE_MISSILE_FREE_TIME,
--         TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
-- )

-- AddStategraphState("wilson",
--     CreateShootCastAoeState("blythe_shoot_missile_castaoe",
--         TUNING.BLYTHE_MISSILE_ENTER_BONUS,
--         TUNING.BLYTHE_MISSILE_SHOOT_TIME,
--         TUNING.BLYTHE_MISSILE_FREE_TIME,
--         TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
-- )
-------------------------------------------------------



AddStategraphState("wilson", State {
    name = "blythe_release_ice_fog2",
    tags = { "attack", "notalking", "abouttoattack", "autopredict", "canrotate" },

    onenter = function(inst)
        if inst.components.combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()

        if target ~= nil and target:IsValid() then
            inst:FacePoint(target.Transform:GetWorldPosition())
            inst.sg.statemem.attacktarget = target
            inst.sg.statemem.retarget = target
        end
        inst.sg.statemem.action = buffaction
        inst.sg.statemem.release_period = 2 * FRAMES

        inst.AnimState:PlayAnimation("hand_shoot")
    end,

    onupdate = function(inst, dt)
        local target = inst.sg.statemem.attacktarget
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local cur_proj = inst.components.blythe_powersuit_configure and
            inst.components.blythe_powersuit_configure.projectile_prefab

        if equip
            and equip:IsValid()
            and (target == nil or inst.components.combat:CanTarget(target))
            and inst.components.playercontroller
            and inst.components.playercontroller:IsAnyOfControlsPressed(CONTROL_PRIMARY, CONTROL_SECONDARY, CONTROL_ATTACK)
            and not inst.sg.statemem.target_miss
            and cur_proj == "blythe_ice_fog" then
            -- local anim_time = inst.AnimState:GetCurrentAnimationTime()
            -- local hold_time = TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME
            -- if anim_time > hold_time then
            --     inst.AnimState:SetTime(hold_time)
            -- end

            if inst.sg.statemem.release_ice_fog then
                inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME)

                inst.sg.statemem.cooldown = inst.sg.statemem.cooldown - dt
                if inst.sg.statemem.cooldown <= 0 then
                    if inst.bufferedaction then
                        inst:PerformBufferedAction()
                    else
                        inst.sg.statemem.action.options.instant = true
                        inst.sg.statemem.action.options.no_predict_fastforward = true
                        inst:PushBufferedAction(inst.sg.statemem.action)
                    end
                    inst.sg.statemem.cooldown = inst.sg.statemem.release_period
                end
            end
        else
            local anim_time = inst.AnimState:GetCurrentAnimationTime()
            if anim_time >= TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME then
                inst.AnimState:PlayAnimation("hand_shoot")
                inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_FINISH_TIME)
                inst.sg:GoToState("idle", true)
            end
        end
    end,

    timeline =
    {
        TimeEvent(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME, function(inst)
            inst.sg.statemem.cooldown = 0
            inst.sg.statemem.release_ice_fog = true
            inst.sg:RemoveStateTag("abouttoattack")

            inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/ice_fog_loop", "ice_fog_loop")
        end),
    },

    events =
    {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
        EventHandler("onmissother", function(inst)
            inst.sg.statemem.target_miss = true
        end),


    },


    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end

        if inst.SoundEmitter:PlayingSound("ice_fog_loop") then
            inst.SoundEmitter:KillSound("ice_fog_loop")
        end

        inst:ClearBufferedAction()
    end,
}
)


AddStategraphState("wilson", State {
    name = "blythe_release_ice_fog_castaoe2",
    tags = { "notalking", "aoe", "stariliad_no_face_point", "autopredict" },

    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        inst.AnimState:PlayAnimation("hand_shoot")

        inst.components.locomotor:Stop()

        inst.sg.statemem.action = buffaction
        inst.sg.statemem.release_period = 2 * FRAMES
    end,

    onupdate = function(inst, dt)
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local cur_proj = inst.components.blythe_powersuit_configure and
            inst.components.blythe_powersuit_configure.projectile_prefab

        if equip
            and equip:IsValid()
            and inst.components.playercontroller
            and inst.components.playercontroller:IsAnyOfControlsPressed(CONTROL_PRIMARY)
            and cur_proj == "blythe_ice_fog" then
            if inst.sg.statemem.release_ice_fog then
                inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME)

                inst.sg.statemem.cooldown = inst.sg.statemem.cooldown - dt
                if inst.sg.statemem.cooldown <= 0 then
                    if inst.bufferedaction then
                        inst:ForceFacePoint(inst.bufferedaction:GetActionPoint())
                        inst:PerformBufferedAction()
                    else
                        inst:ForceFacePoint(inst.sg.statemem.action:GetActionPoint())

                        inst.sg.statemem.action.options.instant = true
                        inst.sg.statemem.action.options.no_predict_fastforward = true
                        inst:PushBufferedAction(inst.sg.statemem.action)
                    end
                    inst.sg.statemem.cooldown = inst.sg.statemem.release_period


                    if not inst.SoundEmitter:PlayingSound("ice_fog_loop") then
                        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/ice_fog_loop", "ice_fog_loop")
                    end
                end
            end
        else
            local anim_time = inst.AnimState:GetCurrentAnimationTime()
            if anim_time >= TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME then
                inst.AnimState:PlayAnimation("hand_shoot")
                inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_FINISH_TIME)
                inst.sg:GoToState("idle", true)
            end
        end
    end,

    timeline =
    {
        TimeEvent(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME, function(inst)
            inst.sg.statemem.cooldown = 0
            inst.sg.statemem.release_ice_fog = true
        end),
    },

    events =
    {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },


    onexit = function(inst)
        if inst.SoundEmitter:PlayingSound("ice_fog_loop") then
            inst.SoundEmitter:KillSound("ice_fog_loop")
        end

        inst:ClearBufferedAction()
    end,
}
)

AddStategraphState("wilson",
    State {
        name = "stariliad_ocean_land_jump",
        tags = { "busy", "nopredict", "jumping" },

        onenter = function(inst)
            local bufferedaction = inst:GetBufferedAction()
            local target_pos = bufferedaction and bufferedaction:GetActionPoint()
            if not target_pos or not inst.components.stariliad_ocean_land_jump then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("jumpout")
            inst.AnimState:SetTime(4 * FRAMES)


            inst.sg.statemem.should_update = true
            inst.sg.statemem.stopped = false

            inst.components.stariliad_ocean_land_jump:SetJumpDuration(14 * FRAMES)
            inst.components.stariliad_ocean_land_jump:OnStartJump(target_pos)

            -- inst.SoundEmitter:PlaySound("spark_hammer/sfx/enm_hand_jump")
            inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.should_update then
                inst.components.stariliad_ocean_land_jump:OnJumpUpdate()
            end
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst:PerformBufferedAction()

                inst.sg:RemoveStateTag("jumping")

                inst.sg.statemem.should_update = false
                inst.components.stariliad_ocean_land_jump:OnStopJump()

                inst.sg.statemem.stopped = true

                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.sg:RemoveStateTag("jumping")

            if inst.sg.statemem.stopped == false then
                inst.components.stariliad_ocean_land_jump:OnStopJump()
            end
        end
    }
)

AddStategraphState("wilson",
    State {
        name = "blythe_swim_start",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()

            inst.sg.mem.footsteps = 0
            inst.sg.statemem.gravity_control = StarIliadBasic.HasGravityControl(inst)

            if inst.sg.statemem.gravity_control then
                inst.AnimState:PlayAnimation("run_pre")
            else
                inst.AnimState:PlayAnimation("careful_walk_pre")
            end
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline = {
            TimeEvent(0 * FRAMES, function(inst)
                if not inst.sg.statemem.gravity_control then
                    PlayWaterSound(inst)
                    DoFoleySounds(inst)
                end
            end),

            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.gravity_control then
                    -- PlayWaterSound(inst)
                    PlayRunWaterSound(inst)
                    DoFoleySounds(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("blythe_swim")
                end
            end),
        },
    }
)

AddStategraphState("wilson",
    State {
        name = "blythe_swim",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()

            inst.sg.statemem.gravity_control = StarIliadBasic.HasGravityControl(inst)

            local anim = "run_loop"
            if inst.sg.statemem.gravity_control then
                anim = "run_loop"
            else
                anim = "careful_walk"
            end

            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.gravity_control then
                    -- PlayWaterSound(inst)
                    PlayRunWaterSound(inst)
                    DoFoleySounds(inst)
                end
            end),


            TimeEvent(11 * FRAMES, function(inst)
                if not inst.sg.statemem.gravity_control then
                    PlayWaterSound(inst)
                    DoFoleySounds(inst)
                end
            end),

            TimeEvent(15 * FRAMES, function(inst)
                if inst.sg.statemem.gravity_control then
                    -- PlayWaterSound(inst)
                    PlayRunWaterSound(inst)
                    DoFoleySounds(inst)
                end
            end),

            TimeEvent(26 * FRAMES, function(inst)
                if not inst.sg.statemem.gravity_control then
                    PlayWaterSound(inst)
                    DoFoleySounds(inst)
                end
            end),
        },

        events =
        {

        },

        ontimeout = function(inst)
            inst.sg:GoToState("blythe_swim")
        end,
    }
)

AddStategraphState("wilson",
    State {
        name = "blythe_swim_stop",
        tags = { "canrotate", "idle", "autopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.sg.statemem.gravity_control = StarIliadBasic.HasGravityControl(inst)

            if inst.sg.statemem.gravity_control then
                inst.AnimState:PlayAnimation("run_pst")
            else
                inst.AnimState:PlayAnimation("careful_walk_pst")
            end
        end,

        timeline = {},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
)


AddStategraphState("wilson", State {
    name = "blythe_dodge",
    tags = { "busy", "nopredict", "nointerrupt", "blythe_dodge" },

    onenter = function(inst, data)
        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Show("ARM_normal")
        inst.AnimState:PlayAnimation("blythe_speedrun_pre")
        inst.AnimState:PushAnimation("blythe_speedrun_loop", true)

        inst.components.blythe_skill_dodge:OnDodgeStart(data.pos)

        inst.sg:SetTimeout(0.2)
        -- inst.sg:SetTimeout(0.33)
    end,

    onupdate = function(inst)
        inst.components.blythe_skill_dodge:OnDodging()
    end,

    timeline = {
        -- TimeEvent(0.15, function(inst)
        --     if not inst.sg.statemem.dodge_stop then
        --         inst.components.blythe_skill_dodge:ClearDodgeFX()
        --     end
        -- end),
    },

    ontimeout = function(inst)
        -- if inst.sg.statemem.equip then
        --     inst.AnimState:PlayAnimation("pickup_pst")
        -- else
        --     inst.AnimState:PlayAnimation("blythe_speedrun_pst")
        -- end

        -- inst.AnimState:PlayAnimation("blythe_speedrun_pst")
        -- inst.AnimState:SetTime(0.05)
        -- inst.AnimState:PlayAnimation("give_pst")
        -- inst.AnimState:SetFrame(5)

        -- if inst.sg.statemem.equip then
        --     inst.AnimState:PlayAnimation("blythe_speedrun_withitem_pst")
        -- else
        --     inst.AnimState:PlayAnimation("blythe_speedrun_pst")
        -- end

        -- inst.AnimState:PlayAnimation("blythe_speedrun_withitem_pst")
        -- inst.AnimState:SetTime(0.05)

        inst.AnimState:PlayAnimation("run_pst")

        if not inst.sg.statemem.dodge_stop then
            -- print("OnDodgeStop ontimeout")
            inst.components.blythe_skill_dodge:OnDodgeStop()
            inst.sg.statemem.dodge_stop = true
        end

        inst.sg:GoToState("idle", true)
    end,

    onexit = function(inst)
        if not inst.sg.statemem.dodge_stop then
            -- print("OnDodgeStop onexit")
            inst.components.blythe_skill_dodge:OnDodgeStop()
            inst.sg.statemem.dodge_stop = true
        end

        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equip then
            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
        end
    end
})

AddStategraphState("wilson",
    State {
        name = "blythe_parry",
        -- tags = { "parrying", "busy", "nomorph", },
        tags = { "parrying", "busy", "nomorph", "autopredict" },
        -- tags = { "parrying", "busy", "nomorph", "pausepredict" },


        onenter = function(inst, data)
            data = data or {}
            if not inst.components.blythe_skill_parry then
                inst.sg:GoToState("idle")
                return
            end

            inst.components.locomotor:Stop()

            local parry_target_pos = data.pos
            -- local function callback(_, data)
            --     parry_target_pos = data.pos
            -- end
            -- inst:ListenForEvent("blythe_parry_target_pos", callback)
            -- inst:PerformBufferedAction()
            -- inst:RemoveEventCallback("blythe_parry_target_pos", callback)

            if parry_target_pos then
                inst:ForceFacePoint(parry_target_pos)
            end

            inst.AnimState:PlayAnimation("blythe_parry")

            inst.components.blythe_skill_parry:OnStartParry()

            inst.sg.statemem.stop_when_exit = true

            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)


            -- if inst.components.playercontroller ~= nil then
            --     inst.components.playercontroller:RemotePausePrediction(3)
            -- end
            inst.sg:SetTimeout(13 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.components.blythe_skill_parry:OnStopParry()
            inst.sg.statemem.stop_when_exit = false

            inst.sg:GoToState("idle", true)
        end,

        timeline = {
            -- TimeEvent(10 * FRAMES, function(inst)
            --     inst.components.blythe_skill_parry:OnStopParry()
            --     inst.sg.statemem.stop_when_exit = false
            -- end),

            TimeEvent(5 * FRAMES, function(inst)
                inst.components.blythe_skill_parry:TrySpawnWaterSplash()
            end),

            -- TimeEvent(10 * FRAMES, function(inst)
            --     inst.sg:RemoveStateTag("busy")
            -- end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            print("onexit at", inst.AnimState:GetCurrentAnimationFrame())
            if inst.sg.statemem.stop_when_exit then
                inst.components.blythe_skill_parry:OnStopParry()
            end
        end
    }
)

--------------------------------------------------------------------

local FREEZE_COLOUR_2 = { 82 / 255, 115 / 255, 124 / 255, 1 }

AddStategraphEvent("gelblob", CommonHandlers.OnFreezeEx())

local function onunfreeze(inst)
    inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle")
end

local function onthaw(inst)
    inst.sg.statemem.thawing = true
    inst.sg:GoToState("thaw")
end

local function onenterfrozenpre(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:StopMoving()
    end
    -- inst.AnimState:PlayAnimation("frozen", true)
    -- inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

    -- inst.AnimState:OverrideSymbol("goo_parts", "stariliad_gelblob_frozen", "frozen")

    inst.AnimState:Pause()
    -- inst.AnimState:SetAddColour(0, 1, 1, 1)
    inst.components.colouradder:PushColour("freezable_2", FREEZE_COLOUR_2[1], FREEZE_COLOUR_2[2], FREEZE_COLOUR_2[3],
        FREEZE_COLOUR_2[4])

    inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
end

local function onenterfrozenpst(inst)
    --V2C: cuz... freezable component and SG need to match state,
    --     but messages to SG are queued, so it is not great when
    --     when freezable component tries to change state several
    --     times within one frame...
    if inst.components.freezable == nil then
        onunfreeze(inst)
    elseif inst.components.freezable:IsThawing() then
        onthaw(inst)
    elseif not inst.components.freezable:IsFrozen() then
        onunfreeze(inst)
    end
end

local function onexitfrozen(inst)
    if not inst.sg.statemem.thawing then
        -- inst.AnimState:ClearOverrideSymbol("swap_frozen")
        -- inst.AnimState:ClearOverrideSymbol("goo_parts")

        inst.AnimState:Resume()
        -- inst.AnimState:SetAddColour(0, 0, 0, 0)
        inst.components.colouradder:PopColour("freezable_2")
    end
end

local function onenterthawpre(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:StopMoving()
    end
    -- inst.AnimState:PlayAnimation("frozen_loop_pst", true)
    -- inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
    -- inst.AnimState:OverrideSymbol("goo_parts", "stariliad_gelblob_frozen", "frozen")

    inst.AnimState:Pause()
    -- inst.AnimState:SetAddColour(0, 1, 1, 1)
    inst.components.colouradder:PushColour("freezable_2", FREEZE_COLOUR_2[1], FREEZE_COLOUR_2[2], FREEZE_COLOUR_2[3],
        FREEZE_COLOUR_2[4])


    inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
end

local function onenterthawpst(inst)
    --V2C: cuz... freezable component and SG need to match state,
    --     but messages to SG are queued, so it is not great when
    --     when freezable component tries to change state several
    --     times within one frame...
    if inst.components.freezable == nil or not inst.components.freezable:IsFrozen() then
        onunfreeze(inst)
    end
end



local function onexitthaw(inst)
    inst.AnimState:Resume()
    -- inst.AnimState:SetAddColour(0, 0, 0, 0)
    inst.components.colouradder:PopColour("freezable_2")

    inst.SoundEmitter:KillSound("thawing")
    -- inst.AnimState:ClearOverrideSymbol("swap_frozen")
    -- inst.AnimState:ClearOverrideSymbol("goo_parts")
end

local gelblob_freeze_states = {
    State {
        name = "frozen",
        tags = { "busy", "frozen" },

        onenter = function(inst)
            onenterfrozenpre(inst)
            onenterfrozenpst(inst)
        end,

        events =
        {
            EventHandler("unfreeze", onunfreeze),
            EventHandler("onthaw", onthaw),
        },

        onexit = function(inst)
            onexitfrozen(inst)
        end,
    },

    State {
        name = "thaw",
        tags = { "busy", "thawing" },

        onenter = function(inst)
            onenterthawpre(inst)
            onenterthawpst(inst)

            local anim = "contact_jiggle"
            anim = anim .. inst.size
            inst.AnimState:Resume()
            inst.AnimState:PlayAnimation(anim, true)
            -- inst.back.AnimState:PlayAnimation(anim, true)
            inst.AnimState:SetDeltaTimeMultiplier(3)
        end,

        events =
        {
            EventHandler("unfreeze", onunfreeze),
        },

        onexit = function(inst)
            onexitthaw(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
    }
}

-- local function onoverridesymbols(inst)
--     inst.AnimState:SetMultColour(0, 1, 1, 1)
-- end

-- local function onclearsymbols(inst)
--     inst.AnimState:SetMultColour(1, 1, 1, 1)
-- end

-- CommonStates.AddFrozenStates(gelblob_freeze_states, onoverridesymbols, onclearsymbols)

for _, v in pairs(gelblob_freeze_states) do
    AddStategraphState("gelblob", v)
end

AddStategraphPostInit("gelblob", function(sg)
    local idle_state = sg.states["idle"]
    if not idle_state then
        return
    end

    local old_onenter = idle_state.onenter

    idle_state.onenter = function(inst, ...)
        local ret = old_onenter(inst, ...)
        if inst.components.freezable then
            if inst.components.freezable:IsFrozen() then
                inst.sg:GoToState("frozen")
            elseif inst.components.freezable:IsThawing() then
                inst.sg:GoToState("thaw")
            elseif not inst.components.freezable:IsFrozen() then
            end
        end
        return ret
    end
end)

-- ------------------------------------------------------------------
