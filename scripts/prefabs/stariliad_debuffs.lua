local assets = {

}

local debuffs_data = {
    stariliad_debuff_shield_break = {
        on_attached = function(inst, target, followsymbol, followoffset, data, buffer)
            inst.detach_task = inst:DoTaskInTime(10, function()
                inst.components.debuff:Stop()
            end)

            if StarIliadBasic.IsShieldState(target) then
                local fx = SpawnPrefab("stariliad_shield_break_fx")
                if followsymbol and followoffset then
                    target:AddChild(fx)
                    fx.entity:AddFollower()
                    fx.Follower:FollowSymbol(target.GUID, followsymbol, followoffset.x, followoffset.y, followoffset.z)
                else
                    fx.Transform:SetPosition(target.Transform:GetWorldPosition())
                end
            end
        end,

        on_extended = function(inst, target, followsymbol, followoffset, data, buffer)
            if inst.detach_task then
                inst.detach_task:Cancel()
            end
            inst.detach_task = inst:DoTaskInTime(10, function()
                inst.components.debuff:Stop()
            end)
        end,
    },

    stariliad_debuff_be_parried = {
        on_attached = function(inst, target, followsymbol, followoffset, data, buffer)
            inst.stacks = 1
            inst.owner = data and data.owner

            inst.detach_task = inst:DoTaskInTime(5, function()
                inst.components.debuff:Stop()
            end)

            inst._callback = function(_, data2)
                local attacker = data2.attacker
                if attacker == inst.owner then
                    local count = 1

                    if IsEntityDeadOrGhost(target, true) then
                        count = count + 3
                    end

                    for i = 1, count do
                        StarIliadBasic.SpawnSupplyBalls(attacker,
                            target:GetPosition() + Vector3(0, GetRandomMinMax(0.8, 2), 0))
                    end

                    inst.stacks = inst.stacks - 1
                    if inst.stacks <= 0 then
                        inst.components.debuff:Stop()
                    end
                end
            end

            inst:ListenForEvent("attacked", inst._callback, target)
        end,

        on_detached = function(inst, target)
            inst:RemoveEventCallback("attacked", inst._callback, target)
        end,

        on_extended = function(inst, target, followsymbol, followoffset, data, buffer)
            inst.stacks = 1
            if inst.detach_task then
                inst.detach_task:Cancel()
            end
            inst.detach_task = inst:DoTaskInTime(5, function()
                inst.components.debuff:Stop()
            end)
        end,
    },

    stariliad_debuff_heal_decrease = {
        on_attached = function(inst, target, followsymbol, followoffset, data, buffer)
            inst.stacks = 1

            inst.detach_task = inst:DoTaskInTime(20, function()
                inst.components.debuff:Stop()
            end)
        end,

        on_detached = function(inst, target)

        end,

        on_extended = function(inst, target, followsymbol, followoffset, data, buffer)
            inst.stacks = inst.stacks + 1
            if inst.detach_task then
                inst.detach_task:Cancel()
            end
            inst.detach_task = inst:DoTaskInTime(20, function()
                inst.components.debuff:Stop()
            end)
        end,
    },

    stariliad_debuff_shock_wave = {
        on_attached = function(inst, target, followsymbol, followoffset, data, buffer)
            inst.stacks = 1

            local speed_mult = math.pow(TUNING.BLYTHE_SHOCK_WAVE_DEBUFF_MOVESPEED_MULT, inst.stacks)
            if target.components.locomotor then
                target.components.locomotor:SetExternalSpeedMultiplier(inst, "stariliad_debuff_shock_wave", speed_mult)
            end

            inst.detach_task = inst:DoTaskInTime(TUNING.BLYTHE_SHOCK_WAVE_DEBUFF_DURATION, function()
                inst.components.debuff:Stop()
            end)
        end,

        on_detached = function(inst, target)
            target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "stariliad_debuff_shock_wave")
        end,

        on_extended = function(inst, target, followsymbol, followoffset, data, buffer)
            inst.stacks = math.min(inst.stacks + 1, TUNING.BLYTHE_SHOCK_WAVE_DEBUFF_MAX_STACKS)

            local speed_mult = math.pow(TUNING.BLYTHE_SHOCK_WAVE_DEBUFF_MOVESPEED_MULT, inst.stacks)
            if target.components.locomotor then
                target.components.locomotor:SetExternalSpeedMultiplier(inst, "stariliad_debuff_shock_wave", speed_mult)
            end

            if inst.detach_task then
                inst.detach_task:Cancel()
            end
            inst.detach_task = inst:DoTaskInTime(TUNING.BLYTHE_SHOCK_WAVE_DEBUFF_DURATION, function()
                inst.components.debuff:Stop()
            end)
        end,
    },
}

local function MakeDebuff(prefab, on_attached, on_detached, on_extended)
    on_detached = on_detached or function(inst)
        inst:Remove()
    end

    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:AddTransform()
        --[[Non-networked entity]]

        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(on_attached)
        inst.components.debuff:SetDetachedFn(on_detached)
        inst.components.debuff:SetExtendedFn(on_extended)
        -- Do not keep on despawn.

        return inst
    end

    return Prefab(prefab, fn, assets)
end

local prefabs = {}
for name, data in pairs(debuffs_data) do
    table.insert(prefabs, MakeDebuff(name, data.on_attached, data.on_detached, data.on_extended))
end

return unpack(prefabs)
