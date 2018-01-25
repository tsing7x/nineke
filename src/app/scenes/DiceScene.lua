--
-- Author: Jonah0608@gmail.com
-- Date: 2016-08-29 09:47:03
--
local DiceController = import("app.module.dice.DiceController")
local StorePopup = import("app.module.newstore.StorePopup")
local QuestionPopup = import("app.module.dice.views.QuestionPopup")
local DiceResultPopup = import("app.module.dice.views.DiceResultPopup")
local AllUserInfoPopup = import("app.module.dice.views.AllUserInfoPopup")
local DiceScene = class("DiceScene", function()
    return display.newScene("DiceScene")
end)

local logger = bm.Logger.new("DiceScene")

function DiceScene:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:createNodes_()
    self:createDiceBg_()
    self:createTop_()
    self.controller = DiceController.new(self)
    self.ctx = self.controller.ctx

    self.controller:createNodes()

    if device.platform == "android" then
        self.touchLayer_ = display.newLayer()
        self.touchLayer_:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                if not nk.PopupManager:removeTopPopupIf() then
                    if self.quitDialog then
                        self.quitDialog:onClose()
                        self.quitDialog = nil
                    else
                        self:onReturnClick_()
                    end
                end
            end
        end)
        self.touchLayer_:setKeypadEnabled(true)
        self:addChild(self.touchLayer_)
    end
end

function DiceScene:createNodes_()
    self.nodes = {}
    self.nodes.backgroundNode = display.newNode():addTo(self,1)
    self.nodes.seatNode = display.newNode():addTo(self,2)
    self.nodes.betTypeNode = display.newNode():addTo(self,3)
    self.nodes.selfNode = display.newNode():addTo(self,4)
    self.nodes.dealNode = display.newNode():addTo(self,5)
    self.nodes.chipNode = display.newNode():addTo(self,6)
    self.topNode_ = display.newNode():pos(display.left + 8, display.top - 8):addTo(self,7)
    self.nodes.animNode = display.newNode():addTo(self,8)
end

function DiceScene:createFloorBg_()
    local bgImg = "dice_room_bg.png"
    -- 背景
    self.backgroundImg_ = display.newNode()
        :pos(display.cx, display.cy)
        :addTo(self.nodes.backgroundNode)
    -- self.leftTopBg_ = display.newSprite(bgImg)
    -- self.leftTopBg_:setAnchorPoint(cc.p(1, 0))
    -- self.leftTopBg_:addTo(self.backgroundImg_)
    -- self.rightTopBg_ = display.newSprite(bgImg)
    -- self.rightTopBg_:setAnchorPoint(cc.p(1, 0))
    -- self.rightTopBg_:setScaleX(-1)
    -- self.rightTopBg_:pos(-1,0)
    -- self.rightTopBg_:addTo(self.backgroundImg_)
    -- self.leftBottomBg_ = display.newSprite(bgImg)
    -- self.leftBottomBg_:setAnchorPoint(cc.p(1, 0))
    -- self.leftBottomBg_:setScaleY(-1)
    -- self.leftBottomBg_:pos(0,1)
    -- self.leftBottomBg_:addTo(self.backgroundImg_)
    -- self.rightBottomBg_ = display.newSprite(bgImg)
    -- self.rightBottomBg_:setAnchorPoint(cc.p(1, 0))
    -- self.rightBottomBg_:setScaleX(-1)
    -- self.rightBottomBg_:setScaleY(-1)
    -- self.rightBottomBg_:pos(-1,1)
    -- self.rightBottomBg_:addTo(self.backgroundImg_)
    display.newSprite(bgImg):addTo(self.backgroundImg_)
    if display.width / display.height > 960 / 640 then
        self.backgroundImg_:setScale(display.width / 960)
    else
        self.backgroundImg_:setScale(display.height / 640)
    end
end

