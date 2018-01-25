--
-- Author: johnny@boomegg.com
-- Date: 2014-08-14 22:11:43
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local HddjController = class("HddjController")
local DragonBonesHddj   = import("boomegg.ui.DragonBonesHddj")
local RoomViewPosition = import(".views.RoomViewPosition")
local SeatPosition = RoomViewPosition.SeatPosition

function HddjController:ctor(container,isPdeng)
    self.container_ = container
    self.loadedHddjIds_ = {}
    self.loadingHddj_ = {}
    self:refreshHddjNum()
    self.loadHddjNumEventListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.ROOM_LOAD_HDDJ_NUM, handler(self, self.loadHddjNum))
    self.refreshHddjNumEventListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.ROOM_REFRESH_HDDJ_NUM, handler(self, self.refreshHddjNum))
    if isPdeng then
        RoomViewPosition = import("app.module.pdeng.views.RoomViewPosition")
        SeatPosition = clone(RoomViewPosition.SeatPosition)
        SeatPosition[5] = RoomViewPosition.SelfSeatPosition[2]
    else
        RoomViewPosition = import("app.module.room.views.RoomViewPosition")
        SeatPosition = RoomViewPosition.SeatPosition
    end
end

function HddjController:dispose()
    for k, v in pairs(self.loadedHddjIds_) do
        display.removeAnimationCache("hddjAnim" .. k)
        display.removeSpriteFramesWithFile("hddjs/hddj-" .. k .. ".plist", "hddjs/hddj-" .. k .. ".png")
    end
    self.loadedHddjIds_ = nil
    self.loadingHddj_ = nil
    self.isDisposed_ = true
    bm.EventCenter:removeEventListener(self.loadHddjNumEventListenerId_)
    bm.EventCenter:removeEventListener(self.refreshHddjNumEventListenerId_)
end

function HddjController:loadHddjNum()
    if not nk.userData.hddjNum then
        self:refreshHddjNum()
    end
end

function HddjController:refreshHddjNum()
    if not self.isHddjNumLoading_ then
        self.isHddjNumLoading_ = true
        nk.userData.hddjNum = nil
        local request
        request = function(times)
            bm.HttpService.POST({mod="user", act="getUserFun"}, function(ret)
                self.isHddjNumLoading_ = false
                local num = tonumber(ret)
                if num then
                    nk.userData.hddjNum = num
                end
            end,
            function()
                if times > 0 then
                    request(times - 1)
                else
                    self.isHddjNumLoading_ = false
                end
            end)
        end
        request(3)
    end
end

function HddjController:playHddj(fromPositionId, toPositionId, hddjId, completeCallback)
    if self.isDisposed_ then
        return
    elseif hddjId == 1 then
        return self:playEgg(fromPositionId, toPositionId, completeCallback)
    elseif hddjId == 10 then
        return self:playTissue(fromPositionId, toPositionId, completeCallback)
    elseif hddjId == 4 then
        return self:playKiss(fromPositionId, toPositionId, completeCallback)
    else
        if hddjId > 1000 then
            self:playHddjAnim(hddjId, fromPositionId, toPositionId, completeCallback) 
        elseif hddjId > 200 then
            return self:playDragonAnim(hddjId, fromPositionId, toPositionId, completeCallback)
        else
            return self:playHddjAnim(hddjId, fromPositionId, toPositionId, completeCallback) 
        end
    end
end

HddjController.hddjConfig = {
    [2] = {frameNum=13, x=35, y=30, iconX=35 + 48, iconY=30 + 38, soundDelay=0.2},
    [3] = {frameNum=14},
    [5] = {frameNum=12, y=12},
    [6] = {frameNum=14, iconScale=0.8, curvePath=true, delay=0, rotation=3, x=0, y=-10, iconX=0, iconY=10, soundDelay=0.2},
    [7] = {frameNum=13, scale=1.6, iconScale=1.6, x=0, y=10, iconX=-38 * 1.6, iconY=-20},
    [8] = {frameNum=15, x=-4, y=0, iconX=44, iconY=26, soundDelay=0.2},
    [9] = {frameNum=17, delay=0, x=0, y=0, iconX=0, iconY=0},
    [11] = {frameNum=10, x = 22, iconX = 22},
    [11] = {frameNum=10, x = 22, iconX = 22},
    [17] = {frameNum = 9, x = 0, iconX = 0, iconScale = 1.6, scale = 0.6},
    [1009] = {frameNum=11},
    [1010] = {frameNum=8}
}

