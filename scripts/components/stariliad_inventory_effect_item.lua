local StarIliadInventoryEffectItem = Class(function(self, inst)
    self.inst = inst


    self.trace_owner = nil

    self.targetvalidfn = nil
    self.onactivatefn = nil
    self.ondeactivatefn = nil

    inst:ListenForEvent("onputininventory", function()
        self:Check()
    end)

    inst:ListenForEvent("onownerputininventory", function()
        self:Check()
    end)

    inst:ListenForEvent("ondropped", function()
        self:Check()
    end)

    inst:ListenForEvent("onownerdropped", function()
        self:Check()
    end)

    inst:ListenForEvent("stacksizechange", function()
        self:Check()
    end)

    inst:ListenForEvent("onremove", function()
        self:Deactivate()
    end)
end)

function StarIliadInventoryEffectItem:SetTargetValidFn(fn)
    self.targetvalidfn = fn
end

function StarIliadInventoryEffectItem:SetOnActivateFn(fn)
    self.onactivatefn = fn
end

function StarIliadInventoryEffectItem:SetOnDeactivateFn(fn)
    self.ondeactivatefn = fn
end

function StarIliadInventoryEffectItem:GetOwner()
    return self.trace_owner
end

function StarIliadInventoryEffectItem:Activate(owner)
    self.trace_owner = owner

    if self.onactivatefn then
        self.onactivatefn(self.inst, owner)
    end

    print(self.inst, "New owner get:", owner)
end

function StarIliadInventoryEffectItem:Deactivate()
    if self.trace_owner == nil then
        return
    end

    if self.ondeactivatefn then
        self.ondeactivatefn(self.inst, self.trace_owner)
    end

    print(self.inst, "Abandon owner:", self.trace_owner)


    self.trace_owner = nil
end

function StarIliadInventoryEffectItem:IsTargetValid(target)
    return target and target:IsValid() and (self.targetvalidfn == nil or self.targetvalidfn(self.inst, target))
end

function StarIliadInventoryEffectItem:Check()
    -- Check if old owner is valid
    if not self:IsTargetValid(self.trace_owner) then
        self:Deactivate()
    end

    -- Try find new owner
    local newowner = self.inst.components.inventoryitem.owner
    if newowner == self.trace_owner then
        return
    end

    -- New owner is not equal to old owner, abandon old onwer
    self:Deactivate()

    if self:IsTargetValid(newowner) then
        self:Activate(newowner)
    end
end

return StarIliadInventoryEffectItem
