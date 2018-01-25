--
-- Author: KevinYu
-- Date: 2017-03-02 18:13:22
-- 彩票类型选择视图

local LotteryPopup        = import("app.module.lottery.LotteryPopup")
local FootballQuizPopup   = import("app.module.football.FootballQuizPopup")

local ChooseLotteryView = class("ChooseLotteryView",function()
    return display.newNode()
end)

function ChooseLotteryView:ctor()
	local w, h = display.width, display.height

 	cc.ui.UIPushButton.new({normal = "lottery_quiz_button.png"}, {scale9 = true})
        :onButtonClicked(buttontHandler(self, self.onLotteryQuizClick_))
        :pos(-200, 0)
        :addTo(self)

    cc.ui.UIPushButton.new({normal = "football_quiz_button.png"}, {scale9 = true})
        :onButtonClicked(buttontHandler(self, self.onFootballQuizClick_))
        :pos(200, 0)
        :addTo(self)
end

function ChooseLotteryView:onLotteryQuizClick_()
	LotteryPopup.new():show()
	self:hidePanel_()
end

function ChooseLotteryView:onFootballQuizClick_()
	display.addSpriteFrames("football_quiz_texture.plist", "football_quiz_texture.png", function()
        FootballQuizPopup.new():showPanel()
    end)
    
	self:hidePanel_()
end

function ChooseLotteryView:showPanel()
	nk.PopupManager:addPopup(self, true, true, true, true)
end

function ChooseLotteryView:hidePanel_()
	nk.PopupManager:removePopup(self)
end

return ChooseLotteryView