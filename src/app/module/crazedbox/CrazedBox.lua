--
-- Author: KevinYu
-- Date: 2015-11-02 18:00:30
-- 宝箱类

local logger = bm.Logger.new("CrazedBox")

local CrazedBox = class("CrazedBox", function()
    return display.newNode()
end)

local BG_W, BG_H = 183, 165 		--宝箱背景框宽高
local BUTTON_W, BUTTON_H = 183, 45 	--领取宝箱按钮宽高
local TIPS_W, TIPS_H = 178, 200 	--提示框宽高
local action = nil 					--倒计时动作

local SHOW_TIPS_TIME = 3 	--奖励说明持续时间
local SHOW_OPEN_BOX = 3 	--打开盒子状态持续时间
local COPPER_BOX = 1 		--铜宝箱
local SILVER_BOX = 2 		--银宝箱
local GLOD_BOX = 3 			--金宝箱

function CrazedBox:ctor(normalImage, openImage, lightImage, btnTitle, boxType, tipsText)
    self:setNodeEventEnabled(true)
	self.schedulerPool_ = bm.SchedulerPool.new()
	self.remainTime_ = 0 --倒计时，初始化默认可领取，会从服务器获取正确时间
	self.isShowTips_ = false --是否已经显示奖励内容
	self.titleList_ = btnTitle --按钮文本
	self.boxType_ = boxType --宝箱类型
	self.rewardKey_ = "" --领取奖励提示语key
	self.rewardStr_ = "" --领取奖励提示语
	self.price_ = 0 --打开宝箱的价格,要与服务器价格一致，客户端判断可以减少一次请求

	local tipsKey = ""
    if boxType == COPPER_BOX then
    	tipsKey = "COPPER_TIPS"
    	self.rewardKey_ = "GET_COPPER_REWARD"
    	self.act_ = "getLittleBox"

    	self:requestCopperReward_(1) --请求一次获取倒计时间
    elseif boxType == SILVER_BOX then
    	tipsKey = "SILVER_TIPS"
    	self.rewardKey_ = "GET_SILVER_REWARD"
    	self.act_ = "getMiddleBox"
    	self.price_ = 50000
    elseif boxType == GLOD_BOX then
    	tipsKey = "GLOD_TIPS"
    	self.rewardKey_ = "GET_GLOD_REWARD"
    	self.act_ = "getMaxBox"
    	self.price_ = 500000
    end
	
	local str = bm.LangUtil.getText("CRAZED", "NOT_OPEN_BOX_TIPS")
	self.notOpenBoxTips_ = str[boxType] --不能打开宝箱提示

 	cc.ui.UIPushButton.new({normal = "#crazed_box_bg.png"}, {scale9 = true})
 		:setButtonSize(BG_W, BG_H)
 		:onButtonClicked(function (event)
 			if self.isShowTips_ then
 				return
 			end

 			self:showTips_()
 		end)
 		:addTo(self)

 	--光
    self.light_ = display.newSprite(lightImage)
 		:hide()
 		:addTo(self) 

 	--没有领取奖励时的状态
 	self.normalBox_ = display.newSprite(normalImage)
 		:addTo(self)

 	--领取奖励时的状态
 	self.openBox_ = display.newSprite(openImage)
 		:hide()
 		:addTo(self)

 	self.btn_ = cc.ui.UIPushButton.new({normal = "#crazed_box_btn_normal.png", disabled="#crazed_box_btn_disable.png"}, {scale9 = true})
    self.btn_:align(display.TOP_CENTER, 0, -BG_H / 2)
    	:setButtonSize(BUTTON_W, BUTTON_H)
    	:setButtonLabel("normal", ui.newTTFLabel({
    		text = btnTitle.normal,
    		color = display.COLOR_WHITE,
    		size = 18}))
    	:setButtonLabel("disabled", ui.newTTFLabel({
    		text = btnTitle.disabled or btnTitle.normal, 
    		color = display.COLOR_WHITE,
    		size = 18}))
        :onButtonPressed(function(evt)
           	self.btn_:setColor(cc.c3b(0x69, 0x69, 0x69))
        end)
        :onButtonRelease(function ()
        	self.btn_:setColor(cc.c3b(0xff, 0xff, 0xff))
        end)
        :addTo(self)
    if boxType == COPPER_BOX then
    	self.btn_:onButtonClicked(handler(self, self.onCopperRewardClicked_))
    else
    	self.btn_:onButtonClicked(handler(self, self.onSilverOrGlodRewardClicked_))
    end

    self.tips_ = display.newScale9Sprite("#crazed_tips_bg.png", 0, 0, cc.size(TIPS_W, TIPS_H), cc.rect(40, 28, 1, 1))
    	:align(display.BOTTOM_CENTER, 0, 0)
    	:opacity(200)
    	:hide()
    	:addTo(self)

    local tipsStr = bm.LangUtil.getText("CRAZED", tipsKey, tipsText)
    ui.newTTFLabel({
			text = tipsStr, 
			color = cc.c3b(0, 0, 0),
			size = 16,
			align = ui.TEXT_ALIGN_LEFT,
			valign = ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(400, 200)})
		:align(display.LEFT_TOP, 5, TIPS_H - 10)
		:addTo(self.tips_)
