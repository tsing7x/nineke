--
-- Author: KevinLiang
-- Date: 2016-01-13 13:55:45
--
local UserInfoStuffItem = class("UserInfoStuffItem", bm.ui.ListItem)
UserInfoStuffItem.WIDTH = 192
UserInfoStuffItem.HEIGHT = 224
UserInfoStuffItem.ROW_GAP = 5
UserInfoStuffItem.COL_GAP = 14
local ICON_WIDTH = 120
local ICON_HEIGHT = 120
local AVATAR_TAG = 101

function UserInfoStuffItem:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	UserInfoStuffItem.super.ctor(self, UserInfoStuffItem.WIDTH * 3 + UserInfoStuffItem.COL_GAP * 2, UserInfoStuffItem.HEIGHT + UserInfoStuffItem.ROW_GAP)
    self.isFolded_ = true

    self.props = {}
    self.propIcons = {}
    self.propDates = {}
    self.propNums = {}
    self.propLabels = {}
    self.propButtons = {}
    self.btnLabels_ = {}
    self.propUseButtons = {}
    
    for i = 1, 3 do
    	local px, py = UserInfoStuffItem.WIDTH*0.5 - UserInfoStuffItem.COL_GAP + (i - 1) * (UserInfoStuffItem.WIDTH + UserInfoStuffItem.COL_GAP), UserInfoStuffItem.HEIGHT*0.5
    	-- 背景
        self.props[i] = display.newNode():addTo(self)
    	display.newScale9Sprite("#pop_userinfo_my_stuff_item_bg.png", 0, 0, cc.size(UserInfoStuffItem.WIDTH, UserInfoStuffItem.HEIGHT))
            :pos(px, py)
            :addTo(self.props[i])

        display.newSprite("#pop_userinfo_my_stuff_item_bg2.png")
            :pos(px - 46, py + 38)
            :addTo(self.props[i])

        display.newSprite("#pop_userinfo_my_stuff_item_bg2.png")
            :pos(px + 46, py + 38)
            :addTo(self.props[i])
            :setScaleX(-1)

        -- 道具图标
        self.propIcons[i] = display.newSprite("#user-info-big-laba-icon.png")
        	:pos(px, py + 30)
        	:addTo(self.props[i], 2, 2)
            :hide()

        -- 门票过期时间
        self.propDates[i] = ui.newTTFLabel({text = "" , color = styles.FONT_COLOR.GOLDEN_TEXT, size = 18, align = ui.TEXT_ALIGN_CENTER})
            :pos(px, 206)
            :addTo(self.props[i],2,2)
            :hide()

        -- 道具数量
        self.propNums[i] = ui.newTTFLabel({text = "X0" , color = cc.c3b(0xdd, 0xc5, 0x93), size = 26, align = ui.TEXT_ALIGN_CENTER})
            :pos(px + UserInfoStuffItem.WIDTH * 0.5 - 10, 200)
            :addTo(self.props[i],99,99)
        self.propNums[i]:setAnchorPoint(cc.p(1, 0.5))

        -- 道具标签
        display.newScale9Sprite("#pop_userinfo_my_stuff_item_text_bg.png", 0, 0, cc.size(UserInfoStuffItem.WIDTH - 10, 42))
            :pos(px, 72)
            :addTo(self.props[i])

        self.propLabels[i] = ui.newTTFLabel({text = bm.LangUtil.getText("BANK", "BANK_DROP_LABEL") , color = cc.c3b(0x5a, 0x75, 0xbe), size = 18, align = ui.TEXT_ALIGN_CENTER})
            :pos(px, 72)
            :addTo(self.props[i])

        self.propButtons[i] = display.newScale9Sprite("#pop_userinfo_my_stuff_item_button_bg.png", px, 27, cc.size(UserInfoStuffItem.WIDTH - 6, 48))
            :addTo(self.props[i])

        self.btnLabels_[i] = ui.newTTFLabel({text = bm.LangUtil.getText("STORE","BUY"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER})
            :pos(px, 27)
            :addTo(self.props[i], 2, 2)

        -- 道具使用 common_transparent_skin
        self.propUseButtons[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png" , pressed = "#rounded_rect_10.png"}, {scale9 = true})
            :setButtonSize(UserInfoStuffItem.WIDTH - 10, UserInfoStuffItem.HEIGHT - 5)
            :onButtonPressed(function(evt) 
                self.btnPressedY_ = evt.y
                self.btnClickCanceled_ = false
            end)
            :onButtonRelease(function(evt)
                if math.abs(evt.y - self.btnPressedY_) > 5 then
                    self.btnClickCanceled_ = true
                end
            end)
            :onButtonClicked(function(evt)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:buyPropHandler_(i)
            end)
            :pos(px, py)
            :addTo(self.props[i])

        self.propUseButtons[i]:setTouchSwallowEnabled(false)
    end
end

function UserInfoStuffItem:onDataSet(dataChanged, data)
	self.data_ = data
	self:render()
end

function UserInfoStuffItem:render()
	if self.data_ and type(self.data_) == "table" then
        for i = 1, #self.data_ do 
            if self.data_[i].icon then
                local px, py = self.propIcons[i]:getPosition()
                local path = cc.FileUtils:getInstance():fullPathForFilename(self.data_[i].icon)
                if io.exists(path) then
                    self.propIcons[i] = display.newSprite(self.data_[i].icon)
                        :addTo(self)
                        :pos(px, py)
                elseif string.find(self.data_[i].icon, "http://") then
                    if not self.iconLoaderIds then
                        self.iconLoaderIds = {}
                    end

                    if not self.iconLoaderIds[i] then
                        self.iconLoaderIds[i] = nk.ImageLoader:nextLoaderId()
                    end

                    local imgStr = self.data_[i].icon
                    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderIds[i])
                    nk.ImageLoader:loadAndCacheImage(self.iconLoaderIds[i],
                        imgStr, 
                        function(success, sprite)
                            if success then
                                local tex = sprite:getTexture()
                                local texSize = tex:getContentSize()
                                local xxScale = 100/texSize.width
                                local yyScale = 100/texSize.height
                                -- 判断是否过期
                                if not self.data_[i].isOverDate then
                                    sprite:scale(xxScale<yyScale and xxScale or yyScale):addTo(self):pos(px, py)
                                else
                                    local spr_ = bm.grayNodeByTex(tex)
                                    spr_:scale(xxScale<yyScale and xxScale or yyScale):addTo(self):pos(px, py)
                                end
                            end
                        end,
                        nk.ImageLoader.CACHE_TYPE_GIFT
                    )
                else
                    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(self.data_[i].icon)
                    if frame then
                        self.propIcons[i]:show()
                        self.propIcons[i]:setSpriteFrame(frame)
                    end
                end
            end
    		
    		self.propNums[i]:setString(bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES", self.data_[i].num))
    		self.propLabels[i]:setString(self.data_[i].label)
            bm.fitSprteWidth(self.propLabels[i], (UserInfoStuffItem.WIDTH - 15));

            self:setBtnLabelsString_(i)

            -- 是否过期:true为过期
            if self.data_[i].endtime then
                if not self.data_[i].isOverDate then
                    self.propDates[i]:show()
                    self.propDates[i]:setString(nk.MatchTickManager:getTickDateStr(self.data_[i].endtime))
                    self.propNums[i]:pos(self.propNums[i]:getPositionX(), self.propNums[i]:getPositionY() - 10)

                    self:removeOverDueSign_()
                else
                    self.propDates[i]:hide()

                    self.propButtons[i]:hide()
                    display.newScale9Sprite("#pop_userinfo_my_stuff_item_button_disabled_bg.png", self.propButtons[i]:getPositionX(), self.propButtons[i]:getPositionY(), 
                        cc.size(self.propButtons[i]:getContentSize().width, self.propButtons[i]:getContentSize().height))
                            :addTo(self.props[i])
                    self.propUseButtons[i]:setButtonEnabled(false)
 
                    self:addOverDueSign_(i)
                end
            end
        end
        if #self.data_ < 3 then
            for i = #self.data_ + 1, 3 do
                self.props[i]:hide()
            end
        end
	end	
end

function UserInfoStuffItem:setBtnLabelsString_(index)
    local btnType = self.data_[index].btnType
    local label = self.btnLabels_[index]
    if btnType == 2 then
        label:setString("เปิดดู")
    elseif btnType == 3 then
        label:setString(bm.LangUtil.getText("TICKET", "APPLY_LABLE"))
        if self.data_[index].num > 0 then
            self.propUseButtons[index]:setButtonEnabled(true)
        else
            self.propUseButtons[index]:setButtonEnabled(false)
        end
    elseif btnType == 4 then
        label:setString(bm.LangUtil.getText("CARD_ACT", "GOTO_USE"))
    elseif btnType == 5 then
        label:setString(bm.LangUtil.getText("USERINFO", "USE_PROP"))
    elseif btnType == 6 then
        label:setString(bm.LangUtil.getText("USERINFO", "QUICK_USE_PROP"))
    else
        label:setString(bm.LangUtil.getText("STORE","BUY"))
    end
end

function UserInfoStuffItem:addOverDueSign_(index_)
    if not self.overDueSign_ then
        self.overDueSigns = {}
    end

    if not self.overDueSigns[index_] then
        local px, py = self.propIcons[index_]:getPosition()
        self.overDueSigns[index_] = display.newSprite("#overdue_tick_sign.png")
            :pos(px, py)
            :addTo(self, 10, 999)
        self.overDueSigns[index_]:setScale(0.6)
        self.overDueSigns[index_]:setRotation(-25)
    end
end

function UserInfoStuffItem:removeOverDueSign_(index_)
    if self.overDueSigns and self.overDueSigns[index_] then
        self.overDueSigns[index_]:removeFromParent()
        self.overDueSigns[index_] = nil
    end
end

function UserInfoStuffItem:buyPropHandler_(index)
    local data = self.data_[index]
    local btnType = data.btnType

	if btnType == 3 then
        self:dispatchEvent({name = "ITEM_EVENT", type="APPLY_PROP", data = data})
    elseif btnType == 2 then
        self:dispatchEvent({name = "ITEM_EVENT", type="SEE_PROP", data = data})
    elseif btnType == 4 then
        self:dispatchEvent({name = "ITEM_EVENT", type="USE_VIP_COUPON", data = data})
    elseif btnType == 5 then
        self:dispatchEvent({name = "ITEM_EVENT", type="USE_HOLIDAY_PROP", data = data})
     elseif btnType == 6 then
        self:dispatchEvent({name = "ITEM_EVENT", type="USE_WATERLAMP_PROP", data = data})
    else
        self:dispatchEvent({name="ITEM_EVENT", type="USE_PROP", data = data}) 
    end
end

function UserInfoStuffItem:onCleanup()
    if self.iconLoaderIds then
        for i = 1, #self.iconLoaderIds do 
            nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderIds[i])
            self.iconLoaderIds[i] = nil
        end
        self.iconLoaderIds = nil
    end
end

return UserInfoStuffItem