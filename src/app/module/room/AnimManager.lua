--
-- Author: tony
-- Date: 2014-07-10 13:47:18
--
local AnimManager = class("AnimManager")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local HddjController = import(".HddjController")
local YouWinAnim = import(".views.YouWinAnim")
local RoomViewPosition = import(".views.RoomViewPosition")
local SendChipView = import(".views.SendChipView")
local RoomChatBubble = import(".views.RoomChatBubble")
local RoomSignalIndicator = import(".views.RoomSignalIndicator")
local RoomBatteryIndicator = import(".views.RoomBatteryIndicator")
local ExpressionConfig = import(".views.ExpressionConfig").new()
local LoadGiftControl = import("app.module.gift.LoadGiftControl")
local DealerRewardView = import(".views.DealerRewardView")
local ClockProgressTimer = import(".views.ClockProgressTimer")
-- require(cc.PACKAGE_NAME..".cocos2dx.DragonBonesEx")

local DealerPosition = RoomViewPosition.DealerPosition
local SeatPosition = RoomViewPosition.SeatPosition

function AnimManager:ctor()
    
end

function AnimManager:createNodes()
    self.tableDealerPositionId_ = 1
    self.tableDealer_ = display.newSprite("#room_table_dealer.png")
        :pos(DealerPosition[self.tableDealerPositionId_].x, DealerPosition[self.tableDealerPositionId_].y)
        :addTo(self.ctx.scene.nodes.dealCardNode)

    self.signal_ = RoomSignalIndicator.new()
        :addTo(self.ctx.scene.nodes.dealerNode)
        :pos(display.cx - 135, display.top - 22)

    self.battery_ = RoomBatteryIndicator.new()
        :addTo(self.ctx.scene.nodes.dealerNode)
        :pos(display.cx - 100, display.top - 22)

    self.isTimeSplitStr = true;
    self.clock_ = ui.newTTFLabel({size=20, color=cc.c3b(0x80, 0xa0, 0xe1), text=os.date("%H:%M", os.time()), align=ui.TEXT_ALIGN_CENTER})
        :addTo(self.ctx.scene.nodes.dealerNode)
        :pos(display.cx + 110, display.top - 21)
    self.ctx.sceneSchedulerPool:loopCall(function()
        if self.disposed_ then
            return false
        end
        -- local timeString = os.date("%H:%M", os.time())
        local date = os.date("*t",os.time())
        local hour = date.hour
        if tonumber(hour)<10 then
            hour = "0"..hour
        end
        local min = date.min
        if tonumber(min)<10 then
            min = "0"..min
        end
        -- 
        local splitStr = self.isTimeSplitStr and ":" or " "
        self.clock_:setString(hour..splitStr..min);
        self.isTimeSplitStr = not self.isTimeSplitStr;
        return true;
    end, 1)

    -- 互动道具控制器
    self.hddjController_ = HddjController.new(self.ctx.scene.nodes.animNode)
    self:bindDataObservers_()
    self:getBatteryInfo();
end

function AnimManager:changeColor(r,g,b)
    self.clock_:setTextColor(cc.c3b(r, g, b))
    -- self.signal_
end

function AnimManager:getBatteryInfo()
    nk.Native:getBatteryInfo(function(result)
        self.battery_:setSignalStrength(tonumber(result))
    end);
end

function AnimManager:onSignalStrengthChanged_(strength)
    self.signal_:setSignalStrength(strength or 5)
end

function AnimManager:moveDealerTo(positionId, animation)
    local p = DealerPosition[positionId]
    if not p then
        p = DealerPosition[1]
        self.tableDealerPositionId_ = 1
    end
    self.tableDealer_:stopAllActions()
    if animation then
        self.tableDealer_:moveTo(0.5, p.x, p.y)
    else
        self.tableDealer_:setPosition(p)
    end
    self.tableDealerPositionId_ = positionId
end

function AnimManager:rotateDealer(step)
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