function HddjController:playHddjAnim(hddjId, fromPositionId, toPositionId, completeCallback)

    local container = display.newNode():addTo(self.container_)
    local animName = "hddjAnim" ..hddjId
    if self.loadedHddjIds_[hddjId] then
        print(animName .. " loaded")
        self.loadedHddjIds_[hddjId] = bm.getTime()
        local anim = display.getAnimationCache(animName)
        self:playHddjAnim_(hddjId, container, anim, fromPositionId, toPositionId, completeCallback)
    elseif self.loadingHddj_[hddjId] then
        print(animName .. " loading")
        table.insert(self.loadingHddj_[hddjId], function(anim)
            self:playHddjAnim_(hddjId, container, anim, fromPositionId, toPositionId, completeCallback)
        end)
    else
        print(animName .. " not loading")
        self.loadingHddj_[hddjId] = {}
        table.insert(self.loadingHddj_[hddjId], function(anim)
            self:playHddjAnim_(hddjId, container, anim, fromPositionId, toPositionId, completeCallback)
        end)
        display.addSpriteFrames("hddjs/hddj-" .. hddjId .. ".plist", "hddjs/hddj-" .. hddjId .. ".png", function()
            print(animName .. " texture loaded")
            if self.isDisposed_ then
                display.removeSpriteFramesWithFile("hddjs/hddj-" .. hddjId .. ".plist", "hddjs/hddj-" .. hddjId .. ".png")
            else
                local config = HddjController.hddjConfig[hddjId]
                local frameNum = config.frameNum
                local loop = config.loop
                local frames = display.newFrames("hddj-" .. hddjId .. "-%04d.png", 1, frameNum, loop)
                local anim = display.newAnimation(frames, 1 / 10)
                display.setAnimationCache(animName, anim)
                while #self.loadingHddj_[hddjId] > 0 do
                    self.loadingHddj_[hddjId][1](display.getAnimationCache(animName))
                    table.remove(self.loadingHddj_[hddjId], 1)
                end
                self.loadingHddj_[hddjId] = nil
                self.loadedHddjIds_[hddjId] = bm.getTime()
                local keys = table.keys(self.loadedHddjIds_)
                if #keys > 4 then
                    table.sort(keys, function(o1, o2)
                        return self.loadedHddjIds_[o1] < self.loadedHddjIds_[o2]
                    end)
                    local delNum = #keys - 4
                    for i = 1, delNum do
                        local id = keys[i]
                        self.loadedHddjIds_[id] = nil
                        display.removeAnimationCache("hddjAnim" .. id)
                        display.removeSpriteFramesWithFile("hddjs/hddj-" .. id .. ".plist", "hddjs/hddj-" .. id .. ".png")
                    end
                end
            end
        end)
    end
    return container
end

