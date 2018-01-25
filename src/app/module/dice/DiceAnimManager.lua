--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-08 17:34:13
--
local DiceAnimManager = class("DiceAnimManager")

local HddjController = import(".DiceHddjController")
local SendChipView = import("app.module.room.views.SendChipView")
local RoomSignalIndicator = import("app.module.room.views.RoomSignalIndicator")
local RoomBatteryIndicator = import("app.module.room.views.RoomBatteryIndicator")
local ExpressionConfig = import("app.module.room.views.ExpressionConfig").new()
local P = import(".views.DiceViewPosition")
function DiceAnimManager:ctor()

end

function DiceAnimManager:createNodes()
    self.signal_ = RoomSignalIndicator.new()
        :addTo(self.ctx.scene.nodes.backgroundNode)
        :pos(display.cx - 50, display.top- 100)

    self.battery_ = RoomBatteryIndicator.new()
        :addTo(self.ctx.scene.nodes.backgroundNode)
        :pos(display.cx + 50, display.top- 100)

    self.isTimeSplitStr = true;
    self.clock_ = ui.newTTFLabel({size=20, color=cc.c3b(0x80, 0xa0, 0xe1), text=os.date("%H:%M", os.time()), align=ui.TEXT_ALIGN_CENTER})
        :addTo(self.ctx.scene.nodes.backgroundNode)
        :pos(display.cx - 50, display.top-120)
    self.ctx.sceneSchedulerPool:loopCall(function()
        if self.disposed_ then
            return false
        end

        local date = os.date("*t",os.time())
        local hour = date.hour
        if tonumber(hour)<10 then
            hour = "0"..hour
        end
        local min = date.min
        if tonumber(min)<10 then
            min = "0"..min
        end

        local splitStr = self.isTimeSplitStr and ":" or " "
        self.clock_:setString(hour..splitStr..min);
        self.isTimeSplitStr = not self.isTimeSplitStr;
        return true;
    end, 1)

    self.hddjController_ = HddjController.new(self.ctx.scene.nodes.animNode)
    self:bindDataObservers_()
    self:getBatteryInfo();
end

function DiceAnimManager:playExpression(seatId,uid, expressionId)
    if not self.sendExpressions_ then
        self.sendExpressions_ = {}
        self.loadingExpressions_ = {}
        self.waitPlay_ = {}
        self.loadedExpressions_ = {}
    end
    local animName = "expression-" .. expressionId
    local anim = display.getAnimationCache(animName)
    if anim then
        print("play ", expressionId)
        self:playExpressionAnim_(seatId, expressionId, anim,uid)
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
                        self:playExpressionAnim_(seatId, expressionId, animation,uid)
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
                 local animation = display.newAnimation(frames, 1 / 3)
                 display.setAnimationCache(animName, animation)
                 table.insert(self.loadedExpressions_, animName)
                 local toPlay = self.waitPlay_[animName]
                 while #toPlay > 0 do
                     local seatId = table.remove(toPlay, 1)
                     print("play ..", expressionId, seatId)
                     self:playExpressionAnim_(seatId, expressionId, animation,uid)
                 end

                 self.waitPlay_[animName] = nil
                 self.loadingExpressions_[animName] = nil
             end)
            print("load.. ", expressionId)
        end
    end
end

