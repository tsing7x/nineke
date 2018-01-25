--
-- Author: HLF
-- Date: 2015-09-27 00:33:39
-- 兑换确认框
local ScoreExchangePopup = class("ScoreExchangePopup", nk.ui.Panel)

ScoreExchangePopup.WIDTH = 720
ScoreExchangePopup.HEIGHT = 480
local ICON_WIDTH = 150
local ICON_HEIGHT = 150
local AVATAR_TAG = 101

function ScoreExchangePopup:ctor(ctrl, goodsData, addressData, callbackExchange, callbackModify, isExchangeShop)
    ScoreExchangePopup.super.ctor(self, {ScoreExchangePopup.WIDTH+20, ScoreExchangePopup.HEIGHT+20})
    self:addBgLight()
    if goodsData.type == nil then
        self.isLuckturn_ = 0
    elseif type(goodsData.type) == "string" and goodsData.type == "luckturn" then
        self.isLuckturn_ = 1
    elseif type(goodsData.type) == "string" or type(goodsData.type) == "number" then
        self.isLuckturn_ = 2
    end
    
    self.ctrl_ = ctrl
    self.goodsData_ = goodsData
    self.addressData_ = addressData
    self.callbackExchange_ = callbackExchange
    self.callbackModify_ = callbackModify
    self.isExchangeShop_ = isExchangeShop
    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
    self:initView()
    self:proAlertTip_()
    if self.addressData_ then
        self:bindAddressInfo_(self.addressData_)
    else
        self.ctrl_:getMatchAddress1(handler(self, self.bindAddressInfo_))
    end
end

