--
-- Author: KevinYu
-- Date: 2016-10-24 10:51:35
-- VIP商品列表

local ProductVipList = class("ProductVipList",function()
    return display.newNode()
end)

local BG_W, BG_H
local FIRSR_COL_W--第一列宽度
local ITEM_W, ITEM_H--除第一列外，每个item宽高

local vipIcons = {
	"#store_vip_silver.png",
	"#store_vip_gold.png",
	"#store_vip_blue.png",
	"#store_vip_purple.png",
}

function ProductVipList:ctor(w, h)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	self:setNodeEventEnabled(true)

	--适配
	BG_W, BG_H = w, h
	FIRSR_COL_W = w * 0.16
	ITEM_W, ITEM_H = w * 0.84 / 4, h / 8

	if not self.onOffLoadId_ then
        self.onOffLoadId_ = bm.EventCenter:addEventListener("OnOff_Load", handler(self, self.updateVipInfo_))
    end

	self.isAddVipInfo_ = false

	--购买按钮
	self.buyBtnList_ = {}

	--续费按钮
	self.againBtnList_ = {}

	self.bg_ = display.newScale9Sprite("#store_bg.png", 0, 0, cc.size(BG_W, BG_H))
		:addTo(self)

	local bg = self.bg_

	for i = 1, 7, 2 do
		display.newScale9Sprite("#store_vip_bg.png", 0, 0, cc.size(BG_W, ITEM_H))
			:align(display.BOTTOM_CENTER, BG_W/2, ITEM_H * (i - 1))
			:addTo(bg)
	end

	for i = 1, 4 do
		display.newScale9Sprite("#store_vip_line.png", FIRSR_COL_W + ITEM_W * (i - 1), BG_H/2, cc.size(4, BG_H))
			:addTo(bg)
	end

	for i = 1, 4 do
		display.newSprite(vipIcons[i])
			:pos(FIRSR_COL_W + ITEM_W * (i - 0.5), ITEM_H * 7.5)
			:addTo(bg)
	end

	if nk.userData.vipcoupon == 1 then
		display.newSprite("#store_label_off_20.png")
			:pos(FIRSR_COL_W + 37 , ITEM_H * 7.5 - 8)
			:addTo(bg)
	end

	local titleList = bm.LangUtil.getText("VIP", "REWARD_TITLE_LIST")
	for i = 1, 7 do
		ui.newTTFLabel({text = titleList[i], size = 18})
			:pos(FIRSR_COL_W/2, ITEM_H * (i - 0.5))
			:addTo(bg)
	end
end

function ProductVipList:addVipInfo_(index, data, x)
	local bg = self.bg_

	--立即开通
	self.buyBtnList_[index] = cc.ui.UIPushButton.new({normal="#common_btn_green_normal.png", pressed="#common_btn_green_pressed.png"}, {scale9=true})
        :setButtonSize(130, 52)
        :setButtonLabel("normal", ui.newTTFLabel({size = 20, text = data.priceLabel}))
        :onButtonClicked(buttontHandler(self, self.onOpenClicked_))
        :pos(x, ITEM_H * 0.5)
        :addTo(bg)
    self.buyBtnList_[index]:setTag(index)

    self.againBtnList_[index] = cc.ui.UIPushButton.new({normal="#common_btn_blue_normal.png", pressed="#common_btn_blue_pressed.png"}, {scale9=true})
        :setButtonSize(130, 52)
        :setButtonLabel("normal", ui.newTTFLabel({size = 20, text = bm.LangUtil.getText("VIP", "PAY_AGAIN") .. data.priceLabel}))
        :onButtonClicked(buttontHandler(self, self.onAgainClicked_))
        :pos(x, ITEM_H * 0.5)
        :addTo(bg)
        :hide()
    self.againBtnList_[index]:setTag(index)

	--踢人卡
	display.newSprite("#pop_userinfo_prop_kickCard.png")
			:pos(x - 16, ITEM_H * 1.5)
			:addTo(bg)
			:setScale(0.4)
	ui.newTTFLabel({text = "X" .. data.tickcard, size = 18})
			:pos(x + 30, ITEM_H * 1.5 - 10)
			:addTo(bg)

	--VIP表情
	if data.expression == 1 then
		expressionImg = "#store_vip_yes.png"
	else
		expressionImg = "#store_vip_no.png"
	end

	display.newSprite(expressionImg)
			:pos(x, ITEM_H * 2.5)
			:addTo(bg)

	--破产优惠
	local str = bm.LangUtil.getText("VIP", "BROKE_REWARD", (data.brokeDis - 1) * 100, data.brokeDisNum)
	ui.newTTFLabel({text = str, size = 18})
			:pos(x, ITEM_H * 3.5)
			:addTo(bg)

	--经验
	ui.newTTFLabel({text = data.exp, size = 18})
			:pos(x, ITEM_H * 4.5)
			:addTo(bg)

    --登录返还
	ui.newTTFLabel({text = bm.LangUtil.getText("VIP", "LOGINREWARD", data.loginrwd), size = 18})
			:pos(x, ITEM_H * 5.5)
			:addTo(bg)

	--筹码
	ui.newTTFLabel({text = data.chips, size = 18})
			:pos(x, ITEM_H * 6.5)
			:addTo(bg)

