--
-- Author: tony
-- Date: 2014-07-08 14:28:57
--
local HandCard = import(".HandCard")
local FoldCards = import(".FoldCards")
local AnimationIcon = import("boomegg.ui.AnimationIcon")
local SeatStateMachine = import("app.module.room.model.SeatStateMachine")
local GiftShopPopUp = import("app.module.gift.GiftShopPopup")
local LoadGiftControl = import("app.module.gift.LoadGiftControl")
local VipIcon = import("app.module.vip.VipIcon")
local ExpressionConfig = import(".ExpressionConfig").new()

local SeatView = class("SeatView", function() 
    return display.newNode()
end)

SeatView.CLICKED = "SeatView.CLICKED"
SeatView.WIDTH = 108
SeatView.HEIGHT = 164

function SeatView:ctor(ctx, seatId)
    self:retain()
    self.ctx = ctx
    self.nodeCleanup_ = true
    self.isInMatch_ = self.ctx.model.isInMatch_
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    --2 桌子背景
    self.background_ = display.newScale9Sprite("#room_seat_bg.png", 0, 0, cc.size(SeatView.WIDTH, SeatView.HEIGHT)):addTo(self, 2)

    --3 赢牌座位金色边框
    self.winBorderBatch_ = display.newBatchNode("room_texture.png", 3):addTo(self, 3, 3):hide()
    self.winBorder_ = display.newSprite("#room_seat_win_border.png"):addTo(self.winBorderBatch_)

    --白色星星1
    self.star1_ = display.newSprite("#room_you_win_flash.png"):addTo(self.winBorderBatch_)
    --白色星星2
    self.star2_ = display.newSprite("#room_you_win_flash.png"):addTo(self.winBorderBatch_)

    self.seatId_ = seatId
    self.positionId_ = seatId + 1
    self.seatImageLoaderId_ = nk.ImageLoader:nextLoaderId()
    --坐下图片
    self.sitdown_ = display.newSprite("#room_sitdown_icon.png")
    --用户头像容器
    self.image_ = display.newNode():add(display.newSprite("#common_male_avatar.png"), 1, 1):pos(0, -100)

    --4 用户头像剪裁节点
    self.clipNode_ = cc.ClippingNode:create()

    local stencil = display.newDrawNode()
    local pn = {{-50, -50}, {-50, 50}, {50, 50}, {50, -50}}  
    local clr = cc.c4f(255, 0, 0, 255)  
    stencil:drawPolygon(pn, clr, 1, clr)

    self.clipNode_:setStencil(stencil)
    self.clipNode_:addChild(self.sitdown_, 1, 1)
    self.clipNode_:addChild(self.image_, 2, 2)
    self.clipNode_:addTo(self, 4, 4)

    --5 头像灰色覆盖
    self.cover_ = display.newRect(100, 100, {fill=true, fillColor=cc.c4f(0, 0, 0, 0.6)})
        :addTo(self, 5, 5)
        :hide()

    -- VIP坐下动画
    self.vipSeatDownLight = display.newSprite("#pop_vip_light.png"):pos(0, 0):scale(1.2):addTo(self, 0, 0):hide()

    --6 状态文字
    if appconfig.LANG == "vn" then
        self.state_ = ui.newTTFLabel({text = "Seat" .. seatId, size = 20, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x0) })
    else
        self.state_ = ui.newTTFLabel({text = "Seat" .. seatId, size = 24, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x0) })
    end
    self.state_:pos(0, 64):addTo(self, 6, 6)

    --7 座位筹码文字
    self.chips_ = ui.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x00)})
        :pos(0, -66)
        :addTo(self, 7, 7)

     --8 手牌
    self.handCards_ = HandCard.new(0.8):addTo(self, 8, 8):hide()
    self.foldcards_ = FoldCards.new():addTo(self,20,9)
    -- 礼物
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        self.giftImage_ = AnimationIcon.new("#gift-icon-up.png", 0.6, 0.5, buttontHandler(self, self.openGiftPopUpHandler))
            :addTo(self, 10, 10):hide()
        self.giftImage_:retain()
        self.giftImage_:setNodeEventEnabled(false)
    end
    

    --9 winner动画
    self.winnerAnimBatch_ = display.newBatchNode("room_texture.png", 8):addTo(self, 29, 29):hide()
    --winner文字

    self.winner_ = display.newSprite("#room_seat_win_winner.png"):pos(0, -4):addTo(self.winnerAnimBatch_)
    --星星1
    self.winnerStar1_ = display.newSprite("#room_you_win_star.png"):addTo(self.winnerAnimBatch_)
    --星星2
    self.winnerStar2_ = display.newSprite("#room_you_win_star.png"):addTo(self.winnerAnimBatch_)
    --星星3
    self.winnerStar3_ = display.newSprite("#room_you_win_star.png"):addTo(self.winnerAnimBatch_)
    --星星4
    self.winnerStar4_ = display.newSprite("#room_you_win_star.png"):addTo(self.winnerAnimBatch_)

    --10 牌型背景
    self.cardTypeBackground_ = display.newScale9Sprite("#room_seat_card_type_light_bg.png", 0, 0, cc.size(118,32)):addTo(self, 10, 10):hide()

    --11 牌型文字
    self.cardType_ = ui.newTTFLabel({
        size = 24,
        align = ui.TEXT_ALIGN_CENTER,
        valign = ui.TEXT_VALIGN_CENTER,
        color=cc.c3b(0x0d, 0xd3, 0x3e)
    }):addTo(self, 11, 11):hide()

    --座位触摸
    self.touchHelper_ = bm.TouchHelper.new(self.background_, handler(self, self.onTouch_))
    self.touchHelper_:enableTouch()

    --初始为站起状态
    self:standUpState_()
