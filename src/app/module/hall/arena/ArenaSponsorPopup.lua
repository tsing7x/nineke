--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-01-13 16:20:15
--
local logger = bm.Logger.new("ArenaSponsorPopup")
local BubbleButton = import("boomegg.ui.BubbleButton")
local ScrollLabel = import("boomegg.ui.ScrollLabel")
local AnimationIcon = import("boomegg.ui.AnimationIcon")
local ArenaSponsorPopup = class("ArenaSponsorPopup", nk.ui.Panel)

ArenaSponsorPopup.WIDTH = 568;
ArenaSponsorPopup.HEIGHT = 363;

local BUTTON_DW, BUTTON_DH = 198, 58;

local ICON_WIDTH = 164
local ICON_HEIGHT = 164
local AVATAR_TAG = 101

function ArenaSponsorPopup:ctor(params)
    local width, height = ArenaSponsorPopup.WIDTH, ArenaSponsorPopup.HEIGHT;
    ArenaSponsorPopup.super.ctor(self, {ArenaSponsorPopup.WIDTH+30, ArenaSponsorPopup.HEIGHT+30})
    self:setCommonStyle(bm.LangUtil.getText("MATCH", "REALINFO"))
    self:addBgLight()
	-- 
	self.mainContainer_ = display.newNode():addTo(self);
	self.mainContainer_:setContentSize(width, height);
	self.mainContainer_:setTouchEnabled(true);
	self.mainContainer_:setTouchSwallowEnabled(false);
	-- 
	local px, py = 0, 0;
	local dw, dh = 540, 210
	py = height*0.5 - dh*0.5 - 65;
	self.border_ = display.newScale9Sprite("#panel_overlay.png", px, py, cc.size(dw, dh))
		:pos(px, py)
		:addTo(self.mainContainer_)

    local sz = {width=170,height=170}
	px = -width*0.5 + sz.width*0.5 + 32;

    self.iconBg_ = display.newScale9Sprite("#panel_overlay.png", px, py, cc.size(sz.width, sz.height+30))
        :addTo(self.mainContainer_)
    display.newSprite("#pop_userinfo_my_stuff_item_decoration.png")
        :scale(2)
        :addTo(self.iconBg_)
        :pos(sz.width/2,25)
	-- 
	self.px_, self.py_ = px, py;
    -- 
    self.animationIcon_ = AnimationIcon.new(nil, 1, 1)
        :pos(px, py+5)
        :addTo(self)
	-- 
	px = px + sz.width*0.5 + 36;
	py = py + sz.height*0.5;
	self.name_ = ui.newTTFLabel({
			text="",
			color=cc.c3b(0xff,0xd3,0x3b),
			size=24,
			align=ui.TEXT_ALIGN_LEFT,
		})
		:align(display.LEFT_TOP, px - 15, py)
		:addTo(self.mainContainer_)

	local dw = 330;
    local dh = 122;
    py = py - 36;
    px = px + dw*0.5 - 15;
    self.desc_ = ScrollLabel.new(
            {
                text="ทุกวันล็อกอินเข้าเกมส์ จะได้รับตั๋วห้องชิงมิกุ.ธัญพืชฟรี 1 ใบ ผู้ชนะเลิศจะได้รับมิกุ.ธัญพืช ไปรับประทานฟรี 1 ลัง โดยทุกวันจะเปิดห้องแข่งทุกๆครึ่งชั่วโมง ตั้งแต่เวลา 08:00~00:00 น. รีบลงชื่อตอนนี้เลยสิ!",
                color=cc.c3b(0xb0,0x87,0xca),
                size=20,
                align = ui.TEXT_ALIGN_LEFT,
                valign = ui.TEXT_VALIGN_TOP,
                dimensions=cc.size(dw, dh)
            },
            {
                viewRect = cc.rect(-dw * 0.5, -dh * 0.5, dw, dh)
            })
        :pos(px, py - dh*0.5)
        :addTo(self.mainContainer_)

	-- 立即参与  ร่วมทันที
    self.btnLbl_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0), size = 36, align = ui.TEXT_ALIGN_CENTER});
    self.bubbleBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed="#common_btn_yellow_pressed.png"},{scale9 = true})
            :setButtonLabel("normal", self.btnLbl_)
            :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:onBtnClick_()
            end)
            :setButtonSize(BUTTON_DW, BUTTON_DH)
            :pos(0, -height*0.5 + BUTTON_DH - 14)
            :addTo(self.mainContainer_)
	-- 关闭按钮
    px, py = width*0.5 - 26, height*0.5 - 28
    -- 
    self:addLinkUrl_();
    self:addCloseBtn()
end

