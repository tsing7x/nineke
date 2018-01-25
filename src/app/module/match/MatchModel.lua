--
-- Author: Jonah0608@gmail.com
-- Date: 2015-06-30 09:15:45
--
local logger = bm.Logger.new("MatchModel")
local MatchEventHandler = import("app.module.match.MatchEventHandler")
local MatchRewardPopup = import("app.module.matchreward.MatchRewardPopup")
local LoadMatchControl = import("app.module.match.LoadMatchControl")
local MatchModel = {}

function MatchModel.new()
    local instance = {}
    local datapool = {}

    local function getData(table, key)
        return MatchModel[key] or datapool[key]
    end

    local function setData(table, key, value)
        datapool[key] = value
    end

    local function clearData(self)
        local newdatapool = {}
        for k, v in pairs(datapool) do
            if type(v) == "function" then
                newdatapool[k] = v
            end
        end 
        datapool = newdatapool
        return self
    end

    instance.clearData = clearData
    local mtable = {__index = getData, __newindex = setData}
    setmetatable(instance, mtable)
    instance:ctor()

    return instance
end

function MatchModel:ctor()
    self.NOTENOUGHSCORE = bm.LangUtil.getText("MATCH", "NOTENOUGHSCORE")
    -- 比赛延迟resume 比赛弹窗
    self.matchSchedulerPool_ = bm.SchedulerPool.new()

    -- 比赛颁奖
    self.isInitialized = false

    self.joinTime_ = 0
    self.online = {}
    self.regList = {}
    self.openMatchIds = {} -- 开发场次的等级ID

    -- 事件监听 颁奖延后处理 在大厅scene中resume的
    self.eventProxy = cc.EventProxy.new(nk.socket.MatchSocket,nil)
        :addEventListener(nk.socket.MatchSocket.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived_))

    bm.EventCenter:addEventListener("GET_ONE_MATCH_STATUS", handler(self, self.handlerMatchStatus_))
end

function MatchModel:startDelayResume(need,time,matchServerIsClose)
    if need==true then
        nk.socket.MatchSocket.canDelayResume = true
    end
    -- body
    if not time then time =1.2 end
    -- 比赛颁奖
    if nk.socket.MatchSocket.canDelayResume then
        self.matchSchedulerPool_:delayCall(function()
            if nk.socket.MatchSocket.canDelayResume then
                nk.socket.MatchSocket:resume()
            end
            if matchServerIsClose==true then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("MATCH", "MATCHSERVERCLOSETIPS"),
                    hasCloseButton = false,
                    hasFirstButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            local curScene = display.getRunningScene()
                            if curScene.name == "HallScene" then
                                if curScene.controller_ and curScene.controller_.onEnterMatch then
                                    curScene.controller_:onEnterMatch()
                                end
                            end
                        end
                    end
                }):show()
            end
        end, time)
    else
        if matchServerIsClose==true then
            self.matchSchedulerPool_:delayCall(function()
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("MATCH", "MATCHSERVERCLOSETIPS"),
                    hasCloseButton = false,
                    hasFirstButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            local curScene = display.getRunningScene()
                            if curScene.name == "HallScene" then
                                if curScene.controller_ and curScene.controller_.onEnterMatch then
                                    curScene.controller_:onEnterMatch()
                                end
                            end
                        end
                    end
                }):show()
            end,time)
        end
    end
end

function MatchModel:startDownTime(time)
    self.joinTime_ = time
    nk.schedulerPool:delayCall(function() 
        self:countFunc()
    end, 1)
end

function MatchModel:countFunc()
    self.joinTime_ = self.joinTime_ - 1
    if self.joinTime_ <= 0 then
        self.joinTime_ = 0
    else
        nk.schedulerPool:delayCall(function() 
            self:countFunc()
        end, 1)
    end
end

function MatchModel:onPacketReceived_(evt)
    self:processPacket_(evt.packet)
end

function MatchModel:processPacket_(pack)
    local cmd = pack.cmd
    local P = nk.socket.MatchSocket.PROTOCOL

    if cmd == P.SVR_LOGIN_SUCCESS_HALL then -- 时间管理
        LoadMatchControl:getInstance():dealServerTime()
    elseif cmd == P.SVR_CMD_MATCH_REWARD then
        self:handleMatchAward(pack.type,pack.info)
        nk.socket.MatchSocket.matchRewardPack = nil
    elseif cmd == P.SVR_CANCEL_REGISTER then
        local str2 = ""
        if pack.reason==2 or pack.reason==3 then
            str2 = bm.LangUtil.getText("MATCH", "CANCELREASON2")
        else
            str2 = bm.LangUtil.getText("MATCH", "CANCELREASON1")
        end
        LoadMatchControl:getInstance():getMatchById(pack.matchlevel,function(matchData)
            if matchData then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "CANCELTIP2",matchData.name,str2))
            end
        end
        )
    end
