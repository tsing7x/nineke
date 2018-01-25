--
-- Author: hlf
-- Date: 2015-09-21 20:11:59
-- http://blog.csdn.net/a102111/article/details/43236947
local ComboboxView = class("ComboboxView", function()
	return display.newNode()
end)

function ComboboxView:ctor(params)
	self.lblSize_ = params.lblSize or 22
	self.borderSize_ = params.borderSize or cc.size(180, 36)
	self.lblcolor_ = params.lblcolor or cc.c3b(0,0,0)
	self.barUpRes_ = params.barUpRes or "#transparent.png"
	self.barDownRes_ = params.barDownRes or "#transparent.png"
	self.borderRes_ = params.borderRes or "#transparent.png"
	self.itemCls_ = params.itemCls
	self.listWidth_ = params.listWidth
	self.listHeight_ = params.listHeight
	self.listOffX_ = params.listOffX or 0
	self.listOffY_ = params.listOffY or 0

	local value = params.data
	local data = {}
    for i = 1, #value do
        data[i] = {}
        data[i].id = i
        data[i].selected = false
        data[i].title = value[i]
    end

	self.data_ = data

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.borderBg_ = display.newScale9Sprite(self.borderRes_, 0, 0, self.borderSize_)
		:addTo(self, 1)

	self.icon_ = display.newSprite(self.barUpRes_)
		:addTo(self, 2)
	self.icon_:pos(self.borderSize_.width*0.5 - self.icon_:getContentSize().width*0.5, 0)

	self.lbl_ = ui.newTTFLabel({
		text = value[1],
		color = self.lblcolor_,
		size = self.lblSize_,
		align = ui.TEXT_ALIGN_CENTER,
		dimensions=cc.size(self.borderSize_.width-self.borderSize_.height - 0, 0)
	})
	:pos(-self.borderSize_.height*0.5, 0)
	:addTo(self, 3)

	self.btn_ = cc.ui.UIPushButton.new({normal="#common_transparent_skin.png", pressed="#common_transparent_skin.png"}, {scale9=true})
		:setButtonSize(self.borderSize_.width, self.borderSize_.height)
		:pos(0, 0)
		:onButtonPressed(function(evt)
			if string.byte(self.barDownRes_) == 35 then
				self.icon_:setSpriteFrame(display.newSpriteFrame(string.sub(self.barDownRes_, 2)))
			else
				self.icon_:setSpriteFrame(display.newSpriteFrame(self.barDownRes_))
			end
		end)
		:onButtonRelease(function(evt)
			if string.byte(self.barDownRes_) == 35 then
				self.icon_:setSpriteFrame(display.newSpriteFrame(string.sub(self.barUpRes_, 2)))
			else
				self.icon_:setSpriteFrame(display.newSpriteFrame(self.barUpRes_))
			end
			if evt.touchInTarget then
				
			end
		end)
		:onButtonClicked(function(evt)
			nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
			self:onBtnClicked_()
		end)
		:addTo(self,5)
end

function ComboboxView:addDropList_()
	if not self.list_ then
        self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-self.listWidth_ * 0.5, -self.listHeight_ * 0.5, self.listWidth_, self.listHeight_),
                direction=bm.ui.ListView.DIRECTION_VERTICAL,
            }, 
            self.itemCls_
        )
        :pos(self.listOffX_, -self.listHeight_*0.5+self.listOffY_)
        :addTo(self, 99)

        self.list_:setData(self.data_,true)

	    self:onShowed()

	    self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
	end
end

function ComboboxView:onBtnClicked_()
	if self.list_ then
		self:hideList()
	else
		bm.EventCenter:dispatchEvent(nk.eventNames.DISENABLED_EDITBOX_TOUCH)

		self:addDropList_()
		self:addModule()
	end
end

function ComboboxView:hideList()
	if self.list_ then
		self.list_:removeFromParent()
		self.list_ = nil
		
		if self.modal_ then
	        self.modal_:removeFromParent()
	        self.modal_ = nil
	    end
	    bm.EventCenter:dispatchEvent(nk.eventNames.ENABLED_EDITBOX_TOUCH)
	end
end

function ComboboxView:setText(value)
	self.lbl_:setString(value or "")
end

function ComboboxView:getText()
	return self.lbl_:getString()
end

function ComboboxView:onShowed()
	if self.list_ then
		self.list_:setScrollContentTouchRect()
        self.list_:update()
    end
end

function ComboboxView:onItemEvent_(evt)
    if evt.type == "DROPDOWN_LIST_SELECT" then
        self.lbl_:setString(evt.data.title or "")
    end

    self:hideList()
end

function ComboboxView:addModule()
    if not self.modal_ then
        self.modal_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width*1.5, display.height*1.5))
            :pos(0, 0)
            :addTo(self, -999)
        self.modal_:setTouchEnabled(true)
        self.modal_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.hideList))
    end    
end

return ComboboxView