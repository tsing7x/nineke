--
-- Author: viking@boomegg.com
-- Date: 2014-11-21 10:51:55
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local SlotController = class("SlotController")

function SlotController:ctor(view)
    self.view_ = view
    bm.EventCenter:addEventListener(nk.eventNames.SLOT_PLAY_RESULT, handler(self, self.onPlayResultListener_))
    bm.EventCenter:addEventListener(nk.eventNames.SLOT_BUY_RESULT, handler(self, self.onBuyResultListener_))
    self:getShowSlot_()
    if not self.view_:isInRoom() then
        self.isOpened = true
    end
end

local sideBtnAminTime = 0.2
local sideBtnMinDistance = 5
function SlotController:sideBarCallback_(evtName, xArgs)
    if not self.view_:isInRoom() then
        return
    end
    local startX, currentX = xArgs.startX, xArgs.currentX
    local distance = currentX - startX
    local isOpening = self.isOpened or false
    if distance > 0 then
        isOpening = false
    else
        isOpening = true
    end

    local width = display.width
    local view_ = self.view_
    -- view_:closeUnVisible(false)
    local srcX = view_:getSrcX()
    local endX = view_:getEndX()
    local posX = view_:getPositionX()
    local moveX = (isOpening and srcX or endX) + distance
    self.view_:runTipAnim(false)
    if evtName == "began" then
        --todo
    elseif evtName == "moved" then
        if moveX <= endX then
            moveX = endX
            self.isOpened = true
        elseif moveX >= srcX then
            moveX = srcX
            self.isOpened = false
        end
        if math.abs(distance) > sideBtnMinDistance then
            view_:setPositionX(moveX)
        end
        -- print("SlotController:sideBarCallback_ moveX", self.isOpened, moveX)
    elseif evtName == "ended" then
        if moveX ~= srcX and moveX ~= endX then
            local srcY = view_:getPositionY()
            if isOpening then
                local sequence = transition.sequence({
                        cc.MoveTo:create(sideBtnAminTime, cc.p(endX, srcY)),
                        cc.CallFunc:create(function()
                            self.isOpened = true
                        end)
                    })
                view_:runAction(sequence)
            else
                local sequence = transition.sequence({
                        cc.MoveTo:create(sideBtnAminTime, cc.p(srcX, srcY)),
                        cc.CallFunc:create(function()
                            self.isOpened = false
                        end)
                    })
                view_:runAction(sequence)
                view_:setAutoCheckBoxAnim()
            end
        end
    elseif evtName == "clicked" then
        -- print("SlotController:sideBarCallback_ clicked", self.isOpened)
        local srcY = view_:getPositionY()
        if self.isOpened then
            local sequence = transition.sequence({
                    cc.MoveTo:create(sideBtnAminTime, cc.p(srcX, srcY)),
                    cc.CallFunc:create(function()
                        self.isOpened = false
                    end)
                })
            view_:runAction(sequence)                
        else
            local sequence = transition.sequence({
                    cc.MoveTo:create(sideBtnAminTime, cc.p(endX, srcY)),
                    cc.CallFunc:create(function()
                        self.isOpened = true
                    end)
                })
            view_:runAction(sequence)
            view_:setAutoCheckBoxAnim()
        end        
    end
    self.view_:getMinusMoneyView():stop()
    self.view_:getAddMoneyView():stop()
end

function SlotController:handlerCallback(isGcoins)
    -- print("SlotController:handlerCallback")
    if self:notEnoughMoney2Play(isGcoins) then
        return
    end

    local view_ = self.view_
    local betMoney = view_:getBetBar():getBet()
    if view_:isInRoom() then
        view_:getSideBar():handlerAnim()
    end
    -- nk.socket.SlotSocket:buySlot(betMoney, view_:getTid())
    self:buySlot_(tonumber(betMoney), isGcoins)
    if self.isOpened then
        nk.SoundManager:playSound(nk.SoundManager.SLOT_START)
    end
    view_:getFlashBar():stop()
    view_:getFlashBar():setTip(betMoney)
end

