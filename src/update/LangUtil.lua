--
-- Author: Johnny Lee
-- Date: 2014-07-07 21:04:24
--

local LangUtil = {}
local lang = require(appconfig.UPD_LANG_FILE_NAME)

-- 获取一个指定键值的text
function LangUtil.getText(primeKey, secKey, ...)
    assert(primeKey ~= nil and secKey ~= nil, "must set prime key and secondary key")
    if LangUtil.hasKey(primeKey, secKey) then
        if (type(lang[primeKey][secKey]) == "string") then
            return LangUtil.formatString(lang[primeKey][secKey], ...)
        else
            return lang[primeKey][secKey]
        end
    else
        return ""
    end
end

-- 判断是否存在指定键值的text
function LangUtil.hasKey(primeKey, secKey)
    return lang[primeKey] ~= nil and lang[primeKey][secKey] ~= nil
end

-- Formats a String in .Net-style, with curly braces ("{1},{2}").
function LangUtil.formatString(str, ...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        local output = str
        for i = 1, numArgs do
            local value = select(i, ...)
            output = string.gsub(output, "{" .. i .. "}", value)
        end
        return output
    else
        return str
    end
end

function LangUtil.compareResource(cn, th, path)
    for k, v in pairs(cn) do
        local found = false
        if th then
            for k1, v1 in pairs(th) do
                if k1 == k then
                    found = true
                    if type(v) == "table" then
                        LangUtil.compareResource(v, v1, path .. "." ..k)
                    end
                    break;
                end
            end
        end
        if not found then
            print(path .. "." .. k)
        end
    end
end

return LangUtil