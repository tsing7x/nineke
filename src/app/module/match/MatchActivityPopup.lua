--
-- Author: hlf
-- Date: 2015-11-26 16:04:45
--
local logger = bm.Logger.new("MatchActivityPopup")
local BubbleButton = import("boomegg.ui.BubbleButton")
local ScrollLabel = import("boomegg.ui.ScrollLabel")
local TitleBtnGroup = require("app.module.room.views.TitleBtnGroup");
local MatchActivityPopup = class("MatchActivityPopup", nk.ui.Panel)

MatchActivityPopup.WIDTH = 638
MatchActivityPopup.HEIGHT = 418

local BUTTON_DW, BUTTON_DH = 196, 58;

local ICON_WIDTH = 164
local ICON_HEIGHT = 164
local AVATAR_TAG = 101

local APPLY_ACT_STR = "ร่วมทันที"-- 报名
local GOTO_SHOP_STR = "ไปที่ห้าง"-- 跳转商城

function MatchActivityPopup:ctor()
    MatchActivityPopup.super.ctor(self, {MatchActivityPopup.WIDTH+30, MatchActivityPopup.HEIGHT+30})
    --修改背景框
    -- self:setBackgroundStyle1()

    self.data_ = nk.userData.popup
    if not self.data_ then
        self.data_ = {}
    end
    self:setNodeEventEnabled(true)
	self:initView_();
    self:initTileBtnGroup_()

    self:addCloseBtn()
    self:setCloseBtnOffset(0,-15)
end

