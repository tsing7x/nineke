--
-- Author: hlf
-- Date: 2015-11-04 11:47:15
-- 比赛场每日任务全部任务都完成的提示界面

local WIDTH = 520
local HEIGHT = 320
local BubbleButton = import("boomegg.ui.BubbleButton")
local DailyMatchEndPopup = class("DailyMatchEndPopup", function()
	return display.newNode()
end)

function DailyMatchEndPopup:ctor() 
	local bgSz = cc.size(WIDTH, HEIGHT)
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(bgSz.width, bgSz.height)
    self.mainContainer_:setTouchEnabled(true)
    self.mainContainer_:setTouchSwallowEnabled(true)

	self.bg_ = display.newScale9Sprite("#dailytasksMatch_dialog_bg2.png", 0, 0, cc.size(bgSz.width, bgSz.height), cc.rect(24, 162, 2, 1))
		:addTo(self.mainContainer_)
	local dw,dh = bgSz.width-50, bgSz.height-100
	self.tbg_ = display.newScale9Sprite("#user-info-tab-background.png", 0, 0, cc.size(dw,dh))
		:pos(0, -15)
		:addTo(self.mainContainer_)

	self.btnBg_ = display.newScale9Sprite("#user-info-tab-background.png", 0, 0, cc.size(170,50))
		:addTo(self.mainContainer_)
	
	self.txt1_ = display.newSprite("#dailytasksMatch_txt1.png")
		:addTo(self.mainContainer_)
	local fsz = self.txt1_:getContentSize()
	local px, py = 0, dh*0.5 - fsz.height*0.5 - 15 - 10 
	self.txt1_:pos(px,py)
	py = py-fsz.height*1.0
	self.txt2_ = display.newSprite("#dailytasksMatch_txt2.png")
		:pos(px, py)
		:addTo(self.mainContainer_)

	fsz = self.txt2_:getContentSize()
	py = -bgSz.height*0.5 + 70

	self.btnBg_:pos(px, py+2)
	self.sendButton_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png",pressed = "#common_green_btn_down.png"},{scale9 = true})
	    :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("WHEEL", "DIALOG_KNOWN"),size = 28,color = cc.c3b(0xd6, 0xff, 0xef),align = ui.TEXT_ALIGN_CENTER}))
	    :setButtonSize(160, 42)
	    :pos(px, py)
	    :onButtonClicked(buttontHandler(self, self.onClose))
	    :addTo(self.mainContainer_)

    self.close_x_ = bgSz.width * 0.5 - 21
    self.close_y_ = bgSz.height * 0.5 - 28
    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
        :pos(self.close_x_, self.close_y_)
        :onButtonClicked(function()
            self:onClose()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        end)
        :addTo(self, 1000)
end

function DailyMatchEndPopup:show(callback)
    self.callback_ = callback
    nk.PopupManager:addPopup(self)
    return self
end

function DailyMatchEndPopup:onClose()
    self:close()
end

function DailyMatchEndPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

return DailyMatchEndPopup
