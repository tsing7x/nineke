--
-- Author: viking@boomegg.com
-- Date: 2014-09-12 10:27:04
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 比赛奖励弹窗

local ScoreExchangePopup = import("app.module.scoremarket.ScoreExchangePopup")
local ScoreExchangeE2PPopup = import("app.module.scoremarket.ScoreExchangeE2PPopup")
local ScoreMarketController = import("app.module.scoremarket.ScoreMarketController")
local ScoreExchangeSuccessPopup = import("app.module.scoremarket.ScoreExchangeSuccessPopup")
local ScoreAddressPopup = import("app.module.scoremarket.ScoreAddressPopup")
local PushMsgPopup        = import("app.module.playerback.PushMsgPopup")

local MatchRewardItem = import(".MatchRewardItem")
local LoadGiftControl = import("app.module.gift.LoadGiftControl")
local AVATAR_TAG = 101

local MatchRewardPopup = class("MatchRewardPopup", function()
    return display.newNode()
end)

MatchRewardPopup.WIDTH = 636
MatchRewardPopup.HEIGHT = 448

function MatchRewardPopup:ctor(rewardData,matchData, openlist)
    self.controller_ = ScoreMarketController.new(self)
    self.rewardData_ = rewardData
    self.matchData_ = matchData
    self.openList_ = openlist
    self:setNodeEventEnabled(true)
    display.addSpriteFrames("matchreward.plist", "matchreward.png")
    self:setupView()
    self:setLoading(true)
    self:updateView1()
end

function MatchRewardPopup:onCleanup()
    self.rewardData_ = nil
    self.matchData_ = nil
    self:setLoading(false)
    display.removeSpriteFramesWithFile("matchreward.plist", "matchreward.png")
    nk.ImageLoader:cancelJobByLoaderId(self.awardImageLoaderId_)

    bm.EventCenter:dispatchEvent({name = nk.eventNames.MATCH_REWARDPOPUP_END})
end

function MatchRewardPopup:setupView()
    local width, height = MatchRewardPopup.WIDTH, MatchRewardPopup.HEIGHT
    self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height) -- 截取标题
    height = height - 20
    self.background_ = display.newScale9Sprite("#matchreward_content_bg1.png", 0, 0, cc.size(width, height)):addTo(self.mainContainer_)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    --顶部
    local titleMarginTop = 70
    local titleHeight = 65
    local titleIcon = display.newSprite("#matchreward_title_icon.png"):addTo(self.mainContainer_)
    titleIcon:pos(0, height/2 - titleIcon:getContentSize().height/2 + titleMarginTop)

    --内容
    local container = display.newNode():addTo(self.mainContainer_)
    local bottomMargin = 15
    local contentPadding = 12
    local contentWidth = width - contentPadding * 2
    local contentHeight = height - titleHeight - bottomMargin

    --内容
    self.contentBg_ = display.newNode()
        :addTo(container)
        :pos(-MatchRewardPopup.WIDTH*0.5, -MatchRewardPopup.HEIGHT*0.5)
        :size(MatchRewardPopup.WIDTH, MatchRewardPopup.HEIGHT)
        :hide()

    --关闭按钮
    local closeBtnMarginTop = 60
    local closeBtnMarginRight = 0
    local closeBtnWidth = 60
    local closeBtnHeight = 60
    self.coloseBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed = "#panel_black_close_btn_down.png"})
        :addTo(self.mainContainer_)
        :pos(width/2-15, height/2-15)
        :onButtonClicked(function()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            self:onClose()
        end)
end

function MatchRewardPopup:isChampion()
    if self.rewardData_ and self.rewardData_.ranking == 1 or self.rewardData_.ranking == 2 then
        return true
    end
    return false
end
--[[
    awardData:{
        rank:1
        allNum:10
        giftId:1000
        num:1
        history:10
    }
--]]

function MatchRewardPopup:isChampion1()
    -- if self.rewardData_ and self.rewardData_.ranking == 1 then
    --     return true
    -- end
    return false
end

