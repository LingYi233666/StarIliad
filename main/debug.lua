StarIliadDebug = {}

function StarIliadDebug.SetDebugInventoryImage(inst)
    if not inst.components.inventoryitem then
        inst:AddComponent("inventoryitem")
    end

    inst.components.inventoryitem.imagename = "stariliad_debug_inventoryimage"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_debug_inventoryimage.xml"
end

function StarIliadDebug.PrintStackTrace()
    print("--- Stack Trace ---")
    for level = 1, 100 do                       -- 从级别 1 开始往上查找
        local info = debug.getinfo(level, "nS") -- 获取名称和源信息
        if not info then
            break                               -- 没有更多堆栈帧了
        end
        local name = info.name or "匿名/未知"
        local source = info.short_src or info.source or "未知源"
        local line = info.currentline or info.linedefined or "未知行"
        local what = info.what -- "Lua", "C", "main"
        print(string.format("Level %d: %s [%s:%s] (%s)", level, name, source, line, what))
    end
    print("--- End Stack Trace ---")
end

-- print(StarIliadDebug.GetTargetScreenPos(ThePlayer))
-- print(StarIliadDebug.GetTargetScreenPos(c_findnext("dummytarget")))
function StarIliadDebug.GetTargetScreenPos(target)
    local x, y, z = target.Transform:GetWorldPosition()
    local x2, y2 = TheSim:GetScreenPos(x, y, z)

    return x2, y2
end

StarIliadDebug.LOREM_ENG =
[=[English Lorem: ipsum dolor sit amet consectetur adipisicing elit. Omnis vitae corporis labore perspiciatis nam laboriosam, saepe, autem veritatis vel nihil ut, quibusdam aliquam quo minus! Dicta dolor ab repellat vel excepturi eos ad optio a iusto consequatur fugit cumque sint pariatur velit quidem assumenda quaerat suscipit autem omnis ipsa, voluptas molestiae? Iure, provident maiores libero doloremque a quibusdam dolorum at suscipit officia aperiam consectetur temporibus voluptatem ex, et sequi ad voluptate ipsam, quisquam soluta! Eaque accusamus recusandae impedit reiciendis, esse quasi debitis architecto doloribus distinctio asperiores facilis ullam nihil aliquid in nam itaque dolor quo dolorum, pariatur ratione. Doloribus, dolorem!]=]

StarIliadDebug.LOREM_CHS =
[=[中文假文：我韩他场，与决小欲和低若关尘风思才评手时助，商法秦创开六收夫德，临实太人幕太则锐幕了可国呼承，勇德皇低憾，其如在国叹韩，导互定气间郭己到，韩许面属人俭，纯老领，后上呼老知，躲春拆九秦了俭文人秦予，就本此我太重孔时心一招被台卞次五同诗弄，榜价求惊从临话友两无承曰是忧惜，国李云人只之为策是舟下杨在无兴二忧，出严不力友马知娘我，的许守找分愿人，是洪前卑馆拢云太人下疾能才郭气，舟病见与订九创今九德从为落，丈皇不徒灰人耐，言国笔我非此者郭兴就王落不法太罪而你郭，羊斯救，领云的灰况，密张我卑己航老反无谓游临，定也清以，么问是，不设活皇韩善认通回为服应三未低服里看就，姑以书司头，要才玉助将婵是是重朗人国天把，判法廿一人，派仑价哉谓，谓没视与雷仁地行年曾金，训定这接普失赐使为收书穿不夫领有，可叹毒下兼上登下恼，内付到会上非生人着这王起也苦，是同慧也如后畴人少人，等牛足二如来处切才，导样后宋能能量作胜下后以哥没九友破将互，鲜言自杨化皇不何里考者怒可娘风，下定也面派你非奔快姑亡们，极许司制千名因远担三没非慧没等，人文来不说畴找尺不，故案上书收求在哉身以皇，都知家老听，雷关陈念大讨身后杨洪亓仓拢匹，人则知人服定今脱洪帝王曾娇他，会春叹磊而谓风上为土死逝联案，命罪如太商，而传面都就的、，不穿都归放，劫评就哉，否又的极看案处惊到的丰她，文后着大请笔太皇衣却德之找血商，乐如快，在怎应而中，守国普在。]=]

