--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-19 11:04:11
--
-- 新版本反馈到反馈平台

local FeedbackCommon = {}

-- FIXME:newFeedBackUrl目前写死在文件中，需要修改到PHP返回或者配置文件中
local feedBackUrl = "http://feedback.kx88.net/api/api.php"

local appid

if device.platform == "android" then
    appid = "4098"
elseif device.platform == "ios" then
    appid = "9009"
else
    appid = "4098"
end

local game = "sg"

local orderedPairs = function(t)
    local cmpMultitype = function(op1, op2)
        local type1, type2 = type(op1), type(op2)
        if type1 ~= type2 then --cmp by type
            return type1 < type2
        elseif type1 == "number" and type2 == "number"
            or type1 == "string" and type2 == "string" then
            return op1 < op2 --comp by default
        elseif type1 == "boolean" and type2 == "boolean" then
            return op1 == true
        else
            return tostring(op1) < tostring(op2) --cmp by address
        end
    end

    local genOrderedIndex = function(t)
        local orderedIndex = {}
        for key in pairs(t) do
            table.insert( orderedIndex, key )
        end
        table.sort( orderedIndex, cmpMultitype ) --### CANGE ###
        return orderedIndex
    end

    local orderedIndex = genOrderedIndex( t );
    local i = 0;
    return function(t)
        i = i + 1;
        if orderedIndex[i] then
            return orderedIndex[i],t[orderedIndex[i]];
        end
    end,t, nil;
end

local function Joins(t, mtkey)
    local str = "K";
    if t == nil or type(t) == "boolean"  or type(t) == "byte" then
        return str;
    elseif type(t) == "number" or type(t) == "string" then
        str = string.format("%sT%s%s", str.."", mtkey, string.gsub(t, "[^a-zA-Z0-9]",""));
    elseif type(t) == "table" then
        for k,v in orderedPairs(t) do
            str = string.format("%s%s=%s", str, tostring(k), Joins(v, mtkey));
        end
    end
    return str;
end

local getParams = function(method,postParams)
    postParams.appid = appid
    postParams.game = game
    local post_data = {}
    post_data.method = method
    post_data.mid = nk.userData and nk.userData.uid or nk.Native:getLoginToken()
    post_data.username = nk.userData and nk.userData.nick or "user_" .. post_data.mid
    post_data.time = bm.getTime()
    post_data.mtkey = nk.userData and nk.userData.mtkey or post_data.time .. ""
    post_data.deviceno = nk.Native:getDeviceInfo().deviceId
    post_data.version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion()
    post_data.param = postParams
    local signature = Joins(post_data,post_data.mtkey);
    post_data.sig = crypto.md5(signature)
    print(json.encode(post_data))
    return post_data
end

function FeedbackCommon.initFeedback()
    local post_data = getParams("Feedback.initFeedback",{lang = "tl"})
    local params = {
        api = json.encode(post_data)
    }
    bm.HttpService.POST_URL(feedBackUrl,
        params,
        function (data)
            -- {"time":1433747919,"ret":{"categories":[{"ctid":"402","ctgameid":"sg","ctlanguage":"tl","ctname":"\u767b\u9646\u95ee\u9898","ctpriority":"0","ctprompt":"\u65e0\u6cd5\u767b\u9646\u6e38\u620f\u6216\u8005\u8fdb\u5165\u6e38\u620f\u8fc7\u6162","ctgamesubmit":"0","ctgameprompt":"","ctsearch":"0","ctactive":"1","ctposition":"100","ctcreatetime":"0","ctupdatetime":null,"url":"http:\/\/apps.facebook.com\/twtexas\/feednew.php?ref=submit02.php?ctid="}],"urls":{"faqurl":"http:\/\/apps.facebook.com\/twtexas\/faqnew.php?ref=index.php?a=a","myurl":"http:\/\/apps.facebook.com\/twtexas\/feednew.php?ref=my.php?a=a","myallurl":"http:\/\/apps.facebook.com\/twtexas\/feednew.php?ref=my.php?a=a"}},"flag":1}
        end,
        function ()
            callback(false,"network")
        end
    )
