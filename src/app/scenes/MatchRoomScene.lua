--
-- Author: Johnny Lee
-- Date: 2014-07-08 11:26:08
--
local MatchRoomController = import("app.module.room.MatchRoomController")
local RoomViewPosition = import("app.module.room.views.RoomViewPosition")
local RoomImageButton = import("app.module.room.views.RoomImageButton")
local RoomMenuPopup = import("app.module.room.views.RoomMenuPopup")
local CardTypePopup = import("app.module.room.views.CardTypePopup")
local StorePopup = import("app.module.newstore.StorePopup")
-- local CountDownBox = import("app.module.act.CountDownBox")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local RoomChatBubble = import("app.module.room.views.RoomChatBubble")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
local SlotPopup = import("app.module.slot.SlotPopup")
local HallController = import("app.module.hall.HallController")
local LoadMatchControl = import("app.module.match.LoadMatchControl")
local MatchManager = import("app.module.match.MatchManager")

local AnimationDownNum = import("app.module.room.views.AnimationDownNum")
local MatchDetailPanel = import("app.module.match.MatchDetailPanel")
local MatchDetailBar = import("app.module.match.MatchDetailBar")

local MatchRoomScene = class("MatchRoomScene", function()
    return display.newScene("MatchRoomScene")
end)
local logger = bm.Logger.new("MatchRoomScene")

local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 58

MatchRoomScene.EVT_BACKGROUND_CLICK = "EVT_BACKGROUND_CLICK"

function MatchRoomScene:ctor()
    self.tableImg_ = "room_table2.png"
    self.tableLevel_ = nk.socket.MatchSocket.currentRoomMatchLevel or 11
    nk.socket.RoomSocket = nk.socket.MatchSocket
    nk.match.MatchModel:setCurrentView(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:createNodes_()

    self.sendDealerChipBubbleListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, handler(self, self.playDealerBubble))
    self.logoutByMsg_ = bm.EventCenter:addEventListener(nk.eventNames.DOUBLE_LOGIN_LOGINOUT,handler(self, self.doubleLoginOut_))

    -- 背景
    self.backgroundImg_ = display.newNode():addTo(self.nodes.backgroundNode)
    self.backgroundImg_:pos(display.cx, display.cy)
    -- batchNode
    local batchNode = display.newNode():addTo(self.nodes.backgroundNode)
    self.tableBatchNode_ = batchNode

    LoadMatchControl:getInstance():getMatchById(self.tableLevel_,function(matchData)
        self.matchData_ = matchData
        local bgImg = "match_bg1.png"
        local style = matchData and matchData.style and tonumber(matchData.style) or 1
        if style==1 then
            self.tableImg_ = "room_table2.png"
        elseif style==2 then
            bgImg = "match_bg2.png"
            self.tableImg_ = "room_table2.png"
        elseif style==3 then
            bgImg = "match_bg3.png"
            self.tableImg_ = "room_table2.png"
        end
        self:changeTableBg(bgImg)

        if display.width / display.height > 960 / 640 then
            self.backgroundImg_:setScale(display.width / 960)
        else
            self.backgroundImg_:setScale(display.height / 640)
        end
        -- 背景桌子
        self:removeAndAddNewTable()
    end)

    -- 扑克堆
    for i = 1, 6 do
        display.newSprite("#room_dealed_hand_card.png"):pos(RoomViewPosition.DealCardPosition[10].x, RoomViewPosition.DealCardPosition[10].y + i)
            :rotation(180)
            :addTo(batchNode)
    end

    self.wifibg_ = display.newSprite("#wifi_bg.png")
        :pos(display.cx-76, display.height-24)
        :addTo(self.nodes.backgroundNode):hide()
        
    -- 房间信息 (初级场 前注)
    self.roomInfo_ = ui.newTTFLabel({size=24, text="", color=cc.c3b( 0xB4, 0xB4, 0xB4)}):pos(display.cx, display.cy):addTo(self.nodes.backgroundNode)
    -- 顶部操作栏
    local marginLeft = 32
    local marginTop = -30

    -- 退出按钮
    local logOutPosX = marginLeft + 10
    local logOutPosY = marginTop
    self.outBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_bg_normal.png",pressed = "#common_btn_bg_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.onLogOutClick_))
        :pos(logOutPosX, logOutPosY)
        :addTo(self.topNode_)
    self.outBtnIcon_ = display.newSprite("#room_menu_button_normal.png"):addTo(self.outBtn_):rotation(90)

    -- 牌型按钮
    local cardTypePosX = marginLeft + 10
    local cardTypePosY = -display.height + 128
    self.cardTypeBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png", "#room_icon_card_type_normal.png"},pressed = {"#common_btn_bg_pressed.png", "#room_icon_card_type_pressed.png"}})
        :onButtonClicked(buttontHandler(self, self.onCardTypeClick_))
        :pos(cardTypePosX, cardTypePosY)
        :addTo(self.topNode_)

    -- 房间总控
    self.controller = MatchRoomController.new(self)
    self.ctx = self.controller.ctx

    -- 创建比赛信息
    self.matchInfoPanel_ = MatchDetailBar.new()
        :pos(display.right - 106, -28)
        :setClickHandler(handler(self, self.showMatchDetailPanel_)) 
        :addTo(self.topNode_)
        :hide()
    LoadMatchControl:getInstance():getMatchById(self.tableLevel_,function(matchData)
        self.matchInfoPanel_:setMatchData(matchData)
    end)

    self.timeTxt_ =  ui.newTTFLabel({size=30, text=tostring(nk.match.MatchModel.joinTime_), color=cc.c3b(0xff, 0xff, 0xff)})
        :align(display.CENTER_TOP, display.cx, display.cy + 80)
        :addTo(self, 11)

    self:startJoinTimeCountDown()
    -- 创建其他元素
    self.controller:createNodes()

    self:setChangeRoomButtonMode(1)

    -- Android的右键和菜单事件
    if device.platform == "android" then
        self.touchLayer_ = display.newLayer()
        self.touchLayer_:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                if not nk.PopupManager:removeTopPopupIf() then
                    self:onMenuClick_()
                end
            elseif event.key == "menu" then
                self:onMenuClick_()
            end
        end)
        self.touchLayer_:setKeypadEnabled(true)
        self:addChild(self.touchLayer_)
    end

    -- 添加动画
    nk.UserInfoChangeManager:reg(nk.UserInfoChangeManager.MatchRoomScene, {"score", "gameCoupon", "goldCoupon","money","gcoins"})
