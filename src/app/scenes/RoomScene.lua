--
-- Author: Johnny Lee
-- Date: 2014-07-08 11:26:08
--
local RoomController        = import("app.module.room.RoomController")
local RoomViewPosition      = import("app.module.room.views.RoomViewPosition")
local RoomImageButton       = import("app.module.room.views.RoomImageButton")
local RoomMenuPopup         = import("app.module.room.views.RoomMenuPopup")
local CardTypePopup         = import("app.module.room.views.CardTypePopup")
local StorePopup            = import("app.module.newstore.StorePopup")
local CountDownBox          = import("app.module.act.CountDownBox")
local SettingAndHelpPopup   = import("app.module.settingAndhelp.SettingAndHelpPopup")
local RoomChatBubble        = import("app.module.room.views.RoomChatBubble")
local UserInfoPopup         = import("app.module.userInfo.UserInfoPopup")
local SlotPopup             = import("app.module.slot.SlotPopup")
local HallController        = import("app.module.hall.HallController")
local SeatInviteView        = import("app.module.room.views.SeatInviteView")
local SeatPushView          = import("app.module.room.views.SeatPushView")
local SeatInvitePlayView    = import("app.module.room.views.SeatInvitePlayView")
local FirstPayPopup         = import("app.module.firstpay.FirstPayPopup")
local GuidePayPopup         = import("app.module.firstpay.GuidePayPopup")
local HighRoomRewardPopup   = import("app.module.newestact.HighRoomRewardPopup")
local PokerActivityPopup    = import("app.module.newestact.PokerActivityPopup")
local RichManActPopup       = import("app.module.newestact.RichManActPopup")
local AnimationDownNum      = import("app.module.room.views.AnimationDownNum")

local RoomScene = class("RoomScene", function()
    return display.newScene("RoomScene")
end)
local logger = bm.Logger.new("RoomScene")

local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 58

RoomScene.EVT_BACKGROUND_CLICK = "EVT_BACKGROUND_CLICK"

