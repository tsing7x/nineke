--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-04-13 12:20:45

local AvatarIcon          = import("boomegg.ui.AvatarIcon")
local OtherUserInfoPanel = class("OtherUserInfoPanel", nk.ui.Panel)
OtherUserInfoPanel.WIDTH = 520
OtherUserInfoPanel.HEIGHT = 210

function OtherUserInfoPanel:ctor(ctrl)
    self.ctrl_ = ctrl
	self:setNodeEventEnabled(true)
    OtherUserInfoPanel.super.ctor(self, {OtherUserInfoPanel.WIDTH, OtherUserInfoPanel.HEIGHT})

    local LEFT = -OtherUserInfoPanel.WIDTH * 0.5
	local TOP = OtherUserInfoPanel.HEIGHT * 0.5
	local RIGHT = OtherUserInfoPanel.WIDTH * 0.5
	local BOTTOM = -OtherUserInfoPanel.HEIGHT * 0.5
    -- 头像
    local avatar_x = LEFT + 90
    self.avatar_ = AvatarIcon.new("#common_male_avatar.png", 82, 82, 8, {resId="#transparent.png", size=cc.size(100,100)}, 1, 14, 0)
        :pos(avatar_x, TOP - 72)
        :addTo(self)

    --加好友按钮
    self.isAddFriend_ = true
    self.addFriendBtn_ = cc.ui.UIPushButton.new({
                normal="#common_btn_green_normal.png",
                pressed="#common_btn_green_pressed.png",
                disabled="#common_btn_disabled.png",
            }, {scale9=true})
        :setButtonSize(122, 47)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("ROOM", "ADD_FRIEND"), size=20, color=cc.c3b(0xFF, 0xFF, 0xFF)}))
        :onButtonClicked(buttontHandler(self, self.onFriendClicked_))
        :setButtonEnabled(false)
        :pos(avatar_x, TOP - 150)
        :addTo(self)
        :hide()

    --性别图标背景
    local offy = 7
    local sex_x, sex_y = LEFT + 178, TOP - 50 - offy
    self.sexIcon_ = display.newSprite("#pop_userinfo_sex_female.png"):pos(sex_x, sex_y):addTo(self)
    --昵称
    self.nick_ = ui.newTTFLabel({size=24, text="", color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, LEFT + 210, sex_y)
        :addTo(self)
    --UID
    self.uid_ = ui.newTTFLabel({size = 20, text="", color = cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, LEFT + 360, sex_y)
        :addTo(self)
    --筹码
    local chip_y = TOP - 92 - offy
    self.chipIcon_ = display.newSprite("#chip_icon.png", LEFT + 174, chip_y):addTo(self)
    self.chip_ = ui.newTTFLabel({size=24, text="", color=cc.c3b(0xff, 0xd5, 0x31)})
        :align(display.LEFT_CENTER, LEFT + 196, chip_y)
        :addTo(self)
    --等级
    self.levelIcon_ = display.newSprite("#level_icon.png")
        :align(display.LEFT_CENTER, LEFT + 360, chip_y)
        :addTo(self)
    self.level_ = ui.newTTFLabel({size=24, text="", color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, LEFT + 400, chip_y)
        :addTo(self)
    --排名
    local rank_x = LEFT + 160
    self.ranking_ = ui.newTTFLabel({text = bm.LangUtil.getText("ROOM", "INFO_RANKING", ".."),size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, rank_x, TOP - 128 - offy)
        :addTo(self)
    --胜率
    self.winRate_ = ui.newTTFLabel({size=24, text="", color=cc.c3b(0xce, 0xe8, 0xff)})
        :align(display.LEFT_CENTER, rank_x, TOP - 164 - offy)
        :addTo(self)

    self:addCloseBtn()
    self:setCloseBtnOffset(12, 5)
end

function OtherUserInfoPanel:show(uid, params)
	self:setLoading(true)
	self.puid_ = uid or "*"
	self.params_ = params
	nk.PopupManager:addPopup(self);
    if uid==nk.userData.uid then
        self.isSelf_ = true
        self.avatar_:renderVIP()
    end
	return self;
end

function OtherUserInfoPanel:onShowed()
	self.uid_:setString(bm.LangUtil.getText("ROOM", "INFO_UID", self.puid_) or "")
	self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", "-") or "")
	self:renderParams_()
	

	if tostring(nk.userData.uid) ~= tostring(self.puid_) then
		self.addFriendBtn_:show()
        self:loadOtherUserInfo_()
	else
		self.addFriendBtn_:hide()

        self.otherData_ = {}
        self.otherData_.level = nk.userData.level
        self.otherData_.money = nk.userData.money
        self.otherData_.nick = nk.userData.nick
        self.otherData_.sex = nk.userData.sex
        self.otherData_.img = nk.userData.s_picture
        self.otherData_.rankMoney = nk.userData.bank_money
        self.otherData_.win = nk.userData.win or 0
        self.otherData_.lose = nk.userData.lose or 0
        self:render_()
	end	
end

function OtherUserInfoPanel:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function OtherUserInfoPanel:loadOtherUserInfo_()
    self.ctrl_:getOtherUserDetail(self.puid_, handler(self, self.callbackLoadOtherUserInfo))
end

function OtherUserInfoPanel:callbackLoadOtherUserInfo(callData)
    if callData then
        self.otherData_ = callData
        self.otherData_.win = self.otherData_.win or 0
        self.otherData_.lose = self.otherData_.lose or 0
        self:render_()
        self.isFriend_ = self.otherData_.fri
        self:setAddFriendStatus()
    end
end

function OtherUserInfoPanel:render_()
    if not self.isSelf_ then
        --别人
    end
	self:setLoading(false)

	self.nick_:setString(self.otherData_.nick or "*")
    bm.fitSprteWidth(self.nick_, 145)

    self.chip_:setString(bm.formatBigNumber(self.otherData_.money or 0))
    self.level_:setString(bm.LangUtil.getText("ROOM", "INFO_LEVEL", self.otherData_.level or 1))
    self.winRate_:setString(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", self.otherData_.win + self.otherData_.lose > 0 and math.round(self.otherData_.win * 100 / (self.otherData_.win + self.otherData_.lose)) or 0))
    self:renderSex_(self.otherData_.sex or "f")
    self:renderPic_(self.otherData_.img)

    if self.otherData_.rankMoney then
        if self.otherData_.rankMoney > 10000 then
            self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ">10,000") or "")
        else
            self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", bm.formatNumberWithSplit(self.otherData_.rankMoney)) or "")
        end
    end
end

function OtherUserInfoPanel:renderParams_()
	if self.params_ then
		self.nick_:setString(self.params_.nick or "*")
        bm.fitSprteWidth(self.nick_, 145)

	    self:renderSex_(self.params_.sex or "f")
	    self:renderPic_(self.params_.img)
        if self.params_.uid ~= nk.userData.uid then
            local vipconfig =  self.params_.vipinfo or {}
            local isVip = self:checkIsVip_(vipconfig,self.params_.viplevel or 0)
            if isVip > 0 then     
                self.avatar_:renderOtherVIP(tonumber(isVip))
            end
        end
	end
end

--yk
function OtherUserInfoPanel:checkIsVip_(vipconfig,viplevel)
    if viplevel > 0 then
        return viplevel
    end

    if vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light and vipconfig.vip.light == 1 then
        return tonumber(vipconfig.vip.level)
    end

    return 0
end

-- 加载性别
function OtherUserInfoPanel:renderSex_(sex)
    if sex == "f" then
        self.sexIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_female.png"))
        self.avatar_:setSpriteFrame("common_female_avatar.png")
    else
        self.sexIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_male.png"))
        self.avatar_:setSpriteFrame("common_male_avatar.png")
    end
end

-- 加载头像
function OtherUserInfoPanel:renderPic_(img)
	if string.len(tostring(img)) > 5 then
        local imgurl = img
        if string.find(imgurl, "facebook") then
            if string.find(imgurl, "?") then
                imgurl = imgurl .. "&width=200&height=200"
            else
                imgurl = imgurl .. "?width=200&height=200"
            end
        end
        self.avatar_:loadImage(imgurl);
    end
end

function OtherUserInfoPanel:setAddFriendStatus()
    self.addFriendBtn_:setButtonEnabled(true)
    if self.isFriend_ == 0 then
        self.addFriendBtn_:setButtonImage("normal", "#common_btn_green_normal.png", true)
        self.addFriendBtn_:setButtonImage("pressed", "#common_btn_green_pressed.png", true)
        self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
        self.isAddFriend_ = true
    else
        self.addFriendBtn_:setButtonImage("normal", "#common_btn_blue_normal.png", true)
        self.addFriendBtn_:setButtonImage("pressed", "#common_btn_blue_pressed.png", true)
        self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
        self.isAddFriend_ = false
    end
end

function OtherUserInfoPanel:onFriendClicked_(evt)
    if self.isAddFriend_ then
        self:onAddFriendClicked_(evt)
    else
        self:onDelFriendClicked_(evt)
    end
end

function OtherUserInfoPanel:onAddFriendClicked_(evt)
    self.addFriendBtn_:setButtonEnabled(false)
    self.ctrl_:setFriendPoker(self.puid_, function(data)

        local retData = json.decode(data)
        if retData then
            if retData.ret == 1 or retData.ret == 2 then
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
            self:setAddFriendStatus()
        end
    end)
end

function OtherUserInfoPanel:onDelFriendClicked_(evt)
    self.addFriendBtn_:setButtonEnabled(false)
    self.ctrl_:delFriendPoker(self.puid_, function(data)
        if nil == data then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DEL_FRIEND_FAILED_MSG"))
        elseif data == "1" then
            self.isFriend_ = 0
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DEL_FRIEND_FAILED_MSG"))
        end

        self:setAddFriendStatus()
    end)
end

function OtherUserInfoPanel:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

return OtherUserInfoPanel