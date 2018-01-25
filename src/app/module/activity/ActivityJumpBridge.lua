--
-- Author: Jonah0608@gmail.com
-- Date: 2016-01-07 09:14:52
--

local StorePopup          = import("app.module.newstore.StorePopup")
local InvitePopup         = import("app.module.friend.InvitePopup")
local FriendPopup         = import("app.module.friend.FriendPopup")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local DailyTasksPopup     = import("app.module.dailytasks.DailyTasksPopup")
local RankingPopup        = import("app.module.newranking.RankingPopup")
local UserInfoPopup       = import("app.module.userInfo.UserInfoPopup")
local ExchangeCodePop     = import("app.module.exchangecode.ExchangeCode")

local ByActivityJumpManager = class("ByActivityJumpManager")

function ByActivityJumpManager:ctor()
end

function ByActivityJumpManager:doJump(jumpInfo)
    if not jumpInfo then
        return
    end
    local currentViewType = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
    local runningScene = nk.runningScene

    local getJumpSceneByTargetInst = {
        ["store"] = function()
            if jumpInfo.desc == "online" then
                StorePopup.new():showPanel()
            elseif jumpInfo.desc == "exchange" then
                local ScoreMarketView = import("app.module.scoremarket.ScoreMarketViewExt");
                ScoreMarketView.load(nil, nil)
            elseif jumpInfo.desc == "gift" then
                local GiftShopPopUp = import("app.module.gift.GiftShopPopup")
                GiftShopPopUp.new():show(false,nk.userData.uid)
            else
                StorePopup.new():showPanel()
            end
        end,
        ["room"] = function()
            if runningScene.name == "HallScene" then
                if jumpInfo.desc == "game" then
                    runningScene.controller_:getEnterRoomData(nil, true)
                elseif jumpInfo.desc == "cash" then
                elseif jumpInfo.desc == "match" then
                else
                    self:gotoGivenRoomByIns(runningScene,jumpInfo.desc)
                end
            end
        end,
        ["invite"] = function()
            InvitePopup.new():show()
        end,
        ["friend"] = function()
            FriendPopup.new():show()
        end,
        ["feedback"] = function()
            SettingAndHelpPopup.new(false,true,1):show()
        end,
        ["task"] = function()
            DailyTasksPopup.new():show()
        end,
        ["rank"] = function()
            RankingPopup.new():show()
        end,
        ["info"] = function()
            UserInfoPopup.new():show(false)
        end,
        ["exrechargecode"] = function()
            ExchangeCodePop.new():show()            
        end,
        ["propstore"] = function()
            StorePopup.new():showPanel()
        end,
        ["shareFB"] = function()
            nk.Facebook:shareFeed(jumpInfo.desc, function(success, result)
                dump(result, "nk.Facebook:shareFeed.feed :" .. jumpInfo.desc .. "[success : " .. tostring(success) .. "] :==================")
            end)
        end,
        ["lobby"] = function()
            if jumpInfo.desc == "match" then
                if runningScene.name == "HallScene" then
                    if currentViewType ~= 5 then
                        runningScene.controller_:onEnterMatch()
                    end
                end
            elseif jumpInfo.desc == "normal" then
                if runningScene.name == "HallScene" then
                    if currentViewType ~= 3 then
                        runningScene.controller_:showChooseRoomView(3)
                    end
                end
            elseif jumpInfo.desc == "prohall" then
                if runningScene.name == "HallScene" then
                    if currentViewType ~= 4 then
                        runningScene.controller_:showChooseRoomView(4)
                    end
                end
            elseif jumpInfo.desc == "coinroom" then
                if runningScene.name == "HallScene" then
                    if currentViewType ~= 5 then
                        runningScene.controller_:onEnterMatch()
                    end
                end
            end
        end,
        ["buy"] = function()
        end,
        ["link"] = function()
            device.openURL(tostring(jumpInfo.desc) or "")
            --local openURL = import("app.module.openURL.OpenURL")
            --openURL.new(tostring(jumpInfo.desc) or ""):show()
        end,
        ["popup"] = function()
            if jumpInfo.desc == "mix" then
                nk.MixCurrentManager:openMixListPopup()
            elseif jumpInfo.desc == "friend" then
                FriendPopup.new():show()
            elseif jumpInfo.desc == "rank" then
                RankingPopup.new():show()
            elseif jumpInfo.desc == "openbox" then
                local CrazedBoxPopup = import("app.module.crazedbox.CrazedBoxPopup")
                display.addSpriteFrames("crazed_box_texture.plist", "crazed_box_texture.png",function()
                        CrazedBoxPopup.new():show()
                    end)
            elseif jumpInfo.desc == "lottery" then
                local LotteryPopup = import("app.module.lottery.LotteryPopup")
                LotteryPopup.new():show()
            elseif jumpInfo.desc == "wheel" then
                local LuckWheelFreePopup = import("app.module.luckturn.LuckWheelFreePopup")
                LuckWheelFreePopup.load(nil, nil)
            else
                dump("Wrong Desc For Target:'popup'.")
            end
        end
    }

    if getJumpSceneByTargetInst[jumpInfo.target] then
        getJumpSceneByTargetInst[jumpInfo.target]()
    end
end

function ByActivityJumpManager:gotoGivenRoomByIns(runningScene,desc)
    local roomLevelRangeTable = string.split(desc,"-")
    if nk.userData.money / 10 > tonumber(roomLevelRangeTable[2]) then
        runningScene.controller_:getEnterRoomData({sb = roomLevelRangeTable[2]}, true)
    else
        runningScene.controller_:getEnterRoomData({sb = roomLevelRangeTable[1]}, true)
    end 
end

return ByActivityJumpManager