end

function MatchModel:test()
    local retData = json.decode('{"end_time":1442489825,"matchid":"11_1442489775","matchlevel":11,"ranking":1,"start_time":1442489812,"uid":10446,"chips":50000,"tools":{"score":5,"goldCoupon":1,"gameCoupon":50},"giftId":1049}')
    retData.totalCount = 108;

    LoadMatchControl:getInstance():getMatchById(retData.matchlevel,function(matchData)
        if matchData then
            MatchRewardPopup.new(retData,matchData):show()
        end
    end
    )
end

function MatchModel:isRegistered()
    if self.regList~=nil then
        for k,v in pairs(self.regList) do
            if v~=nil and v~=0 and v~="" then
                return true
            end
        end
    end
    return false
end

-- 设置游戏当前场景
function MatchModel:setCurrentView(view)
    self.view_ = view
end

-- 正式开始进入比赛房间
function MatchModel:startEnterMatchRoom()
    -- 添加加载loading
    if self.view_ then
        self.matchLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "ENTERING_MSG"))
            :pos(display.cx, display.cy)
            :addTo(self.view_, 1000)
    end

    -- 预加载房间纹理
    self.loadMatchTextureNum_ = 0
    self:onLoadedMatchTexture_()
end


-- 加载比赛场资源
function MatchModel:onLoadedMatchTexture_()
    self.loadMatchTextureNum_ = self.loadMatchTextureNum_ + 1
    if self.loadMatchTextureNum_ == 1 then
        display.addSpriteFrames("room_texture.plist", "room_texture.png", handler(self, self.onLoadedMatchTexture_))
    elseif self.loadMatchTextureNum_ == 2 then
        display.addSpriteFrames("roommatch_texture.plist", "roommatch_texture.png", handler(self, self.onLoadedMatchTexture_))
    elseif self.loadMatchTextureNum_ == 3 then
        app:enterMatchRoomScene()
    end
end

function MatchModel:setRegistered(matchlevel,matchid,notDispatch)
    if not self.regList then
        self.regList = {}
    end
    local preMatchId = self.regList[matchlevel]
    local prevIsReg = nil
    if (not preMatchId or preMatchId==0 or preMatchId=="") then
        prevIsReg = false
    else
        prevIsReg = true
    end

    self.regList[matchlevel] = matchid or ""
    if self.regList[matchlevel]=="" then  -- 定时赛修改流程手动赋值
        self.regList[matchlevel] = "1"
    end

    if not prevIsReg then
        self:dispatchRegMsg(matchlevel, true)
    end

    -- 缓存
    nk.userDefault:setIntegerForKey(nk.cookieKeys.IS_JOIN_MATCH..nk.userData.uid,1)
    nk.userDefault:flush()
end

function MatchModel:setCancelRegistered(matchlevel,notDispatch)
    if not matchlevel then
        matchlevel = 0
        notDispatch = true
    end

    if not self.regList then
        self.regList = {}
    end

    local preMatchId = self.regList[matchlevel]
    local prevIsReg = nil

    if (not preMatchId or preMatchId==0 or preMatchId=="") then
        prevIsReg = false
    else
        prevIsReg = true
    end

    -- 模拟假数据 刷新显示
    local matchid = self.regList and self.regList[matchlevel]
    matchid = matchid or ""
    local count = self[matchlevel] or 1
    count = count - 1
    if count < 0 then
        count = 0
    end

    bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_REG_COUNT,data={matchlevel=matchlevel,matchid=matchid,userCount = count}})

    self.regList[matchlevel] = 0

    if prevIsReg then
        self:dispatchRegMsg(matchlevel, false)
    end

    local haveMatch = false
    for k,v in pairs(self.regList) do
        if v~=nil and v~="" and v~=0 then
            haveMatch = true
            break
        end
    end

    if haveMatch==false then
        -- 缓存
        nk.userDefault:setIntegerForKey(nk.cookieKeys.IS_JOIN_MATCH..nk.userData.uid,0)
        nk.userDefault:flush()
    end
end

-- 初始化报名信息
function MatchModel:initRegistered(info)
    self.regList = {}
    for k,v in pairs(info) do
        self.regList[v.matchlevel] = v.matchid
    end
end

function MatchModel:saveRegCount(data)
    self[data.matchlevel] = data.userCount
end

function MatchModel:dispatchRegMsg(matchLevel,isregistered)
    bm.EventCenter:dispatchEvent({name = MatchEventHandler.REGISTER_STATE_CHANGED,data = {matchlevel = matchLevel,isReg = isregistered}})
end

