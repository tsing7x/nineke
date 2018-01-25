--
-- Author: viking@boomegg.com
-- Date: 2014-09-12 10:27:04
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 积分奖励弹窗

local LoadGiftControl = import("app.module.gift.LoadGiftControl")
local AVATAR_TAG = 101

local ScoreRewardPopup = class("ScoreRewardPopup", nk.ui.Panel)

ScoreRewardPopup.WIDTH = 660
ScoreRewardPopup.HEIGHT = 530
local  ICON_WIDTH = 305
local ICON_HEIGHT = 155

function ScoreRewardPopup:ctor(rewardData,goodsData,callBack)
    ScoreRewardPopup.super.ctor(self, {ScoreRewardPopup.WIDTH+30, ScoreRewardPopup.HEIGHT+30})
    self:addBgLight()
    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
    self.rewardData_ = rewardData
    self.goodsData_ = goodsData
    self.callBack_ = callBack
    self:setNodeEventEnabled(true)
    display.addSpriteFrames("scorereward.plist", "scorereward.png")
    self:setupView()
end

function ScoreRewardPopup:onCleanup()
    self.rewardData_ = nil
    self.goodsData_ = nil
    self.callBack_ = nil
    self:setLoading(false)
    display.removeSpriteFramesWithFile("scorereward.plist", "scorereward.png")
    nk.ImageLoader:cancelJobByLoaderId(self.awardImageLoaderId_)
end