function RoomScene:ctor()
    self.unDispose = false
    nk.userData.continuousGameNumber = 0 --当前连续玩牌局数
    nk.socket.RoomSocket = nk.socket.RealRoomSocket
    nk.match.MatchModel:setCurrentView(self)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:createNodes_()

    self.sendDealerChipBubbleListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, handler(self, self.playDealerBubble))
    self.logoutByMsg_ = bm.EventCenter:addEventListener(nk.eventNames.DOUBLE_LOGIN_LOGINOUT,handler(self, self.doubleLoginOut_))

    
    self:createRoomBg_();
    self:createRoomTable_();
    
    -- batchNode
    local batchNode = display.newBatchNode("room_texture.png"):addTo(self.nodes.backgroundNode)
    -- 扑克堆
    for i = 1, 6 do
        display.newSprite("#room_dealed_hand_card.png"):pos(RoomViewPosition.DealCardPosition[10].x, RoomViewPosition.DealCardPosition[10].y + i)
            :rotation(180)
            :addTo(batchNode)
    end

    -- 房间信息 (初级场 前注)
    self.roomInfo_ = ui.newTTFLabel({size=24, text="", color=cc.c3b(0x0, 0x0, 0x0)}):pos(display.cx, display.cy):addTo(self.nodes.backgroundNode)
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

    -- 换桌按钮
    local changeRoomPosX = marginLeft + 100
    local changeRoomPosY = marginTop
    self.changeRoomBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png", "#room_button_change.png"}, pressed = {"#common_btn_bg_pressed.png", "#room_button_change_pressed.png"}})
        :onButtonClicked(buttontHandler(self, self.onChangeRoomClick_))
        :pos(changeRoomPosX, changeRoomPosY)
        :addTo(self.topNode_)
        :hide()

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

    -- 限时优惠按钮
    self.onSaleNode_ = display.newNode()
    self.onSaleNode_:pos(shopPosX,shopPosY):addTo(self.topNode_):hide()

    cc.ui.UIPushButton.new({normal = {"#guidepay_discount_normal.png"}, pressed = {"#guidepay_discount_pressed.png"}})
            :addTo(self.onSaleNode_)
            :onButtonClicked(buttontHandler(self, self.onSaleGoodsPayClick_))

    ui.newTTFLabel({text="+50%", size=18, color = cc.c3b(0xff, 0xed, 0x23)})
        :pos(0, 15)
        :addTo(self.onSaleNode_)

    self.onsaleTimeText_ = ui.newTTFLabel({text = "", size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -20)
        :addTo(self.onSaleNode_)

    self:updateShopIcon()

    -- 牌型按钮
    local cardTypePosX = marginLeft + 10
    local cardTypePosY = -display.height + 128
    self.cardTypeBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png", "#room_icon_card_type_normal.png"},pressed = {"#common_btn_bg_pressed.png", "#room_icon_card_type_pressed.png"}})
        :onButtonClicked(buttontHandler(self, self.onCardTypeClick_))
        :pos(cardTypePosX, cardTypePosY)
        :addTo(self.topNode_, 1, nk.TutorialManager.CARDTYPE_TAG)


    if nk.OnOff:check("festivalActView") then
    else
        self.toDealerSendChip_ = cc.ui.UIPushButton.new({normal="#room_dealer_send_chip_up.png", pressed="#room_dealer_send_chip_down.png"})
        :onButtonClicked(buttontHandler(self, self.toDelearSendChipHandler))
        :pos(display.cx - 68, -60)
        :addTo(self.topNode_)
    end

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
        self.sendDealerChipIcon:addTo(self.topNode_)

    end

    -- 房间总控
    self.controller = RoomController.new(self)
    self.ctx = self.controller.ctx

    -- 倒计时进度框
    self.actNode = CountDownBox.new(self.ctx)
        :pos(display.right, display.bottom)
        :addTo(self.nodes.lampNode)

    if nk.config.HALLOWEEN_ENABLED then
        self.halloween_room_node = display:newNode()
            :pos(display.right - 128, display.bottom + 100)
            :addTo(self.nodes.lampNode)
            :hide()
        self.halloween_room_node:setNodeEventEnabled(true)
        self.halloween_room_progress = ui.newTTFLabel({text = "30/30", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
            :addTo(self.halloween_room_node)
        self.halloweenRoomLight = display.newSprite("#pop_vip_light.png"):pos(0, 32):scale(0.4):addTo(self.halloween_room_node):hide()
        if nk.config.SONGKRAN_ACTIVITY_ENABLED then
            local width = 100
            local height = 42
            local pos_x = 20
            local pos_y = 42

            local stencil = display.newDrawNode()
            stencil:drawPolygon({
                    {pos_x - width * 0.5, pos_y - 20 + height * 0.5},
                    {pos_x - width * 0.5, pos_y - 20 - height * 0.5},
                    {pos_x + 20 + width * 0.5, pos_y - 20 - height * 0.5},
                    {pos_x + 20 + width * 0.5, pos_y - 20 + height * 0.5}
                })
            local clipNode_ = cc.ClippingNode:create()
                :pos(pos_x - 72, pos_y - 32)
                :addTo(self.halloween_room_node, 3)
            clipNode_:setStencil(stencil)

            local frames = display.newFrames("songkran_act_card_light%d.png", 1, 3)
            local animation = display.newAnimation(frames, 30)
            local animSprite = display.newSprite(animation[1])
                :pos(width * 0.5, height * 0.5)
                :addTo(clipNode_)
            animSprite:playAnimationForever(animation, 0)

            cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"},{scale9 = true})
                :setButtonSize(width, height + 20)
                :addTo(self.halloween_room_node, 6)
                :pos(0, 32)
                :onButtonClicked(buttontHandler(self, self.openNewAct))
        else
            cc.ui.UIPushButton.new({normal="room_match_ticket_icon.png"})
                :onButtonClicked(buttontHandler(self, self.openNewAct))
                :pos(0, 32)
                :addTo(self.halloween_room_node, 3)
        end
    end

    if nk.config.POKER_ACTIVITY_ENABLED then
        self.poker_activity_room_node = display:newNode()
            :pos(display.right - 128, display.bottom + 100)
            :addTo(self.nodes.lampNode)
            :hide()
        self.poker_activity_room_node:setNodeEventEnabled(true)
        self.poker_activity_light = display.newSprite("#pop_vip_light.png"):pos(8, 24):scale(0.4):addTo(self.poker_activity_room_node):hide()
        cc.ui.UIPushButton.new({normal="#poker_activity_icon.png"})
                :onButtonClicked(buttontHandler(self, self.openPokerAct))
                :pos(12, 24)
                :addTo(self.poker_activity_room_node, 3)
        if nk.OnOff:check("newMotherDays") then
            self.motherDayLabel = ui.newTTFLabel({text="", size=24, color=cc.c3b(0xff, 0x00, 0x00), align=ui.TEXT_ALIGN_CENTER})
            self.motherDayLabel:pos(30, 50)
            self.motherDayLabel:rotation(-20)
            self.motherDayLabel:addTo(self.poker_activity_room_node,4)
            self.motherDayLabel:setString("X2")
        end
    end

    if nk.config.RICHMAN_SCORE then
        self.richman_activity_room_node = display:newNode()
            :pos(display.right - 140, display.bottom + 100)
            :addTo(self.nodes.lampNode)
        self.richman_activity_room_node:setNodeEventEnabled(true)
        cc.ui.UIPushButton.new({normal="#richman_icon.png"})
                :onButtonClicked(buttontHandler(self, self.openRichManAct))
                :pos(12, 24)
                :addTo(self.richman_activity_room_node, 3)
    end

    -- 创建其他元素
    self.controller:createNodes()

    self:setChangeRoomButtonMode(1)

    -- if not nk.OnOff:check("inviteRecall") and nk.OnOff:check("roomInvite") then
    --     local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    --     if lastLoginType ==  "FACEBOOK" then
    --         self.seatInviteView = SeatInviteView.new(self.ctx):addTo(self.nodes.seatNode)
    --     end
    -- end
    -- self.seatPushView = SeatPushView.new(self.ctx):addTo(self.nodes.seatNode)
    
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
function RoomScene:createRoomBg_()
   -- local bgImg = "match_bg2.png"
    -- if nk.gameState.roomLevel==nk.gameState.RoomLevel[2] then
    --     bgImg = "match_bg1.png"
    -- elseif nk.gameState.roomLevel==nk.gameState.RoomLevel[3] then
    --     bgImg = "match_bg3.png"
    -- end
    -- if nk.gameState.roomLevel == nk.gameState.RoomLevel[4] then
    --     bgImg = "match_bg3.png"
    -- end
    -- if nk.gameState.roomType ~= nil then
    --     if nk.gameState.roomType == 3 then
    --         bgImg = "match_bg2.png"
    --     end
    -- else
    --     bgImg = "match_bg2.png"
    -- end
    local bgImg = "match_bg2.png"
    local tableFlag = tonumber(nk.userData.tableFlag)
    local tableType = tonumber(nk.userData.tableType)
    if tableType and tableFlag then
        if tableFlag == 5 or tableFlag == 6 or tableType == 3 then
            bgImg = "match_bg3.png"
        elseif tableType == 1 then
            bgImg = "match_bg2.png"
        elseif tableType == 2 and (tableFlag == 1 or tableFlag == 2) then
            bgImg = "match_bg1.png"
        end
    end
    -- 背景
    self.backgroundImg_ = display.newNode()
        :pos(display.cx, display.cy)
        :addTo(self.nodes.backgroundNode)
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

    if display.width / display.height > 960 / 640 then
        self.backgroundImg_:setScale(display.width / 960)
    else
        self.backgroundImg_:setScale(display.height / 640)
    end
end
-- 创建房间桌子
function RoomScene:createRoomTable_()
    local tableNode = display.newNode():addTo(self.nodes.backgroundNode)
    local defaultTable = "room_table1.png"
    -- if nk.gameState.roomLevel==nk.gameState.RoomLevel[1] then
    --     defaultTable = "room_table.png"
    -- end

    -- if nk.gameState.roomType ~= nil then
    --     if nk.gameState.roomType == 3 then
    --         defaultTable = "room_table.png"
    --     end
    -- else
    --     defaultTable = "room_table.png"
    -- end
    local tableFlag = tonumber(nk.userData.tableFlag)
    local tableType = tonumber(nk.userData.tableType)
    if tableType and tableFlag then
        if tableFlag == 9 then
            defaultTable = "room_table2.png"
        end
        if tableType == 1 and (tableFlag ==1 or tableFlag == 2) then
            defaultTable = "room_table.png"
        end
    end
    -- 背景桌子
    self.roomTableLeft = display.newSprite(defaultTable)
    self.roomTableLeft:setAnchorPoint(cc.p(1, 0.5))
    self.roomTableLeft:pos(display.cx + 3, RoomViewPosition.SeatPosition[1].y - self.roomTableLeft:getContentSize().height * 0.5):addTo(tableNode)
    self.roomTableRight = display.newSprite(defaultTable)
    self.roomTableRight:setAnchorPoint(cc.p(1, 0.5))
    self.roomTableRight:setScaleX(-1)
    self.roomTableRight:pos(display.cx - 3, RoomViewPosition.SeatPosition[1].y - self.roomTableRight:getContentSize().height * 0.5):addTo(tableNode)
end

function RoomScene:changeRoomBg(type,blind)
    -- if type == consts.ROOM_TYPE.TYPE_4K or type == consts.ROOM_TYPE.TYPE_5K then
    --     local roombg = "match_bg3.png"
    --     local roomtable = "room_table2.png"
    --     if blind < 100 * 1000 then
    --         roombg = "match_bg2.png"
    --     end
    --     if type == consts.ROOM_TYPE.TYPE_4K then
    --         roomtable = "room_table1.png"
    --     end
    --     self.leftTopBg_:setSpriteFrame(display.newSprite(roombg):getSpriteFrame())
    --     self.rightTopBg_:setSpriteFrame(display.newSprite(roombg):getSpriteFrame())
    --     self.leftBottomBg_:setSpriteFrame(display.newSprite(roombg):getSpriteFrame())
    --     self.rightBottomBg_:setSpriteFrame(display.newSprite(roombg):getSpriteFrame())
        
    --     self.roomTableLeft:setSpriteFrame(display.newSprite(roomtable):getSpriteFrame())
    --     self.roomTableRight:setSpriteFrame(display.newSprite(roomtable):getSpriteFrame())
    -- end
end

function RoomScene:AddSelectCardView(cards,show,time)
    self:removeSelectCardView()
    local SelectCard = import("app.module.room.views.SelectCard")
    self.selectcard_ = SelectCard.new(1,#cards):pos(display.cx,display.cy - 150):addTo(self.nodes.oprNode):hide()
    self.selectcard_:setCards(cards)
    self.ctx.oprManager:hideOperationButtons(false)
    if time then
        self.selectcard_:setTime(time)
    end
    if show then
        self.selectcard_:show()
        self.selectcard_:flipAllCards()
    end
end

function RoomScene:setSelectedCardTime(time)
    if self.selectcard_ then
        self.selectcard_:setTime(time)
    end
end

function RoomScene:getSelectCardView()
    if self.selectcard_ then
        return self.selectcard_
    else
        return nil
    end
end

function RoomScene:removeSelectCardView()
    self.ctx.oprManager:showOperationButtons(true)
    if self.selectcard_ then
        self.selectcard_:delayRemoveCard()
        self.selectcard_:removeFromParent()
        self.selectcard_ = nil
    end
end

function RoomScene:toDelearSendChipHandler()
    local roomType = self.ctx.model:roomType()
    if roomType == consts.ROOM_TYPE.NORMAL or roomType == consts.ROOM_TYPE.PRO or roomType == consts.ROOM_TYPE.TYPE_4K or roomType == consts.ROOM_TYPE.TYPE_5K then
        if self.ctx.model:isSelfInSeat() then
            local canSend = (nk.userData.money - 10 * self.ctx.model.roomInfo.blind ) >0
            if self.ctx.model:isCoinRoom() then
                canSend = (nk.userData.gcoins - 10 * self.ctx.model.roomInfo.blind ) >0
            end
            if canSend then
                nk.socket.RoomSocket:sendDealerChip()
            else
                if self.ctx.model:isCoinRoom() then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COINROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
                end
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

function RoomScene:setStoreDiscount(discount)
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

function RoomScene:setRoomInfoText(roomInfo)
    if roomInfo.roomField == 0 then
        roomInfo.roomField = 1
    end
    local roomFiled = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT_ROOMTIP")[roomInfo.roomField]

    local info = bm.LangUtil.getText("ROOM", "ROOM_INFO", roomFiled, roomInfo.tid, bm.formatBigNumber(roomInfo.blind))
    if self.ctx.model:isCoinRoom() then
        info = info .. bm.LangUtil.getText("COINROOM", "SCORE")
    end
    self.roomInfo_:setString(info)
end

function RoomScene:updateHalloweenRoomProgress(isShow, info, reward)
    if nk.config.HALLOWEEN_ENABLED and self.halloween_room_node then 
        if isShow then 
            self.halloween_room_node:show()
            self.halloween_room_progress:setString(info)
            if reward and self.halloweenRoomLight then
                self.halloweenRoomLight:show()
                self.halloweenRoomLight:runAction(cc.RepeatForever:create(transition.sequence({
                    cc.RotateTo:create(1, 180),
                    cc.RotateTo:create(1, 360)
                })))
            else
                self.halloweenRoomLight:stopAllActions()
                self.halloweenRoomLight:hide()
            end
        else
            self.halloween_room_node:hide()
        end
    end
end

function RoomScene:openNewAct()
    if nk.config.SONGKRAN_ACTIVITY_ENABLED then
    else
        HighRoomRewardPopup.new():show()
    end
end

function RoomScene:showPokerAct()
    if self.poker_activity_room_node then
        local show = self.controller:transformPokerActivityRoomType()
        if show then
            self.poker_activity_room_node:show()
        else
            self.poker_activity_room_node:hide()
        end
    end
end

function RoomScene:openPokerAct()
    local show, type_ = self.controller:transformPokerActivityRoomType()
    PokerActivityPopup.new(self, type_):show()
end

function RoomScene:openRichManAct()
    local flag = 1
    if self.ctx.model:isCoinRoom() then
        flag = 5
    end
    local sb = self.ctx.model and self.ctx.model.roomInfo and self.ctx.model.roomInfo.blind or 50
    RichManActPopup.new(flag,sb):show()
end

function RoomScene:updatePokerActivityStatus(reward)
    if nk.config.POKER_ACTIVITY_ENABLED and self.poker_activity_light then 
        if reward then
            self.poker_activity_light:show()
            self.poker_activity_light:runAction(cc.RepeatForever:create(transition.sequence({
                cc.RotateTo:create(1, 180),
                cc.RotateTo:create(1, 360)
            })))
        else
            self.poker_activity_light:stopAllActions()
            self.poker_activity_light:hide()
        end
    end
end

function RoomScene:setSlotBlind(roomInfo)
    self.slotBlindRoomInfo_ = roomInfo
    if self.slotPopup then
        self.slotPopup:setPreBlind(roomInfo.blind, self.ctx.model:isCoinRoom())
    end
end

function RoomScene:setChangeRoomButtonMode(mode)
    if mode == 1 then
        self.changeRoomBtn_:show()
        self.standupBtn_:hide()
    else
        self.changeRoomBtn_:hide()
        self.standupBtn_:show()
    end
end

function RoomScene:onStandupClick_()
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

function RoomScene:doBackToHall(msg)
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

function RoomScene:doBackToLogin(msg)
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

function RoomScene:doBackToLoginByDoubleLogin(msg)
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

function RoomScene:onMenuClick_()
    RoomMenuPopup.new(function(tag)
        if tag == 1 then
            --返回大厅
            nk.socket.RoomSocket:sendLogout()
            self:doBackToHall()
        elseif tag == 2 then
            --换桌
            -- self:onChangeRoom_()
            self:onChangeRoomClick_()
        elseif tag == 3 then
            --弹出设置菜单
            SettingAndHelpPopup.new(true):show()
        elseif tag == 4 then
            UserInfoPopup.new():show(false)
        end
    end):showPanel()
end



function RoomScene:onChangeRoomClick_()
    local isFastPlay = false  -- 10倍低于自己应该进去的场次
    local sb_ = nil
    local attribute="money"
    if nk.userData.opensbguide==1 and self.ctx.model and nk.userData.sbGuide then
        local curList = nil
        if self.ctx.model.is4K then
            curList = nk.userData.sbGuide["k4"]
        else
            curList = nk.userData.sbGuide["normal"]
        end
        if self.ctx.model:isCoinRoom() then
            curList = nk.userData.sbGuide["gold"]
            attribute = "gcoins"
        end
        if curList and #curList>0 then
            for k,v in ipairs(curList) do
                local rang = v.rang
                local sb = v.sb
                if nk.userData[attribute]>=rang[1] and nk.userData[attribute]<=rang[2] then
                    if sb and sb[1] then
                        local curSb = self.ctx.model and self.ctx.model.roomInfo and self.ctx.model.roomInfo.blind
                        if curSb and curSb*10<sb[1] then
                            sb_ = sb[1]
                            isFastPlay = true
                            break;
                        end
                    end
                end
            end
        end
    end
    if isFastPlay then
        -- if attribute == "gcoins" then -- 黄金币场没有快速开始
            self:onChangeRoom_(nil, nil, sb_)
        -- else
        --     self:onChangeRoom_(false, true)
        -- end
    else
        self:onChangeRoom_()
    end
end

function RoomScene:playNowChangeRoom()
    self:onChangeRoom_(false, true)
end

function RoomScene:onChangeRoom_(doNotUpdateRoomInfo, isPlayNow, sb_)
    if self.logoutEventHandlerId_ then
        bm.EventCenter:removeEventListener(self.logoutEventHandlerId_)
        self.logoutEventHandlerId_ = nil
    end
    if self.loginEventHandlerId_ then
        bm.EventCenter:removeEventListener(self.loginEventHandlerId_)
        self.loginEventHandlerId_ = nil
    end

    self.controller.isKickedOut = false

    --显示正在更换房间
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "CHANGING_ROOM_MSG"))
        :pos(display.cx, display.cy)
        :addTo(self, 100)

    --先记录换房php请求数据
    if isPlayNow then
        self.changeRoomParam_ = {
            mod="table",
            act="quickIn",
        }
    elseif not doNotUpdateRoomInfo then
        self.changeRoomParam_ = {
            mod="table", 
            act="quickIn", 
            tid=nk.socket.RoomSocket:getTid(),
            tt=self.ctx.model.roomInfo.roomType, 
            sb=sb_ or self.ctx.model.roomInfo.blind,
            pc=self.ctx.model.roomInfo.playerNum,
            changeSb=1,
        }
        if self.ctx.model:isCoinRoom() then
            self.changeRoomParam_.isgcoin = 1
        end
    end

    --登出房间
    local function logoutSuccess()
        if self.logoutEventHandlerId_ then
            bm.EventCenter:removeEventListener(self.logoutEventHandlerId_)
            self.logoutEventHandlerId_ = nil
        end
        --清空房间聊天记录
        bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
        self.ctx.oprManager:setLatestChatMsg("")

        --登出成功调用php获取新房间
        local retryLimit = 3
        local function onFail()
            --失败处理
            if self.roomLoading_ then 
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("ROOM", "CHANGE_ROOM_FAIL"), 
                firstBtnText = bm.LangUtil.getText("ROOM", "BACK_TO_HALL"),
                secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                callback = function (type)
                    if not self.onChangeRoom_ then
                        return
                    end
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self:onChangeRoom_(true)
                    else
                        self:doBackToHall()
                    end
                end
            }):show()
        end
        local function getNewRoomInfo()
            bm.HttpService.POST(self.changeRoomParam_,
                function(str)
                    local retData = json.decode(str)
                    if retData.ret == 0 then
                        if self.loginEventHandlerId_ then
                            bm.EventCenter:removeEventListener(self.loginEventHandlerId_)
                            self.loginEventHandlerId_ = nil
                        end
                        if self.loginFailEventHandlerId_ then
                            bm.EventCenter:removeEventListener(self.loginFailEventHandlerId_)
                            self.loginFailEventHandlerId_ = nil
                        end
                        --新房间获取成功，连接新房间
                        self.loginEventHandlerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_ROOM_SUCC, function()
                            if self.loginEventHandlerId_ then
                                bm.EventCenter:removeEventListener(self.loginEventHandlerId_)
                                self.loginEventHandlerId_ = nil
                            end
                            --新房间登录成功，干掉动画
                            if self.roomLoading_ then
                                self.roomLoading_:removeFromParent()
                                self.roomLoading_ = nil
                            end
                        end)
                        self.loginFailEventHandlerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_ROOM_FAIL, function(evt)
                            if self.loginFailEventHandlerId_ then
                                bm.EventCenter:removeEventListener(self.loginFailEventHandlerId_)
                                self.loginFailEventHandlerId_ = nil
                            end
                            if not evt or not evt.silent then
                                onFail()
                            else
                                self:doBackToHall()
                            end
                        end)
                        nk.socket.RoomSocket:connectToRoom(retData.ip, retData.port, retData.tid)
                    elseif retData.ret == -103 then
                        --钱不够，一定无法换房了
                        if self.roomLoading_ then
                            self.roomLoading_:removeFromParent()
                            self.roomLoading_ = nil
                        end
                        nk.ui.Dialog.new({
                            messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", nk.userData.limitMin), 
                            hasCloseButton = false,
                            callback = function (type)
                                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                    StorePopup.new():showPanel(function()
                                        retryLimit = 3
                                        getNewRoomInfo()
                                    end)
                                elseif type == nk.ui.Dialog.FIRST_BTN_CLICK then
                                    self:doBackToHall()
                                end
                            end
                        }):show()
                    elseif retryLimit > 0 then
                        retryLimit = retryLimit -1
                        getNewRoomInfo()
                    else
                        onFail()
                    end
                end,
                function()
                    if retryLimit > 0 then
                        retryLimit = retryLimit -1
                        getNewRoomInfo()
                    else
                        onFail()
                    end
                end)
        end
        getNewRoomInfo()
        --登出成功，断掉连接
        nk.socket.RealRoomSocket:disconnectRoom()
    end
    if nk.socket.RoomSocket:isConnected() then
        self.logoutEventHandlerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGOUT_ROOM_SUCC, logoutSuccess)
        nk.socket.RoomSocket:sendLogout()
    else
        logoutSuccess()
    end
