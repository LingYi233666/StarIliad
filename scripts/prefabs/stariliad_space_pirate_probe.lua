-- TODO: Finish this probe for space pirate invasion warning


local assets =
{
    Asset("ANIM", "anim/wx_scanner.zip"),
    Asset("ANIM", "anim/wx_scanner_ring_fx.zip"),
    Asset("ANIM", "anim/stariliad_space_pirate_probe.zip"),

    Asset("MINIMAP_IMAGE", "wx78_scanner_item"),
}

local function OnLightDirty(inst)
    inst.Light:Enable(inst._light_enable:value())
end

local function SetTarget(inst, target)
    inst.components.entitytracker:TrackEntity("target", target)
end

local function IsTargetInRange(inst)
    local target = inst.components.entitytracker:GetEntity("target")
    if target and target:IsValid() then
        return inst:GetDistanceSqToInst(target) < TUNING.STARILIAD_SPACE_PIRATE_PROBE_SCAN_RANGE_SQ
    end
    return false
end

local function ShouldScan(inst)
    local lastattackedtime = inst.components.combat:GetLastAttackedTime()
    if lastattackedtime and GetTime() - lastattackedtime < 1 then
        return false
    end
    return IsTargetInRange(inst)
end

local function SetShouldLeave(inst)
    inst.components.entitytracker:ForgetEntity("target")

    inst.persists = false
    inst.should_leave = true
    if inst:IsAsleep() then
        inst:Remove()
    end
end

local function OnEntityWake(inst)
    if not inst.SoundEmitter:PlayingSound("movement_lp") then
        inst.SoundEmitter:PlaySound("WX_rework/scanner/movement_lp", "movement_lp")
    end
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("movement_lp")
    if inst.should_leave then
        inst:Remove()
    end
end

local function OnPhase(inst)
    if TheWorld.state.phase == "night" then
        inst._light_enable:set(true)
        inst.AnimState:Show("top_light")
    else
        inst._light_enable:set(false)
        inst.AnimState:Hide("top_light")
    end
end

local function UpdateScanSound(inst)
    if inst.AnimState:IsCurrentAnimation("scan_loop") then
        if not inst.SoundEmitter:PlayingSound("telemetry_lp") then
            inst.SoundEmitter:PlaySound("WX_rework/scanner/telemetry_lp", "telemetry_lp")
        end
    else
        inst.SoundEmitter:KillSound("telemetry_lp")
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeTinyFlyingCharacterPhysics(inst, 1, 0.5)

    inst.Transform:SetFourFaced()

    inst.MiniMapEntity:SetIcon("wx78_scanner_item.png")
    inst.MiniMapEntity:SetCanUseCache(false)

    inst.DynamicShadow:SetSize(1.2, 0.75)

    inst:AddTag("NOBLOCK")
    -- inst:AddTag("scarytoprey")
    inst:AddTag("flying")
    inst:AddTag("mech")
    inst:AddTag("stariliad_space_pirate")

    inst.AnimState:SetBank("scanner")
    inst.AnimState:SetBuild("stariliad_space_pirate_probe")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:Hide("top_light")
    inst.AnimState:Hide("bottom_light")

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(252 / 255, 251 / 255, 237 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)

    inst._light_enable = net_bool(inst.GUID, "inst._light_enable", "lightdirty")
    inst._light_enable:set(false)

    inst:ListenForEvent("lightdirty", OnLightDirty)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.SetTarget = SetTarget
    inst.IsTargetInRange = IsTargetInRange
    inst.ShouldScan = ShouldScan
    inst.SetShouldLeave = SetShouldLeave

    inst:AddComponent("entitytracker")

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { allowocean = true, ignorecreep = true, ignorewalls = true }
    inst.components.locomotor.walkspeed = 6.1

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(100)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(0)

    -- inst:AddComponent("updatelooper")
    -- inst.components.updatelooper:AddOnUpdateFn(function()
    --     inst._light_enable:set(inst.AnimState:IsCurrentAnimation("scan_loop"))
    -- end)

    local brain = require("brains/stariliad_space_pirate_probe_brain")
    inst:SetStateGraph("SGstariliad_space_pirate_probe")
    inst:SetBrain(brain)

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

    -- inst._light_enable:set(true)

    inst:WatchWorldState("phase", OnPhase)

    inst:ListenForEvent("stariliad_space_pirate_invasion_start", function()
        inst:DoTaskInTime(math.random(), function()
            inst:SetShouldLeave()
        end)
    end, TheWorld)

    OnPhase(inst)

    if not inst:IsAsleep() then
        OnEntityWake(inst)
    end

    inst:DoPeriodicTask(0, UpdateScanSound)

    return inst
end

local function burntground_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("burntground")
    inst.AnimState:SetBank("burntground")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_GROUND)
    inst.AnimState:SetSortOrder(3)

    inst.AnimState:SetMultColour(1, 1, 1, 0.6)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.Transform:SetRotation(math.random() * 360)

    inst:DoTaskInTime(GetRandomMinMax(8, 12), function()
        inst:DoPeriodicTask(0, function()
            local r, g, b, a = inst.AnimState:GetMultColour()
            a = a - FRAMES

            if a < 0 then
                inst:Remove()
            else
                inst.AnimState:SetMultColour(r, g, b, a)
            end
        end)
    end)

    return inst
end

return Prefab("stariliad_space_pirate_probe", fn, assets),
    Prefab("stariliad_space_pirate_probe_burntground", burntground_fn, assets)

-- c_spawn("stariliad_space_pirate_probe")
-- c_spawn("stariliad_space_pirate_probe"):SetTarget(ThePlayer)
-- c_spawn("stariliad_space_pirate_probe"):SetShouldLeave()
