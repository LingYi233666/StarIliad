local assets =
{
    Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
}

local function AddColdnessToTarget(inst, attacker, target)
    if target and target:IsValid() then
        local effective = false
        local factor = target:GetIsWet() and 2 or 1
        if target.components.freezable then
            target.components.freezable:AddColdness(0.3 * factor)
            effective = true
        end

        if target.components.temperature then
            target.components.temperature:DoDelta(-3 * factor)
            effective = true
        end

        if target.components.burnable and target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
            effective = true
        end

        if effective then
            inst.victims[target] = inst:DoTaskInTime(1, function()
                inst.victims[target] = nil
            end)
        end
    end
end


local function ProjectileOnHit(inst, attacker, target)
    inst:Remove()
end

local function CanInteract(inst, v)
    local dist = math.sqrt(inst:GetDistanceSqToInst(v))
    return dist < 0.5 + v:GetPhysicsRadius(0)
end

local function OnLaunch(inst, attacker, target_pos)
    -- if not inst:HasTag("blythe_beam_side") then
    -- local attacker_pos = attacker:GetPosition()
    -- local axis_x = (target_pos - attacker_pos):GetNormalized()
    -- local axis_y = Vector3(0, 1, 0)
    -- local axis_z = axis_y:Cross(axis_x):GetNormalized()

    -- for deg = 5, 50, 5 do
    --     local x1 = math.cos(deg * DEGREES)
    --     local z1 = math.sin(deg * DEGREES)

    --     local proj = SpawnAt("blythe_ice_fog", attacker)
    --     proj:AddTag("blythe_beam_side")

    --     local cur_target_pos = attacker_pos + axis_x * x1 + axis_z * z1
    --     proj.components.complexprojectile:Launch(cur_target_pos, attacker)
    -- end

    -- for deg = -5, -50, -5 do
    --     local x1 = math.cos(deg * DEGREES)
    --     local z1 = math.sin(deg * DEGREES)

    --     local proj = SpawnAt("blythe_ice_fog", attacker)
    --     proj:AddTag("blythe_beam_side")

    --     local cur_target_pos = attacker_pos + axis_x * x1 + axis_z * z1
    --     proj.components.complexprojectile:Launch(cur_target_pos, attacker)
    -- end

    -- for i = 1, 2 do
    --     local proj = SpawnAt("blythe_ice_fog", attacker)
    --     local duration = FRAMES * i
    --     local duration2 = duration * duration
    --     proj:AddTag("blythe_beam_side")

    --     local init_speed = TUNING.BLYTHE_ICE_FOG_SPEED + TUNING.BLYTHE_ICE_FOG_ACCURATE * duration
    --     local offset_x = TUNING.BLYTHE_ICE_FOG_SPEED * duration + 0.5 * TUNING.BLYTHE_ICE_FOG_ACCURATE * duration2
    --     proj.components.complexprojectile:SetHorizontalSpeed(init_speed)
    --     proj.components.complexprojectile:SetLaunchOffset(Vector3(offset_x, 0, 0))
    --     proj.components.complexprojectile:Launch(target_pos, attacker)
    -- end
    -- end

    -- if not attacker.SoundEmitter:PlayingSound("ice_fog_loop") then
    --     attacker.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/ice_fog_loop", "ice_fog_loop")
    -- end

    -- if attacker.ice_fog_sound_task then
    --     attacker.ice_fog_sound_task:Cancel()
    --     attacker.ice_fog_sound_task = nil
    -- end

    -- attacker.ice_fog_sound_task = attacker:DoTaskInTime(3 * FRAMES, function()
    --     if attacker.SoundEmitter:PlayingSound("ice_fog_loop") then
    --         attacker.SoundEmitter:KillSound("ice_fog_loop")
    --     end

    --     -- if attacker.ice_fog_sound_task then
    --     --     attacker.ice_fog_sound_task:Cancel()
    --     --     attacker.ice_fog_sound_task = nil
    --     -- end
    --     attacker.ice_fog_sound_task = nil
    -- end)
end


local function ProjectileOnUpdate(inst)
    inst.max_range = inst.max_range or 20
    inst.start_pos = inst.start_pos or inst:GetPosition()

    local dist_moved = (inst:GetPosition() - inst.start_pos):Length()
    if dist_moved >= inst.max_range then
        inst.components.complexprojectile:Hit()
        return true
    else
        if dist_moved >= 0.66 then
            inst:Show()
        else
            inst:Hide()
        end
    end

    if inst.entity:IsVisible() and not inst.fog then
        inst.fog = inst:SpawnChild("blythe_ice_fog_particle")
        inst.fog.entity:AddFollower()
        inst.fog.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -170, 0)
    end

    local speed = inst.components.complexprojectile.horizontalSpeed
    inst.Physics:SetMotorVel(speed, 0, 0)

    inst.components.complexprojectile.horizontalSpeed = math.max(0, speed + TUNING.BLYTHE_ICE_FOG_ACCURATE * FRAMES)


    local attacker = inst.components.complexprojectile.attacker
    local x, y, z = inst.Transform:GetWorldPosition()

    local combat_ents = TheSim:FindEntities(x, y, z, 3, nil, { "INLIMBO" })
    for k, v in pairs(combat_ents) do
        if v ~= attacker
            and v:IsValid()
            and CanInteract(inst, v)
            and not inst.victims[v]
            and (v.components.freezable or v.components.temperature or v.components.burnable) then
            AddColdnessToTarget(inst, attacker, v)
        end
    end

    if inst.components.complexprojectile.horizontalSpeed <= 0 then
        inst.components.complexprojectile:Hit()
    end

    return true
end

-- local function GetHeatFn(inst, observer)
--     if observer and observer == inst.components.complexprojectile.attacker then
--         return nil
--     end

--     return -99999
-- end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst, nil, 0.25)

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst.AnimState:SetMultColour(0, 0, 0, 0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst.victims = {}

    -- inst:AddComponent("heater")
    -- inst.components.heater.heatfn = GetHeatFn
    -- inst.components.heater:SetThermics(false, true)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(TUNING.BLYTHE_ICE_FOG_SPEED)
    inst.components.complexprojectile:SetOnLaunch(OnLaunch)
    inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
    inst.components.complexprojectile.onupdatefn = ProjectileOnUpdate


    return inst
end



return Prefab("blythe_ice_fog", fn, assets)