end

function RoomScene:onShopClick_()
    local tab_ = 1
    if self.ctx and self.ctx.model:isCoinRoom() then
        tab_ = 3
    end
    StorePopup.new(tab_):showPanel()
end

function RoomScene:onFirstPayClick_()
    FirstPayPopup.new():show()
end

function RoomScene:onSaleGoodsPayClick_()
    if nk.userData.onsaleData then
        GuidePayPopup.new(13, nil, nk.userData.onsaleData):show()
    else
        --请求特价商品
        bm.HttpService.POST({
                mod = "PreferentialOrder",
                act = "jmtinfo"
            },
            function(data)
                local jsnData = json.decode(data)
                if jsnData and jsnData.goods then
                    jsnData.goodsInfo = jsnData.goods
                    nk.userData.onsaleData = jsnData
                    GuidePayPopup.new(13, nil, nk.userData.onsaleData):show()
                else
                    nk.OnOff:clearTimer(nk.OnOff.onsaleCountDownTimerId)
                    nk.userData.onsaleCountDownTime = -1
                end
            end,
            function()
                nk.OnOff:clearTimer(nk.OnOff.onsaleCountDownTimerId)
                nk.userData.onsaleCountDownTime = -1
            end)
    end
end

function RoomScene:onFathersdayRankClick_()
    FathersDayPopup.new():show()