end

function MatchRoomScene:showMatchDetailPanel_()
    if self.rankInfo_ and self.matchInfo_ and self.matchData_ then
        self:removeTopMatchAwardAim()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        local selfSeatView = self.ctx.seatManager:getSelfSeatView()
        local seatdata = selfSeatView:getSeatData()
        if seatdata then
            local py = 78
            if self.matchInfoPanel_ and self.matchInfoPanel_:isScorePool() then
                py = py + 18
            end
            MatchDetailPanel.new(self.matchData_, self.matchInfo_, self.rankInfo_, seatdata):showAnimation(display.width - 140, py)

            if device.platform == "android" or device.platform == "ios" then
                cc.analytics:doCommand{command = "event",
                            args = {eventId = "Match_DetailPanel_Click", label = "USER UID::"..nk.userData.uid}}
            end
        end
    end
end

function MatchRoomScene:removeAndAddNewTable()
    if self.roomTableLeft_ then
        do return end
        self.roomTableLeft_:removeFromParent()
        self.roomTableLeft_ = nil
    end
    if self.roomTableRight_ then
        self.roomTableRight_:removeFromParent()
        self.roomTableRight_ = nil
    end
    self.roomTableLeft_ = display.newSprite(self.tableImg_)
    self.roomTableRight_ = display.newSprite(self.tableImg_)
    self.roomTableLeft_:setAnchorPoint(cc.p(1, 0.5))
    self.roomTableLeft_:pos(display.cx + 3, RoomViewPosition.SeatPosition[1].y - self.roomTableLeft_:getContentSize().height * 0.5):addTo(self.tableBatchNode_,-1)
    self.roomTableRight_:setAnchorPoint(cc.p(1, 0.5))
    self.roomTableRight_:setScaleX(-1)
    self.roomTableRight_:pos(display.cx - 3, RoomViewPosition.SeatPosition[1].y - self.roomTableRight_:getContentSize().height * 0.5):addTo(self.tableBatchNode_,-1)
