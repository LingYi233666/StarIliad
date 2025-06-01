local assets =
{
    Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
    Asset("ANIM", "anim/stariliad_blowdart_attacks_red_white.zip"),
}


local function MakeArrow(name, mult_colour, add_colour)
    local function arrow_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("lavaarena_blowdart_attacks")
        inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
        inst.AnimState:PlayAnimation("attack_3", true)

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

local function MakeLargeArrow(name, mult_colour, add_colour, extra_fn)
    local function arrow_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("lavaarena_blowdart_attacks")
        inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
        -- inst.AnimState:PlayAnimation("attack_4_large", true)
        inst.AnimState:PlayAnimation("attack_4", true)
        -- inst.AnimState:PlayAnimation("attack_3", true)


        -- local s = 1.1
        -- inst.Transform:SetScale(s, s, s)


        inst.AnimState:SetLightOverride(1)

        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

        if mult_colour then
            inst.AnimState:SetMultColour(unpack(mult_colour))
        end

        if add_colour then
            -- inst.AnimState:SetAddColour(1, 1, 0, 0)
            inst.AnimState:SetAddColour(unpack(add_colour))
        end

        if extra_fn then
            extra_fn(inst)
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



return MakeArrow("blythe_beam_arrow_white", nil, { 1, 1, 1, 1 }),
    MakeArrow("blythe_beam_arrow_yellow", nil, { 1, 1, 0, 1 }),
    MakeArrow("blythe_beam_arrow_purple", nil, { 1, 0, 1, 1 }),
    MakeArrow("blythe_beam_arrow_green", { 0.1, 1, 1, 1 }, { 0, 1, 0, 1 }),
    MakeArrow("blythe_beam_arrow_red", nil, { 1, 0, 0, 1 }),
    MakeLargeArrow("blythe_beam_arrow_large_yellow"),
    MakeLargeArrow("blythe_beam_arrow_large_purple", nil, { 0, 0, 1, 1 }),
    MakeLargeArrow("blythe_beam_arrow_large_red", nil, nil, function(inst)
        inst.AnimState:OverrideSymbol("attack_4", "stariliad_blowdart_attacks_red_white", "attack_4")
    end)
