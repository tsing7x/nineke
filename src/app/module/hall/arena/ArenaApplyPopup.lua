-- Author: DavidXiFeng@gmail.com
-- Date: 2015-06-30 18:01:54
-- 比赛场 报名弹窗
local LoadMatchControl = import("app.module.match.LoadMatchControl")
local ScrollLabel = import("boomegg.ui.ScrollLabel")
local GuidePayPopup    = import("app.module.firstpay.GuidePayPopup")
local FirstPayPopup = import("app.module.firstpay.FirstPayPopup")
local ArenaMatchRecordItem = import(".ArenaMatchRecordItem")
local ArenaUserInfoItem = import(".ArenaUserInfoItem")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local ScoreMarketController = import("app.module.scoremarket.ScoreMarketController")
local ScoreExchangePopup = import("app.module.scoremarket.ScoreExchangePopup")
local ScoreAddressPopup = import("app.module.scoremarket.ScoreAddressPopup")
local ScoreExchangeE2PPopup = import("app.module.scoremarket.ScoreExchangeE2PPopup")
-- E2P场次特殊处理
local ArenaApplyPopup = class('ArenaApplyPopup', nk.ui.Panel)

ArenaApplyPopup.FEE_TOTAL_CNT = 72 -- 普通场比赛总人数
ArenaApplyPopup.FEE_TOTAL_TIME = 20-- 普通场比赛平均事件

local MatchEventHandler         = import("app.module.match.MatchEventHandler")
local MatchManager  = import 'app.module.match.MatchManager'
local ArenaApplyQuestAlert = import 'app.module.hall.arena.ArenaApplyQuestAlert'

local POPUP_WIDTH = 758
local POPUP_HEIGHT = 418

local LIST_WIDTH, LIST_HEIGHT = 730, 325

function ArenaApplyPopup:onCleanup()
    self:onCleanGetRegCountScheduler_()

    if self.matchLoginSuccessId_ then
        bm.EventCenter:removeEventListener(self.matchLoginSuccessId_)
        self.matchLoginSuccessId_ = nil
    end

    if self.action_ then
        self:stopAction(self.action_)
    end
    self.matchData_ = nil
    if self.regListenerId_ then
        bm.EventCenter:removeEventListener(self.regListenerId_)
        self.regListenerId_ = nil
    end
    if self.pushId_ then
        bm.EventCenter:removeEventListener(self.pushId_)
        self.pushId_ = nil
    end
    if self.matchTimeChangeId_ then
        bm.EventCenter:removeEventListener(self.matchTimeChangeId_)
        self.matchTimeChangeId_ = nil
    end

    if self.matchAsyncRecordLogId_ then
        bm.EventCenter:removeEventListener(self.matchAsyncRecordLogId_)
        self.matchAsyncRecordLogId_ = nil
    end

    bm.EventCenter:removeEventListener(self.onCountListenerId_)
    display.removeSpriteFramesWithFile("matchreg.plist", "matchreg.png")
    self:setLoading(false)
    bm.HttpService.CANCEL(self.regUseTicketsId_)

    bm.EventCenter:removeEventListener(self.onTicketChange_)
    bm.EventCenter:removeEventListener(self.matchCoolDownId_)
end

function ArenaApplyPopup:createContain(isBtn)
    local contentWidth,contentHeight = POPUP_WIDTH,POPUP_HEIGHT-56
    local note = nil
    if isBtn then
        contentWidth,contentHeight = 383,124
        note = display.newNode()
        note:setContentSize(cc.size(contentWidth,contentHeight))

        return note
    end

    note = display.newNode()
    note:setContentSize(cc.size(contentWidth,contentHeight))
    note:addTo(self):pos(-contentWidth/2,-(POPUP_HEIGHT)/2)

    return note
end

function ArenaApplyPopup:onMatchCoolDown(evt)
    if self.matchData_ then
        -- 次数显示
        if self.needReduce and self.matchData_.leftTimes and self.matchData_.playTimes and self.matchData_.playTimes>0 then
            if self.matchData_.CDTime then
                self.leftTimes_:setString(bm.LangUtil.getText("MATCH", "LEFTPLAYTIMES_1",self.matchData_.leftTimes or 0,bm.TimeUtil:getTimeString(self.matchData_.CDTime)))
            else
                self.leftTimes_:setString(bm.LangUtil.getText("MATCH", "LEFTPLAYTIMES",self.matchData_.leftTimes or 0))
            end
            self.leftTimes_:setVisible(true)
            local visible = self.helpBtn_:isVisible()
            if self.matchData_.leftTimes>0 then
                if visible then
                    self:dealFinalStr(self.isRegistered_)
                end
            else
                if not visible then
                    self:dealFinalStr(self.isRegistered_)
                end
            end
        else
            self.leftTimes_:setVisible(false)
        end
    end
    -- 针对现金币场显示总奖池
    self:proScoreMatchCondition_()
end

