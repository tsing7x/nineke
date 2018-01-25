--
-- Author: HLF
-- Date: 2015-09-28 00:53:08
--
local ScoreComboItem = class("ScoreComboItem", bm.ui.ListItem)
ScoreComboItem.WIDTH = 200
ScoreComboItem.HEIGHT = 48

function ScoreComboItem:ctor()
	local WIDTH = ScoreComboItem.WIDTH
	local HEIGHT = ScoreComboItem.HEIGHT
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	ScoreComboItem.super.ctor(self, ScoreComboItem.WIDTH, ScoreComboItem.HEIGHT)
	self:setNodeEventEnabled(true) -- 框架直接执行 onCleanup
    
    local px = WIDTH*0.5

    display.newScale9Sprite("#invite_friend_inputback.png", px, 0, cc.size(WIDTH, HEIGHT+2)):addTo(self)
	self.lbl_ = ui.newTTFLabel({
			text = "",
			color = cc.c3b(0, 0, 0),
			size=20,
			align = ui.TEXT_ALIGN_CENTER,
		})
		:pos(px, 0)
		:addTo(self)

	self.btnGroup_ = cc.ui.UICheckBoxButton.new({off="#common_transparent_skin.png", on="#common_transparent_skin.png"}, {scale9 = true})
            :setButtonLabel(ui.newTTFLabel({text="", size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0, 0)
            :setButtonSize(WIDTH, HEIGHT+2)
            :setButtonLabelAlignment(display.CENTER)
            :pos(px, 0)
            :addTo(self)

	self.btnGroup_:setTouchSwallowEnabled(false)
	self.btnGroup_:onButtonPressed(function(evt)
		self.btnPressedX_ = evt.x
		self.btnClickCanceled_ = false
	end)

	self.btnGroup_:onButtonRelease(function(evt)
		if math.abs(evt.x - self.btnPressedX_) > 2 then
			self.btnClickCanceled_ = true
		end
	end)

	self.btnGroup_:onButtonClicked(function(evt)
		if not self.btnClickCanceled_ and self:getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
			nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
			self:selectHandler_(evt)
		end
	end)

	self:setAnchorPoint(cc.p(0.0, -0.5))
end

function ScoreComboItem:onDataSet(dataChanged, data)
	self.data_ = data
	self.lbl_:setString(self.data_.title)
end

function ScoreComboItem:selectHandler_(evt)
	self:dispatchEvent({name="ITEM_EVENT", type="DROPDOWN_LIST_SELECT", data=self.data_})
end

return ScoreComboItem