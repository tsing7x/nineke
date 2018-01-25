--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-01 10:15:41
--
local BetTypeManager = class("BetTypeManager")
local P = import(".views.DiceViewPosition")

function BetTypeManager:ctor()
    self.typebutton_ = {}
    self.ratelabel_ = {}
    self.mychipslabel_ = {}
    self.mychips_ = {}
    self.allchipslabel_ = {}
    self.allchips_ = {}
    self.history_ = {}
    self.historySprite_ = {}
    self.historyTypeSprite_ = {}
end

function BetTypeManager:createNodes()
    self.bettypenode_ = display.newNode():addTo(self.scene.nodes.betTypeNode)
    for i = 1,8 do
        self.bettype_ = display.newSprite("#dice_bet_type_" .. i .. ".png")
        self.bettype_:pos(P.BetTypePosition[i].x,P.BetTypePosition[i].y + self.bettype_:getContentSize().height / 2)
        self.bettype_:addTo(self.bettypenode_)

        self.allchips_[i] = 0
        self.mychips_[i] = 0
        self.allchipslabel_[i] = cc.ui.UILabel.new({text = "", color = cc.c3b(126,147,228)})
            :pos(P.BetTypePosition[i].x + P.BetTypeArea[i].width / 2 - 5,P.BetTypePosition[i].y + P.BetTypeArea[i].height /2 - 3)
            :align(display.RIGHT_BOTTOM)
            :addTo(self.bettypenode_)
        self.allchips_[i] = 0
        self.mychipslabel_[i] = cc.ui.UILabel.new({text = "", color = cc.c3b(228,208,87)})
            :pos(P.BetTypePosition[i].x - P.BetTypeArea[i].width / 2 + 5,P.BetTypePosition[i].y + P.BetTypeArea[i].height /2 - 3)
            :align(display.LEFT_BOTTOM)
            :addTo(self.bettypenode_)

        self.ratelabel_[i] = cc.ui.UILabel.new({text = "",size=20,color = cc.c3b(44,53,122)})
        self.ratelabel_[i]:pos(P.BetTypePosition[i].x + P.BetTypeArea[i].width / 2 - 6, P.BetTypePosition[i].y - P.BetTypeArea[i].height /2)
            :align(display.RIGHT_BOTTOM)
            :addTo(self.bettypenode_)
        if i < 7 then
            self.ratelabel_[i]:setColor(cc.c3b(0xff,0xd0,0x48))
        end

        self.typebutton_[i] = cc.ui.UIPushButton.new({normal="#transparent.png",pressed="#transparent.png"},{scale9=true})
        :setButtonSize(P.BetTypeArea[i].width,P.BetTypeArea[i].height)
        :onButtonClicked(function(evt)
                self:sendBet(i,evt.x,evt.y)
            end)
        :pos(P.BetTypePosition[i].x,P.BetTypePosition[i].y)
        :addTo(self.bettypenode_)
        self.typebutton_[i]:setButtonEnabled(false)
    end

    for i = 1,20 do
        display.newSprite("#dice_win_history_bg.png")
            :pos(display.cx + (10.5 - i) * 15,display.cy -218)
            :addTo(self.bettypenode_)
    end
end


function BetTypeManager:setButtonEnabled(enabled)
    for i = 1,8 do
        self.typebutton_[i]:setButtonEnabled(enabled)
    end
end

function BetTypeManager:sendBet(type,x,y)
    if self.isbet_ then
        return
    end

    local betchip = self.operManager:getBetChip()
    self.ctx.diceController:requestBet(type,betchip,x,y)
end

function BetTypeManager:setRate(rates)
    for k,v in pairs(rates) do
        self.ratelabel_[v.cardType]:setString("x"..tostring(v.typeRate / 100))
    end
end

function BetTypeManager:updateMyChips(type,chips)
    assert(type > 0 and type < 9,"bet type error")
    self.mychips_[type] = self.mychips_[type] + chips
    self.mychipslabel_[type]:setString(bm.formatBigNumber(self.mychips_[type]))
    self:updateAllChips(type,chips)
end

function BetTypeManager:updateAllChips(type,chips)
    assert(type > 0 and type < 9,"bet type error")
    self.allchips_[type] = self.allchips_[type] + chips
    self.allchipslabel_[type]:setString(bm.formatBigNumber(self.allchips_[type]))
