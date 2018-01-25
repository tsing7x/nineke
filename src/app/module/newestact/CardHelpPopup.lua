--
-- Author: Jonah0608@gmail.com
-- Date: 2016-12-02 16:24:07
--
local CardHelpPopup = class("CardHelpPopup", nk.ui.Panel)
local POPUP_WIDTH = 720
local POPUP_HEIGHT = 500

function CardHelpPopup:ctor(isNew)
    CardHelpPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})
    self.isNew_ = isNew
    self:setupView()
    self:addCloseBtn()
end

function CardHelpPopup:setupView()
    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(POPUP_WIDTH - 30, POPUP_HEIGHT - 80))
        :pos(0,-27)
        :addTo(self)

    self.scrollContent = display.newNode()
    local CW = 650
    local CH = 380

    self.title = display.newSprite("#card_activity_recall_desc.png")
        :pos(0,210)
        :addTo(self)

    local scrollViewRect = cc.rect(-CW * 0.5, -CH * 0.5, CW, CH)
    self.scrollView_ = bm.ui.ScrollView.new({
            viewRect      = scrollViewRect,
            scrollContent = self.scrollContent,
            direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
        })
        :pos(0, -30)
        :hideScrollBar()
        :addTo(self)
end

function CardHelpPopup:onCloseBtnListener_()
    self:hide()
end

function CardHelpPopup:setData(data)
    local labelY_ = 0
    local gap = 5
    local strTable = {
            {str = data.title,color = cc.c3b(0x96, 0xa4, 0xd8)},
            {str = bm.LangUtil.getText("CARD_ACT","ACT_TIME",data.openDate),color = cc.c3b(0x96, 0xa4, 0xd8)},
            {str = bm.LangUtil.getText("CARD_ACT","RULE"),color = cc.c3b(0x96, 0xa4, 0xd8)},
            {str = data.rule,color = cc.c3b(0x7a, 0x7e, 0xca)},
            {str = bm.LangUtil.getText("CARD_ACT","NOTICE"),color = cc.c3b(0x96, 0xa4, 0xd8)},
            {str = data.notice,color = cc.c3b(0x7a, 0x7e, 0xca)}
        }
    local labels = {}
    for i,v in pairs(strTable) do
        local label = ui.newTTFLabel({text = v.str, color =v.color, size = 22,dimensions=cc.size(640, 0), align = ui.TEXT_ALIGN_LEFT})
            :align(display.CENTER_LEFT)
            :addTo(self.scrollContent)
        local size = label:getContentSize()
        label:pos(-320, labelY_- size.height / 2)
        labelY_ = labelY_ - size.height - gap
        table.insert(labels,label)
    end

    self.scrollContent:setContentSize(650,-labelY_)

    for i,v in pairs(labels) do
        local posY = v:getPositionY()
        v:pos(-320,posY + ( -labelY_) / 2)
    end

    if self.scrollView_ then
        self.scrollView_:setScrollContent(self.scrollContent)
        self.scrollView_:setScrollContentTouchRect()
    end
end

function CardHelpPopup:getRule()
    bm.HttpService.POST(
            { 
                act = "actDetail",
                mod = "Invite",
            },function(data)
                local jsnData = json.decode(data)
                if jsnData and jsnData.ret == 0 then
                    self:setData(jsnData)
                end
            end,function()
            end)
end

function CardHelpPopup:getRule1()
    bm.HttpService.POST(
            { 
                act = "actRpDetail",
                mod = "Invite",
            },function(data)
                local jsnData = json.decode(data)
                if jsnData and jsnData.ret == 0 then
                    self:setData(jsnData)
                end
            end,function()
            end)
end

function CardHelpPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function CardHelpPopup:onShowed()
    if self.isNew_ then
        self:getRule1()
    else
        self:getRule()
    end
end

function CardHelpPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return CardHelpPopup