local assets = {
    Asset("ANIM", "anim/reticuleaoe.zip"),
}

local PAD_DURATION = 0
local FLASH_TIME = .3

local function UpdatePing(inst, s0, s1, t0, duration, multcolour, addcolour)
    if next(multcolour) == nil then
        multcolour[1], multcolour[2], multcolour[3], multcolour[4] = inst.AnimState:GetMultColour()
    end
    if next(addcolour) == nil then
        addcolour[1], addcolour[2], addcolour[3], addcolour[4] = inst.AnimState:GetAddColour()
    end
    local t = GetTime() - t0
    local k = 1 - math.max(0, t - PAD_DURATION) / duration
    k = 1 - k * k
    local s = Lerp(s0, s1, k)
    local c = Lerp(1, 0, k)
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetMultColour(multcolour[1], multcolour[2], multcolour[3], c * multcolour[4])

    k = math.min(FLASH_TIME, t) / FLASH_TIME
    c = math.max(0, 1 - k * k)
    inst.AnimState:SetAddColour(c * addcolour[1], c * addcolour[2], c * addcolour[3], c * addcolour[4])
end

local function FadeOut(inst, duration, scaleup)
    duration = duration or 0.3
    scaleup = scaleup or 1.05

    local s1, _, _ = inst.Transform:GetScale()

    inst:DoPeriodicTask(0, UpdatePing, nil, s1, s1 * scaleup, GetTime(), duration, {}, {})
    inst:DoTaskInTime(duration, inst.Remove)
end


local function CreateTargetRing(proxy)
    local ring = CreateEntity()

    ring.entity:AddTransform()
    ring.entity:AddAnimState()

    ring.Transform:SetFromProxy(proxy.GUID)

    --[[Non-networked entity]]
    ring.entity:SetCanSleep(false)
    ring.persists = false


    ring:AddTag("FX")
    ring:AddTag("NOCLICK")

    ring.AnimState:SetBank("missile_fx")
    ring.AnimState:SetBuild("missile_fx")
    ring.AnimState:PlayAnimation("target_pre")
    ring.AnimState:PushAnimation("target_loop", true)
    ring.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
    ring.AnimState:SetLayer(LAYER_BACKGROUND)
    ring.AnimState:SetSortOrder(3)
    ring.AnimState:SetLightOverride(1)
    -- ring.AnimState:SetScale(RING_MIN_SCALE, RING_MIN_SCALE)
    -- ring.AnimState:SetMultColour(1, 1, 1, RING_MAX_ALPHA)

    -- ring.StartPing = Ring_StartPing

    ring:AddComponent("updatelooper")

    return ring
end

local function FollowTarget(ring)
    if ring.target and ring.target:IsValid() and not ring.target:IsInLimbo() then
        ring.Transform:SetPosition(ring.target.Transform:GetWorldPosition())
    end
end

local function OnTargetDirty(inst)
    local target = inst._target:value()

    if target then
        if inst._anim and inst._anim:IsValid() then
            inst._anim.target = nil
            inst._anim.components.updatelooper:RemoveOnUpdateFn(FollowTarget)
            FadeOut(inst._anim)
        end

        inst._anim = CreateTargetRing(inst)
        inst._anim.Transform:SetPosition(target.Transform:GetWorldPosition())
        inst._anim.target = target
        inst._anim.components.updatelooper:AddOnUpdateFn(FollowTarget)

        -- target:AddChild(inst._anim)

        -- local s1, s2, s3 = target.Transform:GetScale()
        -- inst._anim.Transform:SetScale(1 / s1, 1 / s2, 1 / s3)
    elseif not target then
        if inst._anim and inst._anim:IsValid() then
            -- local parent = inst._anim.entity:GetParent()

            -- if parent then
            --     print("parent:", parent)
            --     local x, y, z = parent.Transform:GetWorldPosition()
            --     inst._anim.Transform:SetPosition(x, y, z)
            --     parent:RemoveChild(inst)
            -- end
            -- inst._anim.Transform:SetScale(1, 1, 1)

            inst._anim.target = nil
            inst._anim.components.updatelooper:RemoveOnUpdateFn(FollowTarget)

            FadeOut(inst._anim)
        end

        inst._anim = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst._target = net_entity(inst.GUID, "inst._target", "targetdirty")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("targetdirty", OnTargetDirty)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.AttachTarget = function(inst, target)
        inst._target:set(target)
    end

    inst.KillFX = function()
        print("kill fx", inst)
        inst._target:set(nil)
        inst:DoTaskInTime(1, inst.Remove)
    end

    return inst
end

return Prefab("blythe_aim_reticule2", fn, assets)
