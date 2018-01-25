--
-- Author: Jonah0608@gmail.com
-- Date: 2015-09-23 15:56:04
--


local ScoreHelpPopup = class("ScoreHelpPopup",function()
    return display.newNode()
end)

function ScoreHelpPopup:ctor(posX,posY,tips,hasbutton)
    display.newScale9Sprite("#score_tips_bg.png", 0, 0, cc.size(304, 283),cc.rect(27, 46, 2, 2)):addTo(self)
    ui.newTTFLabel({text = tips, dimensions = cc.size(274,253),color = styles.FONT_COLOR.LIGHT_TEXT, size = 18, align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_ALIGN_TOP})
        :pos(10, 20)
        :addTo(self)
    if hasbutton then
        display.newScale9Sprite("#score_tips_btn.png", 0, 0, cc.size(105, 33),cc.rect(8, 14, 2, 8))
            :pos(0,-100)
            :addTo(self)
        ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "SCORE_TIPS_BTN"), dimensions = cc.size(105,33),color = styles.FONT_COLOR.LIGHT_TEXT, size = 16, align = ui.TEXT_ALIGN_CENTER})
            :pos(0, -97)
            :addTo(self)
        cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
            :setButtonSize(105, 33)
            :pos(-3, -97)
            :addTo(self)
            :onButtonClicked(buttontHandler(self, self.goInvitePopup_))
    end
    self:pos(posX,posY)
end

function ScoreHelpPopup:show()
    nk.PopupManager:addPopup(self,true,false,true,false)
end

function ScoreHelpPopup:goInvitePopup_()
    local ScoreMarketView = import("app.module.scoremarket.ScoreMarketViewExt");
    ScoreMarketView.load(nil, nil)
    
    nk.PopupManager:removePopup(self)
end

return ScoreHelpPopup