--
-- Author: hlf
-- Date: 2015-11-20 09:55:54
-- 兑换话费确认框
-- ScoreExchangeCallPopup.new():show(real, true, false, display.cx, display.cy + 50)

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ScoreExchangeCallPopup = class("ScoreExchangeCallPopup", nk.ui.Panel)

ScoreExchangeCallPopup.WIDTH = 600
ScoreExchangeCallPopup.HEIGHT = 400

local ICON_WIDTH = 150
local ICON_HEIGHT = 150
local AVATAR_TAG = 101
local BUTTON_DW = 120
local BUTTON_DH = 42

function ScoreExchangeCallPopup:ctor(params)
	if not params then
		params = {}
	end
	self.params_ = params
	self.preFix_ = params.prefix or "#upgrade_{1}.png"--
	self.plist_ = params.plist or "upgrade_texture.plist"--纹理配置
	self.texture_ = params.texture or "upgrade_texture.png"--纹理图片
	self:initView_()
end

function ScoreExchangeCallPopup:initView_()
	local width, height = ScoreExchangeCallPopup.WIDTH, ScoreExchangeCallPopup.HEIGHT
    ScoreExchangeCallPopup.super.ctor(self, {width+30, height+30})
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
        :addTo(self)

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

    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()

    px, py = self.border_:getPosition()
    local sz = self.border_:getContentSize()
    self.deslbl_ = ui.newTTFLabel({
            text = "",-- bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_TIP"),
            color = cc.c3b(0xf6, 0xff, 0x00), 
            size = 48, 
            align = ui.TEXT_ALIGN_CENTER
        }):pos(0, height*0.5 - 35):addTo(self)
    local lsz = self.deslbl_:getContentSize()

    local lpx = px + 100
    local lpy = py + sz.height*0.5 - lsz.height*1.0 + 20
    self.deslbl_:pos(lpx, lpy)
    self.lpx_ = lpx

    self.titlelbl_ = ui.newTTFLabel({
    		text = "",
    		color = cc.c3b(0xfb, 0xd0, 0x0a),
    		size = 36,
    		align = ui.TEXT_ALIGN_CENTER
    	})
    	:pos(0, height*0.5 - 40)
    	:addTo(self)

    self.copyKey_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(BUTTON_DW, BUTTON_DH)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "COPY"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("disabled", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "COPY"), color = styles.FONT_COLOR.DARK_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onCopyKeyClick_))
        :pos(lpx, lpy - 80)
    -- 关闭按钮
    self:addCloseBtn()
end

function ScoreExchangeCallPopup:onConfirm_()
	self:onClose()
end

function ScoreExchangeCallPopup:show(goods, isModal, isCentered, px, py)
	self.goodsData_ = goods
    px = px or display.cx
    py = py or display.cy
    nk.PopupManager:addPopup(self, isModal, isCentered)
    self:pos(px, py)
    self:render_()
    return self
end

function ScoreExchangeCallPopup:render_()
	local bsz = self.border_:getContentSize()
	self.deslbl_:setString("PIN Code:")
	local tsz = self.deslbl_:getContentSize()
	local px, py = self.lpx_ + 8 + tsz.width*0.5 - 320*0.5, bsz.height*0.5 - tsz.height*0.5 - 10
	self.deslbl_:pos(px, py)
	-- 
	self.titlelbl_:setString(bm.LangUtil.getText("WHEEL", "DIALOG_CONTENT", self.goodsData_.name))
	self.name_:setString(self.goodsData_.name)

    print("self.goodsData_.pin:::"..tostring(self.goodsData_.pin))
    if not self.goodsData_.pin then
        self.goodsData_.pin = 0
    end

	local pinNode, pdw, pdh,nums = self:getNumBatchNode_(self.goodsData_.pin)
	self.nums_ = nums
	-- 
	px, py = self.lpx_+8, py - tsz.height*0.5 - 40
	pinNode:pos(px, py):addTo(self)
	pinNode:setScale(318/pdw)

	-- BUTTON_DH
	px, py = px + 320 * 0.5 - BUTTON_DW*0.5, py - BUTTON_DH - 55
	self.copyKey_:pos(px, py)

	self:playNumsAnim_()
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

function ScoreExchangeCallPopup:playNumsAnim_()
    self:stopNumsAnim_()
    self.firstDotId_ = 1
    local DOTS_NUM = #self.nums_
    self.dotsSchedulerHandle_ = scheduler.scheduleGlobal(handler(self, function (obj)
        obj.nums_[obj.firstDotId_]:runAction(transition.sequence({
                cc.FadeTo:create(0.3, 255), 
                cc.FadeTo:create(0.3, 80),
            })
        )
        -- local secondDotId = obj.firstDotId_ + DOTS_NUM * 0.5
        -- if secondDotId > DOTS_NUM then
        --     secondDotId = secondDotId - DOTS_NUM
        -- end
        -- obj.nums_[secondDotId]:runAction(transition.sequence({
        --         cc.FadeTo:create(0.3, 255), 
        --         cc.FadeTo:create(0.3, 32), 
        --     })
        -- )
        obj.firstDotId_ = obj.firstDotId_ + 1
        if obj.firstDotId_ > DOTS_NUM then
            obj.firstDotId_ = 1
        end
    end), 0.10)
end

function ScoreExchangeCallPopup:stopNumsAnim_()
    for _, dot in ipairs(self.nums_) do
        dot:opacity(0)
        dot:stopAllActions()
    end
    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

function ScoreExchangeCallPopup:onCopyKeyClick_()
    if self.goodsData_ and self.goodsData_.pin then
        nk.Native:setClipboardText(self.goodsData_.pin)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET","COPY_SUCCESS"))
    end
end

function ScoreExchangeCallPopup:onShowed()
    
end

function ScoreExchangeCallPopup:onClose()
    self:close()
end

function ScoreExchangeCallPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function ScoreExchangeCallPopup:onRemovePopup(func)
	self:stopNumsAnim_()
	nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)	
    func()
end

function ScoreExchangeCallPopup:getNumBatchNode_(val)
	local batchNode = display.newBatchNode(self.texture_)
	-- local batchNode = display.newNode()
	local valStr = tostring(val)
	local len = string.len(valStr)
	local list = {}
	local dw,dh = 0,0
	local px
	for i=1,len do
		local numNode = display.newSprite(self:formatString(self.preFix_, string.sub(valStr, i, i))):addTo(batchNode)
		local sz = numNode:getContentSize()
		if nil == px then
			px = -sz.width*(len - 1)*0.5
		end
		dh = sz.height
		numNode:pos(px, 0)
		dw = dw + sz.width
		px = px + sz.width
		-- 
		table.insert(list, #list+1, numNode)
	end
	--
	batchNode:setCascadeOpacityEnabled(true)
	-- 
	return batchNode,dw,dh,list
end

function ScoreExchangeCallPopup:formatString(str, ...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        local output = str
        for i = 1, numArgs do
            local value = select(i, ...)
            output = string.gsub(output, "{" .. i .. "}", value)
        end
        return output
    else
        return str
    end
end

-- upgrade_0.png
return ScoreExchangeCallPopup