end

function RoomScene:onFathersdayRewardClick_()
    FathersDayRewardPopup.new():show()
end

function RoomScene:onCardTypeClick_()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.CARDTYPE_TAG})
    
    CardTypePopup.new():showPanel()
end

function RoomScene:onLoadedHallTexture_()
    app:enterHallScene({bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW), "backFromRoom",self.ctx.model:isCoinRoom()})

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    --dump(isAdSceneOpen,"onLoadedHallTexture_")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(1)
    end
end

function RoomScene:onLoadedHallTextureLogout_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "logout"})

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(0)
    end
end

function RoomScene:onLoadedHallTextureDoubleLogin_()
    app:enterHallScene({HallController.LOGIN_GAME_VIEW, "doublelogin"})
end

function RoomScene:playDealerBubble(evt)
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

function RoomScene:showBubble(textId, DEALER_SPEEK_ARRAY)
    local bubble = RoomChatBubble.new(DEALER_SPEEK_ARRAY[textId], RoomChatBubble.DIRECTION_LEFT)
    bubble:show(self, display.cx + 60, display.cy + 220)
    if bubble then
        bubble:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
            bubble:removeFromParent()
        end)}))
    end
end

--[[
RoomScene nodes:
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
function RoomScene:createNodes_()
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

    self.backgroundTouchHelper_ = bm.TouchHelper.new(self.nodes.backgroundNode, handler(self, self.onBackgroundTouch_))
    self.backgroundTouchHelper_:enableTouch()
end

function RoomScene:onEnter()
    -- nk.SoundManager:preload("roomSounds")
    -- nk.SoundManager:preload("hddjSounds")
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "beginScene",
                    args = {sceneName = "RoomScene"}}
    end

    self:performWithDelay(function()
        nk.TutorialManager:startRoomScene(self)
    end, 2)
end
-- 比赛相关处理
function RoomScene:onEnterBackground()
    nk.socket.MatchSocket:disconnect(true)
end
function RoomScene:onEnterForeground()
    -- 检测比赛报名情况 连接比赛服务器
    local matchStatus = 0
    if nk.userData then
        matchStatus = nk.userDefault:getIntegerForKey(nk.cookieKeys.IS_JOIN_MATCH..nk.userData.uid,0)
    end
    -- matchStatus = 1
    if matchStatus==1 then
        local LoadMatchControl = import("app.module.match.LoadMatchControl")
        LoadMatchControl:getInstance():startLoad(function()
            local tempIP = LoadMatchControl:getInstance().matchIP_ or "127.0.0.1"
            local tempPort = LoadMatchControl:getInstance().matchPort_ or 8081
            nk.socket.MatchSocket:connectToMatch(tempIP, tempPort)
        end)
    end
end
-- 
function RoomScene:onExit()
    --清空房间聊天记录
    bm.DataProxy:clearData(nk.dataKeys.ROOM_CHAT_HISTORY)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "endScene",
                    args = {sceneName = "RoomScene"}}
    end

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

