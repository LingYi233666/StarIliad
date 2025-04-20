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

GLOBAL.StarIliadDebug = StarIliadDebug
