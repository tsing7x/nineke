local GroupCheckListItem          = import(".GroupCheckListItem")
local GroupAwardPopup = class("GroupAwardPopup", function ()
    return display.newNode()
end)

local logger = bm.Logger.new("GroupAwardPopup")

function GroupAwardPopup:ctor(awardInfo,groupid)  -- socket推送构造，拉取PHP数据构造
    self:setNodeEventEnabled(true)
    self.this_ = self
    self.awardInfo_ = awardInfo
    self.group_id_ = groupid
    self.bgLeft_ = display.newScale9Sprite("group/group_award_bg.png",0,0,cc.size(300, 300))
        :addTo(self)
    self.bgRight_ = display.newScale9Sprite("group/group_award_bg.png",0,0,cc.size(300, 300))
        :addTo(self)
    self.bgLeft_:setAnchorPoint(cc.p(1, 0.5))
    self.bgRight_:setAnchorPoint(cc.p(1, 0.5))
    self.bgRight_:setScaleX(-1)

    display.newSprite("group/group_award_light.png")
        :addTo(self)
    self.icon_ = display.newSprite("group/group_award_icon.png")
        :addTo(self)

    if not awardInfo.red_money then
        awardInfo.red_money = awardInfo.money
    end

    ui.newTTFLabel({
            text = awardInfo.msg or nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CANDYINFO",awardInfo.nick,awardInfo.red_money)),
            size = 28,
            valign = ui.TEXT_VALIGN_BOTTOM
        })
        :pos(0, -140)
        :align(display.BOTTOM_CENTER)
        :addTo(self)

    bm.TouchHelper.new(self.icon_, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            bm.HttpService.CANCEL(self.getGroupAwardId_)
            self:setLoading(true)

            self.getGroupAwardId_ = bm.HttpService.POST(
                {
                    mod = "Group",
                    act = "grabRed",
                    uid = nk.userData.uid,
                    group_id = self.group_id_ or awardInfo.group_id,
                    red_id = awardInfo.id or awardInfo.red_id,
                },
                function (data)
                    if self.this_ then
                        local retData = json.decode(data)
                        if retData and retData.ret==1 and retData.data and retData.data.money then
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CANDYAWARD",retData.data.money))
                        else
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CANDYNULL"))
                        end
                        local tempGroupID = self.group_id_  -- 关闭被释放了
                        self:close()
                        if tempGroupID and GroupTangGuo then  -- 拉取PHP数据构造
                            if #GroupTangGuo>0 then
                                local GroupAwardPopup = require("app.module.friend.group.GroupAwardPopup")
                                GroupAwardPopup.new(table.remove(GroupTangGuo,1),tempGroupID):show()
                            end
                        end
                    end
                end,
                function ()
                    if self.this_ then
                        self:close()
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CANDYNULL"))
                    end
                end
            )
        end
    end)
end

function GroupAwardPopup:onCleanup()
    bm.HttpService.CANCEL(self.getGroupAwardId_)
end

function GroupAwardPopup:show()
    nk.PopupManager:addPopup(self, true, true, false, true)
end

function GroupAwardPopup:close()
    nk.PopupManager:removePopup(self)
end

function GroupAwardPopup:onShowed()
    
end

function GroupAwardPopup:setLoading(isLoading)
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

return GroupAwardPopup