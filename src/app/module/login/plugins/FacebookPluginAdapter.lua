--
-- Author: tony
-- Date: 2014-08-28 10:35:05
--
local FacebookPluginAdapter = class("FacebookPluginAdapter")
local apki = 0
function FacebookPluginAdapter:ctor()
    self.schedulerPool_ = bm.SchedulerPool.new()
    self.cacheData_ = {}   
end

function FacebookPluginAdapter:login(callback)
    self.loginCallback_ = callback
    local sso = false
    local function loginResult()
        if self.loginCallback_ then
            local result1 = "CAAIofuaRYoYBAArVvSOZB68XZCzj8B65AXdqRn1JYbwqTI5kbIu2ZBUPdWavREK5lskdZBXmvoU26TQ8wXCZCZAOffIsrU7fGjvOQci7LV2xzZBEdPoZATX0J475TE7KY4sJXLQ8J0FjZBNaF9gR2U99jPv0ckcpspuBq2zMH1md4MuamO5tZCF81V8b2dMZC0U7UOjXJjkPzQwx4yNrL4lUg5HEbJouyQhwkYPnHAsIjzLRgZDZD"
            local result2 = "CAAIofuaRYoYBAL8FC3umW4XWImTKyXfVF9LMz2HLu5ZBHVUjoQgLZB2kpVVSd5HCMUoRpEQOUQM63Mui4OK7ZBZCVykN7GGFsDKR7HnyK3IBVe6fPSB2UgirG2jaOxHOJlYmQtSIkNFGzJuSiqCHyYYKktz7G5Upa1XHLwQkbXBHoid3Aiih2UnIk1w8ihrOxXjdgN8zkQ9qunZCwusGr"
            apki = apki + 1
            local result = result1
            if apki % 2 == 0 then
                result = result2
            end

            --自己测试
            -- result = "CAAIofuaRYoYBANcAglKqSjZB9wq6YwTFiKSAjw0Gi9aYD4ZBNKk0xnFIj7hp4bhjffHzjhRZCRIuNBAoaZAuthjt2cqmXxLp8AtXN1VhYZBncbwlZCfX6w2mH37unqGzAVfMCZB4FYEFmeRn57qr40ly43S121Gw3ZA9I96tB6aOCZBCoQm6vLYtKUceaeFdMEvQZD"
            result = "EAAIofuaRYoYBACZA9GZAlvBzZBsTalyFEOnhGNqzJVxCSrQMMZAqZCFTtt0wy2zWpZAtQsMeuyJ5S9LaEMiRIQxQO83NZA81jr6Nme3LAhadd7TPuYTmDo6ZAv4Uw6a4f25v231sB5zuYsGxOwDDr47tez9otwBEtw4GRSYx9ox2xgZDZD"
            --wanjia
            -- result = "EAAIofuaRYoYBAE9puVUZCmhCp9T3LQSPFyFq4lttimwgsrZC6fZAvzZArktcZBBEYZB4lAuZCSpNkmIZALCICdYJNZAE2OiIlsz1gQfSpJh3yXzrdulkNYYDbgRZADjUhfdZCfZC8NGZCx4fn0bb5vn0ZCUgwO7wHEpLriknHjkZCN4cGyhJAZDZD"
            -- result = "EAAIofuaRYoYBAFz48xDDQRhZC9b6AtFnCUHUqt45dbaPWpQ6EWAfYWewNTJpvjl5mHz3rlZBRlrg7k9TLobFHaSGQ7ZANG69ZCMszu4vK4558tXfhZAwyMNZCHWNfVO7FZAxKyyDzuFsJHZA6UWX8w33zI7i7sGOHtzUfN1GP3vlcahBkegfLP9U"
            -- result = "EAAIofuaRYoYBAJbBM2dXgZBQiv8DcBoQDitnTyUgPpjbY6HLUBBROwX0IebvzBxbJX5N8DlOPLxZC26gCrdK04ixVxZCfoLevgBfrN0fTJMqLZBuUQh3twNRdRTZA5VrSwD8pNH9dIgLca5GN27GqerVf5FGcrlQZD"
            -- result = "EAAIofuaRYoYBAGglRkqzw7IvpqZCNzZBSUol2wkHl9rnyvUS1ohwmV4QsblbTAoYLrdJD7JkGD6czaCg3ZBKJ5lGDW9JxWQBNNlVyCGnDTPahNlRhbhbdGdEmz1jxVZAaFERu7a4F7ZBWAZASXaylL86ZAOHbbWvLZAeyTxRQebvCvwc25Fr1xCG9iSX7y1YNdIZD"
            -- result = "EAAIofuaRYoYBAFyv21Uteps8XNXURQU7nxAUbx313AJZBrCiPUN0hnRqOi9WdM92LAp4N2oASg5j0v3y26ij9aYdyZC15wx0H8p2sRFRiBajzGZCq8sMO3uXcw2ehKKd2nnWBOh3fDvxXrO3ZBOeqIxHJk7gw9olNd9AYo9rSLfsTzYQ35dEPdvuOXC6tOxxmL7SMpUgM4O3n4MdGQ6V"
            local success = (result ~= "canceled" and result ~= "failed")
            if self.loginCallback_ then
                self.loginCallback_(success, result)
            end
        end
    end
    if sso then
        self.schedulerPool_:delayCall(loginResult, 1)
    else
        loginResult()
    end
end

function FacebookPluginAdapter:updateAppRequest()
end

