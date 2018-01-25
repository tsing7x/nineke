--
-- Author: KevinLiang@boyaa.com
-- Date: 2017-01-04 15:28:12
--
local HandCard = import("app.module.room.views.HandCard")
local SeatView = import("app.module.room.views.SeatView")
local SeatStateMachine = import("app.module.pdeng.model.SeatStateMachine")
local PdengSeatView = class("PdengSeatView", SeatView)
local RoomViewPosition = import(".RoomViewPosition")

function PdengSeatView:ctor(ctx, seatId)
	PdengSeatView.super.ctor(self, ctx, seatId)

	--12 博定
    self.pokdengIcon_ = display.newNode():pos(100 + 50, -20 + 50):addTo(self, 12)
    self.pokdengIcon_.showIcon = function(point) 
        self.pokdengIcon_:removeAllChildren()
        self.pokdengIcon_.isShow = false
        if point ~= 0 then
            self.pokdengIcon_.isShow = true
            display.newSprite("#pdeng_room_card_pdeng.png"):addTo(self.pokdengIcon_)
            local icon = display.newSprite("#pdeng_room_card_in_pdeng"..point..".png"):addTo(self.pokdengIcon_)
            if self.pokdengIcon_.value ~= point then
                icon:scale(0):scaleTo(0.2, 1)             
                self.pokdengIcon_.value = point
            end
        else
            self.pokdengIcon_.value = 0
        end
    end   
    
    --13 倍数
    self.XIcon_ = display.newNode():pos(100 + 50, -20 + 50):addTo(self, 13)
    self.XIcon_.showIcon = function(X) 
        self.XIcon_:removeAllChildren()
        if X > 1 then            
            local xBg = display.newSprite("#pdeng_room_card_label.png"):addTo(self.XIcon_)
            local xIcon = display.newSprite("#pdeng_room_card_in_x" .. X .. ".png"):addTo(self.XIcon_)
            if self.XIcon_.value ~= X then
                xBg:scale(0):scaleTo(0.2, 1)
                xIcon:scale(0):scaleTo(0.2, 1)
                self.XIcon_.value = X
            end
            if self.pokdengIcon_.isShow then
                xBg:pos(20,20)
                xIcon:pos(20,20)
            end
        else
            self.XIcon_.value = 0
        end
    end
end

function PdengSeatView:showCardTypeIf()
	if self.seatData and self.seatData.isSelf then
        self.pokdengIcon_:pos(100 + 50, -20 + 50)
        self.XIcon_:pos(100 + 50, -20 + 50)
    else
        self.pokdengIcon_:pos(0 + 40, 26 + 40 - 5 -30):scale(0.8)
        self.XIcon_:pos(0 + 40, 26 + 40 - 5 - 30):scale(0.8)
    end
    local getFrame = display.newSpriteFrame
    if self.seatData_ and self.seatData_.HandPoker and self.seatData_.HandPoker:getTypeLabel() then
        if self.seatData_.HandPoker:isBadType() then
            self.cardTypeBackground_:setSpriteFrame(getFrame("room_seat_card_type_dark_bg.png"))
        else
            self.cardTypeBackground_:setSpriteFrame(getFrame("room_seat_card_type_light_bg.png"))
        end
        self.cardTypeBackground_:setContentSize(118,32)
        self.cardTypeBackground_:show()
        self.cardType_:setString(self.seatData_.HandPoker:getTypeLabel())
        self.cardType_:show()
        if self.seatData_.HandPoker:isPokdeng() then
            self.pokdengIcon_.showIcon(self.seatData_.HandPoker:getPoint())
        end
        self.XIcon_.showIcon(self.seatData_.HandPoker:getX())
    else
        self.cardTypeBackground_:hide()
        self.cardType_:hide()
        self.pokdengIcon_.showIcon(0)
        self.XIcon_.showIcon(0)
    end
end

