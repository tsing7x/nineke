--
-- Author: HLF
-- Date: 2015-11-02 11:58:28
-- 比赛场门票列表弹出框
local BubbleButton = import("boomegg.ui.BubbleButton")
local MatchTickToolItem = import("app.module.match.MatchTickToolItem")

local MatchTickPanel = class("MatchTickPanel", function()
	return display.newNode();
end)

MatchTickPanel.WIDTH = 730;
MatchTickPanel.HEIGHT = 240;

function MatchTickPanel:ctor(isInRoom, value)
	self.isInRoom_ = isInRoom;
	self.modal_ = display.newScale9Sprite("#transparent.png", 0, 0, cc.size(display.width, display.height))
            :pos(0, 0)
            :addTo(self)
    self.modal_:setTouchEnabled(true)
    self.modal_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onModalTouch_))
    local px = 0;
	local py = value or -105;
	local width, height = MatchTickPanel.WIDTH, MatchTickPanel.HEIGHT;
	self.contain_ = display.newNode():pos(0-3, py-6):addTo(self);

	self.bg_ = display.newScale9Sprite("#pop_common_content_bg.png", 0, 0, cc.size(width+45, height+45)):addTo(self.contain_)

	self.bg_:setTouchEnabled(true);
	self.bg_:setTouchSwallowEnabled(true);

	self.bgTex_ = display.newTilesSprite(
            "repeat/panel_repeat_tex.png",
            cc.rect(0, 0, width - 3, height - 3)
        )
        :pos(-width*0.5, -height*0.5)
        :addTo(self.contain_)

	self.title_ = ui.newTTFLabel({
			text=bm.LangUtil.getText("TICKET", "label"),
			color = styles.FONT_COLOR.LIGHT_TEXT,
			size = 32,
			align = ui.TEXT_ALIGN_CENTER
		})
		:pos(0, height*0.5 - 30)
		:addTo(self.contain_)

	px, py = -width*0.5+28, height*0.5 - 28;
	
	self.btnBack_ = cc.ui.UIPushButton.new({normal = "#pop_friend_back_button_normal.png", pressed = "#pop_friend_back_button_pressed.png"})
        :pos(px, py)
        :addTo(self.contain_,999,999)
        :add(display.newSprite("#pop_friend_back_icon.png"))
        :onButtonClicked(buttontHandler(self, self.onClose))

	local tickList = nk.MatchTickManager:getTickList();
	local LIST_WIDTH = 720;
	local LIST_HEIGHT = 210;

	self.propBackground = display.newScale9Sprite("#user-info-tab-background.png", 0, 0,cc.size(LIST_WIDTH+6, LIST_HEIGHT-25))
        :pos(0, -24)
        :addTo(self.contain_)

	self.toolList_ = bm.ui.ListView.new(
			{
				viewRect = cc.rect(-width*0.5, -LIST_HEIGHT*0.5, LIST_WIDTH, LIST_HEIGHT),
				direction=bm.ui.ListView.DIRECTION_HORIZONTAL
			},
			MatchTickToolItem
		)
		:pos(5, -22)
		:addTo(self.contain_)
	self.toolList_:setData(tickList)
    self.toolList_:addEventListener("ITEM_EVENT",handler(self,self.itemSelect_))
    self:updateTouchRect_();
end

function MatchTickPanel:itemSelect_(evt)
	local itemData = evt.data;
	if self.isInRoom_ then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("TICKET", "ALERT_INROOM_MSG"))
	else
		self:onClose();
		nk.userData.useTickType_ = nk.MatchTickManager.TYPE2;-- 个人档门票弹出框使用门票
		nk.MatchTickManager:applyTick(itemData)
	end
end

function MatchTickPanel:show()
	-- nk.PopupManager:addPopup(self)
	-- self:showed();
	return self;
end

function MatchTickPanel:showed()
	self.isShowed_ = true
	-- self:updateTouchRect_();
	self.contain_:scale(0.2)
    transition.scaleTo(self.contain_, {time = 0.5, easing = "BACKOUT", scale = 1})
end

function MatchTickPanel:updateTouchRect_()
	if self.toolList_ then
        self.toolList_:setScrollContentTouchRect()
    end
end

function MatchTickPanel:onClose()
	self:close();
end

function MatchTickPanel:close()
	-- nk.PopupManager:removePopup(self);
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	
	self.modal_:removeFromParent()
	self:removeFromParent();
	return self;
end

function MatchTickPanel:onModalTouch_(evt)
	self:close();
end

return MatchTickPanel;