function ScoreExchangePopup:initView()
    local width, height = ScoreExchangePopup.WIDTH, ScoreExchangePopup.HEIGHT

    self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height)
    self.mainContainer_:setTouchSwallowEnabled(true)

    --顶部
    local dw, dh = 50, 170

    self.border_ = display.newScale9Sprite("#sm_dialog_border.png", 0, 0 + 12, cc.size(width - dw, height - dh))
        :addTo(self.mainContainer_)
    local gdw, gdh = 205, 180
    local px, py = -(width - gdw)*0.5 + 42, 10
    self.goodBg_ = display.newScale9Sprite("#sm_good_border1.png", px, py, cc.size(gdw, gdh))
    	:addTo(self.mainContainer_)

    self.goodLight_ = display.newSprite("#sm_good_light.png")
    	:pos(px, py-10)
    	:addTo(self)

    self.icon_ = display.newNode()
    	:size(ICON_WIDTH,ICON_HEIGHT)
    	:pos(px, py - 10)
    	:addTo(self)

    -- 游戏logo
    self.logo_ = display.newSprite("#game_logo.png")
        :pos(px, py - 10)
        :addTo(self)

    self.goodNBg_ = display.newScale9Sprite("#sm_border1.png", px, py-gdh*0.5-42*0.5 - 5, cc.size(gdw, 42))
    	:addTo(self.mainContainer_)

    self:loadImage()

    fontSize = 23
    self.namelbl_ = ui.newTTFLabel({
        text = self.goodsData_.name,
        color = styles.FONT_COLOR.GOLDEN_TEXT, 
        size = fontSize, 
        align = ui.TEXT_ALIGN_CENTER
    }):pos(px, py-gdh*0.5-42*0.5 - 5):addTo(self)

    local scoreColor = cc.c3b(0xff,0xff, 0x0)
    local scoreStr = bm.LangUtil.getText("SCOREMARKET", "CONSUME_SCORE", tostring(self.goodsData_.score))
    local confirmStr = bm.LangUtil.getText("SCOREMARKET", "CONFIRM_EXCHANGE")

    -- 判断是否为幸运转盘跳转过来的
    if self.isLuckturn_ == 1 then
        confirmStr = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_CONFIRM")
        scoreStr = bm.LangUtil.getText("WHEEL","REWARD_RECORD", self.goodsData_.name)
    elseif self.isLuckturn_ == 2 then
        confirmStr = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_CONFIRM")
        scoreStr = bm.LangUtil.getText("MATCH","REWARD_TIPS", self.goodsData_.name)
    end
    
    self.lblScore_ = ui.newTTFLabel({
        text = scoreStr,
        color = scoreColor, 
        size = 21, 
        align = ui.TEXT_ALIGN_CENTER,

    })
	:addTo(self)
   	local lsz = self.lblScore_:getContentSize()
   	self.lblScore_:pos(px + (lsz.width - gdw)*0.5, py+gdh*0.5 + 20)

   	self.bandIcon_ = display.newSprite("#sm_band.png"):addTo(self)
   	local isz = self.bandIcon_:getContentSize()
   	local ipx,ipy = px+gdw*0.5+isz.width*0.5 + 15, py + (gdh - isz.height) * 0.5 + 2
   	self.bandIcon_:pos(ipx,ipy)

   	self.lbl2_ = ui.newTTFLabel({
            text = bm.LangUtil.getText("SCOREMARKET","CONFIRM_ADDRESS_TIP"),
            color = styles.FONT_COLOR.LIGHT_TEXT, 
            size = 32, 
            align = ui.TEXT_ALIGN_CENTER,
        })
		:addTo(self)
   	lsz = self.lbl2_:getContentSize()
    self.lbl2_:pos(ipx+isz.width*0.5+lsz.width*0.5, ipy-3)

    local fontSize = 22
    local gapH = 33
    local ldw = 100
    ipy = ipy - 5
    self.namel_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("SCOREMARKET", "USER_NAME").." : ",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = fontSize, 
        align = ui.TEXT_ALIGN_RIGHT,
        dimensions=cc.size(ldw,0)
    })
    :addTo(self)
    lsz = self.namel_:getContentSize()
    local llpx, llpy = ipx-isz.width*0.5+lsz.width*0.5, ipy-gapH
    self.namel_:pos(llpx, llpy)

    self.nametxt_ = ui.newTTFLabel({
        text = "",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = 22, 
        align = ui.TEXT_ALIGN_CENTER,
    })
    :addTo(self)
    local lsz2 = self.nametxt_:getContentSize()
    self.nametxt_:pos(llpx + lsz2.width*0.5 + lsz.width*0.5 + 8, llpy)

    self.tellbl_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL").." : ",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = fontSize, 
        align = ui.TEXT_ALIGN_RIGHT,
        dimensions=cc.size(ldw,0)
    })
	:addTo(self)
    lsz = self.tellbl_:getContentSize()
    local llpx, llpy = ipx-isz.width*0.5+lsz.width*0.5, ipy-gapH*2
    self.tellbl_:pos(llpx, llpy)

    self.teltxt_ = ui.newTTFLabel({
        text = "",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = fontSize, 
        align = ui.TEXT_ALIGN_CENTER,
    })
	:addTo(self)
    local lsz2 = self.teltxt_:getContentSize()
    self.teltxt_:pos(llpx + lsz2.width*0.5 + lsz.width*0.5 + 8, llpy)

    self.addresslbl_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("SCOREMARKET", "DETAIL_ADDRESS").." : ",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = fontSize, 
        align = ui.TEXT_ALIGN_RIGHT,
        dimensions=cc.size(ldw,0)
    })
	:addTo(self)
    lsz = self.addresslbl_:getContentSize()
    llpx, llpy = ipx-isz.width*0.5+lsz.width*0.5, ipy-gapH*3
    self.addresslbl_:pos(llpx, llpy)

    self.addresstxt_ = ui.newTTFLabel({
        text = "",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = fontSize, 
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(315, 0)
    })
	:addTo(self)
    lsz2 = self.addresstxt_:getContentSize()
    self.addresstxt_:pos(llpx + lsz2.width*0.5 + lsz.width*0.5 + 8, llpy+lsz.height*0.5)
    self.addresstxt_:setAnchorPoint(cc.p(0.5, 1))

    self.emaillbl_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("SCOREMARKET", "EMAIL").." : ",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = fontSize, 
        align = ui.TEXT_ALIGN_RIGHT,
        dimensions=cc.size(ldw,0)
    })
	:addTo(self)
    lsz = self.emaillbl_:getContentSize()
    llpx, llpy = ipx-isz.width*0.5+lsz.width*0.5, ipy-gapH*6
    self.emaillbl_:pos(llpx, llpy)

    self.emailtxt_ = ui.newTTFLabel({
        text = "",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = fontSize, 
        align = ui.TEXT_ALIGN_CENTER,
    })
	:addTo(self)
    lsz2 = self.emailtxt_:getContentSize()
    self.emailtxt_:pos(llpx + lsz2.width*0.5 + lsz.width*0.5 + 8, llpy)

    local tdw = 400
    self.alertTips_ = ui.newTTFLabel({
        text="",
        color = cc.c3b(0xff, 0x0, 0x0),
        size = 20, 
        align = ui.TEXT_ALIGN_LEFT,
        dimensions=cc.size(tdw,0)
    })
    :pos(llpx + tdw*0.5 - 25, 0)
    :addTo(self)

    -- 关闭按钮
    self:addCloseBtn()

    -- 确认
    local buttonDw, buttonDh = 150,52
    px, py = 0, -height*0.5 + buttonDh*1.0
    self.confirmBtn_ = cc.ui.UIPushButton.new({
        normal = "#common_btn_green_normal.png", 
        pressed = "#common_btn_green_pressed.png"}, 
        {scale9 = true})
    :setButtonSize(buttonDw, buttonDh)
    :setButtonLabel("normal", ui.newTTFLabel({text = confirmStr or "", color = cc.c3b(0xb2, 0xdc, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER}))
    :pos(px, py)
    :onButtonClicked(buttontHandler(self, self.onConfirm_))
    :addTo(self)

    self.titlelbl_ = ui.newTTFLabel({
        text = "",
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    }):pos(0, height*0.5 - 45):addTo(self)

    -- 修改信息>>>
    local modifyLbl = ui.newTTFLabel({
            text = bm.LangUtil.getText("SCOREMARKET","MODIFY_INFO"), 
            size=24, 
            color=cc.c3b(0x27, 0x83, 0xc0),
            align=ui.TEXT_ALIGN_CENTER
        })
        :addTo(self)
    local bsz = modifyLbl:getContentSize()
    local bpx, bpy = width*0.5 - bsz.width*0.5 - 38, height*0.5-bsz.height-62
    modifyLbl:pos(bpx, bpy)

    local modifybtn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9=true})
        :setButtonSize(bsz.width, bsz.height)
        :pos(bpx, bpy)
        :addTo(self)
        :onButtonClicked(handler(self, self.onModify_))
        :onButtonPressed(function()
            local offVal = 2
            modifyLbl:pos(bpx+offVal, bpy-offVal)
        end)
        :onButtonRelease(function()
            modifyLbl:pos(bpx, bpy)
        end)

    self.splitLine_ = display.newScale9Sprite(
        "#user-info-desc-button-background-down-line.png",
        bpx, bpy-12,
        cc.size(bsz.width+20, 2)
    ):addTo(self)
