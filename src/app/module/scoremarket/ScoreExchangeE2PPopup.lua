--
-- Author: hlf
-- Date: 2015-11-20 12:26:51
-- E2P 兑换确认框
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ScoreExchangeE2PPopup = class("ScoreExchangeE2PPopup", nk.ui.Panel)

ScoreExchangeE2PPopup.WIDTH = 600
ScoreExchangeE2PPopup.HEIGHT = 400

local ICON_WIDTH = 150
local ICON_HEIGHT = 150
local AVATAR_TAG = 101

function ScoreExchangeE2PPopup:ctor(params)
	self.params_ = params
	self:initView_()
end

function ScoreExchangeE2PPopup:initView_()
	local width, height = ScoreExchangeE2PPopup.WIDTH, ScoreExchangeE2PPopup.HEIGHT
    ScoreExchangeE2PPopup.super.ctor(self, {width+25, height+25})
    self:addBgLight()
	self.mainContainer_ = display.newNode():addTo(self)
	self.mainContainer_:setContentSize(width, height)
	self.mainContainer_:setTouchEnabled(true)
	self.mainContainer_:setTouchSwallowEnabled(true)

    --顶部
    local dw, dh = 50, 155
    self.border_ = display.newScale9Sprite("#sm_dialog_border.png", 0, 0 + 10, cc.size(width - dw, height - dh))
        :addTo(self.mainContainer_)

    -- 确认
    local buttonDw, buttonDh = 150,52
    px, py = 0, -height*0.5 + buttonDh*1.0-8
    self.confirmBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_green_normal.png", 
            pressed = "#common_btn_green_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(buttonDw, buttonDh)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_CONFIRM") or "", color = cc.c3b(0xb2, 0xdc, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :pos(px, py)
        :onButtonClicked(buttontHandler(self, self.onConfirm_))
        :addTo(self.mainContainer_)

    local gdw, gdh = 205, 180
    local px, py = -width*0.5 + gdw*0.5 + 35, 35
    self.goodBg_ = display.newScale9Sprite("#sm_good_border1.png", px, py, cc.size(gdw, gdh))
    	:addTo(self.mainContainer_)

    self.goodLight_ = display.newSprite("#sm_good_light.png")
    	:pos(px, py-10)
    	:addTo(self)

    self.icon_ = display.newNode()
    	:size(ICON_WIDTH,ICON_HEIGHT)
    	:pos(px, py - 10)
    	:addTo(self)
    self.goodNBg_ = display.newScale9Sprite("#sm_border1.png", px, py-gdh*0.5-42*0.5 - 5, cc.size(gdw, 42))
    	:addTo(self.mainContainer_)

    self.name_ = ui.newTTFLabel({
    		text = "sm_border1",
    		color = cc.c3b(0xe5, 0xe8, 0x1c),
    		size = 26,
    		align = ui.TEXT_ALIGN_CENTER
    	}):pos(px, py-gdh*0.5-42*0.5 - 5):addTo(self)

    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()

    local ldw = width - gdw - 75
    self.desc_ = ui.newTTFLabel({
    		text = "",
    		color = cc.c3b(0xe5, 0xe8, 0x66),
    		size = 22,
    		align = ui.TEXT_ALIGN_LEFT,
    		dimensions = cc.size(ldw, 0)
    	}):pos(px + gdw * 0.5 + 10 + ldw*0.5, py+50):addTo(self)

    local bdw = 300
    self.telBorder_ = display.newScale9Sprite("#sm_dialog_border.png", px, py, cc.size(bdw, 42)):addTo(self)

    self.telEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onTelEdit_), size = cc.size(bdw, 40)})
        :pos(px, py)
        :addTo(self)

    self.telEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.telEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.telEdit_:setMaxLength(10)
    self.telEdit_:setPlaceholderFontColor(cc.c3b(0x94,0x88, 0xae))
    self.telEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.telEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.telEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL"))

    self.deviceInfo_ = nk.Native:getDeviceInfo()
    self.telEdit_:setText(self.deviceInfo_.phoneNumbers or "")

    self.alertT_ = ui.newTTFLabel({
        text = "*",
        color = cc.c3b(0xFF, 0x0, 0x0), 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    }):pos(px+150, py):addTo(self):hide()

    self.alertTip_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("MATCH", "REWARD_E2P_ERROR"),
        color = cc.c3b(0xFF, 0x0, 0x0), 
        size = 16, 
        align = ui.TEXT_ALIGN_LEFT,
        dimensions = cc.size(ldw, 0)
    }):pos(px+150, py):addTo(self)

    self.titlelbl_ = ui.newTTFLabel({
		text = "",
		color = styles.FONT_COLOR.GOLDEN_TEXT,
		size = 24,
		align = ui.TEXT_ALIGN_CENTER
	})
	:pos(0, height*0.5 - 40)
	:addTo(self)

    -- 关闭按钮
    self:addCloseBtn()
