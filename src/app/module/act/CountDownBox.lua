--
-- Author: shanks
-- Date: 2014.09.09
-- ps:后台清数据：MOBILE_TREASURE_13892
-- 游戏玩牌倒计时奖励

local CountDownBox = class("CountDownBox", function()
        return display.newNode()
    end)

local RoomTaskPop = import("app.module.room.views.RoomTaskPopup")
local logger = bm.Logger.new("CountDownBox")

local action

function CountDownBox:ctor(ctx)
    self.ctx = ctx

    bm.HttpService.POST(
        {
            mod = "treasureBox",
            act = "get"
        },
        function (data)
            logger:debug("count_down_get:" .. data)
            local callData = json.decode(data)
            if callData.code == 0 then
                self.isFinished = callData.remainTime <= 0 and callData.rewardChip == "" --是否倒计时结束，为0
                self.remainTime = callData.remainTime --倒计时剩余时间
                self.reward = callData.rewardChip --奖励
                self.multiple = callData.multiple --倍数
                self:showFunc()
            end
        end,
        function (data)
            logger:debug("count_down_get:" .. data)
        end)
end

--创建倒计时，判断是否开始倒计时
function CountDownBox:showFunc()
    self.countStatus = false

    self:showStatus()

    self:bindDataObserver()

    -- 重连
    if self.ctx.model:isSelfInSeat() then
        self:sitDownFunc()
    end
end

--显示不到状态对应的UI
function CountDownBox:showStatus()
    if not self.countButton then
        self.rewardButton = cc.ui.UIPushButton.new({normal="#count_down_box_reward.png", pressed="#count_down_box_reward.png"})
            :onButtonClicked(handler(self, self.showRoomTask))
            :pos(-48, 122)
            :addTo(self)

        self.countButton = cc.ui.UIPushButton.new({normal="#count_down_box_normal.png", pressed="#count_down_box_normal.png"})
            :onButtonClicked(handler(self, self.showRoomTask))
            :pos(-48, 122)
            :addTo(self)

        -- self.multipleLabel = ui.newTTFLabel({text="", size=24, color=cc.c3b(0xff, 0x00, 0x00), align=ui.TEXT_ALIGN_CENTER})
        -- self.multipleLabel:pos(-30, 150)
        -- self.multipleLabel:rotation(-20)
        -- self.multipleLabel:addTo(self)

        self.multipleSprite = display.newSprite("countdown_x2.png")
        self.multipleSprite:pos(-30,150)
        self.multipleSprite:rotation(-20)
        self.multipleSprite:addTo(self)
        self.multipleSprite:hide()
    end

    self.rewardButton:hide()
    self.countButton:hide()

    if self.isFinished then
        logger:debug("status:finish")
        self:countDownStatus(false)
    elseif not self.isFinished and self.remainTime <= 0 then
        logger:debug("status:reward")
        self:countDownStatus(false)
    else
        logger:debug("status:count")
        self:countDownStatus(self.ctx.model:isSelfInSeat())
    end

    self:onNewRewardTask(self.hasNewRewardTask)

    self:updateBoxTask_()

    local multipleStr = (self.multiple and tonumber(self.multiple) > 1 and "x" .. tostring(self.multiple)) or ""
    -- self.multipleLabel:setString(multipleStr)
    if multipleStr ~= "" then
        self.multipleSprite:show()
    end
end

function CountDownBox:updateBoxTask_()
    bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.UPDATE_BOX_TASK, data = nil})
end

--倒计时状态
function CountDownBox:countDownStatus(status)
    if self.countStatus and not status then
        if action then
            self:stopAction(action)
        end
    end

    if not self.countStatus and status then
        action = self:schedule(function ()
            self:countFunc()
        end, 1)
    end

    self.countStatus = status
end

--倒计时计数
function CountDownBox:countFunc()
    self.remainTime = self.remainTime - 1
    if self.remainTime < 0 then
        self:showStatus()
    else
        self:updateBoxTask_()
    end
