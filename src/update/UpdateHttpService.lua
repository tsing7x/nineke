--[[
    UpdateHttpService.POST({mod="friend",act="list"},
    function(data) 
    end,
    function(errCode[, response])
    end)
]]
local UpdateHttpService = {}

UpdateHttpService.requestId_ = 1
UpdateHttpService.requests = {}

local function request_(method, url, params, resultCallback, errorCallback)
    local requestId = UpdateHttpService.requestId_

    --代理回调
    local function onRequestFinished(evt)
        if evt.name ~= "progress" and evt.name ~= "cancelled" then
            local ok = (evt.name == "completed")
            local request = evt.request
            UpdateHttpService.requests[requestId] = nil

            if not ok then
                -- 请求失败，显示错误代码和错误消息
                if errorCallback ~= nil then
                    errorCallback(request:getErrorCode(), request:getErrorMessage())
                end
                return
            end

            local code = request:getResponseStatusCode()
            if code ~= 200 then
                -- 请求结束，但没有返回 200 响应代码
                if errorCallback ~= nil then
                    errorCallback(code)
                end
                return
            end

            -- 请求成功，显示服务端返回的内容
            local response = request:getResponseString()
            if resultCallback ~= nil then
                resultCallback(response)
            end
        end
    end
    -- 创建一个请求，并以 指定method发送数据到服务端UpdateHttpService.cloneDefaultParams初始化
    local request = network.createHTTPRequest(onRequestFinished, url, method)
    UpdateHttpService.requests[requestId] = request
    UpdateHttpService.requestId_ = UpdateHttpService.requestId_ + 1
    
    -- 加入参数
    if params then
        for k, v in pairs(params) do
            if method == "GET" then
                request:addGETValue(tostring(k), tostring(v))
            else
                request:addPOSTValue(tostring(k), tostring(v))
            end
        end
    end
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start()

    return requestId
end

--[[
    POST到指定的URL，该调用不附加默认参数，如需默认参数,params应该使用UpdateHttpService.cloneDefaultParams初始化
]]
function UpdateHttpService.POST_URL(url, params, resultCallback, errorCallback)
    return request_("POST", url, params, resultCallback, errorCallback)
end

function UpdateHttpService.GET_URL(url, params, resultCallback, errorCallback)
    return request_("GET", url, params, resultCallback, errorCallback)
end

return UpdateHttpService