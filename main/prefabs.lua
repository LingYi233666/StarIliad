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

AddPrefabPostInit("minotaur", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if not inst.components.lootdropper then
        inst:AddComponent("lootdropper")
    end
    inst.components.lootdropper:AddChanceLoot("blythe_unlock_skill_item_speed_burst", 1.0)
end)

AddPrefabPostInit("forest", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("stariliad_weather_lightning_storm")
end)

AddPrefabPostInitAny(function(inst)
    if not TheNet:IsDedicated() then
        if inst.components.pointofinterest then
            inst:AddComponent("stariliad_important_scan_target")
        end
    end
end)

local function SaveForRerollWrapper(old_fn)
    local function SaveForReroll(inst, ...)
        local data = old_fn(inst, ...)

        if inst.prefab == "blythe" then
            inst.components.blythe_reroll_data_handler:UpdateMemory()
            data.blythe_reroll_data_handler = inst.components.blythe_reroll_data_handler:OnSave()
        else
            data.blythe_reroll_data_handler = inst.components.blythe_reroll_data_handler:OnSave()
        end

        print(inst, "save for reroll !  data.blythe_reroll_data_handler:")
        dumptable(data.blythe_reroll_data_handler)

        return data
    end

    return SaveForReroll
end

local function LoadForRerollWrapper(old_fn)
    local function LoadForReroll(inst, data, ...)
        old_fn(inst, data, ...)

        print(inst, "load for reroll !  data.blythe_reroll_data_handler:")
        dumptable(data.blythe_reroll_data_handler)

        if inst.prefab == "blythe" then
            if data.blythe_reroll_data_handler ~= nil then
                inst.components.blythe_reroll_data_handler:OnLoad(data.blythe_reroll_data_handler)
                inst.components.blythe_reroll_data_handler:ApplyMemory()
            end
        else
            if data.blythe_reroll_data_handler ~= nil then
                inst.components.blythe_reroll_data_handler:OnLoad(data.blythe_reroll_data_handler)
            end
        end
    end

    return LoadForReroll
end

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("stariliad_rain_fx_bonus_watcher")

    if not TheWorld.ismastersim then
        return
    end

    if inst.prefab == "blythe" or inst.prefab == "wonkey" then
        inst:AddComponent("blythe_reroll_data_handler")

        inst.SaveForReroll = SaveForRerollWrapper(inst.SaveForReroll)
        inst.LoadForReroll = LoadForRerollWrapper(inst.LoadForReroll)
    end
end)