function MatchModel:handleOnlineCount(matchLevelList)
    self.online = matchLevelList
    bm.EventCenter:dispatchEvent({name = MatchEventHandler.ONLINE_COUNT_CHANGED,data = matchLevelList})
end

function MatchModel:handleMatchAward(type,info)
    -- 给自己加比赛券，金券，礼物，积分
    if type==100 then
        -- json 解析
        local retData = json.decode(info)
        self.prevReward = retData -- 切场景的时候正好断掉了
        retData.totalCount = self.lastTotalCount_ or 1000   -- 包里边没有 自己添加一个
        self.lastTotalCount_ = nil

        -- 免费场次数限制
        local needReduce = true -- 需要减少次数
        if (nk.userData.money+nk.userData.bank_money)<=10000 then
            needReduce = false
        end

        if retData.tools and retData.tools.chips then
            nk.userData.money = nk.userData.money + retData.tools.chips
        end

        LoadMatchControl:getInstance():getMatchById(retData.matchlevel,function(matchData)
            if matchData then
                if needReduce and matchData.playTimes and matchData.playTimes>0 then
                    if not matchData.leftTimes then
                        matchData.leftTimes = 5
                    end
                    matchData.leftTimes = matchData.leftTimes - 1 -- 次数减去
                    LoadMatchControl:getInstance():checkCoolDown() -- 是否要进行倒计时
                end

                local curScene = display.getRunningScene()
                if curScene and curScene.showMatchAwardPanel and curScene.controller and curScene.controller.showBigMatchGuide_==true then
                    curScene:showMatchAwardPanel(retData,matchData)
                -- 颁奖的场次和当前玩的不一样 肯定不能弹大窗
                elseif curScene and curScene.showMatchAwardPanel and curScene.controller and retData.matchid~=nk.socket.MatchSocket.currentRoomMatchId then
                    curScene:showMatchAwardPanel(retData,matchData)
                else
                    MatchRewardPopup.new(retData,matchData):show()
                end
                -- 派发一个比赛场结束消息事件
                bm.EventCenter:dispatchEvent({name = nk.eventNames.MATCH_ROOM_END, data=retData.matchlevel})
            end
        end
        )
    end
end


function MatchModel:lastMatchInfo(selfRank,totalCount)
    self.lastTotalCount_ = totalCount
end

-- 获取单独比赛状态
function MatchModel:handlerMatchStatus_(evt)
    local data = evt.data
    if not data then
        return
    end
    if self.catchReg then
        for i=#self.catchReg,1,-1 do
            local obj = self.catchReg[i]
            if obj and obj[1] == data.matchlevel then
                self.catchReg[i] = nil
                self:regLevel(obj[1],obj[2])
                self.matchSchedulerPool_:clear(obj[3])
            end
        end
    end
