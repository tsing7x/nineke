--
-- Author: johnny@boomegg.com
-- Date: 2014-09-05 10:57:15
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local UserInfoPopupController = class("UserInfoPopupController")

function UserInfoPopupController:ctor(view)
    self.view_ = view
end

function UserInfoPopupController:getHddjNum()
    if nk.userData.hddjNum then
        self.view_:setHddjNum(nk.userData.hddjNum)
    else
        bm.HttpService.CANCEL(self.hddjNumRequestId_)
        self.hddjNumRequestId_ = bm.HttpService.POST(
            {
                mod = "user", 
                act = "getUserFun"
            }, 
            function (data)
                nk.userData.hddjNum = tonumber(data)
                self.view_:setHddjNum(nk.userData.hddjNum)
            end
        )
    end
end

function UserInfoPopupController:dispose()
    bm.HttpService.CANCEL(self.hddjNumRequestId_)
end

return UserInfoPopupController