end

function MatchRoomScene:startJoinTimeCountDown(isReJoin)
    if self.animationDownNum_ then
        self.animationDownNum_:cleanUp()
    end
    -- 
    self.timeTxt_:setString("")
    self.animationDownNum_ = AnimationDownNum.new({parent=self,px=display.cx,py=display.cy+60, time=nk.match.MatchModel.joinTime_, scale=0.6})
    -- 
    if isReJoin then
        self.matchInfoPanel_:cleanInfo()
        self.matchInfoPanel_:stopRiseBlind()
    end
end

function MatchRoomScene:showMatchAwardPanel(rewardData,matchData)
    -- 显示
    if not self.matchAwardInfo_ then
        self.matchAwardInfo_ = display.newScale9Sprite("#award_bg.png",0,0,cc.size(400,90))
        self.matchAwardInfo_:addTo(self.topNode_)
                            :align(display.BOTTOM_RIGHT)
                            :pos(display.width-8,-150)
        self.matchAwardTxt_ = ui.newTTFLabel(
            {align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            size=22,
            text="",
            color=cc.c3b( 0xFF, 0xFF, 0xFF),
            dimensions=cc.size(375,200)}
            )
        self.matchAwardTxt_:addTo(self.matchAwardInfo_)
                            :align(display.CENTER_TOP)
                            :pos(198,80)
    end
    local reusltStr = bm.LangUtil.getText("MATCH", "AWARDDLGDESC1",matchData.name,
    rewardData.ranking,rewardData.ranking,rewardData.totalCount)
    local awardStr = bm.LangUtil.getText("MATCH", "AWARDDLGWORD")
    local index = 0
    if rewardData.chips and tonumber(rewardData.chips)>0 then
        index = index + 1
        awardStr = awardStr .. " " .. bm.LangUtil.getText("MATCH", "MONEY")..rewardData.chips
    end
    if rewardData.tools and rewardData.tools.score then
        index = index + 1
        awardStr = awardStr .. " " .. bm.LangUtil.getText("MATCH", "SCORE")..rewardData.tools.score
    end
    if rewardData.tools and rewardData.tools.goldCoupon then
        index = index + 1
        awardStr = awardStr .. " " .. bm.LangUtil.getText("MATCH", "GOLDCOUPON")..rewardData.tools.goldCoupon
    end
    if rewardData.tools and rewardData.tools.gameCoupon then
        index = index + 1
        awardStr = awardStr .. " " .. bm.LangUtil.getText("MATCH", "GAMECOUPON")..rewardData.tools.gameCoupon
    end
    if rewardData.gcoins and tonumber(rewardData.gcoins)>0 then
        index = index + 1
        awardStr = awardStr .. " " .. bm.LangUtil.getText("MATCH", "GOLDCOIN")..rewardData.gcoins
    end
    if index>0 then
        reusltStr = reusltStr.." "..awardStr
    end
    self.matchAwardTxt_:setString(reusltStr)
    self.matchAwardInfo_:pos(display.width+400,-150)
    transition.moveTo(self.matchAwardInfo_, {time = 0.5, x = display.width-8})
    self.matchAwardInfo_:setVisible(true)
    self:clearMatchAwardDelayHide()
    self.matchAwardDelayHideId_ = nk.schedulerPool:delayCall(function()
        self:hideMatchAwardPanel()
    end, 5)
    self.controller:resetMatchGuide()
end
function MatchRoomScene:hideMatchAwardPanel()
    if self.matchAwardInfo_ and self.matchAwardInfo_:isVisible() and not self.matchAwardInfo_.isPlaying then
        self.matchAwardInfo_.isPlaying = true
        local callback = cc.CallFunc:create(function()
            self.matchAwardInfo_.isPlaying = false
            self.matchAwardInfo_:setVisible(false)
        end)
        local moveTo = cc.MoveTo:create(0.5,cc.p(display.width+400, -150))
        local sequence = transition.sequence({moveTo,callback})
        self.matchAwardInfo_:runAction(sequence)
        -- transition.moveTo(self.matchAwardInfo_, {time = 0.5, x = display.width+400})
    end
    self:clearMatchAwardDelayHide()
