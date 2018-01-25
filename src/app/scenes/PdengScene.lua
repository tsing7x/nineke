--
-- Author: Johnny Lee
-- Date: 2014-07-08 11:26:08
--
local RoomController = import("app.module.pdeng.RoomController")
local RoomViewPosition = import("app.module.pdeng.views.RoomViewPosition")
local RoomMenuPopup = import("app.module.pdeng.views.RoomMenuPopup")
local StorePopup = import("app.module.newstore.StorePopup")
local CountDownBox = import("app.module.act.CountDownBox")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local RoomChatBubble = import("app.module.room.views.RoomChatBubble")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
local HallController = import("app.module.hall.HallController")
local FirstPayPopup = import("app.module.firstpay.FirstPayPopup")
local CardTypePopup = import("app.module.pdeng.views.CardTypePopup")
local WaitDealerView = import("app.module.pdeng.views.WaitDealerView")


local PdengScene = class("PdengScene", function()
    return display.newScene("PdengScene")
end)
local logger = bm.Logger.new("PdengScene")

local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 58

PdengScene.EVT_BACKGROUND_CLICK = "EVT_BACKGROUND_CLICK"

function PdengScene:ctor()
    nk.socket.RoomSocket = nk.socket.RealRoomSocket
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:createNodes_()

    self.sendDealerChipBubbleListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, handler(self, self.playDealerBubble))
    self.logoutByMsg_ = bm.EventCenter:addEventListener(nk.eventNames.DOUBLE_LOGIN_LOGINOUT,handler(self, self.doubleLoginOut_))

    
    self:createRoomBg_()
    if nk.socket.RoomSocket.needShowDealer then
     self:createRoomTable_(true)
    else
        self:createRoomTable_(false)
    end
    
    --
    -- -- batchNode
    -- local batchNode = display.newBatchNode("room_texture.png"):addTo(self.nodes.backgroundNode)
    -- -- 扑克堆
    -- for i = 1, 6 do
    --     display.newSprite("#room_dealed_hand_card.png"):pos(RoomViewPosition.DealCardPosition[10].x, RoomViewPosition.DealCardPosition[10].y + i)
    --         :rotation(180)
    --         :addTo(batchNode)
    -- end

    -- 房间信息 (初级场 前注)
    self.roomInfo_ = ui.newTTFLabel({size=24, text="", color=cc.c3b(0x0, 0x0, 0x0)}):pos(display.cx, display.cy):addTo(self.nodes.backgroundNode, 6, 6)
    self.roomInfo_:setOpacity(45)
    -- 顶部操作栏
    local marginLeft = 32
    local marginTop = -30

    -- 菜单按钮
    local menuPosX = marginLeft + 10
    local menuPosY = marginTop
    self.menuBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png", "#room_menu_button_normal.png"},pressed = {"#common_btn_bg_pressed.png", "#room_menu_button_pressed.png"}})
        :onButtonClicked(buttontHandler(self, self.onMenuClick_))
        :pos(menuPosX, menuPosY)
        :addTo(self.topNode_)

    -- 站起按钮
    local standupPosX = marginLeft + 100
    local standupPosY = marginTop
    self.standupBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png", "#room_pop_menu_standup.png"},pressed = {"#common_btn_bg_pressed.png", "#room_pop_menu_standup_pressed.png"}})
        :onButtonClicked(buttontHandler(self, self.onStandupClick_))
        :pos(standupPosX, standupPosY)
        :addTo(self.topNode_)

    -- 商城按钮
    local shopPosX = display.right - 56
    local shopPosY = marginTop
    self.shopNode_ = display.newNode()
    self.shopNode_:pos(shopPosX,shopPosY):addTo(self.topNode_)

    self.shopBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png", "#room_market_icon.png"},pressed = {"#common_btn_bg_pressed.png", "#room_market_icon_pressed.png"}})
        :onButtonClicked(buttontHandler(self, self.onShopClick_))
        :addTo(self.shopNode_)

    self.shopOffBg_ = display.newSprite("#room_store_off_bg.png", self.shopBtn_:getPositionX() - 16, self.shopBtn_:getPositionY() + 8)
        :addTo(self.shopNode_)
        :hide()
    self.shopOffLabel_ = ui.newTTFLabel({size=16, color=cc.c3b(0xFE, 0xF5, 0xD0), text=""})
        :pos(self.shopOffBg_:getPositionX() - 6, self.shopOffBg_:getPositionY() + 6)
        :rotation(-45)
        :addTo(self.shopNode_)
        :hide()

    self.firstPayNode_ = display.newNode()
    self.firstPayNode_:pos(shopPosX,shopPosY):addTo(self.topNode_)

    cc.ui.UIPushButton.new({normal = "#common_first_pay_normal.png", pressed = "#common_first_pay_pressed.png"})
        :addTo(self.firstPayNode_)
        :onButtonClicked(buttontHandler(self, self.onFirstPayClick_))

    self:updateShopIcon()

    -- 牌型按钮
    local cardTypePosX = marginLeft - 4
    local cardTypePosY = -display.height + 204
    self.cardTypeBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png", "#room_icon_card_type_normal.png"},pressed = {"#common_btn_bg_pressed.png", "#room_icon_card_type_pressed.png"}})
        :onButtonClicked(buttontHandler(self, self.onCardTypeClick_))
        :pos(cardTypePosX, cardTypePosY)
        :addTo(self.topNode_, 1, nk.TutorialManager.CARDTYPE_TAG)
        :scale(0.9)

    -- self.toDealerSendChip_ = cc.ui.UIPushButton.new({normal="#room_dealer_send_chip_up.png", pressed="#room_dealer_send_chip_down.png"})
    --     :onButtonClicked(buttontHandler(self, self.toDelearSendChipHandler))
    --     :pos(display.cx - 68, -60)
    --     :addTo(self.topNode_)

    -- 给荷官送礼物提示 (只出现一次)
    local isFirstSendDearlerChip = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.USER_FIRST_DEALER_SEND_CHIP .. nk.userData.uid, false)

    if not isFirstSendDearlerChip then
        if nk.OnOff:check("festivalActView") then
            self.sendDealerChipIcon = display.newSprite("#room_dealer_send_chip_prompt_icon_shuideng.png")
        else
            self.sendDealerChipIcon = display.newSprite("#room_dealer_send_chip_prompt_icon.png")
        end
        self.sendDealerChipIcon:setScaleX(0.7)
        self.sendDealerChipIcon:setScaleY(0.7)
        self.sendDealerChipIcon:pos(display.cx - 68, -56)
        self.sendDealerChipIcon:addTo(self.topNode_):hide()

    end

    -- 房间总控
    self.controller = RoomController.new(self)
    self.ctx = self.controller.ctx

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

    self:addPropertyObservers()