end
-- 报名
-- matchLevel报名的等级
-- callBack(1:成功;-1:已经报名;-2:未连接;-3:没有门票;-4:免费次数不够
-- -5:金币不够;-6:比赛券不够;-7:金券不够;
-- -8:不支持门票;-9:门票过期（没有可使用的门票）刷新; -10:门票报名其他错误（入请求PHP失败）
-- -11:没有提供等级
-- -12:现金币不足
-- -13:黄金币不足
-- )
function MatchModel:regLevel(matchLevel,callBack)
    if not matchLevel then 
        if callBack then
            callBack(-11)
        end

        return 
    end

    if not nk.socket.MatchSocket.receivedLevel or
       not nk.socket.MatchSocket.receivedLevel[matchLevel] then
            if not self.catchReg then
                self.catchReg = {}
            end
            -- 5秒取不到清空
            local id = self.matchSchedulerPool_:delayCall(function()
                if self.catchReg then
                    if callBack then
                        callBack(-2)
                    end
                    self.catchReg[1] = nil
                end
            end,5)
            local obj = {[1]=matchLevel,[2]=callBack,[3]=id}
            table.insert(self.catchReg,obj)

        return
    end

    if self.regList and self.regList[matchLevel]~=0 and self.regList[matchLevel]~="" then
        if callBack then
            callBack(-1)
        end

        return;
    end

    LoadMatchControl:getInstance():getMatchById(matchLevel,function(matchData)
        if matchData then
            if not nk.socket.MatchSocket:isConnected() then
                if callBack then
                    callBack(-2)
                end
                nk.userData.useTickType_ = nil;

                return;
            else
                local regUseTickets = false
                local haveTickets = true
                if matchData.ticketInfo and matchData.ticketInfo.name then
                    -- 检测有没有门票
                    if nk.MatchTickManager:getTickByMatchLevel(matchData.id) then
                        regUseTickets = true
                    elseif matchData and matchData.ticketOnly==1 then
                        regUseTickets = true
                        haveTickets = false
                    end
                end

                if regUseTickets then
                    if not haveTickets then
                        if callBack then
                            callBack(-3)
                        end

                        return;
                    end

                    bm.HttpService.CANCEL(self.regUseTicketsId_)
                    self.regUseTicketsId_ = bm.HttpService.POST(
                        {
                            mod = "Match",
                            act = "signin",
                            level = matchData.id
                        },
                        function(data)
                            local retData = json.decode(data)
                            if retData.ret==0 or retData.ret==-5 then
                                -- 0:成功处理  -- -5重复报名(PHP没有清除状态)
                                if callBack then
                                    callBack(1)
                                end
                                local userInfo = {nick = nk.userData.nick,img = nk.userData.s_picture,mtkey = nk.userData.mtkey}
                                nk.socket.MatchSocket:sendReg({
                                    matchlevel = matchData.id,
                                    userinfo = json.encode(userInfo)
                                })
                            elseif retData.ret==-3 then
                                -- -3该场次不支持门票报名
                                matchData.ticketInfo = nil
                                if callBack then
                                    callBack(-8)
                                end
                            elseif retData.ret==-4 then
                                -- -4用户没有可用门票
                                if callBack then
                                    callBack(-9)
                                end
                            else
                                if callBack then
                                    callBack(-10)
                                end
                            end
                        end,
                        function()
                            if callBack then
                                callBack(-10)
                            end
                        end
                    )

                    local eventId = nil;
                    if not nk.userData.useTickType_ then
                        eventId = "Tick_ApplyMatch_Click_Count"
                        eventId = nil
                    elseif nk.userData.useTickType_ == 1 then
                        eventId = "Bubble_OverdueTick_ApplyMatch_Click_Count"
                    elseif nk.userData.useTickType_ == 2 then
                        eventId = "Popup_Tick_ApplyMatch_Click_Count"
                    elseif nk.userData.useTickType_ == 3 then
                        eventId = "Tick_ApplyMatch_Click_Count"
                        eventId = nil
                    end
                    if eventId and (device.platform == "android" or device.platform == "ios") then
                        cc.analytics:doCommand{command = "event",
                                    args = {eventId = eventId, label = matchLevel}}
                    end
                else
                    self:regNormal_(matchData,callBack)
                end

                nk.userData.useTickType_ = nil;
            end
        end
    end
    )
end

-- 正常流程报名
function MatchModel:regNormal_(matchData,callBack)
    if not nk.socket.MatchSocket:isConnected() then
        if callBack then
            callBack(-2)
        end

        return;
    end

    local needReduce = true -- 需要减少次数
    if (nk.userData.money+nk.userData.bank_money)<=10000 then
        needReduce = false
    end

    if needReduce and matchData.playTimes and matchData.playTimes>0 and
        matchData.leftTimes and matchData.leftTimes<1 then
        if callBack then
            callBack(-4)
        end

        return;
    end

    if matchData.condition and matchData.condition.chips then
        if nk.userData.money < tonumber(matchData.condition.chips) then
            if callBack then
                callBack(-5)
            end

            return;
        end
    end

    local gameCouponStatus = nil
    local goldCouponStatus = nil
    local gcoinsStatus = nil

    if matchData.condition and matchData.condition.gameCoupon then
        gameCouponStatus = 1
        if tonumber(nk.userData.gameCoupon)<tonumber(matchData.condition.gameCoupon) then
            gameCouponStatus = -1
        end
    end

    -- 黄金币报名
    if matchData.condition and matchData.condition.gcoins then
        gcoinsStatus = 1
        if tonumber(nk.userData.gcoins)<tonumber(matchData.condition.gcoins) then
            gcoinsStatus = -1
        end
    end

    if not gcoinsStatus and gameCouponStatus==-1 then
        if callBack then
            callBack(-6)
        end

        return;
    end

    if (not gameCouponStatus and gcoinsStatus==-1) or 
        (gameCouponStatus==-1 and gcoinsStatus==-1) then
        if callBack then
            callBack(-13)
        end

        return;
    end

    if matchData.condition and matchData.condition.goldCoupon then
        goldCouponStatus = 1
        if tonumber(nk.userData.goldCoupon)<tonumber(matchData.condition.goldCoupon) then
            goldCouponStatus = -1
            if callBack then
                callBack(-7)
            end

            return;
        end
    end

    if matchData.condition and matchData.condition.score then
        if nk.userData.score < tonumber(matchData.condition.score) then
            if callBack then
                callBack(-12)
            end
            return;
        end
    end

    if callBack then
        callBack(1)
    end

    local userInfo = {nick = nk.userData.nick,img = nk.userData.s_picture,mtkey = nk.userData.mtkey}
    nk.socket.MatchSocket:sendReg({
        matchlevel = matchData.id,
        userinfo = json.encode(userInfo)
    })
end

function MatchModel:reset()
end

return MatchModel