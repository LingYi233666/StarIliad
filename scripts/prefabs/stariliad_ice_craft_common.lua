local StarIliadIceCraftCommon = {}

function StarIliadIceCraftCommon.AddPerishable(inst, perish_time, fire_melt, perish_to_water_anim)
    ------------------------------------------------

    inst:AddTag("frozen")
    inst:AddTag("show_spoilage")
    inst:AddTag("icebox_valid")

    ------------------------------------------------

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(perish_time or TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()

    if fire_melt ~= false then
        inst:ListenForEvent("firemelt", function()
            inst.components.perishable.frozenfiremult = true
        end)

        inst:ListenForEvent("stopfiremelt", function()
            inst.components.perishable.frozenfiremult = false
        end)
    end

    if perish_to_water_anim ~= false then
        inst:ListenForEvent("perished", function()
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
            local stacksize = inst.components.stackable and inst.components.stackable:StackSize() or 1

            if owner ~= nil then
                if owner.components.moisture ~= nil then
                    owner.components.moisture:DoDelta(2 * stacksize)
                elseif owner.components.inventoryitem ~= nil then
                    owner.components.inventoryitem:AddMoisture(4 * stacksize)
                end
                inst:Remove()
            else
                local x, y, z = inst.Transform:GetWorldPosition()
                TheWorld.components.farming_manager:AddSoilMoistureAtPoint(x, y, z,
                    stacksize * TUNING.ICE_MELT_GROUND_MOISTURE_AMOUNT)

                inst.persists = false

                if inst.components.inventoryitem then
                    inst.components.inventoryitem.canbepickedup = false
                end

                if perish_to_water_anim == nil then
                    inst:Remove()
                else
                    inst.AnimState:PlayAnimation(perish_to_water_anim)
                    inst:ListenForEvent("animover", inst.Remove)
                end
            end
        end)
    end
end

function StarIliadIceCraftCommon.AddHeater(inst, equippedheat)
    inst:AddComponent("heater")
    inst.components.heater:SetThermics(false, true)
    inst.components.heater.equippedheat = equippedheat or 40
end

return StarIliadIceCraftCommon
