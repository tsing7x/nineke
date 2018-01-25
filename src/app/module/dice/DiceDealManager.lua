--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-01 17:02:42
--
local DiceDealManager = class("DiceDealManager")
local P = import(".views.DiceViewPosition")
local DiceClock = import(".views.DiceClock")
local DiceDealInfoPopup = import(".views.DiceDealInfoPopup")

function DiceDealManager:ctor()
end

function DiceDealManager:createNodes()
    self.dealnode_ = display.newNode():addTo(self.scene.nodes.dealNode)
    local PokerCard = nk.ui.PokerCard
    self.silverCards_ = {}
    self.goldCards_ = {}
    self.silverWin_ = display.newScale9Sprite("#dice_win_silver.png", 0, 0, cc.size(162, 143))
            :pos(300, display.cy + 250)
            :addTo(self.dealnode_):hide()
    self.goldWin_ = display.newScale9Sprite("#dice_win_gold.png", 0, 0, cc.size(170, 150))
            :pos(display.width - 300, display.cy + 250)
            :addTo(self.dealnode_):hide()
    for i = 1,3 do
        self.silverCards_[i] = PokerCard.new():pos(300 - 2 * 26 + 26*i,display.cy + 250)
            :addTo(self.dealnode_)
        self.silverCards_[i]:showBack()
        self.goldCards_[i] = PokerCard.new():pos(display.width - 300 - 2*26 + 26*i,display.cy + 250)
            :addTo(self.dealnode_)
        self.goldCards_[i]:showBack()
    end

    self.silverTypeNode = display.newNode():addTo(self.dealnode_):pos(300,display.cy + 230)
    self.goldTypeNode = display.newNode():addTo(self.dealnode_):pos(display.width - 300,display.cy + 230)

    self.silverTypeBg = display.newSprite("#dice_silver_cardtype.png"):addTo(self.silverTypeNode,1)
    self.goldTypeBg = display.newSprite("#dice_gold_cardtype.png"):addTo(self.goldTypeNode,1)

    self.silverTypeLabel = ui.newTTFLabel({text = "", color = cc.c3b(120, 120, 120), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :addTo(self.silverTypeNode,2)
    self.goldTypeLabel = ui.newTTFLabel({text = "", color = cc.c3b(167, 119, 35), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :addTo(self.goldTypeNode,2)

    self.clock_ = DiceClock.new():addTo(self.dealnode_):pos(display.cx,display.cy + 240):hide()
    self:hideAllCards()
    self:hideCardType()

    self.animnode_ = display.newNode():addTo(self.dealnode_)
end

function DiceDealManager:hideAllCards()
    for i = 1,3 do
        self.silverCards_[i]:hide()
        self.goldCards_[i]:hide()
    end
end

function DiceDealManager:showCardAndDeal()
    self:showAllCardsBack()
end

function DiceDealManager:showAllCardsBack()
    for i = 1,3 do
        self.silverCards_[i]:show()
        self.goldCards_[i]:show()
        self.silverCards_[i]:showBack()
        self.goldCards_[i]:showBack()
    end
    self:hideCardType()
end

function DiceDealManager:setCardsResult(data)
    for i = 1,3 do
        self.goldCards_[i]:setCard(data.cards2[i])
        self.silverCards_[i]:setCard(data.cards1[i])
    end
    self:filpAllCards()
    self.gameSchedulerPool:delayCall(function()
        self:showCardType(data.type1,data.type2,data.res)
    end, 1)
end

function DiceDealManager:filpAllCards()
    for i = 1,3 do
        self.silverCards_[i]:show()
        self.goldCards_[i]:show()
        self.silverCards_[i]:flip()
        self.goldCards_[i]:flip()
    end
end

function DiceDealManager:showCardType(silvertype,goldtype,res)
    self.silverTypeNode:show()
    self.silverTypeLabel:setString(self:getTypeString(silvertype))
    self.goldTypeNode:show()
    self.goldTypeLabel:setString(self:getTypeString(goldtype))
    self.wintypebg_ = display.newSprite("#dice_win_bg.png")
    if res == 1 then
        self.wintypebg_:addTo(self.silverTypeNode)
        self.silverWin_:show()
    else
        self.wintypebg_:addTo(self.goldTypeNode)
        self.goldWin_:show()
    end
    self.wintypebg_:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(1, 180), 
            cc.RotateTo:create(1, 360)
        })))
end

function DiceDealManager:getTypeString(type)
    local typeStr = ""
    if type > 9 then
        typeStr = bm.LangUtil.getText("COMMON", "CARD_TYPE")[1][type - 10]
    else
        typeStr = bm.LangUtil.getText("COMMON", "CARD_TYPE")[type]
    end
    return typeStr
end

