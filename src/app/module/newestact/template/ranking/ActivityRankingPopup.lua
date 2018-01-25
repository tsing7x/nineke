--
-- Author: KevinYu
-- Date: 2017-4-21 11:51:29
--
local ActivityRankingListItem = import(".ActivityRankingListItem")
local ActivityRankingPopup = class("ActivityRankingPopup",function()
    return display.newNode()
end)

local POP_WIDTH = 900
local POP_HEIGHT = 503

function ActivityRankingPopup:ctor(flag, sb)
    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    
    self:init_(flag, sb)

    self:addMainUI_()
end

function ActivityRankingPopup:init_(flag, sb)
    self.time_ = 0
    self.day_ = 0
    self.hour_ = 0
    self.min_ = 0
    self.page_ = 1
    self.flag_ = flag
    self.sb_ = sb
    self.tag_ = ""
    self.tagid_ = 1--yk
    if self.flag_ == 5 then
        self.tag_ = "_gold"
    else
        if self.sb_ < 3000 then
            self.tag_ = "_blue"
        elseif self.sb_ >= 3000 and self.sb_ < 99000 then
            self.tag_ = "_red"
            self.tagid_ = 2
        else
            self.tag_ = ""
            self.tagid_ = 3
        end
    end
end

function ActivityRankingPopup:addMainUI_()
    self.bg_ = display.newSprite("richman/richman_bg.png"):addTo(self)
    local size = self.bg_:getContentSize()

    cc.ui.UIPushButton.new({normal = "richman/richman_close_normal.png", pressed = "richman/richman_close_pressed.png"})
        :onButtonClicked(handler(self,self.onCloseClicked_))
        :pos(size.width - 15, size.height - 15)
        :addTo(self.bg_)

    self:addContentNode_(size.width/2, size.height/2 + 22)

    local gotoBtn = cc.ui.UIPushButton.new("richman/richman_goto_btn.png")
        :onButtonClicked(handler(self,self.onGotoClicked_))
        :pos(size.width/2, 42)
        :addTo(self.bg_)

    display.newSprite("richman/richman_goto_btn_title.png")
        :pos(0, 5)
        :addTo(gotoBtn)
end

function ActivityRankingPopup:addContentNode_(x, y)
    local w, h = 832, 448
    local btn_w, btn_h = 146, 40
    local frame = display.newSprite("richman/richman_frame_" .. self.tagid_ ..".png")
        :pos(x, y)
        :addTo(self.bg_)

    display.newSprite("richman/richman_small_frame.png")
        :pos(x, y)
        :addTo(self.bg_)

    self.timeSprite_ = {}
    local sx = 81
    local px, py = {0, 19, 42, 61, 84, 103}, h - 80
    for i = 1, 6 do
        self.timeSprite_[i] = display.newSprite("#rich_time_0".. self.tag_ ..".png")
            :pos(sx + px[i], py)
            :addTo(frame)
    end

    --pop_loginreward_content_bg transparent
    cc.ui.UIPushButton.new("#transparent.png", {scale9 = true})
        :onButtonClicked(handler(self,self.onMoreClicked_))
        :setButtonSize(btn_w, btn_h)
        :pos(w - 87, h - 26)
        :addTo(frame)
    
    self.descTxt_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(w/2, h - 125)
        :addTo(frame)

    self.richitem_ = {}
    for i = 1, 4 do
        self.richitem_[i] = ActivityRankingListItem.new(self.tag_)
            :pos(w/2, 230 - (i - 1) * 41)
            :addTo(frame)
    end

    self.myscore_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 18})
        :align(display.CENTER_LEFT, 57, 35)
        :addTo(frame)

    local x, y = 571, 40
    cc.ui.UIPushButton.new("#transparent.png", {scale9 = true})
        :onButtonClicked(handler(self,self.onPrePage_))
        :setButtonSize(btn_w, btn_h)
        :pos(x, y)
        :addTo(frame)

    cc.ui.UIPushButton.new("#transparent.png", {scale9 = true})
        :onButtonClicked(handler(self,self.onNextPage_))
        :setButtonSize(btn_w, btn_h)
        :pos(x + btn_w + 6, y)
        :addTo(frame)