end

-- 创建房间背景
function PdengScene:createRoomBg_()
    local bgImg = "#pdeng_room_bg.png"
    -- 背景
    self.backgroundImg_ = display.newNode()
        :pos(display.cx, display.cy)
        :addTo(self.nodes.backgroundNode)
    self.leftBg_ = display.newSprite(bgImg)
    self.leftBg_:setAnchorPoint(cc.p(1, 0.5))
    self.leftBg_:addTo(self.backgroundImg_)
    self.rightBg_ = display.newSprite(bgImg)
    self.rightBg_:setAnchorPoint(cc.p(1, 0.5))
    self.rightBg_:setScaleX(-1)
    self.rightBg_:pos(-1,0)
    self.rightBg_:addTo(self.backgroundImg_)

    if display.width / display.height > 960 / 640 then
        self.backgroundImg_:setScale(display.width / 960)
    else
        self.backgroundImg_:setScale(display.height / 640)
    end
end
-- 创建房间桌子
function PdengScene:createRoomTable_(isDealer)
    self.tableNode = display.newNode():addTo(self.nodes.backgroundNode, 5, 5)
    self.tableNode:pos(display.cx, RoomViewPosition.SeatPositionForDealer[1].y)
    local defaultTable = "#pdeng_room_table_left.png"
    -- 背景桌子
    self.roomTableLeft = display.newSprite(defaultTable)
    self.roomTableLeft:setAnchorPoint(cc.p(1, 0.5))
    self.roomTableLeft:pos(3, -203):addTo(self.tableNode)
    self.roomTableRight = display.newSprite(defaultTable)
    self.roomTableRight:setAnchorPoint(cc.p(1, 0.5))
    self.roomTableRight:setScaleX(-1)
    self.roomTableRight:pos(-3, -203):addTo(self.tableNode)
      if isDealer then
        self.dealerTable = true
        self.tableNode:setRotation(180)
        self.tableNode:pos(display.cx,RoomViewPosition.SeatPositionForDealer[1].y - 402)
    end
end

