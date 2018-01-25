--
-- Author: KevinYu
-- Date: 2016-07-25 18:23:32
-- 邀请好友相关逻辑
local InvitePopupController = class("InvitePopupController")
local logger = bm.Logger.new("InvitePopupController")

local IS_LIMIT_INVITE --1关闭 2邀请筛选新规则 3邀请筛选老规则
local INVITE_DAYS --邀请好友显示间隔天数
local INVITE_FB_NUM --拉取FB好友数
local INVITE_ARR_INDEX --分批邀请遍历下标

local sendInvite --递归邀请函数

local INVITE_SUCC_FULL_TIP--邀请成功，奖励已达上限提示

function InvitePopupController:ctor(view)
	self.view_ = view
	IS_LIMIT_INVITE = nk.userData.newInviteType
	INVITE_DAYS = nk.userData.newInviteDays
	INVITE_FB_NUM = nk.userData.newInviteFbNum
    INVITE_SUCC_FULL_TIP = self.view_:getInviteRewardText()
end

function InvitePopupController:getInvitableFriends()
	nk.Facebook:getInvitableFriends(INVITE_FB_NUM, handler(self, self.onGetData_))
end

function InvitePopupController:onGetData_(success, friendData, accesstoken)
	if IS_LIMIT_INVITE == 2 and success then --授权不成功，就没必要发送筛选请求
        local picLists = {}
        for _, data in ipairs(friendData) do
            local pic = self:getFriendPicture_(data.url)
            table.insert(picLists, pic)
        end

        local toPicture = table.concat(picLists, ",")

	    bm.HttpService.POST(
	            {
	                mod = "Inviterule",
	                act = "filtering",
                    keylist = toPicture
	            },
	        function (data)
	            local jsonData = json.decode(data)
	            local limitList = {}
	            if jsonData.ret == 1 then
	            	local list = jsonData.recode --当天未到过邀请的id集合
	            	for _, key in pairs(list) do
                        local index = key + 1
		                limitList[picLists[index]] = true
		            end
	            end

	            self.limitList_ = limitList
	            
	            self.view_:onGetData_(success, friendData)
	            self.view_:onSelectAllClicked()
	        end,
	        function()
	        end
	    )
	else
		self.view_:onGetData_(success, friendData)
		self.view_:onSelectAllClicked()
	end
end

-- note: 不能使用self，因为此userdata对象会被释放
function updateTodayInviteCount_(new_invite_number)
    local today = os.date('%Y%m%d')
    local k1 = nk.cookieKeys.FB_LAST_INVITE_DAY
    local k2 = nk.cookieKeys.FB_INVITE_FRIENDS_NUMBER
    local saved_day = nk.userDefault:getStringForKey(k1, '')

    if saved_day == today then
        local current_n = nk.userDefault:getIntegerForKey(k2, 0)
        nk.userDefault:setIntegerForKey(k2, current_n + new_invite_number)
    else
        nk.userDefault:setStringForKey(k1, today)
        nk.userDefault:setIntegerForKey(k2, new_invite_number)
    end

    nk.userDefault:flush()
end

--分批上报邀请缓存
function getPicList(data)
    local picArr = {}
    local picLists = {}
    local num = 0
    local count = 1

    for _, item in ipairs(data) do
            num = num + 1
            table.insert(picArr, item)
 
            if num == 10 then
                picLists[count] = picArr

                picArr = {}

                num = 0

                count = count + 1
            end
    end

    if num > 0 then
        picLists[count] = picArr
    else
        count = count - 1
    end

    local index = 1

    nk.schedulerPool:loopCall(function ()
        if index > count then
            return false
        end

        local toPicture = table.concat(picLists[index], ",")

        bm.HttpService.POST(
            {
                mod = "invite",
                act = "recodeInviteKey",
                keylist = toPicture --邀请名字+头像，用于PHP缓存已邀请人
            },
            function(data)
            end,
            function(data)
            end
        )

        index = index + 1

        return true
    end, 0.1)
end

function savedTodayInvitedMoney_(money)
    if money == 0 then
        return
    end

    local invitedMoney = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_TODAY_INVITE_MONEY, "")
    local today = os.date("%Y%m%d")

    if invitedMoney == "" or string.sub(invitedMoney, 1, 8) ~= today then
        invitedMoney = today .."#" .. money
    else
        local reward = string.split(invitedMoney, "#") 
        local totalMoney = tonumber(reward[2]) + money

        invitedMoney = today .. "#" .. totalMoney
    end

    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_TODAY_INVITE_MONEY, invitedMoney)
    nk.userDefault:flush()