function ScoreRewardPopup:setupView()
    local width, height = ScoreRewardPopup.WIDTH, ScoreRewardPopup.HEIGHT

    self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height)
    self.mainContainer_:setTouchEnabled(true)
    self.mainContainer_:setTouchSwallowEnabled(true)
    -- 关闭按钮
    self:addCloseBtn()
    -- 标题 时间
    local date = nil
    if self.rewardData_ and self.rewardData_.create_time then
        date = os.date("*t",self.rewardData_.create_time)
    else -- 兑奖的时候
        date = os.date("*t")
        if not self.rewardData_ then
            self.rewardData_ = {}
        end
        self.rewardData_.create_time = os.time()
    end
    local year = tonumber(date.year)
    local month = tonumber(date.month)
    local day = tonumber(date.day)
    local hour = tonumber(date.hour)
    local min = tonumber(date.min)
    local timeStr = year.."-"..(month>10 and month or ("0"..month)).."-"..(day>10 and day or("0"..day)).." "..(hour>10 and hour or("0"..hour))..":"..(min>10 and min or ("0"..min))
    ui.newTTFLabel({text=timeStr, size=28, color=cc.c3b(0xFF, 0xFF, 0xFF)})
        :align(display.LEFT_TOP)
        :pos(-width/2+30, height/2-25)
        :addTo(self.mainContainer_)
    -- 内容背景
    display.newScale9Sprite("#scorereward_bg1.png", 0, 30, cc.size(620, 325)):addTo(self.mainContainer_)
    --内容
    local container = display.newNode()
        :pos(0,30)
        :addTo(self.mainContainer_)
    -- 分享的内容
    self.shareSprite_ = display.newSprite("#scorereward_bg.png")
        :addTo(container)

    local shareSpriteSize = self.shareSprite_:getContentSize()
    --  光
    self.light_ = display.newSprite("#scorereward_light.png")
        :pos(shareSpriteSize.width/2,shareSpriteSize.height/2)
        :addTo(self.shareSprite_)

    local tipsWords = self.rewardData_ and self.rewardData_.tips1
    local pingWords = self.rewardData_ and self.rewardData_.pin
    if not tipsWords or tipsWords=="" then
        tipsWords = self.rewardData_ and self.rewardData_.tips
    end
    if not tipsWords then
        tipsWords = ""
    end
    if not pingWords or pingWords == "" then
        pingWords = ""
    else
        -- pingWords = bm.LangUtil.getText("ECODE", "CODE",pingWords)
        pingWords = bm.LangUtil.getText("ECODE", "CODE1")
    end
    -- 上面的文字
    -- 1、图片
    display.newScale9Sprite("#setting_content_middle_pressed.png",shareSpriteSize.width/2,265,cc.size(shareSpriteSize.width, 60)):addTo(self.shareSprite_)
    ui.newTTFLabel({text=tipsWords, size=22, color=cc.c3b(0xFF, 0xFF, 0xFF), align=ui.TEXT_ALIGN_CENTER, dimensions=cc.size(shareSpriteSize.width, 70)})
        :pos(shareSpriteSize.width/2,262)
        :addTo(self.shareSprite_)
    -- 中间的图片
    self.icon_ = display.newNode()
        :size(ICON_WIDTH,ICON_HEIGHT)
        :pos(shareSpriteSize.width/2,shareSpriteSize.height/2-40)
        :addTo(self.shareSprite_)
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
    self:setLoading(true)
    nk.ImageLoader:loadAndCacheImage(self.iconLoaderId_,
        self.goodsData_.image, 
        function(success, sprite)
            self:setLoading(false)
            if success then
                local tex = sprite:getTexture()
                local texSize = tex:getContentSize()
                local oldAvatar = self.icon_:getChildByTag(AVATAR_TAG)
                if oldAvatar then
                    oldAvatar:removeFromParent()
                end
                local iconSize = self.icon_:getContentSize()
                local xxScale = iconSize.width/texSize.width
                local yyScale = iconSize.height/texSize.height
                sprite:scale(xxScale<yyScale and xxScale or yyScale)
                    :addTo(self.icon_, 0, AVATAR_TAG)
                self:setLoading(false)
            else
                -- print("faile===============")
            end
        end,
        nk.ImageLoader.CACHE_TYPE_GIFT
    )
    -- 兑换码
    ui.newTTFLabel({text=pingWords, size=28, color=cc.c3b(0xFF, 0xFF, 0xFF)})
        :pos(0,55)
        :addTo(container)
    local buttonWidth,buttonHeight = 175,60
    -- 分享按钮
    self.shareBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_blue_normal.png", 
            pressed = "#common_btn_blue_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(buttonWidth, buttonHeight)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("MATCH", "AWARDDLGSHARE") or "", color = cc.c3b(0xb2, 0xdc, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :pos(140,-194)
        :onButtonClicked(buttontHandler(self, function(...)
            if nk.userData and nk.userData.openSharePhoto==1 then
                self:share() -- 分享照片
            else
                self:share1_() -- 分享Feed
            end
            if device.platform == "android" or device.platform == "ios" then
                cc.analytics:doCommand{command = "event",
                    args = {eventId = "scoreAward_dialog_share"}, label = "user scoreAward_dialog_share"}
            end
        end))
        :addTo(self.mainContainer_); 
    -- 截图照片
    self.shotBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_blue_normal.png", 
            pressed = "#common_btn_blue_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(buttonWidth, buttonHeight)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SHARE", "SHOTANDSAVE") or "", color = cc.c3b(0xb2, 0xdc, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :pos(140,-194)
        :onButtonClicked(buttontHandler(self, function(...)
            -- self:setLoading(true)
            -- 拍照
            nk.Native:screenShot(function(value)
                -- self:setLoading(false)
                -- 截图提示
                if value==1 or value=="1" then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("SHARE", "SHOTSAVESUC"))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("SHARE", "SHOTSAVEFAL"))
                end
            end,0,0,display.widthInPixels,display.heightInPixels)
        end))
        :addTo(self.mainContainer_); 
    -- 查看记录
    self.recordBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_green_normal.png", 
            pressed = "#common_btn_green_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(buttonWidth, buttonHeight)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "TAB2") or "", color = cc.c3b(0xb2, 0xdc, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :pos(-140,-194)
        :onButtonClicked(buttontHandler(self, function(...)
            if self.callBack_ then
                self.callBack_()
            end
            if device.platform == "android" or device.platform == "ios" then
                cc.analytics:doCommand{command = "event",
                    args = {eventId = "scoreAward_dialog_record"}, label = "user scoreAward_dialog_record"}
            end
            self:close()
        end))
        :addTo(self.mainContainer_); 
    -- 判断rebate返利字段是否存在
    if self.goodsData_.rebate ~= nil and self.goodsData_.rebate > 0 then
        --邀请
        self.oneInviteBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_blue_normal.png", 
            pressed = "#common_btn_blue_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(buttonWidth, buttonHeight)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_INVITE") or "", color = cc.c3b(0xb2, 0xdc, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :pos(0,-194)
        :onButtonClicked(buttontHandler(self, function(...)
            local gid = 0;
            local rebate = 0;
            if self.goodsData_ then
                gid = self.goodsData_.id;
                rebate = self.goodsData_.rebate;
            end
            bm.EventCenter:dispatchEvent({name = "OPEN_INVITE_MATCHPOPUP", data = {type="STOREMARKET_INVITE_FRIEND", value1=gid, value2=rebate}});
            self:close()
        end))
        :addTo(self.mainContainer_);
        local py = -194;
        local dw = ScoreRewardPopup.WIDTH * 0.33;
        self.shareBtn_:pos(-dw, py);
        self.recordBtn_:pos(dw, py);
        self.oneInviteBtn_:pos(0, py)
        -- local py = -174;
        -- local dw = ScoreRewardPopup.WIDTH * 0.33;
        -- self.shareBtn_:pos(-dw, py);
        -- self.recordBtn_:pos(dw, py);
        -- self.oneInviteBtn_:pos(0, py)

        -- -- 
        -- local tipPy = -ScoreRewardPopup.HEIGHT*0.5+30;
        -- local bg = display.newScale9Sprite("#top_tip_bg.png", 0, tipPy, cc.size(ScoreRewardPopup.WIDTH-20, 46))
        --                 :addTo(self)
        -- local lbl = ui.newTTFLabel({
        --                 text=bm.LangUtil.getText("MATCH", "SCORE_VITEFRIEND_TIPS", self.goodsData_.rebate),
        --                 size=16,
        --                 color=cc.c3b(0xff, 0xc2, 0x21),
        --                 align=ui.TEXT_ALIGN_LEFT,
        --                 dimensions=cc.size(500, 0)
        --             }):pos(0, tipPy):addTo(self);
        -- local icon = display.newSprite("light_tip_icon.png"):addTo(self);
        -- local lsz = lbl:getContentSize();
        -- local isz = icon:getContentSize();
        -- icon:pos(-lsz.width*0.5-isz.width*0.5-10, tipPy);
    end
    self.shotBtn_:setVisible(false)
    -- 二维码
    self.QRCode_ = display.newSprite("QR_code.png")
        :pos(250,-105)
        :addTo(container)
    self.QRCode_:scale(0.3)
end

function ScoreRewardPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function ScoreRewardPopup:share1_()
    -- 分享Feed
    if self.goodsData_ and self.rewardData_ then
        local feedData = clone(bm.LangUtil.getText("FEED", "SCORE_EXCHANGE"))
        feedData.name = bm.LangUtil.formatString(feedData.name, self.goodsData_.name)
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

function ScoreRewardPopup:share()
     print("-----------------------------------------------------share1_")
    -- 分享照片
    if self.goodsData_ and self.rewardData_ then
        local fullPath = "cache/share_picture.jpg"
        local sprite,file = display.printscreen(self.shareSprite_,{file=fullPath,sprite = false})
        local feedData = clone(bm.LangUtil.getText("FEED", "SCORE_EXCHANGE"))
        feedData.name = bm.LangUtil.formatString(feedData.name, self.goodsData_.name)
        feedData.path = fullPath
        if nk.Facebook.uploadPhoto then
            self:setLoading(true)
            nk.Facebook:uploadPhoto(feedData, function(success, result)
                print("UPLOADPHOTO.EXCHANGE_CODE result handler -> ", success, result)
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

function ScoreRewardPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function ScoreRewardPopup:onClose()
    self:close()
end

function ScoreRewardPopup:onShowed()
   
end

function ScoreRewardPopup:setLoading(isLoading)
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

return ScoreRewardPopup