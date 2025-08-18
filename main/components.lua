AddReplicableComponent("stariliad_pistol")
AddReplicableComponent("blythe_skiller")
AddReplicableComponent("blythe_powersuit_configure")
AddReplicableComponent("blythe_missile_counter")
AddReplicableComponent("stariliad_ocean_land_jump")
AddReplicableComponent("blythe_skill_parry")
AddReplicableComponent("blythe_skill_stealth")
AddReplicableComponent("blythe_skill_speed_burst")


AddReplicableComponent("stariliad_rain_fx_bonus_watcher")
AddReplicableComponent("stariliad_tip_manager")
--------------------------------------------------------------------
-- Damage number API

if TUNING.STARILIAD_DAMAGE_NUMBER_ENABLE then
    local SpDamageUtil = require("components/spdamageutil")
    AddComponentPostInit("combat", function(self)
        local function IsLunarWeapon(weapon)
            return weapon
                and weapon:IsValid()
                and weapon.components.damagetypebonus
                and weapon.components.damagetypebonus.tags
                and weapon.components.damagetypebonus.tags.shadow_aligned ~= nil
        end

        local function IsShadowWeapon(weapon)
            return weapon
                and weapon:IsValid()
                and weapon.components.damagetypebonus
                and weapon.components.damagetypebonus.tags
                and weapon.components.damagetypebonus.tags.lunar_aligned ~= nil
        end

        local function IsLunarCreature(attacker)
            return attacker
                and attacker:IsValid()
                and (attacker:HasTag("lunar_aligned") or attacker:HasTag("player_lunar_aligned"))
        end

        local function IsShadowCreature(attacker)
            return attacker
                and attacker:IsValid()
                and (attacker:HasTag("shadow_aligned") or attacker:HasTag("player_shadow_aligned"))
        end

        local function OnAttacked(inst, data)
            local x, y, z = inst.Transform:GetWorldPosition()
            local players_nearby = FindPlayersInRange(x, y, z, 40)
            if #players_nearby <= 0 then
                return
            end

            local damage = data.damage
            local spdamage = data.spdamage
            local weapon = data.weapon
            local attacker = data.attacker
            local stimuli = data.stimuli
            local damage_map = {}

            damage_map.GENERIC = data.damageresolved

            -- damage = damage - SpDamageUtil.CalcTotalDamage(spdamage)

            -- for k, v in pairs(STARILIAD_DAMAGE_NUMBER_COLOURS) do
            --     damage_map[k] = 0
            -- end
            -- -- damage_map.GENERIC = damage

            -- if stimuli == "electric" then
            --     damage_map.LIGHTNING = damage
            -- else
            --     damage_map.GENERIC = damage
            -- end

            -- for damage_type, value in pairs(spdamage or {}) do
            --     if damage_type == "planar" then
            --         if IsLunarWeapon(weapon) then
            --             damage_map.PLANAR_LUNAR = damage_map.PLANAR_LUNAR + value
            --         elseif IsShadowWeapon(weapon) then
            --             damage_map.PLANAR_SHADOW = damage_map.PLANAR_SHADOW + value
            --         elseif IsLunarCreature(attacker) then
            --             damage_map.PLANAR_LUNAR = damage_map.PLANAR_LUNAR + value
            --         elseif IsShadowCreature(attacker) then
            --             damage_map.PLANAR_SHADOW = damage_map.PLANAR_SHADOW + value
            --         else
            --             damage_map.PLANAR_GENERIC = damage_map.PLANAR_GENERIC + value
            --         end
            --     elseif damage_type == "stariliad_spdamage_beam" then
            --         damage_map.FORCE = damage_map.FORCE + value
            --     else
            --         damage_map.GENERIC = damage_map.GENERIC + value
            --     end
            -- end


            local params_pre = {}
            local params = {}
            for k, v in pairs(damage_map) do
                if v > 0.1 then
                    -- table.insert(params, k)
                    -- table.insert(params, v)
                    table.insert(params_pre, { k, v })
                end
            end

            params_pre = shuffleArray(params_pre)

            for _, company in pairs(params_pre) do
                table.insert(params, company[1])
                table.insert(params, company[2])
            end

            for _, v in pairs(players_nearby) do
                SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["show_damage_number"], v.userid, x, y, z,
                    unpack(params))
            end
        end

        self.inst:ListenForEvent("attacked", OnAttacked)

        local old_OnRemoveFromEntity = self.OnRemoveFromEntity
        self.OnRemoveFromEntity = function(self, ...)
            self.inst:RemoveEventCallback("attacked", OnAttacked)

            if old_OnRemoveFromEntity ~= nil then
                return old_OnRemoveFromEntity(self, ...)
            end
        end
    end)

    AddComponentPostInit("health", function(self)
        local function OnHealthDelta(inst, data)
            if not (data and data.amount and data.amount > 0) then
                return
            end

            local x, y, z = inst.Transform:GetWorldPosition()
            local players_nearby = FindPlayersInRange(x, y, z, 40)
            if #players_nearby <= 0 then
                return
            end

            for _, v in pairs(players_nearby) do
                SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["show_damage_number"], v.userid, x, y, z,
                    "HEAL", data.amount)
            end
        end
        self.inst:ListenForEvent("healthdelta", OnHealthDelta)

        local old_OnRemoveFromEntity = self.OnRemoveFromEntity
        self.OnRemoveFromEntity = function(self, ...)
            self.inst:ListenForEvent("healthdelta", OnHealthDelta)

            if old_OnRemoveFromEntity ~= nil then
                return old_OnRemoveFromEntity(self, ...)
            end
        end
    end)
