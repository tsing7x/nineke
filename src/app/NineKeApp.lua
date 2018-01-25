require("config")
require("cocos.init")
require("framework.init")
require("boomegg.init")
require("app.init")

local NineKeApp = class("NineKeApp", cc.mvc.AppBase)
local TRANSITION_TIME = 0.6;

-- ui.DEFAULT_TTF_FONT = "Chococooky.ttf"

function NineKeApp:ctor()
    NineKeApp.super.ctor(self)
    nk.app = self

    -- local analytics = require("app.util.UmengPluginAndroid");
    -- cc.analytics = analytics.new();
end

function NineKeApp:init_analytics()
    -- init analytics
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:start("analytics.UmengAnalytics")
    end
    
    -- 改为真实的应用ID，第二参数为渠道号(可选)
    if device.platform == "android" then
        cc.analytics:doCommand {
            command = "startWithAppkey",
            args = {appKey = appconfig.UMENG_APPKEY_ANDROID, channelId=nk.Native:getChannelId()}
        }
    elseif device.platform == "ios" then
        cc.analytics:doCommand {
            command = "startWithAppkey",
            args = {appKey = appconfig.UMENG_APPKEY_IOS, channelId=nk.Native:getChannelId()}
        }
    end
end

function NineKeApp:run()
    -- note: 更新后update的时候退出游戏会初始化友盟
    self:init_analytics()

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand { command = "updateOnlineConfig"}
    end
    -- 上报广告平台游戏开始
    nk.AdSdk:report(consts.AD_TYPE.AD_START)
    self.immediateDealMatch = true
    self:enterScene("HallScene")
end

