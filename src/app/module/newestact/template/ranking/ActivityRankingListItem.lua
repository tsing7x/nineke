--
-- Author: KevinYu
-- Date: 2017-4-21 11:51:29
--
local ActivityRankingListItem = class("ActivityRankingListItem",function()
    return display.newNode()
end)

function ActivityRankingListItem:ctor(tag)
    self.tag_ = tag

    self:addContent_()
end

function ActivityRankingListItem:addContent_()
    self.bg_ = {}
    for i = 1, 5 do
        self.bg_[i] = display.newNode()
            :size(150, 39)
            :align(display.CENTER, (i - 3) * 152, 0)
            :addTo(self)
    end

    local py = 20
    ui.newTTFLabel({text = bm.LangUtil.getText("RICHMAN", "RANKTAG"), color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(50, py)
        :addTo(self.bg_[1])

    self.rankSprite_ = {}

    for i = 1, 3 do
        self.rankSprite_[i] = display.newSprite("#rich_rank_0".. self.tag_ ..".png")
            :pos(73 + i * 18, py)
            :addTo(self.bg_[1])
            :hide()
    end

    display.newSprite("#richman_coin".. self.tag_ ..".png")
        :pos(20, py)
        :addTo(self.bg_[2])

    self.money_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(90, py)
        :addTo(self.bg_[2])

    self.nick_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(75, py)
        :addTo(self.bg_[3])

    self.score_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(75, py)
        :addTo(self.bg_[4])

    self.changeScore_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(75, py)
        :addTo(self.bg_[5])
end

function ActivityRankingListItem:setData(data)
    self:updateRankSprite(data.rank)
    self.money_:setString(data.reward)
    self.nick_:setString(nk.Native:getFixedWidthText("", 24, data.nick or "nil", 120))
    self.score_:setString(data.score)
    self.changeScore_:setString(data.yesterday)
end

function ActivityRankingListItem:updateRankSprite(rank)
    if rank <= 0 then
        return
    end

    local low = math.mod(rank,10)
    local mid = math.floor(math.mod(rank,100)/10)
    local high = math.floor(math.mod(rank,1000)/100)
    if low > 0 or mid > 0 or high > 0 then
        self.rankSprite_[3]:setSpriteFrame(display.newSpriteFrame("rich_rank_".. low .. self.tag_ .. ".png"))
        self.rankSprite_[3]:show()
    else
        self.rankSprite_[3]:hide()
    end

    if mid > 0 or high > 0 then
        self.rankSprite_[2]:setSpriteFrame(display.newSpriteFrame("rich_rank_".. mid .. self.tag_ .. ".png"))
        self.rankSprite_[2]:show()
    else
        self.rankSprite_[2]:hide()
    end

    if high > 0 then
        self.rankSprite_[1]:setSpriteFrame(display.newSpriteFrame("rich_rank_".. high .. self.tag_ .. ".png"))
        self.rankSprite_[1]:show()
    else
        self.rankSprite_[1]:hide()
    end
end

return ActivityRankingListItem