end

function ScoreExchangePopup:refreshPos()
    local lsz = self.tellbl_:getContentSize()
    local llpx, llpy = self.tellbl_:getPosition()

    local offx = -5
    local lsz2 = self.teltxt_:getContentSize()
    self.teltxt_:pos(llpx + lsz2.width*0.5 + lsz.width*0.5 + offx, llpy)

    llpx, llpy = self.emaillbl_:getPosition()
    lsz2 = self.emailtxt_:getContentSize()
    self.emailtxt_:pos(llpx + lsz2.width*0.5 + lsz.width*0.5 + offx, llpy)

    llpx, llpy = self.addresslbl_:getPosition()
    lsz2 = self.addresstxt_:getContentSize()
    self.addresstxt_:pos(llpx + lsz2.width*0.5 + lsz.width*0.5 + offx, llpy+lsz.height*0.5)

    llpx, llpy = self.namel_:getPosition()
    lsz2 = self.nametxt_:getContentSize()
    self.nametxt_:pos(llpx + lsz2.width*0.5 + lsz.width*0.5 + offx, llpy)
end

function ScoreExchangePopup:bindAddressInfo_(params)
    if params then
        self.addressData_ = params
        self.nametxt_:setString(params.name)
        self.teltxt_:setString(params.phone)
        self.emailtxt_:setString(params.email)    
        self.addresstxt_:setString(params.city.."--"..params.address)

        self:refreshPos()
    end
end

function ScoreExchangePopup:onConfirm_(evt)
    if self.addressData_ then
        if self.callbackExchange_ then
            self.callbackExchange_(self.goodsData_)
        end
    else
        if self.callbackModify_ then
            self.callbackModify_(evt, self.goodsData_)
        end
    end 

    self:onClose()
end

function ScoreExchangePopup:onModify_(evt)
    if self.callbackModify_ then
        self.callbackModify_(evt, self.goodsData_)
    end

    self:onClose()
end

function ScoreExchangePopup:loadImage()
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

                    self.logo_:hide()
				end
			end,
			nk.ImageLoader.CACHE_TYPE_GIFT
		)
	end
end

function ScoreExchangePopup:show(isModal, isCentered, px, py)
    px = px or display.cx
    py = py or display.cy
    nk.PopupManager:addPopup(self, isModal, isCentered)
    self:pos(px, py)

    return self
end

function ScoreExchangePopup:onClose()
    self:close()
end

function ScoreExchangePopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function ScoreExchangePopup:onRemovePopup(func)
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
    func()
end

function ScoreExchangePopup:proAlertTip_()
    if not self.isExchangeShop_ then
        self.alertTips_:setString(bm.LangUtil.getText("SCOREMARKET", "MATCH_REAL_ALERT_TIPS", self.goodsData_.name or ""))
        self:switchStatusText_(true)
    elseif self.isExchangeShop_ == 1 then
        self.alertTips_:setString(bm.LangUtil.getText("SCOREMARKET", "MARKET_REAL_ALERT_TIPS", self.goodsData_.name or ""))
        self:switchStatusText_(true)
    else
        self.alertTips_:setString("")
        self:switchStatusText_(false)
    end
end

function ScoreExchangePopup:switchStatusText_(value)
    if value  then
        self.bandIcon_:hide()
        self.lbl2_:hide()
        self.namel_:hide()
        self.nametxt_:hide()
        self.tellbl_:hide()
        self.teltxt_:hide()
        self.addresslbl_:hide()
        self.addresstxt_:hide()
        self.emaillbl_:hide()
        self.emailtxt_:hide()
        self.lblScore_:hide()
        self.alertTips_:show()
    else
        self.bandIcon_:show()
        self.lbl2_:show()
        self.namel_:show()
        self.nametxt_:show()
        self.tellbl_:show()
        self.teltxt_:show()
        self.addresslbl_:show()
        self.addresstxt_:show()
        self.emaillbl_:show()
        self.emailtxt_:show()
        self.lblScore_:show()
        self.alertTips_:hide()
    end
end

return ScoreExchangePopup