function ArenaApplyPopup:ctor(matchlevel, index, isRegistered, regCallback, data)
    ArenaApplyPopup.super.ctor(self, {POPUP_WIDTH+32, POPUP_HEIGHT+32})
    self:addBgLight()
    self:addCloseBtn()
    self.needReduce = true -- 需要减少次数
    if (nk.userData.money + nk.userData.bank_money)<=10000 then
        self.needReduce = false
    end
    self.ruleStr_ = nil
    self.isReging_ = false -- 是否正在
    self:setNodeEventEnabled(true)
    self.controller_ = ScoreMarketController.new(self)
    self.onCountListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_REG_COUNT, handler(self,self.setRegOnline_))
    self.onTicketChange_ = bm.EventCenter:addEventListener("USER_TICKET_CHANGE", handler(self,self.dealFinalStr))
    self.matchCoolDownId_ = bm.EventCenter:addEventListener("Match_Cool_Down_Change", handler(self,self.onMatchCoolDown))
    self.pushId_ = bm.EventCenter:addEventListener("ABOUT_MATCH_PUSH", handler(self,self.onMatchPush_))
    self.matchLoginSuccessId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_MATCH_SUCC, handler(self, self.getOnlineCnt_))
    self.matchListIndex_ = matchlevel
    self.matchData_ = data
    self.getWayStr_ = bm.LangUtil.getText("MATCH","MATCHFREE")

    if self.matchData_ then
        self.getWayStr_ = self.matchData_.getWay or bm.LangUtil.getText("MATCH","MATCHFREE")
        if tonumber(self.matchData_.type)==1 then
            ArenaApplyPopup.FEE_TOTAL_CNT = tonumber(self.matchData_.needNum or 72)
            ArenaApplyPopup.FEE_TOTAL_TIME = tonumber(self.matchData_.waitTime or 20)
        end

        -- 没有次数限制场
        if not self.matchData_.playTimes or self.matchData_.playTimes<1 then
            self.needReduce = false
        end
    end

    if isRegistered then
        local count = nk.match.MatchModel[matchlevel]
        if not count then
            if tonumber(self.matchData_.type)==1 then
                count = 1
            else
                math.random(1,500)
                count = math.floor(math.random(1,500))
            end
            nk.match.MatchModel[matchlevel] = count
        end

        self.onlineCnt_ = count
    end

    self.matchLevel_ = matchlevel
    self.page_ = 1
    self.infoitem_ = {}
    self.curCount = 0
    self.curPage = 0
    self.maxPage = 1
    self.isloaded = false
    self.isRegistered_ = isRegistered
    self.regCallback_ = regCallback

    self:initProTime()

    self.title_ = ui.newTTFLabel({
            text  = '',
            color = cc.c3b(0xfb, 0xd0, 0x0a),
            size  = 36,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :align(display.CENTER, 0, 170+15)
        :addTo(self)
    self.conHeight_ = (POPUP_HEIGHT-56)

    self:initRuleView_()
    self:initAwardView_()
    self:initRecordView_()
    self:initMatchRecordView_()
    self:initMainView_()

    if self.isRegistered_ then
        self:renderOnlineCount(self.onlineCnt_)
        self:checkRegStatus(true)
    end

    self:dealShowMatchInfo()
    self:addSchedulerGetRegCount_()

    -- 万一没有倒计时呢？
    self:onMatchCoolDown()
    if self.isRegistered_ and self.matchData_ and self.matchData_.push==1 then
        nk.socket.MatchSocket:getPushInfo(self.matchLevel_)
    end
end

function ArenaApplyPopup:addSchedulerGetRegCount_()
    self:onCleanGetRegCountScheduler_()
    -- 请求当前已经报名人数
    self.countAction_ = self:schedule(function()
        if self.matchData_ and nk.socket.MatchSocket:isConnected() then
            if tonumber(self.matchData_.type)==2 and self.isRegistered_ then
                nk.socket.MatchSocket:getRegedCount(self.matchData_.id)
            end
        end
    end, 3)
end

function ArenaApplyPopup:onCleanGetRegCountScheduler_()
    if self.countAction_ then
        self:stopAction(self.countAction_)
    end
end

function ArenaApplyPopup:dealRuleAndAward(isInit)
    if isInit then return end
    local matchData = self.matchData_
    if matchData then
        if matchData.reward then
            local tempList = {}
            local prevIndex = 0
            local prevValue = nil
            local isRepeat = false
            local currentIndex = 0
            for k,v in pairs(matchData.reward) do
                currentIndex = k
                if prevValue==v then
                    isRepeat = true
                else
                    if currentIndex>1 then
                        if isRepeat then
                            table.insert(tempList,{prevIndex.."-"..(currentIndex-1),prevValue.."\n"})
                        else
                            table.insert(tempList,{(currentIndex-1),prevValue.."\n"})
                        end
                    end
                    isRepeat = false
                    prevIndex = k
                    prevValue = v
                end
            end

            -- 添加最后一个
            if prevValue then
                if isRepeat then
                    table.insert(tempList,{prevIndex.."-"..currentIndex,prevValue})
                else
                    table.insert(tempList,{currentIndex,prevValue})
                end
            end

            local matchStr = ""
            for k,v in pairs(tempList) do
                matchStr = matchStr..bm.LangUtil.getText("MATCH","RANKWORD2",v[1])..v[2]
            end
            self.awardList_:setString(matchStr)
        end

        if self.ruleTips_ then
            self.ruleTips_:setString(tostring(matchData.rules))
        end

        self.ruleStr_ = matchData.rules
    end
end

function ArenaApplyPopup:dealShowMatchInfo()
    local matchData = self.matchData_
    if matchData then
        if self.matchData_ then
            self.getWayStr_ = self.matchData_.getWay or bm.LangUtil.getText("MATCH","MATCHFREE")
            if tonumber(self.matchData_.type)==1 then
                ArenaApplyPopup.FEE_TOTAL_CNT = tonumber(self.matchData_.needNum or 72)
                ArenaApplyPopup.FEE_TOTAL_TIME = tonumber(self.matchData_.waitTime or 20)

                local ts = math.modf(ArenaApplyPopup.FEE_TOTAL_TIME/2)
                self.averTimeCfg_.setString(ts).show()
            end
        end

        self.title_:setString(matchData.name)

        if matchData.factor1 then
            self.leftTime_ = matchData.leftTime - (os.time()-matchData.serverTime)
            if not self.matchTimeChangeId_ then
                self.matchTimeChangeId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_TIME_CHANGE, handler(self,self.onTimeChange))
            end
            if not self.action_ then
                self.action_ = self:schedule(function ()
                    self:countFunc()
                end, 1)
            end
        else
            self:refreshStartTip()
        end

        self:dealRuleAndAward(true)

        -- 入场条件
        local condition = matchData.condition
        local finalStr = ""
        if condition.chips then
            finalStr = bm.LangUtil.getText("CRASH", "CHIPS",condition.chips)
        end

        local gameCouponStatus = nil
        local goldCouponStatus = nil
        local gcoinsStatus = nil
        if condition.gameCoupon then
            gameCouponStatus = 1
            if tonumber(nk.userData.gameCoupon)<tonumber(condition.gameCoupon) then
                gameCouponStatus = -1
            end
        end

        if condition.goldCoupon then
            goldCouponStatus = 1
            if tonumber(nk.userData.goldCoupon)<tonumber(condition.goldCoupon) then
                goldCouponStatus = -1
            end
        end

        if condition.gcoins then
            gcoinsStatus = 1
            if tonumber(nk.userData.gcoins)<tonumber(condition.gcoins) then
                gcoinsStatus = -1
            end
        end

        if gameCouponStatus==1 or (not gcoinsStatus and gameCouponStatus) then
            if finalStr=="" then
                finalStr = condition.gameCoupon..bm.LangUtil.getText("MATCH", "GAMECOUPON")
            else
                finalStr = finalStr.."+"..condition.gameCoupon..bm.LangUtil.getText("MATCH", "GAMECOUPON")
            end
        else
            -- 黄金币
            if condition.gcoins then
                if finalStr=="" then
                    finalStr = condition.gcoins..bm.LangUtil.getText("MATCH", "GOLDCOIN")
                else
                    finalStr = finalStr.."+"..condition.gcoins..bm.LangUtil.getText("MATCH", "GOLDCOIN")
                end
            end
        end

        if condition.goldCoupon then
            if finalStr=="" then
                finalStr = condition.goldCoupon..bm.LangUtil.getText("MATCH", "GOLDCOUPON")
            else
                finalStr = finalStr.."+"..condition.goldCoupon..bm.LangUtil.getText("MATCH", "GOLDCOUPON")
            end
        end

        -- 现金币
        if condition.score then
            if finalStr=="" then
                finalStr = condition.score..bm.LangUtil.getText("BILLDETAIL", "TAB_TYPES")[1]
            else
                finalStr = finalStr.."+"..condition.score..bm.LangUtil.getText("BILLDETAIL", "TAB_TYPES")[1]
            end
        end

        if not finalStr or finalStr=="" then
            finalStr = bm.LangUtil.getText("MATCH", "MATCHFREE")
        end

        self.finalStr_ = finalStr or ""
    end

    self:dealFinalStr()
end

function ArenaApplyPopup:setLoading(isLoading)
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

function ArenaApplyPopup:refreshStartTip()
    self.starttipCfg_.setString(self.matchData_.factor).txtVisible3(false)
    self:refreshTxtPos()
end

-- 主面板
function ArenaApplyPopup:initMainView_()
    self.mainView_ = self:createContain()
    display.newScale9Sprite("#panel_overlay.png", 
           0, 0, cc.size(POPUP_WIDTH - 40, POPUP_HEIGHT - 80))
        :pos(POPUP_WIDTH / 2,(POPUP_HEIGHT - 60) / 2)
        :addTo(self.mainView_)

    -- 比赛时间
    local containerWidth,containerHeight = 383,124
    self.startContainer_ = self:createContain(true)
    self.startContainer_:pos(0,containerHeight*2)
        :addTo(self.mainView_)

    self.startIcon_ = display.newSprite("#start_icon.png")
        :addTo(self.startContainer_)
        :pos(60,containerHeight/2 - 30)

    local fontSzs = 26
    
    self.rulelbl_ = ui.newTTFLabel({
                text  = bm.LangUtil.getText("MATCH", "CONDITION4").."",
                color = styles.FONT_COLOR.LIGHT_TEXT,
                align = ui.TEXT_ALIGN_LEFT,
                size  = 24
            }):addTo(self.startContainer_):pos(140,containerHeight/2)
    self.startmore_ = display.newSprite("#matchreg_more.png")
        :pos(150,containerHeight/2)
        :addTo(self.startContainer_)

    -- 奖励方案
    self.awardContainer_ = self:createContain(true)
    self.awardContainer_:pos(0,containerHeight)
        :addTo(self.mainView_)
    self.awardIcon_ = display.newSprite("#award_icon.png")
        :addTo(self.awardContainer_)
        :pos(60,containerHeight/2 - 7)
    self.award_lbl = ui.newTTFLabel({
                text  = bm.LangUtil.getText("MATCH", "CONDITION3"),
                color = styles.FONT_COLOR.LIGHT_TEXT,
                align = ui.TEXT_ALIGN_LEFT,
                size  = 24
            }):addTo(self.awardContainer_):pos(150,containerHeight/2)
    self.awardmore_ = display.newSprite("#matchreg_more.png")
        :pos(150,containerHeight/2)
        :addTo(self.awardContainer_)

    -- 比赛规则详情
    self.ruleContainer_ = self:createContain(true)
    self.ruleContainer_:pos(0,15)
        :addTo(self.mainView_)
    self.ruleIcon_ = display.newSprite("#matchrecord_icon1.png")
        :addTo(self.ruleContainer_)
        :pos(60,containerHeight/2)
    self.rule_lbl_ = ui.newTTFLabel({
                text  = bm.LangUtil.getText("MATCH", "CONDITION5"),
                color = styles.FONT_COLOR.LIGHT_TEXT,
                align = ui.TEXT_ALIGN_LEFT,
                size  = 24
            }):addTo(self.ruleContainer_):pos(150,containerHeight/2)
    self.rulemore_ = display.newSprite("#matchreg_more.png")
        :pos(150,containerHeight/2)
        :addTo(self.ruleContainer_)
    self.btn1_ = cc.ui.UIPushButton.new({normal = "#matchreg_big_btn_bg.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(287, 93)
        :pos(POPUP_WIDTH/4 - 15, self.conHeight_/4-15 + 103 + 103)
        :addTo(self.mainView_)
        :onButtonClicked(buttontHandler(self, function()
            self:selectedIndex_(4)
        end))
    self.btn2_ = cc.ui.UIPushButton.new({normal = "#matchreg_big_btn_bg.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(287, 93)
        :pos(POPUP_WIDTH/4 - 15, self.conHeight_/4-15 + 103)
        :addTo(self.mainView_)
        :onButtonClicked(buttontHandler(self, function()
            self:selectedIndex_(2)
        end))

    self.btn3_ = cc.ui.UIPushButton.new({normal = "#matchreg_big_btn_bg.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(287, 93)
        :pos(POPUP_WIDTH/4 - 15, self.conHeight_/4-15)
        :addTo(self.mainView_)
        :onButtonClicked(buttontHandler(self, function()
            self:selectedIndex_(5)
        end))

    self.btnList_ = {self.btn1_, self.btn2_, self.btn3_}
    self:selectedIndex_(1)
    self.start_lbl = ui.newTTFLabel({
                text  = bm.LangUtil.getText("MATCH", "CONDITION1"),
                color = styles.FONT_COLOR.LIGHT_TEXT,
                align = ui.TEXT_ALIGN_CENTER,
                size  = 24
            }):addTo(self.mainView_):pos(POPUP_WIDTH - 310,315)
    self.starttipCfg_ = SimpleColorLabel.addMultiLabel(bm.LangUtil.getText("MATCH","TIMESTART"), 24, cc.c3b(0xeb,0x91,0x48), cc.c3b(0xeb,0x91,0x48), styles.FONT_COLOR.LIGHT_TEXT)
    self.starttipCfg_.addTo(self.mainView_).pos(POPUP_WIDTH - 310 + 140, 315).txtVisible3(false)

    self.averTimeCfg_ = SimpleColorLabel.addMultiLabel(bm.LangUtil.getText("MATCH","AVERAGE_TIME"),24,styles.FONT_COLOR.LIGHT_TEXT,cc.c3b(0xeb,0x91,0x48), styles.FONT_COLOR.LIGHT_TEXT)
    self.averTimeCfg_.addTo(self.mainView_).pos(POPUP_WIDTH - 200, 235).hide()

    self.leftStartTimeCfg_ = SimpleColorLabel.addMultiLabel(bm.LangUtil.getText("MATCH","LEFT_TIME"),24,styles.FONT_COLOR.LIGHT_TEXT,cc.c3b(0xeb,0x91,0x48), styles.FONT_COLOR.LIGHT_TEXT)
    self.leftStartTimeCfg_.addTo(self.mainView_).pos(POPUP_WIDTH - 200, 210).hide()
 
    local whiteBg = display.newScale9Sprite("#white_bg.png", POPUP_WIDTH - 200, 275, cc.size(320, 40)):addTo(self.mainView_)
    bm.TouchHelper.new(whiteBg, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            if self.helpBtn_:isVisible() then
                self:onHelpBtn_()
            end
        end
    end)

    self.helpBtn_ = cc.ui.UIPushButton.new({normal = "#help_btn.png"})
        :pos(POPUP_WIDTH - 200 + 160 - 20, 275)
        :addTo(self.mainView_)
        :onButtonClicked(buttontHandler(self, self.onHelpBtn_))
    self.helpBtn_:setVisible(false)

    self.conditionlbl_ = ui.newTTFLabel({
            text = "",
            color = cc.c3b(0xeb, 0x91, 0x48),
            align = ui.TEXT_ALIGN_CENTER,
            size = 25
        }):pos(POPUP_WIDTH - 200, 275):addTo(self.mainView_)
    
    local aa = {
        off = "#aa.png",
        on = "#aa1.png"
    }

    self.pushBtn_ = cc.ui.UICheckBoxButton.new(aa)
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("MATCH","PUSH"), color = display.COLOR_WHITE}))
        :setButtonLabelOffset(13, 0)
        :align(display.LEFT_CENTER)
        :pos(POPUP_WIDTH - 200, 158)
        :addTo(self.mainView_)
        :onButtonClicked(buttontHandler(self, function()
            local states = self.pushBtn_:getDefaultState_()
            if states[1]==cc.ui.UICheckBoxButton.ON then
                nk.socket.MatchSocket:setPushInfo(self.matchLevel_,1)
            else
                nk.socket.MatchSocket:setPushInfo(self.matchLevel_,0)
            end
        end))
    self.pushBtn_:hide()

    -- 计算宽度
    local label1 = self.pushBtn_:getButtonLabel("off")
    local size1 = label1:getContentSize()
    self.pushBtn_:setPositionX(POPUP_WIDTH - 200 - (size1.width+13)*0.5)
    --进度条
    self.progBar_ = nk.ui.ProgressBar.new(
        "#pro_bg.png",
        "#pro_con.png",
        {
            bgWidth = 326,
            bgHeight = 23,
            fillWidth = 12,
            fillHeight = 20
        }
    ):pos(POPUP_WIDTH - 364, 160):addTo(self.mainView_):hide()

    self.progBar_:setValue(0.01)

    self.progTxt_ = ui.newTTFLabel({
                text  = "",
                color = styles.FONT_COLOR.LIGHT_TEXT,
                align = ui.TEXT_ALIGN_CENTER,
                size  = 22
            }):addTo(self.mainView_, 2):pos(POPUP_WIDTH - 200, 160)

    self.applyIcon_ = display.newScale9Sprite("#reg_btn.png", POPUP_WIDTH - 200, 85, cc.size(330,100)):addTo(self.mainView_) 
    self.applyIcon2_ = display.newScale9Sprite("#unreg_btn.png", POPUP_WIDTH - 200, 85, cc.size(330,100)):addTo(self.mainView_):hide() 
    self.apply_btn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png", disabled  = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("MATCH","REGISTER") or "", color = cc.c3b(0xff, 0xff, 0xff), size = 36, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonSize(330-10,100-10)
        :pos(POPUP_WIDTH - 200, 85)
        :addTo(self.mainView_, 2)
        :onButtonClicked(buttontHandler(self, self.onBtnApplyClicked))

    self.mainView_:show()

    -- 免费场次数
    self.leftTimes_ = ui.newTTFLabel({
                text  = "",
                color = styles.FONT_COLOR.LIGHT_TEXT,
                align = ui.TEXT_ALIGN_CENTER,
                size  = 16
            }):addTo(self.mainView_):pos(POPUP_WIDTH - 200, 23)
    self.leftTimes_:setVisible(false)

    self:refreshTxtPos()

    if tonumber(self.matchData_.type)==1 then
        if self.isRegistered_ then
            self.progBar_:show()
        end
    else
        self.progBar_:hide()
    end

    self:onTimeChange()
end

function ArenaApplyPopup:refreshTxtPos()
    local px, py = self.startIcon_:getPosition()
    local iconSz = self.startIcon_:getContentSize()
    local lblSz = self.rulelbl_:getContentSize()
    px = px + iconSz.width*0.5 + lblSz.width*0.5 + 5

    local rsz = self.rulelbl_:getContentSize() 
    self.rulelbl_:pos(px, py)
    px = px + lblSz.width * 0.5 + self.startmore_:getContentSize().width * 0.5 + 3
    self.startmore_:pos(px,py)
    px, py = self.awardIcon_:getPosition()
    iconSz = self.awardIcon_:getContentSize()
    lblSz = self.award_lbl:getContentSize()
    px = px + iconSz.width*0.5 + lblSz.width*0.5 + 5
    self.award_lbl:pos(px, py)
    px = px + lblSz.width * 0.5 + self.awardmore_:getContentSize().width * 0.5 + 3
    self.awardmore_:pos(px,py)
    px, py = self.ruleIcon_:getPosition()
    iconSz = self.ruleIcon_:getContentSize()
    lblSz = self.rule_lbl_:getContentSize()
    px = px + iconSz.width*0.5 + lblSz.width*0.5 + 5
    self.rule_lbl_:pos(px, py)
    px = px + lblSz.width * 0.5 + self.rulemore_:getContentSize().width * 0.5 + 3
    self.rulemore_:pos(px,py)
    local px, py = self.start_lbl:getPosition()
    px = 400
    lblSz = self.start_lbl:getContentSize()
    px = px + lblSz.width*0.5 + 5
    self.start_lbl:pos(px, py)
    px = px + lblSz.width*0.5 + 5
    lblSz = self.starttipCfg_.getContentSize()
    self.starttipCfg_.pos(px + lblSz.width*0.5 + 0, py)
end

-- 帮助按钮
function ArenaApplyPopup:onHelpBtn_()
    local condition1 = self.finalStr_
    local condition2 = self.getWayStr_
    ArenaApplyQuestAlert.new(
        condition1, condition2, self.matchData_,function(arg)
            if arg=="hide" then
                self:hidePopupPanel()
            else
                self:buyPlayTimes_()
            end
        end)
        :showPopupPanel(self)
end

-- 支付
function ArenaApplyPopup:goPlay()
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("MATCH", "NOTIMESBUY"), 
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                local StorePopup = require('app.module.newstore.StorePopup')
                StorePopup.new(1):showPanel()
            end
        end
    }):show()
end

-- 购买免费场次数
function ArenaApplyPopup:buyPlayTimes_()
    if self and self.matchData_ then
        if self.matchData_.buyChips and nk.userData.money<self.matchData_.buyChips then
            self:goPlay()
            return
        end
        self:setLoading(true)
        LoadMatchControl:getInstance():exchangeEntry(
            self.matchData_.id,
            function(data)
                self:setLoading(false)
                if self and self.matchData_ then
                    self:dealFinalStr()
                    if not data or data.ret~=0 then
                        nk.ui.Dialog.new({
                            messageText = bm.LangUtil.getText("MATCH", "NOTIMESEXFIAL"),
                        }):show()
                    else
                        if self.onHelpCallBack_ then
                            self.onHelpCallBack_()
                        end
                    end
                end
            end
        )
    end
end

function ArenaApplyPopup:selectedIndex_(index)
    self.mainView_:hide()
    self.awardView_:hide()
    self.ruleView_:hide()
    self.recordView_:hide()
    self.matchRecordView_:hide()
    if index == 1 then
        self.mainView_:show()
        self.closeBtn_:show()
    elseif index == 2 then
        self.awardView_:show()
        self.closeBtn_:hide()

        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand{
                command = "event",
                args = {eventId = "match_ArenaApplyRewad_Click"}, label = "matchlevel::"..tostring(self.matchListIndex_)
            }
        end
    elseif index == 3 then
        self.recordView_:show()
        self.closeBtn_:hide()

        if not self.isAsyncRecordLog_ then
            nk.MatchRecordManager:asyncHallMatchLog(self.matchLevel_, self.page_)
        end

        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand{
                command = "event",
                args = {eventId = "match_ArenaApplyRule_Click"}, label = "matchlevel::"..tostring(self.matchListIndex_)
            }
        end
    elseif index == 4 then
        self.ruleView_:show()
        self.closeBtn_:hide()

        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand{
                command = "event",
                args = {eventId = "match_ArenaApplyRewad_Click"}, label = "matchlevel::"..tostring(self.matchListIndex_)
            }
        end
    elseif index == 5 then
        self.matchRecordView_:show()
        self.closeBtn_:hide()
        if (#self.infoitem_ <= 0) then
            self:onGetRecord(self.curPage + 1)
        end
    end
    if index~=1 then
        if not self.ruleStr_ or self.ruleStr_ == "" then
            self:setLoading(true)
            LoadMatchControl:getInstance():getMatchDetail(self.matchData_.id,function()
                self:setLoading(false)
                self:dealRuleAndAward()
            end)
        end
    else
        self:setLoading(false)
    end
end

-- 奖励面板
function ArenaApplyPopup:initAwardView_()
    -- 奖励
    self.awardView_ = self:createContain()
    display.newScale9Sprite(
            "#frame_bg.png",
            POPUP_WIDTH/2,self.conHeight_/2,
            cc.size(LIST_WIDTH, LIST_HEIGHT + 10)
            )
        :addTo(self.awardView_)

    self.awardList_ = ScrollLabel.new(
            {
                text  = '',
                color = cc.c3b(255, 255, 255),
                size  = 25,
                align = ui.TEXT_ALIGN_LEFT,
                valign = ui.TEXT_VALIGN_TOP,
                dimensions=cc.size(POPUP_WIDTH - 50, self.conHeight_ - 42)
            },
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
            })
        :pos(LIST_WIDTH * 0.5 + 20, self.conHeight_/2)
        :addTo(self.awardView_)

    cc.ui.UIPushButton.new({normal = "#pop_friend_back_button_normal.png", pressed = "#pop_friend_back_button_pressed.png"})
        :pos(26, 395)
        :addTo(self.awardView_)
        :add(display.newSprite("#pop_friend_back_icon.png"))
        :onButtonClicked(buttontHandler(self, function()
            self:selectedIndex_(1)
        end))

    self.awardView_:hide()
end

--显示所有的记录面板
function ArenaApplyPopup:initMatchRecordView_()
    local CW, CH = 750, 300
    self.matchRecordView_ = self:createContain()

    cc.ui.UIPushButton.new({normal = "#pop_friend_back_button_normal.png", pressed = "#pop_friend_back_button_pressed.png"})
        :pos(26, 395)
        :addTo(self.matchRecordView_)
        :add(display.newSprite("#pop_friend_back_icon.png"))
        :onButtonClicked(buttontHandler(self, function()
            self:selectedIndex_(1)
        end))

    local px, py = 36, CH + 45
    self.matchTipsDesc_ = ui.newTTFLabel({
            text = "",
            color=styles.FONT_COLOR.LIGHT_TEXT,
            size = 22,
            align = ui.TEXT_ALIGN_LEFT
        })
        :pos(px, py)
        :addTo(self.matchRecordView_)

    self.matchTipsGetDesc_ = ui.newTTFLabel({
            text = bm.LangUtil.getText("MATCH","GOT_REWARD_MATCH"),
            color=styles.FONT_COLOR.LIGHT_TEXT,
            size = 22,
            align = ui.TEXT_ALIGN_LEFT
        })
        :pos(px, py - 25)
        :addTo(self.matchRecordView_)
	
    cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
        :setButtonSize(160,52)
        :addTo(self.matchRecordView_)
        :onButtonClicked(buttontHandler(self, function()
            self:selectedIndex_(3)
        end))
        :pos(650,325)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("MATCH","MY_MATCH_REWARD"), color = cc.c3b(0xff,0xff,0xff), size = 24, align = ui.TEXT_ALIGN_CENTER}))
    
    self.scrollContent = display.newNode()
    local scrollViewRect = cc.rect(-CW * 0.5, -CH * 0.5, CW, CH)
    self.scroll_ = bm.ui.ScrollView.new({
            viewRect      = scrollViewRect,
            scrollContent = self.scrollContent,
            direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
            upRefresh = handler(self, self.onUpMatchRecodeList_)
        })
        :pos(CW / 2, CH / 2)
        :addTo(self.matchRecordView_)
    self.scroll_:hideScrollBar()
    self.matchRecordView_:hide()
    self:refreshMatchRecordListView()
