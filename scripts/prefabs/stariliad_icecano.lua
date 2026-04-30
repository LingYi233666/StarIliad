local assets =
{
    Asset("ANIM", "anim/stariliad_volcano.zip"),
    Asset("ANIM", "anim/stariliad_icecano2.zip"),
}

----------------------------------------------------------------
-- Camera setting

local zoomdistance = 100
local distToFinish = 10 --Distance to volcano where you reach max zoom
local distToStart = 65  --Distance from the volcano where you start to zoom
local distToStart_SQ = distToStart * distToStart
local distToFinish_SQ = distToFinish * distToFinish
local distToLerpOver = distToStart_SQ - distToFinish_SQ
local percentFromPlayer = 1

local function CameraUpdate(inst, player)
    local distToTarget = inst:GetDistanceSqToInst(player)

    if distToTarget < distToStart_SQ then
        -- TheCamera:SetControllable(false)
        percentFromPlayer = (distToTarget - distToFinish_SQ) / distToLerpOver

        if percentFromPlayer >= 0 and percentFromPlayer <= 1 then
            local camDist = Lerp(zoomdistance, inst.prevCamDist, percentFromPlayer)
            TheCamera:SetDistance(camDist)
            TheCamera:Apply()
        elseif percentFromPlayer < 0 then
            TheCamera:SetDistance(zoomdistance)
            TheCamera:Apply()
        end
    else
        if not TheCamera:IsControllable() then
            TheCamera:SetDistance(inst.prevCamDist)
            -- TheCamera:SetHeadingTarget(inst.prevCamAngle)
            TheCamera:Apply()
        end
        -- TheCamera:SetControllable(true)
        -- inst.prevCamAngle = TheCamera:GetHeadingTarget()
        inst.prevCamDist = TheCamera:GetDistance()
    end
end

local camera_settings = {
    ActiveFn = function(best_focus, player, best_dist_sq)

    end,

    UpdateFn = function(dt, best_focus, player, best_dist_sq)
        CameraUpdate(best_focus.target, player)
    end,
}

----------------------------------------------------------------

local function TryAffectPlayer(inst)
    if not ThePlayer or not ThePlayer:IsValid() or not TheFocalPoint or not TheCamera then
        return
    end

    local is_near = inst:IsNear(ThePlayer, distToStart)

    if is_near and not inst.affecting_camera then
        TheCamera.dollyzoom = true
        if ThePlayer.HUD.clouds_on then
            ThePlayer.HUD.clouds_on = false
            ThePlayer.HUD.clouds:Hide()
            ThePlayer.HUD.clouds:GetAnimState():SetMultColour(0, 0, 0, 0)
            TheFocalPoint.SoundEmitter:KillSound("windsound")
            TheMixer:PopMix("high")
        end

        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, nil, distToStart, 999, camera_settings)

        inst.affecting_camera = true
    elseif not is_near and inst.affecting_camera then
        TheCamera.dollyzoom = false
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)

        inst.affecting_camera = false
    end
end

----------------------------------------------------------------


local function IsErupting(inst)
    return TheWorld.components.stariliad_weather_ice_meteor
        and TheWorld.components.stariliad_weather_ice_meteor:IsErupting()
end

local function ShouldActive(inst)
    return inst:IsErupting() or TheWorld.state.iswinter
end

local function CheckState(inst)
    if inst:IsErupting() then
        inst.sg:GoToState("erupt_pre")
    elseif inst:ShouldActive() then
        inst.sg:GoToState("active_idle")
    else
        inst.sg:GoToState("dormant_idle")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    -- inst.entity:AddPhysics()

    -- inst.Physics:SetMass(0)
    -- inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    -- inst.Physics:ClearCollisionMask()
    -- inst.Physics:CollidesWith(COLLISION.ITEMS)
    -- inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    -- inst.Physics:CollidesWith(COLLISION.WAVES)

    MakeWaterObstaclePhysics(inst, 5, 17, 0.75)

    inst.AnimState:SetBank("volcano")
    inst.AnimState:SetBuild("stariliad_icecano2")
    inst.AnimState:PlayAnimation("dormant_idle", true)

    if not TheNet:IsDedicated() then
        inst.prevCamDist = 30
        -- inst.prevCamAngle = 45
        inst:DoPeriodicTask(0, TryAffectPlayer)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst.IsErupting = IsErupting
    inst.ShouldActive = ShouldActive

    inst:AddComponent("inspectable")

    inst:SetStateGraph("SGstariliad_icecano")

    inst:ListenForEvent("stariliad_ice_meteor_erupt_warning", function()
        inst.sg:GoToState("rumble")
    end, TheWorld)


    inst:ListenForEvent("stariliad_start_erupting_ice_meteor", function()
        CheckState(inst)
    end, TheWorld)

    inst:ListenForEvent("stariliad_stop_erupting_ice_meteor", function()
        CheckState(inst)
    end, TheWorld)

    inst:WatchWorldState("iswinter", CheckState)
    CheckState(inst)

    return inst
end

return Prefab("stariliad_icecano", fn, assets)
