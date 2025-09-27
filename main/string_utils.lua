StarIliadString = {}

--- 计算字符串中的字数（字符数），支持多字节字符。
-- @param s string 输入字符串。
-- @return number 字符串中的字符数量。
function StarIliadString.StrLen(s)
    if s == nil or type(s) ~= 'string' then
        return 0
    end

    local len = 0
    local i = 1
    while i <= #s do
        local byte = string.byte(s, i)
        if byte < 128 then
            -- ASCII 字符 (1字节)
            len = len + 1
            i = i + 1
        elseif byte >= 192 and byte < 224 then
            -- 2字节字符
            len = len + 1
            i = i + 2
        elseif byte >= 224 and byte < 240 then
            -- 3字节字符 (多数中文汉字在此范围内)
            len = len + 1
            i = i + 3
        elseif byte >= 240 and byte < 248 then
            -- 4字节字符
            len = len + 1
            i = i + 4
        else
            -- 其他情况或无效字节，跳过当前字节
            len = len + 1 -- 视为一个未知字符
            i = i + 1
        end
    end
    return len
end

--- 按字符下标截取字符串，支持多字节字符。
-- 注意：Lua 字符串下标通常从 1 开始。
-- @param s string 输入字符串。
-- @param start_index number 截取的起始字符下标（从 1 开始）。
-- @param num_words number 截取的字符数量。
-- @return string 截取后的字符串。
function StarIliadString.Strip(s, start_index, num_words)
    if type(s) ~= "string" or type(start_index) ~= "number" or type(num_words) ~= "number" or start_index < 1 or num_words < 1 then
        return "" -- 输入无效，返回空字符串
    end


    -- 如果 Lua 版本低于 5.3 或 utf8 库不可用
    -- 尝试使用一个简单的基于字节遍历的方法（不完全准确）
    local len = 0
    local byte_start = nil
    local byte_end = nil
    local i = 1
    local current_char_index = 1

    while i <= #s do
        if current_char_index == start_index then
            byte_start = i
        end

        local byte = string.byte(s, i)
        local byte_len = 1
        if byte >= 192 and byte < 224 then
            byte_len = 2
        elseif byte >= 224 and byte < 240 then
            byte_len = 3
        elseif byte >= 240 and byte < 248 then
            byte_len = 4
        end

        if current_char_index == start_index + num_words - 1 then
            byte_end = i + byte_len - 1
            break -- 找到结束位置，退出循环
        end

        current_char_index = current_char_index + 1
        i = i + byte_len
    end

    if not byte_start then
        return "" -- 起始下标超出范围
    end

    if not byte_end then
        -- 如果没有找到结束位置（num_words 超过字符串剩余长度），截取到末尾
        return string.sub(s, byte_start)
    else
        return string.sub(s, byte_start, byte_end)
    end
end

function StarIliadString.Split(s)
    local result = {}
    local i = 1
    local len = #s -- 获取字符串的字节长度

    while i <= len do
        local char_len = 1
        local byte = string.byte(s, i)

        -- 根据 UTF-8 编码的第一个字节来确定字符的长度
        if byte >= 0xF0 and byte <= 0xF7 then     -- 4 字节字符
            char_len = 4
        elseif byte >= 0xE0 and byte <= 0xEF then -- 3 字节字符 (中文常用)
            char_len = 3
        elseif byte >= 0xC0 and byte <= 0xDF then -- 2 字节字符
            char_len = 2
            -- 否则，它是一个单字节 ASCII 字符 (0x00 到 0x7F)
        end

        -- 提取字符
        local char = string.sub(s, i, i + char_len - 1)
        table.insert(result, char)

        -- 移动到下一个字符的起始位置
        i = i + char_len
    end

    return result
end

GLOBAL.StarIliadString = StarIliadString