function HddjController:playHddjAnim_(hddjId, container, anim, fromPositionId, toPositionId, completeCallback)
    print("playHddjAnim_", hddjId, container, anim, fromPositionId, toPositionId)
    if fromPositionId == nil or toPositionId == nil then
        return
    end
    local config = HddjController.hddjConfig[hddjId]
    local icon = display.newSprite("#hddj_" .. hddjId .. ".png"):scale(config.iconScale or 1)

    if hddjId == 1009 then 
        icon = display.newSprite("#waterLampAMov.png")
    elseif hddjId == 1010 then 
        icon = display.newSprite("#waterLampBMov.png")
    end

    icon:pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
    icon:addTo(container)
    if config.curvePath then
        local distance = cc.pGetDistance(cc.p(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y), cc.p(SeatPosition[toPositionId].x + (config.iconX or 0), SeatPosition[toPositionId].y + (config.iconY or 0)))
        local bconfig = {}
        --controlPoint_1
        bconfig[1] = cc.p((SeatPosition[fromPositionId].x + SeatPosition[toPositionId].x + (config.iconX or 0)) * 0.5, (SeatPosition[fromPositionId].y + SeatPosition[toPositionId].y + (config.iconY or 0)) * 0.5 + distance * 0.16)
        --controlPoint_2
        bconfig[2] = cc.p((SeatPosition[fromPositionId].x + SeatPosition[toPositionId].x + (config.iconX or 0)) * 0.5, (SeatPosition[fromPositionId].y + SeatPosition[toPositionId].y + (config.iconY or 0)) * 0.5 + distance * 0.16)
        --endPosition
        bconfig[3] = cc.p(SeatPosition[toPositionId].x + (config.iconX or 0), SeatPosition[toPositionId].y + (config.iconY or 0))
        icon:runAction(transition.sequence({
            cc.EaseInOut:create(cc.BezierTo:create(1, bconfig), 2),
            cc.DelayTime:create(config.delay or 0.1),
            cc.CallFunc:create(function()
                    icon:removeFromParent()
                    if not config.soundDelay then
                        nk.SoundManager:playHddjSound(hddjId)
                    end
                end)
        }))
    else
        icon:runAction(transition.sequence({
            cc.EaseOut:create(cc.MoveTo:create(1, cc.p(SeatPosition[toPositionId].x + (config.iconX or 0), SeatPosition[toPositionId].y + (config.iconY or 0))), 1),
            cc.DelayTime:create(config.delay or 0.1),
            cc.CallFunc:create(function()
                    icon:removeFromParent()
                    if not config.soundDelay then
                        nk.SoundManager:playHddjSound(hddjId)
                    end
                end)
        }))
    end

    if config.rotation then
        if SeatPosition[fromPositionId].x < SeatPosition[toPositionId].x then
            icon:rotateBy(1, 360 * config.rotation)
        else
            icon:rotateBy(1, -360 * config.rotation)
        end
    end

    local ani = display.newSprite():scale(config.scale or 1)
        :pos(SeatPosition[toPositionId].x + (config.x or 0), SeatPosition[toPositionId].y + (config.y or 0))
        :addTo(container)

    ani:playAnimationOnce(anim, true, function()
            completeCallback()
        end, 1 + (config.delay or 0.1))
    if config.soundDelay then
        ani:runAction(transition.sequence({
                cc.DelayTime:create(1 + (config.delay or 0.1) + config.soundDelay),
                cc.CallFunc:create(function()
                        nk.SoundManager:playHddjSound(hddjId)
                    end)
            }))
    end
end

function HddjController:playTissue(fromPositionId, toPositionId, completeCallback)
    local tissueSpr = display.newSprite("#hddj_tissue.png")
        :pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
        :scale(1.4)
        :addTo(self.container_)
    local baseTime = 0.6
    tissueSpr:runAction(transition.sequence(
        {
            cc.EaseOut:create(cc.MoveTo:create(1, cc.p(SeatPosition[toPositionId].x - 40, SeatPosition[toPositionId].y)), 1),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                    nk.SoundManager:playHddjSound(10)
                end),
            cc.Repeat:create(
                transition.sequence(
                    {
                        cc.MoveTo:create(0.5, cc.p(SeatPosition[toPositionId].x + 40, SeatPosition[toPositionId].y)), 
                        cc.MoveTo:create(0.5, cc.p(SeatPosition[toPositionId].x - 40, SeatPosition[toPositionId].y)), 
                    }
                ), 
                3
            ), 
            cc.CallFunc:create(function ()
                completeCallback()
            end)
        }
    ))
    return tissueSpr
end

function HddjController:playEgg(fromPositionId, toPositionId, completeCallback)
    local eggContainer = display.newNode():addTo(self.container_)
    local eggIconSpr = display.newSprite("#hddj_egg_icon.png")
        :scale(1.4)
        :pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
        :addTo(eggContainer)
    local distance = cc.pGetDistance(cc.p(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y), cc.p(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y + 20))
    local config = {}
    config[1] = cc.p((SeatPosition[fromPositionId].x + SeatPosition[toPositionId].x) * 0.5, (SeatPosition[fromPositionId].y + SeatPosition[toPositionId].y + 20) * 0.5 + distance * 0.15)
    config[2] = cc.p((SeatPosition[fromPositionId].x + SeatPosition[toPositionId].x) * 0.5, (SeatPosition[fromPositionId].y + SeatPosition[toPositionId].y + 20) * 0.5 + distance * 0.15)
    config[3] = cc.p(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y + 20)

    eggIconSpr:runAction(transition.sequence({
        cc.EaseInOut:create(cc.BezierTo:create(1, config), 2),
        cc.CallFunc:create(function()
            eggIconSpr:removeFromParent()

            nk.SoundManager:playHddjSound(1)

            local eggSpr = display.newSprite("#hddj_egg.png")
                :pos(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y + 20)
                :scale(1.4)
                :addTo(eggContainer)
            transition.scaleTo(eggSpr, {time = 1.5, scaleY = 1.2 * 1.4})
            transition.fadeOut(eggSpr, {time = 0.5, delay = 1})
            transition.moveTo(eggSpr, {
                time = 1.5, 
                y = SeatPosition[toPositionId].y - 30, 
                onComplete = function ()
                    completeCallback()
                end
            })
        end)
    }))
    if SeatPosition[fromPositionId].x < SeatPosition[toPositionId].x then
        eggIconSpr:rotateBy(1, 360 * 3)
    else
        eggIconSpr:rotateBy(1, -360 * 3)
    end
    return eggContainer