function PdengSeatView:updateState(shouldhide)
    if self.seatData_ == nil then
        if self.ctx.model:isSelfInSeat() then
            self:hide()
        else
            if not self.isTransitionForDealer then
                self:show()
            end
            self.state_:hide()
            self.chips_:hide()
            self.sitdown_:show()
        end
        if shouldhide then
            self:hide()
        end
    else
        if not self.isTransitionForDealer then
            self:show()
        end
        self.state_:show()
        self.chips_:show()
        if self.seatData_.isSelf and not self.ctx.model:isSelfDealer() then
            -- self.handCards_:setNotRotate(true)
        end
        self.sitdown_:hide()
        self.state_:setString(nk.Native:getFixedWidthText("", 24, self.seatData_.statemachine:getStateText(), 110))

        if self.seatData_.seatChips < 100000 then
            self.chips_:setString(bm.formatNumberWithSplit(self.seatData_.seatChips))
        else
            self.chips_:setString(bm.formatBigNumber(self.seatData_.seatChips))
        end

        local sm = self.seatData_.statemachine
        local st = sm:getState()

        if st ~= SeatStateMachine.STATE_GETTING then
            self.handCards_:stopShakeAll()
        end

        if st == SeatStateMachine.STATE_WAIT_START then
            self.cover_:show()
        else
            self.cover_:hide()
        end
    end
    if self.isSystemDealerSeat_ == 1 or self.isSelfSeatNotDealer_ then
        self:showOrHideSeatView(false)
    end
end

function PdengSeatView:setDealerStatus(isShow)

    if isShow then
        self.isSystemDealerSeat_ = 0
    else
        self.isSystemDealerSeat_ = 1
    end
    self:showOrHideSeatView(isShow)
end

function PdengSeatView:showOrHideSeatView(isShow)

    if isShow then
        if self.giftImage_ then
            self.giftImage_:hide()
        end
        self.background_:show()
        self.image_:show()
        self.chips_:show()
        self.clipNode_:show()
       -- self.cover_:show()
        self.state_:show()
    else
        if self.giftImage_ then
            self.giftImage_:hide()
        end
        self.background_:hide()
        self.image_:hide()
        self.chips_:hide()
        self.clipNode_:hide()
        self.cover_:hide()
        self.state_:hide()
    end
end

function PdengSeatView:setIsTransitionForDealer(transition)
    self.isTransitionForDealer = transition
end

function PdengSeatView:sitDownState_()
    if self.seatData_ and self.seatData_.isSelf and self.seatData_.seatId ~= 9 then
        self.isSelfSeatNotDealer_ = true
        self.handCards_:pos(0, 20):scale(1.0)
        self.cardTypeBackground_:pos(0, -60)
        self.cardType_:pos(0, -60)
        return self:showOrHideSeatView(false)
    end
    PdengSeatView.super.sitDownState_(self)
    if self.giftImage_ then
        self.giftImage_:hide()
    end
end

function PdengSeatView:standUpState_()
    self.isSelfSeatNotDealer_ = false
    PdengSeatView.super.standUpState_(self)
end

function PdengSeatView:fade()
end

function PdengSeatView:unfade()
end

function PdengSeatView:updateVipIcon()
end

function PdengSeatView:stopGiftAnim_()
end

function PdengSeatView:setHandCardNum(num)
    if self.seatData_ and self.seatData_.isSelf and not self.ctx.model:isSelfDealer() then
        -- self.handCards_:setNotRotate(true)
    end
    self.handCards_:setCardNum(num)
end

function PdengSeatView:playExpChangeAnimation(expChange)
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

        local parent = self
        local pos_off = cc.p(0, 0)
        if self.isSelfSeatNotDealer_ then
            parent = self.ctx.scene.nodes.seatNode
            pos_off.x = 60
            pos_off.y = 60
        end

        node:addTo(parent, 99)
            :pos(pos_off.x, pos_off.y)
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

