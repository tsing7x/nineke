--
--
--
local UpdateView = require("update.UpdateView")
local upd = require("update.init")
local Func = require("update.functions")

local UpdateScene = class("UpdateScene", function()
    return display.newScene("UpdateScene")
end)

function UpdateScene:ctor(controller)
    self.controller_ = controller
    self:setNodeEventEnabled(true)
    --更新进度条界面
    -- 背景缩放系数
    self.bgScale_ = 1
    if display.width > 1140 and display.height == 640 then
        self.bgScale_ = display.width / 1140
    elseif display.width == 960 and display.height > 640 then
        self.bgScale_ = display.height / 640
    end

    self.updateView = UpdateView.new(self.bgScale_)
        :pos(display.cx, display.cy)
        :addTo(self)

    if device.platform == "android" then
        self.touchLayer_ = display.newLayer()
        self.touchLayer_:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then 
                device.showAlert(upd.lang.getText("UPDATE", "QUIT_DIALOG_TITLE"),
                    upd.lang.getText("UPDATE", "QUIT_DIALOG_MSG"),
                    {
                        upd.lang.getText("UPDATE", "QUIT_DIALOG_CONFIRM"), 
                        upd.lang.getText("UPDATE", "QUIT_DIALOG_CANCEL")
                    }, function(event)
                        if event.buttonIndex == 1 then
                            cc.Director:getInstance():endToLua()
                        end
                    end)
            end
        end)
        self.touchLayer_:setKeypadEnabled(true)
        self:addChild(self.touchLayer_)
    end
end

function UpdateScene:onEnter()
    self.controller_:startUpdate()

    if Func.is_mobile_platform() then
        local g = global_statistics_for_umeng
        g.umeng_view = g.Views.loading
    end
end

function UpdateScene:onExit()
    if device.platform == "android" then
        device.cancelAlert()
    end

    if Func.is_mobile_platform() then
        local g = global_statistics_for_umeng
        g.umeng_view = g.Views.other
    end
end

function UpdateScene:getUpdateView()
    return self.updateView
end

return UpdateScene
