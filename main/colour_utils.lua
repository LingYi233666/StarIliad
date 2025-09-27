StarIliadColour = {}

function StarIliadColour.IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

function StarIliadColour.CreateShiningColour(r, g, b, a, step)
    a = a or 255
    step = step or 0.15
    local t = 0

    local envs = {}
    while t + step + 0.01 < 1 do
        table.insert(envs, { t, StarIliadColour.IntColour(r, g, b, a) })
        t = t + step
        table.insert(envs, { t, StarIliadColour.IntColour(255, 255, 255, 255) })
        t = t + .01
    end

    table.insert(envs, { 1, StarIliadColour.IntColour(r, g, b, 0) })

    return envs
end

function StarIliadColour.CreateFadingColour(r, g, b, a)
    a = a or 255
    return {
        { 0, StarIliadColour.IntColour(r, g, b, a) },
        { 1, StarIliadColour.IntColour(r, g, b, 0) },
    }
end

function StarIliadColour.CreateFadingInOutColour(r, g, b, a, p1, p2)
    a = a or 255
    p1 = p1 or 0.1
    p2 = p2 or 0.8
    return {
        { 0,  StarIliadColour.IntColour(r, g, b, 0) },
        { p1, StarIliadColour.IntColour(r, g, b, a) },
        { p2, StarIliadColour.IntColour(r, g, b, a) },
        { 1,  StarIliadColour.IntColour(r, g, b, 0) },
    }
end

function StarIliadColour.CreateConstantColour(r, g, b, a)
    a = a or 255
    return {
        { 0, StarIliadColour.IntColour(r, g, b, a) },
        { 1, StarIliadColour.IntColour(r, g, b, a) },
    }
end

GLOBAL.StarIliadColour = StarIliadColour
