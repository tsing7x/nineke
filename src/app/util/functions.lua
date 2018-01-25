-- NOTE: 本模块的函数在 app/init.lua 中直接导出到了全局变量 nk中
-- Author: tony
-- Date: 2014-08-01 10:35:58
--
local functions = {}

function functions.getCardDesc(handCard)
    if handCard then
        local value = handCard % 256
        local variety = math.floor(handCard / 256)

        local p = ""
        if variety == 1 then
            p = "方块"
        elseif variety == 2 then
            p = "梅花"
        elseif variety == 3 then
            p = "红桃"
        elseif variety == 4 then
            p = "黑桃"
        end

        if value >= 2 and value <= 10 then
            p = p .. value
        elseif value == 11 then
            p = p .. "J"
        elseif value == 12 then
            p = p .. "Q"
        elseif value == 13 then
            p = p .. "K"
        elseif value == 14 then
            p = p .. "A"
        end

        if p == "" then
            return "无"
        else
            return p
        end
    else
        return "无"
    end
end

function functions.cacheKeyWordFile()
    if not functions.keywords then
        bm.cacheFile(nk.userData.FILTER_CONF, function(result, content)
            if result == "success" then
                functions.keywords = json.decode(content);
                
                table.sort(functions.keywords, function(a, b)
                    return string.utf8len(a)>string.utf8len(b);
                end);
            end
        end, "keywordfilter")
    end
end

function functions.keyWordFilter(message, replaceWord)
    local replaceWith = replaceWord or "**"
    if not functions.keywords then
        functions.cacheKeyWordFile()
    else
        local searchMsg = string.lower(message)
        for i=1,#functions.keywords do
            local v = functions.keywords[i];
            local keywords = string.lower(v)
            local limit = 50
            while true do
                limit = limit - 1
                if limit <= 0 then
                    break
                end
                local s, e = string.find(searchMsg, keywords)
                if s and s > 0 then
                    searchMsg = string.sub(searchMsg, 1, s - 1) .. replaceWith ..string.sub(searchMsg, e + 1)
                    message = string.sub(message, 1, s - 1) .. replaceWith .. string.sub(message, e + 1)
                else
                    break
                end
            end
        end
    end
    return message
end

function functions.badNetworkToptip()
    local t = bm.LangUtil.getText("COMMON", "BAD_NETWORK")
    --nk.TopTipManager:showTopTip(t)
    print(t)
end

function functions.exportMethods(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

function functions.splitString(str, sep)
    local t = {}
    sep = sep or '#'
    local pattern = string.format('([^%s]+)', sep)
    for line in string.gmatch(str, pattern) do
        table.insert(t, line)
    end
    return t
end

function functions.reportToDAdmin(event_,param_)
    if device.platform == "android" or device.platform == "ios" then
        bm.HttpService.POST({mod="Statistic2D", act="toDAdmin", event=event_, param=param_})
    end
end

function functions.reportClickEvent(eventId)
    -- if device.platform == "android" or device.platform == "ios" then
        bm.HttpService.POST({mod="Funnel", act="log", uid=nk.userData.uid, type=eventId})
    -- end
end

function functions.pushMsg(push_uid,title,msg,showIcon, type)
    local sid = appconfig.SID[string.upper(device.platform)]
    local md5key = push_uid .. sid .. "_boyaa"
    local data = {}
    data.contentTitle = title or " "
    data.contentText = msg or " " 
    data.parameters = {}
    local s_picture = nk.userData.s_picture
    if string.len(s_picture) <= 5 then
    else
        if showIcon then
            data.parameters.pictureUrl = s_picture
        end
    end
    bm.HttpService.POST(
        {
            mod = "Push",
            act = "sendMsg",
            push_uid = push_uid,
            msg = json.encode(data),
            key = crypto.md5(md5key),
            type = type
        },
        function(data)
        end,
        function ()
        end)
end

function functions.setScaleBtn(btn,scale)
    -- if typeof
    btn:onButtonPressed(function(evt) 
            btn:setScale(scale or 0.9)
        end
        )
        :onButtonRelease(function(evt)
            btn:setScale(1)
        end
        )
end

function functions.getUserInfo(default)
    local userInfo = nil
    if default ~= true then
        userInfo = {
            mavatar = nk.userData.m_picture, --nk.userData['aUser.micon'], 
            name = nk.userData.nick,     --nk.userData['aUser.name'],
            mlevel = nk.userData.level,  --nk.userData['aUser.mlevel'],
            mlose = nk.userData.lose,    --nk.userData['aUser.lose'],
            mwin = nk.userData.win,       --nk.userData['aUser.win'],
            money = nk.userData.money,    --nk.userData['aUser.money'], 
            msex = nk.userData.sex,       --nk.userData['aUser.msex'],
            mexp = nk.userData.experience,--nk.userData['aUser.exp'],
            sitemid = nk.userData.siteuid,--nk.userData['aUser.sitemid'],
            giftId = nk.userData.user_gift,--nk.userData['aUser.gift'],
            sid = appconfig.SID[string.upper(device.platform)],--tonumber(nk.userData['aUser.sid']),
            lid = nk.userData.lid or 1,--tonumber(nk.userData['aUser.lid']),
            rankMoney = nk.userData.maxmoney--nk.userData["best"]~=nil and (tonumber(nk.userData["best"].rankMoney)) or 0
            --[[
            终端类型、版本类型、渠道信息
            --]]
        }
        
    else
        userInfo = {
            mavatar = "", 
            name = " ",
            mlevel = 3,
            mlose = 0,
            mwin = 0,
            money = 10000, 
            msex = 1,
            mexp = 100,
            sitemid = 0,
            giftId = 0,
            sid = 5,
            lid = 1
        }
    end
    return userInfo 
end

return functions
