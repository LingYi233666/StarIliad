local assets =
{
    Asset("ANIM", "anim/gelblob.zip"),
}

local brain = require "brains/stariliad_boss_gorgoroth_blob_brain"

local CHUNK_RETURN_ACCEL = 0.0825

local function OnUpdate(inst)
    local mainblob = inst.components.entitytracker:GetEntity("mainblob")
    if mainblob and mainblob:IsValid() then
        local distsq = inst:GetDistanceSqToInst(mainblob)
        inst.speed = math.clamp(inst.speed + CHUNK_RETURN_ACCEL, 0, 6)
        -- if inst.speed > 0 then
        --     inst.components.locomotor.runspeed = inst.speed / math.sqrt(distsq)
        -- end
        inst.components.locomotor.runspeed = inst.speed

        if distsq <= 2 * 2 and not mainblob.sg:HasStateTag("no_absorb_blob") then
            inst.task:Cancel()
            inst.task = nil

            for ent, boolean in pairs(inst.victims) do
                ent.components.locomotor:RemoveExternalSpeedMultiplier(inst, inst.prefab)
            end
            inst.victims = {}

            mainblob:PushEvent("absorb_blob", { blob = inst })
            inst.sg:GoToState("despawn")

            return
        end
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 2, { "locomotor" },
        { "flying", "playerghost", "INLIMBO", "shadow_aligned" })

    local new_victims = {}

    -- for _, v in pairs(ents) do
    --     if inst:IsNear(v, 0.4) and not inst.sg:HasStateTag("busy") then
    --         if not inst.victims[v] then
    --             new_victims[v] = SpawnPrefab("gelblob_attach_fx")
    --             new_victims[v]:SetupBlob(inst, v)
    --             new_victims[v].AnimState:SetMultColour(1, 1, 1, 0.66)
    --             print("New victim:", v)
    --         end
    --     end
    -- end

    -- for ent, fx in pairs(inst.victims) do
    --     if not inst:IsNear(ent, 1) or inst.sg:HasStateTag("busy") then
    --         if fx:IsValid() then
    --             fx:KillFX()
    --         end
    --         print("Remove victim:", ent)
    --     else
    --         new_victims[ent] = fx
    --     end
    -- end

    for _, v in pairs(ents) do
        if inst:IsNear(v, 0.8) and not inst.sg:HasStateTag("busy") then
            if not inst.victims[v] then
                v.components.locomotor:SetExternalSpeedMultiplier(inst, inst.prefab, 0.5)
                new_victims[v] = true

                print("New victim:", v)
            end
        end
    end

    for ent, boolean in pairs(inst.victims) do
        if not inst:IsNear(ent, 0.8) or inst.sg:HasStateTag("busy") then
            ent.components.locomotor:RemoveExternalSpeedMultiplier(inst, inst.prefab)
            print("Remove victim:", ent)
        else
            new_victims[ent] = boolean
        end
    end

    inst.victims = new_victims
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 1.5)

    inst.entity:AddPhysics()
    inst.Physics:SetMass(10)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:SetCollisionMask(COLLISION.WORLD)
    inst.Physics:SetCapsule(0.5, 1)

    inst:AddTag("canbebottled")
    inst:AddTag("shadow_aligned")

    inst.AnimState:SetBank("gelblob")
    inst.AnimState:SetBuild("gelblob")
    inst.AnimState:PlayAnimation("blob_idle_med", true)

    inst.AnimState:HideSymbol("shine")

    inst.AnimState:SetMultColour(1, 1, 1, 0.8)

    inst:SetPrefabNameOverride("gelblob")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.speed = -3
    inst.victims = {}

    inst:AddComponent("entitytracker")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 1e-6
    inst.components.locomotor.runspeed = 1e-6

    inst:SetStateGraph("SGstariliad_boss_gorgoroth_blob")
    inst:SetBrain(brain)

    inst.task = inst:DoPeriodicTask(0, OnUpdate)

    return inst
end

return Prefab("stariliad_boss_gorgoroth_blob", fn, assets)
