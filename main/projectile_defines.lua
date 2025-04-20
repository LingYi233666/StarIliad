STARILIAD_PROJECTILE_DEFINES = {
    {
        prefab = "blythe_beam_basic",
        sound = "stariliad_sfx/prefabs/blaster/beam_shoot",
        fx = "stariliad_pistol_shoot_cloud",
        attack_sg = "blythe_shoot_beam",
        castaoe_sg = "blythe_shoot_beam_castaoe",
        repeat_cast = true,
    },

    {
        prefab = "blythe_beam_teleport",
        sound = "stariliad_sfx/prefabs/blaster/beam_shoot",
        fx = "stariliad_pistol_shoot_cloud",
        attack_sg = "blythe_shoot_beam",
        castaoe_sg = "blythe_shoot_beam_castaoe",
        shoot_at_sg = "blythe_shoot_beam_shoot_at",
        repeat_cast = true,
        enable_shoot_at = true, -- enable shoot at certain target, not attack
    },

    -- {
    --     prefab = "blythe_beam_swap",
    --     sound = "stariliad_sfx/prefabs/blaster/beam_shoot",
    --     fx = "stariliad_pistol_shoot_cloud",
    --     attack_sg = "blythe_shoot_beam",
    --     castaoe_sg = "blythe_shoot_beam_castaoe",
    --     shoot_at_sg = "blythe_shoot_beam_shoot_at",
    --     repeat_cast = true,
    --     enable_shoot_at = true, -- enable shoot at certain target, not attack
    -- },

    {
        prefab = "blythe_missile",
        sound = "stariliad_sfx/prefabs/blaster/beam_shoot2",
        fx = "stariliad_pistol_shoot_cloud",
        attack_sg = "blythe_shoot_missile",
        castaoe_sg = "blythe_shoot_missile_castaoe",
        repeat_cast = true,
    },
}


GLOBAL.STARILIAD_PROJECTILE_DEFINES = STARILIAD_PROJECTILE_DEFINES
