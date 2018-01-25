--
-- Author: HLF
-- Date: 2015-09-23 20:52:55
--
local UserInfoMatchOtherItem = class("UserInfoMatchOtherItem", bm.ui.ListItem);

UserInfoMatchOtherItem.WIDTH = 415;
UserInfoMatchOtherItem.HEIGHT = 55;
UserInfoMatchOtherItem.ROW_GAP = 0;
UserInfoMatchOtherItem.COL_GAP = 0;

function UserInfoMatchOtherItem:ctor()
	self:setNodeEventEnabled(true);

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	UserInfoMatchOtherItem.super.ctor(self, UserInfoMatchOtherItem.WIDTH + UserInfoMatchOtherItem.COL_GAP, UserInfoMatchOtherItem.HEIGHT + UserInfoMatchOtherItem.ROW_GAP);
	-- 
	local LEFT = 0;
	local TOP = 110;
	local py = 0;
	local dws,dhs = 220, 28;
    local offXs, offYs = 120, 0;
    local fontSzs = 20;
    local lblFontSz = 16;
    local lblColor = cc.c3b(68, 84, 106);
    local txtColor = cc.c3b(173, 174, 174)
	self.feeLbl_ = ui.newTTFLabel({
                text  = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[1],
                color = txtColor,
                align=ui.TEXT_ALIGN_CENTER,
                dimensions=cc.size(dws,dhs),
                size  = fontSzs
            }):pos(LEFT + offXs, TOP - py - 80):addTo(self);
	-- 
	dws = 160;
    local offXs2 = 140
	self.feeWinLbl_ = ui.newTTFLabel({
                text  = "0%", --bm.LangUtil.getText("USERINFOMATCH", "WINRATE", 0),
                color = txtColor,
                align=ui.TEXT_ALIGN_CENTER,
                dimensions=cc.size(dws,dhs),
                size  = fontSzs
            }):pos(LEFT + offXs + offXs2, TOP - py - 80):addTo(self);
	-- 
	dws = 160;
    local offXs3 = 100;
    self.feeCntLbl_ = ui.newTTFLabel({
                text  = "0", --bm.LangUtil.getText("USERINFOMATCH", "MATCHCNT", 0),
                color = txtColor,
                align=ui.TEXT_ALIGN_CENTER,
                dimensions=cc.size(dws,dhs),
                size  = fontSzs
            }):pos(LEFT + offXs + offXs2 + offXs3, TOP - py - 80):addTo(self);
    -- 
	display.newScale9Sprite("#user-info-desc-division-line.png",0 ,0 , cc.size(450 ,3)):pos(LEFT + 245, TOP - py - 100):addTo(self)
end

function UserInfoMatchOtherItem:onDataSet(dataChanged, data)
	self.data_ = data;
	self:render();
end

function UserInfoMatchOtherItem:render()
	if nil ~= self.data_ then
		-- 
		self.feeLbl_:setString(self.data_.name);
		-- 
		self.feeCntLbl_:setString(self.data_.cnt);-- 初级场 "参赛次数:{1}"
		-- "获冠军率:{1}%"
        local val,_ = math.modf(self.data_.championRate*100);
        self.feeWinLbl_:setString(val.."%");-- 初级场 "获冠军率:{1}%"
	end
end

return UserInfoMatchOtherItem;