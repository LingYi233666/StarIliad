local StarIliadTipManager = Class(function(self, inst)
    self.inst = inst

    self.queue = {}

    self.triggered_tips = {
        -- configure_powersuit = false,
        -- parry               = false,
        -- new_ammo            = false,
        -- new_switch_passive  = false,
    }

    self.use_blythe_reroll_data_handler = true

    self.inst:DoTaskInTime(0.1, function()
        self:InitListeners()
    end)
end)

function StarIliadTipManager:InitListeners()
    self.inst:ListenForEvent("equip", function(_, data)
        if not TUNING.STARILIAD_TIP_ENABLE then
            return
        end

        if not self.triggered_tips.configure_powersuit
            and data.item
            and data.item:IsValid()
            and data.item.prefab == "blythe_blaster" then
            self:ShowTip("CONFIGURE_POWERSUIT")
            self.triggered_tips.configure_powersuit = true
        end
    end)

    self.inst:ListenForEvent("attacked", function(_, data)
        if not TUNING.STARILIAD_TIP_ENABLE then
            return
        end

        if not self.triggered_tips.parry then
            self:ShowTip("PARRY")
            self.triggered_tips.parry = true
        end
    end)

    local new_ammon_skill = {
        "wide_beam",
        "wave_beam",
        "plasma_beam",
        "usurper_shot",
        "missile",
        "super_missile",
    }
    local new_switch_passive_skill = {
        "speed_burst",
        -- "gravity_control",
    }
    self.inst:ListenForEvent("blythe_skill_learned", function(_, data)
        if not TUNING.STARILIAD_TIP_ENABLE then
            return
        end

        if data.is_onload then
            return
        end

        if table.contains(new_ammon_skill, data.name) and not self.triggered_tips.new_ammo then
            self:ShowTip("CONFIGURE_POWERSUIT")
            self.triggered_tips.new_ammo = true
        end

        if table.contains(new_switch_passive_skill, data.name) and not self.triggered_tips.new_switch_passive then
            self:ShowTip("CONFIGURE_POWERSUIT")
            self.triggered_tips.new_switch_passive = true
        end
    end)
end

function StarIliadTipManager:ShowTip(key, duration)
    SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["show_tip"], self.inst.userid, key, duration or 10)
end

function StarIliadTipManager:OnSave()
    -- return {
    --     triggered_tips = self.triggered_tips
    -- }

    local data = { triggered_tips = {} }

    for k, v in pairs(self.triggered_tips) do
        if v then
            table.insert(data.triggered_tips, k)
        end
    end

    return data
end

function StarIliadTipManager:OnLoad(data)
    if data ~= nil then
        if data.triggered_tips ~= nil then
            -- self.triggered_tips = data.triggered_tips
            for k, v in pairs(data.triggered_tips) do
                self.triggered_tips[v] = true
            end
        end
    end
end

return StarIliadTipManager
