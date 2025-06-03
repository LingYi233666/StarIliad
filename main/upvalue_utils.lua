StarIliadUpvalue = {}

function StarIliadUpvalue.Print(fn)
    local i = 1
    while debug.getupvalue(fn, i) do
        local name, value = debug.getupvalue(fn, i)
        print(i, name, value)
        i = i + 1
    end
end

local function GetUpvalueHelper(fn, name)
    local i = 1
    while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
        i = i + 1
    end
    local name, value = debug.getupvalue(fn, i)
    return value, i
end

function StarIliadUpvalue.Get(fn, ...)
    local prv, i, prv_var = nil, nil, "(the starting point)"
    for j, var in ipairs({ ... }) do
        assert(type(fn) == "function", "We were looking for " .. var .. ", but the value before it, "
            .. prv_var .. ", wasn't a function (it was a " .. type(fn)
            .. "). Here's the full chain: " .. table.concat({ "(the starting point)", ... }, ", "))
        prv = fn
        prv_var = var
        fn, i = GetUpvalueHelper(fn, var)
    end
    return fn, i, prv
end

local function FindAllChildren(fn)
    local i = 1
    local children = {}
    while true do
        local seg_name, seg_value = debug.getupvalue(fn, i)
        if not seg_name then
            break
        end
        table.insert(children, { seg_name, seg_value })
        i = i + 1
    end

    return children
end

function StarIliadUpvalue.GetRecursion(fn, name, max_depth, test_fn)
    max_depth = max_depth or 30

    local searched = {}
    local queue = { { "", fn, nil, 1 } }

    while #queue > 0 do
        local cur_name, cur_value, parent, cur_depth = unpack(table.remove(queue, 1))
        if cur_value == nil or not searched[cur_value] then
            if cur_value ~= nil then
                searched[cur_value] = true
            end

            -- print("Recursion:", cur_name, cur_value, parent, cur_depth)

            if cur_name == name and (test_fn == nil or test_fn(cur_name, cur_value, parent, cur_depth)) then
                return cur_value
            end

            if cur_depth >= max_depth then
                break
            end

            if type(cur_value) == "function" then
                local children = FindAllChildren(cur_value)
                for _, child in pairs(children) do
                    table.insert(queue, { child[1], child[2], cur_value, cur_depth + 1 })
                end
            end
        end
    end
end

function StarIliadUpvalue.Set(start_fn, new_fn, ...)
    local _fn, _fn_i, scope_fn = StarIliadUpvalue.Get(start_fn, ...)
    debug.setupvalue(scope_fn, _fn_i, new_fn)
end

---------------------------------------------------------------------------------------------
function StarIliadUpvalue.GetListenFns(listener, event, be_listened_guy)
    if not listener.event_listening then
        return
    end

    be_listened_guy = be_listened_guy or listener

    return listener.event_listening[event][be_listened_guy]
end

-- function StarIliadUpvalue.PrintListenFns(listener, event, be_listened_guy)
-- 	be_listened_guy = be_listened_guy or listener
-- 	for k, v in pairs(GetListenFns(listener, event, be_listened_guy)) do
-- 		print(k, listener, "is listening", be_listened_guy, "for event", event, "with fn", v)
-- 	end
-- end

GLOBAL.StarIliadUpvalue = StarIliadUpvalue