end

function CountDownBox:showRoomTask()
    local popup = RoomTaskPop.new()
    popup:setCountDownBox(self)
    popup:showPanel()
end

--获取奖励
function CountDownBox:getReward()
    nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_REWARD)
    bm.HttpService.POST(
        {
            mod = "treasureBox" ,
            act = "reward"
         },
        function (data)
            local callData = json.decode(data)
            logger:debug("count_down_reward:" .. data)

            if callData.code == 2 then
                local multipleStr = (self.multiple and tonumber(self.multiple) > 1 and "x" .. tostring(self.multiple)) or ""
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "REWARD", tostring(self.reward) .. multipleStr))

                self.isFinished = callData.nextRemainTime <= 0 and callData.nextRewardChip == ""
                self.remainTime = callData.nextRemainTime
                self.multiple = callData.multiple
                self.reward = callData.nextRewardChip

                self:showStatus()
            elseif callData.code == 0 then
                self.remainTime = callData.nextRemainTime
                self.multiple = callData.multiple
                self:showStatus()
            end

        end,
        function (data)
            logger:debug("count_down_reward:" .. data)
        end)
end

--提示再玩多久，可以获得什么样的奖励；坐下才开始计时
function CountDownBox:promptFunc()
    nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_NORMAL)
    if self.ctx.model:isSelfInSeat() then
        local multipleStr = (self.multiple and tonumber(self.multiple) > 1 and "x" .. tostring(self.multiple)) or ""
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "NEEDTIME",
            bm.TimeUtil:getTimeMinuteString(self.remainTime), bm.TimeUtil:getTimeSecondString(self.remainTime), tostring(self.reward) .. multipleStr))
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "SITDOWN"))
    end
end

function CountDownBox:onNewRewardTask(hasNewRewardTask)
    self.hasNewRewardTask = hasNewRewardTask
    if hasNewRewardTask or (not self.isFinished and self.remainTime <= 0) then
        self.rewardButton:show()
        self.countButton:hide()
    else
        self.rewardButton:hide()
        self.countButton:show()
    end
end

function CountDownBox:bindDataObserver()
    self.onDataObserver = bm.DataProxy:addDataObserver(nk.dataKeys.SIT_OR_STAND, handler(self, self.sitStatusFunc))
    self.onNewRewardTaskObserver = bm.DataProxy:addDataObserver(nk.dataKeys.NEW_REWARD_TASK, handler(self, self.onNewRewardTask))
end

function CountDownBox:unbindDataObserver()
    bm.DataProxy:removeDataObserver(nk.dataKeys.SIT_OR_STAND, self.onDataObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.NEW_REWARD_TASK, self.onNewRewardTaskObserver)
end

function CountDownBox:sitStatusFunc(isSit)
    if isSit then
        self:sitDownFunc()
    else
        self:standUpFunc()
    end
end

--坐下，发送请求，开始计时
function CountDownBox:sitDownFunc()
    bm.HttpService.POST(
        {
            mod = "treasureBox" ,
            act = "sit"
         },
        function (data)
            local callData = json.decode(data)
            logger:debug("count_down_sit:" .. data)
            if callData.code == 0 then
                self:showStatus()
            end
        end,
        function (data)
            logger:debug("count_down_sit:" .. data)
        end)
end

--站起，停止倒计时
function CountDownBox:standUpFunc()
    self:countDownStatus(false)

    bm.HttpService.POST(
        {
            mod = "treasureBox" ,
            act = "stand"
         },
        function (data)
            local callData = json.decode(data)
            logger:debug("count_down_stand:" .. data)
            if callData.code == 0 then

            end
        end,
        function (data)
            logger:debug("count_down_stand:" .. data)
        end)
end

function CountDownBox:release()
    self:unbindDataObserver()

    if action then
        self:stopAction(action)
    end
end

return CountDownBox
