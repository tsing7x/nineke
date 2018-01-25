--
-- Author: Jonah0608@gmail.com
-- Date: 2016-11-04 12:13:44
--

local RichManHelpPopup = class("RichManHelpPopup",function()
    return display.newNode()
end)

local POP_WIDTH = 686
local POP_HEIGHT = 454

function RichManHelpPopup:ctor(tag)
    self.tag_ = tag
    self:setupView()
end

function RichManHelpPopup:setupView()
    self.background_ = display.newScale9Sprite("#richman_detail_bg".. self.tag_ ..".png", 0, 0, cc.size(POP_WIDTH, POP_HEIGHT),cc.rect(23,23,1,1)):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    self.closeBtnBg_ = display.newSprite("#richman_detail_close_bg".. self.tag_ ..".png")
        :pos(320,208)
        :addTo(self)
    cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9 = true})
        :onButtonClicked(handler(self,self.onCloseBtnListener_))
        :setButtonSize(46,36)
        :pos(23,17)
        :addTo(self.closeBtnBg_)
    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#richman_button_close_normal".. self.tag_ ..".png", pressed = "#richman_button_close_pressed".. self.tag_ ..".png"})
        :onButtonClicked(handler(self,self.onCloseBtnListener_))
        :pos(23,17)
        :addTo(self.closeBtnBg_)

    self.title_ = display.newScale9Sprite("#richman_detail_title".. self.tag_ ..".png",0,0,cc.size(436,27),cc.rect(98,17,1,1))
        :pos(0,150)
        :addTo(self)

    self.titlelabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("RICHMAN", "RULE_TITLE"), color = cc.c3b(0xff, 0xff, 0xff), size = 28, align = ui.TEXT_ALIGN_CENTER})
        :pos(220,24)
        :addTo(self.title_)

    local scrollContent = display.newNode()
    local rule = nk.userDefault:getStringForKey("RICH_RULE" .. self.tag_,"")
    self.rulelabel_ = ui.newTTFLabel({text = rule, color = cc.c3b(0xff, 0xff, 0xff), size = 28, dimensions=cc.size(510, 0),align = ui.TEXT_ALIGN_LEFT})
        :pos(0,0)
        :addTo(scrollContent)

    local CW = 640
    local CH = 300
    
    local scrollViewRect = cc.rect(-CW * 0.5, -CH * 0.5, CW, CH)
    self.scrollView_ = bm.ui.ScrollView.new({
            viewRect      = scrollViewRect,
            scrollContent = scrollContent,
            direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
        })
        :pos(0, -30)
        :hideScrollBar()
        :addTo(self)
end

function RichManHelpPopup:onCloseBtnListener_()
    self:hide()
end

function RichManHelpPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function RichManHelpPopup:onShowed()
    if self.scrollView_ then
        self.scrollView_:setScrollContentTouchRect()
    end
end

function RichManHelpPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return RichManHelpPopup