function PdengSeatView:playChipChangeAnimation(chipChange)
    if chipChange ~= 0 then
        local node = display.newNode()
        node:setCascadeOpacityEnabled(true)
        local chip = display.newSprite("match_chip.png"):addTo(node):scale(0.6)
        local text_ = chipChange
        if chipChange > 0 then
            text_ = "+"..chipChange
        end
        local num = ui.newTTFLabel({
            text = text_, 
            color = cc.c3b(0x1D, 0xBC, 0xFC), 
            size = 24, 
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(node)
        local expW = chip:getContentSize().width * 0.6
        local numW = num:getContentSize().width
        local w =  expW + numW
        chip:pos(w * -0.5 + expW * 0.5, 0)
        num:pos(w * 0.5 - numW * 0.5, 0)

        local parent = self
        local pos_off = cc.p(0, 0)
        if self.isSelfSeatNotDealer_ then
            parent = self.ctx.scene.nodes.seatNode
            pos_off.x = 160
            pos_off.y = 40
        end

        node:addTo(parent, 99)
            :pos(pos_off.x, pos_off.y)
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

function PdengSeatView:playWinnerAnimation(type_, label_)
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
            frame_Bone = {1, "qitapaixin_jinhuang"}
        elseif type_ == 2 then
            armatures = {"fla_qitapaixinzhong", "fla_qitapaixinzhong_ADDITIVE"}
            label_Bone = {1, "qitapaixinzhong_mingzi"}
            frame_Bone = {1, "qitapaixinzhong_jinhuang"}
        elseif type_ == 3 then
            armatures = {"fla_qitapaixinchu", "fla_qitapaixinchu_ADDITIVE"}
            label_Bone = {1, "qitapaixinchu_mingzi"}
            frame_Bone = {1, "qitapaixinchu_jinhuang"}
        end
        self:playDBWinnerAnim(armatures, label_Bone, frame_Bone)
    end
end

function PdengSeatView:playDBWinnerAnim(armatures, label_Bone, frame_Bone)
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

    if #frame_Bone == 2 and self.dbs[frame_Bone[1]] then
        frame_Bone_ = self.dbs[frame_Bone[1]]:getArmature():getBone(frame_Bone[2])
    end

    if frame_Bone_ then
        frame_Bone_:setVisible(false)
    end

    for i = 1, #self.dbs do
        self.dbs[i]:getAnimation():play()
    end
end

function PdengSeatView:playSelfOrDealerWinAnimation(type_, label_)
    if not self.seatData_ then return end

    --停止未播放完的动画
    self:stopWinAnimation_()

    self.winnerAnimBatch_:show()
    
    local offsetX = 100
    if self.seatData_.isSelf then
        offsetX = 100
        self.winner_:hide()
        self:showCardTypeIf()
    else
        offsetX = 0
        self.winner_:hide()
        self:stopWinAnimation_()
    end
    self:playWinnerAnimation(type_, label_)

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

function PdengSeatView:playSitDownAnimation(onCompleteCallback)
    if self.isSelfSeatNotDealer_ then
        self:showOrHideSeatView(false)
        return
    end
    PdengSeatView.super.playSitDownAnimation(self, onCompleteCallback)
end

function PdengSeatView:playStandUpAnimation(onCompleteCallback)
    self:showOrHideSeatView(true)
    self:updateState()
    PdengSeatView.super.playStandUpAnimation(self, onCompleteCallback)
end

function PdengSeatView:updateAnte(money)
    self.seatData_.seatChips = checkint(self.seatData_.seatChips) + money
    if self.seatData_.seatChips < 100000 then
        self.chips_:setString(bm.formatNumberWithSplit(self.seatData_.seatChips))
    else
        self.chips_:setString(bm.formatBigNumber(self.seatData_.seatChips))
    end
end

function PdengSeatView:reset()
    PdengSeatView.super.reset(self)
    self.pokdengIcon_.showIcon(0)
    self.XIcon_.showIcon(0)
end


return PdengSeatView