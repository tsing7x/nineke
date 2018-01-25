--
-- Author: Jonah0608@gmail.com
-- Date: 2017-03-14 14:26:48
--

local smspic = {
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/sms/1.png",height = 538},
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/sms/2.png",height = 458},
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/sms/3.png",height = 462},
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/sms/4.png",height = 478}
}

local cardpic = {
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/card/1.png",height = 536},
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/card/2.png",height = 460},
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/card/3.png",height = 546},
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/card/4.png",height = 460},
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/card/5.png",height = 460},
    {pic = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/checkout/card/6.png",height = 626}
}

local CheckoutGuidePopup = class("CheckoutGuidePopup", nk.ui.Panel)

local POPUP_WIDTH = 720
local POPUP_HEIGHT = 500

function CheckoutGuidePopup:ctor()
    CheckoutGuidePopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})
    self:setNodeEventEnabled(true)
    self:createNodes_()
    self:addCloseBtn()
end

function CheckoutGuidePopup:createNodes_()
    self.title_ = ui.newTTFLabel({
        size = 24,
        text = "วิธีชำระผ่านช่องทาง google play (Check Out)",
        color = cc.c3b(255, 255, 255),
    })
    :pos(0,500 / 2 - 40)
    :addTo(self)

    local text = {"ชำระผ่านค่าโทร","ชำระผ่านบัตรธนาคาร"}
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = 440,
            iconOffsetX = 10, 
            btnText = text, 
        })
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 47)
        :addTo(self)

    display.newScale9Sprite("#pop_friend_content_bg.png", 0, 0, cc.size(686, 362))
        :pos(0,-50)
        :addTo(self)
    self:createSms()
    self:createCard()
    self.cardview_:hide()
end

function CheckoutGuidePopup:createSms()
    local CW,CH = 690,350
    local scrollViewRect = cc.rect(-CW * 0.5, -CH * 0.5, CW, CH)
    local smsContent = display.newNode()
    local smsAllHeight = 0
    local smssprite = {}
    local smsids = {}
    smsContent:setContentSize(668,1936)
    for k,v in pairs(smspic) do
        smsids[k] = nk.ImageLoader:nextLoaderId()
        smssprite[k] = display.newSprite("#transparent.png")
            :pos(0, 1936 / 2 - smsAllHeight - v.height / 2)
            :addTo(smsContent)
        smsAllHeight = smsAllHeight + v.height
        nk.ImageLoader:loadAndCacheImage(
                    smsids[k], 
                    v.pic,
                    handler(self, function(obj, success, sprite)
                        if success then
                            local tex = sprite:getTexture()
                            local texSize = tex:getContentSize()
                            local con = smssprite[k]
                            con:setTexture(tex)
                            con:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
                        end
                    end),
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
    end
    

    self.smsview_ = bm.ui.ScrollView.new({
            viewRect      = scrollViewRect,
            scrollContent = smsContent,
            direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
        }):pos(0, -50)
        :addTo(self)
end

function CheckoutGuidePopup:createCard()
    local CW,CH = 690,350
    local scrollViewRect = cc.rect(-CW * 0.5, -CH * 0.5, CW, CH)
    local cardContent = display.newNode()
    local cardAllHeight = 0
    local cardsprite = {}
    local cardids = {}
    cardContent:setContentSize(668,3088)
    for k,v in pairs(cardpic) do
        cardids[k] = nk.ImageLoader:nextLoaderId()
        cardsprite[k] = display.newSprite("#transparent.png")
            :pos(0, 3088 / 2 - cardAllHeight - v.height / 2)
            :addTo(cardContent)
        cardAllHeight = cardAllHeight + v.height
        nk.ImageLoader:loadAndCacheImage(
                    cardids[k], 
                    v.pic,
                    handler(self, function(obj, success, sprite)
                        if success then
                            local tex = sprite:getTexture()
                            local texSize = tex:getContentSize()
                            local con = cardsprite[k]
                            con:setTexture(tex)
                            con:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
                        end
                    end),
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
    end
    

    self.cardview_ = bm.ui.ScrollView.new({
            viewRect      = scrollViewRect,
            scrollContent = cardContent,
            direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
        }):pos(0, -50)
        :addTo(self)
end

function CheckoutGuidePopup:onMainTabChange_(selectedTab)
    if selectedTab == 1 then
        self.smsview_:show()
        self.cardview_:hide()
    else
        self.smsview_:hide()
        self.cardview_:show()
    end
end

function CheckoutGuidePopup:show()
    self:showPanel_()
end

function CheckoutGuidePopup:onShowed()
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
end

return CheckoutGuidePopup