--
-- Author: VanfoHuang
-- Date: 2016-07-04 10:00:00
--
local WelcomeScene = require("welcome.WelcomeScene")
local WelcomeController = class("WelcomeController")

function WelcomeController:ctor()
	if (device.platform == "android" or device.platform == "ios") and (ccexp.VideoPlayer) then 
        self:showWelcomePage()
    else
        self:enterGame()
    end
end

function WelcomeController:showWelcomePage()
	self.scene_ = WelcomeScene.new(self)
    display.replaceScene(self.scene_)
    self.scene_:showWelcomePage()
end

function WelcomeController:enterGame()
	require("update.UpdateController").new()
end

return WelcomeController