end

--显示提示
function CrazedBox:showTips_()
	self.isShowTips_ = true
	self.tips_:show()
	self.schedulerPool_:delayCall(handler(self, self.hideTips_), SHOW_TIPS_TIME)
end

--隐藏提示
function CrazedBox:hideTips_()
	self.isShowTips_ = false
	self.tips_:hide()
end

--铜宝箱领取
function CrazedBox:onCopperRewardClicked_(event)
	if self.remainTime_ > 0 then
		nk.TopTipManager:showTopTip(self.notOpenBoxTips_)
		return
	end
	
	self:requestCopperReward_(2)
end

--铜宝箱领取请求
function CrazedBox:requestCopperReward_(click)
    if click == 2 then
        self:onOffEvent(true)
    end

    bm.HttpService.POST(
        {
            mod = "CrazyBox",
            act = self.act_,
            click = click --1.打开界面时请求 2.领取宝箱时请求 只有铜宝箱区分
         },
        function (data)
            local callData = json.decode(data)
            logger:debug("copper_reward:" .. data)
            if callData.code == 1 then	
            	if click == 2 then
					self.rewardStr_ = bm.LangUtil.getText("CRAZED", self.rewardKey_, callData.desc)
					self:setButtonEnabled_(false)
					self:getReward_()
                    -- 
                    self:playAnimation_(self.act_, callData);
				end
				self:showReceiveStatus_()		
			elseif callData.code == -1 then
				-- printInfo("铜宝箱每天限开一次，用户已开启过")
				self:setButtonEnabled_(false)
			elseif callData.code == -2 then
				-- printInfo("铜宝箱未开启，在线时间未满十五分钟，返回十五分钟倒计时剩余时间")
				self.remainTime_ = callData.rtime
				self:startCountDown_()
            end

            if callData.code ~= 1 then
                if click == 2 then
                    self:onOffEvent(false)
                end
            end	
        end,
        function (data)
            logger:debug("copper_reward:" .. data)
            if click == 2 then
                self:onOffEvent(false)
            end
        end)	
end

--银宝箱或金宝箱领取
function CrazedBox:onSilverOrGlodRewardClicked_(event)
	if nk.userData.money < self.price_ then
		nk.TopTipManager:showTopTip(self.notOpenBoxTips_)
		return
	end

    self:onOffEvent(true)
    bm.HttpService.POST(
        {
            mod = "CrazyBox",
            act = self.act_
         },
        function (data)
            local callData = json.decode(data)
            logger:debug(self.act_ .. "_reward:" .. data)
            if callData.code == 1 then	
				self.rewardStr_ = bm.LangUtil.getText("CRAZED", self.rewardKey_, callData.desc)
				self:getReward_()
				self:setButtonEnabled_(false)

				self.schedulerPool_:delayCall(function()
					self:setButtonEnabled_(true)
				end, SHOW_OPEN_BOX)
                -- 
                self:playAnimation_(self.act_, callData);
			elseif callData.code == -1 then
				printInfo("用户游戏币不够，无法开启")
				nk.TopTipManager:showTopTip(self.notOpenBoxTips_)
			elseif callData.code == -6 then
				printInfo("扣除用户游戏币失败")
				self.remainTime_ = callData.rtime
			elseif callData.code == -11 then
				printInfo("获取uid失败")
			elseif callData.code == -101 then
				printInfo("获取随机奖励失败")
            end

            if callData.code ~= 1 then
                self:onOffEvent(false)
            end
        end,
        function (data)
            logger:debug(self.act_ .. "_reward:" .. data)
            self:onOffEvent(false)
        end)		
