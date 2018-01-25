--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-01 15:50:03
--
local UserInfoOtherDialog = import(".UserInfoOtherDiceDialog")
local DiceSeatView = class("DiceSeatView",function()
    return display.newNode()
end)

function DiceSeatView:ctor(ctx)
    self.data_ = nil
    self.exData_ = nil
    self.ctx = ctx
    self.avatar_ = nk.ui.CircleIcon.new():addTo(self)
    self.touchHelper_ = bm.TouchHelper.new(self.avatar_, handler(self, self.onTouch_))
    self.touchHelper_:enableTouch()
end

function DiceSeatView:setData(data,exData)
    self.data_ = data
    self.exData_ = exData
    if self.data_ == nil then
        self:removeData()
        return
    end
    if self.exData_ and self.exData_.img and string.len(self.exData_.img) > 5 then
        self.avatar_:setSexAndImgUrl(self.data_.gender,self.exData_.img)
    else
        self.avatar_:setSexAndImgUrl(self.data_.gender,self.data_.img)
    end
end

function DiceSeatView:setSeatId(seatId)
    if self.data_ then
        self.data_.seatId = seatId
    end
end

function DiceSeatView:removeData()
    self.data_ = nil
    self.exData_ = nil
    self.avatar_:resetToDefault()
end

function DiceSeatView:onTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        self:onClickHead()
    end
end

function DiceSeatView:onClickHead()
    if self.data_ then
        if self.data_.uid == nk.userData.uid then
            return
        end
        UserInfoOtherDialog.new(self.ctx):show(self.data_)
    else
        return
    end
end

return DiceSeatView