--
-- Author: tony
-- Date: 2014-07-10 13:47:18
--
local AnimManager = class("AnimManager")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local HddjController = import("app.module.room.HddjController")
local YouWinAnim = import("app.module.room.views.YouWinAnim")
local RoomViewPosition = import(".views.RoomViewPosition")
local SendChipView = import("app.module.room.views.SendChipView")
local RoomChatBubble = import("app.module.room.views.RoomChatBubble")
local RoomSignalIndicator = import("app.module.room.views.RoomSignalIndicator")
local ExpressionConfig = import("app.module.room.views.ExpressionConfig").new()
local LoadGiftControl = import("app.module.gift.LoadGiftControl")

local DealerPosition = RoomViewPosition.DealerPosition
local SeatPosition = clone(RoomViewPosition.SeatPosition)
local DealCardStartPosition = RoomViewPosition.DealCardStartPosition

function AnimManager:ctor()
    SeatPosition[5] = RoomViewPosition.SelfSeatPosition[2]
end

function AnimManager:createNodes()
    self.tableDealerPositionId_ = 10
    self.tableDealer_ = display.newSprite("#room_table_dealer.png")
        :pos(DealerPosition[self.tableDealerPositionId_].x, DealerPosition[self.tableDealerPositionId_].y)
        :addTo(self.ctx.scene.nodes.dealerNode)
        :hide()

    self.pokerBatch_ = display.newBatchNode("room_texture.png"):addTo(self.ctx.scene.nodes.dealerNode)
    self.pokerBatch_:pos(
        DealCardStartPosition[self.tableDealerPositionId_].x, 
        DealCardStartPosition[self.tableDealerPositionId_].y)
    -- 扑克堆
    -- for i = 1, 6 do
    --     display.newSprite("#room_dealed_hand_card.png"):pos(0, i)
    --         :rotation(180)
    --         :addTo(self.pokerBatch_)
    -- end

    self.signal_ = RoomSignalIndicator.new()
        :addTo(self.ctx.scene.nodes.dealerNode)
        :pos(display.cx - 86 + 10, display.top - 32)
        :hide()

    -- self.clock_ = ui.newTTFLabel({size=20, color=cc.c3b(0x2B, 0x56, 0x86), text=os.date("%H:%M", os.time()), align=ui.TEXT_ALIGN_CENTER})
    --     :addTo(self.ctx.scene.nodes.dealerNode)
    --     :pos(display.cx + 86, display.top - 24)
    -- self.ctx.sceneSchedulerPool:loopCall(function()
    --     if self.disposed_ then
    --         return false
    --     end
    --     local timeString = os.date("%H:%M", os.time())
    --     if timeString ~= self.clock_:getString() then
    --         self.clock_:setString(timeString)
    --     end
    --     return true
    -- end, 1)

    -- 互动道具控制器
    self.hddjController_ = HddjController.new(self.ctx.scene.nodes.animNode,true)

    self:bindDataObservers_()
end

function AnimManager:onSignalStrengthChanged_(strength)
    self.signal_:setSignalStrength(strength or 5)
end

-- positionId = 10 移动到荷官位置
function AnimManager:moveDealerTo(positionId, animation)   
    if positionId == nil then
        positionId = 10
    end

    local p = DealerPosition[positionId]
    local p2 = DealCardStartPosition[positionId]
    if not p then
        p = DealerPosition[10]
        p2 = DealCardStartPosition[10]
        self.tableDealerPositionId_ = 1
    end
    self.tableDealer_:stopAllActions()
    self.pokerBatch_:stopAllActions()
    if animation then
        self.tableDealer_:moveTo(0.5, p.x, p.y)
        self.pokerBatch_:moveTo(0.5, p2.x, p2.y)
    else
        self.tableDealer_:setPosition(p)
        self.pokerBatch_:setPosition(p2)
    end    
    self.tableDealerPositionId_ = positionId
end

function AnimManager:rotateDealer(step)
    if self.tableDealerPositionId_ == 10 then
        return
    end
    local newPositionId = self.tableDealerPositionId_ - step
    if newPositionId > 9 then
        newPositionId = newPositionId - 9
    elseif newPositionId < 1 then
        newPositionId = newPositionId + 9
    end
    self:moveDealerTo(newPositionId, true)
end

