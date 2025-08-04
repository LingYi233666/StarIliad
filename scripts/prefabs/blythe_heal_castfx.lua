local assets = {
    Asset("ANIM", "anim/bloodpump.zip"),
    Asset("ANIM", "anim/cointosscast_fx.zip"),
    Asset("ANIM", "anim/mount_cointosscast_fx.zip"),

    Asset("ANIM", "anim/blythe_skill_heal.zip"),
}

local function SetUp(inst, colour)
    inst.AnimState:SetMultColour(colour[1], colour[2], colour[3], 1)
end


local function MakeFX(prefab, bank, build, anim, face)
    local function MakeHeart()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("FX")

        inst.AnimState:SetBank("blythe_skill_heal")
        inst.AnimState:SetBuild("blythe_skill_heal")
        inst.AnimState:PlayAnimation("heart")

        local s = 0.4
        inst.AnimState:SetScale(s, s, s)

        inst.AnimState:SetLightOverride(1)

        inst.persists = false

        return inst
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        if face == 6 then
            inst.Transform:SetSixFaced()
        elseif face == 4 then
            inst.Transform:SetFourFaced()
        end

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:SetSymbolMultColour("coin01", 0, 0, 0, 0)

        inst.AnimState:SetFinalOffset(1)
        inst.AnimState:SetLightOverride(1)

        if not TheNet:IsDedicated() then
            local heart = MakeHeart()
            inst:AddChild(heart)

            heart.entity:AddFollower()
            -- heart.Follower:FollowSymbol(inst.GUID, "coin01", 0, 0, 0, true)
            heart.Follower:FollowSymbol(inst.GUID, "coin01", 0, 0, 0)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.SetUp = SetUp

        inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end

    return Prefab(prefab, fn, assets)
end

return MakeFX("blythe_heal_castfx", "cointosscast_fx", "cointosscast_fx", "cointoss", 4),
    MakeFX("blythe_heal_castfx_mount", "mount_cointosscast_fx", "cointosscast_fx", "cointoss", 6)
