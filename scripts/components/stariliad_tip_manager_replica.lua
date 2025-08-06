local StarIliadTipManager = Class(function(self, inst)
    self.inst = inst

    -- self._key = net_string(inst.GUID, "StarIliadTipManager._key", "StarIliadTipManager._key")

    -- inst:ListenForEvent("StarIliadTipManager._key", function()
    --     if ThePlayer
    --         and ThePlayer == self.inst
    --         and ThePlayer.HUD
    --         and ThePlayer.HUD.controls
    --         and ThePlayer.HUD.controls.StarIliadTipUI then
    --         local str = self:GenerateString(self._key:value())
    --         if str then
    --             ThePlayer.HUD.controls.StarIliadTipUI:ShowTip(str, 10)
    --         end
    --         self._key:set_local("")
    --     end
    -- end)
end)

function StarIliadTipManager:GenerateString(key)
    local skiller = self.inst.replica.blythe_skiller
    if key == "CONFIGURE_POWERSUIT" then
        local key = skiller and skiller:GetSkillKey("configure_powersuit")
        local key_str = key and STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key] or STRINGS.STARILIAD_UI.TIPS.NOT_SET_KEY

        return string.format(STRINGS.STARILIAD_UI.TIPS.CONFIGURE_POWERSUIT, key_str)
    elseif key == "PARRY" then
        local key = skiller and skiller:GetSkillKey("parry")
        local key_str = key and STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key] or STRINGS.STARILIAD_UI.TIPS.NOT_SET_KEY

        return string.format(STRINGS.STARILIAD_UI.TIPS.PARRY, key_str)
    end
end

function StarIliadTipManager:Process(key, duration)
    if not (ThePlayer
            and ThePlayer == self.inst
            and ThePlayer.HUD
            and ThePlayer.HUD.controls
            and ThePlayer.HUD.controls.StarIliadTipUI) then
        return
    end

    local str = self:GenerateString(key)
    if str then
        ThePlayer.HUD.controls.StarIliadTipUI:ShowTip(str, duration)
    end
end

-- function StarIliadTipManager:ShowTip(str, duration)
--     ThePlayer.HUD.controls.StarIliadTipUI:ShowTip(str, duration)
-- end

return StarIliadTipManager
