-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.blythe = "星际游侠"
STRINGS.CHARACTER_NAMES.blythe = "布莱丝"
STRINGS.CHARACTER_DESCRIPTIONS.blythe = "*\n*擅长射击和魔法\n*讨厌粗糙的工具"
STRINGS.CHARACTER_QUOTES.blythe = "\"真正的星际游侠会把《星辰史诗》 加入steam愿望单！\""

-- Custom speech strings  ----人物语言文件  可以进去自定义
STRINGS.CHARACTERS.BLYTHE = require "speech_blythe"

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.BLYTHE = "布莱丝"
STRINGS.SKIN_NAMES.blythe_none = "布莱丝" --检查界面显示的名字

--生存几率
STRINGS.CHARACTER_SURVIVABILITY.blythe = "简单"

STRINGS.NAMES.BLYTHE_BLASTER = "魔法枪"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLYTHE_BLASTER = "这东西已经超出我所认知的科学的范畴了。"
STRINGS.CHARACTERS.BLYTHE.DESCRIBE.BLYTHE_BLASTER = "值得信赖的小手枪，能发射不同种类的弹药！"

STRINGS.NAMES.STARILIAD_ALIEN_STATUE_NORMAL_CHOZO = "神族雕像"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.STARILIAD_ALIEN_STATUE_NORMAL_CHOZO = "一尊未知种族的雕像。"
STRINGS.CHARACTERS.BLYTHE.DESCRIBE.STARILIAD_ALIEN_STATUE_NORMAL_CHOZO = "鸟人族曾经在宇宙的各个角落留下这种雕像。"

STRINGS.NAMES.STARILIAD_ALIEN_STATUE_BROKEN_CHOZO = "上古神族雕像"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.STARILIAD_ALIEN_STATUE_BROKEN_CHOZO = "已经无法辨认它原本的模样了。"
STRINGS.CHARACTERS.BLYTHE.DESCRIBE.STARILIAD_ALIEN_STATUE_BROKEN_CHOZO = "这尊鸟人雕像更加古老。"


STRINGS.NAMES.BLYTHE_UNLOCK_SKILL_ITEM = "神秘球体"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLYTHE_UNLOCK_SKILL_ITEM = "这东西很神秘。"
STRINGS.CHARACTERS.BLYTHE.DESCRIBE.BLYTHE_UNLOCK_SKILL_ITEM = "它迫不及待地想要和我融合。"

STRINGS.NAMES.BLYTHE_UNLOCK_SKILL_ITEM_ENCRYPTED = "上古球体"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLYTHE_UNLOCK_SKILL_ITEM_ENCRYPTED = "这东西既复杂又神秘。"
STRINGS.CHARACTERS.BLYTHE.DESCRIBE.BLYTHE_UNLOCK_SKILL_ITEM_ENCRYPTED = "一定有某种方法能解析它。"

STRINGS.NAMES.BLYTHE_UNLOCK_SKILL_ITEM_MISSILE = "导弹柜"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLYTHE_UNLOCK_SKILL_ITEM_MISSILE = "盒中信号弹？"
STRINGS.CHARACTERS.BLYTHE.DESCRIBE.BLYTHE_UNLOCK_SKILL_ITEM_MISSILE = "太好了！是导弹柜！"

STRINGS.NAMES.BLYTHE_UNLOCK_SKILL_ITEM_SUPER_MISSILE = "超级导弹柜"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLYTHE_UNLOCK_SKILL_ITEM_SUPER_MISSILE = "盒中大只信号弹？"
STRINGS.CHARACTERS.BLYTHE.DESCRIBE.BLYTHE_UNLOCK_SKILL_ITEM_SUPER_MISSILE = "太好了！是超级导弹柜！"

STRINGS.ACTIONS.STARILIAD_SHOOT_AT = "射击"
-- STRINGS.ACTIONS.STARILIAD_OCEAN_LAND_JUMP = "跳"
STRINGS.ACTIONS.STARILIAD_OCEAN_LAND_JUMP = {
    TO_OCEAN = "下水行动",
    TO_LAND = "回到岸上",
}

STRINGS.ACTIONS.CASTAOE.BLYTHE_BLASTER = "射击"

-- STRINGS.ACTIONS.BLYTHE_UNLOCK_SKILL = {
--     LEARNED = "我已经知晓这个技能了。"
-- }

STRINGS.ACTIONS.BLYTHE_UNLOCK_SKILL = "解析"

STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.BLYTHE_UNLOCK_SKILL = {
    LEARNED = "我已经知晓这个技能了。",
    MISSILE_THRESHOLD = "导弹容量最大值已经达到上限，没法再提升了。",
    SUPER_MISSILE_THRESHOLD = "超级导弹容量最大值已经达到上限，没法再提升了。",
}

--------------------- HUD ------------------------
STRINGS.STARILIAD_UI = {}

STRINGS.STARILIAD_UI.MAIN_MENU = {
    CALLER_TEXT = "菜单",
    SUB_TITLES = {
        POWERSUIT_DISPLAY = "状态",
        MAGIC_TAB = "魔法",
    },
}

STRINGS.STARILIAD_UI.MAGIC_TAB = {
    KEY_CONFIG = "设置键位",
}

STRINGS.STARILIAD_UI.KEY_CONFIG_DIALOG = {
    TITLE = "设置键位",
    TEXT_BEFORE = "请按下对应的键位后再按确定来完成键位设置。\n不仅仅是键盘按键，鼠标中键或者侧键也可以进行设置哦！",
    TEXT_AFTER = "当前选的按键是：%s。您可以点击确定键完成键位设置，或者重新选择按键。",

    DO_SET_SKILL_KEY = "确定",
    CLEAR_SKILL_KEY = "清除按键",
    SET_KEY_CANCEL = "取消"
}