function RoomScene:onCleanup()
    -- 
    nk.TutorialManager:clean()
    -- 控制器清理
    self.controller:dispose()

    -- 移除事件
    self:removeAllEventListeners()
    self:removePropertyObservers()
    -- remove data observer
    if self.actNode then
        self.actNode:release()
    end

    -- 卸载预加载的声音
    -- nk.SoundManager:unload("roomSounds")
    -- nk.SoundManager:unload("hddjSounds")

    -- 断开socket
    -- nk.socket.RealRoomSocket:disconnectRoom()
    
    if not self.unDispose then
        -- 清除房间纹理 延时清理，解决进入大厅卡顿问题
        -- nk.schedulerPool:delayCall(function ()
        --     display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
        --     display.removeSpriteFramesWithFile("slot_texture.plist", "slot_texture.png")
        --     display.removeSpriteFramesWithFile("upgrade_texture.plist", "upgrade_texture.png")
        -- end, 0.5)
    end

    if self.sendDealerChipBubbleListenerId_ then
        bm.EventCenter:removeEventListener(self.sendDealerChipBubbleListenerId_)
        self.sendDealerChipBubbleListenerId_ = nil
    end
    if self.logoutByMsg_ then
        bm.EventCenter:removeEventListener(self.logoutByMsg_)
        self.logoutByMsg_ = nil
    end
    app:dealEnterMatch()
