-- attack
AddStategraphPostInit("wilson_client", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        local old_rets = old_ATTACK(inst, action)
        local weapon = inst.replica.combat:GetWeapon()
        if old_rets ~= nil
            and weapon ~= nil
            and not (inst.replica.rider and inst.replica.rider:IsRiding()) then
            if weapon.prefab == "blythe_blaster" then
                local proj_data = weapon.replica.stariliad_pistol:GetProjectileData()
                return proj_data.attack_sg
            end
        end

        if old_rets == nil then
            print("old_rets is", old_rets)
        end

        return old_rets
    end
end)

-- castaoe
AddStategraphPostInit("wilson_client", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local old_rets = old_CASTAOE(inst, action)
        local weapon = inst.replica.combat:GetWeapon()
        if old_rets ~= nil
            and weapon ~= nil
            and not (inst.replica.rider and inst.replica.rider:IsRiding()) then
            if weapon.prefab == "blythe_blaster" then
                local proj_data = weapon.replica.stariliad_pistol:GetProjectileData()

                if inst.sg:HasStateTag("aoe") then
                    if proj_data.aoe_reject_fn then
                        proj_data.aoe_reject_fn(inst, action)
                    end
                    return
                else
                    return proj_data.castaoe_sg
                end
                -- local proj_data = weapon.replica.stariliad_pistol:GetProjectileData()
                -- return proj_data.castaoe_sg
            end
        end

        return old_rets
    end
end)

-- locomote
AddStategraphPostInit("wilson_client", function(sg)
    local old_locomote = sg.events["locomote"].fn
    sg.events["locomote"].fn = function(inst, data)
        --#HACK for hopping prediction: ignore busy when boathopping... (?_?)
        if (inst.sg:HasStateTag("busy") or inst:HasTag("busy")) and
            not (inst.sg:HasStateTag("boathopping") or inst:HasTag("boathopping")) then
            return
        elseif inst.sg:HasStateTag("overridelocomote") then
            return
        end

        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local is_swimming = inst.replica.stariliad_ocean_land_jump and
            inst.replica.stariliad_ocean_land_jump:IsSwimming()

        local handle_by_old = true


        if inst:HasTag("ingym") then

        elseif inst:HasTag("sleeping") then

        elseif not inst.entity:CanPredictMovement() then

        elseif is_moving and not should_move then
            if not (inst.replica.rider and inst.replica.rider:IsRiding()) then
                if is_swimming then
                    handle_by_old = false
                    inst.sg:GoToState("blythe_swim_stop")
                end
            end
        elseif not is_moving and should_move then
            if not (inst.replica.rider and inst.replica.rider:IsRiding()) then
                if data and data.dir then
                    if inst.components.locomotor then
                        inst.components.locomotor:SetMoveDir(data.dir)
                    else
                        inst.Transform:SetRotation(data.dir)
                    end
                end

                if is_swimming then
                    handle_by_old = false
                    inst.sg:GoToState("blythe_swim_start")
                end
            end
        end

        if handle_by_old then
            return old_locomote(inst, data)
        else

        end
    end
end)

local function PlayWaterSound(inst)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small", nil, nil, true)
end

local function DoEquipmentFoleySounds(inst)
    local inventory = inst.replica.inventory
    if inventory ~= nil then
        for k, v in pairs(inventory:GetEquips()) do
            if v.foleysound ~= nil then
                inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
            end
        end
    end
end

