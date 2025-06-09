local function onnum_missiles(self, val)
    self.inst.replica.blythe_missile_counter:SetNumMissiles(math.floor(val))
end

local function onmax_num_missiles(self, val)
    self.inst.replica.blythe_missile_counter:SetMaxNumMissiles(math.floor(val))
end

local function onnum_super_missiles(self, val)
    self.inst.replica.blythe_missile_counter:SetNumSuperMissiles(math.floor(val))
end

local function onmax_num_super_missiles(self, val)
    self.inst.replica.blythe_missile_counter:SetMaxNumSuperMissiles(math.floor(val))
end

local BlytheMissileCounter = Class(function(self, inst)
    self.inst = inst

    self.max_num_missiles = 10
    self.num_missiles = self.max_num_missiles

    self.max_num_super_missiles = 5
    self.num_super_missiles = self.max_num_super_missiles

    self.inst:StartUpdatingComponent(self)
end, nil, {
    num_missiles = onnum_missiles,
    max_num_missiles = onmax_num_missiles,
    num_super_missiles = onnum_super_missiles,
    max_num_super_missiles = onmax_num_super_missiles,
})

function BlytheMissileCounter:SetNumMissiles(val, on_load)
    self.num_missiles = math.clamp(val, 0, self.max_num_missiles)
end

function BlytheMissileCounter:DoDeltaNumMissiles(delta)
    self:SetNumMissiles(self.num_missiles + delta)
end

function BlytheMissileCounter:SetMaxNumMissiles(val, on_load)
    self.max_num_missiles = math.max(0, val)
end

function BlytheMissileCounter:GetNumMissiles()
    return self.num_missiles
end

function BlytheMissileCounter:GetMaxNumMissiles()
    return self.max_num_missiles
end

-----------------------------------------------------------------

function BlytheMissileCounter:SetNumSuperMissiles(val, on_load)
    self.num_super_missiles = math.clamp(val, 0, self.max_num_super_missiles)
end

function BlytheMissileCounter:DoDeltaNumSuperMissiles(delta)
    self:SetNumSuperMissiles(self.num_super_missiles + delta)
end

function BlytheMissileCounter:SetMaxNumSuperMissiles(val, on_load)
    self.max_num_super_missiles = math.max(0, val)
end

function BlytheMissileCounter:GetNumSuperMissiles()
    return self.num_super_missiles
end

function BlytheMissileCounter:GetMaxNumSuperMissiles()
    return self.max_num_super_missiles
end

-----------------------------------------------------------------

function BlytheMissileCounter:OnSave()
    return {
        num_missiles = self.num_missiles,
        max_num_missiles = self.max_num_missiles,
        num_super_missiles = self.num_super_missiles,
        max_num_super_missiles = self.max_num_super_missiles,
    }
end

function BlytheMissileCounter:OnLoad(data)
    if data ~= nil then
        if data.max_num_missiles ~= nil then
            self:SetMaxNumMissiles(data.max_num_missiles, true)
        end
        if data.num_missiles ~= nil then
            self:SetNumMissiles(data.num_missiles, true)
        end

        if data.max_num_super_missiles ~= nil then
            self:SetMaxNumSuperMissiles(data.max_num_super_missiles, true)
        end
        if data.num_super_missiles ~= nil then
            self:SetNumSuperMissiles(data.num_super_missiles, true)
        end
    end
end

function BlytheMissileCounter:OnUpdate(dt)
    self:DoDeltaNumMissiles(dt / 10)
    self:DoDeltaNumSuperMissiles(dt / 15)
end

return BlytheMissileCounter