end
function ArenaApplyPopup:onUpMatchRecodeList_()
    if self.curPage >= self.maxPage then
        return
    end
    self.needscroll_ = true
    if self.isloaded then
        self.isloaded = false
        self:onGetRecord(self.curPage + 1)
    end
end

function ArenaApplyPopup:initRecordView_()
    -- 战绩
    local list_w, list_h = LIST_WIDTH, 258
    self.recordView_ = self:createContain()

    cc.ui.UIPushButton.new({normal = "#pop_friend_back_button_normal.png", pressed = "#pop_friend_back_button_pressed.png"})
        :pos(26, 395)
        :addTo(self.recordView_)
        :add(display.newSprite("#pop_friend_back_icon.png"))
        :onButtonClicked(buttontHandler(self, function()
            self:selectedIndex_(1)
        end))

    local px, py = 36, 342
    self.scoreIcon_ = display.newSprite("#arena/match_bestScore.png")
        :pos(px, py)
        :addTo(self.recordView_)

    self.scoreIcon_:setScale(0.5)
    self.scoreDesc_ = ui.newTTFLabel({
        text = "",
        color=styles.FONT_COLOR.LIGHT_TEXT,
        size = 22,
        align = ui.TEXT_ALIGN_LEFT
    })
    :pos(px, py)
    :addTo(self.recordView_)

    local bg_w, bg_h = list_w, 300
    local bg = display.newScale9Sprite(
        "#frame_bg.png",
        POPUP_WIDTH/2, self.conHeight_/2 - 15,
        cc.size(bg_w, bg_h)
    ):addTo(self.recordView_)

    local titleBg_w, titleBg_h = list_w, 35
    local titleBg = display.newScale9Sprite("#setting_content_up_pressed.png",0 ,0 , cc.size(titleBg_w, titleBg_h))
        :align(display.TOP_CENTER, bg_w/2, bg_h)
        :addTo(bg)

    -- 时间、名次、奖励、操作
    local lblFontSz = 20
    local lblColor = cc.c3b(68, 84, 106)
    px = 110
    py = titleBg_h/2

    self.tsLbl_ = ui.newTTFLabel({
        text=bm.LangUtil.getText("MATCH","MATCHTIME"),
        color=lblColor,
        size=lblFontSz,
        align=ui.TEXT_ALIGN_CENTER,
    })
    :pos(px, py)
    :addTo(titleBg)

    px = px + 130
    self.rankLbl_ = ui.newTTFLabel({
        text=bm.LangUtil.getText("MATCH","MATCHRANK"),
        color=lblColor,
        size=lblFontSz,
        align=ui.TEXT_ALIGN_CENTER,
    })
    :pos(px, py)
    :addTo(titleBg)

    px = px + 190
    self.rewardLbl_ = ui.newTTFLabel({
        text=bm.LangUtil.getText("MATCH","MATCHREWARD"),
        color=lblColor,
        size=lblFontSz,
        align=ui.TEXT_ALIGN_CENTER,
    })
    :pos(px, py)
    :addTo(titleBg)

    px = px + 235
    self.actLbl_ = ui.newTTFLabel({
        text=bm.LangUtil.getText("MATCH","MATCHACT"),
        color=lblColor,
        size=lblFontSz,
        align=ui.TEXT_ALIGN_CENTER,
    })
    :pos(px, py)
    :addTo(titleBg)

    self.recordList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-list_w * 0.5, -list_h * 0.5, list_w, list_h),
            upRefresh = handler(self, self.onUpRecodeList_)
        },
        ArenaMatchRecordItem
    )
    :pos(list_w/2 + 13, list_h/2 + 22)
    :addTo(self.recordView_)

    self.recordList_:setNotHide(true)
    self.recordList_:addEventListener("ITEM_EVENT",handler(self, self.onItemEvent_))

    self.noRecordLbl_ = ui.newTTFLabel({
        text=bm.LangUtil.getText("MATCH", "NO_RECORD"),
        color = styles.FONT_COLOR.LIGHT_TEXT,
        size=32,
        align=ui.TEXT_ALIGN_CENTER,
    })
    :pos(list_w/2 + 20, list_h/2+20)
    :addTo(self.recordView_)

    self:refreshInitRuleView()
    self.recordView_:hide()
