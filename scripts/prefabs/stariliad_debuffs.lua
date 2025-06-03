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
    }
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
