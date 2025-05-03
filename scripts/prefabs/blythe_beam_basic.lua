local assets =
{
    Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
}

local function CollisionCallback(inst, other)
    if other and not other:HasTag("pond")
        and not inst._is_wave_beam:value()
        and inst.components.complexprojectile.attacker ~= nil
        and other ~= inst.components.complexprojectile.attacker
        and other.components.combat == nil
        and (inst.last_reflect_time == nil or GetTime() - inst.last_reflect_time > 5 * FRAMES) then
        -- inst.components.complexprojectile:Hit(other)


        local fx = SpawnAt(inst.hit_fx_prefab, inst)
        fx.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/beam_reflect")

        local my_pos = inst:GetPosition()
        local other_pos = other:GetPosition()
        local delta_pos = my_pos - other_pos
        local speed = Vector3(inst.Physics:GetVelocity()):GetNormalized()
        local reflection_speed = StarIliadMath.GetReflectionSpeed(other_pos, my_pos, speed)

        inst:ForceFacePoint(my_pos + reflection_speed)


        local all_rad = inst:GetPhysicsRadius(0) + other:GetPhysicsRadius(0) + 0.1
        if delta_pos:Length() < all_rad then
            my_pos = other_pos + delta_pos:GetNormalized() * all_rad
        end
        -- my_pos = my_pos + reflection_speed * 1.5

        -- inst.Transform:SetPosition(my_pos:Get())

        inst.Physics:Teleport(my_pos:Get())

        inst.last_reflect_time = GetTime()
    end
end

local function DoAttackDamage(inst, attacker, target)
    if attacker
        and attacker:IsValid()
        and attacker.components.combat
        and attacker.components.combat:CanTarget(target) then
        attacker.components.combat:DoAttack(target, inst, inst, nil, nil, math.huge)


        inst.victims[target] = true

        local factor = 1
        for k, v in pairs(inst.victims) do
            factor = factor * 0.95
        end

        inst.components.stariliad_spdamage_force:AddMultiplier(attacker, math.max(0.1, factor),
            "plasma_beam_piercing_weaken")
    end

    SpawnAt(inst.hit_fx_prefab, inst)
end

local function OnHit(inst, attacker, target)
    DoAttackDamage(inst, attacker, target)
    inst:Remove()
end

local function SpawnSideBeam(inst, attacker)
    local main_pos = inst:GetPosition()
    local attacker_pos = attacker:GetPosition()

    local axis_x = StarIliadBasic.GetFaceVector(inst)
    local axis_y = Vector3(0, 1, 0)
    local axis_z = axis_y:Cross(axis_x):GetNormalized()

    -- local offsets = { axis_z * 1, axis_z * -1 }

    local offsets_data = {
        { speed = 3,  duration = 1.0 / 3 },
        { speed = -3, duration = 1.0 / 3 },
    }

    local projectiles_side = {}
    for _, offset_data in pairs(offsets_data) do
        local proj_side = SpawnAt("blythe_beam_basic", inst)

        if not proj_side then
            return
        end

        proj_side:AddTag("blythe_beam_side")

        proj_side._is_wide_beam:set(inst._is_wide_beam:value())
        proj_side._is_wave_beam:set(inst._is_wave_beam:value())
        proj_side._is_plasma_beam:set(inst._is_plasma_beam:value())

        -- proj_side.target = inst.target
        -- proj_side.side_beam_offset = offset
        proj_side.side_beam_speed = offset_data.speed
        proj_side.side_beam_widen_duration_tmp = offset_data.duration
        proj_side.side_beam_widen_duration = 0


        proj_side.components.stariliad_spdamage_force:AddMultiplier(attacker, 0.25, "wide_beam")

        local forward_speed = inst.components.complexprojectile.horizontalSpeed

        proj_side.components.complexprojectile:SetHorizontalSpeed(forward_speed / 2)
        proj_side.components.complexprojectile:SetLaunchOffset(Vector3(main_pos.x - attacker_pos.x, 0, 0))
        proj_side.components.complexprojectile:Launch(main_pos + axis_x, attacker)
        proj_side:DoTaskInTime(3 * FRAMES, function()
            proj_side.components.complexprojectile:SetHorizontalSpeed(forward_speed)
        end)

        table.insert(projectiles_side, proj_side)
    end

    return projectiles_side