STRINGS.STARILIAD_UI.ITEM_ACQUIRED = {
    FOUND = "获得了%s",
    ENCRYPTED = {
        TITLE = "不明装备",
        DESC = "分析无结果，此装备不适用于当前装甲。",
    },
    CHALLENGE = {
        TITLE = "获得了战神赐福",
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

STRINGS.STARILIAD_UI.BLYTHE_MISSILE_STATUS = {
    MISSILE = "导弹数量",
    SUPER_MISSILE = "超级导弹数量",
}

STRINGS.STARILIAD_UI.SKILL_DETAIL = {
    BASIC_BEAM = {
        NAME = "光束",
        DESC = "能够使用魔法枪发射光束，造成34伤害。强大的生物对光束具有抗性。",
        -- DESC = "能够使用魔法枪发射光束，造成34伤害。",
    },

    ICE_FOG = {
        NAME = "冰雾",
        DESC = "能够使用魔法枪连续喷出低温气体，冻结敌人。",
    },

    -- 猪王树林群系 "Speak to the king"
    WIDE_BEAM = {
        NAME = "宽光束",
        DESC = "你的光束攻击能额外射出两条子光束（此功能可在调整轮盘页面里进行开关），每根子光束的攻击力均为主光束的25%。",
    },

    -- 苔藓地群系 "LichenLand"
    WAVE_BEAM = {
        NAME = "波动光束",
        DESC = "为你的光束攻击附加纯粹的异界能量，使其能穿透障碍物（此功能可在调整轮盘页面里进行开关）。并且，光束的位面攻击力永久提升17点。",
    },

    -- 远古档案馆群系 "ArchiveMaze"
    -- 需要额外挑战解码
    PLASMA_BEAM = {
        NAME = "等离子光束",
        DESC = "为你的光束攻击附加强大的等离子体，使其能穿透敌人（此功能可在调整轮盘页面里进行开关）。并且，光束的攻击力永久提升17点。",
    },

    -- 海象森林群系 "Forest hunters"
    -- or
    -- 曼德拉草森林群系 "For a nice walk"
    USURPER_SHOT = {
        NAME = "夺位射击",
        DESC = "能够使用魔法枪进行夺位射击。夺位射击能射出两种特殊的非杀伤性光束，其中“夺位射击-抓取”能将远处的生物送至你身边，或是捡起远处的物品。“夺位射击-互换”能让你与目标互换位置。",
    },

    -- 混合地群系 "Dig that rock"
    MISSILE = {
        NAME = "导弹",
        DESC = "能够使用魔法枪发射一枚导弹，造成小范围120伤害并摧毁周围的建筑。导弹的上限可以通过搜集导弹柜来提升。",
    },

    -- 石虾地群系 "RockyLand"
    -- or
    -- 蛛网岩洞穴群系 "SpillagmiteCaverns"
    SUPER_MISSILE = {
        NAME = "超级导弹",
        DESC = "能够使用魔法枪发射一枚超级导弹，造成中范围300伤害并摧毁周围的建筑。超级导弹的上限可以通过搜集超级导弹柜来提升。",
    },

    -- Deprecated
    -- 原本打算用这个致敬毁灭战士的B.F.G.的，但是UI里塞不下新的技能框了。
    -- BIG_FUCKING_MISSILE = {
    --     NAME = "B.F.M.",
    --     DESC = "能够使用魔法枪发射一枚毁灭飞矢，造成大范围3000伤害。每隔5天才能发射一发。",
    -- },

    -- 击败远古守护者获得
    SPEED_BURST = {
        NAME = "速度推进器",
        DESC = "沿着同一方向连续奔跑3秒后进入加速状态，对撞上的生物和物体造成大量破坏。速度推进器的功能可在调整轮盘页面里进行开关。",
    },

    -- 红蘑菇森林群系 "RedForest"
    -- 需要额外挑战解码
    GRAVITY_CONTROL = {
        NAME = "重力控制器",
        DESC = "通过引力平衡你受到的阻力。可以在水中行动自如。",
    },

    CONFIGURE_POWERSUIT = {
        NAME = "调整装备",
        DESC = "打开一个设置轮盘，在轮盘中，你可以切换魔法枪使用的弹药，或是开关某些特殊能力。",
    },

    PARRY = {
        NAME = "拨挡攻击",
        DESC = "进行一次快速的格挡。如果你成功挡下了一次攻击，则你可以马上使用魔法枪的光束发动一次强力反击。\n*被反击的生物会掉落导弹补给。",
    },

    -- 月岛浴场群系 "MoonIsland_Baths"
    STEALTH = {
        NAME = "幻影斗篷",
        DESC = "进入隐形状态，躲避敌人，在使用期间会持续消耗饥饿值。如果在隐形时发动攻击或是进行其他工作，角色会短暂暴露，并额外消耗一些饥饿值。",
    },

    -- 大沼泽群系 "Squeltch"
    DODGE = {
        NAME = "闪光转移",
        DESC = "瞬间向鼠标所指方向高速移动一段距离。可以连续使用两次。",
    },

    -- 泥泞光照区群系 "MudLights"
    SCAN = {
        NAME = "脉冲雷达",
        DESC = "消耗些许饥饿值，使用脉冲雷达扫描周围的地形，周期性揭示半径60码内的地图，持续10秒。\n*脉冲可以迫使隐形的生物显形。",
    },

    UNKNOWN = {
        NAME = "未知技能",
        DESC = "这个技能需要你自己去探寻。",
    },
}