end

function SeatView:enableTouch()
    if self.touchHelper_ then
        self.touchHelper_:enableTouch()
    end
end

function SeatView:onCleanup()
end

function SeatView:playSitDownAnimation(onCompleteCallback)
    transition.moveTo(self.image_:pos(0, 100):show(), {time=0.5, easing="backOut", x=0, y=0})
    transition.moveTo(self.sitdown_:pos(0, 0):show(), {time=0.5, easing="backOut", x=0, y=-100, onComplete=function() 
        self.sitdown_:hide()
        if onCompleteCallback then
            onCompleteCallback()
        end
    end})

    if self.seatData_ then
        local isVip, vipconfig = self:checkIsVip_()
        if isVip then
            self.vipSeatDownLight:show()
            self.vipSeatDownLight:runAction(cc.RepeatForever:create(transition.sequence({
                cc.RotateTo:create(2, 180),
                cc.RotateTo:create(2, 360)
            })))

            self.vipSeatDownLight:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function() 
                self.vipSeatDownLight:stopAllActions()
                self.vipSeatDownLight:hide()
            end)}))
        else
            self.vipSeatDownLight:hide()
        end
    else
        self.vipSeatDownLight:hide()
    end
end

function SeatView:playStandUpAnimation(onCompleteCallback)
    transition.moveTo(self.image_:pos(0, 0):show(), {time=0.5, easing="backOut", x=0, y=110})
    transition.moveTo(self.sitdown_:pos(0, -100):show(), {time=0.5, easing="backOut", x=0, y=0, onComplete=function() 
        self.image_:hide()
        if onCompleteCallback then
            onCompleteCallback()
        end
    end})
    if self.vipIcon then
        self.vipIcon:hide()
    end
end

function SeatView:playAllInAnimation(onCompleteCallback)
    if not self.db_node then
        self.db_node = display.newNode():addTo(self, 100):pos(0, 4)
    else
        self.db_node:pos(0, 4)
    end
    if self.db then
        self.db:removeFromParent()
    end 
    local path = "dragonbones/fla_allinQ/"
    self.db = dragonbones.new({
            skeleton=path .. "skeleton.xml",
            texture=path .. "texture.xml",
            armatureName="fla_allinQ",
            aniName="",
            skeletonName="fla_allinQ",
        })
        :addTo(self.db_node)
    self.db:getAnimation():play()
end

function SeatView:fade()
    transition.execute(self.cover_:show(), cc.FadeIn:create(0.2))
end

function SeatView:unfade()
    self.cover_:hide()
end

function SeatView:sitDownState_()
    self.image_:stopAllActions()
    self.sitdown_:stopAllActions()
    self.image_:pos(0, 0):show()
    self.sitdown_:pos(0, -100):hide()
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        self.giftImage_:show()
    end
