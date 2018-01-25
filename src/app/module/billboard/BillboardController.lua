local BillboardController = {}

function BillboardController.loadDataFromServer(callback)
    bm.HttpService.POST({
        mod = "Notice",
        act = "noticeDetail",
        limit = 1,
    }, function(response)
        local json_response = json.decode(response)
        if type(json_response) == 'table' then
            callback(json_response)
        end
    end)
end

return BillboardController