end

function InvitePopupController:getTodayInvitedMoney_()
    local invitedMoney = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_TODAY_INVITE_MONEY, "")
    local today = os.date("%Y%m%d")
    local money = 0

    if invitedMoney == "" or string.sub(invitedMoney, 1, 8) ~= today then
        money = 0
    else
        local reward = string.split(invitedMoney, "#") 
        money = tonumber(reward[2])
    end

    return money
end

function sendInvite(toIdList, nameList, toPictureList)
	local len = #toIdList
	if INVITE_ARR_INDEX > len then
		return
	end

    local toIds = table.concat(toIdList[INVITE_ARR_INDEX], ",")
    local names = table.concat(nameList[INVITE_ARR_INDEX], "#")
    local toPicture = toPictureList[INVITE_ARR_INDEX]
    local selectedNum = #toIdList[INVITE_ARR_INDEX]

	bm.HttpService.POST(
        {
            mod = "invite",
            act = "getInviteID"
        },
        function (data)
            local retData = json.decode(data)
            local requestData = ""

            if retData and retData.ret and retData.ret == 0 then
                requestData = "u:"..retData.u..";id:"..retData.id..";sk:"..retData.sk; 
            end

            local needReport = false
            if retData and retData.needReport and retData.needReport == 1 then
                needReport = true
            end

            nk.Facebook:sendInvites(
                requestData,
                toIds,
                bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"),
                bm.LangUtil.getText("FRIEND", "INVITE_CONTENT"),
                function (success, result)
                    if success then
                        -- 更新成功邀请的次数
                        updateTodayInviteCount_(selectedNum)

                        if nk.userData.newInviteType == 2 then
                            getPicList(toPicture)
                        end

                        -- 保存邀请过的名字
                        if names ~= "" then
                            local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                            local today = os.date("%Y%m%d")
                            if invitedNames == "" or string.sub(invitedNames, 1, 8) ~= today then
                                invitedNames = today .."#" .. names
                            else
                                invitedNames = invitedNames .. "#" .. names
                            end
                            nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, invitedNames)
                            nk.userDefault:flush()
                        end

                        -- 去掉最后一个逗号
                        if result.toIds then
                            local idLen = string.len(result.toIds)
                            if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                                result.toIds = string.sub(result.toIds, 1, idLen - 1)
                            end
                        end
                        
                        requestData = string.gsub(requestData, ";match:2", "")

                        -- 上报php，领奖
                        local postData = {
                            mod = "invite",
                            act = "report",
                            data = requestData,
                            requestid = result.requestId,
                            list = result.toIds,
                            source = "register",
                        }

                        postData.type = "register"
                        if needReport then
                            postData.userList = names
                        end

                        bm.HttpService.POST(
                            postData,
                            function (data)
                                local retData = json.decode(data)
                                if retData and retData.ret == 0 and retData.money then
                                    if retData.money > 0 then
                                        local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
                                        historyVal = historyVal + retData.money
                                        nk.userDefault:setIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, historyVal)

                                        savedTodayInvitedMoney_(retData.money)

                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.money))
                                    else
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_FULL_TIP", INVITE_SUCC_FULL_TIP))
                                    end
                                end
                            end,
                            function(data)
                                print("php return false:" .. data)
                            end
                        )

                        INVITE_ARR_INDEX = INVITE_ARR_INDEX + 1
                        sendInvite(toIdList, nameList, toPictureList)
                    end
                end
            )
        end,
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_INVITE_FRIEND"))
        end
    )
end