end

function SeatView:standUpState_()
    self.image_:stopAllActions()
    self.sitdown_:stopAllActions()
    self.image_:pos(0, 100):hide()
    self.sitdown_:pos(0, 0):show()
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        self.giftImage_:hide()
        if self.giftAnimNode_ then
            self.giftAnimNode_:hide()
        end
    end
    
end

function SeatView:userImageLoadCallback_(success, sprite)
    if success and self.image_ then
        local img = self.image_:getChildByTag(1)
        if img then
            img:removeFromParent()
        end
        local spsize = sprite:getContentSize()
        if spsize.width > spsize.height then
            sprite:scale(100 / spsize.width)
        else
            sprite:scale(100 / spsize.height)
        end
        spsize = sprite:getContentSize()
        local seatSize = self:getContentSize()
        
        sprite:pos(seatSize.width * 0.5, seatSize.height * 0.5):addTo(self.image_, 1, 1)
    end
end

function SeatView:isEmpty()
    return not self.seatData_
end

function SeatView:getPositionId()
    return self.positionId_
end

function SeatView:setPositionId(id)
    self.positionId_ = id
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        if id then
            if ((id == 1) or (id == 2) or (id == 3) or (id == 5)) then
                self.giftImage_:pos(-55, 0)
            else
                self.giftImage_:pos(55, 0)
            end
            if self.giftAnimNode_ then
                local px, py = self.giftImage_:getPosition()
                self.giftAnimNode_:pos(px, py)
            end
        end
    end

end

function SeatView:resetToEmpty()
    self.seatData_ = nil
    self:updateState()
end

function SeatView:setSeatData(seatData)
    self.seatData_ = seatData
    
    if not (self.showedHandCardAnim_ and self.showedHandCardAnimRound_ == self.ctx.model.gameInfo.roundCount) then
        self.showedHandCardAnim_ = false
        if seatData and seatData.isSelf then
            self.handCards_:pos(100, -20):scale(1)
            self.cardTypeBackground_:pos(100, -60)
            self.cardType_:pos(100, -60)
        else
            self.handCards_:pos(0, 26):scale(0.8)
            self.cardTypeBackground_:pos(0, -37)
            self.cardType_:pos(0, -37)
        end
    end
    
    if not seatData then
        self:reset()
        self:standUpState_()
    else
        self:sitDownState_()
        local img = self.image_:getChildByTag(1)
        if img then
            img:removeFromParent()
        end
        if seatData.gender == "f" then
            display.newSprite("#common_female_avatar.png"):addTo(self.image_, 1, 1)
            if self.isInMatch_ then
                self.state_:setTextColor(cc.c3b(0xff, 0x61, 0xc2))
            end
        else
            display.newSprite("#common_male_avatar.png"):addTo(self.image_, 1, 1)
            if self.isInMatch_ then
                self.state_:setTextColor(cc.c3b(0xff, 0xd1, 0x0))
            end
        end

        self:updateVipIcon()
        
        if string.len(seatData.img) > 5 then
            local imgurl = seatData.img
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=200&height=200"
                else
                    imgurl = imgurl .. "?width=200&height=200"
                end
            end
            nk.ImageLoader:loadAndCacheImage(self.seatImageLoaderId_,
                imgurl, 
                handler(self,self.userImageLoadCallback_),
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
            )
        end
        
        if nk.config.GIFT_SHOP_ENABLED and nk.userData.GIFT_SHOP == 1 then
            if self.giftUrlReqId_ then
                LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
            end
            self.gift_Id_ = seatData.giftId
            self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(seatData.giftId, function(url)
                self.giftUrlReqId_ = nil
                if url and string.len(url) > 5 then
                    self.giftImage_:onData(url, AnimationIcon.MAX_GIFT_DW, AnimationIcon.MAX_GIFT_DH)
                else
                    self.giftImage_:onData(nil)
                end
            end)
        end
    end

end

