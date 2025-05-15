local assets =
{
    Asset("ANIM", "anim/lavaarena_firebomb.zip"),
    Asset("ANIM", "anim/bearger_ring_fx.zip"),
}


local function segment_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.vfx = inst:SpawnChild("blythe_beam_swap_segment_particle")
    inst.vfx.entity:AddFollower()
    inst.vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)


    inst:DoTaskInTime(4 * FRAMES, inst.Remove)

    return inst
end

local function EmitSegments(start_pos, end_pos)
    local delta_pos  = end_pos - start_pos
    delta_pos.y      = 0
    local forward    = delta_pos:GetNormalized()
    local range_step = 1
    local num_steps  = delta_pos:Length() / range_step

    for i = 1, num_steps - 1 do
        local cur_pos = start_pos + forward * i * range_step

        local segment = SpawnAt("blythe_beam_swap_segment", cur_pos)
        local angle   = math.atan2(-forward.z, forward.x) * RADIANS
        segment.Transform:SetRotation(angle)
    end

    print("dist:", delta_pos:Length())
end

local function LaunchBeam(inst, target_pos, attacker)
    local my_pos     = attacker:GetPosition()
    local forward    = (target_pos - my_pos):GetNormalized()
    local max_range  = (attacker.components.combat:GetAttackRange() + 2)
    local range_step = 0.5
    local num_steps  = max_range / range_step
    forward.y        = 0


    local victim = nil
    local final_pos = nil

    for i = 1, num_steps do
        final_pos = my_pos + forward * i * range_step
        -- local x, y, z = (my_pos + forward * i * range_step):Get()
        local x, y, z = final_pos:Get()

        local ents = TheSim:FindEntities(x, y, z, 3, nil, { "FX", "INLIMBO" })

        for _, v in pairs(ents) do
            if v ~= attacker then
                local dist = (final_pos - v:GetPosition()):Length()
                if dist < 0.5 + v:GetPhysicsRadius(0) and StarIliadUsurper.CanSwap(attacker, v) then
                    victim = v
                    break
                end
            end
        end

        if victim then
            break
        end
    end

    EmitSegments(my_pos, final_pos)



    if victim then
        SpawnAt("blythe_beam_swap_hit_fx", final_pos)
        ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .2, inst, 40)

        StarIliadUsurper.SwapPositionPre(attacker, victim)
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.LaunchBeam = LaunchBeam

    return inst
end


--------------------------------------------------------------

local function CreateAnim()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_firebomb")
    inst.AnimState:SetBuild("lavaarena_firebomb")
    inst.AnimState:PlayAnimation("used")
    inst.AnimState:SetLightOverride(1)

    return inst
end


local function hit_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")


    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst._anim = CreateAnim()
        inst:AddChild(inst._anim)

        inst._anim.AnimState:SetAddColour(0, 0.5, 0.5, 1)

        inst._anim.entity:AddFollower()
        inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    -- inst:ListenForEvent("animover", inst.Remove)

    inst.vfx = inst:SpawnChild("blythe_beam_swap_explode_particle")
    inst.vfx.entity:AddFollower()
    inst.vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)

    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")


    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

local function ring_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bearger_ring_fx")
    inst.AnimState:SetBuild("bearger_ring_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFrame(5)

    inst.AnimState:SetMultColour(0, 1, 0, 1)

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)

    local s = 0.5
    inst.Transform:SetScale(s, s, s)

    inst:AddTag("FX")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end



return Prefab("blythe_beam_swap_segment", segment_fn, assets),
    Prefab("blythe_beam_swap", fn, assets),
    Prefab("blythe_beam_swap_hit_fx", hit_fx_fn, assets),
    Prefab("blythe_beam_swap_ring_fx", ring_fn, assets)
