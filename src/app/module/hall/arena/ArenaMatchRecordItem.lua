--
-- Author: XT
-- Date: 2015-11-19 10:16:42
--
local ArenaMatchRecordItem = class("ArenaMatchRecordItem", bm.ui.ListItem);

ArenaMatchRecordItem.WIDTH = 740;
ArenaMatchRecordItem.HEIGHT = 72;
ArenaMatchRecordItem.ROW_GAP = 2;
ArenaMatchRecordItem.PADDING_LEFT = 10;
ArenaMatchRecordItem.PADDING_RIGHT = 2;
ArenaMatchRecordItem.FONTSIZE = 20;
ArenaMatchRecordItem.OFFY = -25;

local AVATAR_TAG             = 100 -- 获取子节点时， 通过此tag查找 替换贴图
local ICON_WIDTH = 50;
local ICON_HEIGHT = 50;

function ArenaMatchRecordItem:ctor()
	local width, height = ArenaMatchRecordItem.WIDTH, ArenaMatchRecordItem.HEIGHT;
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	ArenaMatchRecordItem.super.ctor(self, width, height + ArenaMatchRecordItem.ROW_GAP);
    self:setNodeEventEnabled(true)
	-- 分割线
	display.newScale9Sprite("#pop_up_split_line.png"):size(width-20, 2):pos(width*0.5,5):addTo(self);
	-- 时间、名次、奖励、操作
	local dw,dh = 200, 32;
	local px = 0 + dw*0.5;
	local py = 0.5 * ArenaMatchRecordItem.HEIGHT + 5;
    local fontSzs = ArenaMatchRecordItem.FONTSIZE;
    local lblColor = styles.FONT_COLOR.LIGHT_TEXT;
    self.tsLbl_ = ui.newTTFLabel({
                text  = "",
                color = lblColor,
                align=ui.TEXT_ALIGN_CENTER,
                dimensions=cc.size(dw,dh),
                size  = fontSzs
            })
    		:pos(px, py)
    		:addTo(self);
    px = px + dw*0.5;
    dw = 90
    px = px + dw*0.5;
    self.rankbg_ = display.newSprite("#matchreg_num_bg.png")
        :pos(px,py)
        :addTo(self)
    self.rankLbl_ = ui.newTTFLabel({
            text="",
            color=lblColor,
            size=28,
            align=ui.TEXT_ALIGN_CENTER,
            dimensions=cc.size(dw, 0)
        })
        :pos(px, py)
        :addTo(self)
    self.ranksp_ = display.newSprite("#matchreg_high_1.png")
        :pos(px,py)
        :addTo(self)
    px = px + dw*0.5;
    dw = 330
    px = px + dw*0.5;
    self.rewardLbl_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("USERINFOMATCH","NOREWARD"),
            color=lblColor,
            size=fontSzs,
            align=ui.TEXT_ALIGN_CENTER,
            dimensions=cc.size(dw, 0)
        })
        :pos(px, py)
        :addTo(self)
    px = px + dw*0.5;
    dw = 110
    px = px + dw*0.5;
    -- self.actLbl_ = ui.newTTFLabel({
    --         text="",
    --         color=lblColor,
    --         size=fontSzs,
    --         align=ui.TEXT_ALIGN_CENTER,
    --         dimensions=cc.size(dw, 0)
    --     })
    --     :pos(px, py)
    --     :addTo(self)

    self.btnTxt_ = ui.newTTFLabel({
    		text=bm.LangUtil.getText("MATCH", "MATCHDETAIL"),
    		size = 16,
    		color = styles.FONT_COLOR.LIGHT_TEXT,
    		align = ui.TEXT_ALIGN_CENTER,
    	})
    self.btn_ = cc.ui.UIPushButton.new({
	    		normal="#common_btn_green_normal.png",
	    		pressed="#common_btn_green_pressed.png"
	    	},
	    	{
	    		scale9=true
	    	}
    	)
    	:setButtonSize(112, 52)
    	:setButtonLabel(self.btnTxt_)
    	:pos(px, py)
    	:addTo(self)
    	:onButtonClicked(handler(self, self.onClick_))
end

function ArenaMatchRecordItem:onClick_(evt)
	self:dispatchEvent({name="ITEM_EVENT", data=self.data_})
end

function ArenaMatchRecordItem:onDataSet(dataChanged, data)
	self.data_ = data;
	self:renderInfo();
end

