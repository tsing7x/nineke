--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-13 16:13:55
--

local QuestionPopup = class("QuestionPopup", nk.ui.Panel)

local POPUP_WIDTH = 715
local POPUP_HEIGHT = 480

function QuestionPopup:ctor(ctx,defaultTab)
    QuestionPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})
    self.ctx = ctx
    self:createNodes_()
    self:addCloseBtn()
end

function QuestionPopup:createNodes_()
    self.title_ = ui.newTTFLabel({
        size = 35,
        text = bm.LangUtil.getText("DICE","HELP_TITLE"),
        color = cc.c3b(255, 255, 255),
    })
    :pos(0,480 / 2 - 40)
    :addTo(self)
    display.newScale9Sprite("#panel_overlay.png", 
           0, 0, cc.size(POPUP_WIDTH - 30, POPUP_HEIGHT - 80)):addTo(self):pos(0,-27)

    self.qaNode_ = display.newNode():addTo(self)
    self.qasprite_ = display.newSprite("#dice_qa_text.png")
        :pos(-10,0)
        :addTo(self.qaNode_)

end

function QuestionPopup:show()
    self:showPanel_()
end

function QuestionPopup:hide()
    self:hidePanel_()
end

return QuestionPopup