end

function ArenaApplyPopup:onUpRecodeList_()
    self:setLoading(true)
    nk.MatchRecordManager:asyncHallMatchLog(self.matchLevel_, self.page_ + 1)
end

function ArenaApplyPopup:onItemEvent_(evt)
    local data = evt.data
    self.controller_:getMatchAddress1(handler(self, self.getMatchAddressCallback))

    local real = data.reward.real
    real.data = data
    real.logid = data.logid
    self:openScoreExchangePopup_(real)
end

function ArenaApplyPopup:getMatchAddressCallback(params)
    self.addressData_ = params
    if self.scoreE2PPopup_ and self.scoreE2PPopup_["refreshTelEdit"] then
        self.scoreE2PPopup_:refreshTelEdit(self.addressData_)
    end
end

function ArenaApplyPopup:openScoreExchangePopup_(real, addressData)
    if real then
        -- // 1实物弹地址，2现金卡弹PIN码，3暂定E2P奖励
        if real.type == 1 then
            display.addSpriteFrames("scoremarket_texture.plist", "scoremarket_texture.png", function()
                ScoreExchangePopup.new(self.controller_, real, addressData,  handler(self, self.onExchange_), handler(self, self.onOpenAddressPopup_)):show()
            end)
        elseif real.type == 2 then
            display.addSpriteFrames("scoremarket_texture.plist", "scoremarket_texture.png", function()
                display.addSpriteFrames("upgrade_texture.plist", "upgrade_texture.png", function()
                    local ScoreTrackCardExchangePopup = import("app.module.scoremarket.ScoreTrackCardExchangePopup")
                    ScoreTrackCardExchangePopup.new(real, self.controller_):show()
                end)
            end)
        elseif real.type == 3 then
            display.addSpriteFrames("scoremarket_texture.plist", "scoremarket_texture.png")
            self.scoreE2PPopup_ = ScoreExchangeE2PPopup.new():show(real)
            self.scoreE2PPopup_:refreshTelEdit(self.addressData_)
        end
    end
