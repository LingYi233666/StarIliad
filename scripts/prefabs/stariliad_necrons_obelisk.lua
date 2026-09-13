--Down when sane, up when insane.
local assets =
{
    Asset("ANIM", "anim/blocker_sanity.zip"),
    Asset("ANIM", "anim/blocker_sanity_fx.zip"),
    Asset("ANIM", "anim/stariliad_necrons_obelisk2.zip"),
}

local COLLISION_SIZE = 1 --must be an int
local NEAR_DIST_SQ = 10 * 10
local FAR_DIST_SQ = 11 * 11

local UPDATE_INTERVAL = .2
local UPDATE_OFFSET = 0 --used to stagger periodic updates across entities

--V2C: Use a shared add/remove wall because regions may overlap
local PF_SHARED = {}

local function AddSharedWall(pathfinder, x, z, inst)
    local id = tostring(x) .. "," .. tostring(z)
    if PF_SHARED[id] == nil then
        PF_SHARED[id] = { [inst] = true }
        pathfinder:AddWall(x, 0, z)
    else
        PF_SHARED[id][inst] = true
    end
end

local function RemoveSharedWall(pathfinder, x, z, inst)
    local id = tostring(x) .. "," .. tostring(z)
    if PF_SHARED[id] ~= nil then
        PF_SHARED[id][inst] = nil
        if next(PF_SHARED[id]) ~= nil then
            return
        end
        PF_SHARED[id] = nil
    end
    pathfinder:RemoveWall(x, 0, z)
end

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pftable == nil and inst:GetCurrentPlatform() == nil then
            inst._pftable = {}
            local pathfinder = TheWorld.Pathfinder
            local x, y, z = inst.Transform:GetWorldPosition()
            x = math.floor(x * 100 + .5) / 100
            z = math.floor(z * 100 + .5) / 100
            for dx = -COLLISION_SIZE, COLLISION_SIZE do
                local x1 = x + dx
                for dz = -COLLISION_SIZE, COLLISION_SIZE do
                    local z1 = z + dz
                    AddSharedWall(pathfinder, x1, z1, inst)
                    table.insert(inst._pftable, { x1, z1 })
                end
            end
        end
    elseif inst._pftable ~= nil then
        local pathfinder = TheWorld.Pathfinder
        for i, v in ipairs(inst._pftable) do
            RemoveSharedWall(pathfinder, v[1], v[2], inst)
        end
        inst._pftable = nil
    end
end

local function InitializePathFinding(inst, isready)
    if isready then
        inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
        OnIsPathFindingDirty(inst)
    else
        inst:DoTaskInTime(0, InitializePathFinding, true)
    end
end

local function updatephysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    local mask = COLLISION.WORLD
    if not inst.conceal then
        mask = bit.bor(mask, COLLISION.ITEMS)
        if inst.active then
            mask = bit.bor(mask, COLLISION.CHARACTERS)
        end
    end
    inst.Physics:SetCollisionMask(mask)
end

local function OnActiveStateChanged(inst)
    inst.active = inst.active_queue
    inst._ispathfinding:set(inst.active_queue and not inst.conceal)
    updatephysics(inst)
end

local function OnConcealStateChanged(inst)
    inst.conceal = inst.conceal_queued
    if not inst.conceal then
        LaunchAndClearArea(inst, COLLISION_SIZE, 0.5, 0.5, .2, COLLISION_SIZE)
    end

    OnActiveStateChanged(inst)
end

local function dotransition(inst)
    inst.transition_task = nil
    if inst.conceal ~= inst.conceal_queued then
        if not inst.sg:HasStateTag("busy") then
            if inst.conceal_queued then
                inst.sg:GoToState("conceal", inst.active)
            else
                inst.sg:GoToState("reveal")
            end
        end
    elseif inst.active ~= inst.active_queue and not inst.conceal_queued then
        inst.sg:GoToState(inst.active_queue and "raise" or "lower")
    end
end

