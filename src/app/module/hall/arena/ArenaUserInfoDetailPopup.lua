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
local ArenaUserInfoDetailPopup = class("ArenaUserInfoDetailPopup", Panel)

function ArenaUserInfoDetailPopup:ctor()
    self:setNodeEventEnabled(true)
    ArenaUserInfoDetailPopup.super.ctor(self, {WIDTH, HEIGHT})

    -- 头像
    local avatar_x = LEFT + 90
    self.avatar_ = AvatarIcon.new("#common_male_avatar.png", 82, 82, 8, {resId="#transparent.png", size=cc.size(100,100)}, 1, 14,0)
        :pos(avatar_x, TOP - 72)
        :addTo(self)

    self.addFriendBtn_ = cc.ui.UIPushButton.new({
                normal = {"#pop_userinfo_other_green_normal.png", "#pop_userinfo_other_addFriends_add.png"},
                pressed = {"#pop_userinfo_other_green_pressed.png", "#pop_userinfo_other_addFriends_add.png"},
                disabled= {"#pop_userinfo_other_disable.png", "#pop_userinfo_other_addFriends_disable.png"},
            })
        :onButtonClicked(buttontHandler(self, self.onFriendClicked_))
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
    self.ranking_ = ui.newTTFLabel({text = bm.LangUtil.getText("ROOM", "INFO_RANKING", ".."),size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, rank_x, TOP - 128)
        :addTo(self)

    --胜率
    self.winRate_ = ui.newTTFLabel({size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, rank_x, TOP - 164)
        :addTo(self)
end

function ArenaUserInfoDetailPopup:hide()
    self:hidePanel_()
end

function ArenaUserInfoDetailPopup:show(uid)
    self:showPanel_()
    self.uidt_ = uid
    bm.HttpService.POST({mod="user", act="othermain", puid=uid},
                function(calldata)
                    local data = json.decode(calldata)
                        self:setData(data)
                end, function()
                    end)
end

function ArenaUserInfoDetailPopup:setData(data)
    self.uid_:setString(bm.LangUtil.getText("ROOM", "INFO_UID", tostring(self.uidt_)))
    self.chip_:setString(bm.formatBigNumber(data.money))
    self.level_:setString(bm.LangUtil.getText("ROOM", "INFO_LEVEL", data.level))
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

    if data.rankMoney > 10000 then
        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ">10,000"))
    else
        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", bm.formatNumberWithSplit(data.rankMoney)))
    end

    if data.nick then
        self.nick_:setString(data.nick) -- self.nick_:setString(nk.Native:getFixedWidthText("", 24, data.nick, 120))
        bm.fitSprteWidth(self.nick_, 145)
    end

    if data.fri then
        self.isFriend_ = data.fri
        self:setAddFriendStatus()
    end
    if data.viplevel then
        self.avatar_:renderOtherVIP(data.viplevel)
    end
end

function ArenaUserInfoDetailPopup:onFriendClicked_(evt)
    if self.isAddFriend_ then
        self:onAddFriendClicked_(evt)
    else
        self:onDelFriendClicked_(evt)
    end
end

function ArenaUserInfoDetailPopup:setAddFriendStatus()
    self.addFriendBtn_:setButtonEnabled(true)
    if self.isFriend_ == 0 then
        self.addFriendBtn_:setButtonImage("normal", {"#pop_userinfo_other_green_normal.png", "#pop_userinfo_other_addFriends_add.png"})
        self.addFriendBtn_:setButtonImage("pressed", {"#pop_userinfo_other_green_pressed.png", "#pop_userinfo_other_addFriends_add.png"})
        self.isAddFriend_ = true
    else
        self.addFriendBtn_:setButtonImage("normal", {"#pop_userinfo_other_blue_normal.png", "#pop_userinfo_other_addFriends_cancel.png"})
        self.addFriendBtn_:setButtonImage("pressed", {"#pop_userinfo_other_blue_pressed.png", "#pop_userinfo_other_addFriends_cancel.png"})
        self.isAddFriend_ = false
    end
end

function ArenaUserInfoDetailPopup:onAddFriendClicked_(evt)
    self.addFriendBtn_:setButtonEnabled(false)
    bm.HttpService.POST({mod="friend", act="setPoker", fuid=self.uidt_, new = 1}, function(data)
        local retData = json.decode(data)
        if retData then
            if retData.ret == 1 or retData.ret == 2 then
                if retData.ret == 2 then
                    local noticed = nk.userDefault:getBoolForKey(nk.cookieKeys.FRIENDS_FULL_TIPS .. nk.userData.uid, false)
                    if not noticed then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "ADD_FULL_TIPS",nk.OnOff:getConfig("maxFriendNum") or "300"))
                        nk.userDefault:setBoolForKey(nk.cookieKeys.FRIENDS_FULL_TIPS .. nk.userData.uid, true)
                    end
                end
                self.isFriend_ = 1
                self:setAddFriendStatus()
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
                self:setAddFriendStatus()
            end
        end
    end, function()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
        self:setAddFriendStatus()
    end)
    
end

function ArenaUserInfoDetailPopup:onDelFriendClicked_(evt)
    self.addFriendBtn_:setButtonEnabled(false)
    bm.HttpService.POST({mod="friend", act="delPoker", fuid=self.uidt_}, function(data)
        if data == "1" then
            self.isFriend_ = 0
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DEL_FRIEND_FAILED_MSG"))
        end
        
        self:setAddFriendStatus()
    end, function()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DEL_FRIEND_FAILED_MSG"))
        self:setAddFriendStatus()
    end)
end

function ArenaUserInfoDetailPopup:onExit()
    nk.ImageLoader:cancelJobByLoaderId(self.headImageLoaderId_)
end

return ArenaUserInfoDetailPopup