function DiceScene:createDiceBg_()
    self:createFloorBg_()
    self.bg_ = display.newNode():pos(display.cx,display.cy):addTo(self.nodes.backgroundNode)
    -- table
    self.lefttab_ = display.newSprite("#dice_room_desk.png")
    self.lefttab_:setScaleX(-1)
    self.lefttab_:addTo(self.bg_):pos(- (self.lefttab_:getContentSize().width -1) / 2,0)
    self.righttab_ = display.newSprite("#dice_room_desk.png")
    self.righttab_:addTo(self.bg_):pos((self.righttab_:getContentSize().width - 1) / 2,0)

    
    self.lefarea_ = display.newSprite("#dice_bet_area.png")
    self.lefarea_:addTo(self.bg_):pos(- (self.lefarea_:getContentSize().width) / 2,-10)
    self.rightarea_ = display.newSprite("#dice_bet_area.png")
    self.rightarea_:setScaleX(-1)
    self.rightarea_:addTo(self.bg_):pos((self.rightarea_:getContentSize().width) / 2,-10)

    self.titletext_  = display.newSprite("#dice_title_text.png")
    self.titletext_:addTo(self.bg_):pos(0,display.cy - self.titletext_:getContentSize().height)

    self.leftflag_ = display.newSprite("#dice_silver_flag.png")
    self.rightflag_ = display.newSprite("#dice_gold_flag.png")
    self.leftflag_:pos(-display.cx + 300,display.cy - self.leftflag_:getContentSize().height /2 + 10):addTo(self.bg_)
    self.rightflag_:pos(display.cx - 300,display.cy - self.rightflag_:getContentSize().height /2 + 10):addTo(self.bg_)

    self.tidlabel_ = ui.newTTFLabel({text = "", color = cc.c3b(0x80, 0xa0, 0xe1), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(35,display.cy - 120)
        :addTo(self.bg_)
end

function DiceScene:createTop_()
    local marginLeft = 32
    local marginTop = -30

    local returnPosX = marginLeft + 10
    local returnPosY = marginTop
    self.returnBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_bg_normal.png",pressed = "#common_btn_bg_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.onReturnClick_))
        :pos(returnPosX, returnPosY)
        :addTo(self.topNode_)

    self.returnBtnIcon_ = display.newSprite("#dice_top_return.png"):addTo(self.returnBtn_)

    local questionPosX = marginLeft + 100
    local questionPosY = marginTop
    self.questionBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_bg_normal.png",pressed = "#common_btn_bg_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.onQuestionClick_))
        :pos(questionPosX, questionPosY)
        :addTo(self.topNode_)
    self.questionBtnIcon_ = display.newSprite("#dice_top_question.png"):addTo(self.questionBtn_)

    local shopPosX = display.right - 56
    local shopPosY = marginTop
    self.shopNode_ = display.newNode()
    self.shopNode_:pos(shopPosX,shopPosY):addTo(self.topNode_)

    self.shopBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_bg_normal.png",pressed = "#common_btn_bg_pressed.png"})
            :onButtonClicked(buttontHandler(self, self.onShopClick_))
            :addTo(self.shopNode_)
    self.shopBtnIcon_ = display.newSprite("#room_market_icon.png"):addTo(self.shopBtn_)

    local userInfoPosX = display.right - 142
    local userInfoPosY = marginTop
    self.userInfoBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_bg_normal.png",pressed = "#common_btn_bg_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.onUserInfoClick_))
        :pos(userInfoPosX, userInfoPosY)
        :addTo(self.topNode_)
    self.userInfoBtnIcon_ = display.newSprite("#dice_top_userinfo.png"):addTo(self.userInfoBtn_)
end

function DiceScene:setRoomInfoText(roomInfo)
    self.tidlabel_:setString(bm.LangUtil.getText("DICE","ROOM_ID" ,roomInfo.tid))
end

function DiceScene:onReturnClick_()
    local needConfirm = self.ctx.model.isbet_
    if needConfirm then
        self.quitDialog = nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("DICE", "TO_HALL_CONFIRM"), 
                hasFirstButton = true,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        nk.socket.HallSocket:sendLogoutDice()
                        self:doBackToHall()
                    end
                end
            }):show()
    else
        nk.socket.HallSocket:sendLogoutDice()
        self:doBackToHall()
    end
end

function DiceScene:onQuestionClick_()
    QuestionPopup.new(self.ctx):show()
    -- self:showResultPopup(-100,1)
end

function DiceScene:showResultPopup(money,wintype)
    self.resultPopup_ = DiceResultPopup.new(money,wintype):show()
end

function DiceScene:hideResultPopup()
    if self.resultPopup_ and self.resultPopup_.hidePanel then
        self.resultPopup_:hidePanel()
        self.resultPopup_ = nil
    end
end

function DiceScene:onShopClick_()
    local tab_ = 1
    StorePopup.new(tab_):showPanel()
end

function DiceScene:onUserInfoClick_()
    AllUserInfoPopup.new(self.ctx):show()
end

function DiceScene:doBackToHall(msg)
    if self.isback_ then
        return
    end
    self.isback_ = true
    local msg = msg or bm.LangUtil.getText("ROOM", "OUT_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.onLoadedHallTexture_))
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        :pos(display.cx, display.cy)
        :addTo(self, 100)
end

function DiceScene:onLoadedHallTexture_()
    app:enterHallScene({bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)})
end

function DiceScene:onExit()
end

function DiceScene:onCleanup()
    self.controller:dispose()
end

return DiceScene