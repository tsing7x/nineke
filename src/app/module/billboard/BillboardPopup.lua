-- 系统公告版弹窗
-- Author: David Feng
-- Date: 2015-07-21 Tuesday 10:10:10
--
local RichLabel = import("boomegg.ui.RichLabel")
local BillboardPopup = class('BillboardPopup', nk.ui.Panel)

local BillboardController = import('.BillboardController')

local HEADER_HEIGHT = 80
local PANEL_WIDTH, PANEL_HEIGHT = 720, 480
-- 滚动区域的大小
local CW, CH                  = 700, 380
local TITLE_FONT_SIZE         = 32
local CONTENT_FONT_SIZE       = 24
local MARGIN_LEFT, MARGIN_TOP = 30, 30
local TEXT_AREA_W             = CW - MARGIN_LEFT * 2
local OFFPY = 35;

function BillboardPopup:ctor(notice)
    BillboardPopup.super.ctor(self, {PANEL_WIDTH, PANEL_HEIGHT})

    self:setCommonStyle(bm.LangUtil.getText("COMMON", "SYSTEM_BILLBOARD"))

    local scrollContent = display.newNode()
    local txt = notice.content or ''

    -- 可变高度的公告内容区域
    -- local params = {
    --     text=txt,
    --     fontColor=display.COLOR_WHITE,
    --     fontSize=CONTENT_FONT_SIZE,
    --     dimensions=cc.size(TEXT_AREA_W, 0)
    -- }

    -- self.billboardText_ = RichLabel:create(params)
    --     :addTo(scrollContent)

    self.billboardText_ = ui.newTTFLabel({
            text = txt,
            size = CONTENT_FONT_SIZE,
            dimensions = cc.size(TEXT_AREA_W, 0),
            color = display.COLOR_WHITE,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
        })
        :align(display.TOP_LEFT)
        :addTo(scrollContent)
    -- -- 
    local billboardTextSize = self.billboardText_:getContentSize()
    local sc_total_height = billboardTextSize.height
    -- 检查是否有 链接可以创建 
    local ok, link_desc, link_addr = self:checkCreateLink_(notice)
    if ok then
        -- 链接描述     粉丝页链接:
        self.linkDesc_ = ui.newTTFLabel({
                text  = link_desc,
                size  = CONTENT_FONT_SIZE,
                color = display.COLOR_WHITE,
                align = ui.TEXT_ALIGN_LEFT,
            })
            :align(display.TOP_LEFT)
            :addTo(scrollContent)
        local link_desc_size = self.linkDesc_:getContentSize()
        sc_total_height = sc_total_height + link_desc_size.height + 30

        if sc_total_height <= CH then
            sc_total_height = CH
        end
        scrollContent:setContentSize(CW, sc_total_height)

        local btx = -CW * 0.5 + MARGIN_LEFT
        local bty = sc_total_height * 0.5 - MARGIN_TOP
        self.billboardText_:pos(btx, bty)

        local link_y = bty - billboardTextSize.height - 10
        self.linkDesc_:pos(btx, link_y)

        -- link text    http://www.oa.com
        local la_x = btx + link_desc_size.width
        self.linkAddr_ = link_addr
        self.linkLabel_ = ui.newTTFLabel({
                text  = link_addr,
                size  = CONTENT_FONT_SIZE,
                color = cc.c3b(46, 144, 255), -- 取自iTerm的黑背景之上的蓝
                align = ui.TEXT_ALIGN_LEFT,
            })
            :align(display.TOP_LEFT)
            :pos(la_x, link_y)
            :addTo(scrollContent)

        local link_size = self.linkLabel_:getContentSize()
        -- 可点击的透明按钮
        self.linkClickBtn_ = cc.ui.UIPushButton.new({
                normal = "#common_transparent_skin.png",
                pressed = "#setting_content_up_pressed.png"},
                {scale9 = true})
            :setButtonSize(link_size.width, link_size.height)
            :onButtonClicked(buttontHandler(self, self.onLinkClick_))
            :align(display.TOP_LEFT)
            :pos(la_x, link_y)
            :addTo(scrollContent)
        self.linkClickBtn_:setTouchSwallowEnabled(false)
    else
        if sc_total_height < CH then
            sc_total_height = CH
        end
        scrollContent:setContentSize(CW, sc_total_height)

        local btx = -CW * 0.5 + MARGIN_LEFT
        local bty = sc_total_height * 0.5 - MARGIN_TOP
        self.billboardText_:pos(btx, bty)
    end
    
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

-- pop manager的回调
function BillboardPopup:onShowed()
    if self.scrollView_ then
        self.scrollView_:setScrollContentTouchRect()
    end
end

function BillboardPopup:checkCreateLink_(notice)
    local x, y = notice.linkDesc, notice.link
    if type(x) == 'string' and type(y) == 'string' then
        return true, x, y
    else
        return false
    end
end

function BillboardPopup:onLinkClick_()
    device.openURL(self.linkAddr_)
end

return BillboardPopup
