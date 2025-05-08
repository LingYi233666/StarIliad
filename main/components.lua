AddReplicableComponent("stariliad_pistol")
AddReplicableComponent("blythe_skiller")
AddReplicableComponent("blythe_powersuit_configure")
AddReplicableComponent("blythe_missile_counter")

AddComponentPostInit("playercontroller", function(self)
    local old_OnUpdate = self.OnUpdate
    self.OnUpdate = function(self, dt, ...)
        local old_res = old_OnUpdate(self, dt, ...)

        local isenabled, ishudblocking = self:IsEnabled()
        if isenabled and not ishudblocking then
            if self:IsControlPressed(CONTROL_PRIMARY) and self:IsAOETargeting() then
                local item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if item and item:HasTag("stariliad_chain_castaoe") then
                    self:OnLeftClick(true)
                end
            end

            -- if self:IsControlPressed(CONTROL_ATTACK) then
            --     local item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            --     if item and item.prefab == "blythe_blaster" then
            --         self.attack_buffer = CONTROL_ATTACK
            --     end
            -- end
        end
        return old_res
    end
end)
