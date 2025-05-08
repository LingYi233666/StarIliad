local BlytheMissileCounter = Class(function(self, inst)
    self.inst = inst

    -- Optional netvars:
    -- net_tinybyte            3-bit unsigned integer   [0..7]
    -- net_smallbyte           6-bit unsigned integer   [0..63]
    -- net_byte                8-bit unsigned integer   [0..255]

    self._num_missiles = net_byte(inst.GUID, "BlytheMissileCounter._num_missiles")
    self._max_num_missiles = net_byte(inst.GUID, "BlytheMissileCounter._max_num_missiles")

    self._num_super_missiles = net_byte(inst.GUID, "BlytheMissileCounter._num_super_missiles")
    self._max_num_super_missiles = net_byte(inst.GUID, "BlytheMissileCounter._max_num_super_missiles")
end)

---------------------------------------------------------

function BlytheMissileCounter:SetNumMissiles(val)
    self._num_missiles:set(val)
end

function BlytheMissileCounter:SetMaxNumMissiles(val)
    self._max_num_missiles:set(val)
end

function BlytheMissileCounter:GetNumMissiles()
    return self._num_missiles:value()
end

function BlytheMissileCounter:GetMaxNumMissiles()
    return self._max_num_missiles:value()
end

---------------------------------------------------------


function BlytheMissileCounter:SetNumSuperMissiles(val)
    self._num_super_missiles:set(val)
end

function BlytheMissileCounter:SetMaxNumSuperMissiles(val)
    self._max_num_super_missiles:set(val)
end

function BlytheMissileCounter:GetNumSuperMissiles()
    return self._num_super_missiles:value()
end

function BlytheMissileCounter:GetMaxNumSuperMissiles()
    return self._max_num_super_missiles:value()
end

return BlytheMissileCounter
