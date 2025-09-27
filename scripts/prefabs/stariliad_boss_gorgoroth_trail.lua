local assets =
{
    Asset("ANIM", "anim/damp_trail.zip"),
}

local function OnStartFade(inst)
    inst.task = nil
    inst.AnimState:PlayAnimation(inst.trailname .. "_pst")
end

local function OnAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation(inst.trailname .. "_pre") then
        inst.AnimState:PlayAnimation(inst.trailname)
        if inst.task ~= nil then
            inst.task:Cancel()
        end
        inst.task = inst:DoTaskInTime(inst.duration, OnStartFade)
    elseif inst.AnimState:IsCurrentAnimation(inst.trailname .. "_pst") then
        inst:Remove()
    end
end

local function SetVariation(inst, rand, scale, duration)
    if inst.trailname == nil then
        inst.task:Cancel()
        inst.task = nil

        inst.Transform:SetScale(scale, scale, scale)

        inst.trailname = "trail" .. tostring(rand)
        inst.duration = duration
        inst.AnimState:PlayAnimation(inst.trailname .. "_pre")
        inst:ListenForEvent("animover", OnAnimOver)
    end
end

local function Refresh(inst)
    if inst.trailname ~= nil and inst.task ~= nil then
        inst.task:Cancel()
        inst.task = inst:DoTaskInTime(inst.duration, OnStartFade)
    end
end

local function OnUpdate(inst, x, y, z, rad)
    for i, v in ipairs(TheSim:FindEntities(x, y, z, rad, { "locomotor" }, { "flying", "playerghost", "INLIMBO", "shadow_aligned" })) do
        if v.components.locomotor ~= nil then
            v.components.locomotor:PushTempGroundSpeedMultiplier(TUNING.STARILIAD_BOSS_GORGOROTH_TRAIL_SPEED_PENALTY,
                WORLD_TILES.MUD)
        end
    end
end

local function OnUpdateClient(inst, x, y, z, rad)
    local player = ThePlayer
    if player ~= nil and
        player.components.locomotor ~= nil and
        not player:HasTag("playerghost") and
        player:GetDistanceSqToPoint(x, 0, z) < rad * rad then
        player.components.locomotor:PushTempGroundSpeedMultiplier(TUNING.STARILIAD_BOSS_GORGOROTH_TRAIL_SPEED_PENALTY,
            WORLD_TILES.MUD)
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("damp_trail")
    inst.AnimState:SetBuild("damp_trail")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:DoTaskInTime(0, function()
        local x, y, z = inst.Transform:GetWorldPosition()
        local scale = inst.Transform:GetScale()
        local rad = scale * 1

        local onupdatefn = TheWorld.ismastersim and OnUpdate or OnUpdateClient
        inst.slow_task = inst:DoPeriodicTask(0, onupdatefn, nil, x, y, z, rad)
        onupdatefn(inst, x, y, z, rad)
    end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetVariation = SetVariation
    inst.Refresh = Refresh

    inst.persists = false
    inst.task = inst:DoTaskInTime(0, inst.Remove)

    return inst
end

return Prefab("stariliad_boss_gorgoroth_trail", fn, assets)
