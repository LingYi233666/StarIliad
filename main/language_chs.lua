-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.blythe = "星际游侠"
STRINGS.CHARACTER_NAMES.blythe = "布莱丝"
STRINGS.CHARACTER_DESCRIPTIONS.blythe = "*Perk 1\n*Perk 2\n*Perk 3"
STRINGS.CHARACTER_QUOTES.blythe = "\"真正的星际游侠会把《星辰史诗》 加入steam愿望单！\""

-- Custom speech strings  ----人物语言文件  可以进去自定义
STRINGS.CHARACTERS.BLYTHE = require "speech_blythe"

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.BLYTHE = "布莱丝"
STRINGS.SKIN_NAMES.blythe_none = "布莱丝" --检查界面显示的名字

--生存几率
STRINGS.CHARACTER_SURVIVABILITY.blythe = "简单"

STRINGS.NAMES.BLYTHE_BLASTER = "星际游侠爆能枪"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLYTHE_BLASTER = "这东西已经超出我所认知的科学的范畴了。"
STRINGS.CHARACTERS.BLYTHE.DESCRIBE.BLYTHE_BLASTER = "这是我最信赖的小手枪，能发射不同种类的弹药！"


STRINGS.ACTIONS.STARILIAD_SHOOT_AT = "射击"
-- STRINGS.ACTIONS.STARILIAD_OCEAN_LAND_JUMP = "跳"
STRINGS.ACTIONS.STARILIAD_OCEAN_LAND_JUMP = {
    TO_OCEAN = "下水行动",
    TO_LAND = "回到岸上",
}

STRINGS.ACTIONS.CASTAOE.BLYTHE_BLASTER = "射击"



--------------------- HUD ------------------------
STRINGS.STARILIAD_UI = {}

STRINGS.STARILIAD_UI.MAIN_MENU = {
    CALLER_TEXT = "菜单",
    SUB_TITLES = {
        POWERSUIT_DISPLAY = "状态",
        MAGIC_TAB = "魔法",
    },
}

STRINGS.STARILIAD_UI.POWERSUIT_CONFIGURE_WHEEL = {
    -- SELECTED = "（当前弹药）",
    -- ENABLED = "（已启用）",

    BASIC_BEAM = "光束",
    ICE_FOG = "冰雾",
    MISSILE = "导弹",
    SUPER_MISSILE = "超级导弹",
    USURPER_SHOT_TELEPORT = "夺位射击-抓取",
    USURPER_SHOT_SWAP = "夺位射击-互换",
    WIDE_BEAM = "宽光束-散射（开/关）",
    WAVE_BEAM = "波动光束-穿透障碍物（开/关）",
    PLASMA_BEAM = "等离子光束-穿透敌人（开/关）",
    SPEED_BURST = "速度推进器（开/关）",
}

STRINGS.STARILIAD_UI.BLYTHE_SKILL_TYPE_NAME = {
    ENERGY = "能量武器",
    KINETIC = "动能武器",
    SUIT = "强化服",
    MAGIC = "魔法",
}

STRINGS.STARILIAD_UI.SKILL_DETAIL = {
    BASIC_BEAM = {
        NAME = "光束",
        DESC = "能够使用星际游侠爆能枪发射光束，造成34力场伤害。",
    },

    ICE_FOG = {
        NAME = "冰雾",
        DESC = "能够使用星际游侠爆能枪连续喷出低温气体，冻结敌人。",
    },

    WIDE_BEAM = {
        NAME = "宽光束",
        DESC = "你的光束攻击能额外射出两条子光束，子光束的攻击力为主光束的25%。",
    },

    WAVE_BEAM = {
        NAME = "波动光束",
        DESC = "为你的光束攻击附加纯粹的异界能量，使其能穿透障碍物（此功能可在配置页面开关）。并且，光束的位面攻击力永久提升17点。",
    },

    PLASMA_BEAM = {
        NAME = "等离子光束",
        DESC = "为你的光束攻击附加强大的等离子体，使其能穿透敌人（此功能可在配置页面开关）。并且，光束的力场攻击力永久提升17点。",
    },

    USURPER_SHOT = {
        NAME = "夺位射击",
        DESC = "夺位射击是一种特殊的非杀伤性光束，它有两种工作模式。其中“夺位射击-抓取”能将远处的生物送至你身边，或是捡起远处的物品。“夺位射击-互换”能让你与目标互换位置。",
    },

    MISSILE = {
        NAME = "导弹",
        DESC = "能够使用星际游侠爆能枪发射一枚导弹，造成小范围100力场伤害。导弹的上限可以通过搜集导弹匣来提升。",
    },

    SUPER_MISSILE = {
        NAME = "超级导弹",
        DESC = "能够使用星际游侠爆能枪发射一枚超级导弹，造成中范围300力场伤害。超级导弹的上限可以通过搜集超级导弹匣来提升。",
    },

    SPEED_BURST = {
        NAME = "速度推进器",
        DESC = "沿着同一方向连续奔跑3秒后进入加速状态，对撞上的生物和物体造成大量破坏。速度推进器的功能可在配置页面开关。",
    },

    GRAVITY_CONTROL = {
        NAME = "重力控制器",
        DESC = "通过引力平衡你受到的阻力。可以在水中行动自如。",
    },
}