StarIliadDebug.LOREM =
"这是一段额外的文本，用来确保我们达到所需的长度。无论是英文还是中文，每一个字符都同等重要。再来点：Lorem ipsum dolor sit amet, consectetur adipiscing elit。 Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua? Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat! 最后的中文填充，确保总数接近六百。请注意标点符号也计入总数，比如问号和感叹号。Lorem ipsum dolor sit amet, 再来点中文！ consectetur adipiscing elit. 假文就是这样。 Sed do eiusmod tempor incididunt. 混合填充完成。 Ut labore et dolore magna aliqua. 检查总数。足够六百字符了。 Lorem ipsum！ 最后。"

function GLOBAL.si_skill(name)
    if not ThePlayer.components.blythe_skiller:IsLearned(name) then
        ThePlayer.components.blythe_skiller:Learn(name)
    end
end

-- si_allskills()
function GLOBAL.si_allskills()
    for _, v in pairs(BLYTHE_SKILL_DEFINES) do
        if not ThePlayer.components.blythe_skiller:IsLearned(v.name) then
            ThePlayer.components.blythe_skiller:Learn(v.name)
        end
    end
end

function GLOBAL.si_missile(count)
    if ThePlayer.components.blythe_missile_counter then
        ThePlayer.components.blythe_missile_counter:SetNumMissiles(count)
    end
end

function GLOBAL.si_super_missile(count)
    if ThePlayer.components.blythe_missile_counter then
        ThePlayer.components.blythe_missile_counter:SetNumSuperMissiles(count)
    end
end

-- si_rightclick()
function GLOBAL.si_rightclick(delay)
    delay = delay or 1

    ThePlayer:DoTaskInTime(delay, function()
        local act = ThePlayer.components.playercontroller:GetRightMouseAction()
        print("act is:", act)

        local position = TheInput:GetWorldPosition()
        local mouseover = TheInput:GetWorldEntityUnderMouse()

        local controlmods = ThePlayer.components.playercontroller:EncodeControlMods()
        local platform, pos_x, pos_z = ThePlayer.components.playercontroller:GetPlatformRelativePosition(position.x,
            position.z)

        SendRPCToServer(RPC.RightClick,
            act.action.code,
            pos_x,
            pos_z,
            mouseover,
            act.rotation ~= 0 and act.rotation or nil,
            nil,
            controlmods,
            act.action.canforce,
            act.action.mod_name,
            platform,
            platform ~= nil)
    end)
end

-- si_right_actions(Vector3(-530,0,94))
function GLOBAL.si_right_actions(pos)
    local actions = {}
    local useitem = ThePlayer.components.combat:GetWeapon()
    useitem:CollectActions("POINT", ThePlayer, pos, actions, true)

    for _, v in pairs(actions) do
        print(v, v.code, v.mod_name)
    end
end

-- si_circle_rocks()
-- si_circle_rocks(10, 5)
function GLOBAL.si_circle_rocks(radius, step, pos)
    radius = radius or 10
    step = step or 5
    pos = pos or ThePlayer:GetPosition()

    local num_steps = math.floor(360 / step)
    for i = 1, num_steps do
        local angle = (i * step) * DEGREES
        local offset = Vector3FromTheta(angle, radius)

        SpawnAt("rock1", pos, nil, offset)
    end
end

-- GetWorldTileMap()
-- si_tile(WORLD_TILES.STARILIAD_ALIEN_RUINS_SLAB)
function GLOBAL.si_tile(tile, x, y, z)
    if x == nil or y == nil or z == nil then
        x, y, z = ConsoleWorldPosition():Get()
    end

    local tile_x, tile_y = TheWorld.Map:GetTileCoordsAtPoint(x, y, z)

    TheWorld.Map:SetTile(tile_x, tile_y, tile)
end

-- si_lightning_storm()
function GLOBAL.si_lightning_storm(enable)
    local cmp = TheWorld.components.stariliad_weather_lightning_storm
    if not cmp then
        print("No lightning storm component !")
        return
    end

    if enable == true or enable == nil then
        cmp:StartWeather()
    elseif enable == false then
        cmp:StopWeather()
    end
end

function GLOBAL.si_falling_star(num)
    TheWorld:StartThread(function()
        for i = 1, num or 10 do
            local pos = ThePlayer:GetPosition() + Vector3FromTheta(math.random() * PI2, GetRandomMinMax(2, 20))
            SpawnAt("stariliad_falling_star", pos):DoFalling()
            Sleep(GetRandomMinMax(0.1, 3))
        end
    end)
end

function GLOBAL.si_layout(name, pos)
    pos = pos or ConsoleWorldPosition()
    StarIliadLayout.Spawn(name, pos)
end

GLOBAL.StarIliadDebug = StarIliadDebug
