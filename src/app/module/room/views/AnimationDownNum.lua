--
-- Author: XT
-- Date: 2015-08-12 11:48:32
--
local AnimationDownNum = class("AnimationDownNum")

function AnimationDownNum:ctor(params)
	self.parent_ = params.parent
	self.px_ = params.px
	self.py_ = params.py
	self.val_ = params.time
	self.scaleVal_ = params.scale or 5
	self.ts_ = 0.2/5 * self.scaleVal_
	self.ts_ = self.ts_ < 0.1 and 0.1 or self.ts_
	self.preFix_ = params.prefix or "#upgrade_{1}.png"--
	self.plist_ = params.plist or "upgrade_texture.plist"--纹理配置
	self.texture_ = params.texture or "upgrade_texture.png"--纹理图片
	self.callback_ = params.callback--执行完毕的回调
	self.refreshCallback_ = params.refreshCallback	--每秒钟刷新
	self.startTime_ = os.time()
	display.addSpriteFrames(self.plist_, self.texture_, function()
		self.val_ = self.val_ - (os.time() - self.startTime_)
		self.startTime_ = os.time()
        self:play_(self.val_)
    end)
end

function AnimationDownNum:getNumBatchNode_(val)
	local batchNode = display.newNode()
	local valStr = tostring(val)
	local len = string.len(valStr)
	local dw,dh = 0,0
	local px
	for i=1,len do
		local numNode = display.newSprite(self:formatString(self.preFix_, string.sub(valStr, i, i))):addTo(batchNode)
		local sz = numNode:getContentSize()
		if nil == px then
			px = -sz.width*(len - 1)*0.5
		end
		dh = sz.height
		numNode:pos(px, 0)
		dw = dw + sz.width
		px = px + sz.width
	end

	batchNode:setCascadeOpacityEnabled(true)

	return batchNode,dw,dh
end

function AnimationDownNum:renderNumBatchNode_(val, parent, px, py)
	local batchNode,dw,dh = self:getNumBatchNode_(val)
	if parent then
		batchNode:addTo(parent, 999)
	end

	if px and py then
		batchNode:pos(px, py)
	end

	return batchNode
end

function AnimationDownNum:play_(val)
	if val <= 0 or not self.startTime_ or os.time() - self.startTime_ >= self.val_+1 then
		if self.numNode_ then
			self.numNode_:removeSelf()
			self.numNode_ = nil
		end

		if self.callback_ then
			self.callback_()
		end
		return
	end

	self.numNode_ = self:renderNumBatchNode_(val, self.parent_, self.px_, self.py_)
    transition.scaleTo(self.numNode_, {scale=self.scaleVal_, time=self.ts_, easing = "BOUNCEOUT"})
    self.numNode_:runAction(transition.sequence({
    		cc.DelayTime:create(0.7), 
    		cc.FadeOut:create(0.3),
    		cc.CallFunc:create(function()    			
                self.numNode_:removeSelf()
                val = val - 1
                if self.refreshCallback_ then
                	self.refreshCallback_(val)
                end
                self:play_(val)
            end)
    	}))
end

function AnimationDownNum:cleanUp()
	if self.numNode_ then
		transition.stopTarget(self.numNode_)
		self.numNode_:removeSelf()
		self.numNode_ = nil
	end
	self.startTime_  = nil
	self.val_ = nil
end

function AnimationDownNum:formatString(str, ...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        local output = str
        for i = 1, numArgs do
            local value = select(i, ...)
            output = string.gsub(output, "{" .. i .. "}", value)
        end
        return output
    else
        return str
    end
end

return AnimationDownNum