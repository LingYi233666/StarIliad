AddReplicableComponent("stariliad_pistol")
AddReplicableComponent("blythe_skiller")
AddReplicableComponent("blythe_powersuit_configure")
AddReplicableComponent("blythe_missile_counter")
AddReplicableComponent("stariliad_ocean_land_jump")

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

local STARILIAD_MUSIC = {

}

AddComponentPostInit("dynamicmusic", function(self)
    print("Adding stariliad music !")

    local function IsMusicTable(cur_name, cur_value, parent, cur_depth)
        if type(parent) ~= "function" then
            return false
        end

        local fninfo = debug.getinfo(parent)

        return fninfo.source and fninfo.source:match("components/dynamicmusic") and type(cur_value) == "table"
    end

    local listener_fns = StarIliadUpvalue.GetListenFns(self.inst, "playeractivated")
    if not listener_fns then
        print("listener_fns nil, hack failed!")
        return
    end

    local OnPlayerActivated = nil
    for _, v in pairs(listener_fns) do
        local fninfo = debug.getinfo(v)
        if fninfo.source and fninfo.source:match("components/dynamicmusic") then
            OnPlayerActivated = v
            break
        end
    end

    if not OnPlayerActivated then
        print("OnPlayerActivated is nil, hack failed!")
        return
    end

    -- local TRIGGERED_DANGER_MUSIC = StarIliadUpvalue.Get(OnPlayerActivated, "StartPlayerListeners",
    --     "StartTriggeredDanger", "TRIGGERED_DANGER_MUSIC")

    local TRIGGERED_DANGER_MUSIC = StarIliadUpvalue.GetRecursion(OnPlayerActivated, "TRIGGERED_DANGER_MUSIC", nil,
        IsMusicTable)

    if not TRIGGERED_DANGER_MUSIC then
        print("TRIGGERED_DANGER_MUSIC is nil, hack failed!")
        return
    end
    -- print("After modify, TRIGGERED_DANGER_MUSIC is:")
    -- dumptable(TRIGGERED_DANGER_MUSIC)

    print("Modify success !")
end)
