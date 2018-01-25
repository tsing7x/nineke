--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-10 16:38:12
--
local LoadMatchControl = import("app.module.match.LoadMatchControl")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local MatchRebuyPopup = class("MatchRebuyPopup", nk.ui.Panel)

local logger = bm.Logger.new("MatchRebuyPopup")
local WIDTH = 750
local HEIGHT = 480
local TOP = HEIGHT*0.5
local BOTTOM = -HEIGHT*0.5
local LEFT = -WIDTH*0.5
local RIGHT = WIDTH*0.5
local TOP_HEIGHT = 30
local PADDING = 15

local TOP_BUTTOM_WIDTH   = 78*0.8
local TOP_BUTTOM_HEIGHT  = 64*0.8

function MatchRebuyPopup:ctor(data)
    MatchRebuyPopup.super.ctor(self, {WIDTH+30, HEIGHT+30})
    self.canSend = true
    self.canBuy_ = true
    self:retain()
    self.level_ = nk.socket.MatchSocket.currentRoomMatchLevel
    self.priceList_ = {}
    self.data_ = data
    self:setNodeEventEnabled(true)
    self.title_ = ui.newTTFLabel({text = bm.LangUtil.getText("MATCH","REBUYTITLE"), color = cc.c3b(0xEF, 0xEA, 0x99), size = 32, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, HEIGHT * 0.5 - 18)
        :addTo(self)
    display.addSpriteFrames("match_rebuy.plist", "match_rebuy.png", handler(self, self.setupView))
end

function MatchRebuyPopup:onCleanup()
    -- 坑 倒计时结算时正好玩家点击rebuy
    local curScene = display.getRunningScene()
    if curScene and curScene.controller and curScene.controller.matchRebuyPopup_==self then
        curScene.controller.matchRebuyPopup_ = nil
    end
    if self.action then
        self:stopAction(self.action)
    end
    display.removeSpriteFramesWithFile("match_rebuy.plist", "match_rebuy.png")
    self:release()
end

function MatchRebuyPopup:setupView()
    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(WIDTH, HEIGHT*0.5))
        :pos(0, -10)
        :addTo(self)

    local buttonWidth,buttonHeight = 190,55
    self.cancelBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed="#common_btn_blue_pressed.png"}, {scale9 = true})
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("COMMON","CANCEL"), color = display.COLOR_WHITE}))
        :setButtonSize(buttonWidth, buttonHeight)
        :pos(0, -HEIGHT*0.5+35)
        :addTo(self)
        :onButtonClicked(function()
            nk.socket.MatchSocket:sendRebuy(-1)
            self:onClose()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        end)
    self.tipsLabel_ = ui.newTTFLabel({
            text = bm.LangUtil.getText("MATCH","REBUYTIPS"),
            color = cc.c3b(0x95, 0xa7, 0xd1),
            size = 18, align = ui.TEXT_ALIGN_CENTER}
        )
        :pos(0,-HEIGHT*0.5+90)
        :addTo(self)

    self.moneyLabel_ = SimpleColorLabel.addMultiLabel(
            bm.LangUtil.getText("MATCH","REBUYAVERAGE"),
            22,
            cc.c3b(0x80, 0xa0, 0xe1),
            cc.c3b(0xb8,0x9c,0xdc),
            cc.c3b(0x80, 0xa0, 0xe1)
        ).addTo(self)
    self.moneyLabel_.pos(0,162)
    self.moneyLabel_.setString(self.data_.money)

    self.timeLabel_ = SimpleColorLabel.addMultiLabel(
            bm.LangUtil.getText("MATCH","REBUYTIME"),
            22,
            cc.c3b(0xff,0xff,0xff),
            cc.c3b(0xfb,0xdd,0x37),
            cc.c3b(0xff,0xff,0xff)
        ).addTo(self,1000)
    self.timeLabel_.pos(0,130)

    local text = self.timeLabel_.txt2
    local crood = text:getPositionX()
    self.timeBg_ = display.newSprite("#match_rebuy_time_bg.png")
        :pos(crood,130)
        :addTo(self,1000-1)

    local list = {}
    local btn = nil

    local itemWidth,itemHeight = 180,216
    local offX = 4
    local startX = -WIDTH*0.5+itemWidth*0.5+10
    LoadMatchControl:getInstance():getMatchById(self.level_,function(matchData)
        if matchData then
            self.costType_ = "gcoins"
            self.costNum = 10000
            self.iconRes = "#common_gcoin_icon.png"
            -- 黄金币>现金币>游戏币>比赛券>金券，也就是优先口黄金币，黄金币不足扣现金币，，，
            if matchData.condition then
                if matchData.condition.gcoins then
                    self.costType_ = "gcoins"
                    self.costNum = tonumber(matchData.condition.gcoins)
                    self.iconRes = "#common_gcoin_icon.png"
                elseif matchData.condition.score then
                    self.costType_ = "score"
                    self.costNum = tonumber(matchData.condition.score)
                    self.iconRes = "#icon_score.png"
                elseif matchData.condition.chips then
                    self.costType_ = "money"
                    self.costNum = tonumber(matchData.condition.chips)
                    self.iconRes = "#chip_icon.png"
                elseif matchData.condition.gameCoupon then
                    self.costType_ = "gameCoupon"
                    self.costNum = tonumber(matchData.condition.gameCoupon)
                    self.iconRes = "#icon_gamecoupon.png"
                elseif matchData.condition.goldCoupon then
                    self.costType_ = "goldCoupon"
                    self.costNum = tonumber(matchData.condition.goldCoupon)
                    self.iconRes = "#icon_goldcoupon.png"
                end
            end
            
            for i=1,4,1 do
                btn = cc.ui.UIPushButton.new({normal = "#match_rebuy_item_common.png", pressed="#match_rebuy_item_down.png"}, {scale9 = true})
                :setButtonSize(itemWidth, itemHeight)
                :pos(startX+(offX+itemWidth)*(i-1), -11)
                :addTo(self)
                :onButtonClicked(function()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                    self:onRebuy(i)
                end)
                display.newSprite("#match_rebuy_item_light.png")
                    :scale(1.5)
                    :pos(0,10)
                    :addTo(btn)
                display.newSprite("#pop_loginreward_day"..(i+1)..".png")
                    :pos(0,10)
                    :addTo(btn)            

                ui.newTTFLabel({
                    text = bm.formatNumberWithSplit(math.floor(self.data_.money*matchData.rebuyChips[i])).." "..bm.LangUtil.getText("STORE","TITLE_CHIP"),
                    color = cc.c3b(0xff, 0xff, 0xff),
                    size = 24}
                )
                :pos(0,90)
                :addTo(btn)

                local icon_ = display.newSprite(self.iconRes)
                    :pos(0,-80)
                    :addTo(btn)

                local rebuyRule = matchData.rebuyRule
                rebuyRule = string.gsub(rebuyRule,"rebuyChips",matchData.rebuyChips[i])
                rebuyRule = string.gsub(rebuyRule,"num",self.data_.money)
                rebuyRule = string.gsub(rebuyRule,"cost",self.costNum)
                local script = "return "..rebuyRule
                local price = math.ceil(loadstring(script)())
                if i==1 and nk.userData[self.costType_] then
                    if price>nk.userData[self.costType_] then
                        self.canBuy_ = false
                        if self.showeded_==true then
                            nk.socket.MatchSocket:sendRebuy(-1)
                            self:onClose()
                            return
                        end
                    end
                end
                self.priceList_[i] = price
                local price_ = ui.newTTFLabel({
                    text = price,
                    color = cc.c3b(0xff, 0xff, 0xff),
                    size = 28,
                    align=ui.TEXT_ALIGN_LEFT}
                )
                :align(display.CENTER_LEFT)
                :pos(0,-80)
                :addTo(btn)
                local iconSize = icon_:getContentSize()
                local priceSize = price_:getContentSize()
                local startX_ = -priceSize.width*0.5
                icon_:setPositionX(startX_)
                price_:setPositionX(startX_+iconSize.width*0.5+2)

                display.newSprite("#match_rebuy_time_top_light.png")
                    :pos(0,100)
                    :addTo(btn)

                list[i] = btn
            end
        end
    end)
    if self and self.data_ and self.data_.time then
        self.totoalTime = self.data_.time
        self.openTime = os.time()
        self.timeLabel_.setString(self.totoalTime)
        local text = self.timeLabel_.txt2
        local crood = text:getPositionX()
        self.timeBg_:setPositionX(crood)

        self.action = self:schedule(function()
            local runTime = os.time() - self.openTime
            local leftTime = self.totoalTime - runTime
            if leftTime>9 then
                self.timeLabel_.setString(leftTime)
            else
                self.timeLabel_.setString("0"..leftTime)
            end
            local text = self.timeLabel_.txt2
            local crood = text:getPositionX()
            self.timeBg_:setPositionX(crood)
            -- 小于 1 自动关闭掉
            if leftTime<1 then
                self:onClose()
            end
        end,1)
    end
