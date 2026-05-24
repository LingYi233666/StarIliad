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

--[[
    DBSCAN 聚类函数
    points: Vector3 对象的 table
    eps: 邻域半径
    min_pts: 成为核心点所需的最小邻域点数
    返回: 一个 table，格式为 { [聚类ID] = {Vector3, Vector3, ...}, ... }
    注：未达到聚类标准的点（噪声）将不会包含在返回的聚类结果中
--]]
function StarIliadMath.DBSCAN(points, eps, min_pts)
    local n = #points
    local labels = {} -- 0 代表噪声, nil 代表未访问, >0 代表聚类ID
    local clusters = {}
    local cluster_id = 0
    local eps_sq = eps * eps -- 使用平方距离提高效率

    -- 寻找邻居点的辅助函数
    local function get_neighbors(point_idx)
        local neighbors = {}
        local p1 = points[point_idx]
        for i = 1, n do
            -- 使用 Vector3 的 DistSq 方法
            if p1:DistSq(points[i]) <= eps_sq then
                table.insert(neighbors, i)
            end
        end
        return neighbors
    end

    for i = 1, n do
        if labels[i] == nil then -- 如果点尚未处理
            local neighbors = get_neighbors(i)

            if #neighbors < min_pts then
                labels[i] = 0 -- 标记为噪声
            else
                cluster_id = cluster_id + 1
                labels[i] = cluster_id
                clusters[cluster_id] = { points[i] }

                -- 开始扩展聚类
                local queue = {}
                for _, neighbor_idx in ipairs(neighbors) do
                    if neighbor_idx ~= i then
                        table.insert(queue, neighbor_idx)
                    end
                end

                local q_idx = 1
                while q_idx <= #queue do
                    local target_idx = queue[q_idx]

                    if labels[target_idx] == 0 then -- 噪声点可以转换为边界点
                        labels[target_idx] = cluster_id
                        table.insert(clusters[cluster_id], points[target_idx])
                    elseif labels[target_idx] == nil then -- 未访问过的点
                        labels[target_idx] = cluster_id
                        table.insert(clusters[cluster_id], points[target_idx])

                        local target_neighbors = get_neighbors(target_idx)
                        if #target_neighbors >= min_pts then
                            -- 如果是核心点，将其邻居加入待处理队列
                            for _, tn_idx in ipairs(target_neighbors) do
                                table.insert(queue, tn_idx)
                            end
                        end
                    end
                    q_idx = q_idx + 1
                end
            end
        end
    end

    return clusters
end

function StarIliadMath.EllipseRayIntersection(a, b, degree)
    local theta = degree * DEGREES
    local cos_t = math.cos(theta)
    local sin_t = math.sin(theta)
    local denom = math.sqrt(b * b * cos_t * cos_t + a * a * sin_t * sin_t)
    local t = (a * b) / denom
    return t * cos_t, t * sin_t
end

-- 构建椭圆弧长查表（按参数角 t 采样，点一定在椭圆上）
function StarIliadMath.BuildEllipseArcTable(a, b, num_samples)
    num_samples = num_samples or 360

    local samples = {}
    local prev_x, prev_y = a, 0
    local cumulative_s = 0

    -- i=0 对应 t=0，即 (a, 0)
    samples[1] = { s = 0, x = prev_x, y = prev_y }

    for i = 1, num_samples - 1 do
        local t = (i / num_samples) * TWOPI
        local x = a * math.cos(t)
        local y = b * math.sin(t)

        local dx = x - prev_x
        local dy = y - prev_y
        cumulative_s = cumulative_s + math.sqrt(dx * dx + dy * dy)

        table.insert(samples, { s = cumulative_s, x = x, y = y })
        prev_x, prev_y = x, y
    end

    -- 闭合：最后一个采样点回到起点
    local dx = a - prev_x
    local dy = 0 - prev_y
    cumulative_s = cumulative_s + math.sqrt(dx * dx + dy * dy)

    return {
        a = a,
        b = b,
        total_length = cumulative_s,
        samples = samples, -- samples[k].s 严格递增，samples[1].s = 0
    }
end

-- 按弧长 s 查位置（s 可循环）
function StarIliadMath.SampleEllipseByArcLength(arc_table, s)
    local total = arc_table.total_length
    local samples = arc_table.samples
    local n = #samples

    s = s % total
    if s < 0 then
        s = s + total
    end

    -- 找 segment：samples[i].s <= s < samples[i+1].s
    local idx = 1
    for i = 1, n - 1 do
        if s >= samples[i].s and s < samples[i + 1].s then
            idx = i
            break
        end
    end

    -- 最后一段：最后一个点 → 回到起点 (a, 0)
    if s >= samples[n].s then
        idx = n
    end

    local s0 = samples[idx].s
    local x0, y0 = samples[idx].x, samples[idx].y

    local s1, x1, y1
    if idx < n then
        s1 = samples[idx + 1].s
        x1, y1 = samples[idx + 1].x, samples[idx + 1].y
    else
        s1 = total
        x1, y1 = arc_table.a, 0
    end

    local seg_len = s1 - s0
    local f = (seg_len > 0) and ((s - s0) / seg_len) or 0

    local x = x0 + (x1 - x0) * f
    local y = y0 + (y1 - y0) * f

    -- 用于前后层判断；不要对 degree 做线性插值（跨 360° 会出错）
    local degree = math.atan2(y, x) * RADIANS
    if degree < 0 then
        degree = degree + 360
    end

    return x, y, degree
end

GLOBAL.StarIliadMath = StarIliadMath