function InvitePopupController:sendInvites(selectedList)
	local toIdArr, nameArr, pictureArr = {}, {}, {}
	local toIdList, nameList, toPictureList = {}, {}, {}
	local num = 0
	local index = 1
    for _, item in ipairs(selectedList) do
        local data = item:getData()
        local id = data.id
        if item:isSelected() then
        	num = num + 1
            table.insert(toIdArr, id)
            table.insert(nameArr, data.name)
            -- local str = string.gsub(data.name, "[ \t\n\r]+", "")
            -- local pic = self:getFriendPicture_(data.url)
            local pic = self:getFriendPicture_(data.url)
            table.insert(pictureArr, pic)

            if num == 50 then
            	toIdList[index] = toIdArr
    			nameList[index] = nameArr
    			toPictureList[index] = pictureArr

    			toIdArr = {}
				nameArr = {}
				pictureArr = {}

				num = 0
				index = index + 1
            end        
        end
    end

    if num > 0 then
    	toIdList[index] = toIdArr
    	nameList[index] = nameArr
    	toPictureList[index] = pictureArr
    end

    INVITE_ARR_INDEX = 1
	sendInvite(toIdList, nameList, toPictureList)
end

function InvitePopupController:filterAllData(friendData)
    local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
    local yesterdayInvitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.YESTERDAY_INVITED_NAMES, "")
    local thirddayInvitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.THIRDDAY_INVITED_NAMES, "")

    local yesterday = os.date("%Y%m%d",os.time() - 86400)
    local thirdday = os.date("%Y%m%d",os.time() - 86400 * 2)

    if thirddayInvitedNames ~= "" then
        local thirddayNamesTable = string.split(thirddayInvitedNames, "#")
        if thirddayNamesTable[1] ~= thirdday then
            nk.userDefault:setStringForKey(nk.cookieKeys.THIRDDAY_INVITED_NAMES, "")
            thirddayInvitedNames = ""
        end
    end

    if yesterdayInvitedNames ~= "" then
        local yesterdayNamesTable = string.split(yesterdayInvitedNames, "#")
        if yesterdayNamesTable[1] ~=  yesterday then
            if yesterdayNamesTable[1] == thirdday then
                thirddayInvitedNames = yesterdayInvitedNames
                nk.userDefault:setStringForKey(nk.cookieKeys.THIRDDAY_INVITED_NAMES, thirddayInvitedNames)
            end
            nk.userDefault:setStringForKey(nk.cookieKeys.YESTERDAY_INVITED_NAMES, "")
            yesterdayInvitedNames = ""
        end
    end

    if invitedNames ~= "" then
        local namesTable = string.split(invitedNames, "#")
        if namesTable[1] == thirdday then
            nk.userDefault:setStringForKey(nk.cookieKeys.THIRDDAY_INVITED_NAMES, invitedNames)
            nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
            thirddayInvitedNames = invitedNames
            invitedNames = ""
        elseif namesTable[1] == yesterday then
            nk.userDefault:setStringForKey(nk.cookieKeys.YESTERDAY_INVITED_NAMES, invitedNames)
            nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
            yesterdayInvitedNames = invitedNames
            invitedNames = ""
        elseif namesTable[1] == os.date("%Y%m%d") then
            
        else
            nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
            invitedNames = ""
        end
    end

    local invitedNamesList = {invitedNames, yesterdayInvitedNames, thirddayInvitedNames}
    for i = 1, INVITE_DAYS do
    	local names = invitedNamesList[i]
    	if names ~= "" then
	        local namesTable = string.split(names, "#")
	        table.remove(namesTable, 1)
	        for _, name in pairs(namesTable) do
	            local i, max = 1, #friendData
	            while i <= max do
	                if friendData[i].name == name then
	                    logger:debug("remove invited name -> ", name)
	                    table.remove(friendData, i)
	                    i = i - 1
	                    max = max - 1
	                end
	                i = i + 1
	            end
	        end
	    end
    end

    if IS_LIMIT_INVITE == 2 then
    	friendData = self:filterLimitData_(friendData)
    end

    return friendData
end

--去掉已经被被其他玩家邀请过的
function InvitePopupController:filterLimitData_(friendData)
    local limitList = self.limitList_
    local i, max = 1, #friendData
    while i <= max do
        local url = friendData[i].url
        local picture = self:getFriendPicture_(url)
        if not limitList[picture] then
            logger:debug("remove invited picture -> ", picture)
            table.remove(friendData, i)
            i = i - 1
            max = max - 1
        end
        i = i + 1
    end

    return friendData
end

--获取好友头像图片名字
function InvitePopupController:getFriendPicture_(url)
    local p = ".*/(.*)_n%.jpg"
    local str = string.match(url, p)
    local md5str = crypto.md5(str)

    return md5str
end

return InvitePopupController