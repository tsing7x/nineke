--
-- Author: hlf
-- Date: 2015-08-17 13:55:45
--
-- bm.ui.ListView.DIRECTION_HORIZONTAL
-- bm.ui.ListView.DIRECTION_VERTICAL
-- user-info-prop-icon.png
-- user-info-big-laba-icon.png
local UserInfoMatchToolItem = class("UserInfoMatchToolItem", bm.ui.ListItem);
UserInfoMatchToolItem.WIDTH = 228;
UserInfoMatchToolItem.HEIGHT = 202;
UserInfoMatchToolItem.ROW_GAP = 5;
UserInfoMatchToolItem.COL_GAP = 18;

function UserInfoMatchToolItem:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	UserInfoMatchToolItem.super.ctor(self, UserInfoMatchToolItem.WIDTH + UserInfoMatchToolItem.COL_GAP, UserInfoMatchToolItem.HEIGHT + UserInfoMatchToolItem.ROW_GAP);
    self.isFolded_ = true;
    
	local px, py = UserInfoMatchToolItem.WIDTH*0.5, UserInfoMatchToolItem.HEIGHT*0.5;
	-- 背景
	-- self.bg_ = display.newScale9Sprite("#user-info-prop-background-icon.png")
    self.bg_ = display.newScale9Sprite("#pop_userinfo_my_stuff_item_bg.png", 0, 0, cc.size(UserInfoMatchToolItem.WIDTH, UserInfoMatchToolItem.HEIGHT))
        :pos(px, py)
        :addTo(self);
    display.newSprite("#pop_userinfo_my_stuff_item_decoration.png")
        :scale(2)
        :pos(px, py-2)
        :addTo(self)
    -- 道具图标
    self.propIcon_ = display.newSprite("#user-info-big-laba-icon.png")
    	:pos(UserInfoMatchToolItem.WIDTH * 0.5, UserInfoMatchToolItem.HEIGHT * 0.5 + 40)
    	:addTo(self);
    -- 道具数量
    self.propNum_ = ui.newTTFLabel({text = "X0" , color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(UserInfoMatchToolItem.WIDTH * 0.5 + 70, 170)
        :addTo(self,99,99);

    display.newScale9Sprite("#pop_userinfo_my_stuff_item_text_bg.png", 0, 0, cc.size(UserInfoMatchToolItem.WIDTH - 2, 42))
        :pos(px, 71)
        :addTo(self)

    -- 道具标签
    self.propLabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("BANK", "BANK_DROP_LABEL") , color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(UserInfoMatchToolItem.WIDTH * 0.5, 70)
        :addTo(self)

    self.sprBtn_ = display.newScale9Sprite("#pop_userinfo_my_stuff_item_button_bg.png", UserInfoMatchToolItem.WIDTH * 0.5, 19, cc.size(UserInfoMatchToolItem.WIDTH-1, 48))
        :addTo(self)
    self.sprBtn_:setPositionY(25)
    self.txtBtn_ = ui.newTTFLabel({text = bm.LangUtil.getText("STORE","BUY"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(UserInfoMatchToolItem.WIDTH * 0.5, 25)
        :addTo(self)

    -- 道具使用 common_transparent_skin
    self.propUseButton_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png" , pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(UserInfoMatchToolItem.WIDTH-2, UserInfoMatchToolItem.HEIGHT-2)
        :onButtonClicked(buttontHandler(self, self.buyPropHandler_))
        :pos(UserInfoMatchToolItem.WIDTH*0.5, UserInfoMatchToolItem.HEIGHT*0.5)
        :addTo(self)
        :onButtonPressed(function(evt) 
                self.btnPressedY_ = evt.y
                self.btnClickCanceled_ = false
            end
            )
        :onButtonRelease(function(evt)
                if math.abs(evt.y - self.btnPressedY_) > 5 then
                    self.btnClickCanceled_ = true
                end
            end
            )
    self.propUseButton_:setTouchSwallowEnabled(false)
end

function UserInfoMatchToolItem:onDataSet(dataChanged, data)
	self.data_ = data;
	self:render();
end

function UserInfoMatchToolItem:render()
	if self.data_ and type(self.data_) == "table" then
        if self.data_.icon then
            local path = cc.FileUtils:getInstance():fullPathForFilename(self.data_.icon);
            if io.exists(path) then
                self.propIcon_ = display.newSprite(self.data_.icon)
                    :addTo(self)
                    :pos(UserInfoMatchToolItem.WIDTH * 0.5, UserInfoMatchToolItem.HEIGHT * 0.5 + 40);
            else
                local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(self.data_.icon);
                if frame then
                    self.propIcon_:setSpriteFrame(frame);
                end
            end
        end
		
		self.propNum_:setString(bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES",self.data_.num))
		self.propLabel_:setString(self.data_.label);

        if self.data_.btnType == 2 then
            self.txtBtn_:setString("เปิดดู")
            -- self.sprBtn_:setSpriteFrame(display.newSpriteFrame("user-info-prop-green-up.png"))
            -- self.sprBtn_:setContentSize(UserInfoMatchToolItem.WIDTH, 40)
        else
            self.txtBtn_:setString(bm.LangUtil.getText("STORE","BUY"))
            -- self.sprBtn_:setSpriteFrame(display.newSpriteFrame("user-info-prop-blue-up.png"))
            -- self.sprBtn_:setContentSize(UserInfoMatchToolItem.WIDTH, 40)
        end
	end	
end

function UserInfoMatchToolItem:buyPropHandler_(evet)
	if self.data_.btnType == 2 then
        self:dispatchEvent({name = "ITEM_EVENT", type="SEE_PROP", data=self.data_})
    else
        self:dispatchEvent({name="ITEM_EVENT", type="USE_PROP", data=self.data_}) 
    end
end

return UserInfoMatchToolItem;