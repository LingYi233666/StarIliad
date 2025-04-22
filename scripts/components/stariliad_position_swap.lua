local StarIliadPositionSwap = Class(function(self, inst)
    self.inst = inst
end)

function StarIliadPositionSwap:TryStun(target)
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

function StarIliadPositionSwap:SwapPosition(caster, target)
    local p1 = caster:GetPosition()
    local p2 = target:GetPosition()

    caster.Transform:SetPosition(p2:Get())
    target.Transform:SetPosition(p1:Get())
end

function StarIliadPositionSwap:Process(caster, target, delay)
    -- apply roots

    -- disable control

    -- add invincible ?

    -- show HUD (RPC)

    -- delay if have
end

return StarIliadPositionSwap
