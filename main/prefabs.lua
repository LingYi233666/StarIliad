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

-- AddPrefabPostInit("minotaur", function(inst)
--     if not TheWorld.ismastersim then
--         return
--     end

--     if not inst.components.lootdropper then
--         inst:AddComponent("lootdropper")
--     end
--     inst.components.lootdropper:AddChanceLoot("blythe_unlock_skill_item_speed_burst", 1.0)
-- end)

-- AddPrefabPostInit("daywalker", function(inst)
--     if not TheWorld.ismastersim then
--         return
--     end

--     inst:ListenForEvent("minhealth", function()
--         if inst.defeated then
--             if inst.components.lootdropper then
--                 inst.components.lootdropper:SpawnLootPrefab("blythe_unlock_skill_item_wave_beam")
--                 inst.dropped_ball = true
--             end
--         end
--     end)
-- end)

-- AddPrefabPostInit("daywalker2", function(inst)
--     if not TheWorld.ismastersim then
--         return
--     end

--     inst:ListenForEvent("minhealth", function()
--         if inst.defeated then
--             if inst.components.lootdropper then
--                 inst.components.lootdropper:SpawnLootPrefab("blythe_unlock_skill_item_wave_beam")
--             end
--         end
--     end)
-- end)

AddPrefabPostInit("forest", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("stariliad_weather_lightning_storm")

    inst:AddComponent("stariliad_weather_falling_star")
end)

AddPrefabPostInit("tallbirdnest", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local function AddStariliadMissile(inst)
        if not inst.components.pickable then
            return
        end

        if inst.components.pickable.canbepicked then
            inst.components.pickable:MakeEmpty()
        end

        inst.components.pickable:ChangeProduct("blythe_unlock_skill_item_missile")
        inst.components.pickable:Regen()
    end

    -- c_spawn("tallbirdnest"):AddStariliadMissile()
    inst.AddStariliadMissile = AddStariliadMissile

    local old_onpickedfn = inst.components.pickable.onpickedfn
    inst.components.pickable.onpickedfn = function(inst, picker, ...)
        local ret = { old_onpickedfn(inst, picker, ...) }

        if inst.components.pickable.product == "blythe_unlock_skill_item_missile" then
            inst.components.pickable:ChangeProduct("tallbirdegg")
            inst.AnimState:ClearOverrideSymbol("egg01")
        end

        return unpack(ret)
    end

    local old_onregenfn = inst.components.pickable.onregenfn
    inst.components.pickable.onregenfn = function(inst, ...)
        local ret = { old_onregenfn(inst, ...) }

        if inst.components.pickable.product == "blythe_unlock_skill_item_missile" then
            inst.AnimState:OverrideSymbol("egg01", "blythe_missile_tank", "normal_in_nest")
        end

        return unpack(ret)
    end

    local old_OnSave = inst.OnSave

    inst.OnSave = function(inst, data, ...)
        old_OnSave(inst, data, ...)

        if inst.components.pickable.product == "blythe_unlock_skill_item_missile" then
            data.is_stariliad_missile = true
        end
    end

    local old_OnLoad = inst.OnLoad

    inst.OnLoad = function(inst, data, ...)
        old_OnLoad(inst, data, ...)

        if data ~= nil and data.is_stariliad_missile == true then
            AddStariliadMissile(inst)
        end
    end

    local old_onspawned = inst.components.childspawner.onspawned
    inst.components.childspawner:SetSpawnedFn(function(inst, ...)
        if inst.components.pickable.product == "blythe_unlock_skill_item_missile" then
            return
        end

        return old_onspawned(inst, ...)
    end)
end)

AddPrefabPostInit("gears", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if not inst.components.tradable then
        inst:AddComponent("tradable")
    end
end)

AddPrefabPostInit("pigking", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local function launchitem(item, angle)
        local speed = math.random() * 4 + 2
        angle = (angle + math.random() * 60 - 30) * DEGREES
        item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
    end

    local old_fn = inst.components.trader.onaccept

    local function OnGetItemFromPlayer(inst, giver, item, ...)
        old_fn(inst, giver, item, ...)
        if item.components.tradable.goldvalue > 0
            and inst.sg.currentstate.name == "cointoss" then
            inst:DoTaskInTime(2 / 3, function()
                if giver
                    and giver:IsValid()
                    and giver.components.blythe_skiller
                    and not giver.components.blythe_skiller:IsLearned("wide_beam")
                then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local angle = 180 - giver:GetAngleToPoint(x, 0, z)
                    local item = SpawnAt("blythe_unlock_skill_item_wide_beam", inst, nil, { 0, 4.5, 0 })
                    launchitem(item, angle)
                end
            end)
        end
    end

    inst.components.trader.onaccept = OnGetItemFromPlayer
end)

AddPrefabPostInitAny(function(inst)
    if not TheNet:IsDedicated() then
        if inst.components.pointofinterest or inst:HasTag("epic") then
            inst:AddComponent("stariliad_important_scan_target")
        end

        if inst.components.pointofinterest then
            local h = inst.components.pointofinterest.height or 200

            inst.components.stariliad_important_scan_target:SetMarkerHeight(h)
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
