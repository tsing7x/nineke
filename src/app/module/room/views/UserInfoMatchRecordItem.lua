--
-- Author: XT
-- Date: 2015-08-17 10:38:14
--
-----------------------------------------------
local UserInfoMatchRecordItem = class("UserInfoMatchRecordItem", bm.ui.ListItem);
UserInfoMatchRecordItem.WIDTH = 640;
UserInfoMatchRecordItem.HEIGHT = 60;
UserInfoMatchRecordItem.ROW_GAP = 2;
UserInfoMatchRecordItem.PADDING_LEFT = 10;
UserInfoMatchRecordItem.PADDING_RIGHT = 2;
UserInfoMatchRecordItem.FONTSIZE = 18;
UserInfoMatchRecordItem.OFFY = -25;

local AVATAR_TAG             = 100 -- 获取子节点时， 通过此tag查找 替换贴图
local ICON_WIDTH = 50;
local ICON_HEIGHT = 50;

function UserInfoMatchRecordItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
    UserInfoMatchRecordItem.super.ctor(self, UserInfoMatchRecordItem.WIDTH, UserInfoMatchRecordItem.HEIGHT + UserInfoMatchRecordItem.ROW_GAP)
    self:setNodeEventEnabled(true)

    -- 分割线
    display.newScale9Sprite("#pop_up_split_line.png"):size(590, 2):pos(0, 5):addTo(self);
    
    local py = 0.5 * UserInfoMatchRecordItem.HEIGHT + 5;
	local dws,dhs = 180, 32;
    local TOP = 0;
    local fontSzs = UserInfoMatchRecordItem.FONTSIZE;
    local lblColor = cc.c3b(0xff, 0xff, 0xff);
    local px = -UserInfoMatchRecordItem.WIDTH * 0.5 + 85;
    self.typeLbl_ = ui.newTTFLabel({
                text  = "",
                color = lblColor,
                align=ui.TEXT_ALIGN_CENTER,
                dimensions=cc.size(dws,dhs),
                size  = fontSzs
            }):pos(px, py):addTo(self);
    -- 
    px = -UserInfoMatchRecordItem.WIDTH * 0.5 + 210;
    self.rankLbl_ = ui.newTTFLabel({
                text  = "1",
                color = lblColor,
                align=ui.TEXT_ALIGN_CENTER,
                dimensions=cc.size(dws,dhs),
                size  = fontSzs
            }):pos(px, py):addTo(self);
    -- 
    dws = 350
    px = 30
    self.rewardLbl_ = ui.newTTFLabel({
                text  = bm.LangUtil.getText("USERINFOMATCH","NOREWARD"),
                color = lblColor,
                align=ui.TEXT_ALIGN_CENTER,
                dimensions=cc.size(dws,dhs),
                size  = fontSzs
            }):pos(px, py):addTo(self);
    -- 
    dws = 260;
    self.timelbldw_ = dws;
    self.timelbldh_ = dhs;
    px = (UserInfoMatchRecordItem.WIDTH - 40)*0.5 - 60;
    self.timeLbl_ = ui.newTTFLabel({
                text  = "20:00:00",
                color = lblColor,
                align=ui.TEXT_ALIGN_CENTER,
                dimensions=cc.size(dws,dhs),
                size  = fontSzs
            }):pos(px, py):addTo(self);

    self.btnTxt_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("MATCH", "MATCHDETAIL"),
            size = 16,
            color = styles.FONT_COLOR.LIGHT_TEXT,
            align = ui.TEXT_ALIGN_CENTER,
        })
    self.btn_ = cc.ui.UIPushButton.new({
                normal="#common_dark_blue_btn_up.png",
                pressed="#common_dark_blue_btn_down.png"
            },
            {
                scale9=true
            }
        )
        :setButtonSize(112, 36)
        :setButtonLabel(self.btnTxt_)
        :pos(px, py)
        :addTo(self)
        :onButtonClicked(handler(self, self.onClick_))
    self.btn_:hide();
end

function UserInfoMatchRecordItem:clearIconNode_()
    if self.iconNode_ then
        self.iconNode_:removeSelf();
    end
end

function UserInfoMatchRecordItem:onClick_(evt)
    self:dispatchEvent({name="ITEM_EVENT", type="ITEM_EVENT_BTN_CLICK", data=self.data_})
