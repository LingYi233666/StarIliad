local BlytheRerollDataHandler = Class(function(self, inst)
    self.inst = inst

    self.memory = nil
    self:ResetMemory()
end)

function BlytheRerollDataHandler:ResetMemory()
    self.memory = {
        components = {},
    }
end

function BlytheRerollDataHandler:UpdateMemory()
    self:ResetMemory()
    for name, cmp in pairs(self.inst.components) do
        if cmp.use_blythe_reroll_data_handler == true then
            if cmp.SaveForReroll then
                self.memory.components[name] = cmp:SaveForReroll()
            elseif cmp.OnSave then
                self.memory.components[name] = cmp:OnSave()
            else
                print(self.inst, name, "doesn't have any save function for reroll !")
            end
        end
    end
end

function BlytheRerollDataHandler:ApplyMemory()
    for name, saved_data in pairs(self.memory.components) do
        local cmp = self.inst.components[name]
        if cmp then
            if cmp.LoadForReroll then
                cmp:LoadForReroll(saved_data)
            elseif cmp.OnLoad then
                cmp:OnLoad(saved_data)
            else
                print(self.inst, name, "doesn't have any load function for reroll !")
            end
        end
    end

    self:ResetMemory()
end

function BlytheRerollDataHandler:OnSave()
    return {
        memory = self.memory,
    }
end

function BlytheRerollDataHandler:OnLoad(data)
    if data.memory ~= nil then
        self.memory = data.memory
    end
end

return BlytheRerollDataHandler
