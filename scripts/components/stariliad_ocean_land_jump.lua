local function onis_swimming(self, val)
    self.inst.replica.stariliad_ocean_land_jump:SetIsSwimming(val)
end

local StarIliadOceanLandJump = Class(function(self, inst)
    self.inst = inst

    self.jump_duration = 1
    self.speed = 0

    self.is_swimming = false

    self.last_pos = nil
    self.distance_travel = 0
    self.anim_idx = 0

    -- inst:ListenForEvent("newstate", function()
    --     local last_sg_tag = {}
    --     if inst.sg.laststate and inst.sg.laststate.tags then
    --         last_sg_tag = inst.sg.laststate.tags
    --     end

    --     if inst.sg:HasStateTag("jumping") or last_sg_tag["jumping"] == true then
    --         self:CheckSwimming()
    --     end
    -- end)

    self.inst:StartUpdatingComponent(self)
end, nil, {
    is_swimming = onis_swimming,
})

function StarIliadOceanLandJump:SetJumpDuration(val)
    self.jump_duration = val
end

function StarIliadOceanLandJump:IsSwimming()
    return self.is_swimming
end

function StarIliadOceanLandJump:OnStartJump(target_pos)
    self.inst.sg.statemem.isphysicstoggle = true
    self.inst.Physics:ClearCollisionMask()
    self.inst.Physics:CollidesWith(COLLISION.GROUND)

    self.inst.components.health:SetInvincible(true)

    local start_pos = self.inst:GetPosition()
    local delta_pos = target_pos - start_pos

    self.speed = delta_pos:Length() / self.jump_duration

    self.inst:ForceFacePoint(target_pos)
    self.inst.Physics:SetMotorVel(self.speed, 0, 0)

    self:CheckSwimming()
end

function StarIliadOceanLandJump:OnJumpUpdate()
    self.inst.Physics:SetMotorVel(self.speed, 0, 0)
end

function StarIliadOceanLandJump:OnStopJump()
    self.inst.sg.statemem.isphysicstoggle = nil
    self.inst.Physics:ClearCollisionMask()
    self.inst.Physics:CollidesWith(COLLISION.WORLD)
    self.inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    self.inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    self.inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    self.inst.Physics:CollidesWith(COLLISION.GIANTS)

    self.inst.components.health:SetInvincible(false)

    self.inst.Physics:Stop()

    self:CheckSwimming()
end

function StarIliadOceanLandJump:CreateSplash(pos, spawn_child, sound, scale)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    if spawn_child then
        pos = pos or Vector3(0, 0, 0)
    else
        pos = pos or Vector3(x, y, z)
    end
    sound = sound or "small"
    scale = scale or 1
    local fx = SpawnAt("splash_sink", pos)
    fx.Transform:SetScale(scale, scale, scale)
    self.inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/" .. sound)
    if spawn_child then
        self.inst:AddChild(fx)
    end
end

local ANIMS = { "idle_loop_1", "idle_loop_2", "idle_loop_3" }
function StarIliadOceanLandJump:CreateWaterTail(x, y, z, dir_x, dir_z)
    local fx = SpawnPrefab("stariliad_water_tail")

    local radius = 0.5
    fx.Transform:SetPosition(x - dir_x * radius, y, z - dir_z * radius)
    fx.Transform:SetScale(0.65, 0.65, 0.65)

    self.anim_idx = (self.anim_idx + (math.random() > 0.5 and 1 or -1)) % #ANIMS
    fx.AnimState:PlayAnimation(ANIMS[self.anim_idx + 1])

    if fx.components.boattrailmover ~= nil then
        fx.components.boattrailmover:Setup(dir_x, dir_z, 0.5, -0.125)
    end
end

function StarIliadOceanLandJump:EnableSwimming(enable)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local has_gravity_control = StarIliadBasic.HasGravityControl(self.inst)

    if not self.is_swimming and enable then
        self:CreateSplash(Vector3(x, y + 1, z))

        -- self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "stariliad_swimming", 0.5)

        if not has_gravity_control then
            self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "stariliad_swimming", 0.5)
        end
    elseif self.is_swimming and not enable then
        self:CreateSplash(Vector3(x, y + 1, z))

        self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "stariliad_swimming")

        self.last_pos = nil
        self.distance_travel = 0
    elseif self.is_swimming and has_gravity_control then
        self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "stariliad_swimming")
    end

    self.is_swimming = enable
end

function StarIliadOceanLandJump:CheckSwimming()
    self:EnableSwimming(self:ShouldUseSwimming())
end

function StarIliadOceanLandJump:ShouldUseSwimming()
    local x, y, z = self.inst.Transform:GetWorldPosition()

    return TheWorld.has_ocean
        and self.inst:IsOnOcean()
        and y < 0.1
        and not self.inst.sg:HasStateTag("jumping")
        and not self.inst:HasTag("playerghost")
        and not self.inst.sg:HasStateTag("drowning")
        and not self.inst.sg:HasStateTag("floating")
    -- and not self.inst.sg:HasStateTag("aoe")
end

function StarIliadOceanLandJump:OnUpdate(dt)
    self:CheckSwimming()

    if self:IsSwimming() then
        local pos = self.inst:GetPosition()

        if self.last_pos then
            self.distance_travel = self.distance_travel + (pos - self.last_pos):Length()
        end

        if self.distance_travel > 2 then
            local forward = StarIliadBasic.GetFaceVector(self.inst)
            local x, y, z = pos:Get()
            local dir_x = forward.x
            local dir_z = forward.z
            self:CreateWaterTail(x, y + 1, z, dir_x, dir_z)
            self.distance_travel = self.distance_travel - 2
        end

        self.last_pos = pos


        -------------------------------------------

        -- local is_riding = self.inst.components.rider and self.inst.components.rider:IsRiding()
        -- local moisture = self.inst.components.moisture

        -- if not is_riding and moisture then
        --     moisture:DoDelta(10 * dt, true)
        -- end
    end

    -- if self:IsSwimming() and self.inst.components.moisture and self.inst.components.moisture:GetMoisturePercent() < 1.0 then
    --     self.inst.components.moisture:AddRateBonus(self.inst, 1, "stariliad_swimming")
    -- else
    --     self.inst.components.moisture:RemoveRateBonus(self.inst, "stariliad_swimming")
    -- end

    if self:IsSwimming() and self.inst.components.moisture and self.inst.components.moisture:GetMoisturePercent() < 0.5 then
        self.inst.components.moisture:AddRateBonus(self.inst, 1, "stariliad_swimming")
    else
        self.inst.components.moisture:RemoveRateBonus(self.inst, "stariliad_swimming")
    end
end

return StarIliadOceanLandJump
