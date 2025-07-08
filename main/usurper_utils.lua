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

StarIliadUsurper.CanSwapBlackList = {
    "otterden"
}

StarIliadUsurper.CanSwapWhiteList = {
    "tumbleweed",
    "carnival_host",
}


function StarIliadUsurper.CanSwap(caster, target)
    if not (target and target:IsValid()) then
        return false
    end

    if table.contains(StarIliadUsurper.CanSwapBlackList, target.prefab) then
        return false
    end

    if target:HasTag("playerghost")
        or target:HasTag("largecreature")
        or target:HasTag("blythe_beam_swap_ongoing") then
        return false
    end

    if caster.components.combat and caster.components.combat:CanTarget(target) then
        return true
    end

    local valid_actions = {
        ACTIONS.CHOP,
        ACTIONS.MINE,
        ACTIONS.HAMMER,
    }

    if target.components.workable
        and target.components.workable:CanBeWorked()
        and table.contains(valid_actions, target.components.workable.action) then
        return true
    end

    if table.contains(StarIliadUsurper.CanSwapWhiteList, target.prefab) then
        return true
    end

    return false
end

function StarIliadUsurper.TryStun(caster, target)
    -- if target.components.sanity then
    --     target.components.sanity:DoDelta(-33)
    -- end

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

    if target.components.workable
        and target.components.workable:CanBeWorked()
        and target.components.workable.action ~= ACTIONS.NET then
        table.insert(fns_candidate, function(v)
            v.components.workable:WorkedBy(caster, math.random(30))
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

    if target.components.playercontroller then
        target.components.playercontroller:Enable(false)
    end

    target:AddTag("blythe_beam_swap_ongoing")
end

local function RemoveRooted(caster, target)
    if target.components.rooted then
        target.components.rooted:RemoveSource(caster)
    end

    if target.components.playercontroller then
        target.components.playercontroller:Enable(true)
    end

    target:RemoveTag("blythe_beam_swap_ongoing")
end

-- StarIliadUsurper.SwapPositionPre(ThePlayer, c_findnext("dummytarget"))
function StarIliadUsurper.SwapPositionPre(caster, target)
    AddRooted(caster, caster)
    AddRooted(caster, target)

    SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["show_usurper_shot_screen"], caster.userid, caster, target)
end

local function SpawnShadows(caster, start_pos, end_pos)
    -- blythe_clone
    local delta_pos = end_pos - start_pos
    if delta_pos:Length() < 5 then
        return
    end

    local max_range = 5
    local step = 1
    local num_steps = max_range / step

    local forward = delta_pos:GetNormalized()

    for i = 1, num_steps do
        local shadow = SpawnAt("blythe_clone", end_pos - forward * i * step)
        shadow:Copy(caster)

        shadow.Transform:SetRotation(caster.Transform:GetRotation())
        shadow.AnimState:SetPercent("run_pst", 1.0 - 1.0 * i / num_steps)
        shadow.AnimState:SetMultColour(0, 1, 0, 0.5)
        shadow:FadeOut(1 * (num_steps - i + 1) / num_steps)
    end
end

function StarIliadUsurper.SwapPositionPst(caster, target)
    local caster_is_valid = caster and caster:IsValid()
    local target_is_valid = target and target:IsValid()
    if caster_is_valid and target_is_valid then
        local x1, y1, z1 = caster.Transform:GetWorldPosition()
        local x2, y2, z2 = target.Transform:GetWorldPosition()

        -- print(x1, y1, z1)
        -- print(x2, y2, z2)
        -- print(caster, target)

        RemoveRooted(caster, caster)
        RemoveRooted(caster, target)

        caster.Transform:SetPosition(x2, y2, z2)
        target.Transform:SetPosition(x1, y1, z1)

        -- StarIliadUsurper.TryStun(caster)
        -- StarIliadUsurper.TryStun(target)
        StarIliadUsurper.TryStun(caster, caster)
        StarIliadUsurper.TryStun(caster, target)

        SpawnAt("blythe_beam_swap_ring_fx", caster)
        SpawnAt("blythe_beam_swap_ring_fx", target)

        -- Spawn clones as shadow
        if caster:HasTag("player") then
            SpawnShadows(caster, Vector3(x1, y1, z1), Vector3(x2, y2, z2))
        end

        caster.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/swap_end")
    elseif caster_is_valid then
        RemoveRooted(caster, caster)
    end
end

GLOBAL.StarIliadUsurper = StarIliadUsurper
