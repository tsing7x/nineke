--
-- Author: viking@boomegg.com
-- Date: 2014-09-13 21:08:19
-- 事件处理,具体逻辑都是调用DailyTasksController的接口

local DailyTasksEventHandler = class("DailyTasksEventHandler")

local DailyTasksController = import(".DailyTasksController")

--view事件
DailyTasksEventHandler.GET_RWARD = "GET_RWARD"
DailyTasksEventHandler.GET_RWARD_ALREADY = "GET_RWARD_ALREADY"
DailyTasksEventHandler.GET_TASK_LIST = "GET_TASK_LIST"
DailyTasksEventHandler.LOAD_TASK_LIST_ALREAD = "LOAD_TASK_LIST_ALREAD"
DailyTasksEventHandler.GOTO_TASK = "GOTO_TASK"
DailyTasksEventHandler.UPDATE_BOX_TASK = "UPDATE_BOX_TASK"

DailyTasksEventHandler.GET_ACHIEVE_RWARD = "GET_ACHIEVE_RWARD"
DailyTasksEventHandler.GET_ACHIEVE_RWARD_ALREADY = "GET_ACHIEVE_RWARD_ALREADY"
DailyTasksEventHandler.GET_ACHIEVE_LIST = "GET_ACHIEVE_LIST"
DailyTasksEventHandler.LOAD_ACHIEVE_LIST_ALREAD = "LOAD_ACHIEVE_LIST_ALREAD"

--上报事件
DailyTasksEventHandler.REPORT_USER_ALLIN = "REPORT_USER_ALLIN"
DailyTasksEventHandler.REPORT_FB_SHARE = "REPORT_FB_SHARE"
DailyTasksEventHandler.REPORT_SEND_DEALER = "REPORT_SEND_DEALER"
DailyTasksEventHandler.REPORT_WIN_GOODCARD = "REPORT_WIN_GOODCARD"

function DailyTasksEventHandler:ctor()
    self.controller_ = DailyTasksController.new()

    self:addEvents()
end

function DailyTasksEventHandler:addEvents()
    self:addEvent(DailyTasksEventHandler.GET_RWARD, handler(self, self.onGetReward_))
    self:addEvent(DailyTasksEventHandler.GET_TASK_LIST, handler(self, self.onGetTaskList_))

    self:addEvent(DailyTasksEventHandler.GET_ACHIEVE_RWARD, handler(self, self.onGetAchieveReward_))
    self:addEvent(DailyTasksEventHandler.GET_ACHIEVE_LIST, handler(self, self.onGetAchieveList_))

    self:addEvent(nk.eventNames.HALL_LOGIN_SUCC, handler(self, self.onLogin_))
    self:addEvent(nk.eventNames.HALL_LOGOUT_SUCC, handler(self, self.onLogout_))

    self:addEvent(DailyTasksEventHandler.REPORT_USER_ALLIN, handler(self, self.onReportUserAllin_))
    self:addEvent(DailyTasksEventHandler.REPORT_FB_SHARE, handler(self, self.onReportFbShare_))
    self:addEvent(DailyTasksEventHandler.REPORT_SEND_DEALER, handler(self, self.onReportSendDealer_))
    self:addEvent(DailyTasksEventHandler.REPORT_WIN_GOODCARD, handler(self, self.onReportWinGoodCard_))
end

function DailyTasksEventHandler:addEvent(evt, func)
    bm.EventCenter:addEventListener(evt, func)
end

function DailyTasksEventHandler:onGetTaskList_()
    self.controller_:getTasksListData(false)
end

function DailyTasksEventHandler:onGetReward_(evt)
    self.controller_:onGetReward_(evt)
end

function DailyTasksEventHandler:onGetAchieveList_()
    self.controller_:getAchieveListData(false)
end

function DailyTasksEventHandler:onGetAchieveReward_(evt)
    self.controller_:onGetAchieveReward_(evt)
end

function DailyTasksEventHandler:onLogin_()
    self.controller_:setData()
end

function DailyTasksEventHandler:onLogout_()
    
end

function DailyTasksEventHandler:onReportUserAllin_(evt)
    self.controller_:reportDailyTask(1, evt.data)
end

function DailyTasksEventHandler:onReportFbShare_(evt)
    self.controller_:reportDailyTask(2, evt.data)
end

function DailyTasksEventHandler:onReportSendDealer_(evt)
    self.controller_:reportDailyTask(3, evt.data)
end

function DailyTasksEventHandler:onReportWinGoodCard_(evt)
    self.controller_:reportDailyTask(4, evt.data)
end

return DailyTasksEventHandler