function AnimManager:playYouWinAnim()
    if not self.youWinAnim_ then
        self.youWinAnim_ = YouWinAnim.new():pos(display.cx, SeatPosition[1].y - 174)
        self.youWinAnim_:retain()
    end
    if self.youWinAnim_:getParent() then
        if self.youWinScheduleHandle_ then
            scheduler.unscheduleGlobal(self.youWinScheduleHandle_)
        end
    else
        self.youWinAnim_:addTo(self.scene.nodes.animNode)
    end
    self.youWinAnim_:onPlay()
    self.youWinScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, function (obj)
        obj.youWinAnim_:removeFromParent()
    end), 3)
end

function AnimManager:playAddFriendAnimation(fromSeatId, toSeatId)
    local fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    local toPositionId = self.seatManager:getSeatPositionId(toSeatId)
    if fromPositionId == -1 or toPositionId == -1 then
        return;
    end
    
    if not self.addFriendSprites_ then
        self.addFriendSprites_ = {}
    end
    local sp = display.newSprite("#room_add_friend.png"):addTo(self.scene.nodes.animNode)
    table.insert(self.addFriendSprites_, sp)

    if fromPositionId then
        sp:pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
    else
        sp:pos(0, display.top)
    end
    transition.moveTo(sp, {
        time = 2,
        easing = "exponentialInOut",
        x = SeatPosition[toPositionId].x,
        y = SeatPosition[toPositionId].y,
        onComplete = function()
            sp:removeFromParent()
            table.removebyvalue(self.addFriendSprites_, sp, true)
        end,
    })
end

function AnimManager:playSendChipAnimation(fromSeatId, toSeatId, chips)
    self.seatManager:updateSeatState(fromSeatId)

    local fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    local toPositionId = self.seatManager:getSeatPositionId(toSeatId)
    local toX, toY
    if toSeatId == 11 then
        toX = display.cx - 105--display.cx + 10

        -- toY = RoomViewPosition.SeatPosition[1].y + 10  -- 调整坐标适配！
        toY = display.height - 95

        -- toX = display.cx + 10
        -- toY = RoomViewPosition.SeatPosition[1].y - 46
    else
        toX = SeatPosition[toPositionId].x
        toY = SeatPosition[toPositionId].y
    end
    if not self.sendChipViews_ then
        self.sendChipViews_ = {}
    end

    local sp = SendChipView.new(chips):addTo(self.scene.nodes.animNode)
    table.insert(self.sendChipViews_, sp)

    if fromPositionId then
        sp:pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
    else
        sp:pos(0, display.top)
    end
    transition.moveTo(sp, {
        time = 2,
        easing = "exponentialInOut",
        x = toX,
        y = toY,
        onComplete = function()
            sp:removeFromParent()
            table.removebyvalue(self.sendChipViews_, sp, true)
            if toSeatId ~= 11 then
                self.seatManager:updateSeatState(toSeatId)
            end
        end,
    })
end

function AnimManager:playSendGiftAnimation(giftId, fromUid, toUidArr)
    LoadGiftControl:getInstance():getGiftUrlById(giftId, function(url)
        if url and self:checkUidInSeat({fromUid}) and self:checkUidInSeat(toUidArr) then
            nk.ImageLoader:loadAndCacheImage(nk.ImageLoader:nextLoaderId(),
                url, 
                function(success, sprite)
                    if success and self:checkUidInSeat({fromUid}) and self:checkUidInSeat(toUidArr) then
                        local tex = sprite:getTexture()
                        local fromPositionId = self.seatManager:getSeatPositionId(self.model:getSeatIdByUid(fromUid))
                        local fromX, fromY = SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y
                        for _, toUid in ipairs(toUidArr) do
                            local toSeatId = self.model:getSeatIdByUid(toUid)
                            if toSeatId ~= -1 then
                                if not self.sendGiftViews_ then
                                    self.sendGiftViews_ = {}
                                end
                                local toPositionId = self.seatManager:getSeatPositionId(toSeatId)
                                local toX = SeatPosition[toPositionId].x
                                local toY = SeatPosition[toPositionId].y
                                if toPositionId == 1 or toPositionId == 2 or toPositionId == 3 or toPositionId == 5 then
                                    toX = toX - 50
                                else
                                    toX = toX + 50
                                end

                                local sp = display.newSprite(tex):pos(fromX, fromY):scale(0.5):addTo(self.scene.nodes.animNode)
                                table.insert(self.sendGiftViews_, sp)
                                transition.moveTo(sp, {
                                    time = 2,
                                    easing = "exponentialInOut",
                                    x = toX,
                                    y = toY,
                                    onComplete = function()
                                        sp:removeFromParent()
                                        table.removebyvalue(self.sendGiftViews_, sp, true)
                                        toSeatId = self.model:getSeatIdByUid(toUid)
                                        if toSeatId ~= -1 then
                                            self.seatManager:updateGiftUrl(toSeatId, giftId)
                                        end
                                    end,
                                })
                            end
                        end
                    end
                end,
                nk.ImageLoader.CACHE_TYPE_GIFT
            )
        end
    end)