end

function BetTypeManager:updateMyBet(data)
    for i,v in pairs(data) do
        self.mychips_[v.type] = v.betChip
        self.mychipslabel_[v.type]:setString(bm.formatBigNumber(self.mychips_[v.type]))
    end
end

function BetTypeManager:updateAllBet(data)
    for i,v in pairs(data) do
        self.allchips_[v.type] = v.betChip
        self.allchipslabel_[v.type]:setString(bm.formatBigNumber(self.allchips_[v.type]))
    end
end

function BetTypeManager:clearChips()
    for i = 1,8 do
        self.allchips_[i] = 0
        self.mychips_[i] = 0
        self.allchipslabel_[i]:setString("")
        self.mychipslabel_[i]:setString("")
    end
end

function BetTypeManager:setHistory(history)
    local spriteStr = "#dice_win_history_gold.png"
    local count = 1
    for i,v in pairs(history) do
        if v.res == 1 then
            spriteStr = "#dice_win_history_silver.png"
        else
            spriteStr = "#dice_win_history_gold.png"
        end
        self.historySprite_[count] = display.newSprite(spriteStr)
        self.historySprite_[count]:pos(display.cx + (10.5 - count) * 15,display.cy - 218)
            :addTo(self.bettypenode_)
        count = count + 1
    end
    self:setTypeHistory(history)
end

function BetTypeManager:setTypeHistory(history)
    local spriteStr
    local count = 1
    for i,v in pairs(history) do
        for k,wintype in pairs(v.wintypes) do
            if wintype > 0 and wintype < 7 then
                spriteStr = "#dice_win_type_" .. wintype .. ".png"
                self.historyTypeSprite_[count] = display.newSprite(spriteStr)
                self.historyTypeSprite_[count]:pos(display.cx + (4 - count) * 78,display.cy - 190)
                    :addTo(self.bettypenode_)
                count = count + 1
                break
            end
        end
        if count > 6 then
            break
        end
    end
end

function BetTypeManager:updateHistory(newres,wintypes)
    local count = #self.historySprite_
    for i = count,1,-1 do
        if i > 19 then
            self.historySprite_[i]:removeFromParent()
        else
            self.historySprite_[i + 1] = self.historySprite_[i]
            self.historySprite_[i + 1]:runAction(cc.MoveTo:create(0.3,cc.p(display.cx + (9.5 - i) * 15,display.cy -218)))
        end
    end
    local spriteStr = "#dice_win_history_gold.png"
    local pos = P.BetTypePosition[7]
    if newres == 1 then
        spriteStr = "#dice_win_history_silver.png"
        pos = P.BetTypePosition[7]
    else
        spriteStr = "#dice_win_history_gold.png"
        pos = P.BetTypePosition[8]
    end
    self.historySprite_[1] = display.newSprite(spriteStr):pos(pos.x,pos.y)
        :addTo(self.bettypenode_)
    self.historySprite_[1]:runAction(cc.MoveTo:create(0.8,cc.p(display.cx + 9.5 * 15,display.cy -218)))

    self:updateTypeHistory(wintypes)
end

function BetTypeManager:updateTypeHistory(wintypes)
    local wintype = 0
    for i,v in pairs(wintypes) do
        if v.type > 0 and v.type < 7 then
            wintype = v.type
            break
        end
    end
    if wintype == 0 then
        return
    end
    local count = #self.historyTypeSprite_
    for i = count,1,-1 do
        if i > 6 then
            self.historyTypeSprite_[i]:removeFromParent()
        else
            self.historyTypeSprite_[i + 1] = self.historyTypeSprite_[i]
            self.historyTypeSprite_[i + 1]:runAction(cc.MoveTo:create(0.3,cc.p(display.cx + (3 - i) * 78,display.cy -190)))
        end
    end
    self.historyTypeSprite_[1] = display.newSprite("#dice_win_type_" .. wintype .. ".png")
    self.historyTypeSprite_[1]:pos(display.cx + 238,display.cy - 190)
                    :addTo(self.bettypenode_)
    self.historyTypeSprite_[1]:hide()
    self.historyTypeSprite_[1]:runAction(transition.sequence({cc.DelayTime:create(0.3),cc.Show:create()}))
end

function BetTypeManager:reset()
    self:clearChips()
end

return BetTypeManager