end

function RoomScene:onBackgroundTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        self:dispatchEvent({name=RoomScene.EVT_BACKGROUND_CLICK})
    end
end
-- 
function RoomScene:addSlot_()
    -- 老虎机
    if nk.config.SLOT_ENABLED and not self.slotPopup then
        local roomField = self.ctx.model:roomField()
        display.addSpriteFrames("slot_texture.plist", "slot_texture.png", function()
            self.slotPopup = SlotPopup.new(true, self.ctx.model:isCoinRoom()):addTo(self.nodes.popupNode):show()

            -- 
            if self.slotBlindRoomInfo_ then
                self:setSlotBlind(self.slotBlindRoomInfo_)
            end
        end)
    end
end
-- 
function RoomScene:updateCoinRoom()
    self:addSlot_()
    self:updateShopIcon()
    if self.ctx and self.ctx.model:isCoinRoom() then
        -- if self.slotPopup then
        --     self.slotPopup:removeFromParent()
        --     self.slotPopup = nil
        -- end
        -- if self.backgroundImg2_ then
        --     self.backgroundImg_:hide()
        --     self.backgroundImg2_:show()
        -- end
        -- if self.richman_activity_room_node then
        --     self.richman_activity_room_node:hide()
        -- end
    end
    self:showPokerAct()

