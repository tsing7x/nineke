--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-05 09:35:57
--
local DiceChipManager = class("DiceChipManager")
local DiceBetChipView = import(".views.DiceBetChipView")
local DiceChipData = import(".views.DiceChipData")

function DiceChipManager:ctor()
end

function DiceChipManager:createNodes()
    self.chipBatchNode_ = display.newNode():addTo(self.scene.nodes.chipNode)
    local function funcFactory(filename,num)
        return function()
            return DiceChipData.new(filename,num)
        end
    end

    self.chipPool_ = {}
    self.chipPool_[1] = bm.ObjectPool.new(funcFactory("#dice_bet_100.png",1), true, 10, 15, true)
    self.chipPool_[2] = bm.ObjectPool.new(funcFactory("#dice_bet_500.png",2), true, 10, 15, true)
    self.chipPool_[3] = bm.ObjectPool.new(funcFactory("#dice_bet_1000.png",3), true, 10, 15, true)
    self.chipPool_[4] = bm.ObjectPool.new(funcFactory("#dice_bet_5k.png",4), true, 10, 15, true)
    self.chipPool_[5] = bm.ObjectPool.new(funcFactory("#dice_bet_10K.png",5), true, 10, 15, true)
    self.chipPool_[6] = bm.ObjectPool.new(funcFactory("#dice_bet_50K.png",6), true, 10, 15, true)
    self.chipPool_[7] = bm.ObjectPool.new(funcFactory("#dice_bet_100k.png",7), true, 10, 15, true)
    self.chipPool_[8] = bm.ObjectPool.new(funcFactory("#dice_bet_1m.png",8), true, 10, 15, true)
    self.chipPool_[9] = bm.ObjectPool.new(funcFactory("#dice_bet_10m.png",9), true, 10, 15, true)

    self.betChipViews_ = {}
    for i = 1, 8 do
        self.betChipViews_[i] = DiceBetChipView.new(self.chipBatchNode_, self, i)
    end
    self.chipKeys = {100,500,1000,5000,10000,50000,100000,1000000,10000000}
end

function DiceChipManager:betChip(uid,bettype,betchip,callback)
    local seatId = self.ctx.model:getSeatIdByUid(uid)
    local position = self.diceSeatManager:getPosition(seatId,uid)
    self.betChipViews_[bettype]:userBet(position,betchip,callback)
    nk.SoundManager:playSound(nk.SoundManager.DICE_BET)
end

function DiceChipManager:betChipSelf(bettype,betchip,x,y,callback)
    self.betChipViews_[bettype]:userBet(9,betchip,callback,x,y)
    nk.SoundManager:playSound(nk.SoundManager.DICE_BET)
end

function DiceChipManager:betChipOther(bettype,betchip,callback)
    self.betChipViews_[bettype]:userBet(10,betchip,callback)
    nk.SoundManager:playSound(nk.SoundManager.DICE_BET)
end


function DiceChipManager:updateAllChips(data)
    for i,v in pairs(data) do
        self.betChipViews_[v.type]:showChips(v.betChip)
    end
end

function DiceChipManager:showWinResult(data,dealId)
    for i = 1,8 do
        local lose = true
        for k,v in pairs(data) do
            if i == v.wintype then
                lose = false
                break
            end
        end
        if lose then
            self.betChipViews_[i]:moveToDealer(dealId)
        end
    end
    self.gameSchedulerPool:delayCall(function()
        for i,v in pairs(data) do
            self.betChipViews_[v.wintype]:showWinResult(v,dealId)
        end
    end, 1.2)
    
end

function DiceChipManager:getChipData(chips)
    local chipDataArr = {}
    local num = chips
    local keys = {}
    local count = #self.chipKeys
    for i = count,1,-1 do
        local k = self.chipKeys[i]
        if num >= k then
            local t = num / k
            for m = 1,t do
                table.insert(chipDataArr,self.chipPool_[i]:retrive())
                num = num - k
                if #chipDataArr > 200 then
                    break
                end
            end
        end
        if #chipDataArr > 200 then
            num = 0
            break
        end
    end
    if num > 0 then
        table.insert(chipDataArr,self.chipPool_[1]:retrive())
    end
    return chipDataArr
end

function DiceChipManager:recycleChipData(chipDataArr)
    if chipDataArr then
        for _,chipData in pairs(chipDataArr) do
            chipData:getSprite():opacity(255):removeFromParent()
            self.chipPool_[chipData:getNum()]:recycle(chipData)
        end
    end
end

function DiceChipManager:recycleChip(chipData)
    chipData:getSprite():opacity(255):removeFromParent()
    self.chipPool_[chipData:getNum()]:recycle(chipData)
end

function DiceChipManager:reset()
    for _, v in pairs(self.betChipViews_) do
        v:reset()
    end
end

function DiceChipManager:dispose()
    for _, v in pairs(self.betChipViews_) do
        v:dispose()
    end
    for _, v in pairs(self.chipPool_) do
        v:dispose()
    end
end

return DiceChipManager