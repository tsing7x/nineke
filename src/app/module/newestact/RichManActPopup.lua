--
-- Author: Jonah0608@gmail.com
-- Date: 2016-11-01 11:47:10
--
local RichManActListItem = import(".RichManActListItem")
local RichManHelpPopup = import(".RichManHelpPopup")
local RichManActPopup = class("RichManActPopup",function()
    return display.newNode()
end)

local POP_WIDTH = 900
local POP_HEIGHT = 503

function RichManActPopup:ctor(flag,sb)
    self:setNodeEventEnabled(true)
    self.time_ = 0
    self.day_ = 0
    self.hour_ = 0
    self.min_ = 0
    self.page_ = 1
    self.timeinit_ = false
    self.flag_ = flag
    self.sb_ = sb
    self.tag_ = ""
    if self.flag_ == 5 then
        self.tag_ = "_gold"
    else
        if self.sb_ < 3000 then
            self.tag_ = "_blue"
        elseif self.sb_ >= 3000 and self.sb_ < 99000 then
            self.tag_ = "_red"
        else
            self.tag_ = ""
        end
    end
    self:setupView()
end

function RichManActPopup:setupView()
    self.background_ = display.newScale9Sprite("#richman_popup_bg".. self.tag_ ..".png", 0, 0, cc.size(POP_WIDTH, POP_HEIGHT),cc.rect(14,14,14,400)):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    self.leftCoin_ = display.newSprite("#richman_left_bg".. self.tag_ ..".png")
        :pos(-347,160)
        :addTo(self)
    self.rightCoin_ = display.newSprite("#richman_right_bg".. self.tag_ ..".png")
        :pos(349,155)
        :addTo(self)
    self.title_ = display.newSprite("#richman_title".. self.tag_ ..".png")
        :pos(0,192)
        :addTo(self)


    ui.newTTFLabel({text = bm.LangUtil.getText("RICHMAN", "COUNTDOWN"), color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-420,230)
        :addTo(self)
    self.countDownBg_ = display.newSprite("#richman_countdown_bg".. self.tag_ ..".png")
        :pos(-350,190)
        :addTo(self)

    self.timeSprite_ = {}
    self.timeSprite_[1] = display.newSprite("#rich_time_0".. self.tag_ ..".png"):addTo(self.countDownBg_)
        :pos(15,22)
    self.timeSprite_[2] = display.newSprite("#rich_time_0".. self.tag_ ..".png"):addTo(self.countDownBg_)
        :pos(34,22)
    self.timeSprite_[3] = display.newSprite("#rich_time_0".. self.tag_ ..".png"):addTo(self.countDownBg_)
        :pos(58,22)
    self.timeSprite_[4] = display.newSprite("#rich_time_0".. self.tag_ ..".png"):addTo(self.countDownBg_)
        :pos(75 ,22)
    self.timeSprite_[5] = display.newSprite("#rich_time_0".. self.tag_ ..".png"):addTo(self.countDownBg_)
        :pos(99,22)
    self.timeSprite_[6] = display.newSprite("#rich_time_0".. self.tag_ ..".png"):addTo(self.countDownBg_)
        :pos(118,22)

    self.closeBtnBg_ = display.newScale9Sprite("#richman_button_close_bg".. self.tag_ ..".png", 0, 0, cc.size(106, 38),cc.rect(45,20,1,1))
        :pos(397,232)
        :addTo(self)
    self.closeSplit_ = display.newSprite("#richman_button_close_split".. self.tag_ ..".png")
        :pos(60,17)
        :addTo(self.closeBtnBg_)
        
    cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9 = true})
        :onButtonClicked(handler(self,self.onCloseBtnListener_))
        :setButtonSize(46,36)
        :pos(85,17)
        :addTo(self.closeBtnBg_)
    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#richman_button_close_normal".. self.tag_ ..".png", pressed = "#richman_button_close_pressed".. self.tag_ ..".png"})
        :onButtonClicked(handler(self,self.onCloseBtnListener_))
        :pos(85,17)
        :addTo(self.closeBtnBg_)

    cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9 = true})
        :onButtonClicked(handler(self,self.onQuestionBtnListener_))
        :setButtonSize(46,36)
        :pos(40,19)
        :addTo(self.closeBtnBg_)
    self.questionBtn_ = cc.ui.UIPushButton.new({normal = "#richman_button_question_normal".. self.tag_ ..".png", pressed = "#richman_button_question_pressed".. self.tag_ ..".png"})
        :onButtonClicked(handler(self,self.onQuestionBtnListener_))
        :pos(40,19)
        :addTo(self.closeBtnBg_)
    
    self.descTxt_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(0,132)
        :addTo(self)

    local titleTable = bm.LangUtil.getText("RICHMAN", "TITLETABLE")

    self.listtitle_ = {}
    for i = 1,5 do
        display.newSprite("#richman_list_title_bg".. self.tag_ ..".png")
            :pos((i - 3) * 160,75)
            :addTo(self)
        self.listtitle_[i] =  ui.newTTFLabel({text = titleTable[i], color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_CENTER})
            :pos((i - 3) * 160,75)
            :addTo(self)
    end
    self.richitem_ = {}
    for i = 1,4 do
        self.richitem_[i] = RichManActListItem.new(self.tag_):addTo(self):pos(0,(2 - i) * 47 - 30)
    end

    self.tagbg_ = display.newScale9Sprite("#richman_tag_bg".. self.tag_ ..".png", 0, 0, cc.size(410, 33),cc.rect(2,2,1,1)):addTo(self)
        :pos(-190,-169)

    self.myscore_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(10,16)
        :addTo(self.tagbg_)

    cc.ui.UIPushButton.new({normal = "#richman_button_normal".. self.tag_ ..".png", pressed = "#richman_button_pressed".. self.tag_ ..".png"})
        :onButtonClicked(handler(self,self.onSubPage_))
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("RICHMAN", "PRE_PAGE"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :pos(170,-211)
        :addTo(self)

    cc.ui.UIPushButton.new({normal = "#richman_button_normal".. self.tag_ ..".png", pressed = "#richman_button_pressed".. self.tag_ ..".png"})
        :onButtonClicked(handler(self,self.onAddPage_))
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("RICHMAN", "NEXT_PAGE"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :pos(350,-211)
        :addTo(self)
end

function RichManActPopup:setLoading(isLoading)
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

function RichManActPopup:onAddPage_()
    if self.page_ >= 25 then
        return
    end
    self:getPageData(self.page_ + 1)
end

function RichManActPopup:onSubPage_()
    if self.page_ <= 1 then
        return
    end
    self:getPageData(self.page_ - 1)
end

function RichManActPopup:onQuestionBtnListener_()
    RichManHelpPopup.new(self.tag_):show()
end

function RichManActPopup:onCloseBtnListener_()
    self:hide()
end

function RichManActPopup:getPageData(page)
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
        },function(data)
            self:setLoading(false)
            local retData = json.decode(data)
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
        end,function()
            self:setLoading(false)
        end)