end

function AnimManager:checkUidInSeat(uidArr)
    for _, uid in ipairs(uidArr) do
        if self.model:getSeatIdByUid(uid) ~= -1 then
            return true
        end
    end
    return false
end

function AnimManager:setAnimCompleteCallback(callback)
    -- body
    self.animComplCallBack_ = callback
end

function AnimManager:playHddjAnimation(fromSeatId, toSeatId, hddjId)
    local fromPositionId
    local toPositionId
    if fromSeatId ~= 11 then
        fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    else
        fromPositionId = 11
    end
    if toSeatId ~= 11  then
        toPositionId = self.seatManager:getSeatPositionId(toSeatId)
    else
        toPositionId = 11
    end
    if not self.sendHddjs_ then
        self.sendHddjs_ = {}
    end
    local sp
    sp = self.hddjController_:playHddj(fromPositionId, toPositionId, hddjId, function()

            if sp then
                --todo
                sp:removeFromParent()
                table.removebyvalue(self.sendHddjs_, sp, true)
            end
            
            if self.animComplCallBack_ then
                --todo
                self.animComplCallBack_()

                self.animComplCallBack_ = nil
            end
        end)
    if sp then
        table.insert(self.sendHddjs_, sp)
    end
end

function AnimManager:playExpression(seatId, expressionId, time)
    if not self.sendExpressions_ then
        self.sendExpressions_ = {}
        self.loadingExpressions_ = {}
        self.waitPlay_ = {}
        self.loadedExpressions_ = {}
    end
    if self.model.playerList[seatId] then
        local animName = "expression-" .. expressionId
        local anim = display.getAnimationCache(animName)
        if anim then
            print("play ", expressionId)
            self:playExpressionAnim_(seatId, expressionId, anim)
        else
            if not self.waitPlay_[animName] then
                self.waitPlay_[animName] = {}
            end
            table.insert(self.waitPlay_[animName], seatId)
            if not self.loadingExpressions_[animName] then
                self.loadingExpressions_[animName] = true
                if expressionId>100 and expressionId<150 then
                    display.addSpriteFrames("word_expression.plist", "word_expression.png", function()
                        print("loaded=== ", expressionId)
                        local config = ExpressionConfig:getConfig(expressionId)
                        -- local frames = display.newFrames("expression-" .. expressionId .. "-%04d.png", 1, config.frameNum, false)
                        -- local animation = display.newAnimation(frames, 1 / 3)
                        local animation = cc.Animation:create()
                        local frame = display.newSpriteFrame("expression-"..expressionId..".png")
                        animation:addSpriteFrame(frame)
                        animation:setDelayPerUnit(1 / 3)
                        display.setAnimationCache(animName, animation)
                        table.insert(self.loadedExpressions_, animName)
                        local toPlay = self.waitPlay_[animName]
                        while #toPlay > 0 do
                            local seatId = table.remove(toPlay, 1)
                            print("play ..", expressionId, seatId)
                            self:playExpressionAnim_(seatId, expressionId, animation)
                         end
                    end)
                    print("load===.. ", expressionId)
                    return
                end
                display.addSpriteFrames("expressions/expression_" .. expressionId ..".plist", "expressions/expression_" .. expressionId ..".png", function()
                    if self.disposed_ then
                        self.loadingExpressions_[animName] = nil
                        display.removeSpriteFramesWithFile("expressions/expression_" .. expressionId ..".plist", "expressions/expression_" .. expressionId ..".png")
                        return
                    end
                    print("loaded ", expressionId)
                    local config = ExpressionConfig:getConfig(expressionId)
                     local frames = display.newFrames("expression-" .. expressionId .. "-%04d.png", 1, config.frameNum, false)
                     local animation = display.newAnimation(frames, time or 1 / 3)
                     display.setAnimationCache(animName, animation)
                     table.insert(self.loadedExpressions_, animName)
                     local toPlay = self.waitPlay_[animName]
                     while #toPlay > 0 do
                         local seatId = table.remove(toPlay, 1)
                         print("play ..", expressionId, seatId)
                         self:playExpressionAnim_(seatId, expressionId, animation)
                     end

                     self.waitPlay_[animName] = nil
                     self.loadingExpressions_[animName] = nil
                 end)
                print("load.. ", expressionId)
            end
        end
    end