-- 更新房间桌子
function PdengScene:updateRoomTable_(isDealer)
    if isDealer and not self.dealerTable then
        self.dealerTable = true
        self.tableNode:runAction(transition.sequence({
            cc.RotateBy:create(0.5, 180),
            cc.MoveBy:create(0.5, cc.p(0, -402))}))
    elseif not isDealer and self.dealerTable then
        self.dealerTable = false
        self.tableNode:runAction(transition.sequence({
            cc.RotateBy:create(0.5, 180),
            cc.MoveBy:create(0.5, cc.p(0, 402))}))
    end
end

function PdengScene:toDelearSendChipHandler()
    local roomType = self.ctx.model:roomType()
    if roomType == consts.ROOM_TYPE.NORMAL or roomType == consts.ROOM_TYPE.PRO or roomType == consts.ROOM_TYPE.TYPE_4K or roomType == consts.ROOM_TYPE.TYPE_5K then
        if self.ctx.model:isSelfInSeat() then
            local canSend = (nk.userData.money - 10 * self.ctx.model.roomInfo.blind ) >0
            if canSend then
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

function PdengScene:setStoreDiscount(discount)
    if not self.shopOffBg_ or not self.shopOffLabel_ then
        return
    end
    if discount and discount ~= 1 then
        self.shopOffBg_:show()
        self.shopOffLabel_:show()
        self.shopOffLabel_:setString(string.format("%+d%%", math.round((discount - 1) * 100)))
        self.shopNode_:show()
    else
        self.shopOffBg_:hide()
        self.shopOffLabel_:hide()
    end
end

function PdengScene:setRoomInfoText(roomInfo)
    local roomFiled = ""
    if roomInfo.roomField then
        if roomInfo.roomField == 0 then
            roomInfo.roomField = 1
        end
        roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT_ROOMTIP")[roomInfo.roomField]
    end

    local info = bm.LangUtil.getText("ROOM", "ROOM_INFO", roomFiled, roomInfo.tid, bm.formatBigNumber(roomInfo.blind))
    self.roomInfo_:setString(info)
end

function PdengScene:setChangeRoomButtonMode(mode)
    if mode == 1 then
        self.standupBtn_:hide()
    else
        self.standupBtn_:show()
    end
end

function PdengScene:onStandupClick_()
    if self.ctx.model:isSelfInGame() then
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("ROOM", "STAND_UP_IN_GAME_MSG"), 
            hasCloseButton = false,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    nk.socket.RoomSocket.stand_type = 2
                    nk.socket.RoomSocket:sendStandUpPdeng()
                end
            end
        }):show()
    else
        nk.socket.RoomSocket.stand_type = 2
        nk.socket.RoomSocket:sendStandUpPdeng()
    end
end

function PdengScene:doBackToHall(msg)
    if self.isback_ then
        return
    end
    self.isback_ = true
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

function PdengScene:doBackToLogin(msg)
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

function PdengScene:doBackToLoginByDoubleLogin(msg)
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

function PdengScene:onMenuClick_()
    RoomMenuPopup.new(function(tag)
        if tag == 1 then
            --返回大厅
            nk.socket.RoomSocket.stand_type = 1
            nk.socket.RoomSocket:sendLogoutPdeng()
            if (not nk.socket.RoomSocket:isConnected()) or (not nk.socket.RoomSocket.isRoomEntered_) then
                self:doBackToHall()
            end
        elseif tag == 2 then
            --换桌
            -- self:onChangeRoom_()
            --self:onChangeRoomClick_()
        elseif tag == 3 then
            --弹出设置菜单
            SettingAndHelpPopup.new(true):show()
        elseif tag == 4 then
            UserInfoPopup.new():show(false)
        end
    end):showPanel()
end

function PdengScene:onShopClick_()
    local tab_ = 1
    StorePopup.new(tab_):showPanel()
end

function PdengScene:onFirstPayClick_()
    FirstPayPopup.new():show()
end

function PdengScene:onCardTypeClick_()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.CARDTYPE_TAG})
    CardTypePopup.new():showPanel()
end

function PdengScene:onLoadedHallTexture_()
    app:enterHallScene({bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW), "backFromRoom"})
end

function PdengScene:onLoadedHallTextureLogout_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "logout"})
end

function PdengScene:onLoadedHallTextureDoubleLogin_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "doublelogin"})
end

function PdengScene:playDealerBubble(evt)
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

function PdengScene:showBubble(textId, DEALER_SPEEK_ARRAY)
    local bubble = RoomChatBubble.new(DEALER_SPEEK_ARRAY[textId], RoomChatBubble.DIRECTION_LEFT)
    bubble:show(self, display.cx + 60, display.cy + 220)
    if bubble then
        bubble:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
            bubble:removeFromParent()
        end)}))
    end
