--
-- Author: Jonah0608@gmail.com
-- Date: 2016-07-04 17:37:21
--
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local CARD_GAP = 60

local RoomViewPosition = import(".RoomViewPosition")
local P = RoomViewPosition.DealCardPosition
local ClockProgressTimer = import(".ClockProgressTimer")
local Clock = import(".Clock")
local SelectCard = class("SelectCard",function()
    return display.newNode()
end)

function SelectCard:ctor(sizeScale,cardNum)
    self.shouldShake = true
    if sizeScale then self:setScale(sizeScale) end
    -- 扑克牌容器
    local PokerCard = nk.ui.PokerCard
    self.cards = {}
    self.selected_ = {}
    self.cardsbtn_ = {}
    self.selectbg_ = {}
    self.selectboarder = {}
    self.cardNum_ = cardNum
    self.selectTable = {}

    local str = bm.LangUtil.getText("ROOM_4K", "TIPS")[3]
    self.tipLabel = ui.newTTFLabel({text = str, color =cc.c3b(0xff,0xff,0x00), size = 26, align = ui.TEXT_ALIGN_CENTER})
    local size = self.tipLabel:getContentSize()
    self.tipbg = display.newScale9Sprite("#select_card_tip_bg.png",0,0,cc.size(size.width + 80,62),cc.rect(39, 39, 1, 1))
        :pos(0,135)
        :addTo(self)
        :hide()
    self.tipLabel:addTo(self.tipbg):pos((self.tipbg:getContentSize().width)/ 2 + 30,self.tipbg:getContentSize().height / 2)
    self:changeTips(0)
    for i = 1,self.cardNum_ do
        self.selected_[i] = 0
        self.cards[i] = PokerCard.new():pos((i-(self.cardNum_ + 1) / 2) * CARD_GAP, 0):addTo(self):scale(1.1)
        self.selectbg_[i] = display.newScale9Sprite("#select_card_shader.png",0,0,cc.size(80,130),cc.rect(20, 20, 1, 1))
            :pos(-13,-5)
            :addTo(self.cards[i])
            :hide()
        self.selectboarder[i] = display.newScale9Sprite("#select_card_border.png",0,0,cc.size(80,108))
            :pos(0,0)
            :addTo(self.cards[i],5)
            :hide()
        self.cardsbtn_[i] = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9 = true})
                :pos( 0,0)
                :setButtonSize(80,108)
                :addTo(self.cards[i],0,i)
                :onButtonClicked(handler(self, self.onCardsBtn_))
        self.cardsbtn_[i]:setButtonEnabled(false)
    end

    self.btnNode_ = display.newNode():pos(0,-120):addTo(self)
    self.foldbtn_ = cc.ui.UIPushButton.new({normal = "#room_opr_btn_up_red.png", pressed = "#room_opr_btn_down_red.png"}, {scale9 = true})
            :pos(-112,0)
            :setButtonSize(202,73)
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("ROOM_4K", "BTN_FOLD"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0,5)
            :addTo(self.btnNode_)
            :onButtonClicked(handler(self, self.onfoldcard_))
    self.foldbtn_:setColor(cc.c3b(150, 150, 150))
    self.foldbtn_:setButtonEnabled(false)

    self.dropbtn_ = cc.ui.UIPushButton.new({normal = "#room_opr_btn_up.png", pressed = "#room_opr_btn_down.png"}, {scale9 = true})
            :pos(112, 0)
            :setButtonSize(202,73)
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("ROOM_4K", "BTN_DROP"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0,5)
            :addTo(self.btnNode_)
            :onButtonClicked(handler(self, self.onDropCard_))
    self.dropbtn_:setColor(cc.c3b(150, 150, 150))
    self.dropbtn_:setButtonEnabled(false)
    self.btnNode_:pos(0,-300)
    transition.moveTo(self.btnNode_,{time=2.0,y = -120})
end


