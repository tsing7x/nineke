--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-01 15:48:59
--
local DiceSeatManager = class("DiceSeatManager")

local DiceSeatView = import(".views.DiceSeatView")
local P = import(".views.DiceViewPosition")

function DiceSeatManager:ctor()
    self.diceviews_ = {}
    self.diceviewId_ = {}
end

function DiceSeatManager:createNodes()
    self.diceseatnode_ = display.newNode():addTo(self.scene.nodes.seatNode)
    for i = 1,8 do
        self.diceviews_[i] = DiceSeatView.new(self.ctx,i)
            :pos(P.SeatPosition[i].x,P.SeatPosition[i].y)
            :addTo(self.diceseatnode_)
        self.diceviewId_[i] = -1
    end
end

function DiceSeatManager:resetBindIds()
    for i = 1,8 do
        self.diceviewId_[i] = -1
    end
end

function DiceSeatManager:initSeats(players)
    for i,v in pairs(players) do 
        local viewId = self:getViewIdBySeatId(-1)
        if viewId > 0 then
            self.diceviews_[viewId]:setData(json.decode(v.userInfo),json.decode(v.userInfoEx))
            self.diceviews_[viewId]:setSeatId(v.seatId)
            self.diceviewId_[viewId] = v.seatId
        end
    end
end

function DiceSeatManager:updateUserSitDown(seatId)
    local viewId = self:getViewIdBySeatId(-1)
    if viewId > 0 then
        local seatData = self.model.playerList[seatId]
        self.diceviews_[viewId]:setData(json.decode(seatData.userInfo),json.decode(seatData.userInfoEx))
        self.diceviews_[viewId]:setSeatId(seatId)
        self.diceviewId_[viewId] = seatId
    end
end

function DiceSeatManager:updateUserStandUp(seatId)
    local viewId = self:getViewIdBySeatId(seatId)
    if viewId > 0 then
        self.diceviews_[viewId]:setData(nil)
        self.diceviewId_[viewId] = -1
    end
end

function DiceSeatManager:updateSeatState(seatId)
    local viewId = self:getViewIdBySeatId(seatId)
    if viewId > 0 then
        local seatData = self.model.playerList[seatId]
        self.diceviews_[viewId]:setData(json.decode(seatData.userInfo),json.decode(seatData.userInfoEx))
        self.diceviewId_[viewId] = seatId
    end
end

function DiceSeatManager:getViewIdBySeatId(seatId)
    for i = 1,8 do
        if self.diceviewId_[i] == seatId then
            return i
        end
    end
    return -1
end

function DiceSeatManager:getSeatIdByViewId(viewId)
    return self.diceviewId_[viewId] 
end

function DiceSeatManager:getPosition(seatId,uid)
    local position = -1
    if uid == nk.userData.uid then
        positionId = 9
    else
        if seatId > -1 then
            positionId = self:getViewIdBySeatId(seatId)
            if positionId == -1 then
                positionId = 10
            end
        else
            positionId = 10
        end
    end
    return positionId
end

return DiceSeatManager