end

function ActivityRankingPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self, 999)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function ActivityRankingPopup:onNextPage_()
    print("ActivityRankingPopup:onNextPage_()")
    if self.page_ >= 25 then
        return
    end

    self:getPageData(self.page_ + 1)
end

function ActivityRankingPopup:onPrePage_()
    print("ActivityRankingPopup:onPrePage_()")
    if self.page_ <= 1 then
        return
    end

    self:getPageData(self.page_ - 1)
end

function ActivityRankingPopup:onMoreClicked_()
    print("ActivityRankingPopup:onMoreClicked_()")
end

function ActivityRankingPopup:onGotoClicked_()
    print("ActivityRankingPopup:onGotoClicked_()")
end

function ActivityRankingPopup:onCloseClicked_()
    self:hide()
end

function ActivityRankingPopup:getPageData(page)
    self.page_ = page
    local richVersion = nk.userDefault:getStringForKey("RICH_VERSION" .. self.tag_, "")
    self:setLoading(true)
    bm.HttpService.POST(
        { mod = "Activity",
          act = "billions",
          p = page,
          limit = 4,
          flag = self.flag_,
          sb = self.sb_,
          rulever = richVersion
        },
        function(data)
            self:setLoading(false)
            local retData = json.decode(data)
            dump(retData, "retData")
            if retData and retData.ret == 0 then
                if richVersion == retData.rulever then
                else
                    nk.userDefault:setStringForKey("RICH_VERSION".. self.tag_,retData.rulever)
                    nk.userDefault:setStringForKey("RICH_RULE".. self.tag_,retData.rule)
                end
                self:updateMyScore(retData.info.score or 0,retData.info.rank or 0)
                self:updateLeftTime(retData.timeLeft)
                self.descTxt_:setString(retData.desc)
                self:updateInfo(retData.list)
            end
        end,
        function()
            self:setLoading(false)
        end)
end

function ActivityRankingPopup:updateMyScore(score,rank)
    local rankstr = bm.LangUtil.getText("RICHMAN", "NOT_IN_RANK")
    if rank < 100 and rank > 0 then
        rankstr = bm.LangUtil.getText("RICHMAN", "RANK") .. rank
    end

    local scorestr = bm.LangUtil.getText("RICHMAN", "MY_SCORE") .. score .. ","
    self.myscore_:setString(scorestr .. rankstr)
end

function ActivityRankingPopup:updateLeftTime(time)
    if time < 0 then
        time = 0
    end

    if self.time_ - time < 60 and self.time_ > 0 then
        return
    else
        self.time_ = time
    end

    local day = math.floor(self.time_ / (3600 * 24))
    if self.day_ ~= day then
        self.day_ = day
        self:updateTimeSprite(self.day_, 1)
    end

    local hour = math.floor(math.mod(self.time_, 3600 * 24) / 3600)
    if self.hour_ ~= hour then
        self.hour_ = hour
        self:updateTimeSprite(self.hour_, 3)
    end

    local min = math.floor(math.mod(self.time_, 3600) / 60)
    if self.min_ ~= min then
        self.min_ = min
        self:updateTimeSprite(self.min_, 5)
    end
end

function ActivityRankingPopup:updateTimeSprite(time,position)
    local high = math.floor(math.mod(time,100)/10)
    local low = math.mod(time,10)
    self.timeSprite_[position]:setSpriteFrame(display.newSpriteFrame("rich_time_" .. high .. self.tag_ ..".png"))
    self.timeSprite_[position + 1]:setSpriteFrame(display.newSpriteFrame("rich_time_" .. low .. self.tag_ .. ".png"))
end

function ActivityRankingPopup:updateInfo(data)
    for i = 1,4 do
        if data[i] then
            self.richitem_[i]:show()
            self.richitem_[i]:setData(data[i])
        else
            self.richitem_[i]:hide()
        end 
    end
end

function ActivityRankingPopup:onShowed()
    self:getPageData(1)
end

function ActivityRankingPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function ActivityRankingPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return ActivityRankingPopup