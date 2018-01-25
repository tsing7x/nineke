--
-- Author: KevinYu
-- Date: 2016-04-01 10:59:36
--
local SearchUserInfo = class("SearchUserInfo", function ()
    return display.newNode()
end)

local AvatarIcon            = import("boomegg.ui.AvatarIcon")

local PLAYER_INFO_W, PLAYER_INFO_H = 755, 290

-- data = {
--     img         = "https://graph.facebook.com/221116858239857/picture", --头像
--     level       = 5, --等级
--     money       = 0, --筹码
--     nick        = "สะ'ฟิล์ม ยิ้ม'มหวาน'น", --名称
--     sex         = "m", --性别
--     suid         = 11064244, --ID
--     win         = 96, --赢牌局数
--     lose        = 412, --输牌局数
--     rankMoney   = 100001, --筹码排名
--     isFriend    = 0 --是否为好友关系
-- }
function SearchUserInfo:ctor(data, controller)
	self:setNodeEventEnabled(true)

	self.data_ = data
	self.controller_ = controller

	self:addUI(data)
	
    self:setAddFriendStatus_()  
end

function SearchUserInfo:addUI(data)
	local frame = display.newScale9Sprite("#pop_friend_content_bg.png", 0, 0, cc.size(PLAYER_INFO_W, PLAYER_INFO_H))
        :addTo(self)

    -- 头像
    local avatar_x, avatar_y = 100, PLAYER_INFO_H - 110
    local avatar_w, avatar_h = 150, 150
    self.avatar_ = AvatarIcon.new(
        "#common_male_avatar.png",
        avatar_w, avatar_h, 8,
        {resId="#transparent.png", size=cc.size(avatar_w + 15, avatar_h + 15)}, 1, 14, 0)
        :pos(avatar_x, avatar_y)
        :addTo(frame)

    --头像ID
    if string.len(data.img) > 5 then
        self.headImageLoaderId_ = nk.ImageLoader:nextLoaderId()
        local imgurl = data.img
        if string.find(imgurl, "facebook") then
            if string.find(imgurl, "?") then
                imgurl = imgurl .. "&width=150&height=150"
            else
                imgurl = imgurl .. "?width=150&height=150"
            end
        end
        self.avatar_:loadImage(imgurl)
    end

    local btnStr
    self.isAddFriend_ = true
    self.isFriend_ = data.isFriend or 0
    self.addFriendBtn_ = cc.ui.UIPushButton.new({normal="#common_btn_green_normal.png", pressed="#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9=true})
        :setButtonSize(150, 58)
        :setButtonLabel(ui.newTTFLabel({text = btnStr, size = 24, color = cc.c3b(0xFF, 0xFF, 0xFF)}))
        :onButtonClicked(buttontHandler(self, self.addOrDelFriendClicked_))
        :pos(avatar_x, avatar_y - 120)
        :addTo(frame)

    
    --性别图标背景
    local dir = 60
    local sex_x, sex_y = 250, PLAYER_INFO_H - dir
    if data.sex == "f" then
        display.newSprite("#pop_userinfo_sex_female.png"):pos(sex_x, sex_y):addTo(frame)
    else
        display.newSprite("#pop_userinfo_sex_male.png"):pos(sex_x, sex_y):addTo(frame)
    end

    --昵称
    ui.newTTFLabel({text = nk.Native:getFixedWidthText("", 24, data.nick, 200), size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, sex_x + 30, sex_y)
        :addTo(frame)

    --UID
    ui.newTTFLabel({text = bm.LangUtil.getText("ROOM", "INFO_UID", data.suid), size = 20, color = cc.c3b(0xc5, 0xdc, 0xf4)})
        :align(display.LEFT_CENTER, sex_x + 220, sex_y)
        :addTo(frame)

    --筹码
    local chip_x, chip_y = 250, PLAYER_INFO_H - dir * 2
    display.newSprite("#chip_icon.png", chip_x, chip_y):addTo(frame)

    ui.newTTFLabel({text = bm.formatBigNumber(data.money), size=24, color=cc.c3b(0xff, 0xd5, 0x31)})
        :align(display.LEFT_CENTER, chip_x + 30, chip_y)
        :addTo(frame)

    --等级
    display.newSprite("#level_icon.png")
        :align(display.LEFT_CENTER, chip_x + 220, chip_y)
        :addTo(frame)

    ui.newTTFLabel({text = bm.LangUtil.getText("ROOM", "INFO_LEVEL", data.level), size=24, color=cc.c3b(0xc5, 0xdc, 0xf4)})
        :align(display.LEFT_CENTER, chip_x + 250, chip_y)
        :addTo(frame)

    --排名
    local rank_x, rank_y = 240, PLAYER_INFO_H - dir * 3
    local rankStr = bm.LangUtil.getText("ROOM", "INFO_RANKING", "..")
    if data.rankMoney then
        if data.rankMoney > 10000 then
            rankStr = bm.LangUtil.getText("ROOM", "INFO_RANKING", ">10,000")
        else
            rankStr = bm.LangUtil.getText("ROOM", "INFO_RANKING", bm.formatNumberWithSplit(data.rankMoney))
        end
    else
        rankStr = bm.LangUtil.getText("ROOM", "INFO_RANKING", "-")
    end

    local winColor = cc.c3b(0x81, 0x8a, 0xc0)
    self.ranking_ = ui.newTTFLabel({text = rankStr, size = 24, color = winColor})
        :align(display.LEFT_CENTER, rank_x, rank_y)
        :addTo(frame)

    --胜率
    local winStr = bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", data.win + data.lose > 0 and math.round(data.win * 100 / (data.win + data.lose)) or 0)
    ui.newTTFLabel({text = winStr, size = 24, color = winColor})
        :align(display.LEFT_CENTER, rank_x + 230, rank_y)
        :addTo(frame)
end

function SearchUserInfo:addOrDelFriendClicked_()
    if self.isFriend_ == 1 then
        self:onDelFriendClicked_()
    else
        self:onAddFriendClicked_()
    end
end

function SearchUserInfo:onAddFriendClicked_()
    self.addFriendBtn_:setButtonEnabled(false)
    bm.HttpService.POST({mod="friend", act="setPoker", fuid=self.data_.suid, new = 1}, function(data)
        local retData = json.decode(data)
        if retData then
            if retData.ret == 1 or retData.ret == 2 then
                self.controller_:clearAllFriendData()
                self.isFriend_ = 1
                if retData.ret == 2 then
                    local noticed = nk.userDefault:getBoolForKey(nk.cookieKeys.FRIENDS_FULL_TIPS .. nk.userData.uid, false)
                    if not noticed then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "ADD_FULL_TIPS",nk.OnOff:getConfig("maxFriendNum") or "300"))
                        nk.userDefault:setBoolForKey(nk.cookieKeys.FRIENDS_FULL_TIPS .. nk.userData.uid, true)
                    end
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
            end
        end
        self:setAddFriendStatus_()
    end, function()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
        self:setAddFriendStatus_()
    end)
end

function SearchUserInfo:onDelFriendClicked_()
    self.addFriendBtn_:setButtonEnabled(false)
    bm.HttpService.POST({mod="friend", act="delPoker", fuid=self.data_.suid}, function(data)
        if data == "1" then
            self.controller_:clearAllFriendData()
            self.isFriend_ = 0
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DEL_FRIEND_FAILED_MSG"))
        end
        self:setAddFriendStatus_()
    end, function()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DEL_FRIEND_FAILED_MSG"))
        self:setAddFriendStatus_()
    end)
end

function SearchUserInfo:setAddFriendStatus_()
    self.addFriendBtn_:setButtonEnabled(true)
    if self.isFriend_ == 0 then
        self.addFriendBtn_:setButtonImage("normal", "#common_btn_green_normal.png", true)
        self.addFriendBtn_:setButtonImage("pressed", "#common_btn_green_pressed.png", true)
        self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
    else
        self.addFriendBtn_:setButtonImage("normal", "#common_btn_blue_normal.png", true)
        self.addFriendBtn_:setButtonImage("pressed", "#common_btn_blue_pressed.png", true)
        self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
    end
end

function SearchUserInfo:onExit()
    nk.ImageLoader:cancelJobByLoaderId(self.headImageLoaderId_)
end

return SearchUserInfo