function DiceDealManager:hideCardType()
    self.silverTypeNode:hide()
    self.goldTypeNode:hide()
    self.silverWin_:hide()
    self.goldWin_:hide()
    if self.wintypebg_ then
        self.wintypebg_:stopAllActions()
        self.wintypebg_:removeFromParent()
        self.wintypebg_ = nil
    end
end

function DiceDealManager:showClock(timeout,callback)
    if self.clock_ then
        self.clock_:show()
        self.clock_:startCountDown(timeout,function()
                self.clock_:hide()
                if callback then
                    callback()
                end
            end)
    end
end

function DiceDealManager:stopClock()
    if self.clock_ then
        self.clock_:stop()
        self.clock_:hide()
    end
end

function DiceDealManager:showWinType(wintypes)
    if not self.wintypes_ then
        self.wintypes_ = {}
    end
    for i,v in pairs(wintypes) do
        local typeNode = display.newNode():addTo(self.dealnode_)
        typeNode:setCascadeOpacityEnabled(true)
        local typelightbg = display.newScale9Sprite("#dice_show_win.png",0,0,cc.size(P.BetTypeArea[v.wintype].width-4,P.BetTypeArea[v.wintype].height + 30 - 4))
            :addTo(typeNode)
        local position = P.BetTypePosition[v.wintype]
        typeNode:pos(position.x,position.y + 15)
        typeNode:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.FadeOut:create(0.4),cc.FadeIn:create(0.4))))
        table.insert(self.wintypes_,typeNode)
    end
end

function DiceDealManager:showStartAnim()
    self:hideAllCards()
    self.modal_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width, display.height))
            :pos(display.cx, display.cy)
            :addTo(self.animnode_)
    
    nk.SoundManager:playSound(nk.SoundManager.DICE_VS)
    local path = "dragonbones/fla_VS/"
    self.vsanim_ = dragonbones.new({
            skeleton=path .. "skeleton.xml",
            texture=path .. "texture.xml",
            armatureName="fla_VS",
            animationName="",
            skeletonName="fla_VS",
        })
        :pos(display.cx,display.cy + 50)
        :addTo(self.animnode_,2)
    self.vsanim_:getAnimation():play()
    self.gameSchedulerPool:delayCall(function()
        if self.vsanim_ then
            self.vsanim_:removeFromParent()
            self.vsanim_ = nil
        end
        if self.modal_ then
            self.modal_:removeFromParent()
            self.modal_ = nil
        end
        self:showSendCardAnim()
    end, 1.5)
end

function DiceDealManager:hideStartAnim()
    if self.vsanim_ then
        self.vsanim_:removeFromParent()
        self.vsanim_ = nil
    end
    if self.modal_ then
        self.modal_:removeFromParent()
        self.modal_ = nil
    end
    
end

function DiceDealManager:showSendCardAnim()
    local function spawn(actions)
        if #actions < 1 then return end
        if #actions < 2 then return actions[1] end

        local prev = actions[1]
        for i = 2, #actions do
            prev = cc.Spawn:create(prev, actions[i])
        end
        return prev
    end
    for i = 1,3 do
        self.silverCards_[i]:showBack()
        self.silverCards_[i]:show()
        self.silverCards_[i]:setCascadeOpacityEnabled(true)
        self.silverCards_[i]:setOpacity(0)
        self.silverCards_[i]:pos(300+100,display.cy + 250)
        self.silverCards_[i]:runAction(transition.sequence({cc.DelayTime:create((i-1)*0.3),spawn({cc.FadeIn:create(0.1),
            cc.MoveTo:create(0.3,cc.p(300 - 2 * 26 + 26*i,display.cy + 250))})}))


        self.goldCards_[i]:showBack()
        self.goldCards_[i]:show()
        self.goldCards_[i]:setCascadeOpacityEnabled(true)
        self.goldCards_[i]:setOpacity(0)
        self.goldCards_[i]:pos(display.width-300-100,display.cy + 250)
        self.goldCards_[i]:runAction(transition.sequence({cc.DelayTime:create((i-1)*0.3),spawn({cc.FadeIn:create(0.1),
            cc.MoveTo:create(0.3,cc.p(display.width-300-2*26 + 26*i,display.cy + 250))})}))
    end
end

function DiceDealManager:onClickDeal(dealId)
    DiceDealInfoPopup.new(self.ctx,dealId):show()
end

function DiceDealManager:startSound()
end

function DiceDealManager:stopSound()
end

function DiceDealManager:reset()
    self:hideCardType()
    if self.wintypes_ then
        for i,v in pairs(self.wintypes_) do
            v:stopAllActions()
            v:removeFromParent()
            v = nil
        end
    end
    self.wintypes_ = {}
end

return DiceDealManager