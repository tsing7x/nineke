--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2015-12-14 15:52:29
-- 门票过期列表项
local BubbleButton = import("boomegg.ui.BubbleButton")
local MatchTickOverDueItem = class("MatchTickOverDueItem", bm.ui.ListItem)
MatchTickOverDueItem.WIDTH = 660;
MatchTickOverDueItem.HEIGHT = 85;
MatchTickOverDueItem.ROW_GAP = 1;
MatchTickOverDueItem.COL_GAP = 6;

local BUTTON_TEXT = "ใช้ตอนนี้" -- 立即使用

local ICON_WIDTH = 120
local ICON_HEIGHT = 120
local AVATAR_TAG = 101

function MatchTickOverDueItem:ctor()
	local width, height = MatchTickOverDueItem.WIDTH, MatchTickOverDueItem.HEIGHT;
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	MatchTickOverDueItem.super.ctor(self, width + MatchTickOverDueItem.COL_GAP, height + MatchTickOverDueItem.ROW_GAP);
    self:setNodeEventEnabled(true);

    local px, py = width*0.5, height*0.5;
    self.bg_ = display.newScale9Sprite("#panel_overlay.png", px, py, cc.size(width, height))
    	:addTo(self, 1)

    -- 道具图标
    px = 0 + ICON_WIDTH*0.5 + 10;
    self.propIcon_ = display.newSprite("matchTick_icon.png")
    	:pos(px, py)
    	:addTo(self, 2);

    -- 加载图标
    self.icon_ = display.newNode()
    			:size(ICON_WIDTH, ICON_HEIGHT)
    			:pos(px, py)
    			:addTo(self, 2)
    self.icon_:hide();

    px = px + 210;
    self.propDate_ = ui.newTTFLabel({
    		text="",
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		size=22,
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:pos(px, py)
    	:addTo(self, 2);
    px = px + 190;
    self.leftLbl_ = ui.newTTFLabel({
    		text="",
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		size=22,
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:pos(px, py)
    	:addTo(self, 2);

    local BUTTON_DW, BUTTON_DH = 160, 61;
    px = width - BUTTON_DW*0.5 - 10;
    self.bubbleBtn_ = BubbleButton.new({
            image = "#common_btn_green_normal.png",
            color = cc.c3b(0xff, 0xff, 0xcc),
            outcolor = cc.c3b(0,0,0),
            outlineWidth = 1,
            x = px - 0,
            y = py + 0,
            lblOffDw = 0,
            offX = 0,
            offY = 0,
            size = cc.size(BUTTON_DW, BUTTON_DH),
            scale9 = true,
            text = BUTTON_TEXT,
            fontSize = 32,
            prepare = function()

            end,
            listener = function()
                self:applyPropHandler_();
            end,
        }):addTo(self, 2);
end

function MatchTickOverDueItem:applyPropHandler_(evt)
	self:dispatchEvent({name="ITEM_EVENT", type="APPLY_PROP", data=self.data_}) 
end

function MatchTickOverDueItem:onDataSet(dataChanged, data)
	self.data_ = data;
	self:render();
end

function MatchTickOverDueItem:showEffect()
    local width, height = MatchTickOverDueItem.WIDTH, MatchTickOverDueItem.HEIGHT;
    local px, py = width*0.5, height*0.5;
    if nil == self.bg1_ then
        self.bg1_ = display.newScale9Sprite("#common_red_btn_down.png", px, py, cc.size(width, height))
            :addTo(self, 1)
    end
    self.bg1_:setOpacity(0);

    local ts1 = 1.0;
    local ts2 = 1.0;
    self.bg1_:runAction(transition.sequence({
        cc.DelayTime:create(ts1),
        cc.FadeIn:create(ts2),
        cc.FadeOut:create(ts1), 
        cc.FadeIn:create(ts2),
        cc.FadeOut:create(ts1), 
        cc.FadeIn:create(ts2),
        cc.FadeOut:create(ts1), 
    }));
end

function MatchTickOverDueItem:render()
	-- 是否过期:true为过期
	if not self.data_.isOverDate then
        str = nk.MatchTickManager:getTickDateStr(self.data_.endtime, true);
		self.propDate_:setString(str);
	else
		self.propDate_:setString(bm.LangUtil.getText("TICKET", "OVERDUE_LABLE"));
		self.propUseButton_:setButtonEnabled(false);
	end
	self.leftLbl_:setString(self.data_.num);

	if string.find(self.data_.img, "http://") then
		if not self.iconLoaderId_ then
			self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
		end

		local iconContainer = self.icon_;
		nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
		nk.ImageLoader:loadAndCacheImage(self.iconLoaderId_,
            self.data_.img, 
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
                    -- 判断是否过期
                    if not self.data_.isOverDate then
                        sprite:scale(xxScale<yyScale and xxScale or yyScale):addTo(iconContainer, 0, AVATAR_TAG)
                        iconContainer:show();
                    else
                        local spr_ = bm.grayNodeByTex(tex)
                        spr_:scale(xxScale<yyScale and xxScale or yyScale):addTo(iconContainer, 0, AVATAR_TAG)
                        iconContainer:show();
                    end
                    self.propIcon_:hide();
                    self.icon_:show();
                end
            end,
            nk.ImageLoader.CACHE_TYPE_GIFT
        )
	else
		local px, py = 0, 0;
		if self.propIcon_ then
			px, py = self.propIcon_:getPosition();
			self.propIcon_:removeFromParent();
		end

		self.propIcon_ = display.newSprite(self.data_.img)
						:pos(px, py)
						:addTo(self, 1, 1);
	end
end

function MatchTickOverDueItem:onCleanup()
    if self.bg1_ then
        self.bg1_:stopAllActions();
    end
end

return MatchTickOverDueItem;