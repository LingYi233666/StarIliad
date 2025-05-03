local UIAnim = require "widgets/uianim"

local BlythePowersuitConfigure = Class(function(self, inst)
    self.inst = inst

    self._projectile_prefab = net_string(inst.GUID, "BlythePowersuitConfigure._projectile_prefab",
        "BlythePowersuitConfigure._projectile_prefab")
end)

local widget_scale = 0.6

local function EnabledIsValidFn(skill_name)
    local function fn()
        return ThePlayer and ThePlayer.replica.blythe_skiller and ThePlayer.replica.blythe_skiller:IsEnabled(skill_name)
    end

    return fn
end

local function ProjectilePrefabCheck(projectile_prefab)
    local function fn()
        return ThePlayer
            and ThePlayer.replica.blythe_powersuit_configure
            and ThePlayer.replica.blythe_powersuit_configure:GetProjectilePrefab() == projectile_prefab
    end

    return fn
end

local function AddCirclingRing(wheel_item, valid_fn, onupdatefn, toggle_on_sound, toggle_off_sound)
    wheel_item.ring = wheel_item:AddChild(UIAnim())
    wheel_item.ring:GetAnimState():SetBank("spell_icons_woby")
    wheel_item.ring:GetAnimState():SetBuild("spell_icons_woby")
    wheel_item.ring:GetAnimState():PlayAnimation("autocast_ring", true)
    wheel_item.ring:GetAnimState():Hide("frame_woby_0")
    wheel_item.ring.OnUpdate = function(ring, dt)
        local is_valid = valid_fn()
        if is_valid then
            ring:Show()
            wheel_item.overrideclicksound = toggle_off_sound or "dontstarve/HUD/toggle_off"
        else
            ring:Hide()
            wheel_item.overrideclicksound = toggle_on_sound or "dontstarve/HUD/toggle_on"
        end

        if onupdatefn then
            onupdatefn(wheel_item, ring, is_valid, dt)
        end
    end
    wheel_item.OnShow = function(w)
        w.ring:StartUpdating()
    end
    wheel_item.OnHide = function(w)
        w.ring:StopUpdating()
    end
    if wheel_item.shown then
        wheel_item.ring:StartUpdating()
        wheel_item.ring:OnUpdate(0)
    end
end

local function MakeAutoCastToggle(valid_fn)
    return function(w)
        -- SetupMouseOver(w)
        AddCirclingRing(w, valid_fn)
    end
end

local items_candidate = {
    {
        required_skill = "basic_beam",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.BASIC_BEAM,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["set_projectile_prefab"], "blythe_beam_basic")
        end,
        postinit = MakeAutoCastToggle(ProjectilePrefabCheck("blythe_beam_basic")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },

    {
        required_skill = "ice_fog",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.ICE_FOG,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["set_projectile_prefab"], "blythe_ice_fog")
        end,
        postinit = MakeAutoCastToggle(ProjectilePrefabCheck("blythe_ice_fog")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },

    {
        required_skill = "missile",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.MISSILE,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["set_projectile_prefab"], "blythe_missile")
        end,
        postinit = MakeAutoCastToggle(ProjectilePrefabCheck("blythe_missile")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },

    {
        required_skill = "usurper_shot",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.USURPER_SHOT_TELEPORT,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["set_projectile_prefab"], "blythe_beam_teleport")
        end,
        postinit = MakeAutoCastToggle(ProjectilePrefabCheck("blythe_beam_teleport")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },

    {
        required_skill = "usurper_shot",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.USURPER_SHOT_SWAP,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["set_projectile_prefab"], "blythe_beam_swap")
        end,
        postinit = MakeAutoCastToggle(ProjectilePrefabCheck("blythe_beam_swap")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },

    {
        required_skill = "wide_beam",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.WIDE_BEAM,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["switch_enable_skill"], "wide_beam")
            return true
        end,
        postinit = MakeAutoCastToggle(EnabledIsValidFn("wide_beam")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },

    {
        required_skill = "wave_beam",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.WAVE_BEAM,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["switch_enable_skill"], "wave_beam")
            return true
        end,
        postinit = MakeAutoCastToggle(EnabledIsValidFn("wave_beam")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },

    {
        required_skill = "plasma_beam",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.PLASMA_BEAM,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["switch_enable_skill"], "plasma_beam")
            return true
        end,
        postinit = MakeAutoCastToggle(EnabledIsValidFn("plasma_beam")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },

    {
        required_skill = "speed_burst",
        label = STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL.SPEED_BURST,
        execute = function(inst)
            SendModRPCToServer(MOD_RPC["stariliad_rpc"]["switch_enable_skill"], "speed_burst")
            return true
        end,
        postinit = MakeAutoCastToggle(EnabledIsValidFn("speed_burst")),
        bank = "spell_icons_willow",
        build = "spell_icons_willow",
        anims =
        {
            idle = { anim = "fire_throw" },
            focus = { anim = "fire_throw" },
            down = { anim = "fire_throw_pressed" },
        },
        widget_scale = widget_scale,
    },
}

for _, v in pairs(items_candidate) do
    if v.label == nil then
        v.label = "MISSING LABEL"
    end
end

function BlythePowersuitConfigure:SetProjectilePrefab(val)
    self._projectile_prefab:set(val)
end

function BlythePowersuitConfigure:GetProjectilePrefab()
    return self._projectile_prefab:value()
end

function BlythePowersuitConfigure:GetWheelData()
    local skiller = self.inst.replica.blythe_skiller
    assert(skiller ~= nil)

    local wheel_items = {}

    for _, v in pairs(items_candidate) do
        if skiller:IsLearned(v.required_skill) then
            table.insert(wheel_items, v)
        end
    end

    return wheel_items
end

function BlythePowersuitConfigure:TryOpenWheel()
    if ThePlayer.HUD.controls.spellwheel:IsOpen() then
        ThePlayer.HUD.controls.spellwheel:Close()
    else
        local wheel_items = self:GetWheelData()

        local items_cpy = {}
        for i, v in ipairs(wheel_items) do
            items_cpy[i] = shallowcopy(v)
            items_cpy[i].execute = function()
                return v.execute(self.inst)
            end
            items_cpy[i].postinit = v.postinit
            items_cpy[i].onfocus = function()
                for j, v in ipairs(wheel_items) do
                    v.selected = i == j or nil
                end
            end
        end
        ThePlayer.HUD.controls.spellwheel:SetScale(TheFrontEnd:GetProportionalHUDScale()) --instead of GetHUDScale(), because parent already has SCALEMODE_PROPORTIONAL
        ThePlayer.HUD.controls.spellwheel:SetItems(items_cpy, 140, 144)
        ThePlayer.HUD.controls.spellwheel:Open()
    end
end

return BlythePowersuitConfigure