function ArenaMatchRecordItem:setRank(rank)
    if rank >= 10 then
        self.rankLbl_:show()
        self.rankLbl_:setString(rank)
        self.ranksp_:hide()
    else
        self.rankLbl_:hide()
        self.ranksp_:show()
        if rank < 3 and rank > 0 then
            self.ranksp_:setSpriteFrame(display.newSpriteFrame("matchreg_high_" .. rank .. ".png"))
        else
            self.ranksp_:setSpriteFrame(display.newSpriteFrame("matchreg_num_" .. rank .. ".png"))
        end
    end
end

-- 绑定数据
function ArenaMatchRecordItem:renderInfo()
	-- self.rankLbl_:setString(self.data_.rank);
    self:setRank(tonumber(self.data_.rank) or 1)
    local ts = bm.TimeUtil:getTimeStampString(self.data_.time,"-");
    self.tsLbl_:setString(ts)

    -- 比赛券、金券、积分
    if self.data_.reward then
        self:renderIconData(self.data_.reward.giftId, {self.data_.reward.gameCoupon or 0, self.data_.reward.goldCoupon or 0, self.data_.reward.gcoins or 0, self.data_.reward.score or 0, self.data_.reward.chips or 0}, self.data_.reward.real);
        self.rewardLbl_:hide();
        -- 判断是否有实物
        if self.data_.reward.real then
            self.btn_:show();
        else
            self.btn_:hide();
        end
    else
        self:clearIconNode_();
        self.rewardLbl_:show();
        self.btn_:hide();
    end

    -- 判断是否存在实物
    -- self.btn_:show();
end

function ArenaMatchRecordItem:clearIconNode_()
    if self.iconNode_ then
        self.iconNode_:removeSelf();
    end
end
-- 比赛券、金券、积分
function ArenaMatchRecordItem:renderIconData(giftId, vals, real)
    self:clearIconNode_();

    if (vals and #vals > 0) or real or giftId then
        local fontSzs = ArenaMatchRecordItem.FONTSIZE;
        local offY = 0.5 * ArenaMatchRecordItem.HEIGHT + 5;
        local tb = {};
        self.iconNode_ = display.newNode():addTo(self);
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
        -- 黄金币
        self.iconGold_ = display.newSprite("#common_gcoin_icon.png"):pos(0, 0):addTo(self.iconNode_);
        self.goldCoupon_ = ui.newTTFLabel({
                    text  = "x"..vals[3],
                    color = cc.c3b(0xff, 0xff, 0xff),
                    align=ui.TEXT_ALIGN_CENTER,
                    size  = fontSzs
                }):pos(25, offY):addTo(self.iconNode_);
        table.insert(tb, #tb+1, {self.iconGold_, self.goldCoupon_});
        -- 
        self.iconScore_ = display.newSprite("#icon_score.png"):pos(0, 0):addTo(self.iconNode_);
        self.iconScore_:setScale(0.9);
        self.score_ = ui.newTTFLabel({
                    text  = "x"..vals[4],
                    color = cc.c3b(0xff, 0xff, 0xff),
                    align=ui.TEXT_ALIGN_CENTER,
                    size  = fontSzs
                }):pos(25, offY):addTo(self.iconNode_);
        table.insert(tb, #tb+1, {self.iconScore_, self.score_});
        -- 
        self.iconChip_ = display.newSprite("#chip_icon.png"):pos(0, 0):addTo(self.iconNode_);
        self.iconChip_:scale(0.9)
        self.chip_ = ui.newTTFLabel({
                    text  = "x"..bm.formatNumberWithSplit(vals[5]),
                    color = cc.c3b(0xff, 0xff, 0xff),
                    align=ui.TEXT_ALIGN_CENTER,
                    size  = fontSzs
                }):pos(25, offY):addTo(self.iconNode_);
        table.insert(tb, #tb+1, {self.iconChip_, self.chip_});
        -- 
        local arr;
        local px = 15;
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
        local offYs = {ArenaMatchRecordItem.HEIGHT - 15, ArenaMatchRecordItem.HEIGHT - 47};
        if #showsArr > 2 then
            px = 30;
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
                    real.img, 
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
                            -- self.awardIcon_:setTextureRect(CCRect(0, 0, texSize.width, texSize.height))
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
        self.iconNode_:pos(450-px*0.5-10, 0)
    end
end

function ArenaMatchRecordItem:onCleanup()
    if self.iconLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
        self.iconLoaderId_ = nil;
    end
end

return ArenaMatchRecordItem;