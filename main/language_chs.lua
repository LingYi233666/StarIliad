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
STRINGS.ACTIONS.CASTAOE.BLYTHE_BLASTER = "射击"



--------------------- HUD ------------------------
STRINGS.STARILIAD_UI = {}

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