end

function ProductVipList:addOpenVipMark_()
	local w, h = 108, 31
	local bg = display.newScale9Sprite("#store_vip_open_bg.png", FIRSR_COL_W/2, ITEM_H * 7.5, cc.size(w, h))
		:addTo(self.bg_)

	self.openVip_ = display.newSprite()
		:pos(14, h/2)
		:scale(0.55)
		:addTo(bg)

	self.vipDay_ = ui.newTTFLabel({text = "", size = 12})
			:align(display.LEFT_CENTER, 28, h/2)
			:addTo(bg)

	self:updateVipInfo_()
end

--更新VIP是否开通信息
function ProductVipList:updateVipInfo_()
	local vipconfig = nk.OnOff:getConfig('newvipmsg')
	local icon = ""
	local str = ""
	if vipconfig and vipconfig.newvip == 1 then
		icon = "pop_vip_icon_level_" .. vipconfig.vip.level .. ".png"
		str = bm.LangUtil.getText("VIP", "AVAILABLE_DAYS", vipconfig.ttl)
		self:updateBtnState_(vipconfig.vip.level)
	else
		icon = "pop_vip_icon_level_0.png"
		str = bm.LangUtil.getText("VIP", "NOT_VIP")
	end

	self.openVip_:setSpriteFrame(display.newSpriteFrame(icon))
	self.vipDay_:setString(str)
end

--更新按钮名字，已开通的VIP，改成续费，其他为价格
function ProductVipList:updateBtnState_(level)
	local index = level - 6 --VIP等级7-10，减去6对应下标
	for i = 1, #self.data_ do
		if index == i then
			self.againBtnList_[i]:show()
			self.buyBtnList_[i]:hide()
		else
			self.againBtnList_[i]:hide()
			self.buyBtnList_[i]:show()
		end
	end
end

function ProductVipList:setData(data)
	if not self.isAddVipInfo_ then
		self.data_ = data
		self.isAddVipInfo_ = true
		for i = 1, #data do
			self:addVipInfo_(i, data[i], FIRSR_COL_W + ITEM_W * (i - 0.5))
		end

		self:addOpenVipMark_()
	end
end

function ProductVipList:onOpenClicked_(event)
	local tag = event.target:getTag()

	local data = self.data_[tag]

	local vipconfig = nk.OnOff:getConfig('newvipmsg')

	if vipconfig and vipconfig.newvip == 1 and vipconfig.vip.level - 6 ~= tag then
		nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("VIP", "ALREADY_IS_TIPS", vipconfig.vip.name),
            callback = function(param)
                if param == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self:makePurchase_(data)
                end
            end
        }):show()
	else
		self:makePurchase_(data)
	end
end

function ProductVipList:onAgainClicked_(event)
	local tag = event.target:getTag()
	local data = self.data_[tag]

	self:makePurchase_(data)
end

function ProductVipList:makePurchase_(data)
	self:dispatchEvent({name="ITEM_EVENT", type="MAKE_PURCHASE", pid = data.pid, goodsItem = data})
end

function ProductVipList:onCleanup()
	if self.onOffLoadId_ then
        bm.EventCenter:removeEventListener(self.onOffLoadId_);
        self.onOffLoadId_ = nil
    end
end

return ProductVipList