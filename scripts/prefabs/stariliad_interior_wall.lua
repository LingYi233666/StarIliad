local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "stariliad_interior_wall_colourenvelope"

-- Note: 1 range in Game = 150 pixel
local image_dataset = {
    test = {
        path = "levels/interiors/stariliad_wall_sinkhole.tex",
        width = 512,        -- 图像宽度
        height = 512,       -- 图像高度
        height_sink = 10,   -- 高度下沉，可以让图像向下移动一些距离，掩盖底端像素的瑕疵
        scale = 1200 / 512, -- 缩放倍率，缩放后的宽度必须是150的整数倍
        -- scale = 900 / 512,
    },

    sinkhole = {
        path = "levels/interiors/stariliad_wall_sinkhole.tex",
        width = 512,        -- 图像宽度
        height = 512,       -- 图像高度
        height_sink = 10,   -- 高度下沉，可以让图像向下移动一些距离，掩盖底端像素的瑕疵
        scale = 1200 / 512, -- 缩放倍率，缩放后的宽度必须是150的整数倍
        -- scale = 900 / 512,
    },

    rock = {
        path = "levels/interiors/stariliad_wall_rock.tex",
        width = 512,        -- 图像宽度
        height = 512,       -- 图像高度
        height_sink = 10,   -- 高度下沉，可以让图像向下移动一些距离，掩盖底端像素的瑕疵
        scale = 1200 / 512, -- 缩放倍率，缩放后的宽度必须是150的整数倍
    },

    dirt = {
        path = "levels/interiors/stariliad_wall_dirt.tex",
        width = 512,        -- 图像宽度
        height = 512,       -- 图像高度
        height_sink = 10,   -- 高度下沉，可以让图像向下移动一些距离，掩盖底端像素的瑕疵
        scale = 1200 / 512, -- 缩放倍率，缩放后的宽度必须是150的整数倍
    },

    archive = {
        path = "levels/interiors/stariliad_wall_archive2.tex",
        width = 512,        -- 图像宽度
        height = 512,       -- 图像高度
        height_sink = 10,   -- 高度下沉，可以让图像向下移动一些距离，掩盖底端像素的瑕疵
        scale = 1200 / 512, -- 缩放倍率，缩放后的宽度必须是150的整数倍
    },

}

local assets =
{
    Asset("SHADER", SHADER),
}

for k, data in pairs(image_dataset) do
    data.path = resolvefilepath(data.path)
    data.scale = data.scale or 1
    data.height_sink = data.height_sink or 0

    table.insert(assets, Asset("IMAGE", data.path))
end


local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0, { 1, 1, 1, 1 } },
            { 1, { 1, 1, 1, 1 } },
        }
    )

    for k, data in pairs(image_dataset) do
        EnvelopeManager:AddVector2Envelope(
            "stariliad_interior_wall_" .. k .. "_scaleenvelope",
            {
                { 0, { data.scale, data.scale } },
                { 1, { data.scale, data.scale } },
            }
        )
    end


    InitEnvelope = nil
end

local MAX_LIFETIME = 0.33


local function SetLayer(inst, layer)
    local num_emitters = #inst.emit_data

    for i = 0, num_emitters - 1 do
        inst.VFXEffect:SetLayer(i, layer)
    end
end

-- local function FixVertexes(vertexes, loop)
--     local i = 1

--     while true do
--         local start_pos = vertexes[i]
--         local end_pos = vertexes[i + 1]

--         if not start_pos or not end_pos then
--             break
--         end

--         local forward = end_pos - start_pos
--         local forward_length = forward:Length()
--         local forward_unit = forward / forward_length
--         local int_length = math.floor(forward_length)

--         if forward_length > 1 and forward_length - int_length > 0.01 then
--             local mid_pos = start_pos + forward_unit * int_length
--             table.insert(vertexes, i + 1, mid_pos)
--         else
--             i = i + 1
--         end
--     end
-- end

