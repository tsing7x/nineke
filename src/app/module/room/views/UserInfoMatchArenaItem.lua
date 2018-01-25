--
-- Author: HLF
-- Date: 2015-09-22 16:05:45
--

local UserInfoMatchArenaItem = class("UserInfoMatchArenaItem", bm.ui.ListItem)
UserInfoMatchArenaItem.WIDTH = 610
UserInfoMatchArenaItem.HEIGHT = 55
UserInfoMatchArenaItem.ROW_GAP = 0
UserInfoMatchArenaItem.COL_GAP = 0

function UserInfoMatchArenaItem:ctor()
	self:setNodeEventEnabled(true)

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	UserInfoMatchArenaItem.super.ctor(self, UserInfoMatchArenaItem.WIDTH + UserInfoMatchArenaItem.COL_GAP, UserInfoMatchArenaItem.HEIGHT + UserInfoMatchArenaItem.ROW_GAP)

	local px, py =120, 30
	local dws, dhs = 210, 28
    local fontSzs = 22
    local txtColor = cc.c3b(173, 174, 174)

	self.feeLbl_ = ui.newTTFLabel({
        text  = bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT")[1],
        color = txtColor,
        align=ui.TEXT_ALIGN_CENTER,
        dimensions=cc.size(dws,dhs),
        size  = fontSzs
    }):pos(px, py):addTo(self)

	dws = 180
    px = px + 210
	self.feeWinLbl_ = ui.newTTFLabel({
        text  = "0%",
        color = txtColor,
        align=ui.TEXT_ALIGN_CENTER,
        dimensions=cc.size(dws,dhs),
        size  = fontSzs
    }):pos(px, py):addTo(self)

	dws = 180
    px = px + 220
    self.feeCntLbl_ = ui.newTTFLabel({
        text  = "0",
        color = txtColor,
        align=ui.TEXT_ALIGN_CENTER,
        dimensions=cc.size(dws,dhs),
        size  = fontSzs
    }):pos(px, py):addTo(self)
end

function UserInfoMatchArenaItem:onDataSet(dataChanged, data)
	self.data_ = data
	self:render()
end

function UserInfoMatchArenaItem:render()
	if nil ~= self.data_ then
		self.feeLbl_:setString(self.data_.name)
		self.feeCntLbl_:setString(self.data_.cnt)-- 初级场 "参赛次数:{1}"

        local val,_ = math.modf(self.data_.championRate*100)
        self.feeWinLbl_:setString(val.."%")-- 初级场 "获冠军率:{1}%"
	end
end

return UserInfoMatchArenaItem