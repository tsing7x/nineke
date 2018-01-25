--
-- Author: tony
-- Date: 2014-08-19 15:24:19
--
local ChatMsgToListItem = class("ChatMsgToListItem", bm.ui.ListItem)
local AvatarIcon = import("boomegg.ui.AvatarIcon")
--need to be set before creating instances
ChatMsgToListItem.WIDTH = 0
ChatMsgToListItem.HEIGHT = 0
ChatMsgToListItem.ON_ITEM_CLICKED_LISTENER = nil

function ChatMsgToListItem:ctor()
    self:setNodeEventEnabled(true)
    ChatMsgToListItem.super.ctor(self, ChatMsgToListItem.WIDTH, ChatMsgToListItem.HEIGHT)
    self.btn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png" , pressed = "#rounded_rect_10.png"}, {scale9=true})
            :setButtonSize(ChatMsgToListItem.WIDTH, ChatMsgToListItem.HEIGHT)
            :onButtonPressed(function(evt) 
                    self.btnPressedY_ = evt.y
                    self.btnClickCanceled_ = false
                end)
            :onButtonRelease(function(evt)
                    if math.abs(evt.y - self.btnPressedY_) > 5 then
                        self.btnClickCanceled_ = true
                    end
                end)
            :onButtonClicked(function(evt)
                    if not self.btnClickCanceled_ and ChatMsgToListItem.ON_ITEM_CLICKED_LISTENER and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                        ChatMsgToListItem.ON_ITEM_CLICKED_LISTENER(self.data_)
                    end
                end)
    self.btn_:setTouchSwallowEnabled(false)
    self.btn_:pos(ChatMsgToListItem.WIDTH * 0.5, ChatMsgToListItem.HEIGHT * 0.5)
    self.btn_:addTo(self)

    self.userAvatar_ = AvatarIcon.new("#common_male_avatar.png", 96, 96, 6, nil, 1, 8, 0)
        :pos(ChatMsgToListItem.WIDTH*0.5-96, ChatMsgToListItem.HEIGHT*0.5)
        :addTo(self)

    self.userNameTxt_ = ui.newTTFLabel({
            text="",
            color=cc.c3b(0x92, 0x97, 0xb5),
            size=20,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.CENTER_LEFT)
        :pos(ChatMsgToListItem.WIDTH*0.5-20, ChatMsgToListItem.HEIGHT*0.5)
        :addTo(self)

    display.newScale9Sprite("#room_pop_chat_divide.png", ChatMsgToListItem.WIDTH * 0.5+3, 0, cc.size(ChatMsgToListItem.WIDTH, 2)):addTo(self)
end

function ChatMsgToListItem:onDataSet(dataChanged, data)
    if dataChanged then
        local imgurl = data.img
        if not imgurl or string.len(imgurl) <= 5 then
            if data.gender == "f" then
                self.userAvatar_:setSpriteFrame("common_female_avatar.png")
            else
                self.userAvatar_:setSpriteFrame("common_male_avatar.png")
            end
        else
            self.userAvatar_:loadImage(imgurl)
        end
        
        self:renderOtherVIP(json.decode(data.userInfo))
        self.userNameTxt_:setString(data.nick)
    end
end

--yk
function ChatMsgToListItem:renderOtherVIP(userinfo)
    local vipconfig = {}
    if userinfo and userinfo.vipmsg then
        vipconfig = userinfo.vipmsg
    end

    if vipconfig.newvip == 1 then
        local viplevel = vipconfig.vip.level
        self.userAvatar_:renderOtherVIP(tonumber(viplevel))

        return
    end

    if vipconfig.isvip == 1 and vipconfig.vip then
        local viplevel = vipconfig.vip.level
        if viplevel and vipconfig.vip.light == 1 then
            self.userAvatar_:renderOtherVIP(tonumber(viplevel))
        end
    end
end

function ChatMsgToListItem:loadHead(url)
    local imgurl = nk.userData.s_picture
    if not imgurl or string.len(imgurl) <= 5 then
        if nk.userData.sex == "f" then
            self.userAvatar_:setSpriteFrame("common_female_avatar.png")
        else
            self.userAvatar_:setSpriteFrame("common_male_avatar.png")
        end
    else
        self.userAvatar_:loadImage(imgurl)
    end
end

function ChatMsgToListItem:onCleanup()
    self.userAvatar_:onCleanup()
end
return ChatMsgToListItem