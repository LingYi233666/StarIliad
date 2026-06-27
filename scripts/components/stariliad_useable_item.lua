local function onuse_action_meter(self, use_action_meter)
    if use_action_meter then
        self.inst:AddTag("stariliad_useable_item_action_meter")
    else
        self.inst:RemoveTag("stariliad_useable_item_action_meter")
    end
end

local StarIliadUseableItem = Class(function(self, inst)
    self.inst = inst

    self.on_use_fn = nil
    self.max_remove_size = 1
    self.action_duration = 1
    self.use_action_meter = false
end, nil, {
    use_action_meter = onuse_action_meter,
})

function StarIliadUseableItem:SetMaxRemoveSize(size)
    self.max_remove_size = size
end

function StarIliadUseableItem:SetActionDuration(duration)
    self.action_duration = duration
end

function StarIliadUseableItem:SetOnUseFn(fn)
    self.on_use_fn = fn
end

function StarIliadUseableItem:SetUseActionMeter(use_action_meter)
    self.use_action_meter = use_action_meter
end

function StarIliadUseableItem:GetActionDuration()
    return self.action_duration
end

-- function StarIliadUseableItem:RemoveOnce()
--     if not self.inst.components.stackable then
--         self.inst:Remove()
--         return
--     end

--     local stacksize = self.inst.components.stackable:StackSize()
--     if stacksize <= self.max_remove_size then
--         self.inst:Remove()
--         return
--     end

--     self.inst.components.stackable:SetStackSize(stacksize - self.max_remove_size)
-- end

function StarIliadUseableItem:Use(user)
    local num_to_remove
    if self.inst.components.stackable then
        num_to_remove = math.min(self.inst.components.stackable:StackSize(), self.max_remove_size)
    else
        num_to_remove = 1
    end

    if self.on_use_fn then
        if not self.on_use_fn(self.inst, user, num_to_remove) then
            return false
        end
    end

    if self.inst.components.stackable then
        local stacksize = self.inst.components.stackable:StackSize()
        if stacksize <= self.max_remove_size then
            self.inst:Remove()
        else
            self.inst.components.stackable:SetStackSize(stacksize - self.max_remove_size)
        end
    else
        self.inst:Remove()
    end

    return true
end

return StarIliadUseableItem
