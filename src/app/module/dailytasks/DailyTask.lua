
local DailyTask = class("DailyTask")

DailyTask.STATUS_SPECIAL = 0 --特殊指定的任务
DailyTask.STATUS_CAN_REWARD = 1 --可以领取
DailyTask.STATUS_UNDER_WAY = 2 --已经开始并进行着
DailyTask.STATUS_FINISHED = 3 --已经完成，领取过

DailyTask.LOGINREWARD_TASK_ID = 1101
DailyTask.LOGINREWARD_TASK_NAME = bm.LangUtil.getText("LOGINREWARD", "TITLE")
DailyTask.LOGINREWARD_TASK_ICON = "pop_task_loginreward_icon.png"
DailyTask.LOGINREWARD_TASK_SORT = 2
DailyTask.LOGINREWARD_TASK_GOTO = 1101

function DailyTask:ctor()
end

function DailyTask:fromJSON(json)
    self.id = json.id
    self.name = json.name
    self.sort = json.sort 
    self.iconUrl = json.iconUrl 
    self.contype = json.contype
    self.goto = json.goto
    self.subtask = {}
    for k,v in pairs(json.subtask) do
        v.id = k
        table.insert(self.subtask, v)
    end
    table.sort(self.subtask, function(o1, o2)
            return o1.id < o2.id
        end)
    self.cur = json.cur
    self.progress = json.cur
    if self.contype == "cwin" then
        self.lcwin = json.lcwin
    end

    self:update()
end

function DailyTask:update()
    if self.subtask then
        local finished = true
        for i =1, #self.subtask do
            local t = self.subtask[i]
            self.target = t.num
            self.reward = t.reward
            if t.reward.money then
                self.rewardDesc = bm.LangUtil.getText("CRASH", "CHIPS", t.reward.money)
            elseif t.reward.gcoins then
                self.rewardDesc = bm.LangUtil.getText("STORE", "FORMAT_GOLD", t.reward.gcoins)
            elseif t.reward.coins then
                self.rewardDesc = bm.LangUtil.getText("MATCH", "SCORETEXT", t.reward.coins)
            end
            if t.rewarded == 0 then
                if self.cur >= t.num then
                    self.status = DailyTask.STATUS_CAN_REWARD
                    self.progress = t.num
                else
                    self.progress = self.cur
                    if self.contype == "cwin" and self.lcwin then
                        self.progress = self.lcwin
                    end
                    self.status = DailyTask.STATUS_UNDER_WAY
                end
                finished = false
                self.currentSubTaskIndex = i
                self.currentSubTaskId = t.id
                break
            end
        end
        if finished and self.status ~= DailyTask.STATUS_SPECIAL then
            self.progress = self.target
            self.status = DailyTask.STATUS_FINISHED
        end
    end
end

return DailyTask