function MatchRewardPopup:updateView1()
    self:setLoading(false)
    self.coloseBtn_:setVisible(false)
    self.contentBg_:setVisible(true)
    local width, height = MatchRewardPopup.WIDTH, MatchRewardPopup.HEIGHT - 20

    local titleMarginTop = 15
    local titleHeight = 65
    --内容
    local container = display.newNode():addTo(self.mainContainer_)

    local bottomMargin = 15
    local contentPadding = 12
    local contentWidth = width - contentPadding * 2
    local contentHeight = height - titleHeight - bottomMargin

    local contentBgSize = self.contentBg_:getContentSize()
    -- line线
    local line = display.newScale9Sprite("#matchreward_middle_line.png"):addTo(self.contentBg_):size(contentWidth-50,2)
    local lineSize = line:getContentSize()
    line:pos(contentBgSize.width/2-3,contentBgSize.height/2+38)
    self.line_ = line
    
    local offY = 70
    local buttonWidth,buttonHeight = 160,55

    --返回按钮
    self.backBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"}, {scale9 = true})
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("MATCH","AWARDDLGBACK"), color = display.COLOR_WHITE}))
        :setButtonSize(buttonWidth, buttonHeight)
        :pos(-195-3,-148)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onClickBackHandler_))

    --分享按钮
    local txt = bm.LangUtil.getText("MATCH", "AWARDDLGSHARE")
    if self:isChampion1() then
        txt = bm.LangUtil.getText("PUSHMSG", "PUSH_MATCH")
    end
    self.shareBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
        :setButtonLabel(cc.ui.UILabel.new({text = txt, color = display.COLOR_WHITE}))
        :setButtonSize(buttonWidth, buttonHeight)
        :pos(195-3,-148)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, function(...)
            if self:isChampion1() then
                self:showPushMsgPopup()
                return
            end
            if nk.userData and nk.userData.openSharePhoto==1 then
                self:share() -- 分享照片
            else
                self:share1_() -- 分享Feed
            end
            if device.platform == "android" or device.platform == "ios" then
                cc.analytics:doCommand{command = "event",
                    args = {eventId = "matchAward_dialog_share"}, label = "user matchAward_dialog_share"}
            end
        end))

    --再来按钮
    self.oneMoreBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("MATCH","AWARDDLGONEMORE"), color = display.COLOR_WHITE}))
        :setButtonSize(buttonWidth, buttonHeight)
        :pos(0-3,-148)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, function(...)
            self:oneMore()
            if device.platform == "android" or device.platform == "ios" then
                cc.analytics:doCommand{command = "event",
                    args = {eventId = "matchAward_dialog_oneMore"}, label = "user matchAward_dialog_oneMore"}
            end
        end))
    local huntStr = ""
    if self.rewardData_.hunt_num and self.rewardData_.hunt_gcoin then
        if tonumber(self.rewardData_.hunt_gcoin)>0 then
            huntStr = bm.LangUtil.getText("MATCH", "AWARDHUNT",self.rewardData_.hunt_num,self.rewardData_.hunt_gcoin)
        end
    end

    -- 结果信息
    local reusltStr = ""
    if self.rewardData_ and self.rewardData_.historyRank then
        reusltStr = bm.LangUtil.getText("MATCH", "AWARDDLGDESC2",nk.userData.nick,self.matchData_.name,
        self.rewardData_.ranking,self.rewardData_.ranking,self.rewardData_.totalCount,self.rewardData_.historyRank,huntStr,bm.TimeUtil:getTimeStampString(tonumber(self.rewardData_.end_time),"-"))
    else
        reusltStr = bm.LangUtil.getText("MATCH", "AWARDDLGDESC",nk.userData.nick,self.matchData_.name,
        self.rewardData_.ranking,self.rewardData_.ranking,self.rewardData_.totalCount,huntStr,bm.TimeUtil:getTimeStampString(tonumber(self.rewardData_.end_time),"-"))
    end
    self.result_ = ui.newTTFLabel({text=reusltStr, size=24, color=cc.c3b(0x6b, 0x54, 0x2a), align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_TOP,dimensions=cc.size(contentWidth-100, 400)})
        :align(display.TOP_LEFT)
        :addTo(self.contentBg_)
        :pos(55-3,390)

    if nk.config.SONGKRAN_ACTIVITY_ENABLED then
        if tonumber(self.matchData_.id) ~= 11 and tonumber(self.matchData_.id) ~= 51 then
            self.result_:pos(52, 400)
            self.result_:setSystemFontSize(22)
            self.songkran_text = ui.newTTFLabel({text=bm.LangUtil.getText("SONGKRAN_ACT", "CARD2_FINISH_TIPS"), size=18, color=cc.c3b(0xfb, 0x54, 0x2a), align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_TOP,dimensions=cc.size(contentWidth-100, 400)})
                :align(display.TOP_LEFT)
                :addTo(self.contentBg_)
                :pos(55,286)
        end
    end

    -- 奖励
    self.awardNode_ = display.newNode():addTo(self.contentBg_)
        :pos(contentBgSize.width/2,contentBgSize.height/2)

    -- 奖励头
    self.awardTitle_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("MATCH", "AWARDDLGWORD")..'', 
            size=22, 
            color=cc.c3b(0x6b, 0x54, 0x2a), 
            align = ui.TEXT_ALIGN_CENTER,
        })
        :addTo(self.awardNode_)
        :align(display.BOTTOM_LEFT)
    local sz = self.awardTitle_:getContentSize()
    self.awardTitle_:pos(-10-sz.width*0.5, 2)
    self.awardTitle_:hide()
    
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.renderRewards_))
end

