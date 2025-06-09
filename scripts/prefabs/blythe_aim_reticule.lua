local assets = {
    Asset("ANIM", "anim/reticuleaoe.zip"),
}

local function DoRotating(inst)
    local angle = inst.Transform:GetRotation()
    angle = angle + FRAMES * inst.rotate_speed

    inst.Transform:SetRotation(angle)
end

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

local function KillFX(inst, duration, scaleup)
    inst:DetachTarget()

    duration = duration or 0.3
    scaleup = scaleup or 1.05

    local s1, _, _ = inst.Transform:GetScale()

    inst:DoPeriodicTask(0, UpdatePing, nil, s1, s1 * scaleup, GetTime(), duration, {}, {})
    inst:DoTaskInTime(duration, inst.Remove)
end

local function AttachTarget(inst, target)
    if target:HasTag("largecreature") then
        inst.rotate_speed = 60
        inst.AnimState:PlayAnimation("idle")
    end

    target:AddChild(inst)

    local s1, s2, s3 = target.Transform:GetScale()
    inst.Transform:SetScale(1 / s1, 1 / s2, 1 / s3)
end


local function DetachTarget(inst)
    local parent = inst.entity:GetParent()
    if parent then
        local x, y, z = parent.Transform:GetWorldPosition()
        parent:RemoveChild(inst)
        inst.Transform:SetPosition(x, y, z)
    end

    inst.Transform:SetScale(1, 1, 1)
end


local function MakeReticule(name, anim, scale, mult_colour)
    scale = scale or 1
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("reticuleaoe")
        inst.AnimState:SetBuild("reticuleaoe")
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)

        inst.rotate_speed = 90
        inst.AnimState:SetScale(scale, scale, scale)

        if mult_colour then
            inst.AnimState:SetMultColour(unpack(mult_colour))
        end

        inst.Transform:SetInterpolateRotation(true)

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst.AttachTarget = AttachTarget
        inst.DetachTarget = DetachTarget
        inst.KillFX = KillFX

        inst:DoPeriodicTask(0, DoRotating)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeReticule("blythe_aim_reticule", "idle_small", 1),
    MakeReticule("blythe_aim_reticule_yellow", "idle_small", 1, { 0, 1, 1, 1 }),
    MakeReticule("blythe_aim_reticule_purple", "idle_small", 1, { 1, 0, 1, 1 })