end

--[[
PdengScene nodes:
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
function PdengScene:createNodes_()
    self.nodes = {}
    self.nodes.backgroundNode = display.newNode():addTo(self, 1)
    self.nodes.dealerNode = display.newNode():addTo(self, 2)
    self.nodes.seatNode = display.newNode():addTo(self, 3)
    self.nodes.chipNode = display.newNode():addTo(self, 4)
    self.nodes.dealCardNode = display.newNode():addTo(self, 5)
    self.nodes.lampNode = display.newNode():addTo(self, 6)
    self.nodes.oprNode = display.newNode():addTo(self, 7)
    self.nodes.animNode = display.newNode():addTo(self, 8)
    self.topNode_ = display.newNode():pos(display.left + 8, display.top - 8):addTo(self, 9)
    self.nodes.popupNode = display.newNode():addTo(self, 10)
    self.nodes.dealerTipNode = display.newNode():addTo(self,11)

    self.backgroundTouchHelper_ = bm.TouchHelper.new(self.nodes.backgroundNode, handler(self, self.onBackgroundTouch_))
    self.backgroundTouchHelper_:enableTouch()
end

function PdengScene:onEnter()
    -- nk.SoundManager:preload("roomSounds")
    -- nk.SoundManager:preload("hddjSounds")
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "beginScene",
                    args = {sceneName = "PdengScene"}}
    end

    -- self:performWithDelay(function()
    --     nk.TutorialManager:startPdengScene(self)
    -- end, 2)
end

function PdengScene:onExit()
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "endScene",
                    args = {sceneName = "PdengScene"}}
    end

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

function PdengScene:onCleanup()

    -- 控制器清理
    self.controller:dispose()

    -- 移除事件
    self:removeAllEventListeners()
    self:removePropertyObservers()

    if self.sendDealerChipBubbleListenerId_ then
        bm.EventCenter:removeEventListener(self.sendDealerChipBubbleListenerId_)
        self.sendDealerChipBubbleListenerId_ = nil
    end
    if self.logoutByMsg_ then
        bm.EventCenter:removeEventListener(self.logoutByMsg_)
        self.logoutByMsg_ = nil
    end
end

function PdengScene:onBackgroundTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        self:dispatchEvent({name=PdengScene.EVT_BACKGROUND_CLICK})
    end
end

function PdengScene:updateShopIcon()
    if nk.userData.firstPay then
        self.shopNode_:hide()
        self.firstPayNode_:show()
    else
        self.shopNode_:show()
        self.firstPayNode_:hide()
    end
end

function PdengScene:addPropertyObservers()
    self.firstPayObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstPay", handler(self, function (obj, firstPay)
        self:updateShopIcon()
    end))

    -- 添加动画
    nk.UserInfoChangeManager:reg(nk.UserInfoChangeManager.PdengScene, {}, handler(self, self.getTargetIconPosition_))
end

function PdengScene:removePropertyObservers()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstPay", self.firstPayObserverHandle_)

    --移除动画
    nk.UserInfoChangeManager:unReg(nk.UserInfoChangeManager.PdengScene)
end

function PdengScene:doubleLoginOut_(evt)
    nk.socket.RoomSocket:sendLogoutPdeng()
    self:doBackToLoginByDoubleLogin()
end

function PdengScene:getTutorialNode(tag)
    local node = self.topNode_:getChildByTag(tag)
    if node then
        return node
    end

    return nil
end

function PdengScene:getTargetIconPosition_()
    local pos = {
        x = display.cx,
        y = display.cy
    }

    return pos
end
function PdengScene:showWaitDealerView(isShow)
    if self.waitDealerView_ then
        self.waitDealerView_:dispose()
        self.waitDealerView_:removeFromParent()
        self.waitDealerView_ = nil
        self.ctx.oprManager:setGrabDealerVisible(true)
    end
    if isShow then
         self.waitDealerView_ = WaitDealerView.new(self.nodes.dealerTipNode,
            bm.LangUtil.getText("PDENG", "GRAB_DEALER_SUCCESS_WAIT_NEXT"),self.ctx)
        :addTo(self.nodes.dealerTipNode,1,1)
        :pos(display.width/2,display.height/2)
        self.ctx.oprManager:setGrabDealerVisible(false)
    end
   
end
return PdengScene