end

function HddjController:playDragonAnim(hddjId, fromPositionId, toPositionId, completeCallback)
    local sx, sy = SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y
    local ex, ey = SeatPosition[toPositionId].x, SeatPosition[toPositionId].y
    local iconImg = "songkran_ball_icon.png"
    local animationName = "fla_shuiqiu"
    if 202 == hddjId then
        animationName = "fla_shuipeng"
        iconImg = "songkran_hddj_202.png"
    elseif 203 == hddjId then
        animationName = "fla_shuiqiang"
        iconImg = ""
    end

    local container = display.newNode():addTo(self.container_)

    local actions = {}

    local icon
    if iconImg ~= "" then
        icon = display.newSprite(iconImg)
            :pos(sx, sy)
            :addTo(container)
        table.insert(actions, cc.EaseBounceOut:create(cc.ScaleTo:create(0.5, 1)))--反弹变化。类似球碰到地面，不断落下与反弹。
        table.insert(actions, cc.CallFunc:create(function()
            nk.SoundManager:playHddjSound(hddjId)
        end))
        table.insert(actions, cc.EaseSineIn:create(cc.MoveTo:create(0.5, cc.p(ex, ey))))--正弦变化
    else
        icon = display.newSprite()
            :pos(sx, sy)
            :addTo(container)
        table.insert(actions, cc.DelayTime:create(0.3))
        table.insert(actions, cc.CallFunc:create(function()
            nk.SoundManager:playHddjSound(hddjId)
        end))
    end
    
    table.insert(actions, cc.CallFunc:create(function()
            icon:removeFromParent()

            local path = "songkran_db/"..animationName.."/"
            local db = DragonBonesHddj.new(path, animationName)
                :pos(ex, ey)
                :addTo(self.container_)

            db:play("play", completeCallback)
        end))

    if sx < ex and hddjId == 201 then
        icon:rotation(180)
    end

    icon:scale(0)
    icon:runAction(transition.sequence(actions))

    return container
end

function HddjController:playKiss(fromPositionId, toPositionId, completeCallback)
    local kissLipSpr = display.newSprite("#hddj_kiss_lip_icon.png")
        :pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
        :scale(1.4)
        :addTo(self.container_)
    kissLipSpr:runAction(transition.sequence({
            cc.DelayTime:create(1.2),
            cc.CallFunc:create(function()
                nk.SoundManager:playHddjSound(4)
            end)
        }))
    kissLipSpr:runAction(transition.sequence({
        cc.EaseOut:create(cc.MoveTo:create(1, cc.p(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y)), 1),
        cc.Repeat:create(
            transition.sequence(
                {
                    cc.ScaleTo:create(0.5, 1.4 * 1.4), 
                    cc.CallFunc:create(function ()
                        local kissHeartSpr = display.newSprite("#hddj_kiss_heart.png")
                            :pos(0, 0)
                            :scale(1.4)
                            :addTo(kissLipSpr)
                        local ptArr = {
                            cc.p(26, 20),
                            cc.p(26-4 * 1.4, 20+20),
                            cc.p(26+4 * 1.4, 20+40),
                            cc.p(26-4 * 1.4, 20+60),
                            cc.p(26+4 * 1.4, 20+80),
                        }
                        transition.execute(kissHeartSpr, cc.CatmullRomTo:create(0.8, ptArr), {
                            onComplete = function ()
                                kissHeartSpr:removeFromParent()
                            end
                        })
                    end), 
                    cc.ScaleTo:create(0.5, 1.4), 
                }
            ), 
            3
        ), 
        cc.CallFunc:create(function ()
            completeCallback()
        end)
    }))
    return kissLipSpr
end

function HddjController:changeSeatPosition(isDealer)
    if isDealer then
        SeatPosition[5] = RoomViewPosition.SelfSeatPosition[1]
    else
        SeatPosition[5] = RoomViewPosition.SelfSeatPosition[2]
    end
end

return HddjController