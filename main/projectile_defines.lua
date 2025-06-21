STARILIAD_PROJECTILE_DEFINES = {
    {
        prefab = "blythe_beam_basic",
        sound = "stariliad_sfx/prefabs/blaster/beam_shoot",
        -- sound = "stariliad_sfx/prefabs/blaster/beam_shoot_samus",
        fx = "stariliad_pistol_shoot_cloud",
        attack_sg = "blythe_shoot_beam",
        -- shoot_at_sg = "blythe_shoot_beam2",
        -- castaoe_sg = "blythe_shoot_beam_castaoe",
        repeat_cast = true,
    },

    {
        prefab = "blythe_ice_fog",
        range = 8,
        attack_sg = "blythe_release_ice_fog2",
        -- castaoe_sg = "blythe_release_ice_fog_castaoe2",
        -- aoe_reject_fn = function(inst, action)
        --     if not TheNet:IsDedicated() and TheInput then
        --         local mouse_pos = TheInput:GetWorldPosition()
        --         SendModRPCToServer(MOD_RPC["stariliad_rpc"]["set_ice_fog_aoe_action_pos"], mouse_pos.x, mouse_pos.y,
        --             mouse_pos.z)

        --         inst:ForceFacePoint(DynamicPosition(mouse_pos):GetPosition())
        --     end

        --     if not TheWorld.ismastersim then
        --         return
        --     end

        --     if inst.sg.currentstate
        --         and inst.sg.currentstate.name == "blythe_release_ice_fog_castaoe2"
        --         and inst.sg.statemem.action
        --         and action.pos then
        --         inst.sg.statemem.action.pos = action.pos
        --     end
        -- end,
        -- repeat_cast = true,
        swap_build = "swap_blythe_blaster2",
    },

    {
        prefab = "blythe_beam_teleport",
        sound = "stariliad_sfx/prefabs/blaster/beam_shoot",
        fx = "stariliad_pistol_shoot_cloud",
        aim_reticule = "blythe_aim_reticule2",
        attack_sg = "blythe_shoot_beam",
        -- castaoe_sg = "blythe_shoot_beam_castaoe",
        -- shoot_at_sg = "blythe_shoot_beam_shoot_at",
        -- repeat_cast = true,
        -- enable_shoot_at = true, -- enable shoot at certain target, not attack
    },

    {
        prefab = "blythe_beam_swap",
        -- sound = "stariliad_sfx/prefabs/blaster/beam_shoot",
        -- sound = "stariliad_sfx/prefabs/blaster/swap_beam",
        sound = "stariliad_sfx/prefabs/blaster/teleport_beam",
        range = 10,
        fx = "stariliad_pistol_shoot_cloud",
        attack_sg = "blythe_shoot_beam",
        -- castaoe_sg = "blythe_shoot_beam_castaoe",
        -- shoot_at_sg = "blythe_shoot_beam_shoot_at",
        -- repeat_cast = true,
        -- enable_shoot_at = true, -- enable shoot at certain target, not attack
    },

    {
        prefab = "blythe_missile",
        sound = "stariliad_sfx/prefabs/blaster/beam_shoot2",
        fx = "stariliad_pistol_shoot_cloud",
        attack_sg = "blythe_shoot_missile",
        -- shoot_at_sg = "blythe_shoot_missile2",
        -- castaoe_sg = "blythe_shoot_missile_castaoe",
        -- repeat_cast = true,
        swap_build = "swap_blythe_blaster2",

        costs = {
            {
                can_cost = function(inst)
                    if inst.components.blythe_missile_counter then
                        return inst.components.blythe_missile_counter:GetNumMissiles() >= 1
                    end

                    if inst.replica.blythe_missile_counter then
                        return inst.replica.blythe_missile_counter:GetNumMissiles() >= 1
                    end
                end,

                apply_cost = function(inst)
                    if inst.components.blythe_missile_counter then
                        inst.components.blythe_missile_counter:DoDeltaNumMissiles(-1)
                    end
                end,
            },
        },
    },

    {
        prefab = "blythe_super_missile",
        sound = "stariliad_sfx/prefabs/blaster/beam_shoot2",
        fx = "stariliad_pistol_shoot_cloud",
        attack_sg = "blythe_shoot_missile",
        -- shoot_at_sg = "blythe_shoot_missile2",
        -- castaoe_sg = "blythe_shoot_missile_castaoe",
        -- repeat_cast = true,
        swap_build = "swap_blythe_blaster2",

        costs = {
            {
                can_cost = function(inst)
                    if inst.components.blythe_missile_counter then
                        return inst.components.blythe_missile_counter:GetNumSuperMissiles() >= 1
                    end

                    if inst.replica.blythe_missile_counter then
                        return inst.replica.blythe_missile_counter:GetNumSuperMissiles() >= 1
                    end
                end,

                apply_cost = function(inst)
                    if inst.components.blythe_missile_counter then
                        inst.components.blythe_missile_counter:DoDeltaNumSuperMissiles(-1)
                    end
                end,
            },
        },
    },
}

-- for _, v in pairs(STARILIAD_PROJECTILE_DEFINES) do
--     v.swap_build = v.swap_build or "swap_blythe_blaster"
-- end

GLOBAL.STARILIAD_PROJECTILE_DEFINES = STARILIAD_PROJECTILE_DEFINES
