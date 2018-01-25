--
-- Author: Tom
-- Date: 2014-09-15 11:09:27
-- 删除好友

local AvatarIcon          = import("boomegg.ui.AvatarIcon")

local WIDTH = 520
local HEIGHT = 210
local LEFT = -WIDTH * 0.5
local TOP = HEIGHT * 0.5
local RIGHT = WIDTH * 0.5
local BOTTOM = -HEIGHT * 0.5

local Panel = nk.ui.Panel
local DeleteFriendPopUp = class("DeleteFriendPopUp", Panel)

function DeleteFriendPopUp:ctor()
    self:setNodeEventEnabled(true)
    DeleteFriendPopUp.super.ctor(self, {WIDTH, HEIGHT})

    -- 头像
    local avatar_x = LEFT + 90
    self.avatar_ = AvatarIcon.new("#common_male_avatar.png", 82, 82, 8, {resId="#transparent.png", size=cc.size(100,100)}, 1, 14,0)
        :pos(avatar_x, TOP - 72)
        :addTo(self)

    self.delFriendBtn_ = cc.ui.UIPushButton.new({normal="#common_red_btn_up.png", pressed="#common_red_btn_down.png"},{scale9=true})
        :setButtonSize(122, 47)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("ROOM", "DEL_FRIEND"), size=24, color=cc.c3b(0xFF, 0xFF, 0xFF)}))
        :onButtonClicked(buttontHandler(self, self.delFriendClicked_))
        :pos(avatar_x, TOP - 150)
        :addTo(self)

    --头像ID
    self.headImageLoaderId_ = nk.ImageLoader:nextLoaderId()

    --性别图标背景
    local sex_x, sex_y = LEFT + 178, TOP - 50
    self.sexIcon_ = display.newSprite("#pop_userinfo_sex_female.png"):pos(sex_x, sex_y):addTo(self)
    --昵称
    self.nick_ = ui.newTTFLabel({size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, LEFT + 210, sex_y)
        :addTo(self)
    --UID
    self.uid_ = ui.newTTFLabel({size = 20, color = cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, LEFT + 360, sex_y)
        :addTo(self)

    --筹码
    local chip_y = TOP - 92
    self.chipIcon_ = display.newSprite("#chip_icon.png", LEFT + 174, chip_y):addTo(self)

    self.chip_ = ui.newTTFLabel({size=24, color=cc.c3b(0xff, 0xd5, 0x31)})
        :align(display.LEFT_CENTER, LEFT + 196, chip_y)
        :addTo(self)

    --等级
    self.levelIcon_ = display.newSprite("#level_icon.png")
        :align(display.LEFT_CENTER, LEFT + 360, chip_y)
        :addTo(self)

    self.level_ = ui.newTTFLabel({size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, LEFT + 400, chip_y)
        :addTo(self)

    --排名
    local rank_x = LEFT + 160
    self.ranking_ = ui.newTTFLabel({text = bm.LangUtil.getText("ROOM", "INFO_RANKING", "-"),size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, rank_x, TOP - 128)
        :addTo(self)

    --胜率
    self.winRate_ = ui.newTTFLabel({size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, rank_x, TOP - 164)
        :addTo(self)
end

function DeleteFriendPopUp:delFriendClicked_()
    bm.HttpService.POST({mod="friend", act="DelPoker", fuid = self.data.uid},
        function(retCall)                    
            local jsonCall = json.decode(retCall)
            if jsonCall then
                if jsonCall == 1 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DELE_FRIEND_SUCCESS_MSG"))
                    self:deleFriendSuccess()
                    self:hide()
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DELE_FRIEND_FAIL_MSG"))
                end
            end
        end,
        function(retCall)
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DELE_FRIEND_FAIL_MSG"))
        end
    )
end

function DeleteFriendPopUp:deleFriendSuccess()
    if self.owner then
        local list2 = self.owner:getOwner()
        local data2 = list2:getData()
        local itemData2 = data2[self.owner:getIndex()]
        table.remove(data2, self.owner:getIndex())
        list2:setData(nil)
        list2:setData(data2)
        if self.controller_ and self.controller_.sendChipsData and self.data.send > 0 then
            self.controller_.sendChipsData.cnt = self.controller_.sendChipsData.cnt - 1
            self.controller_:updateSendChipsView()
        end
    end
end

function DeleteFriendPopUp:hide()
    self:hidePanel_()
end

function DeleteFriendPopUp:show(data, owner, controller)
    self.owner = owner
    self.controller_ = controller
    self:showPanel_()
    self.data = data

    self.uid_:setString(bm.LangUtil.getText("ROOM", "INFO_UID", data.uid))
    self.chip_:setString(bm.formatBigNumber(data.money))
    self.level_:setString(bm.LangUtil.getText("ROOM", "INFO_LEVEL", nk.Level:getLevelByExp(data.exp)))
    self.winRate_:setString(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", data.win + data.lose > 0 and math.round(data.win * 100 / (data.win + data.lose)) or 0))
      
    -- 设置头像
    if data.sex == "f" then
        self.sexIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_female.png"))
        self.avatar_:setSpriteFrame("common_female_avatar.png")
    else
        self.sexIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_male.png"))
        self.avatar_:setSpriteFrame("common_male_avatar.png")
    end

    if string.len(data.img) > 5 then
        local imgurl = data.img
        if string.find(imgurl, "facebook") then
            if string.find(imgurl, "?") then
                imgurl = imgurl .. "&width=200&height=200"
            else
                imgurl = imgurl .. "?width=200&height=200"
            end
        end
        self.avatar_:loadImage(imgurl);
    end

    if data.rankMoney then
        self:setRanking_(data.rankMoney)
    else
        bm.HttpService.POST({
        mod="user",
        act="othermain",
        puid=data.uid},
        function(calldata)
            if not self.ranking_ then
                return
            end
            local jsonCall = json.decode(calldata)
            if jsonCall and jsonCall.rankMoney then
                self:setRanking_(jsonCall.rankMoney)
            end
        end)
    end
    
    -- 设置昵称
    if data.nick then
        self.nick_:setString(data.nick) -- self.nick_:setString(nk.Native:getFixedWidthText("", 24, data.nick, 120))
        bm.fitSprteWidth(self.nick_, 145)
    end

    self.avatar_:renderOtherVIP(data.viplevel)
end

function DeleteFriendPopUp:setRanking_(rankMoney)
    if rankMoney > 10000 then
        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ">10,000"))
    else
        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", bm.formatNumberWithSplit(jsonCall.rankMoney)))
    end
end

function DeleteFriendPopUp:onExit()
    nk.ImageLoader:cancelJobByLoaderId(self.headImageLoaderId_)
end

return DeleteFriendPopUp