end
function MatchRoomScene:clearMatchAwardDelayHide()
    if self.matchAwardDelayHideId_ then
        nk.schedulerPool:clear(self.matchAwardDelayHideId_)
        self.matchAwardDelayHideId_ = nil
    end
end
function MatchRoomScene:clearMatchTopDelayHide()
    if self.matchTopDelayHideId_ then
        nk.schedulerPool:clear(self.matchTopDelayHideId_)
        self.matchTopDelayHideId_ = nil
    end
end
function MatchRoomScene:hideMatchTopPanel()
    if self.topMatchInfo_ and self.topMatchInfo_:isVisible() and not self.topMatchInfo_.isPlaying then
        self.topMatchInfo_.isPlaying = true
        local callback = cc.CallFunc:create(function()
            self.topMatchInfo_.isPlaying = false
            self.topMatchInfo_:setVisible(false)
            self.matchAwardArrow_:setVisible(true)
        end)
        local moveTo = cc.MoveTo:create(0.5,cc.p(display.width+400, -150))
        local sequence = transition.sequence({moveTo,callback})
        self.topMatchInfo_:runAction(sequence)
        -- transition.moveTo(self.matchAwardInfo_, {time = 0.5, x = display.width+400})
    end
    self:clearMatchTopDelayHide()
end
function MatchRoomScene:onTopMatchClick_()
    self.matchAwardArrow_:setVisible(false)
    self.topMatchInfo_:pos(display.width+400,-150)
    transition.moveTo(self.topMatchInfo_, {time = 0.5, x = display.width-8})
    self.topMatchInfo_:setVisible(true)
    self:clearMatchTopDelayHide()
    self.matchTopDelayHideId_ = nk.schedulerPool:delayCall(function()
        self:hideMatchTopPanel()
    end, 5)
end

function MatchRoomScene:upJoinTime()
    if nk.match.MatchModel.joinTime_ <= 0 then
        if self.timeTxtSchedule_ then
            self:stopAction(self.timeTxtSchedule_)
        end
        self.timeTxt_:hide()
    else
        if self.timeTxt_ then
            self.timeTxt_:setString(tostring(nk.match.MatchModel.joinTime_))
        end
    end
end

function MatchRoomScene:setRankInfo(rankInfo)
    self.rankInfo_ = rankInfo
    self.matchInfoPanel_:renderInfo(rankInfo)
    -- 排名
    LoadMatchControl:getInstance():getMatchById(nk.socket.MatchSocket.currentRoomMatchLevel,function(matchData)
        if matchData then
            if matchData.reward and #matchData.reward>0 then
                if tonumber(rankInfo.totalCount)<=#matchData.reward then
                    if self:isMatchDetail() then
                        self:playTopMatchAwardAnim()
                    else
                        self:showTopMatchAward(matchData.reward[tonumber(rankInfo.totalCount)],rankInfo.totalCount)
                    end                    
                end
            else-- 分布拉去
                LoadMatchControl:getInstance():getMatchDetail(matchData.id,function()
                   if matchData.reward and #matchData.reward>0 then
                        if tonumber(rankInfo.totalCount)<=#matchData.reward then
                            if self:isMatchDetail() then
                                self:playTopMatchAwardAnim()
                            else
                                self:showTopMatchAward(matchData.reward[tonumber(rankInfo.totalCount)],rankInfo.totalCount)
                            end 
                        end
                    end
                end)
            end
        end
    end)

    if self.matchInfoPanel_ then
        self.matchInfoPanel_:show()
    end
end

function MatchRoomScene:setMatchInfo(matchInfo)
    self.matchInfo_ = matchInfo
    self.ctx.model.roomInfo.blind = matchInfo.currentChip
    self.matchInfoPanel_:setMatchInfo(matchInfo)
    -- 
    self:renderRoomInfo()
end

