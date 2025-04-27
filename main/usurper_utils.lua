-- This file handles teleport beam and swap beam

StarIliadUsurper = {}

-- function StarIliadUsurper.TeleportToCaster(caster, target)
--     local p1 = caster:GetPosition()
--     local p2 = target:GetPosition()
--     local towards = (p2 - p1):GetNormalized()

--     local dist = math.max(1.5, caster:GetPhysicsRadius(0) + target:GetPhysicsRadius(0))

--     local pos = p1 + towards * dist
--     target.Transform:SetPosition(pos:Get())
-- end

-- function StarIliadUsurper.CanBeTeleported(target)
--     return target.components.locomotor ~= nil
-- end

-- function StarIliadUsurper.CanBePickedUp(target)
--     return target.components.inventoryitem ~= nil
-- end

-- function StarIliadUsurper.IsCombatTarget(caster, target)
--     return caster and caster:IsValid() and caster.components.combat:CanTarget(target)
-- end

function StarIliadUsurper.TryStun(target)
    if target.components.sanity then
        target.components.sanity:DoDelta(-33)
    end

    if target:HasTag("player") then
        return
    end

    ------------------------------------------------

    local fns_candidate = {}
    if target.components.sleeper then
        table.insert(fns_candidate, function(v)
            v.components.sleeper:AddSleepiness(5, GetRandomMinMax(7, 13))
        end)
    end

    if target.components.hauntable and target.components.hauntable.panicable then
        table.insert(fns_candidate, function(v)
            v.components.hauntable:Panic(7)
        end)
    end

    if #fns_candidate > 0 then
        local fn = GetRandomItem(fns_candidate)
        if fn then
            fn(target)
        end
    end
end

local function AddRooted(caster, target)
    if target.components.rooted == nil then
        target:AddComponent("rooted")
    end
    target.components.rooted:AddSource(caster)
end

-- StarIliadUsurper.SwapPositionPre(ThePlayer, c_findnext("dummytarget"))
function StarIliadUsurper.SwapPositionPre(caster, target)
    AddRooted(caster, caster)
    AddRooted(caster, target)

    SendModRPCToClient(MOD_RPC["stariliad_rpc"]["show_usurper_shot_screen"], caster.userid, caster, target)
end

function StarIliadUsurper.SwapPositionPst(caster, target)
    local x1, y1, z1 = caster.Transform:GetWorldPosition()
    local x2, y2, z2 = target.Transform:GetWorldPosition()

    -- print(x1, y1, z1)
    -- print(x2, y2, z2)
    -- print(caster, target)

    caster.Transform:SetPosition(x2, y2, z2)
    target.Transform:SetPosition(x1, y1, z1)

    StarIliadUsurper.TryStun(caster)
    StarIliadUsurper.TryStun(target)

    caster.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/swap_end")
end

GLOBAL.StarIliadUsurper = StarIliadUsurper