end

--发送反馈请求
function FeedbackCommon.sendFeedback(postParams,callback)
    local deviceInfo = nk.Native:getDeviceInfo()
    local info = "deviceId:" .. deviceInfo.deviceId .. ",deviceName:" .. deviceInfo.deviceName .. ",deviceModel:"
        .. deviceInfo.deviceModel .. ",simNum:" .. deviceInfo.simNum .. ",networkType:" .. deviceInfo.networkType
    if postParams.fcontact == nil then
        postParams.fcontact = info
    else
        postParams.fcontact = postParams.fcontact..","..info
    end
    postParams.vip = 0
    postParams.isHall = 0
    local post_data = getParams("Feedback.sendFeedback",postParams)
    local params = {
        api = json.encode(post_data)
    }
    bm.HttpService.POST_URL(feedBackUrl,
        params,
        function (data)
            if(string.len(data) > 5) then
                local feedbackRetData = json.decode(data)
                if feedbackRetData.ret.fid ~= 0 then
                    callback(true,feedbackRetData)
                end
            else
                callback(false,"paramerr")
            end
        end,
        function ()
            callback(false,"network")
        end
    )
end

--上传图片
function FeedbackCommon.uploadPic(fid,picPath,callback)
    local postParams = {}
    postParams.fid = fid
    network.uploadFile(function(evt)
            if evt.name == "completed" then
                local request = evt.request
                local code = request:getResponseStatusCode()
                local ret = request:getResponseString()
                callback(true,ret)
            elseif evt.name == "failed" then
                callback(false, "failed")
            end
        end,
        feedBackUrl,
        {
            fileFieldName = "pfile",
            filePath = picPath,
            contentType = "Image/jpeg",
            extra={
                {"api",json.encode(getParams("Feedback.mSendFeedBackPicture",postParams))},
            }
        })
end

function FeedbackCommon.getFeedbackList(callback)
    local postParams = {}
    postParams.deviceno = nk.Native:getLoginToken()
    local post_data = getParams("Feedback.mGetFeedback",postParams)
    local params = {
        api = json.encode(post_data)
    }
    bm.HttpService.POST_URL(feedBackUrl,
        params,
        function (data)
            callback(true,FeedbackCommon.translateData(json.decode(data)))
        end,
        function ()
            callback(false,"network")
        end
    )
end

function FeedbackCommon.translateData(feedbackRetData)
    local feedbackList = {}
    feedbackList.ret = 0
    feedbackList.data = {}
    print(#feedbackRetData.ret)
    for i = 1,#feedbackRetData.ret do
        feedbackList.data[i] = {}
        feedbackList.data[i].content = feedbackRetData.ret[i].msgtitle
        feedbackList.data[i].mtime = feedbackRetData.ret[i].msgtime
        feedbackList.data[i].answer = feedbackRetData.ret[i].rptitle
        feedbackList.data[i].rptime = feedbackRetData.ret[i].rptime
        feedbackList.data[i].closed = feedbackRetData.ret[i].closed
        feedbackList.data[i].fid = feedbackRetData.ret[i].id
    end
    -- table.sort(feedbackList.data,function(a,b) return a.mtime > b.mtime end )
    return feedbackList
end

function FeedbackCommon.closeTicket(param_data,callback)
    -- local param_data = {};
    -- param_data.fid = fid;
    -- param_data.solved = solved;
    local postParams = {}
    postParams.fid = param_data.fid
    postParams.solved = param_data.solved
    local post_data = getParams("Feedback.mCloseTicket",postParams)
    local params = {
        api = json.encode(post_data)
    }
    bm.HttpService.POST_URL(feedBackUrl,
        params,
        function (data)
            -- callback(true,FeedbackCommon.translateData(json.decode(data)))
        end,
        function ()
            -- callback(false,"network")
        end
    )
end

return FeedbackCommon