function AnimManager:playLieShaAnim(reward,startX,startY,endX,endY,seatView)
    if not self.db_node then
        self.db_node = display.newNode():addTo(self.scene.nodes.animNode)
    end
    local armatures = {"fla_leisha", "fla_leishaguang", "fla_leishakuang"}
    local path = "dragonbones/fla_leisha/"
    local anims = {}
    for k,v in ipairs(armatures) do
        local dragonbones_ = dragonbones.new({
                    skeleton=path .. "skeleton.xml",
                    texture=path .. "texture.xml",
                    armatureName=armatures[k],
                    aniName="",
                    skeletonName="fla_leisha",
                })
                :addTo(self.db_node)
                :pos(startX,startY)

        if v=="fla_leisha" and seatView then
            -- local huangDong = dragonbones_:getArmature():getBone("leisha_ddssdwaasd")
            local huangDong = dragonbones_:getArmature():getCCSlot("leisha_ddssdwaasd")
            if huangDong then
                seatView:pos(0,0)
                -- huangDong:setDisplay(dragonBones.CCDBNode:new(seatView))
                seatView:removeFromParent()
                huangDong:getCCDisplay():addChild(seatView)
            end
            -- dragonbones_:addScriptListener(cc.DragonBonesNode.EVENTS.COMPLETE, function()
            --     seatView:removeFromParent()
            -- end)
            dragonbones_:registerAnimationEventHandler(function(evt)
                if evt.type == 7 then
                    seatView:removeFromParent()
                end
            end)
        elseif v=="fla_leishakuang" then
            dragonbones_:pos(startX,startY+80)
            -- dragonbones_:addScriptListener(cc.DragonBonesNode.EVENTS.COMPLETE, function()
            --     for kk,vv in ipairs(anims) do
            --         vv:removeFromParent()
            --     end
            -- end)
            dragonbones_:registerAnimationEventHandler(function(evt)
                if evt.type == 7 then
                    for kk,vv in ipairs(anims) do
                        vv:removeFromParent()
                    end
                end
            end)

              -- dragonbones_:addScriptListener(FrameEvent.BONE_FRAME_EVENT, function(evt)
            dragonbones_:registerFrameEventHandler(function(evt)
                -- 开始移动
                -- 弹框上面有个  帧事件  名字 是 吗 @atk是判定  金币出现的时间的
                if evt and evt.type == 2 and evt.frameLabel=="atk" then --evt.type == 2貌似也可以不要
                    -- 金币做了三段式 的     出现born   飞行中   stand      结束消失 end  标签名
                    local step = 1
                    local coin = dragonbones.new({
                        skeleton=path .. "skeleton.xml",
                        texture=path .. "texture.xml",
                        armatureName="fla_leishajinbi",
                        aniName="",
                        skeletonName="fla_leisha",
                    })
                    :addTo(self.db_node)
                    :pos(startX,startY+80)

                    -- coin:addScriptListener(cc.DragonBonesNode.EVENTS.COMPLETE, function()
                    --     if step==1 then
                    --         step = step + 1
                    --         coin:getAnimation():gotoAndPlay("stand")

                    --         local ts = 0.4
                    --         coin:runAction(transition.sequence({
                    --             cc.MoveTo:create(ts, cc.p(endX, endY)),
                    --             cc.CallFunc:create(function(obj)
                    --                 step=step+1
                    --                 coin:getAnimation():gotoAndPlay("end")
                    --             end)
                    --         }))
                    --     elseif step==3 then
                    --         coin:removeFromParent()
                    --         if reward then
                    --             app:tip(9, reward, endX-30, endY, 9999, nil, 40)
                    --         end
                    --     end
                    -- end)

                    coin:registerAnimationEventHandler(function(evt)
                        if evt.type == 7 then
                            if step==1 then
                                step = step + 1
                                coin:getAnimation():gotoAndPlay("stand")

                                local ts = 0.4
                                coin:runAction(transition.sequence({
                                    cc.MoveTo:create(ts, cc.p(endX, endY)),
                                    cc.CallFunc:create(function(obj)
                                        step=step+1
                                        coin:getAnimation():gotoAndPlay("end")
                                    end)
                                }))
                            elseif step==3 then
                                coin:removeFromParent()
                                if reward then
                                    app:tip(9, reward, endX-30, endY, 9999, nil, 40)
                                end
                            end
                        end
                    end)

                    coin:getAnimation():gotoAndPlay("born")
                end
            end)

            -- local lieShaSprite = dragonbones_:getArmature():getBone("leisha_baiz")
            local lieShaSprite = dragonbones_:getArmature():getCCSlot("leisha_baiz")
            if lieShaSprite then
                local sprite = display.newSprite("hunt_icon.png")
                -- lieShaSprite:setDisplay(dragonBones.CCDBNode:new(sprite))
                lieShaSprite:getCCDisplay():addChild(sprite)
            end
        end
        anims[k] = dragonbones_
    end

    local anim = nil
    for i = 1, #anims do
        local anim = anims[i]:getAnimation()
        anim:play()
    end

    nk.SoundManager:playSound("sounds/Hunt.mp3")
end

function AnimManager:playRebuyAnim(x,y)
    if not self.db_node then
        self.db_node = display.newNode():addTo(self.scene.nodes.animNode)
    end
    local path = "dragonbones/fla_leisha/"
    local dragonbones_ = dragonbones.new({
        skeleton=path .. "skeleton.xml",
        texture=path .. "texture.xml",
        armatureName="fla_leishakuang",
        aniName="",
        skeletonName="fla_leisha",
    })
        :addTo(self.db_node)
        :pos(x,y)
    -- local lieShaSprite = dragonbones_:getArmature():getBone("leisha_baiz")
    local lieShaSprite = dragonbones_:getArmature():getCCSlot("leisha_baiz")
    if lieShaSprite then
        local sprite = display.newSprite("rebuy_icon.png")
        -- lieShaSprite:setDisplay(dragonBones.CCDBNode:new(sprite))
        lieShaSprite:getCCDisplay():addChild(sprite)
    end
    dragonbones_:getAnimation():play()
end

function AnimManager:playDragonBonesAnim(type_, label_, cardType_)
    if not self.db_node then
        self.db_node = display.newNode():addTo(self.scene.nodes.animNode)
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
            armatures = {"fla_paixingzhong3_ADDITIVE", "fla_paixinggao2", "fla_paixinggao_ADDITIVE"}
            label_Bone = {2, "paixinggao_TH"}
        elseif type_ == 2 then
            armatures = {"fla_paixingzhong3_ADDITIVE", "fla_paixingzhong", "fla_paixingzhong2_ADDITIVE"}
            label_Bone = {2, "paixingzhong_zitia "}
        elseif type_ == 3 then
            armatures = {"fla_paixingzhong3_ADDITIVE", "fla_paixingxiao", "fla_paixingxiao_ADDITIVE"}
            label_Bone = {2, "paixingxiao_zitia "}
        end
        self:playDBYouWinAnim(armatures, label_Bone, label_, cardType_)
    elseif type_ < 20 then
        local armatures = {}
        local path = ""
        local skeletonName = ""
        if type_ == 11 then
            armatures = {"fla_allinzhu", "fla_allinzhu_ADDITIVE"}
            path = "dragonbones/fla_allinzhu/"
            skeletonName = "fla_allinzhu"
        end
        self:playDBAllInAnim(armatures, path, skeletonName)
    end
end

function AnimManager:playDBYouWinAnim(armatures, label_Bone, label_, cardType_)
    local path = "dragonbones/paixing/"
    for i = 1, #armatures do
        self.dbs[i] = dragonbones.new({
                skeleton=path .. "skeleton.xml",
                texture=path .. "texture.xml",
                armatureName=armatures[i],
                aniName="",
                skeletonName="fla_paixing",
            })
            :addTo(self.db_node, i)
            :pos(display.cx,display.cy + 80)
    end
    if #label_Bone == 2 and self.dbs[label_Bone[1]] then
        -- label_Bone_ = self.dbs[label_Bone[1]]:getArmature():getSlot(label_Bone[2])
        label_Bone_ = self.dbs[label_Bone[1]]:getArmature():getCCSlot(label_Bone[2])
    end
    if label_ and label_Bone_ and cardType_ and cardType_~=consts.CARD_TYPE.POINT_CARD then--
        local text = nil
        if _G.appconfig.LANG_FILE_NAME=="lang_th" then
            text = display.newSprite(string.format("card_type_%d.png",cardType_)):pos(0, 10)
        else
            text = ui.newTTFLabel({text = label_, color = styles.FONT_COLOR.GOLDEN_TEXT, size = 48, align = ui.TEXT_ALIGN_CENTER})
        end
        -- label_Bone_:setDisplayNode(text)
        label_Bone_:getCCDisplay():addChild(text)
    else
        local diban = self.dbs[2]:getArmature():getBone("paixingxiao_diban")
        if diban then
            diban:setVisible(false)
        end
    end
    for i = 1, #self.dbs do
        self.dbs[i]:getAnimation():play()
    end
end

function AnimManager:playDBAllInAnim(armatures, path, skeletonName)
    for i = 1, #armatures do
        self.dbs[i] = dragonbones.new({
                skeleton=path .. "skeleton.xml",
                texture=path .. "texture.xml",
                armatureName=armatures[i],
                aniName="",
                skeletonName=skeletonName,
            })
            :addTo(self.db_node, i)
            :pos(display.cx,display.cy + 80)
    end
    for i = 1, #self.dbs do
        self.dbs[i]:getAnimation():play()
    end
end

function AnimManager:_onMovement(evtType, movId)
    if evtType == cc.DragonBonesNode.EVENTS.START then
    elseif evtType == cc.DragonBonesNode.EVENTS.COMPLETE then
    end
end

function AnimManager:playAddFriendAnimation(fromSeatId, toSeatId)
    local fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    local toPositionId = self.seatManager:getSeatPositionId(toSeatId)
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
    if toSeatId == 9 then
        toX = display.cx + 10
        toY = RoomViewPosition.SeatPosition[1].y - 46
    else
        toX = SeatPosition[toPositionId].x
        toY = SeatPosition[toPositionId].y
    end
    if not self.sendChipViews_ then
        self.sendChipViews_ = {}
    end

    local sp = SendChipView.new(chips,self.model:isCoinRoom()):addTo(self.scene.nodes.animNode)
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
            if toSeatId ~= 9 then
                self.seatManager:updateSeatState(toSeatId)
            end
        end,
    })