end

function AnimManager:playExpressionAnim_(seatId, expressionId, anim)
    if self.model.playerList[seatId] then
        local config = ExpressionConfig:getConfig(expressionId)
        local positionId = self.seatManager:getSeatPositionId(seatId)
        local p = SeatPosition[positionId]
        local sp = display.newSprite()
        sp:pos(p.x + config.adjustX, p.y + config.adjustY + 32):addTo(self.scene.nodes.animNode)
        table.insert(self.sendExpressions_, sp)

        if expressionId>100 and expressionId<150 then
            sp:setScale(0.8)
            sp:runAction(cc.RepeatForever:create(transition.sequence({
                -- cc.DelayTime:create(0.3),
                -- cc.CallFunc:create(function() 
                --     -- sp:setScale(0.8)
                -- end),
                -- cc.DelayTime:create(0.3),
                -- cc.CallFunc:create(function() 
                --     -- sp:setScale(1)
                -- end),
                transition.scaleTo(sp, {scale = 1,time = 0.3}),
                transition.scaleTo(sp, {scale = 0.8,time = 0.3}),
            })))
        end

        transition.playAnimationForever(sp, anim)
        sp:runAction(transition.sequence({
        cc.DelayTime:create(3),
        cc.CallFunc:create(function() 
            sp:removeFromParent()
            table.removebyvalue(self.sendExpressions_, sp, true)
        end)}))
    end
end

--座位扣钱动画
function AnimManager:playChipsChangeAnimation(seatId, chipsChange)
    if not self.chipsChange_ then
        self.chipsChange_ = {}
    end
    local positionId = self.seatManager:getSeatPositionId(seatId)
    local p = SeatPosition[positionId]
    if chipsChange > 0 then
        local lb = ui.newTTFLabel({size=24, text=string.format("+$%s", math.abs(chipsChange)), color=cc.c3b(0xEC, 0xCE, 0x0B)})
            :addTo(self.scene.nodes.animNode)
        table.insert(self.chipsChange_, lb)
        local lbsize = lb:getContentSize()
        lb:pos(p.x - 54 - lbsize.width * 0.5 + 2, p.y)
            :moveTo(2, lb:getPositionX(), p.y + 82 - lbsize.height * 0.5)
            :fadeTo(2, 255 * 0.7)
            :runAction(transition.sequence({cc.DelayTime:create(2), cc.CallFunc:create(function() 
                    lb:removeFromParent()
                    table.removebyvalue(self.chipsChange_, lb, true)
                end)}))
    elseif chipsChange < 0 then
        local lb = ui.newTTFLabel({size=24, text=string.format("-$%s", math.abs(chipsChange)), color=cc.c3b(0xEC, 0xCE, 0x0B)})
            :addTo(self.scene.nodes.animNode)
        table.insert(self.chipsChange_, lb)
        local lbsize = lb:getContentSize()
        lb:pos(p.x - 54 - lbsize.width * 0.5 + 2, p.y)
            :moveTo(2, lb:getPositionX(), p.y - 82 + lbsize.height * 0.5)
            :fadeTo(2, 255 * 0.7)
            :runAction(transition.sequence({cc.DelayTime:create(2), cc.CallFunc:create(function() 
                lb:removeFromParent()
                table.removebyvalue(self.chipsChange_, lb, true)
            end)}))
    end
end