local function DoFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    if inst.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
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
        tags = { "attack", "notalking", "abouttoattack" },

        onenter = function(inst)
            local combat = inst.replica.combat
            if combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            local cooldown = combat:MinAttackPeriod()
            inst.sg.statemem.chained = IsShootChained(inst)

            combat:StartAttack()
            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")


            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                    inst.sg.statemem.retarget = buffaction.target
                end
            end

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(chain_bonus + enter_bonus)
                inst.sg:SetTimeout(math.max(free_time - enter_bonus - chain_bonus, cooldown))
            else
                inst.AnimState:SetTime(enter_bonus)
                inst.sg:SetTimeout(math.max(free_time - enter_bonus, cooldown))
            end

            inst.sg.statemem.weapon = equip
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:RemoveStateTag("busy")
            inst.sg:AddStateTag("idle")
        end,

        timeline =
        {
            TimeEvent(shoot_time - enter_bonus - chain_bonus, function(inst)
                if inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.replica.combat:CancelAttack()
            end
        end,
    }

    return state
end


local function CreateShootCastAoeState(name, enter_bonus, shoot_time, free_time, chain_bonus)
    local state = State {
        name = name,
        tags = { "notalking", "aoe", "stariliad_no_face_point" },

        onenter = function(inst)
            inst.sg.statemem.chained = IsShootChained(inst)

            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")


            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()
            end

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

                    inst:ClearBufferedAction()
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:ClearBufferedAction()
                end
            end),
        },

        events =
        {
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
        tags = { "notalking", "busy" },

        onenter = function(inst)
            inst.sg.statemem.chained = IsShootChained(inst)

            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")


            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()
            end

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
            inst.sg:RemoveStateTag("busy")
            inst.sg:AddStateTag("idle")
        end,

        timeline =
        {
            TimeEvent(shoot_time - enter_bonus - chain_bonus, function(inst)
                if inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:ClearBufferedAction()
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:ClearBufferedAction()
                end
            end),
        },

        events =
        {
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

AddStategraphState("wilson_client",
    CreateShootAttackState("blythe_shoot_beam",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)

AddStategraphState("wilson_client",
    CreateShootCastAoeState("blythe_shoot_beam_castaoe",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)

AddStategraphState("wilson_client",
    CreateShootAtState("blythe_shoot_beam_shoot_at",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)


AddStategraphState("wilson_client",
    CreateShootAttackState("blythe_shoot_missile",
        TUNING.BLYTHE_MISSILE_ENTER_BONUS,
        TUNING.BLYTHE_MISSILE_SHOOT_TIME,
        TUNING.BLYTHE_MISSILE_FREE_TIME,
        TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
)

AddStategraphState("wilson_client",
    CreateShootCastAoeState("blythe_shoot_missile_castaoe",
        TUNING.BLYTHE_MISSILE_ENTER_BONUS,
        TUNING.BLYTHE_MISSILE_SHOOT_TIME,
        TUNING.BLYTHE_MISSILE_FREE_TIME,
        TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
)


AddStategraphState("wilson_client",
    State {
        name = "blythe_release_ice_fog2",
        tags = { "attack", "notalking", "abouttoattack" },
        server_states = { "blythe_release_ice_fog2" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("hand_shoot")
            end

            inst:PerformPreviewBufferedAction()
        end,

        onupdate = function(inst)
            -- if not inst.sg:ServerStateMatches()
            --     or not inst.components.playercontroller:IsAnyOfControlsPressed(CONTROL_PRIMARY, CONTROL_ATTACK) then
            --     inst.AnimState:PlayAnimation("hand_shoot")
            --     inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_FINISH_TIME)
            --     inst.sg:GoToState("idle", true)
            -- end

            -- if not inst.components.playercontroller:IsAnyOfControlsPressed(CONTROL_PRIMARY, CONTROL_ATTACK) then
            --     inst.AnimState:PlayAnimation("hand_shoot")
            --     inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_FINISH_TIME)
            --     inst.sg:GoToState("idle", true)
            --     return
            -- end

            if not inst.sg.statemem.state_matched then
                if inst.sg:ServerStateMatches() then
                    inst.sg.statemem.state_matched = true
                end
            else
                local cur_proj = inst.replica.blythe_powersuit_configure and
                    inst.replica.blythe_powersuit_configure:GetProjectilePrefab()

                if inst.sg:ServerStateMatches() and cur_proj == "blythe_ice_fog" then
                    -- if inst.entity:FlattenMovementPrediction() then
                    --     inst.sg:GoToState("idle", "noanim")
                    -- else
                    --     local anim_time = inst.AnimState:GetCurrentAnimationTime()
                    --     if anim_time > TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME then
                    --         inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME)
                    --     end
                    -- end

                    local anim_time = inst.AnimState:GetCurrentAnimationTime()
                    if anim_time > TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME then
                        inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME)
                    end
                else
                    local anim_time = inst.AnimState:GetCurrentAnimationTime()
                    if anim_time >= TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME then
                        inst.AnimState:PlayAnimation("hand_shoot")
                        inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_FINISH_TIME)
                        inst.sg:GoToState("idle", true)
                    end
                end
            end
        end,

        timeline =
        {
            TimeEvent(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME, function(inst)
                -- inst.sg.statemem.release_ice_fog = true
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },
    }
)


AddStategraphState("wilson_client",
    State {
        name = "blythe_release_ice_fog_castaoe2",
        tags = { "notalking", "aoe", "stariliad_no_face_point" },
        server_states = { "blythe_release_ice_fog_castaoe2" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("hand_shoot")
            end

            inst:PerformPreviewBufferedAction()
        end,

        onupdate = function(inst)
            if not inst.sg.statemem.state_matched then
                if inst.sg:ServerStateMatches() then
                    inst.sg.statemem.state_matched = true
                end
            else
                local cur_proj = inst.replica.blythe_powersuit_configure and
                    inst.replica.blythe_powersuit_configure:GetProjectilePrefab()

                if inst.sg:ServerStateMatches() and cur_proj == "blythe_ice_fog" then
                    local anim_time = inst.AnimState:GetCurrentAnimationTime()
                    if anim_time > TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME then
                        inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME)
                    end
                else
                    local anim_time = inst.AnimState:GetCurrentAnimationTime()
                    if anim_time >= TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME then
                        inst.AnimState:PlayAnimation("hand_shoot")
                        inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_ANIM_FINISH_TIME)
                        inst.sg:GoToState("idle", true)
                    end
                end
            end
        end,

        timeline =
        {
            TimeEvent(TUNING.BLYTHE_ICE_FOG_ANIM_HOLD_TIME, function(inst)
                -- inst.sg.statemem.release_ice_fog = true
                -- inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

    }
)

AddStategraphState("wilson_client",
    State {
        name = "blythe_swim_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("careful_walk_pre")

            inst.sg.mem.footsteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline = {
            TimeEvent(0 * FRAMES, function(inst)
                PlayWaterSound(inst)
                DoFoleySounds(inst)
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

        onexit = function(inst)
            inst.Transform:SetFourFaced()
        end,
    }
)

AddStategraphState("wilson_client",
    State {
        name = "blythe_swim",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()

            local anim = "careful_walk"
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
            TimeEvent(11 * FRAMES, function(inst)
                PlayWaterSound(inst)
                DoFoleySounds(inst)
            end),

            TimeEvent(26 * FRAMES, function(inst)
                PlayWaterSound(inst)
                DoFoleySounds(inst)
            end),
        },

        events = {

        },

        ontimeout = function(inst)
            inst.sg:GoToState("blythe_swim")
        end,
    }
)

AddStategraphState("wilson_client",
    State {
        name = "blythe_swim_stop",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("careful_walk_pst")
        end,

        timeline =
        {
        },

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

AddStategraphState("wilson_client",
    State {
        name = "blythe_parry",
        tags = { "parrying", "busy" },
        server_states = { "blythe_parry" },

        onenter = function(inst, data)
            data = data or {}
            inst.components.locomotor:Stop()

            if data.pos then
                inst:ForceFacePoint(data.pos)
            end

            inst.AnimState:PlayAnimation("blythe_parry")

            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)

            -- inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(13 * FRAMES)
        end,

        -- onupdate = function(inst)
        --     if inst.sg:ServerStateMatches() then
        --         if inst.entity:FlattenMovementPrediction() then
        --             inst.sg:GoToState("idle", "noanim")
        --         end
        --         -- elseif inst.bufferedaction == nil then
        --         --     inst.sg:GoToState("idle", true)
        --     end
        -- end,

        ontimeout = function(inst)
            -- inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
        end,
    }
)
