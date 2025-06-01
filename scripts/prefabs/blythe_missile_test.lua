local assets =
{
    Asset("ANIM", "anim/missile_fx.zip"),
    Asset("ANIM", "anim/blythe_missile_rotation.zip"),
}



local function CreateMissileLoop()
    local looper = CreateEntity()

    --[[Non-networked entity]]
    --looper.entity:SetCanSleep(false)
    looper.persists = false

    looper.entity:AddTransform()
    looper.entity:AddAnimState()
    looper.entity:AddFollower()

    looper:AddTag("FX")
    looper:AddTag("NOCLICK")

    looper.AnimState:SetBank("missile_fx")
    looper.AnimState:SetBuild("missile_fx")
    looper.AnimState:PlayAnimation("missile_loop", true)
    looper.AnimState:SetSymbolBloom("fx_missile_white")
    looper.AnimState:SetSymbolLightOverride("fx_missile_white", 0.3)
    looper.AnimState:SetLightOverride(1)

    return looper
end

local function OnUpdateFn(inst)
    local up = -TheCamera:GetPitchDownVec():GetNormalized()
    local my_pos = inst:GetPosition()
    local target_pos = ThePlayer:GetPosition()

    local forward = (target_pos - my_pos):GetNormalized() * 0.1
    local target_pos2 = my_pos + forward

    local x1, y1 = TheSim:GetScreenPos(my_pos.x, my_pos.y, my_pos.z)
    -- local x2, y2 = TheSim:GetScreenPos(target_pos2.x, target_pos2.y, target_pos2.z)
    local x2, y2 = TheSim:GetScreenPos(target_pos.x, target_pos.y, target_pos.z)

    local angle = math.atan2(y2 - y1, x2 - x1) * RADIANS
    if angle > 360 then
        angle = angle - 360
    end
    if angle < 0 then
        angle = angle + 360
    end

    local anim_time = angle / 100
    local percent = anim_time / inst.anim_length

    inst.AnimState:SetPercent("anim", percent)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)



    if not TheNet:IsDedicated() then
        inst.AnimState:SetBank("blythe_missile_rotation")
        inst.AnimState:SetBuild("blythe_missile_rotation")
        inst.AnimState:SetPercent("anim", 0)

        inst.anim_length = inst.AnimState:GetCurrentAnimationLength()

        inst.missile = CreateMissileLoop()
        inst:AddChild(inst.missile)
        inst.missile.entity:AddFollower()
        inst.missile.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 0, 0, true)

        inst.task = inst:DoPeriodicTask(0, OnUpdateFn)
    end



    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end



    return inst
end

return Prefab("blythe_missile_test", fn, assets)