end

function MatchRebuyPopup:onRebuy(index,needAlert)
    if needAlert==true then
        self.canSend = true
    end
    if self.costType_ == "gcoins" then
        if needAlert==true or nk.userData.gcoins<self.priceList_[index] then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOIN"))
            return
        end
    elseif self.costType_ == "score" then
        if needAlert==true or nk.userData.score<self.priceList_[index] then
            nk.TopTipManager:showTopTip(nk.match.MatchModel.NOTENOUGHSCORE)
            return
        end
    elseif self.costType_ == "money" then
        if needAlert==true or nk.userData.money<self.priceList_[index] then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHCHIPS"))
            return
        end
    elseif self.costType_ == "gameCoupon" then
        if needAlert==true or nk.userData.gameCoupon<self.priceList_[index] then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGAMECOUPON"))
            return
        end
    elseif self.costType_ == "goldCoupon" then
        if needAlert==true or nk.userData.goldCoupon<self.priceList_[index] then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOUPON"))
            return
        end
    end

    --(提示验证当前黄金币数量)
    if self.canSend==true then
        self.canSend = false
        nk.socket.MatchSocket:sendRebuy(index)
    end
end

function MatchRebuyPopup:onShowed()
    
end

function MatchRebuyPopup:show()
    if self.canBuy_ then
        self:showPanel_(true,true,false)
        self.showeded_ = true  -- 已经显示了
    else
        nk.socket.MatchSocket:sendRebuy(-1)
        self:onCleanup()
    end
    return self
end

return MatchRebuyPopup