end

local function OnLaunch(inst, attacker, target_pos)
    if inst._is_wide_beam:value() and not inst:HasTag("blythe_beam_side") then
        inst.projectiles_side = SpawnSideBeam(inst, attacker)
    end
end

local function OnUpdate(inst)
    inst.max_range = inst.max_range or GetRandomMinMax(20, 25)
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

    local attacker = inst.components.complexprojectile.attacker


    if inst.entity:IsVisible() then
        if not inst.tail then
            inst.tail = inst:SpawnChild(inst.tail_prefab)
            inst.tail.entity:AddFollower()
            inst.tail.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
        end

        if not inst.arrow then
            inst.arrow = inst:SpawnChild(inst.arrow_prefab)
            inst.arrow.entity:AddFollower()
            inst.arrow.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
        end

        -- if inst._is_wide_beam:value() and not inst.side_beam_spawned and not inst:HasTag("blythe_beam_side") then
        --     SpawnSideBeam(inst, attacker)
        --     inst.side_beam_spawned = true
        -- end

        if inst.projectiles_side then
            for _, v in pairs(inst.projectiles_side) do
                v.side_beam_widen_duration = v.side_beam_widen_duration_tmp
                v.side_beam_widen_duration_tmp = nil
            end

            inst.projectiles_side = nil
        end
    end

    local forward_speed = inst.components.complexprojectile.horizontalSpeed
    if not inst:HasTag("blythe_beam_side") or inst.side_beam_widen_duration <= 0 then
        inst.Physics:SetMotorVel(forward_speed, 0, 0)
    else
        inst.Physics:SetMotorVel(forward_speed, 0, inst.side_beam_speed)
        inst.side_beam_widen_duration = inst.side_beam_widen_duration - FRAMES
    end


    local x, y, z = inst.Transform:GetWorldPosition()

    -- local ents = TheSim:FindEntities(x, y, z, 1, { "_combat", "_health" }, { "INLIMBO" })
    -- for k, v in pairs(ents) do
    --     if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
    --         inst.components.complexprojectile:Hit(v)
    --         break
    --     end
    -- end

    local ents = TheSim:FindEntities(x, y, z, 3, { "_combat", "_health" }, { "INLIMBO" })
    for k, v in pairs(ents) do
        if attacker.components.combat
            and attacker.components.combat:CanTarget(v)
            and not attacker.components.combat:IsAlly(v)
            and inst.victims[v] == nil then
            local dist = math.sqrt(inst:GetDistanceSqToInst(v))
            if dist < 0.5 + v:GetPhysicsRadius(0) then
                if not inst._is_plasma_beam:value() then
                    inst.components.complexprojectile:Hit(v)
                    break
                else
                    DoAttackDamage(inst, attacker, v)
                end
            end
        end
    end

    return true
end

local function ConfigureArrowTail(inst)
    if inst._is_wave_beam:value() and inst._is_plasma_beam:value() then
        -- inst.arrow_prefab = "blythe_beam_arrow_green"
        inst.arrow_prefab = "blythe_beam_arrow_red"

        inst.tail_prefab = "blythe_beam_tail_purple"
        -- inst.tail_prefab = "blythe_beam_tail_red"

        -- inst.hit_fx_prefab = "blythe_beam_green_purple_hit_fx"
        inst.hit_fx_prefab = "blythe_beam_red_hit_fx"
    elseif inst._is_plasma_beam:value() then
        -- inst.arrow_prefab = "blythe_beam_arrow_green"
        inst.arrow_prefab = "blythe_beam_arrow_red"

        -- inst.tail_prefab = "blythe_beam_tail_green"
        inst.tail_prefab = "blythe_beam_tail_red"

        -- inst.hit_fx_prefab = "blythe_beam_green_hit_fx"
        inst.hit_fx_prefab = "blythe_beam_red_hit_fx"
    elseif inst._is_wave_beam:value() then
        inst.arrow_prefab = "blythe_beam_arrow_purple"
        inst.tail_prefab = "blythe_beam_tail_purple"
        inst.hit_fx_prefab = "blythe_beam_purple_hit_fx"
    end
