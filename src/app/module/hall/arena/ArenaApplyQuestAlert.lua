--
-- Author: XT
-- Date: 2015-08-18 21:05:07
--
local POPUP_WIDTH = 680
local POPUP_HEIGHT = 205
local ITEM_HEIGHT = 150
local POPUP_TOP = 40
local POPUP_BOTTOM = 40
local RECT_HEIGHT = 0
local StorePopup = require('app.module.newstore.StorePopup')
local ScrollLabel = import("boomegg.ui.ScrollLabel")
local ArenaApplyQuestAlertItem = import("app.module.hall.arena.ArenaApplyQuestAlertItem")
local ArenaApplyQuestAlert = class("ArenaApplyQuestAlert", nk.ui.Panel)

function ArenaApplyQuestAlert:ctor(msg1, msg2, matchData, callBack)
    self:setNodeEventEnabled(true)
    self.matchData_ = matchData
    -- 次数限制场
    -- 测试
    -- matchData.playTimes = 100
    -- matchData.leftTimes = 0
    -- matchData.name = " asdfasdf asdf;jasdf;kl asdfasdf; asdfasdf asdfasdf;lkj asdfasdf;lkj  asdfa;sdfj;askdf asdfasdfasdfa asdfasdfa ;j;k asdfasf ;lkj;jk asdfasdf ;lkj;jk asdfasdf ;lkj;lk j"
    -- matchData.exchange = {
    --     limit = 10,
    --     chips = 100,
    --     enum = 100
    -- }
    -- matchData.ticketInfo = {
    --     name = "==ceshi de==",
    --     getWay = "==nimeinimei==",
    --     show = 1,
    --     type = 9,
    --     sb = 1000,
    -- }
    self.showList = {}      -- 显示List
    local t = nil  -- 项目
    -- E2P专场 
    local isSpecial = false
    if matchData and matchData.ticketOnly==1 then
        msg1 = matchData.ticketInfo.name
        msg2 = matchData.ticketInfo.getWay
        isSpecial = true

        t = {
            [1] = bm.LangUtil.getText("MATCH", "ALERTTIPS1",msg1).."\n\n"..bm.LangUtil.getText("MATCH", "ALERTTIPS2",msg2),
            [2] = true,
            [3] = {
                [1] = bm.LangUtil.getText("COMMON", "BUY"), -- 文字
                [2] = "buyTicket", -- 动作 购买门票
            }
        }
        table.insert(self.showList,t)
    end
    if not isSpecial then
        if matchData and matchData.playTimes and matchData.playTimes>0 and
            matchData.leftTimes then -- 免费限制次数场次

            local ex = self.matchData_.exchange

            t = {
                [1] = bm.LangUtil.getText("MATCH", "NOTIMESTIPS_1",ex.limit,self.matchData_.name,bm.TimeUtil:getTimeString(self.matchData_.CDTime or 0)),
                [2] = false,
            }
            t.isCoolDown = true -- 是倒计时
            table.insert(self.showList,t)
            t = {
                [1] = bm.LangUtil.getText("MATCH", "NOTIMESTIPS_2",ex.chips,ex.enum),
                [2] = true,
                [3] = {
                    [1] = bm.LangUtil.getText("SCOREMARKET", "EXCHANGE"), -- 文字
                    [2] = "exchange", -- 动作 兑换次数
                },
            }
            table.insert(self.showList,t)
        else
            t = {
                [1] = bm.LangUtil.getText("MATCH", "ALERTTIPS1",msg1).."\n\n"..bm.LangUtil.getText("MATCH", "ALERTTIPS2",msg2),
                [2] = true,
                [3] = {
                    [1] = bm.LangUtil.getText("COMMON", "BUY"), -- 文字
                    [2] = "buyGameCoupon", -- 动作 购买比赛券
                },
            }
            table.insert(self.showList,t)
        end
        if matchData and matchData.ticketInfo and matchData.ticketInfo.name then
            local btnShow = false
            local curScene = display.getRunningScene()
            if matchData.ticketInfo.show==1 and curScene and curScene.name=="HallScene" then
                btnShow = true
            end
            t = {
                [1] = bm.LangUtil.getText("MATCH", "ALERTTIPS1",matchData.ticketInfo.name).."\n\n"..bm.LangUtil.getText("MATCH", "ALERTTIPS2",matchData.ticketInfo.getWay),
                [2] = btnShow,
                [3] = {
                    [1] = bm.LangUtil.getText("PLAYER_BACK", "GOTO"), -- 去获得门票
                    [2] = "gotoTicketRoom",-- 动作 去普通场赢取门票
                },
            }
            table.insert(self.showList,t)
        end
    end

    if #self.showList>1 then
        RECT_HEIGHT = ITEM_HEIGHT*2
    else
        RECT_HEIGHT = ITEM_HEIGHT
    end
    POPUP_HEIGHT = RECT_HEIGHT + POPUP_TOP + POPUP_BOTTOM

    ArenaApplyQuestAlert.super.ctor(self, {POPUP_WIDTH+30, POPUP_HEIGHT+30})
    self:addBgLight()

    -- list显示
    self.bound_ = cc.rect(-POPUP_WIDTH/2, -RECT_HEIGHT/2, POPUP_WIDTH, RECT_HEIGHT);
    self.listView_ = bm.ui.ListView.new({viewRect = self.bound_, direction = bm.ui.ListView.DIRECTION_VERTICAL}, ArenaApplyQuestAlertItem)
        :addTo(self)
    -- 回调
    local selfCallBack = function(itemData)
        self:hidePopupPanel()
        local curScene = display.getRunningScene()
        if itemData and itemData[3] then
            if itemData[3][2]=="gotoTicketRoom" then
                if curScene.controller_ and curScene.controller_.getEnterRoomData then
                    curScene.controller_:getEnterRoomData {
                        tt = matchData.ticketInfo.tt,
                        sb = matchData.ticketInfo.sb,
                        pc = matchData.ticketInfo.type
                    }
                end
                if callBack then
                    callBack("hide")
                    return
                end
            elseif itemData[3][2]=="exchange" then
                if callBack then
                    callBack()
                end
            else
                StorePopup.new(1):showPanel()
            end
        end
    end
    -- 动态赋值
    for k,v in pairs(self.showList) do
        v.matchData = matchData
        v.callBack = selfCallBack
    end
    if #self.showList>0 then
        -- 动态赋值
        self.showList[#self.showList].isEnd = true
        self.listView_:setData(self.showList)
    end

	-- 关闭按钮
    self:addCloseBtn()
    self:setCloseBtnOffset(10,5)
end

function ArenaApplyQuestAlert:onCleanup()
    self.matchData_ = nil
end

function ArenaApplyQuestAlert:hidePopupPanel()
    self:hide()
end

function ArenaApplyQuestAlert:onShowed()
    if self.listView_ and self.showList and #self.showList>0 then
        self.listView_:update()
    end
end

function ArenaApplyQuestAlert:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function ArenaApplyQuestAlert:showPopupPanel(parent)
    nk.PopupManager:addPopup(self)
    return self
end

return ArenaApplyQuestAlert;

