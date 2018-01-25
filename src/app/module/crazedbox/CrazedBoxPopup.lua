--
-- Author: KevinYu
-- Date: 2015-11-02 14:42:20
-- 疯狂宝箱弹窗
local CrazedBox = import(".CrazedBox")

local CrazedBoxPopup = class("CrazedBoxPopup", nk.ui.Panel)

local WIDTH, HEIGHT = 675, 475 --弹窗宽高
local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

function CrazedBoxPopup:ctor()
	CrazedBoxPopup.super.ctor(self, {WIDTH, HEIGHT})

    self:setCommonStyle(bm.LangUtil.getText("CRAZED", "TITLE"))

	bm.HttpService.POST(
        {
            mod = "CrazyBox",
            act = "getRewardDesc"
         },
        function (data)
            local callData = json.decode(data)
            dump(callData, "CrazyBox")
            self:addBoxTips_()
			self:addMiddleNode_(callData)
        end,
        function (data)
        end)

	
end

--添加开启宝箱说明
function CrazedBoxPopup:addBoxTips_()
	local questionStr = bm.LangUtil.getText("CRAZED", "QUESTION")
	local answerStr = bm.LangUtil.getText("CRAZED", "ANSWER")
	local label_X, label_Y = -WIDTH * 0.5 + 42,  142

 	ui.newTTFLabel({
			text = questionStr, 
			color = TEXT_COLOR,
			size = 18})
		:align(display.LEFT_CENTER, label_X, label_Y)
		:addTo(self)

	for i = 1, #answerStr do
		ui.newTTFLabel({
			text = answerStr[i], 
			color = TEXT_COLOR,
			size = 18})
		:align(display.LEFT_CENTER, label_X, label_Y - 30 * i)
		:addTo(self)	
	end
end

--添加中间宝箱结点
function CrazedBoxPopup:addMiddleNode_(data)
 	local pos_Y = -75

 	self.boxList_ = {}
 	self.boxList_[1] = CrazedBox.new(
	 		"#copper_box_close.png",
	 		"#copper_box_open.png",
	 		"#copper_box_light.png",
	 		{normal = bm.LangUtil.getText("CRAZED", "TIME"), disabled = bm.LangUtil.getText("CRAZED", "TOMORROW")},
	 		1,
	 		data.little)
 		:pos(-210, pos_Y)
 		:addTo(self)
 	self.boxList_[2] = CrazedBox.new(
 			"#silver_box_close.png",
	 		"#silver_box_open.png",
	 		"#silver_box_light.png",
	 		{normal = bm.LangUtil.getText("CRAZED", "COST_50K")},
	 		2,
	 		data.mid)
 		:pos(0, pos_Y)
 		:addTo(self)
 	self.boxList_[3] = CrazedBox.new(
 			"#glod_box_close.png",
	 		"#glod_box_open.png",
	 		"#glod_box_light.png",
	 		{normal = bm.LangUtil.getText("CRAZED", "COST_500K")},
	 		3,
	 		data.max)
 		:pos(210, pos_Y)
 		:addTo(self)
end

function CrazedBoxPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function CrazedBoxPopup:close_()
	nk.PopupManager:removePopup(self)
end

return CrazedBoxPopup