end

-- 确定兑换
function ScoreExchangeE2PPopup:onConfirm_()
    if self:isSendStatus() then
        self:close()
        return
    end

    local result = nil

    local phone = self.telEdit_:getText()
    if phone == nil or phone == "" then
        self.alertT_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL")
    end

    if result then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "ALERT_WRITEADDRESS", result))
        return
    end

    self:rewardE2PHandler_(phone)
end

function ScoreExchangeE2PPopup:show(goods, isModal, isCentered, px, py)
	self.goodsData_ = goods
    px = px or display.cx
    py = py or display.cy
    nk.PopupManager:addPopup(self, false, isCentered, true, true, nil, 1.2)
    self:pos(px, py)
    self:render_()

    return self
end

function ScoreExchangeE2PPopup:render_()
	self.name_:setString(self.goodsData_.name)

	self.desc_:setString(bm.LangUtil.getText("MATCH", "REWARD_E2P_TIPS"))

	local bsz = self.border_:getContentSize()
	local bpx, bpy = self.border_:getPosition()
	local sz = self.desc_:getContentSize()
    local llpx = (ScoreExchangeE2PPopup.WIDTH - 50)*0.5 - sz.width*0.5 - 5
    local llpy = bpy + bsz.height*0.5 - sz.height*0.5 - 15
    self.desc_:pos(llpx, llpy)

    local tsz = self.telBorder_:getContentSize()
    llpy = llpy - sz.height*0.5 - tsz.height*0.5 - 20
    self.telBorder_:pos(llpx - 10, llpy)
    self.telEdit_:pos(llpx - 10, llpy)
    self.alertT_:pos(llpx+tsz.width*0.5, llpy - 10)

    local asz = self.alertTip_:getContentSize()
    llpy = llpy - tsz.height*0.5 - asz.height*0.5 - 10
    self.alertTip_:pos(llpx, llpy)

    self.titlelbl_:setString(bm.LangUtil.getText("WHEEL", "DIALOG_CONTENT", self.goodsData_.name))

	if self.goodsData_ and self.goodsData_.image then
		nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
		nk.ImageLoader:loadAndCacheImage(self.iconLoaderId_,
			self.goodsData_.image,
			function(success, sprite)
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
				end
			end,
			nk.ImageLoader.CACHE_TYPE_GIFT
		)
	end

    self:refreshStatus()
end

-- 使用
function ScoreExchangeE2PPopup:refreshTelEdit(params)
    self.params_ = params
    if not self.deviceInfo_.phoneNumbers and self.params_ and self.params_.phone then
        if self:isSendStatus() then
            return
        end

        self.telEdit_:setText(self.params_.phone)
    end
end

function ScoreExchangeE2PPopup:refreshStatus()
    -- isSend:E2P奖励是否已经发放标志，未发奖不返回此字段
    if self:isSendStatus() then
        -- 恭喜您获得xx元话费。话费PIN码稍后会短信发送到您填写的手机上，您填写的手机号码为xxxxxx
        local fees = self.goodsData_.feeE2P or 50
        local telNum = self.goodsData_.telNum or self:getTelPhoneNum_(self.goodsData_.data.reward.matchid)
        self.desc_:setString(bm.LangUtil.formatString("ยินดีด้วยค่ะ ท่านได้รับค่าโทร {1} บาท ระบบจะส่งข้อความรหัส PIN ผ่านเบอร์โทรที่ท่านกรอก: {2} ", fees, telNum))
        self.desc_:setPositionY(self.desc_:getPositionY() - 60)

        self.alertT_:hide()
        self.alertTip_:hide()
        self.telEdit_:hide()
        self.telBorder_:hide() 
    end
end

-- 判断是否为兑换过，true为兑换过
function ScoreExchangeE2PPopup:isSendStatus()
    local result = false
    if self.goodsData_.data and self.goodsData_.data.reward and self.goodsData_.data.reward.isSend and tostring(self.goodsData_.data.reward.isSend) == "1" then
        result = true
    end
    return result