function SlotController:turningContentCallback(i, isGcoins, rewardMoney, leftMoney)
    if self.isOpened then
        nk.SoundManager:playSound(nk.SoundManager.SLOT_END)
    end
    local view_ = self.view_
    self.slotActive = false
    if i == 3 then
        --中奖
        if rewardMoney > 0 then
            local msg
            if isGcoins then
                msg = bm.LangUtil.getText("SLOT", "PLAY_WIN_BYGCOIN", bm.formatBigNumber(tonumber(rewardMoney)))
            else
                msg = bm.LangUtil.getText("SLOT", "PLAY_WIN", bm.formatBigNumber(tonumber(rewardMoney)))
            end
            nk.TopTipManager:showTopTip(msg)
            if self.isOpened then
                nk.SoundManager:playSound(nk.SoundManager.SLOT_WIN)
                local flashBar_ = view_:getFlashBar()
                flashBar_:flash(rewardMoney)
                flashBar_:delayStop(2, function()
                    if self.slotActive then
                        flashBar_:setTip(view_:getBetBar():getBet())
                    end
                end)
            else
                --没有打开
                view_:getSideBar():glowAnim()
                view_:getAddMoneyView():playAnim(rewardMoney)
            end

            -- 在座位上飘出一个减筹码或黄金币动画
            local itype = 1
            if isGcoins then
                itype = 9
            end
            -- bm.EventCenter:dispatchEvent({name="onAddMoneyAnimationEvent", data={itype=itype, num=tonumber(rewardMoney)}})
        end

        --自动操作的情况
        if view_:getAutoCheckBox():isChecked() then
            view_:getHandler():loopAutoHandler()
        else
            view_:getHandler():setEnabled(true)
        end
        -- 同步数据
        if isGcoins then
            nk.userData.gcoins = tonumber(leftMoney)
        else
            nk.userData.money = tonumber(leftMoney)
        end
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
    elseif i == 1 and self.loopSoundId then
        audio.stopSound(self.loopSoundId)
    end
    if i == 3 then
        nk.schedulerPool:delayCall(function()
            bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
        end,0.5)
    end
end

function SlotController:autoCheckCallback(isChecked)
    -- print("SlotController:autoCheckCallback", isChecked)
    local view_ = self.view_
    local handler_ = view_:getHandler()
    if isChecked then
        if not self.slotActive then
            handler_:setEnabled(false)
            handler_:loopAutoHandler()
        end
    else
        if not self.slotActive then
            handler_:setEnabled(true)
        end
        handler_:stopLoopAutoHandler()
    end
end

function SlotController:onPlayResultListener_(evt)
    -- print("SlotController:onPlayResultListener_")
    if self.isOpened then
        self.loopSoundId = nk.SoundManager:playSound(nk.SoundManager.SLOT_LOOP, true)
    end
    local view_ = self.view_
    self.slotActive = true
    view_:getHandler():setEnabled(false)
    view_:getTurningContent():start(evt.data)
end

function SlotController:onBuyResultListener_(evt)
    --购买成功并且关闭
    if evt.data == 0 and not self.isOpened then
        local view_ = self.view_
        local betMoney = bm.formatBigNumber(view_:getBetBar():getBet())
        view_:getMinusMoneyView():playAnim(betMoney)
    end
end
-- isGcoins:true为黄金币，false为筹码
function SlotController:notEnoughMoney2Play(isGcoins)
    local myMoney, tips
    if isGcoins then
        myMoney = nk.userData.gcoins
        tips = bm.LangUtil.getText("SLOT", "NOT_ENOUGH_MONEY")
    else
        myMoney = nk.userData.money 
        tips = bm.LangUtil.getText("SLOT", "NOT_ENOUGH_GCOINS")
    end

    local view_ = self.view_
    local betMoney = view_:getBetBar():getBet()
    if tonumber(myMoney) < tonumber(betMoney) then
        nk.TopTipManager:showTopTip(tips)
        if view_ then
            view_:changCheckBoxStatus(false)
        end
        return true
    end
    return false
end

function SlotController:Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