end

-- 请求PHP兑换某一物品
function ArenaApplyPopup:onExchange_(real)
    local ScoreTrackRealExchangePopup = import("app.module.scoremarket.ScoreTrackRealExchangePopup")
    ScoreTrackRealExchangePopup.new(real, self.controller_):show()
end

function ArenaApplyPopup:onOpenAddressPopup_(evt, real)
    ScoreAddressPopup.new(self.controller_):show(function(addressData)
        if real then
            self:openScoreExchangePopup_(real, addressData)
        end
    end)
end

-- 刷新
function ArenaApplyPopup:refreshInitRuleView()
    if self.scoreIcon_ then
        local px, py = self.scoreIcon_:getPosition()
        local sz1 = self.scoreIcon_:getContentSize()
        local sz2 = self.scoreDesc_:getContentSize()
        self.scoreDesc_:pos(px + sz1.width*0.5 + sz2.width*0.5-20, py-3)
    end
end

function ArenaApplyPopup:matchAsyncRecordLog_(evt)
    self:setLoading(false)

    self.isAsyncRecordLog_ = true
    local cfg = evt.data
    if self.scoreDesc_ then
        if cfg.rank == nil or cfg.time == nil then
            self.scoreDesc_:setString(bm.LangUtil.getText("USERINFOMATCH","NOREWARD"))
        else
            local ts = bm.TimeUtil:getTimeStampString(cfg.time,"-")
            self.scoreDesc_:setString(bm.LangUtil.getText("MATCH", "BESTRECORD", cfg.rank, ts))
        end
    end

    if self.recordList_ then
        self.page_ = cfg.page
        self.recordList_:setData(cfg.data, true)

        if #cfg.data == 0 then
            self.noRecordLbl_:show()
        else
            self.noRecordLbl_:hide()
        end
    end

    self:refreshInitRuleView()
