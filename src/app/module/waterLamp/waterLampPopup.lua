local WaterLampPopup = class("WaterLampPopup", function()
    return display.newNode()
end)

----[[
local POP_WIDTH = 800
local POP_HEIGHT = 546
local PANEL_CLOSE_BTN_Z_ORDER = 99

function WaterLampPopup:ctor(...)
    self:setNodeEventEnabled(true)

    local bgScaleX, bgScaleY = 1, 1
    if display.width > 960 and display.height == 640 then
        bgScaleX = display.width / 960
    elseif display.width == 960 and display.height > 640 then
        bgScaleY = display.height / 640
    end
    self:setScaleX(bgScaleX)
    self:setScaleY(bgScaleY)
            
    local backFrame = display.newSprite("waterLamp/waterLampPopuBg.png"):addTo(self)
    backFrame:setTouchEnabled(true)
    backFrame:setTouchSwallowEnabled(true)

    bm.HttpService.POST(
    {
        mod = "Lkf",
        act = "getFreeTime",
        uid = tonumber(nk.userData.uid)
     },
    function (data) 
        local callData = json.decode(data)
        self.leftTime_ = callData.freeTimes

        self:addWaterlamp()
        self:addSendBtn()
        self:addCloseBtn()
    end,
    function (data)
    end)
end

function WaterLampPopup:addSendBtn()
    local px = POP_WIDTH/2 - 255
    local py = POP_HEIGHT/2 - 480
    
    local btnPath = "#waterLampSendBtn30k.png"
    if self.leftTime_ > 0 then
        btnPath = "#waterLampSendBtn.png"        

        self.leftTimeLabel_ = ui.newTTFLabel({
            text = self.leftTime_, 
            color = cc.c3b(0x64, 0x10, 0x10), 
            size = 20, 
            dimensions=cc.size(100, 0),
            align = ui.TEXT_ALIGN_RIGHT,
        })
        :pos(px - 45, py + 7)
        :addTo(self, PANEL_CLOSE_BTN_Z_ORDER + 1)
    end

    self.sendBtn_ = cc.ui.UIPushButton.new({normal = btnPath, pressed=btnPath})
        :pos(px, py)
        :onButtonClicked(function()   
            if tonumber(nk.userData.money) > 30000 or self.leftTime_ > 0 then 
                bm.HttpService.POST(
                {
                    mod = "Lkf",
                    act = "waterfall",
                    uid = tonumber(nk.userData.uid)
                 },
                function (data) 
                    local callData = json.decode(data)
                    self.lottoData = callData
                end,
                function (data)
                end)

                self:updateWaterlamp()

                if self.leftTime_ > 0 then
                    self.leftTime_ = self.leftTime_ - 1
                    self.leftTimeLabel_:setString(self.leftTime_)
                    
                    if self.leftTime_ == 0 then
                        self.leftTimeLabel_:hide()
                        self.sendBtn_:setButtonImage("normal", "#waterLampSendBtn30k.png", true)
                        self.sendBtn_:setButtonImage("pressed", "#waterLampSendBtn30k.png", true)
                    end
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("WATERLAMP", "NO_MONEY_TIP"))  
            end
        end)
        :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)  

end

function WaterLampPopup:addCloseBtn()
    local px = POP_WIDTH/2 - 30
    local py = POP_HEIGHT/2 - 45
    if not self.closeBtn_ then
        self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#waterLampCloseBtn.png", pressed="#waterLampCloseBtn.png"})
            :pos(px, py)
            :onButtonClicked(function()
                self:hide()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            end)
            :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)
    end
end

function WaterLampPopup:addWaterlamp()
    self.enableSendLamp = true
    self.sendWaterLampTimes_ = 0
    self.waterLamp_ = {}    
    self.waterLamp_[1] = display.newSprite("#waterLamp1.png"):pos(-276, -154):addTo(self, 2)    

    self.waterLamp_[2] = display.newSprite("#waterLamp2.png"):pos(-328, -208):addTo(self, 2)
    self.waterLamp_[3] = display.newSprite("#waterLamp3.png"):pos(-206, -234):addTo(self, 3)

    self.waterLamp_[5] = display.newSprite("#waterLamp2.png"):pos(-328, -208):addTo(self, 2)
    self.waterLamp_[6] = display.newSprite("#waterLamp3.png"):pos(-206, -234):addTo(self, 3)
    self.waterLamp_[7] = display.newSprite("#waterLamp4.png"):pos(-151, -184):addTo(self, 1)

    self.waterLamp_[4] = display.newSprite("#waterLamp4.png"):pos(-151, -184):addTo(self, 1)
end

function WaterLampPopup:updateWaterlamp()
    if not self.enableSendLamp then
        return 
    end
    self.enableSendLamp = false

    --送水灯次数加1
    self.sendWaterLampTimes_ = self.sendWaterLampTimes_ + 1
    if self.sendWaterLampTimes_ > 4 then 
        self.sendWaterLampTimes_ = 4
    end
    
    --计算路径
    local speed = 300    
    local path = {
        {cc.p(30, -50), cc.p(85, -25), cc.p(95, 20), cc.p(400, 89)},
        {cc.p(30, -50), cc.p(85, -25), cc.p(95, 20), cc.p(273, 113)},
        {cc.p(30, -50), cc.p(85, -25), cc.p(95, 20), cc.p(314, 59)},
        {cc.p(30, -50), cc.p(85, -25), cc.p(95, 20), cc.p(400, 120)},
    }

    --计算时间
    local t = {}
    for i = 1, 4 do
        t[i] = math.sqrt(path[self.sendWaterLampTimes_][i].x*path[self.sendWaterLampTimes_][i].x 
                + path[self.sendWaterLampTimes_][i].y*path[self.sendWaterLampTimes_][i].y)/speed
    end

    --开始动作
    local seq = cc.Sequence:create(
        cc.MoveBy:create(t[1], path[self.sendWaterLampTimes_][1]),
        cc.MoveBy:create(t[2], path[self.sendWaterLampTimes_][2]),
        cc.MoveBy:create(t[3], path[self.sendWaterLampTimes_][3]), 
        cc.CallFunc:create(handler(self, self.updateWaterlamp2)),
        cc.MoveBy:create(t[4], path[self.sendWaterLampTimes_][4]),
        cc.CallFunc:create(handler(self, self.updateWaterlamp3))
    )

    self.waterLamp_[self.sendWaterLampTimes_]:runAction(seq)
end

function WaterLampPopup:updateWaterlamp2()
    if self.sendWaterLampTimes_ < 4 then
        self.waterLamp_[self.sendWaterLampTimes_ + 1]:setPosition(cc.p(-260, -154))
    end
end

function WaterLampPopup:updateWaterlamp3()
    self.enableSendLamp = true
    local newZOrder = {3, 0, 3, 2}
    self.waterLamp_[self.sendWaterLampTimes_]:setLocalZOrder(newZOrder[self.sendWaterLampTimes_])
    if self.sendWaterLampTimes_ == 4 then
        local index = checkint(math.random(4))
        local tex = self.waterLamp_[index]:getTexture()
        self.waterLamp_[self.sendWaterLampTimes_]:setTexture(tex)
        self.waterLamp_[self.sendWaterLampTimes_]:setPosition(cc.p(-260, -154))
    end

    local sendBlessingPopup = import("app.module.waterLamp.sendBlessingPopup")
    sendBlessingPopup.new(self.lottoData):show()
end

function WaterLampPopup:show()
    nk.PopupManager:addPopup(self, true ~= false, true ~= false, true ~= false, nil ~= false)
    return self
end

function WaterLampPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end


--]]

return WaterLampPopup
