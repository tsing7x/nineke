--
-- Author: hlf
-- Date: 2015-12-09 15:46:52
-- 合成炉列表项

local MixCurrencyItem = class("MixCurrencyItem", bm.ui.ListItem);

MixCurrencyItem.WIDTH=516;
MixCurrencyItem.HEIGHT=62+10;
MixCurrencyItem.ROW_GAP = 3;
MixCurrencyItem.PADDING_LEFT = 0;
MixCurrencyItem.PADDING_RIGHT = 0;
MixCurrencyItem.FONTSIZE = 18;
MixCurrencyItem.OFFY = -25;

local AVATAR_TAG = 100 -- 获取子节点时， 通过此tag查找 替换贴图
local ICON_WIDTH = 54;
local ICON_HEIGHT = 54;

function MixCurrencyItem:ctor()
	local width, height = MixCurrencyItem.WIDTH, MixCurrencyItem.HEIGHT
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
    self.width_ = MixCurrencyItem.WIDTH
    self.height_ = MixCurrencyItem.HEIGHT + MixCurrencyItem.ROW_GAP
    MixCurrencyItem.super.ctor(self, MixCurrencyItem.WIDTH, MixCurrencyItem.HEIGHT + MixCurrencyItem.ROW_GAP)
    self:setNodeEventEnabled(true)

    local offX = width*0.5
    local px, py = 0, height*0.5;
    self.bg_ = display.newScale9Sprite("#help_item_background.png", 0, 0, cc.size(width, height), cc.rect(12,31,1,1))
        :pos(px+offX, py)
        :addTo(self)

    -- 终极合成
    px = -width*0.5 + ICON_WIDTH*0.5 + 8
    self.icon_ = display.newNode()
        :size(ICON_WIDTH,ICON_HEIGHT)
        :pos(px+offX+240, py+10)
        :addTo(self)
    self.finalWord_ = ui.newTTFLabel({
            text="",
            color=cc.c3b(0xff, 0xff, 0xff);
            size=22,
            align=ui.TEXT_ALIGN_LEFT
        })
        :align(display.LEFT_CENTER)
        :pos(px+offX+240-ICON_WIDTH*0.5, py-22)
        :addTo(self)

    -- 箭头
    self.arrow_ = display.newSprite("#mix_arrow.png")
        :pos(px+offX+150,py+2)
        :addTo(self)
    -- 合成途径
    self.btn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_green_normal.png",
            pressed = "#common_btn_green_pressed.png"
        }, { scale9 = true })
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("MixCurrent","MIX_BTNLBL"), color = display.COLOR_WHITE}))
        :setButtonSize(100, 50)
        :pos(width-67, py)
        :addTo(self)
        :onButtonPressed(function(evt)
            self.btnPressedX_ = evt.x;
            self.btnClickCanceled_ = false;
        end)
        :onButtonRelease(function(evt)
            if math.abs(evt.x - self.btnPressedX_) > 10 then
                self.btnClickCanceled_ = true;
            end
        end)
        :onButtonClicked(function(evt)
            if not self.btnClickCanceled_ and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON);
                self:onOpenMix_(evt);
            end
        end)
end

function MixCurrencyItem:onOpenMix_(evt)
	self:dispatchEvent({name="ITEM_EVENT", type="BUY_GIFT", data=self.data_})
end

function MixCurrencyItem:onDataSet(dataChanged, data)
    self.needResize_ = false
	self.data_ =data;
	self:renderInfo();
end

function MixCurrencyItem:resizeSize()
    if self.needResize_ then
        self:setContentSize(cc.size(self.width_, self.height_))
        self:dispatchEvent({name="RESIZE"})
    end
    self.needResize_ = false
end

function MixCurrencyItem:renderInfo()
	local sz;
	local px, py;
	if not self.defaultIcon_ then
		local url = self.data_.url;
	    px, py = self.icon_:getPosition();
		self.defaultIcon_ = display.newSprite(url)
			:pos(px+MixCurrencyItem.WIDTH*0.5, py)
			:addTo(self)
		sz = self.defaultIcon_:getContentSize();
		self.defaultIcon_:setScale(ICON_WIDTH/sz.width)
	end
    if self.data_.toStr then
        self.finalWord_:setString(self.data_.toStr)
    end

    local iconContainer = self.icon_;
    local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
    if oldAvatar then
        oldAvatar:removeFromParent()
    end
    if self.data_ and self.data_.toIcons and table.nums(self.data_.toIcons)>0 then
        if self.defaultIcon_ then
            self.defaultIcon_:hide()
        end
        for k,v in pairs(self.data_.toIcons) do
            local sprite = display.newSprite(v)
            local texSize = sprite:getContentSize()
            local iconSize = iconContainer:getContentSize()
            local xxScale = iconSize.width/texSize.width
            local yyScale = iconSize.height/texSize.height
            sprite:scale(xxScale<yyScale and xxScale or yyScale):addTo(iconContainer, 0, AVATAR_TAG)
            iconContainer:show();
            break;
        end
    else
        if self.defaultIcon_ then
            self.defaultIcon_:show()
        end
    end

    -- 重置
    if self.data_ and self.data_.fromNum then
        local length = self.data_.fromNum
        local tempHeight = length*MixCurrencyItem.HEIGHT + MixCurrencyItem.ROW_GAP
        if tempHeight~=self.height_ then
            self.needResize_ = true
        end
        self.height_ = tempHeight
        local trueHeight = self.height_-MixCurrencyItem.ROW_GAP
        self.bg_:setContentSize(cc.size(self.width_, trueHeight))
        local yy = self.height_ * 0.5
        self.bg_:setPositionY(yy)
        self.icon_:setPositionY(yy+10)
        self.finalWord_:setPositionY(yy-23)
        self.btn_:setPositionY(yy+1)
        self.arrow_:setPositionY(yy+2)
        if self.propNode_ then
            self.propNode_:removeFromParent()
            self.propNode_ = nil
        end

        self.propNode_ = display.newNode()
            :pos(40,yy)
            :addTo(self)
        self.propNode_:setContentSize(cc.size(10,10))
        if self.data_.fromIcons then
            local itemHeight = MixCurrencyItem.HEIGHT
            local startHeight = trueHeight*0.5-itemHeight*0.5
            local index = 1
            local icon = nil
            local text = nil
            local size = nil
            local xxScale = nil
            local yyScale = nil
            for k,v in pairs(self.data_.fromIcons) do
                icon = display.newSprite(v)
                    :addTo(self.propNode_)
                size = icon:getContentSize()
                xxScale = ICON_WIDTH/size.width
                yyScale = ICON_HEIGHT/size.height
                icon:scale(xxScale<yyScale and xxScale or yyScale)
                icon:pos(0,startHeight-(index-1)*itemHeight+10)

                text = ui.newTTFLabel({
                    text="",
                    color=cc.c3b(0xff, 0xff, 0xff);
                    size=22,
                    align=ui.TEXT_ALIGN_LEFT
                })
                    :align(display.LEFT_CENTER)
                    :pos(-ICON_WIDTH*0.5,startHeight-(index-1)*itemHeight-20)
                    :addTo(self.propNode_)

                if self.data_["str"..k] then
                    text:setString(self.data_["str"..k])
                end
                index = index + 1
            end
        end
    end
end

function MixCurrencyItem:onCleanup()
	if self.iconLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
        self.iconLoaderId_ = nil;
    end
end

return MixCurrencyItem;