end

function RichManActPopup:updateMyScore(score,rank)
    local rankstr = bm.LangUtil.getText("RICHMAN", "NOT_IN_RANK")
    if rank < 100 and rank > 0 then
        rankstr = bm.LangUtil.getText("RICHMAN", "RANK") .. rank
    end
    local scorestr = bm.LangUtil.getText("RICHMAN", "MY_SCORE") .. score .. ","
    self.myscore_:setString(scorestr .. rankstr)
end

function RichManActPopup:updateLeftTime(time)
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
        self:updateTimeSprite(self.day_,1)
    end
    local hour = math.floor(math.mod(self.time_,3600 * 24) / 3600)
    if self.hour_ ~= hour then
        self.hour_ = hour
        self:updateTimeSprite(self.hour_,3)
    end
    local min = math.floor(math.mod(self.time_ ,3600) / 60)
    if self.min_ ~= min then
        self.min_ = min
        self:updateTimeSprite(self.min_,5)
    end
end

function RichManActPopup:updateTimeSprite(time,position)
    local high = math.floor(math.mod(time,100)/10)
    local low = math.mod(time,10)
    self.timeSprite_[position]:setSpriteFrame(display.newSpriteFrame("rich_time_" .. high .. self.tag_ ..".png"))
    self.timeSprite_[position + 1]:setSpriteFrame(display.newSpriteFrame("rich_time_" .. low .. self.tag_ .. ".png"))
end

function RichManActPopup:updateInfo(data)
    for i = 1,4 do
        if data[i] then
            self.richitem_[i]:show()
            self.richitem_[i]:setData(data[i])
        else
            self.richitem_[i]:hide()
        end 
    end
end

function RichManActPopup:onShowed()
    self:getPageData(1)
end

function RichManActPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function RichManActPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return RichManActPopup