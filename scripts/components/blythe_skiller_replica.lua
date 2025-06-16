require "json"

local BlytheSkiller = Class(function(self, inst)
    self.inst = inst

    self.learned_skill = {}
    self.enabled_skill = {}

    self.input_handler = {
        -- [KEY_Z] = nil,
        -- [KEY_X] = nil,
        -- [KEY_C] = nil,
        -- [KEY_V] = nil,
    }

    self.json_data = net_string(inst.GUID, "BlytheSkiller.json_data", "blythe_skiller_json_data_dirty")

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(1, function()
            if self.inst == ThePlayer then
                self:LoadFromFile()
                self:PrintInputHandler()
            end
        end)

        inst:ListenForEvent("blythe_skiller_json_data_dirty", function()
            if self.inst == ThePlayer then
                self:UpdateByServer()
            end
        end)
    end
end)

function BlytheSkiller:SetJsonData(val)
    self.json_data:set(val)
end

function BlytheSkiller:LoadFromFile()
    TheSim:GetPersistentString("mod_config_data/blythe_skiller_input_handler", function(success, encoded_data)
        if success then
            local save_data = json.decode(encoded_data)
            for k, v in pairs(save_data) do
                self:SetInputHandler(v[1], v[2])
            end

            self.inst:PushEvent("blythe_skiller_ui_update")

            print("Replica blythe_skiller load key config success !")
        else
            print("Replica blythe_skiller input_handler load failed !!!")
        end
    end)
end

function BlytheSkiller:SaveToFile()
    -- print("Current key settings:")
    local tab = {}
    for k, v in pairs(self.input_handler) do
        table.insert(tab, { k, v })
        -- print(string.format("%s:%s", STRINGS.UI.CONTROLSSCREEN.INPUTS[1][k], v))
    end
    TheSim:SetPersistentString("mod_config_data/blythe_skiller_input_handler", json.encode(tab), true)
end

function BlytheSkiller:UpdateByServer()
    local tab = json.decode(self.json_data:value())
    self.learned_skill = tab.learned_skill or {}
    self.enabled_skill = tab.enabled_skill or {}

    -- update galke skill ui (in menu screen) here
    self.inst:PushEvent("blythe_skiller_ui_update")
end

function BlytheSkiller:PrintInputHandler()
    print("BlytheSkiller Current input_handler is:")
    for k, v in pairs(self.input_handler) do
        print(string.format("%s:%s", STRINGS.UI.CONTROLSSCREEN.INPUTS[1][k], v))
    end
end

-- function BlytheSkiller:SetRootInputHandler()
--     for _, v in pairs(BLYTHE_SKILL_DEFINES) do
--         if v.root
--             and self:IsLearned(v.name)
--             and StarIliadBasic.IsCastByButton(v.name)
--             and v.default_key
--             and not self:KeyHasBeenUsed(v.default_key)
--             and not self:SkillHasBeenKeyed(v.name) then
--             self:SetInputHandler(v.default_key, v.name, true)
--         end
--     end
-- end

function BlytheSkiller:SetInputHandler(key, name, save_to_file)
    if name ~= nil and not self:IsLearned(name) then
        return
    end

    self:RemoveInputHandler(name)

    self.input_handler[key] = name

    if name ~= nil then
        print(string.format("BlytheSkiller replica setting %s to %s", name, STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key]))
    else
        -- print(string.format("BlytheSkiller replica clear key %s",STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key]))
    end

    -- self.inst:PushEvent("blythe_skiller_ui_update")

    if save_to_file then
        self:SaveToFile()
    end
end

function BlytheSkiller:RemoveInputHandler(name, save_to_file)
    for k, v in pairs(self.input_handler) do
        if v == name then
            self.input_handler[k] = nil
            print(string.format("BlytheSkiller replica clean old setting:%s,%s", name,
                STRINGS.UI.CONTROLSSCREEN.INPUTS[1][k]))
            break
        end
    end

    if save_to_file then
        self:SaveToFile()
    end
end

function BlytheSkiller:KeyHasBeenUsed(key)
    return self.input_handler[key] ~= nil
end

function BlytheSkiller:SkillHasBeenKeyed(name)
    for k, v in pairs(self.input_handler) do
        if v == name then
            return true
        end
    end

    return false
end

function BlytheSkiller:GetSkillKey(name)
    for k, v in pairs(self.input_handler) do
        if v == name then
            return k
        end
    end
end

function BlytheSkiller:IsLearned(name)
    return name and self.learned_skill[name] == true
end

function BlytheSkiller:IsEnabled(name)
    return name and self.enabled_skill[name] == true
end

function BlytheSkiller:GetLearnedSkill()
    local ret = {}
    for name, v in pairs(self.learned_skill) do
        if v == true then
            table.insert(ret, name)
        end
    end

    return ret
end

function BlytheSkiller:GetEnabledSkill()
    local ret = {}
    for name, v in pairs(self.enabled_skill) do
        if v == true then
            table.insert(ret, name)
        end
    end

    return ret
end

function BlytheSkiller:GetDebugString()
    local s = "Learned skill:"
    for name, bool in pairs(self.learned_skill) do
        if bool then
            s = s .. name .. ","
        end
    end

    s = s .. " Enabled skill:"
    for name, bool in pairs(self.enabled_skill) do
        if bool then
            s = s .. name .. ","
        end
    end

    return s
end

return BlytheSkiller