function MatchActivityPopup:initView_()
	local width, height = MatchActivityPopup.WIDTH, MatchActivityPopup.HEIGHT;
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height)
    self.mainContainer_:setTouchEnabled(true)
    self.mainContainer_:setTouchSwallowEnabled(false)
    -- 背景
    local px, py = 0, 0;
    dw=610;
    dh=200
    px, py = 0, height*0.5-132-dh*0.5;
    self.border_ = display.newScale9Sprite("#panel_overlay.png", px, py, cc.size(dw, dh), cc.rect(16,17,1,1))
        :pos(px, py)
        :addTo(self.mainContainer_);
    -- 关闭按钮
    px, py = width*0.5 - 26, height*0.5 - 28

    local px, py = -width*0.5+ICON_WIDTH*0.5 + 32, -22;
    self.px_, self.py_ = px, py;
    self.leftpx_ = px + ICON_WIDTH*0.5;

    self.icon_ = display.newNode()
        :size(ICON_WIDTH,ICON_HEIGHT)
        :pos(px, py)
        :addTo(self.mainContainer_)

    -- 立即参与
    self.bubbleBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed="#common_btn_yellow_pressed.png"},{scale9 = true})
            :setButtonLabel("normal", ui.newTTFLabel({text = APPLY_ACT_STR, color = cc.c3b(0xff, 0xff, 0), size = 32, align = ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:onBtnClick_()
            end)
            :setButtonSize(BUTTON_DW, BUTTON_DH)
            :pos(0, -height*0.5 + BUTTON_DH - 14)
            :addTo(self.mainContainer_)

    local dw = 400;
    local dh = 170;
    px, py = self.leftpx_ + dw*0.5 + 20, 56;
    self.desc_ = ScrollLabel.new(
            {
                text="",
                color=cc.c3b(0xe6,0xc0,0xff),
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
    self.desc_:setTouchSwallowEnabled(false)

    self:addLinkUrl_();
    self:renderInfo_(self.data_)
end

function MatchActivityPopup:addLinkUrl_()
    local px, py = self.border_:getPosition();
    local sz = self.border_:getContentSize();
    py = py - sz.height*0.5;
    px = px + sz.width*0.5;
    self.linkUrl_ = display.newNode()
        :pos(px, py)
        :addTo(self.mainContainer_)

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

function MatchActivityPopup:initTileBtnGroup_()
    if nk.userData.getPopupDatas then
        self:onDataCallback_(nk.userData.getPopupDatas)
    else
         bm.HttpService.POST({
                mod = "Match",
                act = "getPopup"
            },
            function(data)
                local retJson = json.decode(data);
                if retJson and retJson.ret == 0 then
                    nk.userData.getPopupDatas = retJson.list;
                    self:onDataCallback_(nk.userData.getPopupDatas)
                end         
            end,
            function()
                -- 异常重新请求
            end
        );
    end
end

function MatchActivityPopup:onDataCallback_(list)
    self.datas_ = list;
    if #self.datas_>0 then
        self:createTabs_();
    end
end

function MatchActivityPopup:createTabs_()
    local offx = 0;
    local text = {}
    local len = #self.datas_;
    for i=1,len,1 do
        table.insert(text,self.datas_[i].tabname)
    end
    local width = 500
    if len==1 then
        width = 300
    end
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = width,
            iconOffsetX = 10, 
            btnText = text, 
        }
    )
        :pos(0, MatchActivityPopup.HEIGHT*0.5 - 60)
        :addTo(self.mainContainer_, 10)

    local index = 1;
    for i=1,len do
        if self.data_ and tostring(self.datas_[i].ext) == tostring(self.data_.ext) then
            index = i;
            break;
        end
    end

    self.mainTabBar_:onTabChange(handler(self, self.tableSelectedChange))
    self.mainTabBar_:gotoTab(index)

    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5+10)
end

function MatchActivityPopup:tableSelectedChange()
    local tab = self.mainTabBar_.selectedTab_
    local data = self.datas_[tab];
    self:umengStaticationTabName(data.tabname);
    self:renderInfo_(data);
    return true;
end

function MatchActivityPopup:renderInfo_(data)
    if data == nil then
        return;
    end

    self.curData_ = data;
    if self.curData_.link and string.len(self.curData_.link) > 0 then
        self.linkUrl_:show()
    else
        self.linkUrl_:hide(); 
    end

    local width, height = MatchActivityPopup.WIDTH, MatchActivityPopup.HEIGHT;
    self.desc_:setString(self.curData_.desc or "")
    local url = nk.userData.cdn..""..(self.curData_.img or "");
    self:loadImg_(url);

    if self.curData_.ext and string.len(self.curData_.ext) > 1 then
        self.bubbleBtn_:getButtonLabel("normal"):setString(APPLY_ACT_STR)
    else
        self.bubbleBtn_:getButtonLabel("normal"):setString(GOTO_SHOP_STR)
    end
end

function MatchActivityPopup:loadImg_(img)
    if img then
        self:setLoading(true)

        self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
        local iconContainer = self.icon_;
        local iconLoader = self.iconLoaderId_;
        nk.ImageLoader:cancelJobByLoaderId(iconLoader)
        nk.ImageLoader:loadAndCacheImage(iconLoader,
            img, 
            function(success, sprite)
                if success then
                    local tex = sprite:getTexture()
                    local texSize = tex:getContentSize()
                    local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
                    if oldAvatar then
                        oldAvatar:removeFromParent()
                    end

                    local iconSize = iconContainer:getContentSize()
                    local xxScale = iconSize.width/texSize.width
                    local yyScale = iconSize.height/texSize.height
                    sprite:scale(xxScale<yyScale and xxScale or yyScale)
                        :addTo(iconContainer, 0, AVATAR_TAG)

                    iconContainer:show();
                    self:setLoading(false);
                end
            end,
            nk.ImageLoader.CACHE_TYPE_GIFT
        )
    end
end

function MatchActivityPopup:onBtnClick_(evt)
    if self.curData_.ext and string.len(self.curData_.ext) > 1 then
        local tickData = nk.MatchTickManager:getTickByMatchLevel(self.curData_.ext)
        if nil == tickdata then
            tickData = {}
            tickData.level = self.curData_.ext or 1
        end
        nk.userData.useTickType_ = nk.MatchTickManager.TYPE3;-- 过期门票弹出框使用门票
        nk.MatchTickManager:applyTick(tickData)
    else
        local ScoreMarketView = import("app.module.scoremarket.ScoreMarketViewExt");
        ScoreMarketView.load(nil, nil)
    end
    
    if self["onClose"] then
        self:onClose();
    end
end

function MatchActivityPopup:onCleanup()
    self.data_ = nil
end

function MatchActivityPopup:onShowed()
    self:umengStatication();
end

function MatchActivityPopup:show(goods, isModal, isCentered, px, py)
    px = px or display.cx;
    py = py or display.cy;
    nk.PopupManager:addPopup(self, true, isCentered, true, true, nil, 1.0)
    self:pos(px, py)
    return self
end

function MatchActivityPopup:onClose()
	self:close()
end

function MatchActivityPopup:close()
    if self.closeCallback_ then
        self.closeCallback_()
    end
    
	nk.PopupManager:removePopup(self)
    
    return self
end

function MatchActivityPopup:onRemovePopup(func)
    func();
end

function MatchActivityPopup:setLoading(isLoading)
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

function MatchActivityPopup:onRemovePopup(func)
    if self.iconLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
        self.iconLoaderId_ = nil;
    end

    func();
end

function MatchActivityPopup:onlinkUrlTouchHandler_(evt)
    if self.curData_ and self.curData_.link and string.len(self.curData_.link) > 0 then
        local url = self.curData_.link;
        local sign = self.curData_.name;
        nk.OnOff:openSponsorWebView(sign, url);
    end
end

function MatchActivityPopup:umengStatication()
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
                    args = {eventId = "ShowMatchActivity_Show_Count"}}
    end
end

function MatchActivityPopup:umengStaticationTabName(tabname)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
                    args = {eventId = "ShowMatchActivity_Tabname_Count", label = tostring(tabname or "0")}}
    end
end

return MatchActivityPopup;