end

--领取奖励按钮触摸开关
function CrazedBox:setButtonEnabled_(enabled)
	self.btn_:setButtonEnabled(enabled)
	return self
end

function CrazedBox:getReward_()
	nk.TopTipManager:showTopTip(self.rewardStr_)
	self:openBox()
end

--开始倒计时
function CrazedBox:startCountDown_()
	self:showTime_()
	action = self:schedule(function ()
        self:countFunc_()
    end, 1)
end

--倒计时计数
function CrazedBox:countFunc_()
	--printInfo("CrazedBox:countFunc_()")
    self.remainTime_ = self.remainTime_ - 1
    if self.remainTime_ <= 0 then
        self:showReceiveStatus_()
        return 
    end

    self:showTime_()
end

--显示时间
function CrazedBox:showTime_()
    local timeStr = (self.remainTime_ > 0 and bm.TimeUtil:getTimeString(self.remainTime_)) or ""
    self.btn_:setButtonLabelString("normal", self.titleList_.normal .. timeStr)
end

--显示可领取状态
function CrazedBox:showReceiveStatus_()
	if action then
        self:stopAction(action)
    end

    self.btn_:setButtonLabelString("normal", bm.LangUtil.getText("HALL", "OPEN_BOX"))
end

--打开宝箱
function CrazedBox:openBox()
	self.normalBox_:hide()
	self.openBox_:show()
	self.light_:show():rotateBy(SHOW_OPEN_BOX, 360)
	self.schedulerPool_:delayCall(function()
        self:closeBox();
    end, SHOW_OPEN_BOX)
end

--关闭宝箱
function CrazedBox:closeBox()
	self.normalBox_:show()
	self.openBox_:hide()
	self.light_:hide()
end

function CrazedBox:playAnimation_(act, retData)
    if retData and retData.code then
        local rect = self.openBox_:getParent():convertToWorldSpace(cc.p(self.openBox_:getPosition()));
        local num = retData.num;
        local itype;
        local scaleVal = 0.8;
        local isHddj = nil;
        -- retData.type = 1;
        retData.num = 10;
        -- type=1为游戏币，2为道具，3为比赛券,4为现金币,5为门票,6为黄金币
        if retData.type == 1 then
            itype = 1;
        elseif retData.type == 2 then
            itype = 8;
            scaleVal = 1;
        elseif retData.type == 3 then
            itype = 2;
            scaleVal = 0.5;
        elseif retData.type == 4 then
            itype = 3;
            isHddj = false;
            scaleVal = 0.9;
        elseif retData.type == 5 then
            local ptype = retData.ptype
            local num = 1; -- 门票数量数量
            local ticketValue = 0; -- 门票面值
            if ptype == 1000 then --7泰铢门票
                ticketValue = 7;
            elseif ptype == 1001 then --10泰铢门票
                ticketValue = 10;
            elseif ptype == 1002 then --20泰铢门票
                ticketValue = 20;
            elseif ptype == 1003 then --100泰铢门票
                ticketValue = 100;
            elseif ptype == 1004 then --300泰铢门票
                ticketValue = 300;
            end
            itype = 5;
            scaleVal = 0.5;
            nk.UserInfoChangeManager:playWheelFlyTicketAnimation(ticketValue, rect, itype, num, nil, scaleVal);
            return
        elseif retData.type == 6 then
            itype = 9
            scaleVal = 0.8
        end
        -- 
        if itype ~= 8 then
            nk.UserInfoChangeManager:playWheelFlyAnimationByType(itype, rect, num, scaleVal, true, isHddj)
        end
    end
end

function CrazedBox:onOffEvent(value)
    if value then
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
    else
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"}) 
    end
end

function CrazedBox:onCleanup()
    self.schedulerPool_:clearAll()
end

return CrazedBox