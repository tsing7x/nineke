--
-- Author: XT
-- Date: 2015-09-09 17:15:43
--
local RoomBatteryIndicator = class("RoomBatteryIndicator", function()
	return display.newNode();
end)

RoomBatteryIndicator.MAX_VAL = 27;
RoomBatteryIndicator.MIN_VAL = 8;

RoomBatteryIndicator.HEIGHT = 10;


function RoomBatteryIndicator:ctor()
	self.batteryBg_ = display.newSprite("#room_batteryBg.png"):addTo(self);
	self.batteryBar_ = display.newScale9Sprite("#room_batteryBar.png", 0, 0, cc.size(RoomBatteryIndicator.MIN_VAL, RoomBatteryIndicator.HEIGHT))
						:pos(-15, 0)
						:addTo(self);
	self.batteryBar_:setAnchorPoint(cc.p(0, 0.5));
	self.batteryBar_:setContentSize(RoomBatteryIndicator.MAX_VAL, RoomBatteryIndicator.HEIGHT);

	self.isflash_ = false;
end

-- rate的范围是0.0~1.0
function RoomBatteryIndicator:setSignalStrength(rate)
	if rate then
		local val = rate / 100 * RoomBatteryIndicator.MAX_VAL;
		if val <= RoomBatteryIndicator.MIN_VAL then
			val = RoomBatteryIndicator.MIN_VAL;
		end
		self.batteryBar_:setContentSize(val, RoomBatteryIndicator.HEIGHT);

		if rate <= 10 then
			self:flash_(true);
		end
	end
end

function RoomBatteryIndicator:flash_(isFlash)
	if self.isFlashing_ ~= isFlash then
        self.isFlashing_ = isFlash
        self:stopAllActions();
        if isFlash then
            self.batteryBar_:runAction(cc.RepeatForever:create(transition.sequence({
				cc.Show:create(),
		        cc.DelayTime:create(0.8),
		        cc.Hide:create(),
		        cc.DelayTime:create(0.8)
			})));
        else
            self:show()
        end
    end
end

return RoomBatteryIndicator