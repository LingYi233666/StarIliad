StarIliadUpvalue = {}


local function GetUpvalueHelper(fn, name)
    local i = 1
    while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
        i = i + 1
    end
    local name, value = debug.getupvalue(fn, i)
    return value, i
end

function StarIliadUpvalue.PrintUpvalue(fn)
    local i = 1
    while debug.getupvalue(fn, i) do
        local name, value = debug.getupvalue(fn, i)
        print(i, name, value)
        i = i + 1
    end
end

function StarIliadUpvalue.GetUpvalue(fn, ...)
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

function StarIliadUpvalue.SetUpvalue(start_fn, new_fn, ...)
    local _fn, _fn_i, scope_fn = StarIliadUpvalue.GetUpvalue(start_fn, ...)
    debug.setupvalue(scope_fn, _fn_i, new_fn)
end

---------------------------------------------------------------------------------------------
-- function StarIliadUpvalue.GetListenFns(listener, event, be_listened_guy)
-- 	be_listened_guy = be_listened_guy or listener

-- 	return listener.event_listening[event][be_listened_guy]
-- end

-- function StarIliadUpvalue.PrintListenFns(listener, event, be_listened_guy)
-- 	be_listened_guy = be_listened_guy or listener
-- 	for k, v in pairs(GetListenFns(listener, event, be_listened_guy)) do
-- 		print(k, listener, "is listening", be_listened_guy, "for event", event, "with fn", v)
-- 	end
-- end

GLOBAL.StarIliadUpvalue = StarIliadUpvalue
