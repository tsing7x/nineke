--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-30 11:53:00
--

local DiceResultPopup = class("DiceResultPopup",function()
    return display.newNode()
end)

function DiceResultPopup:ctor(money,wintype)
    self:setNodeEventEnabled(true)
    self.changedmoney_ = money or 0
    local animType = "fla_touziwin"
    if self.changedmoney_ >= 0 then
        animType = "fla_touziwin"
    else
        animType = "fla_touziFAIL"
    end
    self:setupView(animType)
    if money > 0 then
        if wintype == 1 then
            nk.SoundManager:playSound(nk.SoundManager.WINNER1)
        elseif wintype == 2 then
            nk.SoundManager:playSound(nk.SoundManager.WINNER2)
        elseif wintype == 3 then
            nk.SoundManager:playSound(nk.SoundManager.WINNER3)
        end
    end
end

function DiceResultPopup:setupView(animType)
    self.bgNode_ = display.newNode():addTo(self):pos(0,-35)
    
    local btn = cc.ui.UIPushButton.new({normal = "#dice_result_btn_close.png", pressed = "#dice_result_btn_close_pressed.png"})
            :onButtonClicked(buttontHandler(self, self.onCloseBtnListener_))
    local infoNode = display.newNode()
    self.avatar_ = nk.ui.CircleIcon.new():addTo(infoNode):pos(0,20)
    self.avatar_:setSexAndImgUrl(nk.userData.sex,nk.userData.s_picture)
    self.nick_ = ui.newTTFLabel({text = nk.Native:getFixedWidthText("", 18, nk.userData.nick, 110), color = cc.c3b(0xff, 0xff, 0xff), size = 28, align = ui.TEXT_ALIGN_CENTER})
        :addTo(infoNode)
        :pos(0,-45)
    local moneyStr = ""
    local moneyColor = cc.c3b(0xff, 0xff, 0x0)
    if self.changedmoney_ >= 0 then
        moneyStr = "+" .. tostring(self.changedmoney_)
    else
        moneyStr = tostring(self.changedmoney_)
        moneyColor = cc.c3b(169,169,169)
    end
    self.money_ = ui.newTTFLabel({text = moneyStr, color = moneyColor, size = 28, align = ui.TEXT_ALIGN_CENTER})
        :addTo(infoNode)
        :pos(0,-85)
        
    local armatures = {}
    if animType == "fla_touziwin" then
        armatures = {"fla_touziwinC_ADDITIVE","fla_touziwinGQ_ADDITIVE","fla_touziwinB","fla_touziwin_piaodai","fla_touziwinA_ADDITIVE"}
    elseif animType == "fla_touziFAIL" then
        armatures = {"fla_touziFAILC_ADDITIVE","fla_touziFAIL_GQ","fla_touziFAILB","fla_touziFAIL_YEZI","fla_touziFAILA_ADDITIVE"}
    end
    self:playResultAnim(animType,armatures,infoNode,btn)
end


function DiceResultPopup:playResultAnim(animType,armatures,infoNode,btnNode)
    local path = "dragonbones/" .. animType .. "/"
    self.dbs = {}
    for i = 1, #armatures do
        self.dbs[i] = dragonbones.new({
                skeleton=path .. "skeleton.xml",
                texture=path .. "texture.xml",
                armatureName=armatures[i],
                aniName="",
                skeletonName=animType,
            })
            :addTo(self.bgNode_, i)
    end
    if animType == "fla_touziwin" then
        self.dbs[3]:getArmature():getCCSlot("touziwin_TH"):getCCDisplay():addChild(infoNode)
        self.dbs[3]:getArmature():getCCSlot("touziwin_GB"):getCCDisplay():addChild(btnNode)

        -- self.dbs[3]:getArmature():getBone("touziwin_TH"):setDisplay(dragonBones.CCDBNode:new(infoNode))
        -- self.dbs[3]:getArmature():getBone("touziwin_GB"):setDisplay(dragonBones.CCDBNode:new(btnNode))
    elseif animType == "fla_touziFAIL" then
        -- self.dbs[3]:getArmature():getBone("touziFAIL_TH"):setDisplay(dragonBones.CCDBNode:new(infoNode))
        -- self.dbs[3]:getArmature():getBone("touziFAIL_GB"):setDisplay(dragonBones.CCDBNode:new(btnNode))
        
        self.dbs[3]:getArmature():getCCSlot("touziFAIL_TH"):getCCDisplay():addChild(infoNode)
        self.dbs[3]:getArmature():getCCSlot("touziFAIL_GB"):getCCDisplay():addChild(btnNode)
    end
    for i = 1, #self.dbs do
        self.dbs[i]:getAnimation():play()
    end
end

function DiceResultPopup:onCloseBtnListener_()
    self:hidePanel()
end

function DiceResultPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function DiceResultPopup:hidePanel()
    nk.PopupManager:removePopup(self)
    return self
end

return DiceResultPopup