local function refresh(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.conceal or inst.conceal_queued then
        -- nothing to do here
    elseif inst.active then
        inst.active_queue = false
        for i, v in ipairs(AllPlayers) do
            if not v:HasTag("notarget") and
                v.components.sanity ~= nil and
                ((v.components.sanity:IsSane() and inst.activeonsane) or (v.components.sanity:IsInsane() and not inst.activeonsane)) then
                local p1x, p1y, p1z = v.Transform:GetWorldPosition()
                if distsq(x, z, p1x, p1z) < FAR_DIST_SQ then
                    inst.active_queue = true
                    break
                end
            end
        end
    else
        inst.active_queue = false
        for i, v in ipairs(AllPlayers) do
            if not v:HasTag("notarget") and
                v.components.sanity ~= nil and
                ((v.components.sanity:IsSane() and inst.activeonsane) or (v.components.sanity:IsInsane() and not inst.activeonsane)) then
                local p1x, p1y, p1z = v.Transform:GetWorldPosition()
                if distsq(x, z, p1x, p1z) < NEAR_DIST_SQ then
                    inst.active_queue = true
                    break
                end
            end
        end
    end

    if (inst.conceal ~= inst.conceal_queued or inst.active_queue ~= inst.active) and inst.transition_task == nil then
        inst.transition_task = inst:DoTaskInTime(math.random(), dotransition)
    end
end

local function AddRefreshTask(inst)
    if inst._refreshtask == nil then
        inst._refreshtask = inst:DoPeriodicTask(UPDATE_INTERVAL, refresh, UPDATE_OFFSET)

        --Stagger updates for next spawned entity
        UPDATE_OFFSET = UPDATE_OFFSET + FRAMES
        if UPDATE_OFFSET > UPDATE_INTERVAL then
            UPDATE_OFFSET = 0
        end
    end
end


local function getstatus(inst)
    return inst.active and "ACTIVE" or "INACTIVE"
end

local function onremove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

-- -------------------------------------------

local function SetTallPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    local mask = COLLISION.WORLD
    mask = bit.bor(mask, COLLISION.ITEMS)
    mask = bit.bor(mask, COLLISION.CHARACTERS)

    inst.Physics:SetCollisionMask(mask)
end

local function SetLowPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    local mask = COLLISION.WORLD
    mask = bit.bor(mask, COLLISION.ITEMS)

    inst.Physics:SetCollisionMask(mask)
end

local function EnableDust(inst, enable)
    if enable and not inst.dust then
        inst.dust = inst:SpawnChild("stariliad_tomb_building_dust_small")
    elseif not enable and inst.dust then
        inst.dust:Remove()
        inst.dust = nil
    end
end

local function OnLightRadiusDirty(inst)
    local val = inst._light_radius:value()
    if val <= 0 then
        inst.Light:Enable(false)
        -- inst.AnimState:SetLightOverride(0)
    else
        inst.Light:SetRadius(val)
        inst.Light:Enable(true)

        if val >= 1 then
            -- inst.AnimState:SetLightOverride(1)
        else
            local lightoverride = Remap(val, 0, 1, 0, 1)
            -- inst.AnimState:SetLightOverride(lightoverride)
        end


        -- inst.AnimState:SetLightOverride(1)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, COLLISION_SIZE)

    -- inst.MiniMapEntity:SetIcon("obelisk.png")

    inst.AnimState:SetBank("blocker_sanity")
    inst.AnimState:SetBuild("stariliad_necrons_obelisk2")
    inst.AnimState:PlayAnimation("idle_inactive")

    -- inst.AnimState:SetLightOverride(1)

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(43 / 255, 242 / 255, 31 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(1)
    inst.Light:Enable(false)

    inst:AddTag("antlion_sinkhole_blocker")

    -- updatephysics(inst)

    -- inst._pftable = nil
    -- inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
    -- InitializePathFinding(inst, TheWorld.ismastersim)

    -- inst.OnRemoveEntity = onremove

    inst._light_radius = net_float(inst.GUID, "inst._light_radius", "lightradiusdirty")
    inst._light_radius:set(0)

    inst:ListenForEvent("lightradiusdirty", OnLightRadiusDirty)
    OnLightRadiusDirty(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst.active = false
    -- inst.active_queue = false
    --    inst.conceal = nil
    --    inst.conceal_queued = nil

    inst:AddComponent("inspectable")
    -- inst.components.inspectable.getstatus = getstatus

    -- inst.OnActiveStateChanged = OnActiveStateChanged
    -- inst.OnConcealStateChanged = OnConcealStateChanged

    inst:AddComponent("colouradder")

    inst.SetTallPhysics = SetTallPhysics
    inst.SetLowPhysics = SetLowPhysics
    inst.EnableDust = EnableDust

    inst:SetStateGraph("SGstariliad_necrons_obelisk")

    -- MakeRoseTarget_CreateFuel(inst)

    inst:DoTaskInTime(FRAMES, function()
        inst.green_parts = {
            inst:SpawnChild("stariliad_necrons_obelisk_green_part0"),
            inst:SpawnChild("stariliad_necrons_obelisk_green_part1"),
            inst:SpawnChild("stariliad_necrons_obelisk_green_part2"),
        }

        for _, v in pairs(inst.green_parts) do
            v.entity:AddFollower()

            v.components.highlightchild:SetOwner(inst)
            inst.components.colouradder:AttachChild(v)
        end

        inst.green_parts[1].Follower:FollowSymbol(inst.GUID, "nightmare_rock", nil, nil, nil, true, nil, 0)
        inst.green_parts[2].Follower:FollowSymbol(inst.GUID, "nightmare_rock", nil, nil, nil, true, nil, 2)
        inst.green_parts[3].Follower:FollowSymbol(inst.GUID, "nightmare_rock", nil, nil, nil, true, nil, 4)
    end)

    return inst
end

-- green_part0
-- green_part1
-- green_part2
local function MakeGreenPart(index)
    local function part_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("stariliad_necrons_obelisk2")
        inst.AnimState:SetBuild("stariliad_necrons_obelisk2")
        inst.AnimState:PlayAnimation("green_part" .. index)

        -- inst.AnimState:SetLightOverride(1)

        inst:AddTag("NOBLOCK")
        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst:AddComponent("highlightchild")


        return inst
    end

    return Prefab("stariliad_necrons_obelisk_green_part" .. index, part_fn, assets)
end

return Prefab("stariliad_necrons_obelisk", fn, assets, prefabs),
    MakeGreenPart(0), MakeGreenPart(1), MakeGreenPart(2)
