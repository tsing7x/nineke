--
-- Author: KevinLiang
-- Date: 2016-01-27 12:29:15
--

local VipIcon = class("VipIcon", function()
	return display.newNode("VipIcon")
end)

local BG_SIZE_W = 90
local BG_SIZE_H = 88

function VipIcon:ctor(width, height, level)
	local s = 1.0
  	if tonumber(level) >= 7 then --大于7，新版VIP
    	s = 0.7
  	end

	self.level_ = display.newSprite("#pop_vip_icon_level_" .. level .. ".png")
		:pos(-width * 0.5 + 8, height * 0.5 - 15)
		:scale(s)
		:addTo(self)
end

function VipIcon:setLevel(level_)
	if self.level_ then
		self.level_:setSpriteFrame(display.newSpriteFrame("pop_vip_icon_level_" .. level_ .. ".png"))
	end
end

return VipIcon