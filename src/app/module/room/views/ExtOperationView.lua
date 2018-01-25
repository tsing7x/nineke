--
-- Author: viking@boomegg.com
-- Date: 2014-09-17 11:53:34
--

local ExtOperationView = class("ExtOprationView", function()
    return display.newNode()
end)

local OperationButton = import(".OperationButton")

ExtOperationView.WIDTH = display.width * 0.7 - 16
ExtOperationView.HEIGHT = 72

function ExtOperationView:ctor(seatManager)
    self.seatManager_ = seatManager
    self:setupView()
end

function ExtOperationView:setupView()
    local width, height = ExtOperationView.WIDTH, ExtOperationView.HEIGHT

    -- 亮出手牌
    self.showHandCardBtn = OperationButton.new()
        :setEnabled(true)
        :setLabel(bm.LangUtil.getText("ROOM", "SHOW_HANDCARD"))
        :setCheckMode(false)
        :onTouch(handler(self, self.onShowHandcard_))
        :addTo(self)
        :pos(width/2 - OperationButton.BUTTON_WIDTH/2, 0)
end

function ExtOperationView:setShowHandcardCallback(showHandcardCallback)
    self.showHandcardCallback_ = showHandcardCallback
    return self
end

function ExtOperationView:onShowHandcard_(evt)
    if evt == bm.TouchHelper.CLICK then
        print("show handcard")
        if self.showHandcardCallback_ then
            self.showHandcardCallback_()
        end
        self:showHandCardAnimation()
        nk.socket.RoomSocket:showHandcard()
    end
end

function ExtOperationView:showHandCardAnimation()
    local seatView_ = self.seatManager_:getSelfSeatView()
    seatView_:showHandCardsAnimation()
end

return ExtOperationView