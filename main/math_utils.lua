StarIliadMath = {}

function StarIliadMath.AngleBetweenVectors(v1, v2, in_degrees)
    local result = math.atan2(v1:Cross(v2):Length(), v1:Dot(v2))
    if in_degrees then
        result = result * RADIANS
    end
    return result
end

-- NOTE: DST coordinates is Front-X, Left-Z, Up-Y
-- Params:
--  theta: radiance between y-axis and direction
--  phi:  radiance between x-axis and direction
function StarIliadMath.CustomSphereEmitter(radius_min, radius_max, theta_min, theta_max, phi_min, phi_max)
    local function fn()
        local radius = GetRandomMinMax(radius_min, radius_max)
        local theta = GetRandomMinMax(theta_min, theta_max)
        local phi = GetRandomMinMax(phi_min, phi_max)

        return radius * math.sin(theta) * math.cos(phi),
            radius * math.cos(theta),
            radius * math.sin(theta) * math.sin(phi)
    end

    return fn
end

function StarIliadMath.CreateCylinderEmitter(radius_min, radius_max, height_min, height_max)
    local function fn()
        local radius = GetRandomMinMax(radius_min, radius_max)
        local angle = math.random() * TWOPI
        local x = math.cos(angle) * radius
        local y = GetRandomMinMax(height_min, height_max)
        local z = math.sin(angle) * radius

        return x, y, z
    end

    return fn
end

function StarIliadMath.GetVoxelCellIndex(point, voxel_size)
    local x = math.floor(point.x / voxel_size)
    local y = math.floor(point.y / voxel_size)
    local z = math.floor(point.z / voxel_size)
    return bit.lshift(x, 42) + bit.lshift(y, 21) + z
end

function StarIliadMath.GetReflectionSpeed(target_pos, collide_pos, speed)
    local px, _, py = target_pos:Get()
    local hx, _, hy = collide_pos:Get()
    local vx, _, vy = speed:Get()

    local Rx = hx - px
    local Ry = hy - py
    local mag_R = math.sqrt(Rx * Rx + Ry * Ry)
    local nx = Rx / mag_R
    local ny = Ry / mag_R

    local dot_product = nx * vx + ny * vy

    return Vector3(vx - 2 * dot_product * nx, 0, vy - 2 * dot_product * ny)
end

GLOBAL.StarIliadMath = StarIliadMath