local function FnWrapper(name, data)
    local function EmitTask(inst)
        if not inst.emit_data then
            return
        end

        local c_down = TheCamera:GetPitchDownVec():Normalize()
        local c_right = TheCamera:GetRightVec():Normalize()
        local c_up = c_down:Cross(c_right):Normalize()

        local num_emitters = #inst.emit_data
        local effect = inst.VFXEffect

        for i = 1, num_emitters do
            local angle = inst.emit_data[i].angle

            effect:SetSpawnVectors(i - 1,
                math.cos(angle), 0, math.sin(angle),
                c_up.x, c_up.y, c_up.z
            )

            for _, pos_uv in pairs(inst.emit_data[i].pos_uv_list) do
                local half_height = data.height * 0.5 / 150
                local sink = data.height_sink / 150
                local final_pos = pos_uv.pos + c_up * (half_height - sink) * data.scale

                -- print("Emit data:")
                -- print(i - 1)
                -- print(MAX_LIFETIME)
                -- print(final_pos)
                -- print(pos_uv.u_offset)

                effect:AddParticleUV(
                    i - 1,
                    MAX_LIFETIME - 1e-3,                   -- lifetime
                    final_pos.x, final_pos.y, final_pos.z, -- position
                    0, 0, 0,                               -- velocity
                    pos_uv.u_offset, 0                     -- uv offset
                )
            end
        end
    end

    local function GenerateEmitData(inst, vertexes, loop)
        inst.emit_data = {}

        if #vertexes <= 1 then
            return
        end

        -- FixVertexes(vertexes, loop)

        local num_emitters = loop and (#vertexes) or (#vertexes - 1)
        local effect = inst.VFXEffect

        -- local u_offset = 0
        local counter = 0
        for i = 1, num_emitters do
            local start_pos = Vector3(vertexes[i][1], vertexes[i][2], vertexes[i][3])
            local tmp = (i < #vertexes) and vertexes[i + 1] or vertexes[1]
            local end_pos = Vector3(tmp[1], tmp[2], tmp[3])

            local forward = end_pos - start_pos
            local forward_length = forward:Length()
            local forward_unit = forward / forward_length
            local angle = math.atan2(forward.z, forward.x)
            -- local unit_dist = forward_length >= 1 and 1 or 0.01
            -- local unit_dist = 0.1
            local unit_dist = 1

            local num_particles = forward_length / unit_dist
            local uv_step_inv = math.floor((data.width * data.scale) / (150 * unit_dist))
            local uv_step = 1 / uv_step_inv

            if angle < 0 then
                angle = 2 * PI + angle
            end

            local effect_id = i - 1
            effect:SetRenderResources(effect_id, data.path, SHADER)
            effect:SetUVFrameSize(effect_id, uv_step, 1)
            effect:SetMaxNumParticles(effect_id, num_particles)
            effect:SetMaxLifetime(effect_id, MAX_LIFETIME)
            effect:SetColourEnvelope(effect_id, COLOUR_ENVELOPE_NAME)
            effect:SetScaleEnvelope(effect_id, name .. "_scaleenvelope")
            effect:SetSortOrder(effect_id, -1)
            effect:SetLayer(effect_id, LAYER_BACKGROUND)
            effect:SetKillOnEntityDeath(effect_id, true)
            effect:EnableDepthTest(effect_id, true)


            local tab = { angle = angle, pos_uv_list = {} }
            local forward_offset = forward_unit * unit_dist * 0.5
            for j = 0, num_particles - 1 do
                local cur_pos = start_pos + forward_unit * unit_dist * j + forward_offset

                table.insert(tab.pos_uv_list, {
                    pos = cur_pos,
                    u_offset = counter * uv_step,
                })

                counter = counter + 1
                if counter >= uv_step_inv then
                    counter = 0
                end
            end

            table.insert(inst.emit_data, tab)
        end

        -- print("Num emitters:", #inst.emit_data, num_emitters)
        -- dumptable(inst.emit_data)
    end

    local function OnWallDataDirty(inst)
        local str = inst._wall_data_json:value()
        if #str <= 0 then
            return
        end

        local tab = json.decode(str)
        -- dumptable(tab[1])
        -- print(tab[2])
        GenerateEmitData(inst, tab[1], tab[2])

        -- local tab = json.decode(str)
        -- GenerateEmitData(inst, tab, false)
    end

    local function particle_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")


        inst._wall_data_json = net_string(inst.GUID, "inst._wall_data_json", "wall_data_dirty")

        inst.entity:SetPristine()

        inst.persists = false

        --Dedicated server does not need to spawn local particle fx
        if TheNet:IsDedicated() then
            return inst
        else
            if InitEnvelope ~= nil then
                InitEnvelope()
            end

            inst:ListenForEvent("wall_data_dirty", OnWallDataDirty)
        end


        local effect = inst.entity:AddVFXEffect()
        effect:InitEmitters(10) -- Init must put in the construct function

        EmitterManager:AddEmitter(inst, nil, function()
            EmitTask(inst)
        end)

        return inst
    end


    -- local function MakeParticle(tab, loop)
    --     local inst = CreateEntity()

    --     inst.entity:AddTransform()

    --     inst:AddTag("FX")
    --     --[[Non-networked entity]]
    --     inst.persists = false

    --     -----------------------------------------------------

    --     if InitEnvelope ~= nil then
    --         InitEnvelope()
    --     end

    --     local effect = inst.entity:AddVFXEffect()

    --     GenerateEmitData(inst, tab, loop)

    --     EmitterManager:AddEmitter(inst, nil, function()
    --         EmitTask(inst)
    --     end)

    --     return inst
    -- end

    ---------------------------------------------------------------------------

    local function SetWallData(inst, vertexes, loop)
        if loop == nil then
            loop = false
        end

        inst.wall_data = { {}, loop, }

        for _, v in pairs(vertexes) do
            if v.IsVector3 then
                table.insert(inst.wall_data[1], { v.x, v.y, v.z })
            else
                table.insert(inst.wall_data[1], v)
            end
        end

        local str = json.encode(inst.wall_data)
        inst.particle._wall_data_json:set(str)


        -- inst.wall_data = {}

        -- for _, v in pairs(vertexes) do
        --     if v.IsVector3 then
        --         table.insert(inst.wall_data, { v.x, v.y, v.z })
        --     else
        --         table.insert(inst.wall_data, v)
        --     end
        -- end

        -- local str = json.encode(inst.wall_data)
        -- inst.particle._wall_data_json:set(str)
    end

    local function OnSave(inst, data)
        data.wall_data = inst.wall_data
    end

    local function OnLoad(inst, data)
        if data.wall_data ~= nil then
            inst:DoTaskInTime(0, function()
                inst:SetWallData(data.wall_data[1], data.wall_data[2])
            end)
        end
    end

    local function wall_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        -- if not TheNet:IsDedicated() then
        --     inst._particle = MakeParticle({ { 0, 0, 0 }, { 0, 0, 10 }, { 10, 0, 10 } })
        --     inst:AddChild(inst._particle)
        -- end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.wall_data = {}

        inst.SetWallData = SetWallData
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        inst.particle = inst:SpawnChild(name .. "_particle")


        return inst
    end


    return Prefab(name .. "_particle", particle_fn, assets), Prefab(name, wall_fn, assets)
end


-- c_spawn("stariliad_interior_wall_test")
-- c_findnext("stariliad_interior_wall_test"):SetWallData({{0,0,0},{0,0,10},{10,0,10}})
-- c_findnext("stariliad_interior_wall_test"):SetWallData({{0,0,0},{0,0,10},{10,0,10},{10,0,0}},true)
-- c_spawn("stariliad_interior_wall_test"):SetWallData({{0,0,0},{0,0,10},{10,0,10}})
-- c_spawn("stariliad_interior_wall_test"):SetWallData({{0,0,0},{0,0,10},{10,0,10},{10,0,0}},true)
-- c_spawn("stariliad_interior_wall_test")

local ents = {}
for k, data in pairs(image_dataset) do
    local p1, p2 = FnWrapper("stariliad_interior_wall_" .. k, data)
    table.insert(ents, p1)
    table.insert(ents, p2)
end

return unpack(ents)