function MatchRewardPopup:renderRewards_()
    local contentBgSize = self.contentBg_:getContentSize()

    -- 奖励详细信息
    local item
    local cfgs = {}
    local rewardCfgs = {}
    if self.rewardData_ and self.rewardData_.real then
        if not self.rewardData_.real.name then
            self.rewardData_.real.name = self.rewardData_.real.name or ""
        end
        item={}
        item.num = 1;
        item.name = self.rewardData_.real.name;
        item.image = nk.userData.cdn..""..self.rewardData_.real.img;
        item.realdata = self.rewardData_.real;
        table.insert(rewardCfgs, #rewardCfgs+1, item)
    end

    -- 实物2
    if self.rewardData_ and self.rewardData_.real1 then
        item={}
        item.num = 1
        item.name = self.rewardData_.real1.name
        item.image = nk.userData.cdn..""..self.rewardData_.real1.img
        item.realdata = self.rewardData_.real1
        table.insert(rewardCfgs, #rewardCfgs+1, item)
    end

    -- 现金币
    if self.rewardData_.tools and self.rewardData_.tools.score then
        item={}
        item.num = self.rewardData_.tools.score
        item.name = bm.LangUtil.getText("MATCH", "SCORE")
        item.image = "match_score.png"
        table.insert(rewardCfgs, #rewardCfgs+1, item)
    end

    -- 筹码
    if self.rewardData_.chips and tonumber(self.rewardData_.chips)>0 then
        item={}
        item.num = self.rewardData_.chips;
        item.name = bm.LangUtil.getText("MATCH", "MONEY");
        item.image = "match_chip.png";
        table.insert(rewardCfgs, #rewardCfgs+1, item)
    end

    -- 比赛券
    if self.rewardData_.tools and self.rewardData_.tools.gameCoupon then
        item={}
        item.num = self.rewardData_.tools.gameCoupon
        item.name = bm.LangUtil.getText("MATCH", "GAMECOUPON")
        item.image = "match_gamecoupon.png"
        table.insert(rewardCfgs, #rewardCfgs+1, item)
    end
    -- 金券
    if self.rewardData_.tools and self.rewardData_.tools.goldCoupon then
        item={}
        item.num = self.rewardData_.tools.goldCoupon
        item.name = bm.LangUtil.getText("MATCH", "GOLDCOUPON")
        item.image = "match_goldcoupon.png"
        table.insert(rewardCfgs, #rewardCfgs+1, item)
    end

    -- 黄金币
    if self.rewardData_.gcoins and tonumber(self.rewardData_.gcoins)>0 then
        item={}
        item.num = self.rewardData_.gcoins
        item.name = bm.LangUtil.getText("MATCH", "GOLDCOIN")
        item.image = "match_gcoins.png"
        table.insert(rewardCfgs, #rewardCfgs+1, item)
    end

    -- 奖杯
    if self.rewardData_ and self.rewardData_.giftId and tonumber(self.rewardData_.giftId)>0 then
        local cupUrl
        local giftId = self.rewardData_.giftId
        if url and string.len(url) > 5 then
            cupUrl = giftId
        else
            if giftId == 1049 then
                cupUrl = "#match_cup1.png"
            elseif giftId == 1048 then
                cupUrl = "#match_cup2.png"
            elseif giftId == 1047 then
                cupUrl = "#match_cup3.png"
            end
        end

        item={}
        item.num = 1
        item.name = bm.LangUtil.getText("MATCH", "REWARD_CUP_TIPS")
        item.image = cupUrl
        table.insert(rewardCfgs, #rewardCfgs+1, item)
    end

    local LIST_WIDTH = 550
    local LIST_HEIGHT = 154
    self.rewardList_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT*1),
                direction=bm.ui.ListView.DIRECTION_HORIZONTAL
            },
            MatchRewardItem
        )
        :pos(0-3, -LIST_HEIGHT*0.5 + 40)
        :addTo(self.awardNode_)
    self.rewardList_:setNotHide(true)
    self.rewardList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

    self.rewardList_:setData(rewardCfgs)
    self.rewardCfgs_ = rewardCfgs

    -- 没有奖励
    if #self.rewardCfgs_==0 then
        self.awardNode_:setVisible(false)
        self.line_:setVisible(false)
        self.result_:setPositionY(350)
        if self.songkran_text then
            self.songkran_text:setPositionY(200)
        end
    end
end

function MatchRewardPopup:onItemEvent_(evt)
    local evtData = evt.data
    if evtData and evtData.realdata then
        local real = evtData.realdata
        if not real.image then
            real.image = evtData.image
        end
        self:onProRealEntity(real)
    end
end
function MatchRewardPopup:firstShowEntity()
    if self.rewardData_.real then
        local real = self.rewardData_.real
        if not real.image then
            real.image = nk.userData.cdn..""..self.rewardData_.real.img
        end
        self:onProRealEntity(real)
    end
end
function MatchRewardPopup:onProRealEntity(real)
    -- 1实物弹地址，2现金卡弹PIN码，3暂定E2P奖励
    if not real.orderId_time then
        real.orderId_time = bm.getTime()
    end

    if real.type == 1 then
        display.addSpriteFrames("scoremarket_texture.plist", "scoremarket_texture.png", function()
            self:openScoreExchangePopup_(real)
        end)
    elseif real.type == 2 then
        display.addSpriteFrames("scoremarket_texture.plist", "scoremarket_texture.png", function()
            display.addSpriteFrames("upgrade_texture.plist", "upgrade_texture.png", function()
                local ScoreTrackCardExchangePopup = import("app.module.scoremarket.ScoreTrackCardExchangePopup")
                if not real.orderId then
                    real.orderId = real.id
                end
                ScoreTrackCardExchangePopup.new(real, self.controller_):show()
            end)
        end)
    elseif real.type == 3 then
        real.data = {};
        real.data.reward = self.rewardData_;
        self.controller_:getMatchAddress1(handler(self, self.getMatchAddressCallback))
        display.addSpriteFrames("scoremarket_texture.plist", "scoremarket_texture.png")
        self.scoreE2PPopup_ = ScoreExchangeE2PPopup.new():show(real, true, false, display.cx, display.cy + 50)
        self.scoreE2PPopup_:refreshTelEdit(self.addressData_)
    end
end

function MatchRewardPopup:getMatchAddressCallback(params)
    self.addressData_ = params;
    if self.scoreE2PPopup_ and self.scoreE2PPopup_["refreshTelEdit"] then
        self.scoreE2PPopup_:refreshTelEdit(self.addressData_)
    end
end

-- 请求PHP兑换某一物品
function MatchRewardPopup:onExchange_(real)
    local ScoreTrackRealExchangePopup = import("app.module.scoremarket.ScoreTrackRealExchangePopup")
    ScoreTrackRealExchangePopup.new(real, self.controller_):show()
end

function MatchRewardPopup:onOpenAddressPopup_(evt, real)
    ScoreAddressPopup.new(self.controller_):show(function(addressData)
        if real then
            self:openScoreExchangePopup_(real, addressData);
        end
    end);
end

function MatchRewardPopup:openScoreExchangePopup_(real, addressData)
    ScoreExchangePopup.new(self.controller_, real, addressData,  handler(self, self.onExchange_), handler(self, self.onOpenAddressPopup_))
                :show(true, false, display.cx, display.cy + 50)
end

function MatchRewardPopup:renderRewards1_()
    local contentBgSize = self.contentBg_:getContentSize()
    -- 奖励详细信息
    local cfgs = {}
    if self.rewardData_.chips and tonumber(self.rewardData_.chips)>0 then
        table.insert(cfgs, #cfgs+1, bm.LangUtil.getText("MATCH", "MONEY").." * "..self.rewardData_.chips)
    end

    if self.rewardData_.tools and self.rewardData_.tools.score then
        table.insert(cfgs, #cfgs+1, bm.LangUtil.getText("MATCH", "SCORE").." * "..self.rewardData_.tools.score)
    end

    if self.rewardData_.tools and self.rewardData_.tools.goldCoupon then
        table.insert(cfgs, #cfgs+1, bm.LangUtil.getText("MATCH", "GOLDCOUPON").." * "..self.rewardData_.tools.goldCoupon)
    end

    if self.rewardData_.tools and self.rewardData_.tools.gameCoupon then
        table.insert(cfgs, #cfgs+1, bm.LangUtil.getText("MATCH", "GAMECOUPON").." * "..self.rewardData_.tools.gameCoupon)
    end

    -- 黄金币
    if self.rewardData_.gcoins and tonumber(self.rewardData_.gcoins)>0 then
        table.insert(cfgs, #cfgs+1, bm.LangUtil.getText("MATCH", "GOLDCOIN").." * "..self.rewardData_.gcoins)
    end
    local lbl
    local maxdw = 0
    local lpx = -contentBgSize.width/2+90
    for i=1,#cfgs do
        lbl = ui.newTTFLabel({
                text=cfgs[i],
                size=20, 
                color=cc.c3b(0x6b, 0x54, 0x2a), 
                align=ui.TEXT_ALIGN_CENTER,
            }):addTo(self.awardNode_)

        local dw = lbl:getContentSize().width
        if dw > maxdw then
            maxdw = dw
        end

        lbl:pos(lpx+dw*0.5, -25*i-15)
    end

    self.rewardPX_ = 0

    -- 奖励物品
    self.awardIcon_ = display.newNode()
        :size(100,100)
        :pos(0,-65)
        :addTo(self.awardNode_)   

    -- 加载奖励（礼物）
    self.awardImageLoaderId_ = nk.ImageLoader:nextLoaderId()
    if self.giftUrlReqId_ then
        LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
    end

    local giftId = self.rewardData_ and self.rewardData_.giftId 
    if giftId and tonumber(giftId)>0 then
        self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(giftId, function(url)
            self.giftUrlReqId_ = nil
            if url and string.len(url) > 5 then
                nk.ImageLoader:cancelJobByLoaderId(self.awardImageLoaderId_)
                nk.ImageLoader:loadAndCacheImage(self.awardImageLoaderId_,
                    url, 
                    handler(self,self.awardImageLoadCallback_),
                    nk.ImageLoader.CACHE_TYPE_GIFT
                )
            end
        end)
    else
        self.awardIcon_:setVisible(false)
    end

    -- 没有奖励
    if #cfgs==0 then
        self.awardNode_:setVisible(false)
        self.line_:setVisible(false)
    end
end

function MatchRewardPopup:showDialog(msg)
    nk.ui.Dialog.new({
        messageText = msg,
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
    }):show()
end

function MatchRewardPopup:awardImageLoadCallback_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        local oldAvatar = self.awardIcon_:getChildByTag(AVATAR_TAG)
        if oldAvatar then
            oldAvatar:removeFromParent()
        end
        local awardIconSize = self.awardIcon_:getContentSize()
        local xxScale = awardIconSize.width/texSize.width
        local yyScale = awardIconSize.height/texSize.height
        sprite:scale(xxScale<yyScale and xxScale or yyScale)
            :addTo(self.awardIcon_, 0, AVATAR_TAG)

        self.awardIcon_:setPositionX(self.rewardPX_ + awardIconSize.width*0.5 + 0)
    end
end

function MatchRewardPopup:show()
    nk.PopupManager:addPopup(self,nil,nil,false)
    return self
end

function MatchRewardPopup:showPushMsgPopup()
    local rewardStr = ""
    local first = self.rewardData_
    if first.real then
        rewardStr = first.real.name
    else
        if first.score then
            rewardStr = bm.LangUtil.getText("MATCH", "SCOREX", first.score)
        elseif first.gcoins then
            rewardStr = bm.LangUtil.getText("MATCH", "GOLDCOIN", first.gcoins)
        elseif first.chips then
            rewardStr = bm.LangUtil.getText("MATCH", "MONEY").." "..first.chips
        elseif first.gameCoupon then
            rewardStr = bm.LangUtil.getText("MATCH", "GAMECOUPON").." "..first.gameCoupon
        elseif first.goldCoupon then
            rewardStr = bm.LangUtil.getText("MATCH", "GOLDCOUPON").." "..first.goldCoupon
        end
    end

    local msg = bm.LangUtil.getText("PUSHMSG","MATCH_WIN", rewardStr)
    PushMsgPopup.new(" ",msg, true, 3):show()
end

function MatchRewardPopup:share1_()
    -- 分享Feed
    if self.matchData_ and self.rewardData_ then
        local feedData = clone(bm.LangUtil.getText("FEED", "MATCH_COMPLETE"))
        feedData.name = bm.LangUtil.formatString(feedData.name, self.matchData_.name,self.rewardData_.ranking)
        nk.Facebook:shareFeed(feedData, function(success, result)
            print("FEED.EXCHANGE_CODE result handler -> ", success, result)
             if not success then
                 self.shareBtn_:setButtonEnabled(true)
                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
             else
                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
             end
        end)
    end
end

function MatchRewardPopup:share()
    -- 分享照片
    if self.matchData_ and self.rewardData_ then
        local fullPath = "cache/share_picture.jpg"
        local sprite,file = display.printscreen(self.mainContainer_,{file=fullPath,sprite = false},-0.5,-0.48)
        local feedData = clone(bm.LangUtil.getText("FEED", "MATCH_COMPLETE"))
        feedData.name = bm.LangUtil.formatString(feedData.name, self.matchData_.name,self.rewardData_.ranking)
        feedData.path = fullPath

        if nk.Facebook.uploadPhoto then
            self:setLoading(true)
            nk.Facebook:uploadPhoto(feedData, function(success, result)
                self:setLoading(false)
                 if not success then
                     self.shareBtn_:setButtonEnabled(true)
                     nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
                 else
                     nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
                 end
            end)
        end
    end
end

-- 购买免费场次数
function MatchRewardPopup:buyPlayTimes_()
    if self and self.matchData_ then
        if self.matchData_.buyChips and nk.userData.money<self.matchData_.buyChips then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("WHEEL", "LUCKTURN_NOT_ENOUGH_MONEY"),
            }):show()
            return
        end
        self:setLoading(true)
        local LoadMatchControl = import("app.module.match.LoadMatchControl")
        LoadMatchControl:getInstance():exchangeEntry(
            self.matchData_.id,
            function(data)
                self:setLoading(false)
                if self and self.matchData_ then
                    if not data or data.ret~=0 then
                        nk.ui.Dialog.new({
                            messageText = bm.LangUtil.getText("MATCH", "NOTIMESEXFIAL"),
                        }):show()
                    else
                        nk.ui.Dialog.new(bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_TIP")):show()
                        if self.onHelpCallBack_ then
                            self.onHelpCallBack_() 
                        end
                    end
                end
            end
        )
    end
end

function MatchRewardPopup:onClickBackHandler_(evt)
    self:close()
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
            args = {eventId = "matchAward_dialog_close"}, label = "user matchAward_dialog_close"}
    end
end

function MatchRewardPopup:oneMore()
    if self.matchData_ then
        nk.match.MatchModel:regLevel(
            self.matchData_.id,
            function(flag)
                if self.matchData_ then
                    if flag==1 then
                        self:close()
                    elseif flag==-1 then
                        self:close()
                    elseif flag==-2 then
                        self:close()
                    elseif flag==-3 then
                        self.onHelpCallBack_ = nil
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGTICKETSFIAL3",self.matchData_.ticketInfo.name))
                        -- 门票独报
                        local ArenaApplyQuestAlert = import('app.module.hall.arena.ArenaApplyQuestAlert')
                        ArenaApplyQuestAlert.new(
                            "", "", self.matchData_,nil)
                        :showPopupPanel(self)
                    elseif flag==-4 then
                        self.onHelpCallBack_ = function()
                            self:oneMore()
                        end
                        -- 购买次数
                        local ArenaApplyQuestAlert = import('app.module.hall.arena.ArenaApplyQuestAlert')
                        ArenaApplyQuestAlert.new(
                        "", "", self.matchData_,function()
                            self:buyPlayTimes_()
                        end)
                        :showPopupPanel(self)
                    elseif flag==-5 then
                        -- 金币不足
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHCHIPS"))
                    elseif flag==-6 then
                        -- 比赛券
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGAMECOUPON"))
                    elseif flag==-7 then
                        -- 金券
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOUPON"))
                    elseif flag==-8 then
                        self.matchData_.ticketInfo = nil
                        -- Socket重新报名
                        self:oneMore()
                    elseif flag==-9 then
                        -- 清空当前门票
                        nk.MatchTickManager.tickList_ = {}
                        -- Socket重新报名
                        self:oneMore()
                        -- 重新拉取所有门票
                        nk.MatchTickManager:synchPhpTickList(nil)
                    elseif flag==-10 then
                        -- 清空当前门票
                        nk.MatchTickManager.tickList_ = {}
                        -- Socket重新报名
                        self:oneMore()
                        -- 重新拉取所有门票
                        nk.MatchTickManager:synchPhpTickList(nil)
                    elseif flag==-11 then
                        self:close()
                    elseif flag==-12 then
                        -- 现金币不足
                        nk.TopTipManager:showTopTip(nk.match.MatchModel.NOTENOUGHSCORE)
                    elseif flag==-13 then
                        -- 黄金币不足
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOIN"))
                    end
                end
            end
        )
    end
end

function MatchRewardPopup:close()
    nk.PopupManager:removePopup(self)
    local curScene = display.getRunningScene()
    if curScene and curScene.controller and curScene.controller.doBackToHall1 then
        curScene.controller.showBigMatchGuide_ = false
        curScene.controller:doBackToHall1()
    end
    return self
end

function MatchRewardPopup:onClose()
    self:close()
end

function MatchRewardPopup:onShowed()
    if self.rewardList_ then
        self.rewardList_:setScrollContentTouchRect()
    end

    self:firstShowEntity()
end

function MatchRewardPopup:getTasksListData()
end

function MatchRewardPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function MatchRewardPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
                :pos(0,0)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

return MatchRewardPopup