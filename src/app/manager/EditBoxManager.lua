--
-- Author: KevinYu
-- Date: 2016-12-29 14:50:44
-- 输入框管理，因为cocos2dx的引擎cocos\ui目录下的控件，触摸是事件是根据渲染层次的；
-- 而lua这边的触摸是一个管理，统一派发的，级别为为-1；所以lua的触摸屏蔽层，屏蔽不了输入框,触摸会被输入框吞噬
-- 只能主动关闭输入框触摸

local EditBoxManager = class("EditBoxManager")

function EditBoxManager:ctor()
	self.editboxList_ = {}
	self.onEditBoxTouchEnabledId_ = bm.EventCenter:addEventListener(nk.eventNames.ENABLED_EDITBOX_TOUCH, handler(self, self.onEditBoxTouchEnabled_))
    self.onEditBoxTouchDisenabledId_ = bm.EventCenter:addEventListener(nk.eventNames.DISENABLED_EDITBOX_TOUCH, handler(self, self.onEditBoxTouchDisenabled_))
end

--添加需要管理的输入框
--count默认为0，但有种情况需要手动计数，当打开弹窗没有输入框，但是切换tab会有输入框
function EditBoxManager:addEditBox(editbox, count)
	assert(editbox, "editbox is nil")
	editbox.referenceCount_ = count or 0
	table.insert(self.editboxList_, editbox) 
end

--删除输入框，一般在输入框所在弹窗关闭时调用
function EditBoxManager:removeEditBox(editbox)
	assert(editbox, "editbox is nil")
	table.removebyvalue(self.editboxList_, editbox)
end

--打开输入框触摸
function EditBoxManager:onEditBoxTouchEnabled_()
    for _, editbox in ipairs(self.editboxList_) do
		editbox.referenceCount_ = editbox.referenceCount_ - 1
		if editbox.referenceCount_ <= 1 then --referenceCount_ <= 1，说明回到之前被屏蔽的输入框弹窗
	        editbox:setTouchEnabled(true)
	    end
	end
end

--关闭输入框触摸
function EditBoxManager:onEditBoxTouchDisenabled_()
	for _, editbox in ipairs(self.editboxList_) do
		editbox.referenceCount_ = editbox.referenceCount_ + 1
		if editbox.referenceCount_ > 1 then --因为每次在打开新弹窗都会派发这个事件，防止关闭新弹窗的输入框触摸
			editbox:setTouchEnabled(false)
		end
	end
end

return EditBoxManager