end

-- 规则面板
function ArenaApplyPopup:initRuleView_()
    -- 规则
    self.ruleView_ = self:createContain()
    display.newScale9Sprite(
            "#frame_bg.png",
            POPUP_WIDTH/2,self.conHeight_/2,
            cc.size(LIST_WIDTH, LIST_HEIGHT + 10)
            )
        :addTo(self.ruleView_)

    self.ruleTips_ = ScrollLabel.new(
        {
            text  = '',
            color = cc.c3b(255, 255, 255),
            size  = 25,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions=cc.size(POPUP_WIDTH - 50, self.conHeight_ - 42)
        },
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
        })
        :align(display.CENTER_TOP, POPUP_WIDTH/2, self.conHeight_/2)
        :addTo(self.ruleView_)

    cc.ui.UIPushButton.new({normal = "#pop_friend_back_button_normal.png", pressed = "#pop_friend_back_button_pressed.png"})
        :pos(26, 395)
        :addTo(self.ruleView_)
        :add(display.newSprite("#pop_friend_back_icon.png"))
        :onButtonClicked(buttontHandler(self, function()
            self:selectedIndex_(1)
        end))

    self.ruleView_:hide()
end

function ArenaApplyPopup:onTimeChange()
    LoadMatchControl:getInstance():getMatchById(self.matchListIndex_,function(matchData)
        self.matchData_ = matchData
        if matchData then
            if matchData.factor1 then
                self.starttipCfg_.setString(matchData.factor1).txtVisible3(true)
                self.leftTime_ = matchData.leftTime - (os.time()-matchData.serverTime)
                if not self.matchTimeChangeId_ then
                    self.matchTimeChangeId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_TIME_CHANGE, handler(self,self.onTimeChange))
                end

                if not self.action_ then
                    self.action_ = self:schedule(function ()
                        self:countFunc()
                    end, 1)
                end
            else
                self.starttipCfg_.setString(matchData.factor).txtVisible3(false)
            end

            self:refreshTxtPos()
        end
    end)

    local isReg = false
    if nk.match.MatchModel.regList and nk.match.MatchModel.regList[self.matchLevel_]
        and nk.match.MatchModel.regList[self.matchLevel_]~=0 
        and nk.match.MatchModel.regList[self.matchLevel_]~="" then
        isReg = true
    end

    self:checkRegStatus(isReg)
    self:dealFinalStr()
end

function ArenaApplyPopup:countFunc()
    self.leftTime_ = self.leftTime_ - 1
    if self.leftTime_<0 then self.leftTime_ = 0 end
    local timeStr
    local timeTable
    if self.leftTime_ > 24*3600 then
        timeStr,_ = math.modf(self.leftTime_/(24*3600))

        if not self.leftTimeStr3_ then
            self.leftTimeStr3_ = self.averTimeCfg_.txt3:getString()
        end

        if not self.leftTimeStrDayStr3_ then
            self.leftTimeStrDayStr3_ = "วัน"
            self.averTimeCfg_.txt3:setString(self.leftTimeStrDayStr3_)
        end
    else
        timeStr = bm.TimeUtil:getTimeString1(self.leftTime_)
        timeTable = string.split(timeStr,":")
        if timeTable[1]=="00" then
            if timeTable[2]=="00" then
                timeStr = timeTable[3]
            else
                timeStr = timeTable[2]..":"..timeTable[3]
            end
        end

        if self.leftTimeStrDayStr3_ then
            self.averTimeCfg_.txt3:setString(self.leftTimeStr3_)
            self.leftTimeStrDayStr3_ = nil
        end
    end
    self.averTimeCfg_.txt1:setString("การแข่งจะเริ่มในอีก");
    -- self.averTime_:setString(bm.LangUtil.getText("MATCH", "LEFTTIMESTART",timeStr))
    self.averTimeCfg_.setString(timeStr).show();
    -- self.leftStartTime_:setString("")
    self.leftStartTimeCfg_.hide();
end

function ArenaApplyPopup:dealFinalStr(isReged)
    local appendStr = self.finalStr_ or ""
    self.conditionlbl_:setString(appendStr)    
    bm.fitSprteWidth(self.conditionlbl_, 320)

    local isReg = false
    if nk.match.MatchModel.regList and nk.match.MatchModel.regList[self.matchLevel_]
        and nk.match.MatchModel.regList[self.matchLevel_]~=0 
        and nk.match.MatchModel.regList[self.matchLevel_]~="" then
        isReg = true
    end

    if isReged then isReg = true end
    self.helpBtn_:setVisible(false)
    self.conditionlbl_:setTextColor(cc.c3b(0xeb, 0x91, 0x48))

    if not isReg and self.matchData_ then
        local condition = self.matchData_.condition
        local canReg = true
        if self.needReduce and self.matchData_.playTimes and self.matchData_.playTimes>0 and 
            self.matchData_.leftTimes and self.matchData_.leftTimes<1 then
            canReg = false
        end

        if canReg and condition.chips then
            if tonumber(nk.userData.money)<tonumber(condition.chips) then
                canReg = false
            end
        end

        if canReg and condition.score then
            if tonumber(nk.userData.score)<tonumber(condition.score) then
                canReg = false
            end
        end

        local gameCouponStatus = nil
        local goldCouponStatus = nil
        local gcoinsStatus = nil
        if canReg and condition.gameCoupon then
            gameCouponStatus = 1
            if tonumber(nk.userData.gameCoupon)<tonumber(condition.gameCoupon) then
                gameCouponStatus = -1
            end
        end

        if canReg and condition.gcoins then
            gcoinsStatus = 1
            if tonumber(nk.userData.gcoins)<tonumber(condition.gcoins) then
                gcoinsStatus = -1
            end
        end

        if canReg and condition.goldCoupon then
            goldCouponStatus = 1
            if tonumber(nk.userData.goldCoupon)<tonumber(condition.goldCoupon) then
                goldCouponStatus = -1
                canReg = false
            end
        end

        local tempCanReg = true
        if (gameCouponStatus==-1 and gcoinsStatus==-1) or 
           (not gameCouponStatus and gcoinsStatus==-1) or 
           (gameCouponStatus==-1 and not gcoinsStatus) then
           tempCanReg = false
        end

        if canReg and not tempCanReg then
            canReg = false
        end

        -- 门票处理
        self.regUseTickets_ = false
        self.haveTickets_ = true
        if self.matchData_ and self.matchData_.ticketInfo and self.matchData_.ticketInfo.name then
            -- 检测有没有门票
            if nk.MatchTickManager:getTickByMatchLevel(self.matchData_.id) then
                self.regUseTickets_ = true
                canReg = true
                self.conditionlbl_:setString(self.matchData_.ticketInfo.name)
            elseif self.matchData_ and self.matchData_.ticketOnly==1 then
                self.regUseTickets_ = true
                self.haveTickets_ = false
                canReg = false
                self.conditionlbl_:setString(self.matchData_.ticketInfo.name)
            end
        end

        if not canReg then
            self.conditionlbl_:setTextColor(cc.c3b(0xff, 0x00, 0x00))
            self.helpBtn_:setVisible(true)
            self.conditionlbl_:setPosition(POPUP_WIDTH - 200 - 20, 275)
        else
            self.conditionlbl_:setPosition(POPUP_WIDTH - 200, 275)
        end
    else
        self.conditionlbl_:setPosition(POPUP_WIDTH - 200, 275)
        -- 门票处理
        self.regUseTickets_ = false
        self.haveTickets_ = true
        if self.matchData_ and self.matchData_.ticketInfo and self.matchData_.ticketInfo.name then
            -- 检测有没有门票
            if nk.MatchTickManager:getTickByMatchLevel(self.matchData_.id) then
                self.regUseTickets_ = true
                self.conditionlbl_:setString(self.matchData_.ticketInfo.name)
            elseif self.matchData_ and self.matchData_.ticketOnly==1 then
                self.regUseTickets_ = true
                self.haveTickets_ = false
                self.conditionlbl_:setString(self.matchData_.ticketInfo.name)
            end
        end
    end
