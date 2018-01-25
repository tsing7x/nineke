
local Achieve = class("Achieve")

Achieve.STATUS_CAN_REWARD = 1 --可以领取
Achieve.STATUS_UNDER_WAY = 2 --已经开始并进行着
Achieve.STATUS_FINISHED = 3 --已经完成，领取过

function Achieve:ctor()
end

function Achieve:fromJSON(json)
    self.id = json.id
    self.name = json.name
    self.sort = json.sort 
    self.iconUrl = json.iconUrl 
    self.contype = json.contype
    self.desc = json.desc
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

    self.task_desc = ""
    for i =1, #self.subtask do
        local t = self.subtask[i]
        local desc_ = string.gsub(self.desc, "{num}", t.num)
        desc_ = string.gsub(desc_, "{reward}", t.reward)
        if i == 1 then
            self.task_desc = desc_
        else
            self.task_desc = self.task_desc .. "\n" .. desc_
        end
    end

    self:update()
end

function Achieve:update()
    if self.subtask then
        local finished = true
        for i =1, #self.subtask do
            local t = self.subtask[i]
            self.target = t.num
            self.reward = t.reward
            if t.reward then
                self.rewardDesc = bm.LangUtil.getText("CRASH", "CHIPS", t.reward)
            end

            if t.rewarded == 0 then
                if self.cur >= t.num then
                    self.status = Achieve.STATUS_CAN_REWARD
                    self.progress = t.num
                else
                    self.progress = self.cur
                    if self.contype == "cwin" and self.lcwin then
                        self.progress = self.lcwin
                    end
                    self.status = Achieve.STATUS_UNDER_WAY
                end
                finished = false
                self.currentSubTaskIndex = i
                self.currentSubTaskId = t.id
                break
            end
        end
        if finished then
            self.progress = self.target
            self.status = Achieve.STATUS_FINISHED
        end
    end
end

return Achieve