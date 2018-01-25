--
-- Author: XT
-- Date: 2015-11-23 09:47:05
--
local MatchRewardItem = class("MatchRewardItem", bm.ui.ListItem);
MatchRewardItem.WIDTH = 110;
MatchRewardItem.HEIGHT = 140;
MatchRewardItem.ROW_GAP = 0;
MatchRewardItem.COL_GAP = 1;

local ICON_WIDTH = 90;
local ICON_HEIGHT = 90;
local AVATAR_TAG = 999;

function MatchRewardItem:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	MatchRewardItem.super.ctor(self, MatchRewardItem.WIDTH + MatchRewardItem.COL_GAP, MatchRewardItem.HEIGHT + MatchRewardItem.ROW_GAP);
	self:setNodeEventEnabled(true);
    self.isFolded_ = true;

    local rate = 0.5;
    local px, py = MatchRewardItem.WIDTH*rate, MatchRewardItem.HEIGHT*rate;

    -- 背景
	self.bg0_ = display.newScale9Sprite("#rewardItembg0.png", 0, 0, cc.size(MatchRewardItem.WIDTH, MatchRewardItem.HEIGHT))
        :pos(px, py)
        :addTo(self);
    self.bg1_ = display.newScale9Sprite("#rewardItembg1.png", 0, 0, cc.size(MatchRewardItem.WIDTH, MatchRewardItem.HEIGHT))
        :pos(px, py)
        :addTo(self);
    self.bottom_ = display.newScale9Sprite("#rewardItem_bottom.png", MatchRewardItem.WIDTH*0.5, 52*0.5, cc.size(110, 52), cc.rect(16, 52, 1, 1))
        :addTo(self)

    -- 加载图标
    rate = 0;
   	px, py = MatchRewardItem.WIDTH * rate + 10, MatchRewardItem.HEIGHT * rate + 35
    self.icon_ = display.newNode()
    			:size(ICON_WIDTH, ICON_HEIGHT)
    			:pos(px, py)
    			:addTo(self)

    -- 标题
    self.propName_ = ui.newTTFLabel({
    		text = "",
    		color = styles.FONT_COLOR.LIGHT_TEXT,
    		size = 16,
    		align = ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(MatchRewardItem.WIDTH - 2, 0),
    	})
    	:pos(MatchRewardItem.WIDTH * 0.5, 22)
    	:addTo(self, 4, 4)

    -- 道具使用
    self.propUseButton_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png" , pressed = "#user-info-tab-background.png"}, {scale9 = true})
        :setButtonSize(MatchRewardItem.WIDTH-2, MatchRewardItem.HEIGHT-2)
        :onButtonClicked(buttontHandler(self, self.onOpenPopupHandler_))
        :pos(MatchRewardItem.WIDTH*0.5, MatchRewardItem.HEIGHT*0.5)
        :addTo(self)
        :onButtonPressed(function(evt) 
            self.btnPressedY_ = evt.y
            self.btnClickCanceled_ = false
        end)
        :onButtonRelease(function(evt)
            if math.abs(evt.y - self.btnPressedY_) > 5 then
                self.btnClickCanceled_ = true
            end
        end)

    self.propUseButton_:setTouchSwallowEnabled(false)
end

function MatchRewardItem:onDataSet(dataChanged, data)
	self.data_ = data;
    if self.data_ then
	   self:render();
    end
end

function MatchRewardItem:setIndex(index)
	self.index_ = index;
	if self.index_ % 2 == 0 then
        self.bg0_:hide();
        self.bg1_:show();
	else
        self.bg0_:show();
        self.bg1_:hide();
    end
end

function MatchRewardItem:render()
	if not self.data_.num and not self.data_.name and not self.data_.image then
		return;
	end

	if self.propIcon_ then
		self.propIcon_:removeFromParent();
	end

    self.data_.name = self.data_.name or ""
    if string.len(self.data_.name) > 0 then
	   self.propName_:setString(self.data_.name.." x "..self.data_.num);
    else
        self.propName_:setString(self.data_.name);
    end

    local px, py = MatchRewardItem.WIDTH * 0.5, MatchRewardItem.HEIGHT * 0.5 + 24;
	if string.find(self.data_.image, "http://") or string.find(self.data_.image, "https://") then
		if not self.iconLoaderId_ then
			self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
		end

		local iconContainer = self.icon_;
		nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
		nk.ImageLoader:loadAndCacheImage(self.iconLoaderId_,
            self.data_.image, 
            function(success, sprite)
                if success then

                    local tex = sprite:getTexture()
                    local texSize = tex:getContentSize()
                    local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
                    if oldAvatar then
                        oldAvatar:removeFromParent()
                    end
                    local iconSize = iconContainer:getContentSize()
                    local xxScale = iconSize.width/texSize.width
                    local yyScale = iconSize.height/texSize.height
                    sprite:scale(xxScale<yyScale and xxScale or yyScale)
                        :addTo(iconContainer, 0, AVATAR_TAG)
                    iconContainer:pos(ICON_WIDTH*0.5+10, ICON_HEIGHT*0.5+50)
                    iconContainer:show();
                end
            end,
            nk.ImageLoader.CACHE_TYPE_GIFT
        )
	else
		self.propIcon_ = display.newSprite(self.data_.image)
				:pos(ICON_WIDTH*0.5, ICON_HEIGHT*0.5+8)
                :addTo(self.icon_)
        local maxDw = 80;
        local sz = self.propIcon_:getContentSize();
        local xxscale, yyscale = maxDw/sz.width, maxDw/sz.height;
        local scale = xxscale;
        if xxscale > yyscale then
        	scale = yyscale;
        end
        self.propIcon_:setScale(scale)
	end	
end

function MatchRewardItem:onOpenPopupHandler_(evt)
	self:dispatchEvent({name="ITEM_EVENT", type="USE_PROP", data=self.data_}) 
end

function MatchRewardItem:onCleanup()
	if self.iconLoaderId_ then
		nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
		self.iconLoaderId_ = nil;
	end
end

return MatchRewardItem;