function ArenaSponsorPopup:addLinkUrl_()
    local px, py = self.border_:getPosition();
    local sz = self.border_:getContentSize();
    py = py - sz.height*0.5;
    px = px + sz.width*0.5;
    self.linkUrl_ = display.newNode()
        :pos(px, py)
        :addTo(self.mainContainer_)
    -- 
    local lbl = ui.newTTFLabel({
            text="เช็ครายละเอียด>>", -- 查看该奖品更多信息
            color=cc.c3b(0xff, 0xff, 0xff),
            size=18,
            align=ui.TEXT_ALIGN_LEFT,
        })
        :addTo(self.linkUrl_)
    sz = lbl:getContentSize();
    px = -sz.width*0.5;
    py = -sz.height*0.5;
    lbl:pos(px, py)
    -- rounded_rect_6.png transparent.png    
    local btn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9=true})
        :setButtonSize(sz.width, sz.height)
        :pos(px, py)
        :addTo(self.linkUrl_)
        :onButtonClicked(buttontHandler(self, self.onlinkUrlTouchHandler_))
        :onButtonPressed(function()
            
        end)
        :onButtonRelease(function()
            
        end)
    local splitLine = display.newScale9Sprite(
            "#user-info-desc-button-background-up-line.png",
            px, py-12,
            cc.size(sz.width, 2)
        )
        :addTo(self.linkUrl_)
    splitLine:setColor(cc.c3b(0xff, 0xff, 0xff))
end

function ArenaSponsorPopup:initView_()

end

function ArenaSponsorPopup:render_()
	-- self.data_.first.real
	self.name_:setString(self.data_.first.real.name or "")
	self.desc_:setString(self.data_.first.real.desc or "")
	self:loadImg_(self.data_.first.real.img)
    -- 
    if self.data_.first.real.link and string.len(self.data_.first.real.link)>0 then
        self.linkUrl_:show();
    else
        self.linkUrl_:hide(); 
    end
    -- self.matchData_
    local isReg = self:isReg();
    self.bubbleBtn_:getButtonLabel("normal"):setString(not isReg and bm.LangUtil.getText("MATCH", "REGISTER") or bm.LangUtil.getText("MATCH", "CANCELREGISTER"))
    local sz = self.btnLbl_:getContentSize();
    local offVal = 10;
    if sz.width - offVal > BUTTON_DW then
        local scaleVal = BUTTON_DW/(sz.width + offVal);
        self.btnLbl_:setScale(scaleVal)
    end
end

function ArenaSponsorPopup:isReg()
    local isReg = false
    if self.matchData_ then
        local matchLevel = self.matchData_.id;
        if nk.match.MatchModel.regList and nk.match.MatchModel.regList[matchLevel]
            and nk.match.MatchModel.regList[matchLevel]~=0 
            and nk.match.MatchModel.regList[matchLevel]~="" then
            isReg = true
        end
    end
    return isReg
end

function ArenaSponsorPopup:loadImg_(img)
    if img then
        self:setLoading(true)

        local url = nk.userData.cdn..img
        self.animationIcon_:onData(url, ICON_WIDTH, ICON_HEIGHT, function()
            self:setLoading(false)
        end)
    end
end

function ArenaSponsorPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(self.px_, self.py_)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function ArenaSponsorPopup:show(goods, isModal, isCentered, px, py)
	self.data_ = goods;
    self.matchData_ = goods;
    px = px or display.cx;
    py = py or display.cy;
    nk.PopupManager:addPopup(self, isModal, isCentered, true, true, nil, 1.2)
    self:pos(px, py)
    self:render_();
end

function ArenaSponsorPopup:onShowed()
    
end

function ArenaSponsorPopup:onCleanup()
	-- body
end

function ArenaSponsorPopup:onClose()
    self:close()
end

function ArenaSponsorPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function ArenaSponsorPopup:onBtnClick_(evt)
    if not nk.socket.MatchSocket:isConnected() then
        self:close();
        return
    end
    -- 
	if self.matchData_ then
        local isReg = self:isReg();
        if isReg then
            bm.EventCenter:dispatchEvent({name="CancelRegMatch", data=self.matchData_.id})
            self:close();
        else
            nk.match.MatchModel:regLevel(
                self.matchData_.id,
                function(flag)
                    if self.matchData_ then
                        if flag==1 then
                            if device.platform == "android" or device.platform == "ios" then
                                cc.analytics:doCommand{command = "event",
                                    args = {eventId = "count_sponsorIcon_Apply", label=self.matchData_.name.."::"..self.matchData_.id}}
                            end
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
                                self:onBtnClick_()
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
                            self:onBtnClick_()
                        elseif flag==-9 then
                            -- 清空当前门票
                            nk.MatchTickManager.tickList_ = {}
                            -- Socket重新报名
                            self:onBtnClick_()
                            -- 重新拉取所有门票
                            nk.MatchTickManager:synchPhpTickList(nil)
                        elseif flag==-10 then
                            -- 清空当前门票
                            nk.MatchTickManager.tickList_ = {}
                            -- Socket重新报名
                            self:onBtnClick_()
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
end

-- 购买免费场次数
function ArenaSponsorPopup:buyPlayTimes_()
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
                    else -- data.ret==0
                        nk.ui.Dialog.new(bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_TIP")):show()
                        -- 
                        if self.onHelpCallBack_ then
                            self.onHelpCallBack_() 
                        end
                    end
                end
            end
        )
    end
end

function ArenaSponsorPopup:onlinkUrlTouchHandler_(evt)
    if self.data_ then
        local url = self.data_.first.real.link;
        local sign = self.data_.first.real.name;
        nk.OnOff:openSponsorWebView(sign, url);
    end
end

return ArenaSponsorPopup;