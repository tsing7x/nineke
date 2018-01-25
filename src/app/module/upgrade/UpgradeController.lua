--
-- Author: viking@boomegg.com
-- Date: 2014-12-08 15:02:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local UpgradeController = class("UpgradeController")

function UpgradeController:ctor(view_)
    self.view_ = view_
    self.getLevelRewardRetryTimes_ = 3
end

function UpgradeController:getReward()
    -- 领奖
    self.rewardHttpId = bm.HttpService.POST(
        {
            mod = "level", 
            act = "levelUpReward",
            level = nk.userData.nextRwdLevel
        }, 
        function (data)
            local retData = json.decode(data)
            local data = retData.data
            if retData.ret == 0 and data.prizeText ~= "" then
                nk.userData.nextRwdLevel = data.nextRwdLevel
                self.view_:afterGetReward(data.prizeText)
            else
                nk.userData.nextRwdLevel = 0
            end
            self.view_:setLoading(false)
        end, 
        function ()
            if self.getLevelRewardRetryTimes_ > 0 then
                self:getReward()
                self.getLevelRewardRetryTimes_ = self.getLevelRewardRetryTimes_ - 1
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_LEVEL_UP_REWARD"))
                self.view_:setLoading(false)
            end
        end
    )
end

function UpgradeController:dispose()
    if self.rewardHttpId then
        bm.HttpService.CANCEL(self.rewardHttpId)
    end
end

return UpgradeController
