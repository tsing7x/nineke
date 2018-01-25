--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-08-09 15:05:07
--
local WIDTH = 420
local HEIGHT = 500
local logger = bm.Logger.new("RegisterRewardPopup")
local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")

local RegisterRewardPopup = class("RegisterRewardPopup", function()
	return display.newNode()
end)

function RegisterRewardPopup:ctor()
	self:init_()
end

function RegisterRewardPopup:init_()
	self.effect_ = dragonbones.new({
		skeleton="dragonbones/fla_xinshoulb/skeleton.xml", 
        texture="dragonbones/fla_xinshoulb/texture.xml",
        skeletonName="fla_xinshoulb",
        armatureName="fla_xinshoulb",
	})
	:addTo(self)

    self.effect_:registerAnimationEventHandler(handler(self, self.onMovementHandler_))

	local btnNode = display.newNode()
    self.rewardButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
    	:setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("COMMON", "GET_REWARD"), size=32, color=styles.FONT_COLOR.LIGHT_TEXT, align=ui.TEXT_ALIGN_CENTER}))
        :setButtonSize(183, 55)
        :addTo(btnNode)

    local lblNode = display.newNode()
    self.rewardDescLabel_ = ui.newTTFLabel({
    	text = bm.LangUtil.getText("HALL", "TUTORIAL_REGISTERREWARD_MSG", 40000), 
    	color = cc.c3b(0x64, 0x10, 0x10), 
    	size = 20, 
    	dimensions=cc.size(335, 0),
    	align = ui.TEXT_ALIGN_CENTER,
    })
    :addTo(lblNode)
    -- 
    -- local anNiuBoneNode = self.effect_:getArmature():getBone("xinshoulb_AnNiu")
    -- local anNiuView = dragonBones.CCDBNode:new(btnNode)
    -- anNiuBoneNode:setDisplay(anNiuView)
    local anNiuBoneNode = self.effect_:getArmature():getCCSlot("xinshoulb_AnNiu")
    anNiuBoneNode:getCCDisplay():addChild(btnNode)

    -- local wenBenBoneNode = self.effect_:getArmature():getBone("xinshoulb_WENBEN")
    -- local wenBenView = dragonBones.CCDBNode:new(lblNode)
    -- wenBenBoneNode:setDisplay(wenBenView)

    local wenBenBoneNode = self.effect_:getArmature():getCCSlot("xinshoulb_WENBEN")
    wenBenBoneNode:getCCDisplay():addChild(lblNode)
    
    self.effect_:getAnimation():gotoAndPlay("born")

	self:loadData()
end

function RegisterRewardPopup:onMovementHandler_(evt)
	if evt.type == 7 then--7 == "complete"
		if evt.animationName == "born" then
			self.effect_:getAnimation():gotoAndPlay("stand")
			self:onRewardDoing()
			self.rewardButton_:onButtonClicked(buttontHandler(self, self.onRewardButtonHandler))
		elseif evt.animationName == "stand" then

		elseif evt.animationName == "end" then
			self:hide_()
		end
	end
end

function RegisterRewardPopup:show()

end

function RegisterRewardPopup:onShowed()
	return self
end

function RegisterRewardPopup:onRewardButtonHandler()
	self.effect_:getAnimation():gotoAndPlay("end")
	if self.closeCallback_ then
        self.closeCallback_()
        self.closeCallback_ = nil
    end
end

function RegisterRewardPopup:onRewardDoing()
    if not self.juhua_ then
        self.juhua_ = nk.ui.Juhua.new():pos(0, 0):addTo(self)
    end
    -- 上报新手领奖点击
    nk.reportClickEvent(1)

    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
    bm.HttpService.POST(
        { mod = "registerReward",
          act = "reward"
        },
        function (data)
            logger:debug("registerReward reward", data)
            local callData = json.decode(data)
            if callData.ret ~= nil and callData.ret == 2 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "REWARD_SUCCEED"))
                nk.userData.money = nk.userData.money + callData.chips
                self.animation_ = CommonRewardChipAnimation.new(function()
                    nk.UserInfoChangeManager:manualFlyAnimt(1, callData.chips)
                end):addTo(display.getRunningScene(), 9999):pos(display.cx, display.cy)
                self:performWithDelay(function ()
                    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
                end, 0.5)
                nk.SoundManager:playSound(nk.SoundManager.CHIP_DROP)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "REWARD_FAIL"))
                bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
            end
            if self.juhua_ then
                self.juhua_:removeFromParent()
                self.juhua_ = nil
            end
        end,
        function (data)
            if self.juhua_ then
                self.juhua_:removeFromParent()
                self.juhua_ = nil
                self:hide_()
            end
            bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
        end)
end

function RegisterRewardPopup:show()
	
end

function RegisterRewardPopup:setCloseCallback(closeCallback)
	self.closeCallback_ = closeCallback
    return self
end

function RegisterRewardPopup:hide_()
    -- 标记玩家已经领取新手注册礼包
    nk.userData.lastloginRewardStep = 1
    nk.userData.loginRewardStep = 0

    nk.PopupManager:removePopup(self)
    if self.closeCallback_ then
        self.closeCallback_()
        self.closeCallback_ = nil
    end

    dragonbones.unloadData({
		skeleton="dragonbones/fla_xinshoulb/skeleton.xml", 
        texture="dragonbones/fla_xinshoulb/texture.xml"
    })

    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
end

-- 清除进度圈
function RegisterRewardPopup:clearJuhua()
    if self.juhua_ then
        self.juhua_:removeFromParent()
        self.juhua_ = nil
    end
end

function RegisterRewardPopup:loadData()
    bm.HttpService.POST(
        {
            mod = "registerReward",
            act = "text"
        },
        function (data)
            local callData = json.decode(data)

            if callData.ret == 0 then
                self.rewardDescLabel_:setString(bm.LangUtil.getText("HALL", "TUTORIAL_REGISTERREWARD_MSG", callData["1"][1]))
            end
        end,

        function (data) self:clearJuhua() end)
end

return RegisterRewardPopup