--
-- Author: XT
-- Date: 2015-07-30 09:28:52
-- 比赛场 规则说明列表的Item
local ArenaApplyQuestAlertItem = class("ArenaApplyQuestAlertItem", bm.ui.ListItem);
ArenaApplyQuestAlertItem.WIDTH = 680;
ArenaApplyQuestAlertItem.HEIGHT = 150;
local LIST_WIDTH = 370;
local LIST_HEIGHT = 200;
function ArenaApplyQuestAlertItem:ctor()
    self:setNodeEventEnabled(true)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    ArenaApplyQuestAlertItem.super.ctor(self, ArenaApplyQuestAlertItem.WIDTH, ArenaApplyQuestAlertItem.HEIGHT)
    self.node_ = display.newNode()
        :pos(ArenaApplyQuestAlertItem.WIDTH/2,ArenaApplyQuestAlertItem.HEIGHT/2)
        :addTo(self)
    self.label_ = ui.newTTFLabel({
                text  = "",
                color = cc.c3b(0x89, 0xa2, 0xc6),
                size  = fontSzs,
                align = ui.TEXT_ALIGN_LEFT,
                valign = ui.TEXT_VALIGN_TOP,
                dimensions=cc.size(LIST_WIDTH+120, LIST_HEIGHT)
            })
            :pos(-85,0)
    self.label_:setDimensions(LIST_WIDTH+120,0)
    self.label_:addTo(self.node_)
    self.btn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
                :setButtonSize(160, 60)
                :pos(225+20, 0)
                :addTo(self.node_)
                :onButtonClicked(function()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                    if self.data_ and self.data_.callBack then
                        self.data_.callBack(self.data_)
                    end
                end)
                :setButtonLabel("normal", ui.newTTFLabel({
                    text = "",
                    size = 26,
                    color = cc.c3b(0xd6, 0xff, 0xef),
                    align = ui.TEXT_ALIGN_CENTER
                }))
    -- self.line_ = display.newSprite("#user-info-desc-division-line.png")
        -- :pos(155,ArenaApplyQuestAlertItem.HEIGHT/2)
        -- :addTo(self.node_)
    self.line1_ = display.newSprite("#user-info-desc-division-line.png")
        :pos(0,-ArenaApplyQuestAlertItem.HEIGHT/2)
        :addTo(self.node_)
    local size = self.line1_:getContentSize()
    local scale = ArenaApplyQuestAlertItem.WIDTH/size.width
    -- self.line_:setScaleX(scale)
    self.line1_:setScaleX(scale)
end

function ArenaApplyQuestAlertItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.label_:setString(data[1])
        if data[2] then
            self.btn_:show()
            self.btn_:getButtonLabel("normal"):setString(data[3][1])
        else
            self.btn_:hide()
        end
        if data.isEnd then
            self.line1_:hide()
        end
        self:removeCoolDown()
        if data.isCoolDown then
            self:addCoolDown()
        end
    end
end
function ArenaApplyQuestAlertItem:onMatchCoolDown(evt)
    if self.data_ and self.data_.matchData then
        local matchData = self.data_.matchData
        local ex = matchData.exchange
        self.label_:setString(bm.LangUtil.getText("MATCH", "NOTIMESTIPS_1",ex.limit,matchData.name,bm.TimeUtil:getTimeString(matchData.CDTime)))
        if matchData.leftTimes>0 then
            if self.data_ and self.data_.callBack then
                self.data_.callBack()
            end
        end
    end
end
function ArenaApplyQuestAlertItem:addCoolDown()
    if not self.matchCoolDownId_ then
        self.matchCoolDownId_ = bm.EventCenter:addEventListener("Match_Cool_Down_Change", handler(self,self.onMatchCoolDown))
    end
end
function ArenaApplyQuestAlertItem:removeCoolDown()
    if self.matchCoolDownId_ then
        bm.EventCenter:removeEventListener(self.matchCoolDownId_)
        self.matchCoolDownId_ = nil
    end
end

function ArenaApplyQuestAlertItem:onCleanup()
    self:removeCoolDown()
end

return ArenaApplyQuestAlertItem;