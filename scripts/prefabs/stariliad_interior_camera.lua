-- -- self.gale_interior_pitch = 35
-- self.gale_interior_heading = 0
-- -- self.gale_interior_distance = 20
-- self.gale_interior_distance = 21.5
-- self.gale_interior_currentpos = Vector3(0, 0, 0)
-- -- self.gale_interior_fov = 35
-- self.gale_interior_camera_enabled = false
-- self.gale_interior_targetoffset = Vector3(2, 1.5, 0)


local function CameraUpdate(inst, player)
    local player_pos = player:GetPosition()
    local my_pos = inst:GetPosition()
    local limited_offset = player_pos - my_pos

    if math.abs(limited_offset.x) >= inst._limit_range_x:value() then
        limited_offset.x = (limited_offset.x > 0) and inst._limit_range_x:value() or (-inst._limit_range_x:value())
    end

    if math.abs(limited_offset.z) >= inst._limit_range_z:value() then
        limited_offset.z = (limited_offset.z > 0) and inst._limit_range_z:value() or (-inst._limit_range_z:value())
    end

    local camera_pos_offset = my_pos + limited_offset - player_pos
    camera_pos_offset.y = 1.5

    TheCamera:SetDistance(inst._camera_distance:value())
    TheCamera:SetHeadingTarget(-90)
    TheCamera:SetOffset(camera_pos_offset)
end

local camera_settings = {
    ActiveFn = function(best_focus, player, best_dist_sq)
        -- local player_pos = ThePlayer:GetPosition()
        -- local my_pos = parent:GetPosition()
        -- local delta_pos = player_pos - my_pos

        CameraUpdate(best_focus.target, player)
        TheCamera:Snap()

        -- print("active fn:", best_focus.target, player)
    end,

    UpdateFn = function(dt, best_focus, player, best_dist_sq)
        CameraUpdate(best_focus.target, player)
    end,
}


local function TryAffectPlayer(inst)
    if not ThePlayer or not ThePlayer:IsValid() or not TheFocalPoint then
        return
    end

    local player_pos = ThePlayer:GetPosition()
    local my_pos = inst:GetPosition()
    local delta_pos = player_pos - my_pos
    local can_affect = math.abs(delta_pos.x) <= inst._affect_range_x:value() and
        math.abs(delta_pos.z) <= inst._affect_range_z:value()

    if can_affect and not inst.affecting then
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, 21.5, 21.51, 999, camera_settings)
        inst.affecting = true
    elseif not can_affect and inst.affecting then
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)

        -- TheCamera:SetDefault()
        -- TheCamera:SetDefaultOffset()
        -- TheCamera:SetDistance(30)
        -- TheCamera:Snap()

        inst.affecting = false
    end
end

local function SetUp(inst, camera_distance, affect_range_x, affect_range_z, limit_range_x, limit_range_z)
    if camera_distance ~= nil then
        inst._camera_distance:set(camera_distance)
    end

    if affect_range_x ~= nil then
        inst._affect_range_x:set(affect_range_x)
    end

    if affect_range_z ~= nil then
        inst._affect_range_z:set(affect_range_z)
    end

    if limit_range_x ~= nil then
        inst._limit_range_x:set(limit_range_x)
    end

    if limit_range_z ~= nil then
        inst._limit_range_z:set(limit_range_z)
    end
end

local function OnSave(inst, data)
    data.camera_distance = inst._camera_distance:value()
    data.affect_range_x = inst._affect_range_x:value()
    data.affect_range_z = inst._affect_range_z:value()
    data.limit_range_x = inst._limit_range_x:value()
    data.limit_range_z = inst._limit_range_z:value()
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst:SetUp(data.camera_distance,
            data.affect_range_x,
            data.affect_range_z,
            data.limit_range_x,
            data.limit_range_z)
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("stariliad_camera")


    -- inst._range_x = net_float(inst.GUID, "inst._range_x", "rangexdirty")
    -- -- inst._range_z = net_smallbyte(inst.GUID, "inst._range_z", "rangeydirty")
    -- inst._range_affect = net_float(inst.GUID, "inst._range_affect")

    inst._camera_distance = net_float(inst.GUID, "inst._camera_distance")
    inst._camera_distance:set(21.5)
    -- inst._camera_distance:set(18)

    inst._affect_range_x = net_float(inst.GUID, "inst._affect_range_x")
    inst._affect_range_z = net_float(inst.GUID, "inst._affect_range_z")
    inst._affect_range_x:set(10.5)
    inst._affect_range_z:set(2.5)

    inst._limit_range_x = net_float(inst.GUID, "inst._limit_range_x")
    inst._limit_range_z = net_float(inst.GUID, "inst._limit_range_z")
    inst._limit_range_x:set(0)
    inst._limit_range_z:set(0)

    if not TheNet:IsDedicated() then
        inst:DoPeriodicTask(0, TryAffectPlayer)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetUp = SetUp

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad


    return inst
end

return Prefab("stariliad_interior_camera_default", fn)
