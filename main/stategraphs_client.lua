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
            inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

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
            inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

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
            inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

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
        name = "blythe_release_ice_fog",
        tags = { "attack", "notalking", "abouttoattack" },
        -- tags = { "attack", },
        -- server_states = { "blythe_release_ice_fog" },

        onenter = function(inst)
            local combat = inst.replica.combat
            if combat:InCooldown() then
                print("in cooldown !")

                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)

                return
            end

            local buffaction = inst:GetBufferedAction()


            local cooldown = combat:MinAttackPeriod()
            inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

            -- local target = buffaction ~= nil and buffaction.target or nil
            -- combat:SetTarget(target)
            combat:StartAttack()
            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")


            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                    inst.sg.statemem.retarget = buffaction.target
                end
            end

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS)
                -- local cd = math.max(TUNING.BLYTHE_ICE_FOG_FREE_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, cooldown)
                -- print("cd:",cd/FRAMES)
                inst.sg:SetTimeout(math.max(TUNING.BLYTHE_ICE_FOG_FREE_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, cooldown))
            else
                inst.sg:SetTimeout(math.max(TUNING.BLYTHE_ICE_FOG_FREE_TIME, cooldown))
            end

            inst.sg.statemem.weapon = equip

            -- StarIliadDebug.PrintStackTrace()
        end,

        -- onenter = function(inst)
        --     inst.components.locomotor:Stop()

        --     inst.sg.statemem.chained = inst.AnimState:IsCurrentAnimation("hand_shoot")
        --     inst.AnimState:PlayAnimation("hand_shoot")

        --     if inst.sg.statemem.chained then
        --         inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS)
        --     end

        --     local buffaction = inst:GetBufferedAction()
        --     if buffaction ~= nil then
        --         inst:PerformPreviewBufferedAction()

        --         if buffaction.target and buffaction.target:IsValid() then
        --             inst:FacePoint(buffaction.target:GetPosition())
        --             inst.sg.statemem.attacktarget = buffaction.target
        --             inst.sg.statemem.retarget = buffaction.target
        --         end
        --     end

        --     inst.sg:SetTimeout(2)
        -- end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")

            -- inst.components.playercontroller.attack_buffer = CONTROL_ATTACK

            -- inst.components.playercontroller:DoAttackButton()

            print("Remove attack tag at frame:", inst.sg:GetTimeInState() / FRAMES)
        end,

        -- onupdate = function(inst)
        --     local retarget = inst.sg.statemem.retarget
        --     if not inst.sg:HasStateTag("attack")
        --         and inst.replica.combat:CanTarget(retarget)
        --         and TheInput:IsControlPressed(CONTROL_ATTACK) then
        --         local buffaction = BufferedAction(inst, retarget, ACTIONS.ATTACK)
        --         buffaction.preview_cb = function()
        --             local isreleased = false
        --             inst.components.playercontroller:RemoteAttackButton(retarget, false, false, isreleased)
        --         end
        --         inst:PushBufferedAction(buffaction)

        --         -- inst.components.playercontroller:DoAttackButton(retarget, false)
        --     end
        -- end,

        -- onupdate = function(inst)
        --     if inst.sg:HasStateTag("idle") then
        --         if inst.sg:HasStateTag("attack") and not (inst:HasTag("attack") and inst.sg:ServerStateMatches()) then
        --             local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        --             if equip == nil then
        --                 inst.sg:GoToState("idle", "noanim")
        --             else
        --                 inst.sg:RemoveStateTag("attack")
        --             end
        --         end
        --     elseif inst.sg:ServerStateMatches() then
        --         if inst.entity:FlattenMovementPrediction() then
        --             inst.sg:AddStateTag("idle")
        --             inst.sg:AddStateTag("canrotate")
        --             inst.entity:SetIsPredictingMovement(false) -- so the animation will come across
        --             --ClearCachedServerState(inst) --don't clear, we polling this in the above "idle" code
        --         end
        --     elseif inst.bufferedaction == nil then
        --         inst.sg:GoToState("idle")
        --     end
        -- end,

        -- ontimeout = function(inst)
        --     if not inst.sg:HasStateTag("idle") then
        --         inst:ClearBufferedAction()
        --         inst.sg:GoToState("idle")
        --     end
        -- end,

        timeline =
        {
            TimeEvent(TUNING.BLYTHE_ICE_FOG_SHOOT_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, function(inst)
                if inst.sg.statemem.chained then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),

            TimeEvent(TUNING.BLYTHE_ICE_FOG_WITHDRAW_GUN_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, function(inst)
                if inst.sg.statemem.chained then
                    inst.AnimState:SetTime(27 * FRAMES)
                end
            end),

            TimeEvent(TUNING.BLYTHE_ICE_FOG_SHOOT_TIME, function(inst)
                if not inst.sg.statemem.chained then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),

            TimeEvent(TUNING.BLYTHE_ICE_FOG_WITHDRAW_GUN_TIME, function(inst)
                if not inst.sg.statemem.chained then
                    inst.AnimState:SetTime(27 * FRAMES)
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

            -- inst.entity:SetIsPredictingMovement(true)
        end,
    }
)


AddStategraphState("wilson_client",
    State {
        name = "blythe_release_ice_fog_castaoe",
        tags = { "notalking", "aoe", "stariliad_no_face_point" },

        onenter = function(inst)
            inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")


            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()
            end

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS)
                inst.sg:SetTimeout(TUNING.BLYTHE_ICE_FOG_FREE_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS)
            else
                inst.sg:SetTimeout(TUNING.BLYTHE_ICE_FOG_FREE_TIME)
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
            TimeEvent(TUNING.BLYTHE_ICE_FOG_SHOOT_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, function(inst)
                if inst.sg.statemem.chained then
                    inst:ClearBufferedAction()
                end
            end),

            TimeEvent(TUNING.BLYTHE_ICE_FOG_WITHDRAW_GUN_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, function(inst)
                if inst.sg.statemem.chained then
                    inst.AnimState:SetTime(27 * FRAMES)
                end
            end),

            TimeEvent(TUNING.BLYTHE_ICE_FOG_SHOOT_TIME, function(inst)
                if not inst.sg.statemem.chained then
                    inst:ClearBufferedAction()
                end
            end),

            TimeEvent(TUNING.BLYTHE_ICE_FOG_WITHDRAW_GUN_TIME, function(inst)
                if not inst.sg.statemem.chained then
                    inst.AnimState:SetTime(27 * FRAMES)
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
                if inst.sg:ServerStateMatches() then
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


-- TODO: Finish this
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
                if inst.sg:ServerStateMatches() then
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