function MatchRoomScene:toDelearSendChipHandler()

    local roomType = self.ctx.model:roomType()
    if roomType == consts.ROOM_TYPE.NORMAL or roomType == consts.ROOM_TYPE.PRO then
        if self.ctx.model:isSelfInSeat() then
            if (nk.userData.money - 10 * self.ctx.model.roomInfo.blind ) >0 then
                nk.socket.RoomSocket:sendDealerChip()
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
            end
            cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP.. nk.userData.uid, true)
            if  self.sendDealerChipIcon then
                self.sendDealerChipIcon:removeFromParent()
                self.sendDealerChipIcon = nil
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_IN_SEAT"))
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_NORMAL_ROOM_MSG"))
    end
end

function MatchRoomScene:setStoreDiscount(discount)
    -- if discount and discount ~= 1 then
    --     self.shopOffBg_:show()
    --     self.shopOffLabel_:show()
    --     self.shopOffLabel_:setString(string.format("%+d%%", math.round((discount - 1) * 100)))
    -- else
    --     self.shopOffBg_:hide()
    --     self.shopOffLabel_:hide()
    -- end
end

function MatchRoomScene:setRoomInfoText(roomInfo)
    LoadMatchControl:getInstance():getMatchById(nk.socket.MatchSocket.currentRoomMatchLevel,function(matchData)
        self.matchData_ = matchData
        self:renderRoomInfo()
    end)
end

function MatchRoomScene:renderRoomInfo()
    local txt
    if self.matchData_ then
        txt = self.matchData_.name -- .. " " .. nk.socket.MatchSocket.currentRoomMatchId
    else
        txt = "" -- " " -- .. nk.socket.MatchSocket.currentRoomMatchId
    end
    --
    if self.matchInfo_ then
        txt = txt .. "/" .. bm.LangUtil.getText("MATCH", "RANKINFO", self.matchInfo_.currentChip)
    end
    self.roomInfo_:setString(txt) -- TODO:写死了比赛场
    -- self.matchInfoPanel_:setMatchData(self.matchData_)
end

function MatchRoomScene:setSlotBlind(roomInfo)
    -- if self.slotPopup then
    --     self.slotPopup:setPreBlind(roomInfo)
    -- end
end

function MatchRoomScene:setChangeRoomButtonMode(mode)
    if mode == 1 then
        -- self.changeRoomBtn_:show()
        -- self.standupBtn_:hide()
    else
        -- self.changeRoomBtn_:hide()
        -- self.standupBtn_:show()
    end
end

function MatchRoomScene:onStandupClick_()
    if self.ctx.model:isSelfInGame() then
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("ROOM", "STAND_UP_IN_GAME_MSG"), 
            hasCloseButton = false,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    nk.socket.RoomSocket:sendStandUp()
                end
            end
        }):show()
    else
        nk.socket.RoomSocket:sendStandUp()
    end
end