end

-- 检测是否已经注册
function ArenaApplyPopup:checkRegStatus(value)
    local isReg = value or false
    self.applyIcon_:setVisible(not isReg)
    self.applyIcon2_:setVisible(isReg)
    self.apply_btn:getButtonLabel("normal"):setString(isReg and bm.LangUtil.getText("MATCH", "CANCELREGISTER") or bm.LangUtil.getText("MATCH", "REGISTER"))
    if not value and not self:isScorePool_() then
        self:initProTime()
        self.progBar_:hide()
        self.leftStartTimeCfg_.hide()
        self.progTxt_:setString("")
    else
        self:onProTime() 
    end

    if not isReg then
        self:getOnlineCnt_()
    end
end

function ArenaApplyPopup:alignRuleTxt()
    local size1 = self.ruleBtn_:getContentSize()
    local size2 = self.bottom_tip:getContentSize()
    local x1,y1 = self.ruleBtn_:getPosition()
    local x2,y2 = self.bottom_tip:getPosition()
    self.bottom_tip:setPosition(x1-size1.width-size2.width,y2)
end

function ArenaApplyPopup:showPopupPanel(parent)
    if not self.regListenerId_ then
        self.regListenerId_ = bm.EventCenter:addEventListener(MatchEventHandler.REGISTER_STATE_CHANGED, handler(self,self.regStateChanged_))
    end

    nk.PopupManager:addPopup(self)

    return self
end

function ArenaApplyPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function ArenaApplyPopup:hidePopupPanel()
    self:hide()
end

function ArenaApplyPopup:onShowed()
    if self.awardList_ then
        self.awardList_:update()
    end
    if self.ruleTips_ then
        self.ruleTips_:update()
    end
    if self.recordList_ then
        self.recordList_:setScrollContentTouchRect()
        self.recordList_:update()
    end

    if self.matchRecordList_ then
        self.matchRecordList_:setScrollContentTouchRect()
        self.matchRecordList_:update()
    end

    if not self.matchAsyncRecordLogId_ then
        self.matchAsyncRecordLogId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_ASYNC_HALL_RECORD_LOG, handler(self, self.matchAsyncRecordLog_))
    end
end

function ArenaApplyPopup:onMatchPush_(evt)
    if self.matchLevel_ == evt.data.matchlevel then
        if self.isRegistered_ and self.matchData_ and self.matchData_.push==1 then
            self.pushBtn_:show()
            if self.matchData_.type==2 then
                self.pushBtn_:setPositionY(158)
            else
                self.pushBtn_:setPositionY(192)
            end
            if evt.data.open==1 then
                self.pushBtn_:setButtonSelected(true)
            else
                self.pushBtn_:setButtonSelected(false)
            end
        end
    end
end

function ArenaApplyPopup:regStateChanged_(evt)
    if self.matchLevel_ == evt.data.matchlevel then
        self.isReging_ = false -- 是否正在
        self.apply_btn:setButtonEnabled(true)
        self:checkRegStatus(evt.data.isReg)
        self:dealFinalStr(true)
        self.isRegistered_ = evt.data.isReg
        self.pushBtn_:hide()
        if self.isRegistered_ and self.matchData_ and self.matchData_.push==1 then
            nk.socket.MatchSocket:getPushInfo(self.matchLevel_)
        end
    end
end

function ArenaApplyPopup:onBtnApplyClicked(isProAuto)
    if not isProAuto then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end

    if not nk.socket.MatchSocket:isConnected() then
        self.regCallback_()
        self:hidePopupPanel()
        return
    end

    local isReg = false
    if nk.match.MatchModel.regList and nk.match.MatchModel.regList[self.matchLevel_]
        and nk.match.MatchModel.regList[self.matchLevel_]~=0 
        and nk.match.MatchModel.regList[self.matchLevel_]~="" then
        isReg = true
    end

    -- 报名 OR 不报
    if self.matchData_ then
        if self.isReging_ then
            return
        else
            self.isReging_ = true -- 是否正在报名
            self.apply_btn:getButtonLabel("normal"):setString(isReg and bm.LangUtil.getText("MATCH", "CANCELREGISTER1") or bm.LangUtil.getText("MATCH", "REGISTER1"))
            self.apply_btn:setButtonEnabled(false)
            if isReg then -- 取消报名走的通道
                self.regCallback_()
                return
            end
        end
        nk.userData.useTickType_ = nk.MatchTickManager.TYPE3-- 个人档门票弹出框使用门票
        nk.match.MatchModel:regLevel(
            self.matchData_.id,
            function(flag)
                if self.matchData_ then
                    if flag==1 then

                    elseif flag==-1 then

                    elseif flag==-2 then
                        self.regCallback_()
                        self:hidePopupPanel()
                        return
                    elseif flag==-3 then
                        -- 必须用门票报名
                        self.onHelpCallBack_ = nil
                        self:onHelpBtn_()
                    elseif flag==-4 then
                        self.onHelpCallBack_ = function()
                            self:onBtnApplyClicked(isProAuto)
                        end
                        self:onHelpBtn_()
                    elseif flag==-5 then
                        -- 筹码不足
                        bm.HttpService.POST(
                            {mod = "table", act = "siteInRoom", sb = self.matchData_.condition.chips, match = 1},
                            function (data)
                                local retData = json.decode(data)
                                    if retData and retData.showBox == 1 and retData.box >= 3 then
                                        local minBuy = self.matchData_.condition.chips
                                        retData.minBuy = minBuy
                                        if retData.box == 3 then
                                            FirstPayPopup.new():show()
                                        elseif retData.box > 3 then
                                            if retData.box < 10 then
                                                GuidePayPopup.new(6, nil, retData):show()
                                            elseif retData.box == 11 then
                                                GuidePayPopup.new(106, nil, retData):show()
                                            end
                                        end
                                    else
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHCHIPS"))
                                        self:onHelpBtn_()
                                    end
                            end,
                            function ()
                            end
                        )
                    elseif flag==-6 then
                        -- 比赛券
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGAMECOUPON"))
                        self:onHelpBtn_()
                    elseif flag==-7 then
                        -- 金券
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOUPON"))
                        self:onHelpBtn_()
                    elseif flag==-8 then
                        -- 提示对不起您的门票已不能使用
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGTICKETSFIAL2"))
                    elseif flag==-9 then
                        -- 注册回调
                        local fun = function()
                            if self.matchData_ then
                                self:dealFinalStr()
                            end
                        end
                        -- 重新拉取所有门票
                        -- 提示对不起您的门票已不能使用
                        nk.MatchTickManager:synchPhpTickList(fun)
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGTICKETSFIAL1"))
                    elseif flag==-10 then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGISTERFAIL"))
                    elseif flag==-11 then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGISTERFAIL"))
                    elseif flag==-12 then
                        -- 现金币不足
                        nk.TopTipManager:showTopTip(nk.match.MatchModel.NOTENOUGHSCORE)
                        self:onHelpBtn_()
                    elseif flag==-13 then
                        -- 黄金币不足
                        bm.HttpService.POST(
                            {mod = "table", act = "siteInRoom", sb = self.matchData_.condition.gcoins, match = 1, isgcoin = 1},
                            function (data)
                                local retData = json.decode(data)
                                    if retData and retData.showBox == 1 and retData.box >= 3 then
                                        local minBuy = self.matchData_.condition.gcoins
                                        retData.minBuy = minBuy
                                        if retData.box == 11 then
                                            GuidePayPopup.new(106, nil, retData):show()
                                        end
                                    else
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOIN"))
                                        self:onHelpBtn_()
                                    end
                            end,
                            function ()
                            end
                        )
                    end

                    if flag~=1 and flag~=-1 then
                        self.isReging_ = false -- 是否正在
                        self.apply_btn:setButtonEnabled(true)
                        self:checkRegStatus(isReg)
                        self:dealFinalStr(isReg)
                    end
                end
            end
        )
    end
end

