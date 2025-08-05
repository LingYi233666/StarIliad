local assets = {
    Asset("ANIM", "anim/blythe_scan_mark.zip"),
}

local FADEIN_DURATION = 0.33
local FADEOUT_DURATION = 0.5
local MAX_DELAY = 1
local KEEP_TIME = 1
local RADIUS = 60
local GRID_SIZE = 1
local CENTER_DURATION = MAX_DELAY + KEEP_TIME + FADEOUT_DURATION

local function UpdateAnim(transparency_level, inst)
    local r, g, b, a = inst.AnimState:GetMultColour()
    inst.AnimState:SetMultColour(r, g, b, transparency_level)
end

local function OnFadeIn(inst)
    local r, g, b, a = inst.AnimState:GetMultColour()

    inst.components.fader:Fade(a, 1, FADEIN_DURATION, UpdateAnim)
end

local function OnFadeOut(inst)
    local r, g, b, a = inst.AnimState:GetMultColour()

    inst.components.fader:Fade(a, 0, FADEOUT_DURATION, UpdateAnim)
end


local function CreateMarker(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("blythe_scan_mark")
    inst.AnimState:SetBuild("blythe_scan_mark")
    inst.AnimState:SetPercent("anim", 0.1)

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)

    inst:AddComponent("fader")

    return inst
end

local function CreateRing(proxy, scale)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    if proxy then
        inst.Transform:SetFromProxy(proxy.GUID)
    end

    if scale then
        inst.Transform:SetScale(scale, scale, scale)
    end

    inst.AnimState:SetBank("bearger_ring_fx")
    inst.AnimState:SetBuild("bearger_ring_fx")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

-- local function HasBlockItems(pos, master)
--     local ents = TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, { "INLIMBO", "NOBLOCK", "FX", })
--     for _, v in pairs(ents) do
--         if v ~= master then
--             return true
--         end
--     end

--     return false
-- end

local function GetBlockItems(pos, master)
    local result = {}
    local ents = TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, { "INLIMBO", "NOBLOCK", "FX", })
    for _, v in pairs(ents) do
        if v ~= master then
            table.insert(result, v)
        end
    end

    return result
end


local function SpawnClientMarks(inst)
    local mid_pos = inst:GetPosition()

    local x_count = 2 * RADIUS / GRID_SIZE
    local z_count = 2 * RADIUS / GRID_SIZE

    local master = inst._master:value()

    local echo_physics_groups = {
        COLLISION.OBSTACLES,
        COLLISION.CHARACTERS,
        COLLISION.FLYERS,
        COLLISION.SANITY,
        COLLISION.SMALLOBSTACLES,
        COLLISION.GIANTS,
    }


    for i = 0, x_count do
        for j = 0, z_count do
            local x = -RADIUS + i * GRID_SIZE
            local z = -RADIUS + j * GRID_SIZE

            local offset = Vector3(x, 0, z)
            local dist = offset:Length()
            if dist <= RADIUS then
                local delay = Remap(dist, 0, RADIUS, 0, MAX_DELAY)

                -- inst:DoTaskInTime(delay, function()
                --     local fx = CreateMarker(inst)
                --     inst:AddChild(fx)


                --     fx.Transform:SetPosition(x, 0, z)

                --     local new_pos = mid_pos + Vector3(x, 0, z)
                --     local block_items = GetBlockItems(new_pos, master)
                --     if #block_items > 0 then
                --         fx.AnimState:SetAddColour(1, 1, 0, 0)

                --         local may_has_enemy = false
                --         local has_normal = false
                --         for _, v in pairs(block_items) do
                --             -- if v.replica.health and not v.replica.health:IsDead() then
                --             --     local ring = CreateRing(nil, 0.5)
                --             --     ring.Transform:SetPosition(fx.Transform:GetWorldPosition())
                --             --     break
                --             -- end

                --             -- if v.Physics and table.contains(echo_physics_groups, v.Physics:GetCollisionGroup()) then
                --             --     local ring = CreateRing(nil, 0.5)
                --             --     ring.Transform:SetPosition(fx.Transform:GetWorldPosition())
                --             --     break
                --             -- end

                --             if v:HasTag("hostile") or v:HasTag("monster") then
                --                 may_has_enemy = true
                --                 break
                --             end

                --             if v.Physics and table.contains(echo_physics_groups, v.Physics:GetCollisionGroup()) then
                --                 has_normal = true
                --             end
                --         end

                --         if may_has_enemy then
                --             local ring = CreateRing(nil, 0.6)
                --             ring.AnimState:SetMultColour(1, 0, 0, 1)
                --             ring.Transform:SetPosition(fx.Transform:GetWorldPosition())
                --         elseif has_normal then
                --             local ring = CreateRing(nil, 0.5)
                --             ring.Transform:SetPosition(fx.Transform:GetWorldPosition())
                --         end
                --     elseif TheWorld.Map:IsPassableAtPoint(new_pos.x, new_pos.y, new_pos.z, false, false) then
                --         -- fx.AnimState:SetMultColour(0, 1, 0, 0)
                --         fx.AnimState:SetAddColour(0, 1, 0, 0)
                --     else
                --         -- fx.AnimState:SetMultColour(1, 0, 0, 0)
                --         fx.AnimState:SetAddColour(1, 0, 0, 0)
                --     end
                --     fx.AnimState:SetMultColour(1, 1, 1, 0)


                --     OnFadeIn(fx)

                --     fx:DoTaskInTime(KEEP_TIME, function()
                --         OnFadeOut(fx)
                --     end)

                --     fx:DoTaskInTime(KEEP_TIME + FADEOUT_DURATION, fx.Remove)
                -- end)

                local mark_pos = offset * 1.0
                inst:DoTaskInTime(delay, function()
                    local new_pos = mid_pos + offset
                    local block_items = GetBlockItems(new_pos, master)
                    if #block_items > 0 then
                        -- Yellow
                        inst.scan_mark2:AddEmitTask(-1, 1, mark_pos)

                        local may_has_enemy = false
                        local has_normal = false
                        for _, v in pairs(block_items) do
                            if v:HasTag("hostile") or v:HasTag("monster") then
                                may_has_enemy = true
                                break
                            end

                            if v.Physics and table.contains(echo_physics_groups, v.Physics:GetCollisionGroup()) then
                                has_normal = true
                            end
                        end

                        if may_has_enemy then
                            local ring = CreateRing(nil, 0.6)
                            ring.AnimState:SetMultColour(1, 0, 0, 1)
                            ring.Transform:SetPosition(new_pos:Get())
                        elseif has_normal then
                            local ring = CreateRing(nil, 0.5)
                            ring.Transform:SetPosition(new_pos:Get())
                        end
                    elseif TheWorld.Map:IsPassableAtPoint(new_pos.x, new_pos.y, new_pos.z, false, false) then
                        -- Green
                        inst.scan_mark2:AddEmitTask(-1, 0, mark_pos)
                    else
                        -- Red
                        inst.scan_mark2:AddEmitTask(-1, 2, mark_pos)
                    end
                end)
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("CLASSIFIED")

    inst._master = net_entity(inst.GUID, "inst._master")

    if not TheNet:IsDedicated() then
        inst.scan_mark2 = inst:SpawnChild("blythe_scan_mark2")

        inst:DoTaskInTime(0, SpawnClientMarks)
        inst:DoTaskInTime(0, CreateRing, 1.6)
        inst:DoTaskInTime(0.1, CreateRing, 1.6)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    inst:DoTaskInTime(CENTER_DURATION, inst.Remove)

    return inst
end

return Prefab("blythe_scan_mark_center", fn, assets)
