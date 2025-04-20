local assets =
{
    Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
}

local function ProjectileTeleportOnHit(inst, attacker, target)
    SpawnAt("blythe_beam_purple_hit_fx", inst)

    if attacker and attacker:IsValid() and target then
        if (target.components.inventoryitem or target.components.locomotor)
            and not target:HasTag("largecreature") then
            local p1 = attacker:GetPosition()
            local p2 = target:GetPosition()
            local towards = (p2 - p1):GetNormalized()

            local dist = math.max(1.5, attacker:GetPhysicsRadius(0) + target:GetPhysicsRadius(0))

            local pos = p1 + towards * dist
            target.Transform:SetPosition(pos:Get())

            local s = (target:HasTag("character") or target:HasTag("largecreature")) and 1.5 or 1

            SpawnAt("blythe_beam_teleport_pickup_fx", p2, { s, s, s })

            local spawn_after = true
            if target.components.inventoryitem then
                if attacker.components.inventory:GiveItem(target, nil, pos) then
                    spawn_after = false
                end
            end

            if spawn_after then
                SpawnAt("blythe_beam_teleport_pickup_fx", pos, { s, s, s })
            end
        elseif attacker.components.combat and attacker.components.combat:CanTarget(target) then
            attacker.components.combat:DoAttack(target, inst, inst, nil, nil, math.huge)
        end
    end

    inst:Remove()
end

local function CommonOnUpdate(inst)
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
        inst.tail = inst:SpawnChild("blythe_beam_tail_purple")
        inst.tail.entity:AddFollower()
        inst.tail.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    if inst.entity:IsVisible() and not inst.arrow then
        inst.arrow = inst:SpawnChild("blythe_beam_teleport_arrow")
        inst.arrow.entity:AddFollower()
        inst.arrow.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)
end

local function TeleportOnUpdate(inst)
    local ret = CommonOnUpdate(inst)
    if ret ~= nil then
        return ret
    end

    local attacker = inst.components.complexprojectile.attacker
    local x, y, z = inst.Transform:GetWorldPosition()

    local find_combat_ent = false
    local combat_ents = TheSim:FindEntities(x, y, z, 3, { "_combat", "_health" }, { "INLIMBO" })
    for k, v in pairs(combat_ents) do
        if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
            local dist = math.sqrt(inst:GetDistanceSqToInst(v))
            if dist < inst:GetPhysicsRadius(0) + v:GetPhysicsRadius(0) then
                inst.components.complexprojectile:Hit(v)
                find_combat_ent = true
                break
            end
        end
    end

    if find_combat_ent then
        return true
    end

    local ents = TheSim:FindEntities(x, y, z, 3, nil,
        { "INLIMBO", "FX", "largecreature", "carnivalgame_part", "event_trigger", },
        { "_inventoryitem", "locomotor" })

    for k, v in pairs(ents) do
        if v ~= attacker then
            local dist = math.sqrt(inst:GetDistanceSqToInst(v))
            if dist < inst:GetPhysicsRadius(0) + v:GetPhysicsRadius(0) then
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
    end

    return true
end

local function common_fn()
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

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("stariliad_spdamage_force")
    inst.components.stariliad_spdamage_force:SetBaseDamage(17)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(34)


    return inst
end


local function teleport_fn()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.complexprojectile:SetOnHit(ProjectileTeleportOnHit)
    inst.components.complexprojectile.onupdatefn = TeleportOnUpdate

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
    inst.AnimState:SetAddColour(1, 0, 1, 0)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    return inst
end


local function pickup_fx_fn()
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

return Prefab("blythe_beam_teleport", teleport_fn, assets),
    Prefab("blythe_beam_teleport_arrow", arrow_fn, assets),
    Prefab("blythe_beam_teleport_pickup_fx", pickup_fx_fn, assets)
