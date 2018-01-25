
local DeleteFriendPopUp = import("app.module.friend.DeleteFriendPopUp")
local AddFriendPopup = class("AddFriendPopup", DeleteFriendPopUp)

function AddFriendPopup:ctor(data)
    AddFriendPopup.super.ctor(self)
    self.data = data
    self.addFriendBtn_ = self.delFriendBtn_
    self:setAddFriendStatus()
end

function AddFriendPopup:delFriendClicked_()
    if self.isAddFriend_ then
        self:onAddFriendClicked_()
    else
        self:onDelFriendClicked_()
    end
end

function AddFriendPopup:onAddFriendClicked_()
    bm.HttpService.POST({mod="friend", act="setPoker", fuid=self.data.uid, new = 1}, function(data)
        local retData = json.decode(data)
        if retData then
            if retData.ret == 1 or retData.ret == 2 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_SUCC_MSG"))
                self.data.isFriend = 1
                if retData.ret == 2 then
                    local noticed = nk.userDefault:getBoolForKey(nk.cookieKeys.FRIENDS_FULL_TIPS .. nk.userData.uid, false)
                    if not noticed then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "ADD_FULL_TIPS",nk.OnOff:getConfig("maxFriendNum") or "300"))
                        nk.userDefault:setBoolForKey(nk.cookieKeys.FRIENDS_FULL_TIPS .. nk.userData.uid, true)
                    end
                end
                self:hide()
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

function AddFriendPopup:onDelFriendClicked_()
    bm.HttpService.POST({mod="friend", act="delPoker", fuid=self.data.uid}, function(data)
        if data == "1" then
            self.data.isFriend = 0
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DELE_FRIEND_SUCCESS_MSG"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DEL_FRIEND_FAILED_MSG"))
        end
        
        self:setAddFriendStatus()
    end, function()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DEL_FRIEND_FAILED_MSG"))
        self:setAddFriendStatus()
    end)
end

function AddFriendPopup:setAddFriendStatus()
    self.addFriendBtn_:setButtonEnabled(true)
    if self.data.isFriend == 0 then
        self.addFriendBtn_:setButtonImage("normal", "#common_btn_green_normal.png")
        self.addFriendBtn_:setButtonImage("pressed", "#common_btn_green_pressed.png")
        self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
        self.isAddFriend_ = true
    else
        self.addFriendBtn_:setButtonImage("normal", "#common_btn_blue_normal.png")
        self.addFriendBtn_:setButtonImage("pressed", "#common_btn_blue_pressed.png")
        self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
        self.isAddFriend_ = false
    end
end

return AddFriendPopup