end
function RoomScene:updateShopIcon()
    if self.ctx and self.ctx.model:isCoinRoom() then
        self.shopNode_:show()
        self.firstPayNode_:hide()
	    self.onSaleNode_:hide()
        return
    end
    local onsaletime_ = nk.OnOff:getCurrentTime(nk.OnOff.onsaleCountDownTimerId)
    if onsaletime_ and onsaletime_ > 0 then
        self.shopNode_:hide()
        self.firstPayNode_:hide()
        self.onSaleNode_:show()

        self.onsaleTimeText_:stopAllActions()
        self.onsaleTimeText_:runAction((cc.RepeatForever:create(transition.sequence({
            cc.CallFunc:create(function()
                local onsaletime_ = nk.OnOff:getCurrentTime(nk.OnOff.onsaleCountDownTimerId)
                if onsaletime_ > 0 then
                    self.onsaleTimeText_:setString(bm.TimeUtil:getTimeString(onsaletime_))
                else
                    self.onsaleTimeText_:stopAllActions()
                    self:updateShopIcon()
                end
            end),
            cc.DelayTime:create(1.0)
        }))))
    elseif nk.userData.firstPay then
        self.shopNode_:hide()
        self.firstPayNode_:show()
        self.onsaleTimeText_:stopAllActions()
        self.onSaleNode_:hide()
    else
        self.shopNode_:show()
        self.firstPayNode_:hide()
        self.onsaleTimeText_:stopAllActions()
        self.onSaleNode_:hide()
    end
