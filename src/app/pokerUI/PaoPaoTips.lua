-- 
-- 泡泡提示
-- Author: leoluo
-- Date: 2015-06-18
--
local PaoPaoTips = class("PaoPaoTips", function()
    return display.newNode()
end)

function PaoPaoTips:ctor(text, size, margin, dimensions)
	self.text_ = text
	self.size_ = size
	self.dimensions_ = dimensions
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:buildView_(margin)
end

function PaoPaoTips:buildView_(margin)
	self.label_ = ui.newTTFLabel({text = self.text_, color = cc.c3b(51, 60, 68), size = self.size_, align = ui.TEXT_ALIGN_CENTER})
	if self.dimensions_ then
		self.label_:setDimensions(self.dimensions_.width, self.dimensions_.height)
	end
	local labelSize = self.label_:getContentSize()
	local size = cc.size(labelSize.width + 15, labelSize.height + 18)

	local sharedTextureCache = cc.Director:getInstance():getTextureCache()
	local tex = sharedTextureCache:addImage("paopao.png")
	local frame1 = cc.SpriteFrame:createWithTexture(tex, cc.rect(0,0,12,46))
	local frame2 = cc.SpriteFrame:createWithTexture(tex, cc.rect(12,0,22,46))
	local frame3 = cc.SpriteFrame:createWithTexture(tex, cc.rect(34,0,11,46))


	local marginLeft = margin and margin.left or 0
	local marginRight = margin and margin.right or 0
	local leftWidth = size.width / 2 - 11
	local rightWidth = size.width / 2 - 11
	if marginLeft ~= 0 then
		leftWidth = marginLeft
		rightWidth = size.width - leftWidth - 22
	elseif marginRight ~= 0 then
		rightWidth = marginRight
		leftWidth = size.width - rightWidth - 22
	end

	self.left_ = display.newScale9Sprite(frame1, leftWidth / 2 - size.width / 2, -4, cc.size(leftWidth, size.height)):addTo(self)
	self.center_ = display.newScale9Sprite(frame2, leftWidth/2 - rightWidth/2, -4, cc.size(22, size.height)):addTo(self)	
	self.right_ = display.newScale9Sprite(frame3, size.width /2 - rightWidth / 2, -4, cc.size(rightWidth, size.height)):addTo(self)
	self.label_:addTo(self)
end

function PaoPaoTips:reSize_(margin)
	local labelSize = self.label_:getContentSize()
	local size = cc.size(labelSize.width + 15, labelSize.height + 18)
	local marginLeft = margin and margin.left or 0
	local marginRight = margin and margin.right or 0
	local leftWidth = size.width / 2 - 11
	local rightWidth = size.width / 2 - 11
	if marginLeft ~= 0 then
		leftWidth = marginLeft
		rightWidth = size.width - leftWidth - 22
	elseif marginRight ~= 0 then
		rightWidth = marginRight
		leftWidth = size.width - rightWidth - 22
	end

	self.left_:pos(leftWidth / 2 - size.width / 2, -4):setContentSize(cc.size(leftWidth, size.height))
	self.center_:pos(leftWidth/2 - rightWidth/2, -4):setContentSize(cc.size(22, size.height))
	self.right_ :pos(size.width /2 - rightWidth / 2 , -4):setContentSize(cc.size(rightWidth, size.height))
end

function PaoPaoTips:setText(text, margin)
	self.text_ = text
	self.label_:setString(text)
	self:reSize_(margin)
end

function PaoPaoTips:getSize()
	return self.label_:getContentSize()
end

return PaoPaoTips
