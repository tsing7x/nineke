--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-01-28 13:21:24
--
local RichLabel = import(".RichLabel")
local ScrollView = import(".ScrollView")
--[[
local txt="[fontColor=f75d85 fontSize=30]เชื่อมต่ออินเตอร์เน็ตขัดข้อง กรุณาตรวจเช็คเน็ตของท่านก่อนค่ะ[/fontColor][fontColor=fefefe]这是测试代码[/fontColor][fontColor=ff7f00 fontName=ArialRoundedMTBold]看看效果如何[/fontColor][fontColor=3232cd]碉堡了吧!!![/fontColor][fontColor=42426f]哈哈哈哈哈哈!![/fontColor]"
local ScrollRichLabel = import("boomegg.ui.ScrollRichLabel")
local params1 = {
    text=txt..txt..txt..txt..txt..txt..txt..txt,
    fontColor=display.COLOR_WHITE,
    fontSize=CONTENT_FONT_SIZE,
    dimensions=cc.size(TEXT_AREA_W, 0)
}
local rect = cc.rect(-CW * 0.5, -CH * 0.5, CW, CH)
local scrollRich = ScrollRichLabel.new(params1, rect)
    :pos(0, -30)
    :addTo(self)
]]
local ScrollRichLabel = class("ScrollRichLabel", function()
	return display.newNode();
end)

function ScrollRichLabel:ctor(params, viewRect)
	self.params_ = params;
	self.dimensions_ = params.dimensions;
	self.viewRect_ = viewRect;
    --  
    self.scrollContent_ = display.newNode()
    self.scrollContent_:setAnchorPoint(cc.p(0.5, -0.5))
	self.richlabel_ = RichLabel:create(self.params_)
        :addTo(self.scrollContent_)
    local labelSize = self.richlabel_:getLabelSize();
    local dw, dh = labelSize.width, labelSize.height;
    if dh < self.viewRect_.height then
    	dh = self.viewRect_.height;
    end
    self.scrollContent_:setContentSize(dw, dh);
    -- 
    self.scrollView_ = bm.ui.ScrollView.new({
            viewRect      = self.viewRect_,
            scrollContent = self.scrollContent_,
            direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
        })
    	:hideScrollBar()
        :addTo(self)
end

function ScrollRichLabel:setString(text)
	self.richlabel_:setLabelString(text);
	-- self:update();
end

function ScrollRichLabel:update()
	
end

function ScrollRichLabel:getScrollContent()
	return self.scrollContent_;
end

return ScrollRichLabel;