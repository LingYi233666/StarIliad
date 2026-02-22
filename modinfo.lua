name = "恩苏计划：星辰史诗外传" ---mod名字
description = "星际游侠迷失于行星SR114！" --mod描述
author = "灵衣女王的鬼铠" --作者
version = "0.0.3" -- mod版本 上传mod需要两次的版本不一样

forumthread = ""

api_version = 10                   --api版本

dst_compatible = true              --兼容联机

dont_starve_compatible = false     --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

all_clients_require_mod = true     --所有人mod

icon_atlas = "modicon.xml"         --mod图标
icon = "modicon.tex"

server_filter_tags = { --服务器标签
    "character",
}


configuration_options = {
    {
        name = "damage_number",
        label = "伤害数值显示",
        options =
        {
            { description = "开", data = true },
            { description = "关", data = false },
        },
        default = true,
    },

    {
        name = "tips",
        label = "新手教学",
        options =
        {
            { description = "开", data = true },
            { description = "关", data = false },
        },
        default = true,
    },

    {
        name = "blythe_tv",
        label = "小电视UI",
        options =
        {
            { description = "开", data = true },
            { description = "关", data = false },
        },
        default = true,
    },

    -- {
    --     name = "difficulty",
    --     label = "难度",
    --     options =
    --     {
    --         { description = "新手奶爸", data = 1 },
    --         { description = "饶我一命", data = 2 },
    --         { description = "中规中矩", data = 3 },
    --         { description = "艰难险阻", data = 4 },
    --         { description = "金属之王", data = 5 },
    --     },
    --     default = 3,
    -- },

    -- {
    --     name = "play_skill_learned_anim",
    --     label = "技能学习动画",
    --     options =
    --     {
    --         { description = "播放", data = true },
    --         { description = "不播放", data = false },
    --     },
    --     default = true,
    -- },

    -- {
    --     name = "dodge_direction",
    --     label = "冲刺方向",
    --     options =
    --     {
    --         { description = "鼠标所指方向", data = 1 },
    --         { description = "艾希面朝方向", data = 2 },
    --     },
    --     default = 1,
    -- },

    -- {
    --     name = "parry_direction",
    --     label = "格挡时角色朝向",
    --     options =
    --     {
    --         { description = "鼠标所指方向", data = 1 },
    --         { description = "艾希面朝方向", data = 2 },
    --     },
    --     default = 1,
    -- },
} --mod设置

if locale == "zh" or locale == "zhr" or locale == "zht" then
    -- Do nothing
else
    name = "Project En-Zu: Star Iliad Side Story"
    description = "Star Ranger Stranded on Planet SR114!"

    configuration_options[1].label = "Damage Numbers"
    configuration_options[1].options[1].description = "On"
    configuration_options[1].options[2].description = "Off"

    configuration_options[2].label = "Tutorial"
    configuration_options[2].options[1].description = "On"
    configuration_options[2].options[2].description = "Off"

    configuration_options[3].label = "Blythe TV UI"
    configuration_options[3].options[1].description = "On"
    configuration_options[3].options[2].description = "Off"


    -- {
    --     name = "damage_number",
    --     label = "伤害数值显示",
    --     options =
    --     {
    --         { description = "开", data = true },
    --         { description = "关", data = false },
    --     },
    --     default = true,
    -- },

    -- {
    --     name = "tips",
    --     label = "新手教学",
    --     options =
    --     {
    --         { description = "开", data = true },
    --         { description = "关", data = false },
    --     },
    --     default = true,
    -- },

    -- {
    --     name = "blythe_tv",
    --     label = "小电视UI",
    --     options =
    --     {
    --         { description = "开", data = true },
    --         { description = "关", data = false },
    --     },
    --     default = true,
    -- },
end
