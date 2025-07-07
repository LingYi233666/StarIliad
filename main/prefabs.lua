AddPrefabPostInit("gelblob", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if not inst.components.colouradder then
        inst:AddComponent("colouradder")
    end

    MakeLargeFreezableCharacter(inst)
    inst.components.freezable.damagetobreak = inst.components.health.maxhealth

    local function OnAttacked(inst, data)
        if inst.components.freezable
            and inst.components.freezable:IsFrozen()
            and inst.components.health
            and not inst.components.health:IsDead() then
            inst.components.freezable:SpawnShatterFX()
            inst.components.colouradder:PushColour("freezable_2", 82 / 255, 115 / 255, 124 / 255, 1)
            inst.components.health:Kill()
        end
    end

    inst:ListenForEvent("attacked", OnAttacked)

    -- WARNING: Use _ignore_maxdamagetakenperhit is a little bad
    -- inst:ListenForEvent("freeze", function()
    --     -- if inst.components.health then
    --     --     inst.components.health._ignore_maxdamagetakenperhit = true
    --     --     inst.components.health.externalabsorbmodifiers:SetModifier(inst, -6, "freeze")
    --     -- end

    --     local x, y, z = inst.Transform:GetWorldPosition()
    --     local ents = TheSim:FindEntities(x, y, z, 4, nil, { "INLIMBO", "FX" })
    --     for _, v in pairs(ents) do
    --         if v:IsValid() and v.prefab == "gelblob_small_fx" then
    --             local mainblob = v.components.entitytracker and v.components.entitytracker:GetEntity("mainblob")
    --             if mainblob == inst then
    --                 v.components.entitytracker:ForgetEntity("mainblob")
    --             end
    --         end
    --     end
    -- end)

    -- inst:ListenForEvent("unfreeze", function()
    --     if inst.components.health then
    --         inst.components.health._ignore_maxdamagetakenperhit = nil
    --         inst.components.health.externalabsorbmodifiers:RemoveModifier(inst, "freeze")
    --     end
    -- end)
end)

AddPrefabPostInit("player_classified", function(inst)
    inst:ListenForEvent("isghostmodedirty", function(inst, data)
        if inst._parent
            and inst._parent.HUD
            and inst._parent.HUD.controls
            and inst._parent.HUD.controls.secondary_status
            and inst._parent.HUD.controls.secondary_status.blythe_missile_status then
            if inst.isghostmode:value() then
                inst._parent.HUD.controls.secondary_status.blythe_missile_status:Hide()
            else
                inst._parent.HUD.controls.secondary_status.blythe_missile_status:Show()
            end
        end
    end)
end)
