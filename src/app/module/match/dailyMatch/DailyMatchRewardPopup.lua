--
-- Author: hlf
-- Date: 2015-11-04 11:45:19
-- 比赛场每日任务完成后的奖励界面

local DailyMatchRewardPopup = class("DailyMatchRewardPopup", function()
	return display.newNode();
end)

DailyMatchRewardPopup.WIDTH = 475
DailyMatchRewardPopup.HEIGHT = 324

function DailyMatchRewardPopup:ctor(list)
	if #list == 1 then
		DailyMatchRewardPopup.WIDTH = 360
		DailyMatchRewardPopup.HEIGHT = 324
	else
		DailyMatchRewardPopup.WIDTH = 475
		DailyMatchRewardPopup.HEIGHT = 324
	end
	local width, height = DailyMatchRewardPopup.WIDTH, DailyMatchRewardPopup.HEIGHT;
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width, height)
    self.mainContainer_:setTouchEnabled(true)
    self.mainContainer_:setTouchSwallowEnabled(true)

    local px, py = -width*0.5, -height*0.5;
	self.bg_ = display.newScale9Sprite("#dailytasksMatch_dialog_bg2.png", 0, 0, cc.size(width, height), cc.rect(24, 162, 2, 1))
		:addTo(self.mainContainer_)
	self.tbg_ = display.newScale9Sprite("#user-info-tab-background.png", 0, -26, cc.size(width-26, height-75))
		:addTo(self.mainContainer_)

    self.bgTex_ = display.newTilesSprite(
            "repeat/panel_repeat_tex.png",
            cc.rect(0, 0, width - 3, height - 3)
        )
        :pos(px, py)
        :addTo(self.mainContainer_)

    -- 恭喜您获得
    self.title_ = ui.newTTFLabel({
    		text="ยินดีด้วยค่ะ ท่านได้รับ",
    		color=cc.c3b(0xd9,0xaa,0x46),
    		size=32
    	})
    	:pos(0, height*0.5-36)
    	:addTo(self.mainContainer_)

    px = width * 0.5;
    py = height * 0.5;
    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :onButtonClicked(function()
            	nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                self:onClose()
            end)
            :pos(px - 18, py - 25)
            :addTo(self, 99)

	if #list == 1 then
		local item1 = self:createRewardItem(self.mainContainer_, list[1]);
	    item1:pos(0, 0)
	else
		local item1 = self:createRewardItem(self.mainContainer_, list[1]);
	    item1:pos(-width*0.25+10, 0)

	    local item2 = self:createRewardItem(self.mainContainer_, list[2]);
	    item2:pos(width*0.25-10, 0)
	end
end

function DailyMatchRewardPopup:createRewardItem(parent, info)
	local content = display.newNode()
					:addTo(parent);

	local lightBg1 = display.newSprite("#dailytasksMatch_lightBg.png")
						:addTo(content)
	local sz = lightBg1:getContentSize();
	lightBg1:pos(-sz.width*0.5, sz.height*0.5)

	local lightBg3 = display.newSprite("#dailytasksMatch_lightBg.png")
						:addTo(content)
	lightBg3:flipY(true)
	lightBg3:pos(-sz.width*0.5, -sz.height*0.5)

	local lightBg2 = display.newSprite("#dailytasksMatch_lightBg.png")
						:addTo(content)
	lightBg2:flipX(true)
	lightBg2:pos(sz.width*0.5-1, sz.height*0.5)
	
	local lightBg4 = display.newSprite("#dailytasksMatch_lightBg.png")
						:pos(0, 0)
						:addTo(content)
	lightBg4:flipX(true)
	lightBg4:flipY(true)
	lightBg4:pos(sz.width*0.5-1, -sz.height*0.5)


	local rewardIcon;
	local nameStr = ""
	if info.type == 1 then
		rewardIcon = display.newSprite(info.icon)
						:pos(0, 0)
						:addTo(content)
		nameStr = bm.LangUtil.getText("STORE", "TITLE_CHIP")
	elseif info.type == 2 then
		rewardIcon = display.newSprite(info.icon)
						:pos(0, 0)
						:addTo(content)
		nameStr = bm.LangUtil.getText("MATCH", "GAMECOUPON")
	end

	local numBg = display.newScale9Sprite("#dailytasksMatch_numBg.png", 0, 0, cc.size(180, 44), cc.rect(26, 22, 2, 1))
						:addTo(content)
	local nsz = numBg:getContentSize();
	local px, py = 0, -sz.height*1.0-nsz.height*0.5+8;
	numBg:pos(px, py)

	local txtNum = ui.newTTFLabel({
			text = nameStr.." x "..info.num,
			color = cc.c3b(0xfb,0xdd,0x59),
			size = 22
		})
		:pos(px, py)
		:addTo(content)

	return content;
end

function DailyMatchRewardPopup:show(callback)
    self.callback_ = callback;
    nk.PopupManager:addPopup(self)
    return self
end

function DailyMatchRewardPopup:onClose()
    self:close()
end

function DailyMatchRewardPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

return DailyMatchRewardPopup;