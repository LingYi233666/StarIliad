local assets = {}


local function MakeCloud(name, mult_colour, add_colour, lightoverride)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild("player_pistol")
        inst.AnimState:PlayAnimation("hand_shoot")

        if mult_colour then
            inst.AnimState:SetMultColour(unpack(mult_colour))
        end

        if add_colour then
            inst.AnimState:SetAddColour(unpack(add_colour))
        end

        if lightoverride then
            inst.AnimState:SetLightOverride(lightoverride)
        end

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.AnimState:SetTime(17 * FRAMES)

        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeCloud("stariliad_pistol_shoot_cloud"),
    MakeCloud("stariliad_pistol_shoot_cloud_purple", nil, { 1, 0, 1, 1 }, 1)