function MatchRoomScene:doBackToHall(msg)
    nk.socket.MatchSocket.canDelayResume = false -- dispose resume了
    nk.socket.MatchSocket:pause()
    msg = msg or bm.LangUtil.getText("ROOM", "OUT_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.onLoadedHallTexture_))
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        :pos(display.cx, display.cy)
        :addTo(self, 100)
end

function MatchRoomScene:doBackToLogin(msg)
    nk.socket.MatchSocket.canDelayResume = false -- dispose resume了
    nk.socket.MatchSocket:pause()
    msg = msg or bm.LangUtil.getText("ROOM", "OUT_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.onLoadedHallTextureLogout_))
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        :pos(display.cx, display.cy)
        :addTo(self, 100)
end

function MatchRoomScene:doBackToLoginByDoubleLogin(msg)
    nk.socket.MatchSocket.canDelayResume = false -- dispose resume了
    nk.socket.MatchSocket:pause()
    msg = msg or bm.LangUtil.getText("ROOM", "OUT_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.onLoadedHallTextureDoubleLogin_))
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        :pos(display.cx, display.cy)
        :addTo(self, 100)
end

function MatchRoomScene:onLogOutClick_()
    -- if self.ctx.model:isSelfInGame() then
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("MATCH", "LOGOUTWARNING"),
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    nk.match.MatchModel:setCancelRegistered(self.tableLevel_,true)
                    nk.socket.MatchSocket:sendLogout()
                    self:doBackToHall()
                end
            end
        }):show()
    -- else
    --     nk.socket.MatchSocket:sendLogout()
    --     self:doBackToHall()
    -- end
end

function MatchRoomScene:onMenuClick_()
    -- RoomMenuPopup.new(function(tag)
    --     if tag == 1 then
    --         --返回大厅
    --         nk.socket.RoomSocket:sendLogout()
    --         self:doBackToHall()
    --     elseif tag == 2 then
    --         --换桌
    --         self:onChangeRoom_()
    --     elseif tag == 3 then
    --         --弹出设置菜单
    --         SettingAndHelpPopup.new(true):show()
    --     elseif tag == 4 then
    --         UserInfoPopup.new():show(false)
    --     end
    -- end):showPanel()
end

function MatchRoomScene:onChangeRoomClick_()
    self:onChangeRoom_()
end

function MatchRoomScene:playNowChangeRoom()
    self:onChangeRoom_()
end

function MatchRoomScene:onChangeRoom_()
    -- if self.loginEventHandlerId_ then
    --     bm.EventCenter:removeEventListener(self.loginEventHandlerId_)
    --     self.loginEventHandlerId_ = nil
    -- end

    --显示正在更换房间
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("MATCH", "CHANGING_ROOM_MSG"))
        :pos(display.cx, display.cy)
        :addTo(self, 100)

    -- self.loginEventHandlerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_MATCH_ROOM_SUCC, function()
    --     print("LOGIN_MATCH_ROOM_SUCC------------------------------")
    --     if self.loginEventHandlerId_ then
    --         bm.EventCenter:removeEventListener(self.loginEventHandlerId_)
    --         self.loginEventHandlerId_ = nil
    --     end
    --     --新房间登录成功，干掉动画
    --     -- if self.roomLoading_ then
    --     --     self.roomLoading_:removeFromParent()
    --     --     self.roomLoading_ = nil
    --     -- end
    -- end)

end

function MatchRoomScene:onStopChangeRoom()
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
end

function MatchRoomScene:onShopClick_()
    StorePopup.new():showPanel()
end

function MatchRoomScene:onCardTypeClick_()
    CardTypePopup.new():showPanel()
end

function MatchRoomScene:onLoadedHallTexture_()
    app:enterHallScene({bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)})
end

function MatchRoomScene:onLoadedHallTextureLogout_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "logout"})
end

function MatchRoomScene:onLoadedHallTextureDoubleLogin_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "doublelogin"})
end

function MatchRoomScene:playDealerBubble(evt)
    local currentTime = bm.getTime()
    self.prevPlayDealerBubbleTime_ = self.prevPlayDealerBubbleTime_ or 0
    if currentTime - self.prevPlayDealerBubbleTime_ > 3 then
        local DEALER_SPEEK_ARRAY = bm.LangUtil.getText("ROOM", "DEALER_SPEEK_ARRAY")
        local array = {}
        for i,v in ipairs(DEALER_SPEEK_ARRAY) do
            local kk = bm.LangUtil.formatString(v, evt.nick or "")
            table.insert(array, kk)
        end
        DEALER_SPEEK_ARRAY = array

        local textId = 3
        if evt.lastWin then
            if evt.lastWin == 1 then
                textId = 1
            elseif evt.lastWin == 2 then
                textId = 2
            end
        end
        self.prevPlayDealerBubbleTime_ = currentTime
        self:showBubble(textId, DEALER_SPEEK_ARRAY)
    end
    
end