end

function AnimManager:playRewardAnimationWhenSendChipToDealer(fromSeatId, toSeatId, data)
    local fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    local toPositionId = self.seatManager:getSeatPositionId(toSeatId)
    local fromX, fromY
    if fromSeatId == 9 then
        fromX = display.cx + 10
        fromY = RoomViewPosition.SeatPosition[1].y - 46
    else
        fromX = SeatPosition[fromPositionId].x
        fromY = SeatPosition[fromPositionId].y
    end

    local sp = DealerRewardView.new(data.bagtype, data.msg):addTo(self.scene.nodes.animNode)

    sp:pos(fromX, fromY)

    local sequence = transition.sequence({
                        cc.MoveTo:create(1, cc.p(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y)),
                        cc.CallFunc:create(function()
                            sp:showContent()
                        end),
                        cc.DelayTime:create(3),
                        cc.CallFunc:create(function()
                            sp:removeFromParent()
                            if toSeatId ~= 9 then
                                self.seatManager:updateSeatState(toSeatId)
                            end
                        end)
                    })
    sp:runAction(sequence)
end

function AnimManager:playSendGiftAnimation(giftId, fromUid, toUidArr)
    LoadGiftControl:getInstance():getGiftUrlById(giftId, function(url)
        if url and self:checkUidInSeat({fromUid}) and self:checkUidInSeat(toUidArr) then
            -- 
            local sendGiftCallback_ = function(success, sprite)
                if success and self:checkUidInSeat({fromUid}) and self:checkUidInSeat(toUidArr) then
                    local tex
                    local scaleVal = 0.5
                    if sprite then
                        tex = sprite:getTexture()
                    else
                        tex = "#sm_flash_star.png"
                        scaleVal = 2
                    end

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

                            local sp = display.newSprite(tex):pos(fromX, fromY):scale(scaleVal):addTo(self.scene.nodes.animNode)
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
            end
            -- 
            local params = bm.getFileNameByFilePath(url)
            if params["extension"] == "zip" then
                nk.ImageLoader:loadAndCacheAnimationExt(nil, nk.ImageLoader:nextLoaderId(), url, sendGiftCallback_, nk.ImageLoader.CACHE_TYPE_ANIMATION)
            else
                nk.ImageLoader:loadAndCacheImage(nk.ImageLoader:nextLoaderId(), url, sendGiftCallback_, nk.ImageLoader.CACHE_TYPE_GIFT)
            end
            
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

function AnimManager:playHddjAnimation(fromSeatId, toSeatId, hddjId, isRecv)
    local fromPositionId
    local toPositionId
    if fromSeatId ~= 9 then
        fromPositionId = self.seatManager:getSeatPositionId(fromSeatId)
    else
        fromPositionId = 10
    end
    if toSeatId <= 9  then
        toPositionId = self.seatManager:getSeatPositionId(toSeatId)
    else
        toPositionId = 10
    end
    if not self.sendHddjs_ then
        self.sendHddjs_ = {}
    end
    local sp
    sp = self.hddjController_:playHddj(fromPositionId, toPositionId, hddjId, function()
            -- nk.TopTipManager:showTopTip("self.sendHddjs_::"..tostring(#self.sendHddjs_).."  sp::"..tostring(sp))
            if hddjId > 1000 and not isRecv then
                local index = checkint(math.random(3))
                local message = {messagetype = 2,content = bm.LangUtil.getText("WATERLAMP", "BLESSING" .. index)}
                nk.socket.RoomSocket:sendChatMsg(message)
            end

            if sp then
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

function AnimManager:setAnimCompleteCallback(callback)
    -- body
    self.animComplCallBack_ = callback
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
    local bubble
    if seatId==-100 then -- 荷官说话
        bubble = RoomChatBubble.new(message, RoomChatBubble.DIRECTION_LEFT)
        local px, py = display.cx + 32, RoomViewPosition.SeatPosition[1].y + 16
        bubble:show(self.scene.nodes.animNode, px, py)
    elseif seatId ~= -1 then
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
        --删除之前还在显示的消息
        if self.chatBubble_ then
            self.chatBubble_:stopAllActions()
            self.chatBubble_:removeFromParent()
        end

        self.chatBubble_ = bubble
        self.chatBubble_:runAction(transition.sequence({cc.DelayTime:create(5), cc.CallFunc:create(function() 
            self.chatBubble_:removeFromParent()
            self.chatBubble_ = nil
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

    if self.chatBubble_ then
        self.chatBubble_:removeFromParent()
        self.chatBubble_ = nil
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

function AnimManager:bindDataObservers_()
    self.onSignalStengthHandlerId_ = bm.DataProxy:addDataObserver(nk.dataKeys.SIGNAL_STRENGTH, handler(self, self.onSignalStrengthChanged_))
end

function AnimManager:unbindDataObservers_()
    bm.DataProxy:removeDataObserver(nk.dataKeys.SIGNAL_STRENGTH, self.onSignalStengthHandlerId_)
end

return AnimManager