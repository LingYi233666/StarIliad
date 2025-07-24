local function HandleEnableByComponent(cmp_name)
    local function fn(inst, enable, is_onload)
        inst.components[cmp_name]:Enable(enable, is_onload)
    end

    return fn
end

local function CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    local cmp = inst.components[cmp_name]

    if cmp then
        local can_cast, reason = cmp:CanCast(x, y, z, ent)

        if can_cast then
            cmp:Cast(x, y, z, ent)
        else
            print(cmp_name .. " cast failed, reason: " .. tostring(reason))
        end
    end
end

local function CastSkillByComponentWrapper(cmp_name)
    local function fn(inst, x, y, z, ent)
        CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    end

    return fn
end


BLYTHE_SKILL_TYPE = {
    ENERGY = "ENERGY",
    KINETIC = "KINETIC",
    SUIT = "SUIT",
    MAGIC = "MAGIC",
}

STARILIAD_ALIEN_STATUE_TYPE = {
    NORMAL_CHOZO = "NORMAL_CHOZO",
    BROKEN_CHOZO = "BROKEN_CHOZO",
    ALTAR = "ALTAR",
    MERMAID = "MERMAID",
    -- CUSTOM = "CUSTOM",
}

BLYTHE_SKILL_DEFINES = {
    -- ENERGY
    {
        name = "basic_beam",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
        root = true,
    },

    {
        name = "ice_fog",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
        root = true,
    },

    {
        name = "wide_beam",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
        statue_type = STARILIAD_ALIEN_STATUE_TYPE.NORMAL_CHOZO,
    },

    {
        name = "wave_beam",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
        statue_type = STARILIAD_ALIEN_STATUE_TYPE.NORMAL_CHOZO,
    },

    {
        name = "plasma_beam",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
        statue_type = STARILIAD_ALIEN_STATUE_TYPE.BROKEN_CHOZO,
        -- Unlock item params
        encrypted = true,
    },

    {
        name = "usurper_shot",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
        statue_type = STARILIAD_ALIEN_STATUE_TYPE.NORMAL_CHOZO,
    },

    -- KINETIC
    {
        name = "missile",
        dtype = BLYTHE_SKILL_TYPE.KINETIC,
        statue_type = STARILIAD_ALIEN_STATUE_TYPE.ALTAR,

        -- Unlock item params
        bank = "blythe_missile_tank",
        build = "blythe_missile_tank",
        anim = "normal",
        -- stack_size = TUNING.STACK_SIZE_LARGEITEM,
        teach_override = function(inst, player)
            if not inst.components.blythe_unlock_skill:IsLearnedMySkill(player) then
                return
            end

            if not player.components.blythe_missile_counter then
                return false
            end

            local max_num_missiles = player.components.blythe_missile_counter:GetMaxNumMissiles()

            local increase_count = math.min(TUNING.BLYTHE_MISSILE_COUNT_THRESHOLD - max_num_missiles,
                TUNING.BLYTHE_MISSILE_COUNT_UPGRADE)

            local recipe_names = {
                "blythe_unlock_skill_item_missile_plan1",
                "blythe_unlock_skill_item_missile_plan2",
                "blythe_unlock_skill_item_missile_plan3",
                "blythe_unlock_skill_item_missile_plan4"
            }
            StarIliadBasic.TeachRecipes(player, recipe_names)

            if increase_count <= 0 then
                return false, "MISSILE_THRESHOLD"
            end

            player.components.blythe_missile_counter:SetMaxNumMissiles(max_num_missiles + increase_count)
            player.components.blythe_missile_counter:DoDeltaNumMissiles(TUNING.BLYTHE_MISSILE_COUNT_UPGRADE)

            SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["missile_status_spawn_fx"], player.userid, false)

            StarIliadBasic.RemoveOneItem(inst)

            return true
        end,
    },

    {
        name = "super_missile",
        dtype = BLYTHE_SKILL_TYPE.KINETIC,
        statue_type = STARILIAD_ALIEN_STATUE_TYPE.ALTAR,

        -- Unlock item params
        bank = "blythe_missile_tank",
        build = "blythe_missile_tank",
        anim = "super",
        -- stack_size = TUNING.STACK_SIZE_LARGEITEM,
        teach_override = function(inst, player)
            if not inst.components.blythe_unlock_skill:IsLearnedMySkill(player) then
                return
            end

            if not player.components.blythe_missile_counter then
                return false
            end

            local max_num_super_missiles = player.components.blythe_missile_counter:GetMaxNumSuperMissiles()

            local increase_count = math.min(TUNING.BLYTHE_SUPER_MISSILE_COUNT_THRESHOLD - max_num_super_missiles,
                TUNING.BLYTHE_SUPER_MISSILE_COUNT_UPGRADE)

            local recipe_names = {
                "blythe_unlock_skill_item_super_missile_plan1",
                "blythe_unlock_skill_item_super_missile_plan2",
                "blythe_unlock_skill_item_super_missile_plan3",
                "blythe_unlock_skill_item_super_missile_plan4"
            }
            StarIliadBasic.TeachRecipes(player, recipe_names)

            if increase_count <= 0 then
                return false, "SUPER_MISSILE_THRESHOLD"
            end

            player.components.blythe_missile_counter:SetMaxNumSuperMissiles(max_num_super_missiles + increase_count)
            player.components.blythe_missile_counter:DoDeltaNumSuperMissiles(TUNING
                .BLYTHE_SUPER_MISSILE_COUNT_UPGRADE)

            SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["missile_status_spawn_fx"], player.userid, true)

            StarIliadBasic.RemoveOneItem(inst)

            return true
        end,
    },

    -- {
    --     name = "big_fucking_missile",
    --     dtype = BLYTHE_SKILL_TYPE.KINETIC,
    -- },

    -- SUIT
    {
        name = "speed_burst",
        handle_enable = HandleEnableByComponent("blythe_skill_speed_burst"),

        dtype = BLYTHE_SKILL_TYPE.SUIT,
        -- statue_type = STARILIAD_ALIEN_STATUE_TYPE.NORMAL_CHOZO,
        -- Add unlock item to minotaur treasure
    },

    {
        name = "gravity_control",
        -- handle_enable = HandleEnableByComponent("blythe_skill_speed_burst"),

        dtype = BLYTHE_SKILL_TYPE.SUIT,
        statue_type = STARILIAD_ALIEN_STATUE_TYPE.BROKEN_CHOZO,


        -- Unlock item params
        encrypted = true,
    },

    -- MAGIC
    {
        name = "configure_powersuit",
        dtype = BLYTHE_SKILL_TYPE.MAGIC,

        root = true,

        default_key = 1006, --"Mouse Button 5",

        on_pressed_client = function(inst)
            if inst.replica.blythe_powersuit_configure then
                inst.replica.blythe_powersuit_configure:TryOpenWheel()
            end
        end,
    },

    {
        name = "parry",
        dtype = BLYTHE_SKILL_TYPE.MAGIC,

        root = true,

        default_key = 1005, --"Mouse Button 4",

        on_pressed_client = function(inst, x, y, z)
            if inst.replica.blythe_skill_parry and inst.replica.blythe_skill_parry:CanCast(x, y, z) then
                inst.replica.blythe_skill_parry:Cast(x, y, z)
            end
        end,

        -- on_pressed = CastSkillByComponentWrapper("blythe_skill_parry")
    },

    {
        name = "stealth",
        dtype = BLYTHE_SKILL_TYPE.MAGIC,

        on_pressed = CastSkillByComponentWrapper("blythe_skill_stealth")
    },

    {
        name = "dodge",
        dtype = BLYTHE_SKILL_TYPE.MAGIC,

        -- root = true,

        -- default_key = 1002, --"Middle Mouse Button",

        on_pressed = CastSkillByComponentWrapper("blythe_skill_dodge")
    },

    {
        name = "scan",
        dtype = BLYTHE_SKILL_TYPE.MAGIC,

        on_pressed = CastSkillByComponentWrapper("blythe_skill_scan")
    },
}

-- Test
-- for i = 1, 60 do
--     table.insert(BLYTHE_SKILL_DEFINES, {
--         name = "test_" .. tostring(i),
--         dtype = BLYTHE_SKILL_TYPE.MAGIC,
--     })
-- end


GLOBAL.BLYTHE_SKILL_TYPE = BLYTHE_SKILL_TYPE
GLOBAL.BLYTHE_SKILL_DEFINES = BLYTHE_SKILL_DEFINES