function SelectCard:setCards(cardsValue)
    assert(type(cardsValue) == "table" and (#cardsValue == 4 or #cardsValue == 5), "cardsValue should be a table with length equals (4 or 5)")
    self.cardsvalue = cardsValue
    for i, cardUint in ipairs(cardsValue) do
        self.cards[i]:setCard(cardUint)
    end
    return self
end

function SelectCard:flipAllCards()
    for i = 1, self.cardNum_ do
        self.cards[i]:flip()
        self.cardsbtn_[i]:setButtonEnabled(true)
    end
    if not self.tipbgRemove then
        self.tipbg:show()
    end
    self.foldbtn_:setButtonEnabled(true)
    self.foldbtn_:setColor(cc.c3b(255, 255, 255))
    self.dropbtn_:setButtonEnabled(true)
    self.dropbtn_:setColor(cc.c3b(255, 255, 255))
    -- self.foldbtn_:show()
    -- self.dropbtn_:show()
    -- self.btnNode_:pos(0,-300)
    -- transition.moveTo(self.btnNode_,{time=0.5,y = -120})
    self:playDBCountDownAnim()
end

function SelectCard:showWithIndex(...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        for i = 1, numArgs do
            local value = select(i, ...)
            if value >= 1 and value <= self.cardNum_ then
                self.cards[value]:showBack()
            end
        end
    end
    return self
end

function SelectCard:changeTips(count)
   local tipStr  = bm.LangUtil.getText("ROOM_4K", "TIPS")
   local str = tipStr[count + 1]
   self.tipLabel:setString(str)
   -- local size = self.tipLabel:getContentSize()
   -- self.tipbg:setContentSize(cc.size(size.width + 20,size.height + 2))
   -- self.tipLabel:pos((self.tipbg:getContentSize().width)/ 2 ,self.tipbg:getContentSize().height / 2)
end

function SelectCard:onfoldcard_()
    -- self.shouldShake = false
    -- self:stopShake()
    nk.socket.RoomSocket:foldCards4K()
end

function SelectCard:onDropCard_()
    -- self.shouldShake = false
    -- self:stopShake()
    local holdcards = {}
    local foldcards = {}
    for i,v in pairs(self.selected_) do 
        if v == 1 then
            table.insert(foldcards,self.cardsvalue[i])
        else
            table.insert(holdcards,self.cardsvalue[i])
        end
    end
    nk.SoundManager:playSound(nk.SoundManager.DROPCARD)
    nk.socket.RoomSocket:dropCards4K(holdcards,foldcards)
end

function SelectCard:hideItem()
    self.shouldShake = false
    self:stopShake()
    for i = 1,4 do
        self.cardsbtn_[i]:setButtonEnabled(false)
        self.selectbg_[i]:hide()
        self.selectboarder[i]:hide()
    end
    self.dropbtn_:setButtonEnabled(false)
    self.foldbtn_:setButtonEnabled(false)
    self.dropbtn_:hide()
    self.foldbtn_:hide()
    self.shouldShake = false
    self:stopShake()
    self:closeSound()
end

function SelectCard:showDropCardAnim(holdcards,callback)
    self:hideItem()
    self:changeTips(3)
    local foldindex = 1
    local holdindex = 1
    local foldcards = {}
    for i = 1,self.cardNum_ do
        local carduint = self.cards[i].cardUint_
        local inHold = false
        for k,v in ipairs(holdcards) do
            if carduint == v then
                inHold = true
                break
            end
        end
        local card = self.cards[i]
        if inHold then
            transition.moveTo(card, {time=0.5, x= P[5].x + 60 + 28 *(holdindex - 1.5) - display.cx, y=P[5].y - display.cy + 150, onComplete=function()
                self.cards[i]:hide()
                if callback then
                    callback(true)
                end
            end})
            card:rotateTo(0.5, (holdindex-2) * 12)
            holdindex = holdindex + 1
        else
            table.insert(foldcards,carduint)
            transition.scaleTo(card, {scaleX=32 / 116, scaleY=32 / 116, time=0.5,onComplete=function()
                end})
            transition.moveTo(card, {time=0.5, x= P[10].x + 30 * foldindex - display.cx, y=P[10].y - display.cy + 150, onComplete=function()
                self.cards[i]:hide()
                if callback then
                    callback(false,foldcards)
                end
            end})
            card:rotateTo(0.5, 720)
            foldindex = foldindex + 1
        end
    end

end

function SelectCard:showFoldCardAnim(callback)
    self:hideItem()
    self:changeTips(3)
    callback()
    for i = 1,self.cardNum_ do
        self.cards[i]:hide()
        callback()
    end
end

function SelectCard:delayRemoveCard()
    self.tipbg:hide()
    self.tipbgRemove = true
    self:hideItem()
end

function SelectCard:onCardsBtn_(args)
    tag = args.target:getTag()
    self:onCardSelectByIndex(tag)
    nk.SoundManager:playSound(nk.SoundManager.SELECTCARD)
end

function SelectCard:onCardSelectByIndex(index)
    -- self.shouldShake = false
    -- self:stopShake()
    if self.selected_[index] == 1 then
        self.selected_[index] = 0
        self.cards[index]:pos((index-(self.cardNum_ + 1) / 2) * CARD_GAP, 0)
        self.selectboarder[index]:hide()
        self.selectbg_[index]:hide()
        self:removeTableItem(self.selectTable,"tag" .. tostring(index))
    else
        self.selected_[index] = 1
        self.cards[index]:pos((index-(self.cardNum_ + 1) / 2) * CARD_GAP, 20)
        self.selectboarder[index]:show()
        self.selectbg_[index]:show()
        table.insert(self.selectTable,"tag" .. tostring(index))
    end
    if #self.selectTable > 2 then
        local v = self.selectTable[1]
        self:onCardSelectByIndex(tonumber(string.sub(v,4,4)))
    end
    local count = #self.selectTable
    if count > 2 then count = 2 end
    self:changeTips(count)
end

function SelectCard:removeTableItem(list,item)
    for i,v in pairs(list) do
        if v == item then
            table.remove(list,i)
            break
        end
    end
end

function SelectCard:startShake()
    if self.shouldShake then
        self.cards[self.cardNum_ - 1]:shake()
        self.cards[self.cardNum_]:shake()
        self.isShake_ = true
        self.soundId_ = nk.SoundManager:playSound(nk.SoundManager.CLOCK, true)
        if self.clock_ then
            self.clock_:startShake()
        end
    end
end

function SelectCard:stopShake()
    if self.isShake_ then
        self.cards[self.cardNum_ - 1]:stopShake()
        self.cards[self.cardNum_]:stopShake()
        self:closeSound()
        if self.clock_ then
            self.clock_:stopShake()
        end
    end
end

function SelectCard:closeSound()
    if self.soundId_ then
        audio.stopSound(self.soundId_)
        self.soundId_ = nil
    end
end

function SelectCard:onCleanup()
    self:stopDBCountDownAnim()
    self:closeSound()
end

function SelectCard:setTime(time)
    self.time_ = time
end

function SelectCard:playDBCountDownAnim()
    if not self.time_ then self.time_ = 15 end
    self.clock_ = Clock.new():addTo(self.tipbg):pos(31,31)
    ClockProgressTimer.new(self.time_):addTo(self.clock_, 3)--yk test
    self.clock_:startCountDown(self.time_,handler(self,self.stopDBCountDownAnim))
    if self.time_ > 5 then
        self.delayHandle_ = scheduler.performWithDelayGlobal(handler(self,self.startShake), self.time_ - 5)
    else
        self:startShake()
    end
end

function SelectCard:stopDBCountDownAnim()
    if self.clock_ then
        self.clock_:stop()
        self.clock_:removeFromParent()
        self.clock_ = nil
    end
    if self.tipbg then
        self.tipbg:hide()
    end
end

return SelectCard