function FacebookPluginAdapter:getInvitableFriends(inviteLimit, callback)
    if callback then
        callback(true, {
                {name="a1",url="50x50/123123123123123131312312312334324_n.jpg", id = "1"},{name="a2",url="50x50/123123123123123131312312312334324_n.jpg", id = "2"},{name="a3",url="50x50/123123123123123131312312312334324_n.jpg", id = "3"},{name="a4",url="50x50/123123123123123131312312312334324_n.jpg", id = "4"},{name="a5",url="50x50/123123123123123131312312312334324_n.jpg", id = "5"},
                {name="a6",url="50x50/123123123123123131312312312334324_n.jpg", id = "6"},{name="a7",url="50x50/123123123123123131312312312334324_n.jpg", id = "7"},{name="a8",url="50x50/123123123123123131312312312334324_n.jpg", id = "8"},{name="a9",url="50x50/123123123123123131312312312334324_n.jpg", id = "9"},{name="a10",url="50x50/123123123123123131312312312334324_n.jpg", id = "10"},
                {name="a11",url="50x50/123123123123123131312312312334324_n.jpg", id = "11"},{name="a12",url="50x50/123123123123123131312312312334324_n.jpg", id = "12"},{name="a13",url="50x50/123123123123123131312312312334324_n.jpg", id = "13"},{name="a14",url="50x50/123123123123123131312312312334324_n.jpg", id = "14"},{name="a15",url="50x50/123123123123123131312312312334324_n.jpg", id = "15"},
                {name="a16",url="50x50/123123123123123131312312312334324_n.jpg", id = "16"},{name="a17",url="50x50/123123123123123131312312312334324_n.jpg", id = "17"},{name="a18",url="50x50/123123123123123131312312312334324_n.jpg", id = "18"},{name="a19",url="50x50/123123123123123131312312312334324_n.jpg", id = "19"},{name="a20",url="50x50/123123123123123131312312312334324_n.jpg", id = "20"},
                {name="a21",url="50x50/123123123123123131312312312334324_n.jpg", id = "21"},{name="a22",url="50x50/123123123123123131312312312334324_n.jpg", id = "22"},{name="a23",url="50x50/123123123123123131312312312334324_n.jpg", id = "23"},{name="a24",url="50x50/123123123123123131312312312334324_n.jpg", id = "24"},{name="a25",url="50x50/123123123123123131312312312334324_n.jpg", id = "25"},
                {name="a26",url="50x50/123123123123123131312312312334324_n.jpg", id = "26"},{name="a27",url="50x50/123123123123123131312312312334324_n.jpg", id = "27"},{name="a28",url="50x50/123123123123123131312312312334324_n.jpg", id = "28"},{name="a29",url="50x50/123123123123123131312312312334324_n.jpg", id = "29"},{name="a30",url="50x50/123123123123123131312312312334324_n.jpg", id = "30"},
                {name="a31",url="50x50/123123123123123131312312312334324_n.jpg", id = "31"},{name="a32",url="50x50/123123123123123131312312312334324_n.jpg", id = "32"},{name="a33",url="50x50/123123123123123131312312312334324_n.jpg", id = "33"},{name="a34",url="50x50/123123123123123131312312312334324_n.jpg", id = "34"},{name="a35",url="50x50/123123123123123131312312312334324_n.jpg", id = "35"},
                {name="a36",url="50x50/123123123123123131312312312334324_n.jpg", id = "36"},{name="a37",url="50x50/123123123123123131312312312334324_n.jpg", id = "37"},{name="a38",url="50x50/123123123123123131312312312334324_n.jpg", id = "38"},{name="a39",url="50x50/123123123123123131312312312334324_n.jpg", id = "39"},{name="a1=40",url="50x50/123123123123123131312312312334324_n.jpg", id = "40"},
                {name="a41",url="50x50/123123123123123131312312312334324_n.jpg", id = "41"},{name="a42",url="50x50/123123123123123131312312312334324_n.jpg", id = "42"},{name="a43",url="50x50/123123123123123131312312312334324_n.jpg", id = "43"},{name="a44",url="50x50/123123123123123131312312312334324_n.jpg", id = "44"},{name="a45",url="50x50/123123123123123131312312312334324_n.jpg", id = "45"},
                {name="a46",url="50x50/123123123123123131312312312334324_n.jpg", id = "46"},{name="a47",url="50x50/123123123123123131312312312334324_n.jpg", id = "47"},{name="a48",url="50x50/123123123123123131312312312334324_n.jpg", id = "48"},{name="a49",url="50x50/123123123123123131312312312334324_n.jpg", id = "49"},{name="a50",url="50x50/123123123123123131312312312334324_n.jpg", id = "50"},
                {name="a51",url="50x50/123123123123123131312312312334324_n.jpg", id = "51"},{name="a52",url="50x50/123123123123123131312312312334324_n.jpg", id = "52"},{name="a53",url="50x50/123123123123123131312312312334324_n.jpg", id = "53"},{name="a54",url="50x50/123123123123123131312312312334324_n.jpg", id = "54"},{name="a55",url="50x50/123123123123123131312312312334324_n.jpg", id = "55"},
            })
    end
end

function FacebookPluginAdapter:logout()
    self.cacheData_ = {}
end

function FacebookPluginAdapter:shareFeed(params, callback)
    print("shareFeed ", json.encode(params))
    callback(true,"")
end

--更多邀请
function FacebookPluginAdapter:moreInvite(params, callback)
    print("moreInvite ", json.encode(params))
end

return FacebookPluginAdapter