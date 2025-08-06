local StarIliadImportantScanTarget = Class(function(self, inst)
    self.inst = inst

    self.marker_height = 200
    self.hud_data = { image = "poi_question.tex", atlas = "images/avatars.xml" }
    self.max_reveal_time = 10
    self.max_dist = 50

    self.reveal_time = 0
    self.add_indicator = false

    self.inst:StartUpdatingComponent(self)
end)

local function _CommonIndicator(data)
    local inst = CreateEntity()

    --[[Non-networked entity]]
    if not TheWorld.ismastersim then
        inst.entity:SetCanSleep(false)
    end

    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation(data.anim)

    local s = 2
    inst.Transform:SetScale(s, s, s)


    return inst
end

local function PrefabIndicator()
    return _CommonIndicator({ bank = "poi_marker", build = "poi_marker", anim = "idle" })
end

local function CreateRing()
    local inst = _CommonIndicator({ bank = "poi_marker", build = "poi_marker", anim = "ring" })

    inst.entity:AddFollower()

    return inst
end

local function Stand()
    return _CommonIndicator({ bank = "poi_stand", build = "flint", anim = "idle" })
end


function StarIliadImportantScanTarget:AddIndicator()
    ThePlayer.HUD:AddTargetIndicator(self.inst, self.hud_data)
    self.add_indicator = true
end

function StarIliadImportantScanTarget:RemoveIndicator()
    ThePlayer.HUD:RemoveTargetIndicator(self.inst)
    self.add_indicator = false
end

function StarIliadImportantScanTarget:AddHeadMarker()
    self.stand = Stand()
    self.inst:AddChild(self.stand)

    self.marker = PrefabIndicator()
    self.marker.entity:AddFollower()

    self.marker.Follower:FollowSymbol(self.stand.GUID, "marker", 0, self.marker_height, 0)
end

function StarIliadImportantScanTarget:RemoveHeadMarker()
    if self.marker and self.marker:IsValid() then
        self.marker:Remove()
    end
    self.marker = nil

    if self.stand and self.stand:IsValid() then
        self.stand:Remove()
    end
    self.stand = nil
end

function StarIliadImportantScanTarget:OnEntitySleep() -- Master sim only.
    self.inst:StopUpdatingComponent(self)

    if ThePlayer and ThePlayer.HUD then
        if self.add_indicator then
            self:RemoveIndicator()
        end

        if self.stand then
            self:RemoveHeadMarker()
        end
    end
end

function StarIliadImportantScanTarget:OnEntityWake() -- Master sim only.
    self.inst:StartUpdatingComponent(self)
end

function StarIliadImportantScanTarget:IsInScreen()
    local w, h = TheSim:GetScreenSize()
    local u, v = TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())

    return u >= 0 and u < w and v >= 0 and v < h
end

function StarIliadImportantScanTarget:OnUpdate(dt)
    if not (ThePlayer and ThePlayer.HUD) then
        return
    end

    if not self.inst:IsNear(ThePlayer, self.max_dist) then
        self.reveal_time = 0
    elseif ThePlayer and ThePlayer:HasTag("blythe_skill_scan_pulse") then
        self.reveal_time = self.max_reveal_time
    else
        self.reveal_time = math.max(0, self.reveal_time - dt)
    end

    local is_in_screen = self:IsInScreen()
    if self.reveal_time > 0 then
        if not is_in_screen then
            if not self.add_indicator then
                self:AddIndicator()
            end
            if self.stand then
                self:RemoveHeadMarker()
            end
        else
            if self.add_indicator then
                self:RemoveIndicator()
            end

            if not self.stand then
                self:AddHeadMarker()
            end
        end
    else
        if self.add_indicator then
            self:RemoveIndicator()
        end
        if self.stand then
            self:RemoveHeadMarker()
        end
    end
end

function StarIliadImportantScanTarget:OnRemoveEntity()
    self.inst:StopUpdatingComponent(self)

    if ThePlayer and ThePlayer.HUD then
        if self.add_indicator then
            self:RemoveIndicator()
        end

        if self.stand then
            self:RemoveHeadMarker()
        end
    end
end

StarIliadImportantScanTarget.OnRemoveFromEntity = StarIliadImportantScanTarget.OnRemoveEntity


return StarIliadImportantScanTarget
