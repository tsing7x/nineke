--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2015-12-30 17:27:47

local MatchBillDetailItem = class("MatchBillDetailItem", bm.ui.ListItem)

MatchBillDetailItem.WIDTH = 706;
MatchBillDetailItem.HEIGHT = 62;
MatchBillDetailItem.ROW_GAP = 1;
MatchBillDetailItem.PADDING_LEFT = 0;
MatchBillDetailItem.PADDING_RIGHT = 0;
MatchBillDetailItem.FONTSIZE = 18;
MatchBillDetailItem.OFFY = -25;

function MatchBillDetailItem:ctor()
	local width, height = MatchBillDetailItem.WIDTH, MatchBillDetailItem.HEIGHT
	MatchBillDetailItem.super.ctor(self, MatchBillDetailItem.WIDTH, MatchBillDetailItem.HEIGHT + MatchBillDetailItem.ROW_GAP)
    self:setNodeEventEnabled(true)

    local offX = width*0.5
    local fontSize = 20;
	local lblcolor = styles.FONT_COLOR.SLIVER;
	local dw = 70;
	local px = -width*0.5 + dw;
	local py = height*0.5;
	local lastDW = dw;
	self.tlblTime_ = ui.newTTFLabel({
			text="",
			color=lblcolor,
			size=fontSize,
			align=ui.TEXT_ALIGN_CENTER
		})
		:pos(px+offX, py)
		:addTo(self, 1)

	dw = 320;
	px = -100;
	lastDW = dw;
	self.tlblWay_ = ui.newTTFLabel({
			text="",
			color=lblcolor,
			size=fontSize,
			align=ui.TEXT_ALIGN_CENTER
		})
		:pos(px+offX, py)
		:addTo(self, 1)

	dw = 120;
	px = 120;
	lastDW = dw;
	self.tlblChange_ = ui.newTTFLabel({
			text="",
			color=cc.c3b(0xd3, 0x1c, 0x00),
			size=fontSize,
			align=ui.TEXT_ALIGN_CENTER
		})
		:pos(px+offX, py)
		:addTo(self, 1)

	dw = 150;
	px = 280;
	lastDW = dw;
	self.tlblLeft_ = ui.newTTFLabel({
			text="",
			color=lblcolor,
			size=fontSize,
			align=ui.TEXT_ALIGN_CENTER
		})
		:pos(px+offX, py)
		:addTo(self, 1)
end

function MatchBillDetailItem:onDataSet(dataChanged, data)
	self.data_ = data;
	if self.data_ then
		self:renderInfo();
	end
end

function MatchBillDetailItem:renderInfo()
	local timeArr = string.split(bm.TimeUtil:getTimeStampString(self.data_.operTime or 0), " ");
	self.tlblTime_:setString(timeArr[#timeArr])
	self.tlblWay_:setString(self.data_.source or "")
	self.tlblLeft_:setString(self.data_.curNum or "")

	local operNum = tonumber(self.data_.operNum or 0);
	if operNum > 0 then
		self.tlblChange_:setTextColor(cc.c3b(0xd3, 0x1c, 0x00))
		self.tlblChange_:setString("+"..operNum)
	else
		self.tlblChange_:setTextColor(cc.c3b(0x0e, 0xa4, 0x06))
		self.tlblChange_:setString(operNum.."")
	end
end

function MatchBillDetailItem:onCleanup()

end

return MatchBillDetailItem;