end
--------------------------------------------------------------------

AddComponentPostInit("playercontroller", function(self)
    self.stariliad_shoot_buffer = nil

    self.RemoteRectifyStarIliadShootAction = function(self, x, y, z, target)
        if not self.ismastersim then
            if self.inst.sg and self.inst.sg:HasStateTag("stariliad_shoot") then
                if x and y and z then
                    self.inst:ForceFacePoint(Vector3(x, y, z))
                end
            end

            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["rectify_shoot_buffaction"], x, y, z, target)
        end
    end

    self.OnRemoteRectifyStarIliadShootAction = function(self, x, y, z, target)
        if self.ismastersim then
            if self.inst.sg and self.inst.sg:HasStateTag("stariliad_shoot") and self.inst.sg.statemem.action then
                if x and y and z then
                    local new_pos = Vector3(x, y, z)
                    self.inst.sg.statemem.action:SetActionPoint(new_pos)
                    self.inst:ForceFacePoint(new_pos)
                else
                    self.inst.sg.statemem.action.pos = nil
                end
                self.inst.sg.statemem.action.target = target
            end
        end
    end

    -- local old_OnRightClick = self.OnRightClick
    -- self.OnRightClick = function(self, down, ...)
    --     local old_res = old_OnRightClick(self, down, ...)
    --     if down then
    --         local act = self:GetRightMouseAction()
    --         self.stariliad_shoot_buffer = act
    --     end
    --     return old_res
    -- end

    local old_OnUpdate = self.OnUpdate
    self.OnUpdate = function(self, dt, ...)
        local old_res = old_OnUpdate(self, dt, ...)

        local isenabled, ishudblocking = self:IsEnabled()
        if isenabled and not ishudblocking then
            if self:IsControlPressed(CONTROL_SECONDARY) then
                local act = self.stariliad_shoot_buffer
                if act == nil or not act:IsValid() then
                    act = self:GetRightMouseAction()
                end
                if act and act.action == ACTIONS.STARILIAD_SHOOT_AT then
                    local x, y, z
                    local pt = act:GetActionPoint()
                    if pt then
                        x, y, z = pt:Get()
                    end

                    if self.ismastersim then
                        self:OnRemoteRectifyStarIliadShootAction(x, y, z, act.target)
                    else
                        self:RemoteRectifyStarIliadShootAction(x, y, z, act.target)
                    end
                    self:OnRightClick(true)
                end
                self.stariliad_shoot_buffer = nil
            end


            -- if self:IsControlPressed(CONTROL_PRIMARY) and self:IsAOETargeting() then
            --     local item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            --     if item and item:HasTag("stariliad_chain_castaoe") then
            --         self:OnLeftClick(true)
            --     end
            -- end

            -- if self:IsControlPressed(CONTROL_SECONDARY) then
            --     -- local item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            --     -- if item and item.prefab == "blythe_blaster" then
            --     -- local data = item.replica.stariliad_pistol:GetProjectileData()

            --     -- if data and data.prefab == "blythe_ice_fog" then
            --     --     self:OnRightClick(true)
            --     -- else
            --     --     local attack_tag = self.remote_authority and self.remote_predicting and "abouttoattack" or
            --     --         "attack"

            --     --     if not (self.inst.sg and self.inst.sg:HasStateTag(attack_tag)) then
            --     --         self:OnRightClick(true)
            --     --     end
            --     -- end

            --     -- self:OnRightClick(true)

            --     --
            --     -- end
            -- end
        end
        return old_res
    end
end)

local STARILIAD_MUSIC = {
    stariliad_boss_gorgoroth = {
        "",
        "stariliad_music/music/spire_boss_1_mind",
    },
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

    for k, v in pairs(STARILIAD_MUSIC) do
        TRIGGERED_DANGER_MUSIC[k] = v
    end

    print("Modify success !")
end)
