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

function StarIliadMath.RotateVector3(dir_1, axis, angle_degrees)
    -- 1. 将角度从度数转换为弧度
    local angle_radians = angle_degrees * DEGREES

    -- 2. 确保旋转轴是单位向量
    local k = axis:GetNormalized()

    -- 3. 计算 cos(theta) 和 sin(theta)
    local cos_theta = math.cos(angle_radians)
    local sin_theta = math.sin(angle_radians)

    -- 4. 执行罗德里格斯旋转公式的各个部分
    -- V * cos(theta)
    local term1 = dir_1 * cos_theta

    -- (k x V) * sin(theta)
    -- Vector3 类型提供了 CrossProduct 方法
    local term2 = k:Cross(dir_1) * sin_theta

    -- k * (k . V) * (1 - cos(theta))
    -- Vector3 类型提供了 Dot 方法
    local k_dot_dir_1 = k:Dot(dir_1)
    local term3 = k * k_dot_dir_1 * (1 - cos_theta)

    -- 5. 将所有部分相加得到旋转后的向量
    return term1 + term2 + term3
end

local normal_distribution_z0, normal_distribution_z1
local normal_distribution_generate = false
function StarIliadMath.NormalDistribution(mean, stddev)
    mean = mean or 0
    stddev = stddev or 1

    local u1, u2, s, r
    normal_distribution_generate = not normal_distribution_generate

    if not normal_distribution_generate then
        return normal_distribution_z1 * stddev + mean
    end

    repeat
        u1 = math.random() * 2 - 1
        u2 = math.random() * 2 - 1
        s = u1 * u1 + u2 * u2
    until s < 1

    r = math.sqrt(-2 * math.log(s) / s)
    normal_distribution_z0 = r * u1
    normal_distribution_z1 = r * u2

    return normal_distribution_z0 * stddev + mean
end

function StarIliadMath.GetDistPointToLine(point_A, point_B, point_C)
    local AB = point_B - point_A
    local AC = point_C - point_A

    if AB:Length() <= 0 then
        return AC:Length()
    end

    return (AB:Cross(AC)):Length() / AB:Length()

    -- -- 1. 计算向量 AB 和 AC
    -- local AB_x = point_B.x - point_A.x
    -- local AB_y = point_B.y - point_A.y

    -- local AC_x = point_C.x - point_A.x
    -- local AC_y = point_C.y - point_A.y

    -- -- 2. 计算 AB 和 AC 的二维叉乘 (Cross Product)
    -- -- 在 2D 中，这代表了两个向量围成的平行四边形的面积（有正负）
    -- local cross_product = math.abs(AB_x * AC_y - AB_y * AC_x)

    -- -- 3. 计算底边 AB 的长度
    -- local AB_length = math.sqrt(AB_x * AB_x + AB_y * AB_y)

    -- -- 4. 距离 = 面积 / 底边
    -- -- 检查底边是否为0（即A点和B点重合）
    -- if AB_length == 0 then
    --     -- 如果AB重合，距离就是点C到点A的距离
    --     return math.sqrt(AC_x * AC_x + AC_y * AC_y)
    -- end

    -- return cross_product / AB_length
end

GLOBAL.StarIliadMath = StarIliadMath
