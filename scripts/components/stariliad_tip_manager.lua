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

    inst:ListenForEvent("equip", function(_, data)
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

    inst:ListenForEvent("attacked", function(_, data)
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
    inst:ListenForEvent("blythe_skill_learned", function(_, data)
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
end)

function StarIliadTipManager:ShowTip(key, duration)
    SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["show_tip"], self.inst.userid, key, duration or 5)
end

function StarIliadTipManager:OnSave()
    return {
        triggered_tips = self.triggered_tips
    }
end

function StarIliadTipManager:OnLoad(data)
    if data ~= nil then
        if data.triggered_tips ~= nil then
            self.triggered_tips = data.triggered_tips
        end
    end
end

return StarIliadTipManager
