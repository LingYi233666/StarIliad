local StarIliadInteriorDoor = Class(function(self, inst)
    self.inst = inst

    self.style = nil
    self.direction = nil

    self.is_open = true

    self.destination = nil
end)

local OUT_OFFSETS = {
    north = Vector3(0, 0, -1),
    south = Vector3(0, 0, 1),
    west = Vector3(-1, 0, 0),
    east = Vector3(1, 0, 0),
}


function StarIliadInteriorDoor:GetOpenAnim()
    return self.material .. "_door_open_" .. self.direction
end

function StarIliadInteriorDoor:GetOpeningAnim()
    return self.material .. "_door_opening_" .. self.direction
end

function StarIliadInteriorDoor:GetCloseAnim()
    return self.material .. "_door_close_" .. self.direction
end

function StarIliadInteriorDoor:GetClosingAnim()
    return self.material .. "_door_closing_" .. self.direction
end

function StarIliadInteriorDoor:SetDestination(another_door, link_back, is_onload)
    self.destination = another_door

    if link_back == true or link_back == nil then
        another_door.components.stariliad_interior_door:SetDestination(self.inst, false)
    end
end

function StarIliadInteriorDoor:IsValidDestination(dest)
    return dest and dest:IsValid() and dest.components.stariliad_interior_door
end

function StarIliadInteriorDoor:Teleport(doer, instant)
    if not self:IsValidDestination(self.destination) then
        return
    end


    local offset = OUT_OFFSETS[self.destination.components.stariliad_interior_door.direction]

    doer.Transform:SetPosition((offset + self.destination:GetPosition()):Get())
    doer:ForceFacePoint((doer:GetPosition() + offset):Get())

    return true
end

function StarIliadInteriorDoor:OnSave()
    local data = {}
    local references = {}

    if self:IsValidDestination(self.destination) then
        data.destination = self.destination.GUID
        table.insert(references, self.destination.GUID)
    end

    return data, references
end

function StarIliadInteriorDoor:OnLoad(data)

end

function StarIliadInteriorDoor:LoadPostPass(newents, savedata)
    if savedata ~= nil then
        if savedata.destination ~= nil then
            local new_ent = newents[savedata.destination]
            if new_ent then
                self:SetDestination(new_ent, false, true)
            end
        end
    end
end

return StarIliadInteriorDoor