end

local function OnWideBeamDirty(inst)
    if not TheWorld.ismastersim then
        return
    end
end

local function OnWaveBeamDirty(inst)
    -- Physics are common code
    if inst._is_wave_beam:value() then
        inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
    else
        print("Warning! Currently not support return to un-wave beam!!!!!!!!")
    end

    if not TheWorld.ismastersim then
        return
    end

    ConfigureArrowTail(inst)
end

local function OnPlasmaBeamDirty(inst)
    if not TheWorld.ismastersim then
        return
    end

    ConfigureArrowTail(inst)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    StarIliadBasic.MakeCollidableProjectilePhysics(inst)

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst.AnimState:SetMultColour(0, 0, 0, 0)

    ------------------------------------------------------------------------------
    inst._is_wide_beam = net_bool(inst.GUID, "inst._is_wide_beam", "wide_beam_dirty")
    inst._is_wave_beam = net_bool(inst.GUID, "inst._is_wave_beam", "wave_beam_dirty")
    inst._is_plasma_beam = net_bool(inst.GUID, "inst._is_plasma_beam", "plasma_beam_dirty")

    inst._is_wide_beam:set(false)
    inst._is_wave_beam:set(false)
    inst._is_plasma_beam:set(false)

    inst:ListenForEvent("wide_beam_dirty", OnWideBeamDirty)
    inst:ListenForEvent("wave_beam_dirty", OnWaveBeamDirty)
    inst:ListenForEvent("plasma_beam_dirty", OnPlasmaBeamDirty)
    ------------------------------------------------------------------------------

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.victims = {}


    inst.tail_prefab   = "blythe_beam_tail_yellow"
    inst.arrow_prefab  = "blythe_beam_arrow_yellow"
    inst.hit_fx_prefab = "blythe_beam_yellow_hit_fx"


    inst.Physics:SetCollisionCallback(CollisionCallback)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("stariliad_spdamage_force")
    inst.components.stariliad_spdamage_force:SetBaseDamage(TUNING.BLYTHE_BEAM_BASIC_DAMAGE)

    inst:AddComponent("complexprojectile")
    -- inst.components.complexprojectile:SetLaunchOffset(Vector3(0.5, 0, 0))
    inst.components.complexprojectile:SetHorizontalSpeed(34)
    inst.components.complexprojectile:SetOnLaunch(OnLaunch)
    inst.components.complexprojectile:SetOnHit(OnHit)
    inst.components.complexprojectile.onupdatefn = OnUpdate

    return inst
end


local function MakeArrow(name, mult_colour, add_colour)
    local function arrow_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("lavaarena_blowdart_attacks")
        inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
        inst.AnimState:PlayAnimation("attack_3")

        inst.AnimState:SetLightOverride(1)

        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

        if mult_colour then
            inst.AnimState:SetMultColour(unpack(mult_colour))
        end

        if add_colour then
            -- inst.AnimState:SetAddColour(1, 1, 0, 0)
            inst.AnimState:SetAddColour(unpack(add_colour))
        end

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false


        return inst
    end

    return Prefab(name, arrow_fn, assets)
end


return Prefab("blythe_beam_basic", fn, assets),
    MakeArrow("blythe_beam_arrow_white", nil, { 1, 1, 1, 1 }),
    MakeArrow("blythe_beam_arrow_yellow", nil, { 1, 1, 0, 1 }),
    MakeArrow("blythe_beam_arrow_purple", nil, { 1, 0, 1, 1 }),
    MakeArrow("blythe_beam_arrow_green", { 0.1, 1, 1, 1 }, { 0, 1, 0, 1 }),
    MakeArrow("blythe_beam_arrow_red", nil, { 1, 0, 0, 1 })