function ArenaApplyPopup:onBtnRuleSwitchClicked()
    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
    if self.rewardTips_:isVisible() then
        self.rewardTips_:setVisible(false)
        if self.ruleTips_ then
            self.ruleTips_:setVisible(true)
        end

        self.bottom_tip:setString(bm.LangUtil.getText("MATCH", "MATCHAWARD"))
    else
        self.rewardTips_:setVisible(true)
        if self.ruleTips_ then
            self.ruleTips_:setVisible(false)
        end

        self.bottom_tip:setString(bm.LangUtil.getText("MATCH", "MATCHRULE"))
    end

    self:alignRuleTxt()
end

function ArenaApplyPopup:onBtnSwitchClicked()
    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
end

function ArenaApplyPopup:initProTime()
    self.aTime_ = ArenaApplyPopup.FEE_TOTAL_TIME/ArenaApplyPopup.FEE_TOTAL_CNT--
    self.times_ = {}
    table.insert(self.times_, #self.times_+1, self.aTime_)
end

function ArenaApplyPopup:onProTime()
    if not self.firstTime_ then
        self.firstTime_ = os.clock()
        self.twoTime_ = self.firstTime_
    else
        self.twoTime_ = self.firstTime_
        self.firstTime_ = os.clock()
        local ds = self.firstTime_ - self.twoTime_
        ds = ds > self.aTime_ and self.aTime_ or ds
        table.insert(self.times_, #self.times_+1, ds)
    end

    if tonumber(self.matchData_.type)==1 then
        self:renderAverTime()
    end
end

function ArenaApplyPopup:renderAverTime()
    local total = 0
    local len = #self.times_
    for i=1,len do
        total = total + self.times_[i]
    end
    local at = total/len
    local ts = at*ArenaApplyPopup.FEE_TOTAL_CNT

    local lefttime
    if self.onlineCnt_ then 
        len = self.onlineCnt_
        if self.onlineCnt_ == ArenaApplyPopup.FEE_TOTAL_CNT then
            lefttime=0
        end
    else
        len = len > ArenaApplyPopup.FEE_TOTAL_CNT and ArenaApplyPopup.FEE_TOTAL_CNT or len
    end

    if not lefttime then
        lefttime = (ArenaApplyPopup.FEE_TOTAL_CNT - len)*at
        lefttime = lefttime < 1 and 1 or lefttime
    end

    if not self.onlineCnt_ then self.onlineCnt_ = 1 end
    lefttime = ArenaApplyPopup.FEE_TOTAL_TIME - ArenaApplyPopup.FEE_TOTAL_TIME*self.onlineCnt_/ArenaApplyPopup.FEE_TOTAL_CNT

    local val = math.modf(lefttime)
    self.leftStartTimeCfg_.setString(val).show()
end

-- 针对现金币场显示总奖池
function ArenaApplyPopup:proScoreMatchCondition_()
    if self:isScorePool_() then
        if not self.scorePoolLbl_ then
            local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
            local lblStr = bm.LangUtil.getText("MATCH", "SCORE_POOL", " "..tostring("0 "..bm.LangUtil.getText("BANK", "MAIN_TAB_TEXT")[2])) or "" 
            self.scorePoolLbl_ = SimpleColorLabel.html(lblStr, styles.FONT_COLOR.LIGHT_TEXT, cc.c3b(0xff, 0xff, 0x0), 20, 1)
            self.scorePoolLbl_:setPosition(self.leftTimes_:getPosition())
            self.scorePoolLbl_:addTo(self.mainView_)
        end
        self.leftTimes_:hide()
    end
end

function ArenaApplyPopup:refresScorePool_(num)
    if self:isScorePool_() and self.scorePoolLbl_ then
        local totalScore = num * self.matchData_.condition.score
        self.scorePoolLbl_.setString(2, " "..totalScore.." "..bm.LangUtil.getText("BANK", "MAIN_TAB_TEXT")[2])
    end
end

function ArenaApplyPopup:isScorePool_()
    -- rewardType 1固定奖池，2动态奖池(需要动态计算显示)
    if self.matchData_ and self.matchData_.condition and self.matchData_.condition.score and self.matchData_.rewardType then
        return true
    end

    return false
end

function ArenaApplyPopup:setRegOnline_(evt)
    local data  = evt.data
    if not data then return end
    if self.matchLevel_==data.matchlevel then
        self:renderOnlineCount(data.userCount)
    end
end

function ArenaApplyPopup:renderOnlineCount(val)
    if val < 0 then
        val = 0
    end

    if tonumber(self.matchData_.type)==1 then
        self.onlineCnt_ = val
        self.progTxt_:setString(val .. "/" .. ArenaApplyPopup.FEE_TOTAL_CNT)
        self.progBar_:setValue(val/ArenaApplyPopup.FEE_TOTAL_CNT)
        self.progTxt_:show()
        self.progBar_:show()
        
        self:onProTime()
        self.progTxt_:setPosition(POPUP_WIDTH - 200, 160)
    else
        self.progBar_:hide()
        self.progTxt_:setString(bm.LangUtil.getText("MATCH","MATCHREGNUM",val))
        self.progTxt_:setPosition(POPUP_WIDTH - 200, 200)
    end

    if self:isScorePool_() then
        self:refresScorePool_(val)
    end
end

function ArenaApplyPopup:getOnlineCnt_()
    if self.isReging_ then
        return
    end

    if self.matchData_ and self:isScorePool_() then
        if nk.socket.MatchSocket:isConnected() then
            nk.socket.MatchSocket:getRegedCount(self.matchData_.id)
        else
            self:performWithDelay(function()
                nk.socket.MatchSocket:getRegedCount(self.matchData_.id)
            end, 2)
        end
    end
end

function ArenaApplyPopup:onGetRecord(page)
     bm.HttpService.POST(
            {
                mod="Match",
                act="getChampions",
                level=self.matchLevel_,
                p=page,
                limit = 12
            },function(data)
                local curData = json.decode(data)
                if curData and curData.tips then
                    self.matchTipsDesc_:setString(curData.tips)
                    self:refreshMatchRecordListView()
                end
                if curData and curData.list then
                    self.isloaded = true
                    self.curPage = self.curPage + 1
                    if #(curData.list) == 12 then
                        self.maxPage = self.maxPage + 1
                    end
                    if #(curData.list) > 0 then
                        self:updateData(curData.list)
                    end
                end
            end,function()
            end)
end

function ArenaApplyPopup:updateData(data)
    local count = self.curCount + #data
    local scrollHeight = (math.floor((count -1)/3) + 1) * 93 +30
    local curP = self.scrollContent:getContentSize().height
    self.scrollContent:setContentSize(682,scrollHeight)
    for i = 1,self.curCount do
        self.infoitem_[i]:pos(((i-1) % 3 - 1) * 247,scrollHeight / 2 - 45 - math.floor((i -1) /3) * 93)
    end
    for i = self.curCount + 1,count do
        local infoData = {}
        infoData = data[i - self.curCount]
        self.infoitem_[i] = ArenaUserInfoItem.new(infoData)
        self.infoitem_[i]:pos(((i-1) % 3 - 1) * 247,scrollHeight / 2 - 45 - math.floor((i -1) /3) * 93)
        self.infoitem_[i]:addTo(self.scrollContent)
    end
    self.curCount = count
    self.scroll_:update()
    if self.needscroll_ then
        self.scroll_:scrollTo(curP + 20)
    end
    if #data < 12 then
        self.undertips_ = cc.ui.UILabel.new({text = bm.LangUtil.getText("MATCH","ONLY_SHOW"), color = display.COLOR_WHITE})
        self.undertips_:pos( - self.undertips_:getContentSize().width / 2, - scrollHeight / 2 + 10)
        self.undertips_:addTo(self.scrollContent)
    end
end

function ArenaApplyPopup:refreshMatchRecordListView()
    local px, py = self.matchTipsDesc_:getPosition()
    local px = 20
    local sz2 = self.matchTipsDesc_:getContentSize()
    self.matchTipsDesc_:pos(px + sz2.width*0.5, py)
    local px, py = self.matchTipsGetDesc_:getPosition()
    local px = 20
    local sz2 = self.matchTipsGetDesc_:getContentSize()
    self.matchTipsGetDesc_:pos(px + sz2.width*0.5, py)
end

return ArenaApplyPopup