function MatchRoomScene:changeTableBg(bgImg)
    if not bgImg then return end
    if self.leftTopBg_ then
        self.leftTopBg_:removeFromParent()
        self.rightTopBg_:removeFromParent()
        self.leftBottomBg_:removeFromParent()
        self.rightBottomBg_:removeFromParent()
        self.leftTopBg_,self.rightTopBg_,self.leftBottomBg_,self.rightBottomBg_ = nil,nil,nil,nil
    end
    self.leftTopBg_ = display.newSprite(bgImg)
    self.leftTopBg_:setAnchorPoint(cc.p(1, 0))
    self.leftTopBg_:addTo(self.backgroundImg_)
    self.rightTopBg_ = display.newSprite(bgImg)
    self.rightTopBg_:setAnchorPoint(cc.p(1, 0))
    self.rightTopBg_:setScaleX(-1)
    self.rightTopBg_:pos(-1,0)
    self.rightTopBg_:addTo(self.backgroundImg_)
    self.leftBottomBg_ = display.newSprite(bgImg)
    self.leftBottomBg_:setAnchorPoint(cc.p(1, 0))
    self.leftBottomBg_:setScaleY(-1)
    self.leftBottomBg_:pos(0,1)
    self.leftBottomBg_:addTo(self.backgroundImg_)
    self.rightBottomBg_ = display.newSprite(bgImg)
    self.rightBottomBg_:setAnchorPoint(cc.p(1, 0))
    self.rightBottomBg_:setScaleX(-1)
    self.rightBottomBg_:setScaleY(-1)
    self.rightBottomBg_:pos(-1,1)
    self.rightBottomBg_:addTo(self.backgroundImg_)
end
-- 切换桌面贴图
function MatchRoomScene:changeTableTexture()
    local prevLevel = self.tableLevel_
    self.tableLevel_ = nk.socket.MatchSocket.currentRoomMatchLevel
    if prevLevel ~= nk.socket.MatchSocket.currentRoomMatchLevel then
        LoadMatchControl:getInstance():getMatchById(self.tableLevel_,function(matchData)
            self.matchData_ = matchData
            local tableBg = nil
            local style = matchData and matchData.style and tonumber(matchData.style) or 1
            if style==1 then
                tableBg = "match_bg1.png"
                self.tableImg_ = "room_table2.png"
            elseif style==2 then
                tableBg = "match_bg2.png"
                self.tableImg_ = "room_table2.png"
            elseif style==3 then
                tableBg = "match_bg3.png"
                self.tableImg_ = "room_table2.png"
            end
            if tableBg then
                self:changeTableBg(tableBg)
                self:removeAndAddNewTable()
            end
        end)
    end
end
--[[
MatchRoomScene nodes:
    animLayer:动画层
    oprNode:操作按钮层
    lampNode:桌面灯光层
    chipNode:桌面筹码层
    dealCardNode:手牌层
    seatNode:桌子层
        seat1~9:桌子
            giftImage:礼物图片(*)
            userImage:用户头像
            backgroundImage:桌子背景
    backgroundNode:背景层
        dealerImage:荷官图片
        tableTextLayer:桌面文字
        tableImage:桌子图片
        backgroundImage:背景图片
]]
function MatchRoomScene:createNodes_()
    self.nodes = {}
    self.nodes.backgroundNode = display.newNode():addTo(self,1)
    self.nodes.dealerNode = display.newNode():addTo(self,2)
    self.nodes.seatNode = display.newNode():addTo(self,3)
    self.nodes.chipNode = display.newNode():addTo(self,4)
    self.nodes.dealCardNode = display.newNode():addTo(self,5)
    self.nodes.lampNode = display.newNode():addTo(self,6)
    self.nodes.oprNode = display.newNode():addTo(self,7)
    self.nodes.animNode = display.newNode():addTo(self,8)
    self.topNode_ = display.newNode():pos(display.left + 8, display.top - 8):addTo(self,9)
    self.nodes.popupNode = display.newNode():addTo(self,10)

    self.backgroundTouchHelper_ = bm.TouchHelper.new(self.nodes.backgroundNode, handler(self, self.onBackgroundTouch_))
    self.backgroundTouchHelper_:enableTouch()
end

function MatchRoomScene:onEnter()
    -- nk.SoundManager:preload("roomSounds")
    -- nk.SoundManager:preload("hddjSounds")
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "beginScene",
                    args = {sceneName = "MatchRoomScene"}}
    end
end
-- 奖励框弹在大厅了 要重新显示
function MatchRoomScene:onEnterTransitionFinish()
    if nk.match.MatchModel.prevReward then
        local retData = nk.match.MatchModel.prevReward
        -- setData
        if retData.matchid == nk.socket.MatchSocket.currentRoomMatchId then
            LoadMatchControl:getInstance():getMatchById(retData.matchlevel,function(matchData)
                if matchData then
                    local curScene = display.getRunningScene()
                    if curScene and curScene.showMatchAwardPanel and curScene.controller and curScene.controller.showBigMatchGuide_==true then
                        curScene:showMatchAwardPanel(retData,matchData)
                    else
                        nk.schedulerPool:delayCall(function()
                            local MatchRewardPopup = import("app.module.matchreward.MatchRewardPopup")
                            MatchRewardPopup.new(retData,matchData):show()
                        end,0.5)
                    end
                end
            end
            )
        end
    end
    nk.match.MatchModel.prevReward = nil
