local StarIliadOceanLandJump = Class(function(self, inst)
    self.inst = inst

    self._is_swimming = net_bool(inst.GUID, "StarIliadOceanLandJump._is_swimming", "swimming_dirty")

    inst:ListenForEvent("swimming_dirty", function()
        local vert_offset = 1
        -- local vert_offset = 0.2

        if self._is_swimming:value() then
            inst.DynamicShadow:Enable(false)
            inst.AnimState:SetFloatParams(0.45, 1.0, 0.5)
            -- inst.AnimState:SetFloatParams(0.15, 1.0, 0.5)


            if self.front_fx == nil then
                self.front_fx = inst:SpawnChild("float_fx_front")
                self.front_fx.Transform:SetPosition(0, vert_offset, 0)
                self.front_fx.AnimState:PlayAnimation("idle_front_med", true)
            end

            if self.back_fx == nil then
                self.back_fx = inst:SpawnChild("float_fx_back")
                self.back_fx.Transform:SetPosition(0, vert_offset, 0)
                self.back_fx.AnimState:PlayAnimation("idle_back_med", true)
            end

            if self.shadow_fx == nil then
                self.shadow_fx = inst:SpawnChild("float_fx_back")
                self.shadow_fx.Transform:SetPosition(0, 0.5, 0)
                self.shadow_fx.Transform:SetScale(0.6, 1.3, 0.6)

                -- self.shadow_fx.AnimState:SetLayer(LAYER_BACKGROUND)
                -- self.shadow_fx.AnimState:SetSortOrder(3)

                self.shadow_fx.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
                self.shadow_fx.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)

                self.shadow_fx.AnimState:PlayAnimation("idle_back_med", true)
                self.shadow_fx.AnimState:HideSymbol("back_water_large")
                self.shadow_fx.AnimState:HideSymbol("water_ripple_front")
            end
        else
            inst.DynamicShadow:Enable(true)
            inst.AnimState:SetFloatParams(0, 0, 0)

            if self.front_fx and self.front_fx:IsValid() then
                self.front_fx:Remove()
            end
            self.front_fx = nil

            if self.back_fx and self.back_fx:IsValid() then
                self.back_fx:Remove()
            end
            self.back_fx = nil

            if self.shadow_fx and self.shadow_fx:IsValid() then
                self.shadow_fx:Remove()
            end
            self.shadow_fx = nil
        end
    end)
end)

function StarIliadOceanLandJump:SetIsSwimming(val)
    self._is_swimming:set(val)
end

function StarIliadOceanLandJump:IsSwimming()
    return self._is_swimming:value()
end

return StarIliadOceanLandJump
