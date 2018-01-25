--
-- Author: XT
-- Date: 2015-09-30 16:26:24
--
local ScoreExchangeSuccessPopup = class("ScoreExchangeSuccessPopup", nk.ui.Panel)

ScoreExchangeSuccessPopup.WIDTH = 600
ScoreExchangeSuccessPopup.HEIGHT = 400
local ICON_WIDTH = 150
local ICON_HEIGHT = 150
local AVATAR_TAG = 101

function ScoreExchangeSuccessPopup:ctor(params)
    ScoreExchangeSuccessPopup.super.ctor(self, {ScoreExchangeSuccessPopup.WIDTH+25, ScoreExchangeSuccessPopup.HEIGHT+25})
    self:addBgLight()
	self.params_ = params
    if not self.params_ then
        self.params_ = {}
    end
	self:initView()
end

function ScoreExchangeSuccessPopup:initView()
	local width, height = ScoreExchangeSuccessPopup.WIDTH, ScoreExchangeSuccessPopup.HEIGHT

	self.mainContainer_ = display.newNode():addTo(self)
	self.mainContainer_:setContentSize(width, height)
	self.mainContainer_:setTouchEnabled(true)
	self.mainContainer_:setTouchSwallowEnabled(true)
    --顶部
    local dw, dh = 50, 155
    self.border_ = display.newScale9Sprite("#sm_dialog_border.png", 0, 0 + 10, cc.size(width - dw, height - dh))
        :addTo(self.mainContainer_)
    -- 二维码
    self.QRCode_ = display.newSprite("QR_code.png")
        :pos(229,-65)
        :addTo(self.mainContainer_)
    self.QRCode_:scale(0.3)
    -- 确认
    local buttonDw, buttonDh = 150,52
    px, py = 0, -height*0.5 + buttonDh*1.0-5
    self.confirmBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_green_normal.png", 
            pressed = "#common_btn_green_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(buttonDw, buttonDh)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_CONFIRM") or "", color = cc.c3b(0xb2, 0xdc, 0xff), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        :pos(px+100, py)
        :onButtonClicked(buttontHandler(self, self.onConfirm_))
        :addTo(self.mainContainer_)

    -- 截图照片
    self.shotBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_blue_normal.png", 
            pressed = "#common_btn_blue_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(buttonDw, buttonDh)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SHARE", "SHOTANDSAVE") or "", color = cc.c3b(0xb2, 0xdc, 0xff), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        :pos(px-100, py)
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
            -- screenShot(callback,x,y,w,h)
        end))
        :addTo(self.mainContainer_)
    self.shotBtn_:hide()
    self.confirmBtn_:pos(px,py)
    -- SCOREMARKET.EXCHANGE_CONFIRM
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
    -- 
    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
    --
    local ldw = width - gdw - 75
    self.desc_ = ui.newTTFLabel({
    		text = "",
    		color = cc.c3b(0xe5, 0xe8, 0x66),
    		size = 20,
    		align = ui.TEXT_ALIGN_LEFT,
    		dimensions = cc.size(ldw, 0)
    	}):pos(px + gdw * 0.5 + 10 + ldw*0.5, py):addTo(self)
    -- 
    px, py = self.border_:getPosition()
    local sz = self.border_:getContentSize()
    local titleStr
    local lblSz
    if not self.params_ then
        titleStr = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_TIP")
        lblSz = 48
    else
        titleStr = self.params_.title or bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_TIP")
        lblSz = self.params_.size or 48
    end
    
    self.titlelbl_ = ui.newTTFLabel({
            text = titleStr,
            color = cc.c3b(0xf6, 0xff, 0x00), 
            size = lblSz, 
            align = ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(ldw+8, 0)
        }):pos(0, height*0.5 - 35):addTo(self)
    local lsz = self.titlelbl_:getContentSize()

    local lpx = px + 100
    local lpy = py + sz.height*0.5 - lsz.height*1.0 + 20
    self.titlelbl_:pos(lpx, lpy)

    -- 关闭按钮
    self:addCloseBtn()
end

function ScoreExchangeSuccessPopup:onConfirm_()
	self:onClose()
end

function ScoreExchangeSuccessPopup:setLoading(isLoading)
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

function ScoreExchangeSuccessPopup:show(goods, isModal, isCentered, px, py)
	self.goodsData_ = goods
    px = px or display.cx
    py = py or display.cy
    nk.PopupManager:addPopup(self, isModal, isCentered)
    self:pos(px, py)
    self:render_()

    -- 标题 时间
    local width, height = ScoreExchangeSuccessPopup.WIDTH, ScoreExchangeSuccessPopup.HEIGHT
    local date = nil
    if goods and goods.create_time then -- 查看历史
        date = os.date("*t",goods.create_time)
    else
        date = os.date("*t")
        if not goods then
            goods = {}
        end
        goods.create_time = os.time()
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
    -- 24小时以内
    if self.goodsData_ and self.goodsData_.create_time then
        local time = nk.userDefault:getIntegerForKey("socreMatchShare"..nk.userData.uid,0)
        if time<tonumber(self.goodsData_.create_time) then
            nk.userDefault:setIntegerForKey("socreMatchShare"..nk.userData.uid,self.goodsData_.create_time)
            nk.userDefault:flush()
        end
    end

    return self
end

function ScoreExchangeSuccessPopup:render_()
	self.name_:setString(self.goodsData_.name)

    if self.params_ and self.params_.desc then
	   self.desc_:setString(self.params_.desc)
    else
        self.desc_:setString(bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_DESC", self.goodsData_.name))
    end


	local _, py = self.titlelbl_:getPosition()
	local lsz = self.titlelbl_:getContentSize()
	local sz = self.desc_:getContentSize()
	-- nk.TopTipManager:showTopTip(tostring(sz.height))
    -- local llpy = py - lsz.height * 0.5 - sz.height*0.5 - 0
    local llpx = (ScoreExchangeSuccessPopup.WIDTH - 50)*0.5 - sz.width*0.5 - 5
    self.desc_:pos(llpx, -2)
	-- 
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
end

function ScoreExchangeSuccessPopup:onShowed()
    
end

function ScoreExchangeSuccessPopup:onClose()
    self:close()
end

function ScoreExchangeSuccessPopup:close()
	nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
    nk.PopupManager:removePopup(self)
    return self
end

return ScoreExchangeSuccessPopup