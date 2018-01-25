--
-- Author: XT
-- Date: 2015-09-28 16:42:57
--
local ScoreLineCoinsPopupExt = class("ScoreLineCoinsPopupExt", nk.ui.Panel)

ScoreLineCoinsPopupExt.WIDTH = 720
ScoreLineCoinsPopupExt.HEIGHT = 360

local TOP_HEIGHT = 64 - 20
local CONTENT_WIDTH = 455
local CONTENT_HEIGHT = 165
local topTitleSize = 30
local topTitleColor = cc.c3b(0x64, 0x9a, 0xc9)
local contentSize = 22
local contentColor = cc.c3b(0xca, 0xca, 0xca)
local serviceSize = 14
local serviceColor = cc.c3b(0x64, 0x9a, 0xc9)
local PADDING = 40;

function ScoreLineCoinsPopupExt:ctor(titleMsg, dataList, isUrl)
	local width, height = ScoreLineCoinsPopupExt.WIDTH, ScoreLineCoinsPopupExt.HEIGHT;
    ScoreLineCoinsPopupExt.super.ctor(self, {width+30, height+30})
    self:addBgLight()
	self.mainContainer_ = display.newNode():addTo(self);
	self.mainContainer_:setContentSize(width, height);
	self.mainContainer_:setTouchEnabled(true);
	self.mainContainer_:setTouchSwallowEnabled(true);
	
	display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(width - PADDING * 0.5, height - PADDING * 0.25 - TOP_HEIGHT - PADDING))
        :pos(0, -30)
        :addTo(self)
	--顶部文字
    local titleMarginTop = 20
    local titleLabel = ui.newTTFLabel({
            text = titleMsg,
            size = topTitleSize,
            color = topTitleColor,
            align = ui.TEXT_ALIGN_CENTER
        }):pos(0, height/2 - TOP_HEIGHT + TOP_HEIGHT/2 - titleMarginTop):addTo(self)
    -- 
    self.content_ = display.newNode():addTo(self.mainContainer_);
    self.content_:setContentSize(width-PADDING, 0);
    local lbls = {};
    local maxDw = 0;
    local px, py = 0, 0;
    local gap = 12;
    local sz;
    for i=#dataList, 1, -1 do
        local lbl = ui.newTTFLabel({
                text = dataList[i],
                size = contentSize,
                color = contentColor,
                align = ui.TEXT_ALIGN_LEFT,
                dimensions=cc.size(ScoreLineCoinsPopupExt.WIDTH-PADDING, 0)
            })
            :addTo(self.content_)
        -- 
        sz = lbl:getContentSize();
        if sz.width > maxDw then
            maxDw = sz.width;
        end
        -- 
        px = sz.width*0.5;
        lbl:pos(px, py);
        lbls[i] = {lbl = lbl, sz = sz, px=px, py=py};
        py = py + sz.height + gap;
    end
    self.content_:pos(-width*0.5+26, -py*0.5 + 15);
    -- 
    if isUrl then
        local itemCfg = lbls[1];
        -- 
        lbl = ui.newTTFLabel({
            text = dataList[1],
            size = contentSize,
        }):addTo(self):hide()
        itemCfg.sz = lbl:getContentSize()
        -- 
        local lineContent = display.newNode()
        :addTo(self.content_)
        local url = "http://store.line.me";
        local lblUrl = ui.newTTFLabel({
                text=url, 
                size=contentSize+2, 
                color=cc.c3b(0x27, 0x83, 0xc0),
                align=ui.TEXT_ALIGN_LEFT
            })
            :addTo(lineContent)
        sz = lblUrl:getContentSize()
        px = itemCfg.sz.width*1.0 + sz.width*0.5
        lineContent:pos(px+5, itemCfg.py)
        -- 
        self.splitLine_ = display.newScale9Sprite(
                "#user-info-desc-button-background-down-line.png",
                0, -12,
                cc.size(sz.width+12, 2)
            ):addTo(lineContent)
    end
    local bdw, bdh = 140, 45;
    local btn = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9=true})
        :setButtonSize(bdw, bdh)
        :pos(0, -height/2 + TOP_HEIGHT)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("COMMON", "CONFIRM"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 32, align = ui.TEXT_ALIGN_CENTER}))
        :addTo(self)
        :onButtonClicked(function()
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:hide();
        end)
    self:addCloseBtn()
end

function ScoreLineCoinsPopupExt:show()
    nk.PopupManager:addPopup(self)
    return self
end

function ScoreLineCoinsPopupExt:hide()
    self:close()
end

function ScoreLineCoinsPopupExt:onClose()
    self:close()
end

function ScoreLineCoinsPopupExt:close()
    nk.PopupManager:removePopup(self)
    return self
end

return ScoreLineCoinsPopupExt;