function SlotController:getShowSlot_()
    local getConfig
    local retry = 3
    getConfig = function()
        bm.HttpService.POST({
                mod = "Slot",
                act = "getShowSlot"
            },
            function(data)
                local jsn = json.decode(data)
                if jsn and jsn.ret == 1 then
                    self.slotconfig = jsn.data
                else
                    retry = retry - 1
                    if retry > 0 then
                        getConfig()
                    end
                end
            end,
            function()
                retry = retry - 1
                    if retry > 0 then
                        getConfig()
                    end
            end)
    end
    getConfig()
end

function SlotController:buySlot_(betMoney, isGcoins)
    if self.slotBuyId_ then
        return
    end
    -- 
    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="start"})

    local actKey = "ernieSlot"
    local resultKey = "addmoney"
    local totalKey = "money"
    local enoughTips = bm.LangUtil.getText("SLOT", "NOT_ENOUGH_MONEY")
    -- 判断是否黄金币老虎机
    local whereclick = 1  -- whereclick = int 0在房间，1在大厅；
    if display.getRunningScene().name == "RoomScene" then
        whereclick = 0
    end
    -- 
    if isGcoins then
        actKey = "ernieGcoinsSlot"
        resultKey = "addgcoins"
        totalKey = "gcoins"
        enoughTips = bm.LangUtil.getText("SLOT", "NOT_ENOUGH_GCOINS")
    end
    self.slotBuyId_ = bm.HttpService.POST({
            mod = "Slot",
            act = actKey,
            gcoins = betMoney,
            money = betMoney,
            whereclick = whereclick,
        },
        function(data)
            print("Slot:::"..data)
            self.slotBuyId_ = nil
            local result = json.decode(data)
            if not result then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "SYSTEM_ERROR"))
                bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
                return
            end
            -- 
            local ret = result.ret
            if ret == 1 then
                local itype = 1
                if isGcoins then
                    itype = 9
                end
                -- 在座位上飘出一个减筹码或黄金币动画
                -- bm.EventCenter:dispatchEvent({name="onAddMoneyAnimationEvent", data={itype=itype, num=tonumber(betMoney)*-1}})
                -- 
                local totalNum = tonumber(result[totalKey] or 0)  -- 转动后最终剩余筹码或黄金币(包括奖励的)
                local moneyNum = tonumber(result[resultKey] or 0) -- 本次转动后奖励筹码或黄金币
                local rewardArr = self:Split(result.cardtype, ",")
                local values = {tonumber(rewardArr[1]),tonumber(rewardArr[2]),tonumber(rewardArr[3])}
                bm.EventCenter:dispatchEvent({name = nk.eventNames.SLOT_BUY_RESULT, data = ret})
                bm.EventCenter:dispatchEvent({name = nk.eventNames.SLOT_PLAY_RESULT, data = {values = values, totalNum=totalNum, rewardMoney = tonumber(moneyNum)}})
                if isGcoins then
                    nk.userData.gcoins = tonumber(nk.userData.gcoins) - tonumber(betMoney)
                else
                    nk.userData.money = tonumber(nk.userData.money) - tonumber(betMoney)
                end
                -- end
                return
            elseif ret == -3 then
                nk.TopTipManager:showTopTip(enoughTips)
                if self.view_ then
                    self.view_:changCheckBoxStatus(false)
                end
            elseif ret == -1 or ret == -2 or ret == -4 or ret == -5 or ret == -6 or ret == -7 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "SYSTEM_ERROR"))
            else
                print '未知错误'
            end
            bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
        end, function()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT","SYSTEM_ERROR"))
            bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
            self.slotBuyId_ = nil
        end)
end

function SlotController:dispose()
    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.SLOT_PLAY_RESULT)
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.SLOT_BUY_RESULT)
    if self.loopSoundId then
        audio.stopSound(self.loopSoundId)
    end
    local view_ = self.view_
    if view_:isInRoom() then
        view_:getAddMoneyView():dispose()
    end
    view_:getAutoCheckBox():dispose()
    view_:getBetBar():dispose()
    view_:getFlashBar():dispose()
    view_:getHandler():dispose()
    if view_:isInRoom() then
        view_:getMinusMoneyView():dispose()
        view_:getSideBar():dispose()
    end
    view_:getTurningContent():dispose()
end

return SlotController