end
-- 
function MatchRoomScene:onExit()
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "endScene",
                    args = {sceneName = "MatchRoomScene"}}
    end

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

function MatchRoomScene:onCleanup()
    self.matchData_ = nil
    self.matchInfo_ = nil
    self:clearMatchAwardDelayHide()
    self:clearMatchTopDelayHide()
    -- 控制器清理
    self.controller:dispose()

    -- 移除事件
    self:removeAllEventListeners()

    -- remove data observer
    if self.actNode then
        self.actNode:release()
    end

    -- 卸载预加载的声音
    -- nk.SoundManager:unload("roomSounds")
    -- nk.SoundManager:unload("hddjSounds")

    -- 断开socket
    -- nk.socket.RoomSocket:disconnect()
    local curScene = display.getRunningScene()
    if curScene.name ~= "RoomScene" and curScene.name ~= "MatchRoomScene" then
        -- 清除房间纹理
        display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
        display.removeSpriteFramesWithFile("slot_texture.plist", "slot_texture.png")
        display.removeSpriteFramesWithFile("roommatch_texture.plist", "roommatch_texture.png")
        display.removeSpriteFramesWithFile("upgrade_texture.plist", "upgrade_texture.png")
    elseif curScene.name ~= "MatchRoomScene" then
        display.removeSpriteFramesWithFile("roommatch_texture.plist", "roommatch_texture.png")
    end

    if self.sendDealerChipBubbleListenerId_ then
        bm.EventCenter:removeEventListener(self.sendDealerChipBubbleListenerId_)
        self.sendDealerChipBubbleListenerId_ = nil
    end
    if self.logoutByMsg_ then
        bm.EventCenter:removeEventListener(self.logoutByMsg_)
        self.logoutByMsg_ = nil
    end
    nk.match.MatchModel.prevReward = nil
    -- 坑爹的socket延迟 大厅场景1.2有时候不弹颁奖框BUG
    nk.match.MatchModel:startDelayResume(true,1,self.serverIsClosed_)
    app:dealEnterMatch()
    -- 
    nk.UserInfoChangeManager:unReg(nk.UserInfoChangeManager.MatchRoomScene)
end

function MatchRoomScene:setServerIsClosed()
    self.serverIsClosed_ = true
end

function MatchRoomScene:gameStart()
    if self.matchInfoPanel_ then
        self.matchInfoPanel_:show()
    end
    if self.timeTxt_ then
        self.timeTxt_:hide()
    end
end

function MatchRoomScene:onBackgroundTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        self:dispatchEvent({name=MatchRoomScene.EVT_BACKGROUND_CLICK})
        self:hideMatchAwardPanel()
        self:hideMatchTopPanel()
    end
end

function MatchRoomScene:doubleLoginOut_(evt)
    -- nk.socket.RoomSocket:sendLogout()
    nk.socket.MatchSocket:disconnect(true)
    self:doBackToLoginByDoubleLogin()
end

function MatchRoomScene:playTopMatchAwardAnim()
    self.matchInfoPanel_:playAnimation()
end

function MatchRoomScene:removeTopMatchAwardAim()
    self.matchInfoPanel_:stopAnimation()
end

function MatchRoomScene:isMatchDetail()
    return nk.userData.isMatchDetail and nk.userData.isMatchDetail == 1
end

function MatchRoomScene:showBubble(textId, DEALER_SPEEK_ARRAY)
    local bubble = RoomChatBubble.new(DEALER_SPEEK_ARRAY[textId], RoomChatBubble.DIRECTION_LEFT)
    bubble:show(self, display.cx + 60, display.cy + 220)
    if bubble then
        bubble:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
            bubble:removeFromParent()
        end)}))
    end
end

return MatchRoomScene
