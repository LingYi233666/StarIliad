local function HasNotableCreatureNearby(x, y, z)
    local ents = TheSim:FindEntities(x, y, z, 4, nil, { "INLIMBO" }, { "player", "stariliad_necrons" })
    for _, v in pairs(ents) do
        if v and v:IsValid() and not IsEntityDeadOrGhost(v, true) then
            return true
        end
    end

    return false
end

local LIGHT_RADIUS_MAX = 1.5

local states =
{
    State {
        name = "idle_active",
        tags = { "idle" },

        onenter = function(inst)
            inst:EnableDust(false)
            inst:SetTallPhysics()

            inst.AnimState:PlayAnimation("idle_active")

            inst._light_radius:set(LIGHT_RADIUS_MAX)
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if not HasNotableCreatureNearby(x, y, z) then
                inst.sg:GoToState("lower")
            end
        end,
    },

    State {
        name = "idle_inactive",
        tags = { "idle" },

        onenter = function(inst)
            inst:EnableDust(false)
            inst:SetLowPhysics()

            inst.AnimState:PlayAnimation("idle_inactive")

            inst._light_radius:set(0)
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if HasNotableCreatureNearby(x, y, z) then
                inst.sg:GoToState("raise")
            end
        end,
    },


    State {
        name = "raise",
        tags = { "busy" },

        onenter = function(inst)
            inst:SetTallPhysics()

            inst.AnimState:PlayAnimation("raise")
            -- inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
            -- SpawnPrefab("sanity_raise").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        onupdate = function(inst)
            local percent = inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()
            local threshold = 0.6887
            if percent < threshold then
                inst._light_radius:set(0)
                return
            end

            local radius = Remap(percent, threshold, 1, 0, LIGHT_RADIUS_MAX)
            inst._light_radius:set(radius)
        end,

        timeline = {
            TimeEvent(0.6, function(inst)
                inst:EnableDust(true)
            end),

            TimeEvent(0.8, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
            end),

            TimeEvent(1.3, function(inst)
                inst:EnableDust(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_active")
            end),
        },
    },

    State {
        name = "lower",
        tags = { "busy" },

        onenter = function(inst)
            inst:EnableDust(true)
            inst:SetLowPhysics()
            inst.AnimState:PlayAnimation("lower")
            inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_down")

            -- SpawnPrefab("sanity_lower").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        onupdate = function(inst)
            local percent = inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()
            local threshold = 0.6734
            if percent > threshold then
                inst._light_radius:set(0)
                return
            end

            local radius = Remap(percent, 0, threshold, LIGHT_RADIUS_MAX, 0)
            inst._light_radius:set(radius)
        end,


        timeline = {
            TimeEvent(0.8, function(inst)
                inst:EnableDust(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle_inactive")
                end
            end),
        },
    },
}

return StateGraph("SGstariliad_necrons_obelisk", states, {}, "idle_inactive")
