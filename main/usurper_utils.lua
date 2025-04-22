-- This file handles teleport beam and swap beam

UsurperUtils = {}

function UsurperUtils.TeleportToCaster(caster, target)
    local p1 = caster:GetPosition()
    local p2 = target:GetPosition()
    local towards = (p2 - p1):GetNormalized()

    local dist = math.max(1.5, caster:GetPhysicsRadius(0) + target:GetPhysicsRadius(0))

    local pos = p1 + towards * dist
    target.Transform:SetPosition(pos:Get())
end

function UsurperUtils.CanBeTeleported(target)
    return target.components.locomotor ~= nil
end

function UsurperUtils.CanBePickedUp(target)
    return target.components.inventoryitem ~= nil
end

function UsurperUtils.IsCombatTarget(caster, target)
    return caster and caster:IsValid() and caster.components.combat:CanTarget(target)
end

GLOBAL.UsurperUtils = UsurperUtils
