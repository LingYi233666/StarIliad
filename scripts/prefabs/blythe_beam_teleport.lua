local assets =
{
    Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
}

local function CollisionCallback(inst, other)
    if other and not other:HasTag("pond")
        and not inst.already_hit
        and inst.components.complexprojectile.attacker ~= nil
        and other ~= inst.components.complexprojectile.attacker then
        inst.components.complexprojectile:Hit(other)
    end
end

local function RemoveAimReticule(inst)
    if inst.aim_reticule and inst.aim_reticule:IsValid() then
        local parent = inst.aim_reticule.entity:GetParent()
        if parent then
            local x, y, z = parent.Transform:GetWorldPosition()
            parent:RemoveChild(inst.aim_reticule)
            inst.aim_reticule.Transform:SetPosition(x, y, z)
        end
        inst.aim_reticule:KillFX()
    end
    inst.aim_reticule = nil
end

local function OnRemove(inst)
    RemoveAimReticule(inst)
end

local function OnProjectileLaunch(inst, attacker, target_pos)
    if attacker
        and attacker:IsValid()
        and attacker.sg
        and attacker.sg.statemem.aim_reticule
        and attacker.sg.statemem.aim_reticule:IsValid() then
        inst.aim_reticule = attacker.sg.statemem.aim_reticule
        attacker.sg.statemem.aim_reticule = nil
    end
end

-- local function TeleportToCaster(caster, target)
--     local p1 = caster:GetPosition()
--     local p2 = target:GetPosition()
--     local towards = (p2 - p1):GetNormalized()

--     local dist = math.max(1.5, caster:GetPhysicsRadius(0) + target:GetPhysicsRadius(0))

--     local pos = p1 + towards * dist
--     target.Transform:SetPosition(pos:Get())
-- end

local function SpawnTeleportFX(target, pos)
    pos = pos or target:GetPosition()

    if target:HasTag("character") or target:HasTag("largecreature") then
        SpawnAt("blythe_beam_teleport_pickup_large_front_fx", pos)
        SpawnAt("blythe_beam_teleport_pickup_large_back_fx", pos)
    else
        SpawnAt("blythe_beam_teleport_pickup_fx", pos)
    end
end

local function ProjectileOnHit(inst, attacker, target)
    inst.already_hit = true
    if inst.tail and inst.tail:IsValid() then
        inst.tail._stop_event:push()
    end

    RemoveAimReticule(inst)

    -- SpawnAt("blythe_beam_purple_hit_fx", inst)
    SpawnAt("blythe_beam_white_hit_fx", inst)


    if attacker and attacker:IsValid() and target and target:IsValid() then
        if (target.components.inventoryitem or target.components.locomotor) and not target:HasTag("largecreature") then
            local p1 = attacker:GetPosition()
            local p2 = target:GetPosition()
            local towards = (p2 - p1):GetNormalized()

            local dist = math.max(1.5, attacker:GetPhysicsRadius(0) + target:GetPhysicsRadius(0))

            local pos = p1 + towards * dist
            target.Transform:SetPosition(pos:Get())


            SpawnTeleportFX(target, p2)

            if target.components.inventoryitem and attacker.components.inventory:GiveItem(target, nil, pos) then
                -- Give to attacker, no need to spawn fx
            else
                SpawnTeleportFX(target, pos)
            end
        elseif attacker.components.combat and attacker.components.combat:CanTarget(target) then
            -- Can't teleport, just do attack
            -- attacker.components.combat:DoAttack(target, inst, inst, nil, nil, math.huge)
        end
    end

    -- inst:Remove()

    inst:Hide()
    inst:DoTaskInTime(3 * FRAMES, inst.Remove)
end

local function CanInteract(inst, v)
    local dist = math.sqrt(inst:GetDistanceSqToInst(v))
    return dist < 0.5 + v:GetPhysicsRadius(0)
end

local function ProjectileOnUpdate(inst)
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

    if inst.entity:IsVisible() and not inst.tail then
        -- inst.tail = inst:SpawnChild("blythe_beam_tail_purple")
        inst.tail = inst:SpawnChild("blythe_beam_teleport_surrounding")
        inst.tail.entity:AddFollower()
        inst.tail.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    if inst.entity:IsVisible() and not inst.arrow then
        inst.arrow = inst:SpawnChild("blythe_beam_teleport_arrow")
        inst.arrow.entity:AddFollower()
        inst.arrow.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)

    -----------------------------------------------------------------------

    local attacker = inst.components.complexprojectile.attacker
    local x, y, z = inst.Transform:GetWorldPosition()

    -- combat target will block on the path
    local combat_ents = TheSim:FindEntities(x, y, z, 3, { "_combat", "_health" }, { "INLIMBO" })
    for k, v in pairs(combat_ents) do
        if CanInteract(inst, v) and attacker.components.combat and attacker.components.combat:CanTarget(v) then
            inst.components.complexprojectile:Hit(v)
            return true
        end
    end

    -----------------------------------------------------------------------

    local ents = TheSim:FindEntities(x, y, z, 3, nil,
        { "INLIMBO", "FX", "largecreature", "carnivalgame_part", "event_trigger", },
        { "_inventoryitem", "locomotor" })

    for k, v in pairs(ents) do
        if v ~= attacker and CanInteract(inst, v) then
            if inst.target ~= nil then
                if v == inst.target then
                    inst.components.complexprojectile:Hit(v)
                    break
                end
            else
                inst.components.complexprojectile:Hit(v)
                break
            end
        end
    end

    return true
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- MakeProjectilePhysics(inst, nil, 0.25)

    StarIliadBasic.MakeCollidableProjectilePhysics(inst)

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst.AnimState:SetMultColour(0, 0, 0, 0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(CollisionCallback)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(27)
    inst.components.complexprojectile:SetOnLaunch(OnProjectileLaunch)
    inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
    inst.components.complexprojectile.onupdatefn = ProjectileOnUpdate

    inst:ListenForEvent("onremove", OnRemove)

    return inst
end

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
    -- inst.AnimState:SetAddColour(1, 0, 1, 0)
    inst.AnimState:SetAddColour(1, 1, 1, 0)


    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end


local function pickup_fx_common_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sand_puff")
    inst.AnimState:SetBuild("sand_puff")
    inst.AnimState:PlayAnimation("forage_out")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetAddColour(1, 0, 0.4, 1)
    -- inst.AnimState:SetMultColour(0.5, 0, 1, 1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function pickup_fx_fn()
    local inst = pickup_fx_common_fn()

    return inst
end

local function pickup_fx_large_front_fn()
    local inst = pickup_fx_common_fn()

    local s = 1.5
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:Hide("back")

    return inst
end

local function pickup_fx_large_back_fn()
    local inst = pickup_fx_common_fn()

    local s = 1.5
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:Hide("front")

    return inst
end

return Prefab("blythe_beam_teleport", fn, assets),
    Prefab("blythe_beam_teleport_arrow", arrow_fn, assets),
    Prefab("blythe_beam_teleport_pickup_fx", pickup_fx_fn, assets),
    Prefab("blythe_beam_teleport_pickup_large_front_fx", pickup_fx_large_front_fn, assets),
    Prefab("blythe_beam_teleport_pickup_large_back_fx", pickup_fx_large_back_fn, assets)