function SeatView:updateVipIcon()
    if self.seatData_ then
        local isVip, vipconfig = self:checkIsVip_()

        if isVip then
            local viplevel = tonumber(vipconfig.vip.level)

            --yk 以前vip字段都是0，是个bug，找不到vip字段哪来的，在这里强制设置
            self.seatData_.vip = viplevel

            if self.vipIcon then
                self.vipIcon:setLevel(viplevel)
                self.vipIcon:show()
            else
                self.vipIcon = VipIcon.new(118, 116, viplevel):pos(0, 0):addTo(self, 6, 6)
            end
        else
            if self.vipIcon then
                self.vipIcon:hide()
            end
        end
    else
        if self.vipIcon then
            self.vipIcon:hide()
        end
    end
end

function SeatView:getSeatData()
    return self.seatData_
end

function SeatView:checkDynamicGift(gift_Id)
    local dynamic = -1
    -- if nk.config.SONGKRAN_ACTIVITY_ENABLED then
        if gift_Id then
            local id = tonumber(gift_Id)
            if id == 7013 or id == 1082 then
                dynamic = 615
            elseif id == 7011 or id == 1080 then
                dynamic = 1202
            elseif id == 7012 or id == 1081 then
                dynamic = 1293
            end
        end
    -- end
    --print("checkDynamicGift " .. gift_Id .. ",dynamic = " .. dynamic)
    if dynamic > 0 then
        self:playDynamicGift(dynamic)
    else
        self:stopGiftAnim_()
    end
end

function SeatView:playDynamicGift(gift_Id)
    if self.giftImage_ then
        local animName = "gift-" .. gift_Id
        local anim = display.getAnimationCache(animName)
        if anim then
            print("playDynamicGift ", gift_Id)
            self:playGiftAnim_(gift_Id, anim)
        else
            display.addSpriteFrames("expressions/gift_frame_" .. gift_Id ..".plist", "expressions/gift_frame_" .. gift_Id ..".png", function()
                    if self.disposed_ then
                        display.removeSpriteFramesWithFile("expressions/gift_frame_" .. gift_Id ..".plist", "expressions/gift_frame_" .. gift_Id ..".png")
                        return
                    end
                    print("loaded ", gift_Id)
                    local config = ExpressionConfig:getConfig(gift_Id)
                    local frames = display.newFrames(gift_Id .. "_%04d.png", 1, config.frameNum, false)
                    local animation = display.newAnimation(frames, 1 / 8)
                    display.setAnimationCache(animName, animation)
                    
                    self:playGiftAnim_(gift_Id, animation)
                end)
            print("load.. ", gift_Id)
        end
    end
end

function SeatView:playGiftAnim_(gift_Id, anim)
    if self.giftImage_ then
        if self.giftAnimNode_ then
            self.giftAnimNode_:removeFromParent()
            self.giftAnimNode_ = nil
        end 
        local config = ExpressionConfig:getConfig(gift_Id)
        local px, py = self.giftImage_:getPosition()
        local sp = display.newSprite()
        sp:pos(px + config.adjustX, py + config.adjustY):addTo(self.giftImage_:getParent(), 20, 20)

        transition.playAnimationForever(sp, anim)

        self.giftImage_:hide()
        cc.ui.UIPushButton.new({normal = "#transparent.png"},{scale9 = true})
            :setButtonSize(42, 72)
            :pos(48, 24)
            :addTo(sp)
            :onButtonClicked(buttontHandler(self, self.openGiftPopUpHandler))
        self.giftAnimNode_ = sp
    end
end

function SeatView:stopGiftAnim_()
    if self.giftAnimNode_ then
        self.giftAnimNode_:removeFromParent()
        self.giftAnimNode_ = nil
        self.giftImage_:show()
    end
end

function SeatView:updateGiftUrl(gift_Id)
    if nk.config.GIFT_SHOP_ENABLED and nk.userData.GIFT_SHOP == 1 then
        if self.giftUrlReqId_ then
            LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
        end
        self.gift_Id_ = gift_Id
        self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(gift_Id, function(url)
            self.giftUrlReqId_ = nil
            if url and string.len(url) > 5 then
                self.giftImage_:onData(url)
            else
                self.giftImage_:onData(nil) 
            end
        end)
    end
end