function DiceAnimManager:playExpressionAnim_(seatId, expressionId, anim, uid)
    local positionId = self.diceSeatManager:getPosition(seatId,uid)
    local config = ExpressionConfig:getConfig(expressionId)
    local p = P.SeatPosition[positionId]
    local sp = display.newSprite()
    sp:pos(p.x + config.adjustX, p.y + config.adjustY):addTo(self.scene.nodes.animNode)
    table.insert(self.sendExpressions_, sp)

    if expressionId>100 and expressionId<150 then
        sp:setScale(0.8)
        sp:runAction(cc.RepeatForever:create(transition.sequence({
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

function DiceAnimManager:playSendChipAnimation(fromseatId,fromUid,toseatId,toUid,chips)
    local fromPositionId = self.diceSeatManager:getPosition(fromseatId,fromUid)
    local toPositionId = self.diceSeatManager:getPosition(toseatId,toUid)
    if fromPositionId == 9 then
        self.ctx.operManager:subCurrMoney(chips)
    end
    local toX, toY
    toX = P.SeatPosition[toPositionId].x
    toY = P.SeatPosition[toPositionId].y
    if not self.sendChipViews_ then
        self.sendChipViews_ = {}
    end

    local sp = SendChipView.new(chips,false):addTo(self.scene.nodes.animNode)
    table.insert(self.sendChipViews_, sp)

    sp:pos(P.SeatPosition[fromPositionId].x, P.SeatPosition[fromPositionId].y)
    transition.moveTo(sp, {
        time = 2,
        easing = "exponentialInOut",
        x = toX,
        y = toY,
        onComplete = function()
            sp:removeFromParent()
            table.removebyvalue(self.sendChipViews_, sp, true)
            if toPositionId == 9 then
                self.ctx.operManager:subCurrMoney(-chips)
            end
        end,
    })
end

function DiceAnimManager:playSendToDealChipAnimation(fromseatId,fromUid,dealId,chips)
    local fromPositionId = self.diceSeatManager:getPosition(fromseatId,fromUid)
    local toX, toY
    toX = P.DealPosition[dealId].x
    toY = P.DealPosition[dealId].y
    if not self.sendChipViews_ then
        self.sendChipViews_ = {}
    end

    local sp = SendChipView.new(chips,false):addTo(self.scene.nodes.animNode)
    table.insert(self.sendChipViews_, sp)

    sp:pos(P.SeatPosition[fromPositionId].x, P.SeatPosition[fromPositionId].y)
    transition.moveTo(sp, {
        time = 2,
        easing = "exponentialInOut",
        x = toX,
        y = toY,
        onComplete = function()
            sp:removeFromParent()
            table.removebyvalue(self.sendChipViews_, sp, true)
        end,
    })
end

function DiceAnimManager:playAddFriendAnimation(fromSeatId,fromUid, toSeatId,toUid)
    local fromPositionId = self.diceSeatManager:getPosition(fromSeatId,fromUid)
    local toPositionId = self.diceSeatManager:getPosition(toSeatId,toUid)
    if not self.addFriendSprites_ then
        self.addFriendSprites_ = {}
    end
    local sp = display.newSprite("#room_add_friend.png"):addTo(self.scene.nodes.animNode)
    table.insert(self.addFriendSprites_, sp)

    if fromPositionId then
        sp:pos(P.SeatPosition[fromPositionId].x, P.SeatPosition[fromPositionId].y)
    else
        sp:pos(0, display.top)
    end
    transition.moveTo(sp, {
        time = 2,
        easing = "exponentialInOut",
        x = P.SeatPosition[toPositionId].x,
        y = P.SeatPosition[toPositionId].y,
        onComplete = function()
            sp:removeFromParent()
            table.removebyvalue(self.addFriendSprites_, sp, true)
        end,
    })
end

function DiceAnimManager:playHddjAnimation(fromSeatId, toSeatId, hddjId,fromUid,toUid, isRecv)
    local fromPositionId = self.diceSeatManager:getPosition(fromSeatId,fromUid)
    local toPositionId
    toPositionId = self.diceSeatManager:getPosition(toSeatId,toUid)

    if not self.sendHddjs_ then
        self.sendHddjs_ = {}
    end
    local sp
    sp = self.hddjController_:playHddj(fromPositionId, toPositionId, hddjId, function()
            if hddjId > 1000 and not isRecv then
                local index = checkint(math.random(3))
                local message = {messagetype = 2,content = bm.LangUtil.getText("WATERLAMP", "BLESSING" .. index)}
                nk.socket.RoomSocket:sendChatMsg(message)
            end

            if sp then
                sp:removeFromParent()
                table.removebyvalue(self.sendHddjs_, sp, true)
            end
        end)
    if sp then
        table.insert(self.sendHddjs_, sp)
    end
end

function DiceAnimManager:playTipsAnim(tips,callback)
    if self.tipsNode_ then
        self.tipsNode_:removeFromParent()
        self.tipsNode_ = nil
    end
    local sprite = "#dice_tips_start.png"
    if tips == "result" then
        sprite = "#dice_tips_result.png"
    end
    self.tipsNode_ = display.newNode():addTo(self.ctx.scene.nodes.animNode):pos(display.cx,display.cy + 20)
    self.leftbg_ = display.newSprite("#dice_tips_bg.png"):addTo(self.tipsNode_)
    self.leftbg_:pos(-self.leftbg_:getContentSize().width /2,0)
    self.rightbg_ = display.newSprite("#dice_tips_bg.png"):addTo(self.tipsNode_)
    self.rightbg_:setScaleX(-1)
    self.rightbg_:pos(self.rightbg_:getContentSize().width/2,0)
    self.tipslight_ = display.newSprite("#dice_tips_light.png"):addTo(self.tipsNode_)
    self.tipsprite_ = display.newSprite(sprite):addTo(self.tipsNode_):pos(0,10)
    self.tipsNode_:setOpacity(0)
    self.tipsNode_:setScale(1.5)
    self.tipsNode_:runAction(transition.sequence({cc.FadeIn:create(0.2),cc.ScaleTo:create(0.3,1),
        cc.DelayTime:create(1),cc.CallFunc:create(function()
            if callback then
                callback()
            end
            self.tipsNode_:removeFromParent()
            self.tipsNode_ = nil
        end)}))
end

function DiceAnimManager:playChipsChangeAnimation(seatId, chipsChange,fromUid)
    if not self.chipsChange_ then
        self.chipsChange_ = {}
    end
    local positionId = self.diceSeatManager:getPosition(seatId,fromUid)
    local p = P.SeatPosition[positionId]
    if chipsChange > 0 then
        local lb = ui.newTTFLabel({size=24, text=string.format("+%s", math.abs(chipsChange)), color=cc.c3b(0xEC, 0xCE, 0x0B)})
            :addTo(self.scene.nodes.animNode)
        table.insert(self.chipsChange_, lb)
        local lbsize = lb:getContentSize()
        lb:pos(p.x - lbsize.width * 0.5 + 2 + 86, p.y)
            :moveTo(2, lb:getPositionX(), p.y + 82 - lbsize.height * 0.5 )
            :fadeTo(2, 255 * 0.7)
            :runAction(transition.sequence({cc.DelayTime:create(2), cc.CallFunc:create(function() 
                    lb:removeFromParent()
                    table.removebyvalue(self.chipsChange_, lb, true)
                end)}))
    elseif chipsChange < 0 then
        local lb = ui.newTTFLabel({size=24, text=string.format("-%s", math.abs(chipsChange)), color=cc.c3b(0xEC, 0xCE, 0x0B)})
            :addTo(self.scene.nodes.animNode)
        table.insert(self.chipsChange_, lb)
        local lbsize = lb:getContentSize()
        lb:pos(p.x - lbsize.width * 0.5 + 2 + 86, p.y)
            :moveTo(2, lb:getPositionX(), p.y - 82 + lbsize.height * 0.5)
            :fadeTo(2, 255 * 0.7)
            :runAction(transition.sequence({cc.DelayTime:create(2), cc.CallFunc:create(function() 
                lb:removeFromParent()
                table.removebyvalue(self.chipsChange_, lb, true)
            end)}))
    end
end

function DiceAnimManager:getBatteryInfo()
    nk.Native:getBatteryInfo(function(result)
        self.battery_:setSignalStrength(tonumber(result))
    end);
end

function DiceAnimManager:onSignalStrengthChanged_(strength)
    self.signal_:setSignalStrength(strength or 5)
end

function DiceAnimManager:bindDataObservers_()
    self.onSignalStengthHandlerId_ = bm.DataProxy:addDataObserver(nk.dataKeys.SIGNAL_STRENGTH, handler(self, self.onSignalStrengthChanged_))
end

function DiceAnimManager:unbindDataObservers_()
    bm.DataProxy:removeDataObserver(nk.dataKeys.SIGNAL_STRENGTH, self.onSignalStengthHandlerId_)
end

function DiceAnimManager:dispose()
    if self.loadedExpressions_ and #self.loadedExpressions_ > 0 then
        while #self.loadedExpressions_ > 0 do
            local animName = table.remove(self.loadedExpressions_, 1)
            local spPos = string.find(animName, "-")
            local expressionId = string.sub(animName, spPos + 1)
            display.removeAnimationCache(animName)
            local expressionNum = tonumber(expressionId)
            if expressionNum>100 and expressionNum<150 then
                
            else
                display.removeSpriteFramesWithFile("expressions/expression_" .. expressionId .. ".plist", "expressions/expression_" .. expressionId .. ".png")
            end
        end
    end
    self:unbindDataObservers_()
    self.hddjController_:dispose()
    self.disposed_ = true
end

return DiceAnimManager