end

function RoomScene:addPropertyObservers()
    self.firstPayObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstPay", handler(self, function (obj, firstPay)
        self:updateShopIcon()
    end))

    self.onsaleCountDownTimeObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "onsaleCountDownTime", handler(self, function (obj, onsaleCountDownTime)
        self:updateShopIcon()
    end))

    self.changeDealerObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "dealerId", handler(self, function (obj, dealerId)
        -- self.controller:changeDealer(dealerId)
    end))

    -- 添加动画
    nk.UserInfoChangeManager:reg(nk.UserInfoChangeManager.RoomScene, {}, handler(self, self.getTargetIconPosition_))
end

function RoomScene:removePropertyObservers()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstPay", self.firstPayObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "onsaleCountDownTime", self.onsaleCountDownTimeObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "dealerId", self.changeDealerObserverHandle_)

    --移除动画
    nk.UserInfoChangeManager:unReg(nk.UserInfoChangeManager.RoomScene)
end

function RoomScene:doubleLoginOut_(evt)
    nk.socket.RoomSocket:sendLogout()
    self:doBackToLoginByDoubleLogin()
end

function RoomScene:getTutorialNode(tag)
    local node = self.topNode_:getChildByTag(tag)
    if node then
        return node
    end

    return nil
end

function RoomScene:getTargetIconPosition_()
    local pos = {
        x = display.cx,
        y = display.cy
    }

    return pos
end

function RoomScene:showInvitePlayView()
    if self.invitePlayView_ then
        self.invitePlayView_:removeFromParent()
    end
    
    self.invitePlayView_ = SeatInvitePlayView.new(self.ctx):addTo(self.nodes.seatNode)
end

return RoomScene