--显示聊天消息
function AnimManager:showChatMsg(seatId, message)
    if not self.chatBubbles_ then
        self.chatBubbles_ = {}
    end
    local bubble
    if seatId ~= -1 then
        local positionId = self.seatManager:getSeatPositionId(seatId)
        local p = SeatPosition[positionId]
        if p then
            local px, py
            if positionId >= 1 and positionId <=3 then
                bubble = RoomChatBubble.new(message, RoomChatBubble.DIRECTION_RIGHT)
                px = p.x + 8
            else
                bubble = RoomChatBubble.new(message, RoomChatBubble.DIRECTION_LEFT)
                px = p.x - 8
            end
            if positionId == 1 or positionId == 9 then
                py = p.y + 8
            elseif positionId == 2 or positionId == 8 then
                py = p.y + 8
            elseif positionId == 3 or positionId == 7 then
                py = p.y + 48
            elseif positionId == 10 then
                py = p.y + 36
            else
                py = p.y + 36
            end
            bubble:show(self.scene.nodes.animNode, px, py)
        end
    else
        --bubble = RoomChatBubble.new(message, RoomChatBubble.DIRECTION_LEFT)
        --bubble:show(self.scene.nodes.animNode, 16, 86)
    end
    if bubble then
        table.insert(self.chatBubbles_, bubble)
        bubble:runAction(transition.sequence({cc.DelayTime:create(5), cc.CallFunc:create(function() 
            bubble:removeFromParent()
            table.removebyvalue(self.chatBubbles_, bubble, true)
        end)}))
    end
end

function AnimManager:removeAllAnimation()
    while(#self.addFriendSprites_ > 0) do
        local sp = table.remove(self.addFriendSprites_, 1)
        if sp:getParent() then
            sp:removeFromParent()
        end
    end
    while(#self.sendChipViews_ > 0) do
        local sp = table.remove(self.sendChipViews_, 1)
        if sp:getParent() then
            sp:removeFromParent()
        end
    end
    while(#self.sendGiftViews_ > 0) do
        local sp = table.remove(self.sendGiftViews_, 1)
        if sp:getParent() then
            sp:removeFromParent()
        end
    end
    while(#self.sendHddjs_ > 0) do
        local sp = table.remove(self.sendHddjs_, 1)
        if sp:getParent() then
            sp:removeFromParent()
        end
    end
    while(#self.sendExpressions_ > 0) do
        local sp = table.remove(self.sendExpressions_, 1)
        if sp:getParent() then
            sp:removeFromParent()
        end
    end
    while(#self.chipsChange_ > 0) do
        local sp = table.remove(self.chipsChange_, 1)
        if sp:getParent() then
            sp:removeFromParent()
        end
    end
    while(#self.chatBubbles_ > 0) do
        local sp = table.remove(self.chatBubbles_, 1)
        if sp:getParent() then
            sp:removeFromParent()
        end
    end
end

function AnimManager:dispose()
    if self.youWinScheduleHandle_ then
        scheduler.unscheduleGlobal(self.youWinScheduleHandle_)
    end
    if self.youWinAnim_ then
        self.youWinAnim_:release()
    end
    if self.loadedExpressions_ and #self.loadedExpressions_ > 0 then
        while #self.loadedExpressions_ > 0 do
            local animName = table.remove(self.loadedExpressions_, 1)
            local spPos = string.find(animName, "-")
            local expressionId = string.sub(animName, spPos + 1)
            display.removeAnimationCache(animName)
            display.removeSpriteFramesWithFile("expressions/expression_" .. expressionId .. ".plist", "expressions/expression_" .. expressionId .. ".png")
        end
    end
    self:unbindDataObservers_()
    self.hddjController_:dispose()
    self.disposed_ = true
end

function AnimManager:bindDataObservers_()
    self.onSignalStengthHandlerId_ = bm.DataProxy:addDataObserver(nk.dataKeys.SIGNAL_STRENGTH, handler(self, self.onSignalStrengthChanged_))
end

function AnimManager:unbindDataObservers_()
    bm.DataProxy:removeDataObserver(nk.dataKeys.SIGNAL_STRENGTH, self.onSignalStengthHandlerId_)
end

function AnimManager:changeSeatPosition(isDealer)
    if isDealer then
        SeatPosition[5] = RoomViewPosition.SelfSeatPosition[1]
    else
        SeatPosition[5] = RoomViewPosition.SelfSeatPosition[2]
    end
    if self.hddjController_ then
        self.hddjController_:changeSeatPosition(isDealer)
    end
end

return AnimManager