function SeatView:updateHeadImage(imgurl)
    if string.len(imgurl) > 5 then
        if string.find(imgurl, "facebook") then
            if string.find(imgurl, "?") then
                imgurl = imgurl .. "&width=200&height=200"
            else
                imgurl = imgurl .. "?width=200&height=200"
            end
        end
        nk.ImageLoader:loadAndCacheImage(self.seatImageLoaderId_,
            imgurl, 
            handler(self,self.userImageLoadCallback_),
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
end

function SeatView:updateState()
    if self.seatData_ == nil then
        if self.ctx.model:isSelfInSeat() then
            self:hide()
        else
            self:show()
            self.state_:hide()
            self.chips_:hide()
            self.sitdown_:show()
            if self.userImage_ then
                self.userImage_:removeFromParent()
                self.userImage_ = nil
            end
        end
    else
        self:show()
        self.state_:show()
        self.chips_:show()
        self.sitdown_:hide()
        if appconfig.LANG == "vn" then
            self.state_:setString(nk.Native:getFixedWidthText("", 20, self.seatData_.statemachine:getStateText(), 110))
        else
            self.state_:setString(nk.Native:getFixedWidthText("", 24, self.seatData_.statemachine:getStateText(), 110))
        end
        if self.seatData_.seatChips < 100000 then
            self.chips_:setString(bm.formatNumberWithSplit(self.seatData_.seatChips))
        else
            self.chips_:setString(bm.formatBigNumber(self.seatData_.seatChips))
        end

        local sm = self.seatData_.statemachine
        local st = sm:getState()

        if st ~= SeatStateMachine.STATE_BETTING then
            self.handCards_:stopShakeAll()
        end

        if st == SeatStateMachine.STATE_WAIT_START or st == SeatStateMachine.STATE_FOLD then
            self.cover_:show()
        else
            self.cover_:hide()
        end

        if st == SeatStateMachine.STATE_FOLD then
            self.handCards_:addDarkWithNum(3)
        end
    end
end

function SeatView:setFoldCardValue(cards)
    if cards then
        printf("SeatView[%s]setFoldCardValue [%x %x %x][%s %s %s][%s %s %s]", self.seatId_ or -1, cards[1] or 0, cards[2] or 0, cards[3] or 0, cards[1] or 0, cards[2] or 0, cards[3] or 0, nk.getCardDesc(cards[1]), nk.getCardDesc(cards[2]), nk.getCardDesc(cards[3]))
    end
    self.foldcards_:setCards(cards)
end

function SeatView:showFoldCards()
    self.foldcards_:show()
    self.foldcards_:showFrontAll()
    self.foldcards_:addDarkAll()
end

function SeatView:hideFoldCards()
    self.foldcards_:hide()
end

function SeatView:setHandCardValue(cards)
    if cards then
        printf("SeatView[%s]setHandCardValue [%x %x %x][%s %s %s][%s %s %s]", self.seatId_ or -1, cards[1] or 0, cards[2] or 0, cards[3] or 0, cards[1] or 0, cards[2] or 0, cards[3] or 0, nk.getCardDesc(cards[1]), nk.getCardDesc(cards[2]), nk.getCardDesc(cards[3]))
    end
    self.handCards_:setCards(cards)
end

function SeatView:setHandCardNum(num)
    self.handCards_:setCardNum(num)
end

function SeatView:showHandCards()
    self.handCards_:show()
end

function SeatView:hideHandCards()
    self.handCards_:hide()
end

function SeatView:showHandCardBackAll()
    self.handCards_:showBackAll()
end

function SeatView:showHandCardFrontAll()
    self.handCards_:showFrontAll()
end

function SeatView:flipAllHandCards()
    self.handCards_:flipAll()
end

function SeatView:hideAllHandCardsElement()
    self.handCards_:hideAllCards()
end

function SeatView:showAllHandCardsElement()
    self.handCards_:showAllCards()
end

function SeatView:showHandCardsElement(idx)
    self.handCards_:showWithIndex(idx)
end

function SeatView:flipHandCardsElement(idx)
    self.handCards_:flipWithIndex(idx)
end

function SeatView:shakeAllHandCards()
    self.handCards_:shakeWithNum(3)
end

function SeatView:showHandCardsAnimation()
    local sequence = transition.sequence({
        cc.ScaleTo:create(0.1, 1.2),
        cc.MoveTo:create(0.35, cc.p(240, 165)),
        cc.ScaleTo:create(0.2, 0.8),
        cc.CallFunc:create(function() 
            nk.SoundManager:playSound(nk.SoundManager.SHOW_HAND_CARD)
        end),
    })
    self.handCards_:runAction(sequence)    
    self.showedHandCardAnimRound_ = self.ctx.model.gameInfo.roundCount
    self.showedHandCardAnim_ = true
end

function SeatView:showCardTypeIf()

    local getFrame = display.newSpriteFrame
    if self.seatData_ and self.seatData_.cardType and self.seatData_.cardType:getLabel() then
        if self.seatData_.cardType:isBadType() and self.seatData_.cardType:getCardTypeValue() then
            self.cardTypeBackground_:setSpriteFrame(getFrame("room_seat_card_type_dark_bg.png"))
        else
            self.cardTypeBackground_:setSpriteFrame(getFrame("room_seat_card_type_light_bg.png"))
        end
        self.cardTypeBackground_:setContentSize(118,32)
        self.cardTypeBackground_:show()
        self.cardType_:setString(self.seatData_.cardType:getLabel())
        self.cardType_:show()
    else
        self.cardTypeBackground_:hide()
        self.cardType_:hide()
    end
end

function SeatView:playExpChangeAnimation(expChange)
    if expChange > 0 then
        local node = display.newNode()
        node:setCascadeOpacityEnabled(true)
        local exp = display.newSprite("#room_seat_exp.png"):addTo(node)
        local num = ui.newTTFLabel({
            text = "+"..expChange, 
            color = cc.c3b(0x1D, 0xBC, 0xFC), 
            size = 24, 
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(node)
        local expW = exp:getContentSize().width
        local numW = num:getContentSize().width
        local w =  expW + numW
        exp:pos(w * -0.5 + expW * 0.5, 0)
        num:pos(w * 0.5 - numW * 0.5, 0)

        node:addTo(self, 99)
            :scale(0.4)
            :moveBy(0.8, 0, 92)
            :scaleTo(0.8, 1)
        node:runAction(transition.sequence({
            cc.FadeIn:create(0.4),
            cc.DelayTime:create(1.2),


            cc.FadeOut:create(0.2),
            cc.CallFunc:create(function()
                node:removeFromParent()
            end),
        }))
    end
end

function SeatView:playAutoBuyinAnimation(buyinChips)
    local buyInBg = display.newSprite("#buyin-action-yellowbackground.png")
        :addTo(self, 6)
    local buyInBgSize = buyInBg:getContentSize()
    buyInBg:pos(0, -SeatView.HEIGHT/2 + buyInBgSize.height/2)
    local buyInSequence = transition.sequence({
            cc.FadeIn:create(0.5),
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
                buyInBg:removeFromParent()
            end),
        })
    buyInBg:runAction(buyInSequence)

    local buyInLabelPaddding = 20
    local buyInLabel = ui.newTTFLabel({
            text = "+"..buyinChips, 
            color = cc.c3b(0xf4, 0xcd, 0x56), 
            size = 32, 
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self, 6):pos(0, -SeatView.HEIGHT/2 + buyInBgSize.height/2 + buyInLabelPaddding)

    local function spawn(actions)
        if #actions < 1 then return end
        if #actions < 2 then return actions[1] end

        local prev = actions[1]
        for i = 2, #actions do
            prev = cc.Spawn:create(prev, actions[i])
        end
        return prev
    end

    local buyInLabelSequence = transition.sequence({
            spawn({
                cc.FadeTo:create(1, 0.7 * 255),
                cc.MoveTo:create(1, cc.p(0, SeatView.HEIGHT/2 - buyInBgSize.height/2 - buyInLabelPaddding)),
            }),
            cc.CallFunc:create(function()
                buyInLabel:removeFromParent()
            end),
        })
    buyInLabel:runAction(buyInLabelSequence)
end

function SeatView:playWinnerAnimation(type_, label_)
    if not self.db_node then
        self.db_node = display.newNode():addTo(self, 101):pos(0, 12)
    else
        self.db_node:pos(0, 12)
    end
    if not self.dbs then
        self.dbs = {}
    end 
    for i = 1, #self.dbs do
        self.dbs[i]:removeFromParent()
        self.dbs[i] = nil
    end

    if type_ < 4 then
        local armatures = {}
        local label_Bone = {}
        if type_ == 1 then
            armatures = {"fla_qitapaixin", "fla_qitapaixin_ADDITIVE"}
            label_Bone = {1, "qitapaixin_mingzi"}
        elseif type_ == 2 then
            armatures = {"fla_qitapaixinzhong", "fla_qitapaixinzhong_ADDITIVE"}
            label_Bone = {1, "qitapaixinzhong_mingzi"}
        elseif type_ == 3 then
            armatures = {"fla_qitapaixinchu", "fla_qitapaixinchu_ADDITIVE"}
            label_Bone = {1, "qitapaixinchu_mingzi"}
        end
        self:playDBWinnerAnim(armatures, label_Bone, label_)
    end
end

function SeatView:playDBWinnerAnim(armatures, label_Bone, label_)
    local path = "dragonbones/fla_qitapaixin/"
    for i = 1, #armatures do
        self.dbs[i] = dragonbones.new({
                skeleton=path .. "skeleton.xml",
                texture=path .. "texture.xml",
                armatureName=armatures[i],
                aniName="",
                skeletonName="fla_qitapaixin",
            })
            :addTo(self.db_node, i)
    end

    if #label_Bone == 2 and self.dbs[label_Bone[1]] then
        label_Bone_ = self.dbs[label_Bone[1]]:getArmature():getBone(label_Bone[2])
    end

    if label_Bone_ then
        label_Bone_:setVisible(false)
    end

    for i = 1, #self.dbs do
        self.dbs[i]:getAnimation():play()
    end
end

function SeatView:playWinAnimation(type_, label_)
    if not self.seatData_ then return end

    --停止未播放完的动画
    self:stopWinAnimation_()

    --开始新的动画
    self.winBorderBatch_:show()
    self.winnerAnimBatch_:show()

    -- self:showCardTypeIf()
    
    local offsetX = 100
    if self.seatData_.isSelf then
        offsetX = 100
        self.winner_:hide()
        self:showCardTypeIf()
    else
        offsetX = 0
        self.winner_:hide()
        self:stopWinAnimation_()
        self:playWinnerAnimation(type_, label_)
    end

    self.star1_:pos(46, 86)
    transition.execute(self.star1_, cc.RepeatForever:create(transition.sequence({
        cc.ScaleTo:create(0, 0.7, 0.7),
        cc.ScaleTo:create(0.3, 1.1, 1.1),
        cc.ScaleTo:create(0.3, 0.7, 0.7),
        })))

    self.star2_:pos(-57, -71)
    transition.execute(self.star2_, cc.RepeatForever:create(transition.sequence({
        cc.ScaleTo:create(0, 0.9, 0.9),
        cc.ScaleTo:create(0.3, 1.2, 1.2),
        cc.ScaleTo:create(0.2, 0.9, 0.9),
        })))

    self.winnerStar1_:pos(offsetX-70, -10):scale(0.4):setOpacity(255 * 0.8)
    self.winnerStar1_:rotateBy(3, 360 * 0.5)
    self.winnerStar1_:scaleTo(3, 0.8)
    self.winnerStar1_:fadeTo(1.5, 255)
    local path = {
        cc.p(offsetX-70, -10),
        cc.p(offsetX-80, 16),
        cc.p(offsetX-70, 30)
    }

    transition.execute(self.winnerStar1_, cc.CatmullRomTo:create(3, path), {onComplete=function()
        self.winBorderBatch_:hide()
        self.winnerAnimBatch_:hide()
        self.winner_:stopAllActions()
        self.star1_:stopAllActions()
        self.star2_:stopAllActions()
        self.winnerStar1_:stopAllActions()
        self.winnerStar2_:stopAllActions()
        self.winnerStar3_:stopAllActions()
        self.winnerStar4_:stopAllActions()
    end})

    self.winnerStar2_:pos(offsetX + 40, -10):scale(0.4):setOpacity(255 * 0.6)
    self.winnerStar2_:rotateBy(3, 360 * 0.5)
    self.winnerStar2_:scaleTo(1.5, 1.2)
    self.winnerStar2_:fadeTo(1.5, 255 * 1)
    path = {
        cc.p(offsetX + 40, -10),
        cc.p(offsetX + 60, 0),
        cc.p(offsetX + 50, 20)
    }

    transition.execute(self.winnerStar2_, cc.RepeatForever:create(cc.CatmullRomTo:create(3, path)))

    self.winnerStar3_:pos(offsetX + 10, -10):scale(0.4):setOpacity(255 * 0.4)
    self.winnerStar3_:rotateBy(3, 360 * -1)
    self.winnerStar3_:scaleTo(3, 2)
    self.winnerStar3_:fadeTo(1.5, 255 * 0.8)
    self.winnerStar3_:moveTo(3, offsetX + 20, 15)

    self.winnerStar4_:pos(offsetX-20, -20):scale(0.2):setOpacity(255)
    self.winnerStar4_:rotateBy(3, 360 * 0.8)
    self.winnerStar4_:scaleTo(3, 5)
    self.winnerStar4_:fadeTo(3, 255 * 0.6)
    self.winnerStar4_:moveTo(3, offsetX-30, 5)
end

function SeatView:stopWinAnimation_()
    self.winBorderBatch_:hide()
    self.winnerAnimBatch_:hide()
    self.winner_:stopAllActions()
    self.star1_:stopAllActions()
    self.star2_:stopAllActions()
    self.winnerStar1_:stopAllActions()
    self.winnerStar2_:stopAllActions()
    self.winnerStar3_:stopAllActions()
    self.winnerStar4_:stopAllActions()
end

function SeatView:onTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self:dispatchEvent({name=SeatView.CLICKED, seatId=self.seatId_, target=self})
    end
end

function SeatView:reset()
    self.handCards_:showAllCards()
    self.handCards_:showBackAll()
    self.handCards_:removeDarkAll()
    self.handCards_:stopShakeAll()
    self.handCards_:hide()
    self.foldcards_:hide()
    self.cover_:hide()

    self:stopWinAnimation_()
    self.cardTypeBackground_:hide()
    self.cardType_:hide()
end

function SeatView:openGiftPopUpHandler()
    local roomUid = ""
    local roomOtherUserUidArray = ""
    local tableNum = 0
    local toUidArr = {}
    for i=0,8  do
        if self.ctx.model.playerList[i] then
            if self.ctx.model.playerList[i].uid > 0 then
                tableNum = tableNum + 1
                roomUid = roomUid..","..self.ctx.model.playerList[i].uid
                roomOtherUserUidArray = string.sub(roomUid,2)
                table.insert(toUidArr, self.ctx.model.playerList[i].uid)
            end
        end
    end
    if self.ctx.model.playerList[self.seatId_] then
        local seatData = self.ctx.model.playerList[self.seatId_];
        if seatData and tonumber(seatData.giftId) > 0 and nk.OnOff:isScoreMarketSaleGift(seatData.giftId) then
            local ScoreMarketView = import("app.module.scoremarket.ScoreMarketViewExt");
            ScoreMarketView.load(nil, nil)
        else
            GiftShopPopUp.new():show(true,self.ctx.model.playerList[self.seatId_].uid,roomOtherUserUidArray,tableNum,toUidArr) 
        end
    end
end

--yk
function SeatView:checkIsVip_()
    local vipconfig, vipconfig_2 = {}
    if self.seatData_.isSelf then
        vipconfig = nk.OnOff:getConfig('vipmsg') or {}
        vipconfig_2 = nk.OnOff:getConfig('newvipmsg') or {}

        if vipconfig_2 and vipconfig_2.newvip == 1 then
            return true, vipconfig_2
        end
    else
        local userinfo = json.decode(self.seatData_.userInfo)
        if userinfo and userinfo.vipmsg then
            vipconfig = userinfo.vipmsg
        end
    end

    if vipconfig and vipconfig.newvip == 1 then
        return true, vipconfig
    end

    if vipconfig and vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light and vipconfig.vip.light == 1 then
        return true, vipconfig
    end

    return false, vipconfig
end

function SeatView:dispose()
    self.handCards_:dispose()
    if self.giftImage_ then
        self.giftImage_:cancelLoaderId()
        self.giftImage_:release()
    end
    self:release()
    self.disposed_ = true
end

return SeatView