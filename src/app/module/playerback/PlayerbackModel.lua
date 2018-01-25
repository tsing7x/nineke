--
-- Author: Jonah0608@gmail.com
-- Date: 2015-12-16 19:19:16
--
local PlayerbackModel = {}

function PlayerbackModel.getTaskData(callback)
    if PlayerbackModel.taskData then
        if callback then callback(PlayerbackModel.taskData) end
        return PlayerbackModel.taskData
    else
        if postId then
            bm.HttpService.CANCEL(postId)
        end
        postId = bm.HttpService.POST({mod = "Regression", act = "getOldUser"}, function(data)
                local jsn = json.decode(data)
                if jsn and jsn[1] and jsn[1] == 1 then
                    PlayerbackModel.taskData = jsn
                    if callback then
                        callback(PlayerbackModel.taskData)
                    end
                else
                    if callback then
                        callback(false)
                    end
                end
            end,
            function()
                if callback then
                    callback(false)
                end
            end)
    end
end

function PlayerbackModel.task2CanReward()
    return nk.userDefault:getStringForKey("task2CanReward","")
end

function PlayerbackModel.task3CanReward()
    return nk.userDefault:getStringForKey("task3CanReward","")
end

function PlayerbackModel.isTask2Doing()
    if PlayerbackModel.taskData then
        return PlayerbackModel.getTask2Status() == "doing"
    else
        return false
    end
end

function PlayerbackModel.isTask3Doing()
    if PlayerbackModel.taskData then
        return PlayerbackModel.getTask3Status() == "doing"
    else
        return false
    end
end

function PlayerbackModel.getTask1Status()
    if not PlayerbackModel.taskData then
        return ""
    end
    if PlayerbackModel.taskData[3] == 1 then
        return "rewarded"
    else
        return "done"
    end
end

function PlayerbackModel.getTask2Status()
    if not PlayerbackModel.taskData then
        return ""
    end
    if PlayerbackModel.taskData[4] == 1 then
        return "rewarded"
    else 
        if PlayerbackModel.getTask1Status() == "rewarded" then
            if PlayerbackModel.task2CanReward() == "done" then
                return "done"
            else
                return "doing"
            end
        elseif not (PlayerbackModel.getTask1Status() == "rewarded") then
            return "not_start"
        end
    end
    return "not_start"
end

function PlayerbackModel.getTask3Status()
    if not PlayerbackModel.taskData then
        return ""
    end
    if PlayerbackModel.taskData[5] == 1 then
        return "rewarded"
    else 
        if PlayerbackModel.getTask2Status() == "rewarded" then
            if PlayerbackModel.task3CanReward() == "done" then
                return "done"
            else
                return "doing"
            end
        elseif not (PlayerbackModel.getTask2Status() == "rewarded") then
            return "not_start"
        end
    end
    return "not_start"
end

function PlayerbackModel.getTask4Status()
    if not PlayerbackModel.taskData then
        return ""
    end
    if PlayerbackModel.taskData[6] == 1 then
        return "rewarded"
    else
        return "done"
    end
end

function PlayerbackModel.setStatus(num)
    if PlayerbackModel.taskData then
        PlayerbackModel.taskData[num + 1] = 1
    end
end

function PlayerbackModel.clearData()
    PlayerbackModel.taskData = nil
end

return PlayerbackModel