end

-- 比赛券、金券、积分
function UserInfoMatchRecordItem:renderIconData(giftId, vals, real)
    self:clearIconNode_();

    if (vals and #vals > 0) or real or giftId then
        local fontSzs = UserInfoMatchRecordItem.FONTSIZE;
        local offY = 0.5 * UserInfoMatchRecordItem.HEIGHT + 5;
        local tb = {};
        self.iconNode_ = display.newNode():addTo(self);
        -- 
        local cupUrl;
        if giftId == 1049 then
            cupUrl = "#match_cup1.png";
        elseif giftId == 1048 then
            cupUrl = "#match_cup2.png";
        elseif giftId == 1047 then
            cupUrl = "#match_cup3.png";
        end
        -- 
        if cupUrl then
            self.iconCup_ = display.newSprite(cupUrl):pos(0, offY):addTo(self.iconNode_);
            self.iconCup_:scale(0.5);
        end
        -- 
        self.iconGameCoupon_ = display.newSprite("#icon_gamecoupon.png"):pos(0, 0):addTo(self.iconNode_);
        self.gameCoupon_ = ui.newTTFLabel({
                    text  = "x"..vals[1],
                    color = cc.c3b(0xff, 0xff, 0xff),
                    align=ui.TEXT_ALIGN_CENTER,
                    size  = fontSzs
                }):pos(25, offY):addTo(self.iconNode_);
        table.insert(tb, #tb+1, {self.iconGameCoupon_, self.gameCoupon_});
        -- 
        self.iconGold_ = display.newSprite("#icon_goldcoupon.png"):pos(0, 0):addTo(self.iconNode_);
        self.goldCoupon_ = ui.newTTFLabel({
                    text  = "x"..vals[2],
                    color = cc.c3b(0xff, 0xff, 0xff),
                    align=ui.TEXT_ALIGN_CENTER,
                    size  = fontSzs
                }):pos(25, offY):addTo(self.iconNode_);
        table.insert(tb, #tb+1, {self.iconGold_, self.goldCoupon_});
        -- 
        self.iconScore_ = display.newSprite("#icon_score.png"):pos(0, 0):addTo(self.iconNode_);
        self.iconScore_:setScale(0.9);
        self.score_ = ui.newTTFLabel({
                    text  = "x"..vals[3],
                    color = cc.c3b(0xff, 0xff, 0xff),
                    align=ui.TEXT_ALIGN_CENTER,
                    size  = fontSzs
                }):pos(25, offY):addTo(self.iconNode_);
        table.insert(tb, #tb+1, {self.iconScore_, self.score_});
        -- 
        self.iconChip_ = display.newSprite("#chip_icon.png"):pos(0, 0):addTo(self.iconNode_);
        self.iconChip_:setScale(0.9);
        self.chip_ = ui.newTTFLabel({
                    text  = "x"..bm.formatNumberWithSplit(vals[4]),
                    color = cc.c3b(0xff, 0xff, 0xff),
                    align=ui.TEXT_ALIGN_CENTER,
                    size  = fontSzs
                }):pos(25, offY):addTo(self.iconNode_);
        table.insert(tb, #tb+1, {self.iconChip_, self.chip_});
        -- 
        local arr;
        local px = 0;
        local iconSz;
        local lblSz;
        local showsArr = {}
        for i=1,#tb do
            arr = tb[i];
            if vals[i] > 0 then
                arr[1]:show();
                arr[2]:show();
                iconSz = arr[1]:getContentSize();
                lblSz = arr[2]:getContentSize();
                px = px + iconSz.width*0.5;
                arr[1]:pos(px, offY);
                px = px + lblSz.width*0.5 + iconSz.width*0.5;
                arr[2]:pos(px, offY);
                px = px + lblSz.width*0.5 + 2;

                table.insert(showsArr, #showsArr+1, arr);
            else
                arr[1]:hide();
                arr[2]:hide();
            end
        end
        -- 
        local offYs = {UserInfoMatchRecordItem.HEIGHT - 10, UserInfoMatchRecordItem.HEIGHT - 38};
        if #showsArr > 2 then
            px = 0;
            local lastdw = 0;
            local len = #showsArr;
            local lastMax = 0;
            for i=0,len-1 do
                arr = showsArr[i+1];
                local idx = i%2+1;
                local py=offYs[idx]
                iconSz = arr[1]:getContentSize();
                lblSz = arr[2]:getContentSize();
                local dw = iconSz.width + lblSz.width + 2;

                local x = px + iconSz.width*0.5;
                arr[1]:pos(x, py);
                x = x + lblSz.width*0.5 + iconSz.width*0.5;
                arr[2]:pos(x, py);
                x = x + lblSz.width*0.5 + 2;

                if i%2 == 1 then
                    lastMax = math.max(lastdw, dw);
                    px = px + lastMax
                else
                    lastdw = dw;
                    lastMax = lastdw;
                end
            end

            if len%2 == 1 then
                px = px + lastMax
            end
        end


        if self.iconCup_ then
            iconSz = self.iconCup_:getContentSize();
            self.iconCup_:pos(-12, offY)
        end

        if real then
            self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
            self.icon_ = display.newNode()
            :size(ICON_WIDTH, ICON_HEIGHT)
            :addTo(self.iconNode_, 6, 6)
            :pos(px+ICON_WIDTH*0.5, offY)
            px = px + ICON_WIDTH
            -- 
            self.logo_ = display.newSprite("#game_logo.png")
                :addTo(self.icon_, AVATAR_TAG, AVATAR_TAG)
            local sz = self.logo_:getContentSize();
            local xscale = ICON_WIDTH/sz.width;
            local yscale = ICON_HEIGHT/sz.height;
            self.logo_:setScale(xscale>yscale and yscale or xscale)

            local iconContainer = self.icon_
            local iconLoader = self.iconLoaderId_
            nk.ImageLoader:cancelJobByLoaderId(iconLoader)
            nk.ImageLoader:loadAndCacheImage(iconLoader,
                    nk.userData.cdn..""..real, 
                    function(success, sprite)
                        if success then
                            -- print("success===============")
                            local tex = sprite:getTexture()
                            local texSize = tex:getContentSize()
                            local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
                            if oldAvatar then
                                oldAvatar:removeFromParent()
                            end
                            -- self.awardIcon_:setTexture(tex)
                            -- self.awardIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
                            local iconSize = iconContainer:getContentSize()
                            local xxScale = iconSize.width/texSize.width
                            local yyScale = iconSize.height/texSize.height
                            sprite:scale(xxScale<yyScale and xxScale or yyScale)
                                :addTo(iconContainer, 0, AVATAR_TAG)
                                -- :pos(iconSize.width/2,iconSize.height/2)
                            -- 
                            iconContainer:show();
                        else
                            -- print("faile===============")
                        end
                    end,
                    nk.ImageLoader.CACHE_TYPE_GIFT
                )
        end
        self.iconNode_:pos(50-px*0.5-10, 0)
    end
end

function UserInfoMatchRecordItem:onDataSet(dataChanged, data)
    -- self.rankLbl_:setString(data);
    self.data_ = data;
    self:renderInfo();
end

function UserInfoMatchRecordItem:renderInfo()
    local typeName = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[1];
    if self.data_.id == 11 then
        typeName = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[1];
    elseif self.data_.id == 21 then
        typeName = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[2];
    elseif self.data_.id == 31 then
        typeName = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[3];
    end
    -- 
    self.typeLbl_:setString(self.data_.name);-- self.typeLbl_:setString(typeName);
    self.rankLbl_:setString(self.data_.rank);
    -- self.rankLbl_:setString(100);
    local ts = bm.TimeUtil:getTimeStampString(self.data_.time,"-");
    self.timeLbl_:setString(ts)
    -- 比赛券、金券、积分
    if self.data_.reward then
        self:renderIconData(self.data_.reward.giftId, {self.data_.reward.gameCoupon or 0, self.data_.reward.goldCoupon or 0, self.data_.reward.score or 0, self.data_.reward.chips or 0}, self.data_.reward.real);
        self.rewardLbl_:hide();
    else
        self:clearIconNode_();
        self.rewardLbl_:show();
    end
end

function UserInfoMatchRecordItem:onCleanup()
    if self.iconLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
        self.iconLoaderId_ = nil;
    end
end

return UserInfoMatchRecordItem;