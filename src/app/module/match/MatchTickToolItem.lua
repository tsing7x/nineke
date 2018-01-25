--
-- Author: XT
-- Date: 2015-11-02 12:28:28
--
local MatchTickToolItem = class("MatchTickToolItem", bm.ui.ListItem);
MatchTickToolItem.WIDTH = 170;
MatchTickToolItem.HEIGHT = 180;
MatchTickToolItem.ROW_GAP = 5;
MatchTickToolItem.COL_GAP = 6;
local ICON_WIDTH = 120
local ICON_HEIGHT = 120
local AVATAR_TAG = 101
local IS_USEGRAY = true;

function MatchTickToolItem:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	MatchTickToolItem.super.ctor(self, MatchTickToolItem.WIDTH + MatchTickToolItem.COL_GAP, MatchTickToolItem.HEIGHT + MatchTickToolItem.ROW_GAP);
    self.isFolded_ = true;

    self:setNodeEventEnabled(true);
    local px, py = MatchTickToolItem.WIDTH*0.5, MatchTickToolItem.HEIGHT*0.5;

    -- 背景
	self.bg_ = display.newScale9Sprite("#pop_userinfo_my_stuff_item_bg.png", px, py, cc.size(MatchTickToolItem.WIDTH, MatchTickToolItem.HEIGHT))
        :addTo(self)
    display.newSprite("#pop_userinfo_my_stuff_item_decoration.png")
        :scale(2)
        :pos(px, py-2)
        :addTo(self)
    display.newScale9Sprite("#pop_userinfo_my_stuff_item_text_bg.png", 0, 0, cc.size(MatchTickToolItem.WIDTH - 2, 42))
        :pos(px, 55)
        :addTo(self)
    -- 道具图标
    self.propIcon_ = display.newSprite(nk.MatchTickManager.iconUrl)
    	:pos(MatchTickToolItem.WIDTH * 0.5, MatchTickToolItem.HEIGHT * 0.5 + 40)
    	:addTo(self);

    -- 加载图标
    self.icon_ = display.newNode()
    			:size(ICON_WIDTH, ICON_HEIGHT)
    			:pos(MatchTickToolItem.WIDTH * 0.5, MatchTickToolItem.HEIGHT * 0.5 + 20)
    			:addTo(self)
    self.icon_:hide();

    -- 道具数量
    self.propNum_ = ui.newTTFLabelWithOutline({
            text = "X0" , 
            color = styles.FONT_COLOR.GOLDEN_TEXT, 
            size = 18, 
            align = ui.TEXT_ALIGN_CENTER,
            outlineWidth = 1,
        })
        :pos(MatchTickToolItem.WIDTH * 0.5 + 30, 146)
        :addTo(self, 2, 2);

    -- 道具有效期
    self.propDate_ = ui.newTTFLabelWithOutline({
            text = "" , 
            color = cc.c3b(0x27, 0x90, 0xd5), 
            size = 22, 
            align = ui.TEXT_ALIGN_CENTER,
            outlineWidth = 1,
        })
        :pos(MatchTickToolItem.WIDTH * 0.5, 60)
        :addTo(self, 3, 3)

    -- 标题
    self.propName_ = ui.newTTFLabelWithOutline({
    		text = "",
    		color = styles.FONT_COLOR.GOLDEN_TEXT,
    		size = 22,
    		align = ui.TEXT_ALIGN_CENTER,
            outlineWidth = 1,
    	})
    	:pos(MatchTickToolItem.WIDTH * 0.5, 168)
    	:addTo(self, 4, 4)

    -- 道具使用
    px, py = MatchTickToolItem.WIDTH * 0.5, 19;
    self.btnLbl_ = ui.newTTFLabel({
            text = bm.LangUtil.getText("TICKET", "APPLY_LABLE"), 
            color = cc.c3b(0xC7, 0xE5, 0xFF), 
            size = 26, 
            align = ui.TEXT_ALIGN_CENTER
        })
    self.propUseButton_ = cc.ui.UIPushButton.new({normal = "#pop_userinfo_my_stuff_item_button_bg.png"}, {scale9 = true})
        :setButtonSize(MatchTickToolItem.WIDTH-3, 40)
        :pos(px, py+3)
        :setButtonLabel(self.btnLbl_)
        :addTo(self)
    self.propUseButton_:setButtonEnabled(false)
    self.propUseButton1_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png" , pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(MatchTickToolItem.WIDTH-3, 40)
        :pos(px, py+3)
        :onButtonClicked(buttontHandler(self, self.applyPropHandler_))
        :addTo(self)

    if not IS_USEGRAY then
        self.grayLbl_ = ui.newTTFLabel({
                text = bm.LangUtil.getText("TICKET", "APPLY_LABLE"), 
                color = cc.c3b(0x99, 0x99, 0x99), 
                size = 26, 
                align = ui.TEXT_ALIGN_CENTER
            })
        self.grayBtn_ = cc.ui.UIPushButton.new({normal = "#pop_userinfo_my_stuff_item_button_disabled_bg.png"}, {scale9 = true})
            :setButtonSize(MatchTickToolItem.WIDTH-3, 40)
            :pos(px, py+3)
            :setButtonLabel(self.grayLbl_)
            :onButtonClicked(buttontHandler(self, self.applyPropHandler_))
            :addTo(self)
        self.grayBtn_:setButtonEnabled(false)
        self.grayBtn_:hide();
    end
    self.btnPX_, self.btnPY_ = px, py+4;