function NineKeApp:enterHallScene(args)
    self.immediateDealMatch = false
    self:enterScene("HallScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end

function NineKeApp:enterRoomScene(args)
    self.immediateDealMatch = false
    self:enterScene("RoomScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end

function NineKeApp:enterMatchRoomScene(args)
    self.immediateDealMatch = false
    self:enterScene("MatchRoomScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end

function NineKeApp:enterDiceScene(args)
    self.immediateDealMatch = false
    self:enterScene("DiceScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end

function NineKeApp:enterPdengScene(args)
    self.immediateDealMatch = false
    self:enterScene("PdengScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end

-- 比赛入场Bug
function NineKeApp:dealEnterMatch()
    self.immediateDealMatch = true
    local list = {}
    local tempList = nk.socket.MatchSocket.catchMatchStartPack
    for k,v in pairs(tempList) do
        if v then
            if (os.time()-v.time)<v.pack.joinTime then
                table.insert(list,v)
            end
        end
    end
    local temp = nil
    for k,v in pairs(list) do
        if not temp then
            temp = v
        else
            if v.pack.matchlevel>temp.pack.matchlevel then
                temp = v
            end
        end
    end
    if temp then
        local pack = temp.pack
        if pack and pack.matchlevel and pack.matchid then
            nk.socket.MatchSocket.canDelayResume = false
            pack.joinTime = pack.joinTime - os.time() + temp.time
            nk.match.MatchModel:startDownTime(pack.joinTime)
            bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_STARTING,data=pack}) -- 弹窗比赛开始
        end
    end
end

-- 统计停留在游戏不到30秒
local function umeng_check_enter_background_too_short()
    local g = global_statistics_for_umeng
    local t1 = g.enter_foreground_time or g.run_main_timestamp
    local delta = math.abs(os.difftime(os.time(), t1))
    if delta <= 30 then
        cc.analytics:doCommand {
            command = 'eventCustom',
            args = {
                eventId    = 'leave_in_short_time',
                attributes = 'leave_time,' .. delta,
                counter    = 1,
            },
        }
    end
end

-- 统计 loading界面关闭应用的情况
-- 日期: Jun 2 2016
-- 备注: 产品曦敏说,此项的含义是为了统计没有进入过大厅,还停留在登录界面就流失的
-- 用户的数量.
-- 已经进入过大厅并游戏了很长时间,只是后来返回登录界面,然后切到后台的用户,不应该
-- 统计的.
local function umeng_check_close_view()
    local g = global_statistics_for_umeng
    if g.umeng_view == g.Views.login then
        if g.first_enter_login_not_checked then
            g.first_enter_login_not_checked = false

            -- cocos2d-x/external/extra/network/CCNetwork.h
            local nt = network.getInternetConnectionStatus()
            local ns = ({ [0] = 'NA', [1] = 'Wifi', [2] = 'WWAN' })[nt] or 'Unknown'
            local s1 = 'network_type,' .. ns

            -- 友盟限制: 每个事件最多10个参数,每个参数最多1000个取值
            local dt = math.abs(os.difftime(os.time(), g.run_main_timestamp))
            if dt > 999 then dt = 999 end
            local s2 = '|quit_time,' .. dt

            cc.analytics:doCommand {
                command = 'eventCustom',
                args = {
                    eventId    = 'quit_at_login_scene',
                    attributes = s1 .. s2,
                    counter    = 2,
                },
            }
        end
    end

end

function NineKeApp:onEnterBackground()
    -- 比赛相关
    local curScene = display.getRunningScene()
    if curScene and curScene.onEnterBackground then
        curScene:onEnterBackground()
    end

    NineKeApp.super.onEnterBackground(self)
    bm.EventCenter:dispatchEvent(nk.eventNames.APP_ENTER_BACKGROUND)
    if device.platform == "android" or device.platform == "ios" then
        umeng_check_enter_background_too_short()
        umeng_check_close_view()
        cc.analytics:doCommand { command = "applicationDidEnterBackground" }
    end
    audio.stopMusic(true)
end

function NineKeApp:onEnterForeground()
    -- 推送弹窗
    local startType = -1
    if nk and nk.Native and nk.Native.getStartType then
        startType = nk.Native:getStartType()
    end
    -- 比赛相关
    local curScene = display.getRunningScene()
    if curScene and curScene.onEnterForeground then
        curScene:onEnterForeground(startType)
    end
    nk.socket.MatchSocket.isFromBack = true  -- 从后台切回来

    NineKeApp.super.onEnterForeground(self)
    bm.EventCenter:dispatchEvent(nk.eventNames.APP_ENTER_FOREGROUND)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand { command = "applicationWillEnterForeground" }

        -- 记录下返回的时间
        global_statistics_for_umeng.enter_foreground_time = os.time()
    end
end

function NineKeApp:addAlertTip(msg)
    -- local scene = display.getRunningScene()
    -- if scene then
    --     if not self.alertTip_ then
    --         self.alertTip_ = ui.newTTFLabel({
    --             text = msg,
    --             font = "Arial.ttf",
    --             size = 36,
    --             x = display.left + 10,
    --             y = display.cy,
    --             color=cc.c3b(0xff,0x0,0x0),
    --             align = ui.TEXT_ALIGN_LEFT,
    --             dimensions = cc.size(display.width,display.height)
    --         }):addTo(scene, 9900)
    --     end
    --     self.alertTip_:setString(msg);
    -- end
end

function NineKeApp:loadOnOffData()
    nk.OnOff:load(function()
        -- nk.TopTipManager:showTopTip("loadOnOffData");
        bm.EventCenter:dispatchEvent({name="OnOff_Load"});
    end);
end

-- 文字提示
function NineKeApp:tip(itype, val, px, py, layer, delayts, lblSize, offY)
    -- if CF_DEBUG >= 5 then
        local runScene = display.getRunningScene()
        if runScene == nil then
            return
        end
        -- 
        px = px or 0;
        py = py or 0;
        delayts = delayts or 0;
        lblSize = lblSize or 22;
        layer = layer and layer or 100;
        offY = offY or 0;
        local offy = lblSize*1.82 + offY;--默认偏移量为40，默认字体大小为22：40/22
        local maxdw = lblSize*1.4;--默认图标大小为30，默认字体大小为22：30/22
        local lblColor;

        if type(val) == "table" then
            num = tonumber(val.num) or 1;
        else
            num = tonumber(val) or 1;
        end
        
        if num == 0 then
            return;
        end

        if num > 0 then
            lblColor = cc.c3b(0xf4, 0xcd, 0x56)--styles.FONT_COLOR.GOLDEN_TEXT;
        else
            lblColor = cc.c3b(0x0, 0x99, 0x0);
        end

        local sign;
        if num < 0 then
            sign = " - "
        else
            sign = " + "
        end
        -- 
        local isFlipY = false;
        local info = {}
        if itype == 2 then -- 比赛券
            info.icon = "match_gamecoupon.png"
            info.txt = sign..tostring(math.abs(num))
        elseif itype == 1 then -- 筹码
            info.icon = "match_chip.png"
            info.txt = sign..tostring(math.abs(num))
        elseif itype == 3 then --现金币
            info.icon = "match_score.png"
            info.txt = sign..tostring(math.abs(num))
        elseif itype == 4 then -- 金券
            info.icon = "match_goldcoupon.png"
            info.txt = sign..tostring(math.abs(num))
        elseif itype == 5 then -- 门票
            info.icon = "matchTick_icon.png"
            info.txt = sign..tostring(math.abs(num))
        -- elseif itype == 7 then --道具
        --     info.icon = "#user-info-prop-icon.png"
        --     info.txt = sign..tostring(math.abs(num)) 
        elseif itype == 7 or itype == 8 then
            if type(val) == "table" then
                info.icon = val.url or "#prop_hddj_icon.png";
            else
                info.icon = "#prop_hddj_icon.png";
            end            
            info.txt = sign..tostring(math.abs(num))
            if type(info.icon) == "userdata" and tolua.type(info.icon) == "CCTexture2D" then
                isFlipY = true;
            end
        elseif itype == 9 then
            info.icon = "match_gcoins.png"
            info.txt = sign..tostring(math.abs(num))
        elseif itype == 11 then
            info.icon = "#pop_userinfo_prop_kickCard.png"
            info.txt = sign..tostring(math.abs(num))
        else
            return; 
        end
        -- 
        if num < 0 then
            offy = offy + 32
        end
        -- 
        layer = layer + itype;
        -- 
        local node = display.newNode():pos(px, py):addTo(runScene, layer)
        local label = ui.newTTFLabel({
                    text = info.txt,            
                    size = lblSize,
                    x = 0,
                    y = 0,
                    align = ui.TEXT_ALIGN_CENTER,
                    color = lblColor
            })
            :addTo(node)

        local icon = display.newSprite(info.icon):addTo(node);
        local isz = icon:getContentSize();
        local lblSz = label:getContentSize()
        local xxscale, yyscale = maxdw/isz.width, maxdw/isz.height;
        icon:setScale(yyscale)
        icon:setFlippedY(isFlipY);
        label:setPositionX(isz.width*yyscale*0.5 + lblSz.width*0.5 + 0)
        
        node:moveBy(0.3, 0, offy)
        node:setCascadeOpacityEnabled(true)
        node:opacity(0)
        local ts = 0.35
        transition.fadeIn(node, {time=ts, delay=delayts, onComplete=function()
            transition.moveBy(node, {time=ts, delay=delayts, y=offy, delay=0.5})
            transition.fadeOut(node, {time=ts, delay=delayts, delay=0.5, onComplete=function() 
                node:removeSelf()
            end})
        end})
    -- end
end

return NineKeApp
