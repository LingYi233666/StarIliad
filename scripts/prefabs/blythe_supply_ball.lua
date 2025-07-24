local assets =
{
    Asset("ANIM", "anim/deer_ice_charge.zip"),
    Asset("ANIM", "anim/deer_fire_charge.zip"),
}

local SCALE = 0.7

-- local COLOUR = { 96 / 255, 249 / 255, 255 / 255, 1 }
local COLOUR = { 0.8, 0.1, 0.1, 1 }


local function OnAbsorb(inst, player)
    if player then
        if inst.missile_recover and player.components.blythe_missile_counter then
            player.components.blythe_missile_counter:DoDeltaNumMissiles(inst.missile_recover)
        end

        if inst.super_missile_recover and player.components.blythe_missile_counter then
            player.components.blythe_missile_counter:DoDeltaNumSuperMissiles(inst.super_missile_recover)
        end
    end

    if inst.hit_fx_prefab then
        SpawnAt(inst.hit_fx_prefab, inst)
    end
    inst:Remove()
end


local function OnUpdateFn(inst, dt)
    local target = inst.chasing_target
    if not (target and target:IsValid() and not IsEntityDeadOrGhost(target, true)) then
        if inst.OnAbsorbFn then
            inst:OnAbsorbFn()
        end
        return true
    end

    local my_pos = inst:GetPosition()
    local target_pos = inst:GetTargetPosition(target)


    if (my_pos - target_pos):Length() < 0.5 or (my_pos - target:GetPosition()):Length() < 0.5 then
        if inst.OnAbsorbFn then
            inst:OnAbsorbFn(target)
        end
        return true
    end

    if GetTime() - inst.start_launch_time < inst.chase_after_time then
        local vx, vy, vz = (inst.direction * inst.speed):Get()
        inst.Physics:SetVel(vx, vy, vz)
        return true
    end

    local towards = target_pos - inst:GetPosition()

    local delta_vec = towards:GetNormalized() - inst.direction

    local cut_angle = StarIliadMath.AngleBetweenVectors(inst.direction, towards, true)
    local is_inverse_moving = math.abs(cut_angle) > 90

    if math.abs(cut_angle) < 10 or inst.locked then
        inst.locked = true
        inst.direction = towards:GetNormalized()
    else
        inst.direction = inst.direction + delta_vec:GetNormalized() * 0.14
    end

    local vx, vy, vz = (inst.direction * inst.speed):Get()
    inst.Physics:SetVel(vx, vy, vz)

    if is_inverse_moving then
        inst.speed = inst.speed - dt * 5
    else
        inst.speed = inst.speed + dt * 15
    end

    inst.speed = math.clamp(inst.speed, 10, 30)
end

local function Setup(inst, player, pos_start)
    if pos_start == nil then
        pos_start = inst:GetPosition()
    end
    -- pos_start.y = pos_start.y + GetRandomMinMax(2, 3)
    -- pos_start.y = pos_start.y
    local pos_player = player:GetPosition()

    local vec_out    = (pos_start - pos_player):GetNormalized()
    vec_out.y        = 0
    local vec_up     = Vector3(0, 1, 0)
    local vec_z      = vec_out:Cross(vec_up)

    local theta_1    = GetRandomMinMax(-45, 45) * DEGREES
    local theta_2    = GetRandomMinMax(0, 60) * DEGREES


    inst.speed             = GetRandomMinMax(8, 10)
    inst.direction         = vec_out * math.cos(theta_1) * math.cos(theta_2) + vec_up * math.sin(theta_2) +
        vec_z * math.sin(theta_1) * math.cos(theta_2)
    inst.chasing_target    = player
    inst.start_launch_time = GetTime()


    inst.Transform:SetPosition(pos_start:Get())
    inst.Physics:SetVel((inst.direction * inst.speed):Get())


    if inst.tail_prefab then
        inst.vfx = inst:SpawnChild(inst.tail_prefab)
        inst.vfx.entity:AddFollower()
        inst.vfx.Follower:FollowSymbol(inst.GUID, "glow_", 0, 0, 0)
    end

    inst.components.updatelooper:AddOnUpdateFn(OnUpdateFn)
end

local function GetTargetPosition(inst, target)
    return target:GetPosition() + (inst.target_offset or Vector3(0, 0, 0))
end

local function fn_common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    -- inst.AnimState:SetBank("deer_ice_charge")
    -- inst.AnimState:SetBuild("deer_ice_charge")
    -- inst.AnimState:PlayAnimation("pre")
    -- inst.AnimState:PushAnimation("loop", true)

    -- inst.AnimState:HideSymbol("line")
    -- inst.AnimState:HideSymbol("blast")


    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop", true)

    inst.AnimState:HideSymbol("line")
    inst.AnimState:HideSymbol("fire_puff_fx")
    inst.AnimState:HideSymbol("blast")

    inst.AnimState:SetMultColour(unpack(COLOUR))

    inst.Transform:SetScale(SCALE, SCALE, SCALE)


    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetDeltaTimeMultiplier(3)


    inst:AddTag("FX")
    inst:AddTag("NOCLICK")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.chase_after_time = GetRandomMinMax(0.4, 0.6)
    inst.target_offset = Vector3FromTheta(math.random() * PI2, 0.4)
    inst.target_offset.y = math.random(1, 1.75)

    inst.hit_fx_prefab = "blythe_supply_ball_missile_hit"
    inst.tail_prefab = "blythe_supply_ball_tail_red"

    inst.Setup = Setup
    inst.GetTargetPosition = GetTargetPosition
    inst.OnAbsorbFn = OnAbsorb


    inst:AddComponent("updatelooper")

    inst:ListenForEvent("animover", function()
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end)

    inst.persists = false

    return inst
end

local function fn_missile()
    local inst = fn_common()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.missile_recover = 1

    return inst
end

local function fn_super_missile()
    local inst = fn_common()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.super_missile_recover = 1

    return inst
end

local function fn_missile_hit()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()


    -- inst.AnimState:SetBank("deer_ice_charge")
    -- inst.AnimState:SetBuild("deer_ice_charge")
    -- inst.AnimState:PlayAnimation("blast")

    -- inst.AnimState:HideSymbol("line")
    -- inst.AnimState:HideSymbol("blast")

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast")

    inst.AnimState:HideSymbol("line")
    inst.AnimState:HideSymbol("fire_puff_fx")
    inst.AnimState:HideSymbol("blast")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetMultColour(unpack(COLOUR))

    inst.AnimState:SetDeltaTimeMultiplier(2)

    inst.Transform:SetScale(SCALE, SCALE, SCALE)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end


return Prefab("blythe_supply_ball_missile", fn_missile, assets),
    Prefab("blythe_supply_ball_super_missile", fn_super_missile, assets),
    Prefab("blythe_supply_ball_missile_hit", fn_missile_hit, assets)