end

function MatchTickToolItem:onDataSet(dataChanged, data)
	self.data_ = data;
	self:render();
end

function MatchTickToolItem:addOverDueSign_()
    if not self.overDueSign_ then
        local px, py = self.icon_:getPosition();
        self.overDueSign_ = display.newSprite("#overdue_tick_sign.png")
            :pos(px, py)
            :addTo(self, 10, 999)
        self.overDueSign_:setScale(0.6)
        self.overDueSign_:setRotation(-25)
    end
end

function MatchTickToolItem:removeOverDueSign_()
    if self.overDueSign_ then
        self.overDueSign_:removeFromParent();
        self.overDueSign_ = nil;
    end
end

function MatchTickToolItem:render()
	if self.propIcon_ then
		self.propIcon_:removeFromParent();
	end

	self.propNum_:setString("X"..self.data_.num);
    local sz = self.propNum_:getContentSize();
    self.propNum_:setPositionX(MatchTickToolItem.WIDTH - sz.width*0.5 - 6)
	if self.data_.num > 0 then
        self.propUseButton1_:setButtonEnabled(true);
	else
        self.propUseButton1_:setButtonEnabled(false);
	end
	-- 是否过期:true为过期
	if not self.data_.isOverDate then
        str = nk.MatchTickManager:getTickDateStr(self.data_.endtime);
		self.propDate_:setString(str);
        self.propUseButton1_:setButtonEnabled(true);
        self.propUseButton1_:show()
        self.propUseButton_:show();

        if not IS_USEGRAY then
            self.grayBtn_:hide();
        end

        self:removeOverDueSign_();
	else
		self.propDate_:setString("");
        if not IS_USEGRAY then
            self.grayBtn_:show();
        else
            -- 使用滤镜实现灰色
            if not self.grayBtn_ then
                sz = cc.size(MatchTickToolItem.WIDTH, 40)
                local btnClone = bm.cloneNode(self.propUseButton_, sz, MatchTickToolItem.WIDTH*0.5, 40*0.5-2);
                if btnClone then
                    local btnTex = btnClone:getTexture();
                    if btnTex then
                        self.grayBtn_ = bm.grayNodeByTex(btnTex)
                        self.grayBtn_:pos(self.btnPX_, self.btnPY_):addTo(self)
                        self.grayBtn_:flipY(true)
                    end
                end
            end
        end
        self.propUseButton_:setButtonEnabled(false);
        self.propUseButton_:hide();
        self.propUseButton1_:setButtonEnabled(false);
        self.propUseButton1_:hide()

        self:addOverDueSign_();
	end
	self.propName_:setString(self.data_.name);
    bm.fitSprteWidth(self.propName_, MatchTickToolItem.WIDTH - 8);
    bm.fitSprteWidth(self.propDate_, MatchTickToolItem.WIDTH - 8);

    local px, py = MatchTickToolItem.WIDTH * 0.5, MatchTickToolItem.HEIGHT * 0.5 + 24;
	if string.find(self.data_.img, "http://") then
		if not self.iconLoaderId_ then
			self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
		end

        local imgStr = self.data_.img;
        if not IS_USEGRAY and self.data_.isOverDate then
            local replaceStr = ".png"
            local arr = string.split(self.data_.img, replaceStr)
            if #arr == 2 then
                imgStr = arr[1].."g"..replaceStr..arr[2];
            end
        end
        
		local iconContainer = self.icon_;
		nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
		nk.ImageLoader:loadAndCacheImage(self.iconLoaderId_,
            imgStr, 
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

                    -- 判断是否过期
                    if not self.data_.isOverDate then
                        sprite:scale(xxScale<yyScale and xxScale or yyScale):addTo(iconContainer, 0, AVATAR_TAG)
                        iconContainer:show();
                    else
                        if not IS_USEGRAY then
                            sprite:scale(xxScale<yyScale and xxScale or yyScale):addTo(iconContainer, 0, AVATAR_TAG)
                            iconContainer:show();
                        else
                            local spr_ = bm.grayNodeByTex(tex)
                            spr_:scale(xxScale<yyScale and xxScale or yyScale):addTo(iconContainer, 0, AVATAR_TAG)
                            iconContainer:show(); 
                        end
                    end
                end
            end,
            nk.ImageLoader.CACHE_TYPE_GIFT
        )
	else        
		self.propIcon_ = display.newSprite(self.data_.img)
			:pos(px, py)
			:addTo(self, 1, 1);
	end
	
end

function MatchTickToolItem:applyPropHandler_(evt)
	self:dispatchEvent({name="ITEM_EVENT", type="APPLY_PROP", data=self.data_}) 
end

function MatchTickToolItem:onCleanup()
	if self.iconLoaderId_ then
		nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
		self.iconLoaderId_ = nil;
	end
end

return MatchTickToolItem;