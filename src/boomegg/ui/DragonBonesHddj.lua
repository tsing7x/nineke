--
-- Author: KevinYu
-- Date: 2017-03-23 16:39:23

local DragonBonesHddj = class("DragonBonesHddj", function()
	return display.newNode()
end)

local DRAGONBONE_FILES = {"texture.png", "texture.xml", "skeleton.xml"}

function DragonBonesHddj:ctor(path, animationName)
	self.db_ = dragonbones.new({
		skeleton = path..DRAGONBONE_FILES[3],
	    texture = path..DRAGONBONE_FILES[2],
	    aniName = "",
	    armatureName = string.lower(animationName),
	    skeletonName = string.lower(animationName)
	})
	:addTo(self)
	
	self.db_:registerAnimationEventHandler(handler(self, self.onMovementHandler_))
end

function DragonBonesHddj:play(actionName, callback)
	self.callback_ = callback
	self.db_:getAnimation():gotoAndPlay(actionName)
end

function DragonBonesHddj:onMovementHandler_(evt)
	if evt.type == 7 then
		if self.callback_ then
			self.callback_()
			self.callback_ = nil
		end
	end
end

return DragonBonesHddj