end

function ScoreExchangeE2PPopup:onTelEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.telEdit_:getText()
        if string.find(text,"^[+-]?%d+$") then
            local len = string.len(string.trim(text))
            if len > 10 then
                -- 提示超出长度
                text = string.sub(text, 1, 10)
            end
            self.editTel_ = text
            self.telEdit_:setText(text)
        else
            self.editTel_ = self.editTel_ or ""
            self.telEdit_:setText(self.editTel_)
        end

        if self.editTel_ ~= "" then
            self.alertT_:hide()
        else
            self.alertT_:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function ScoreExchangeE2PPopup:onShowed()
end

function ScoreExchangeE2PPopup:onClose()
    self:close()
end

function ScoreExchangeE2PPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function ScoreExchangeE2PPopup:onRemovePopup(func)
    self:setLoading(false)
	nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)	
    func()
end

function ScoreExchangeE2PPopup:rewardE2PHandler_(phone)
    self:setLoading(true)
    local matchId = self.goodsData_.id
    if self.goodsData_ and self.goodsData_.data and self.goodsData_.data.reward then
        matchId = self.goodsData_.data.reward.matchid
    end
    bm.HttpService.POST({
            mod="Match",
            act="partReward",
            matchId=matchId,
            phone=phone,
        },
        function(data)
            local retData = json.decode(data)
            if retData then
                if retData.ret == 0 then
                    self:saveTelPhoneNum_(matchId, phone)
                    if self.goodsData_.data.reward then
                        self.goodsData_.data.reward.isSend = 1
                    end

                    nk.ui.Dialog.new({
                        messageText = "สำเร็จ", -- 兑换成功
                        hasFirstButton = false,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            end
                        end
                    }):show()
                elseif retData.ret == -1 then
                    nk.ui.Dialog.new({
                        messageText = "เบอร์โทรไม่ถูกต้องค่ะ", -- 手机号码有误
                        hasFirstButton = false,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            end
                        end
                    }):show()
                elseif retData.ret == -100  then
                    nk.ui.Dialog.new({
                        messageText = "เบอร์โทรไม่ถูกต้องค่ะ", -- 手机号码有误
                        hasFirstButton = false,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            end
                        end
                    }):show()
                elseif retData.ret == -102 then
                    nk.ui.Dialog.new({
                        messageText = "ส่งรางวัลเรียบร้อยแล้วค่ะ",  -- -102发奖已发放
                        hasFirstButton = false,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            end
                        end
                    }):show()
                elseif retData.ret == -103 then
                    nk.ui.Dialog.new({
                        messageText = "ส่งรางวัลล้มเหลว",  -- -103发奖失败
                        hasFirstButton = false,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            end
                        end
                    }):show()
                end
            end

            self:refreshStatus()
            self:setLoading(false)
        end,
        function()
            self:setLoading(false)
        end)
end

local COOKIE_KEY = "ScoreExchangeE2PPopup_TELS"
function ScoreExchangeE2PPopup:getTelPhoneNum_(matchId)
    local jsonStr = nk.userDefault:getStringForKey(COOKIE_KEY, "")
    if jsonStr ~= "" then
        local telList = json.decode(jsonStr)
        local len = #telList
        for i=1,len do
            if telList[i].id == matchId then
                return telList[i].tel
            end
        end
    end

    return self:getDefaultTelNum_()
end

function ScoreExchangeE2PPopup:getDefaultTelNum_()
    if self.params_ and self.params_.phone then
        return self.params_.phone
    end

    return ""
end

function ScoreExchangeE2PPopup:saveTelPhoneNum_(matchId, telNum)
    local jsonStr = nk.userDefault:getStringForKey(COOKIE_KEY, "")
    local telList
    if jsonStr == "" then
        telList = {}
    else
        telList = json.decode(jsonStr)
    end

    table.insert(telList,#telList+1, {id=matchId, tel=telNum})
    jsonStr = json.encode(telList)
    nk.userDefault:setStringForKey(COOKIE_KEY, jsonStr)
end

-- Loading
function ScoreExchangeE2PPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            local runScene = display.getRunningScene()
            self.juhua_ = nk.ui.Juhua.new()
                :pos(display.cx, display.cy)
                :addTo(runScene, 9999, 9999)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

return ScoreExchangeE2PPopup