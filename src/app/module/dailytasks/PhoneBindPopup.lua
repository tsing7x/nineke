--
-- Author: zhangyibc@outlook.com
-- Date: 2017-12-8 11:26:02
--

-- ┏┓　　　┏┓
-- ┏┛┻━━━━━━┛┻┓
-- ┃　　　    ┃ 　
-- ┃　　　━　 ┃
-- ┃　┳┛　┗┳　┃
-- ┃　　　　　┃
-- ┃　　┻　　 ┃
-- ┃　　　　　┃
-- ┗━┓　　　┏━┛
-- ┃　　　┃ 神兽保佑　　　　　　　　
-- ┃　　　┃ 代码无BUG！
-- ┃　　　┗━━━━━━━┓
-- ┃　　　　　　　┣┓
-- ┃　　　　　　　┏┛
-- ┗┓┓┏━━━━━━━━┳┓┏┛
--  ┃┫┫　       ┃┫┫
--  ┗┻┛　       ┗┻┛

--[[                                                                   
              .,,       .,:;;iiiiiiiii;;:,,.     .,,                   
            rGB##HS,.;iirrrrriiiiiiiiiirrrrri;,s&##MAS,                
           r5s;:r3AH5iiiii;;;;;;;;;;;;;;;;iiirXHGSsiih1,               
              .;i;;s91;;;;;;::::::::::::;;;;iS5;;;ii:                  
            :rsriii;;r::::::::::::::::::::::;;,;;iiirsi,               
         .,iri;;::::;;;;;;::,,,,,,,,,,,,,..,,;;;;;;;;iiri,,.           
      ,9BM&,            .,:;;:,,,,,,,,,,,hXA8:            ..,,,.       
     ,;&@@#r:;;;;;::::,,.   ,r,,,,,,,,,,iA@@@s,,:::;;;::,,.   .;.      
      :ih1iii;;;;;::::;;;;;;;:,,,,,,,,,,;i55r;;;;;;;;;iiirrrr,..       
     .ir;;iiiiiiiiii;;;;::::::,,,,,,,:::::,,:;;;iiiiiiiiiiiiri         
     iriiiiiiiiiiiiiiii;;;::::::::::::::::;;;iiiiiiiiiiiiiiiir;        
    ,riii;;;;;;;;;;;;;:::::::::::::::::::::::;;;;;;;;;;;;;;iiir.       
    iri;;;::::,,,,,,,,,,:::::::::::::::::::::::::,::,,::::;;iir:       
   .rii;;::::,,,,,,,,,,,,:::::::::::::::::,,,,,,,,,,,,,::::;;iri       
   ,rii;;;::,,,,,,,,,,,,,:::::::::::,:::::,,,,,,,,,,,,,:::;;;iir.      
   ,rii;;i::,,,,,,,,,,,,,:::::::::::::::::,,,,,,,,,,,,,,::i;;iir.      
   ,rii;;r::,,,,,,,,,,,,,:,:::::,:,:::::::,,,,,,,,,,,,,::;r;;iir.      
   .rii;;rr,:,,,,,,,,,,,,,,:::::::::::::::,,,,,,,,,,,,,:,si;;iri       
    ;rii;:1i,,,,,,,,,,,,,,,,,,:::::::::,,,,,,,,,,,,,,,:,ss:;iir:       
    .rii;;;5r,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,sh:;;iri        
     ;rii;:;51,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.:hh:;;iir,        
      irii;::hSr,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.,sSs:;;iir:         
       irii;;:iSSs:.,,,,,,,,,,,,,,,,,,,,,,,,,,,..:135;:;;iir:          
        ;rii;;:,r535r:...,,,,,,,,,,,,,,,,,,..,;sS35i,;;iirr:           
         :rrii;;:,;1S3Shs;:,............,:is533Ss:,;;;iiri,            
          .;rrii;;;:,;rhS393S55hh11hh5S3393Shr:,:;;;iirr:              
            .;rriii;;;::,:;is1h555555h1si;:,::;;;iirri:.               
              .:irrrii;;;;;:::,,,,,,,,:::;;;;iiirrr;,                  
                 .:irrrriiiiii;;;;;;;;iiiiiirrrr;,.                    
                    .,:;iirrrrrrrrrrrrrrrrri;:.                        
                         ..,:::;;;;:::,,.                             
]]--
local PhoneBind = class("PhoneBind", nk.ui.Panel)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local POP_WIDTH = 580
local POP_HEIGHT = 386

function PhoneBind:ctor()
	PhoneBind.super.ctor(self,{POP_WIDTH, POP_HEIGHT})

	display.addSpriteFrames("BindPhone.plist", "BindPhone.png")
	self.layerout = display.newNode():pos(0,0):addTo(self)
    self:getBindInfo()
    --self:onStart()

	self:addCloseBtn()
    self:setNodeEventEnabled(true)

end
--启动调度器
function PhoneBind:onStart()
    -- body
    --[[self.timer = scheduler.scheduleGlobal(function()
        -- body
        self:onTimer()
    end, 1.0)]]--
    self.timer = scheduler.scheduleGlobal(function()
            self:onTimer()
        end,1.0)
end
--调度器执行函数
function PhoneBind:onTimer()
    self.waitTime = self.waitTime - 1
    self.waitTimeLabel:setString(self.waitTime.."S")

    if self.waitTime == 0 then
        self.waitTimeLabel:setVisible(false)
        self.keyButton:setVisible(true)
        self:onEnd()
        return
    end
    print(self.waitTime)
end
--关闭调度器
function PhoneBind:onEnd()
    -- body
    scheduler.unscheduleGlobal(self.timer)
end

--请求绑定信息
function PhoneBind:getBindInfo()
    local retryTimes = 3

    local getInofo = function()
        -- body
        bm.HttpService.POST(
        {
            mod = "Phone" ,
            act = "isBound"
         },
        function (data)
            local callData = json.decode(data)
            if callData then 
                if callData.code == 0 then
                    self:noBindView()--未绑定显示绑定界面
                elseif callData.code == 1 then
                    self:isBindView()--绑定显示去官网界面
                end
            end
        end,
        function (data)
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                getInofo()
            end
        end
        )
    end
    
    getInofo()
end

--获取验证码按钮回调
function PhoneBind:OnGetKey()
    local retryTimes = 3

    self:setLoading(true)
    local getInofo = function()
        bm.HttpService.POST(
            {
                mod = "Phone" ,
                act = "getVerifyCode",
                phone = self.phoneNumberEdit:getText()
            },
            function (data)
                local callData = json.decode(data)
                self:setLoading(false)
                if callData then
                    nk.TopTipManager:showTopTip(callData.codemsg)
                    self:onWait(callData.data.wait)
                else
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        getInofo()
                    end
                end
            end,
            function (data)
                retryTimes = retryTimes - 1
                if retryTimes > 0 then
                    getInofo()
                end
            end
        )
    end

    if(self.phoneNumberEdit:getText() == "" or self.phoneNumberEdit:getText() == nil) then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "NULLPHONE"))
    else
        if self.timer then
            self:onEnd()
        end
        getInofo()
    end   
end

function PhoneBind:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
                :pos(0, 0)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function PhoneBind:onWait(needTime)
    -- body
    self.waitTime = needTime
    self:onStart()
    self.waitTimeLabel:setString(needTime.."S")
    self.keyButton:setVisible(false)
    self.waitTimeLabel:setVisible(true)
end

--绑定手机按钮回调
function PhoneBind:OnBindPhone()
    local retryTimes = 3

    local getInofo = function()
	    bm.HttpService.POST(
            {
                mod = "Phone",
                act = "bound",
                code = self.keyNumberEdit:getText(),
                phone = self.phoneNumberEdit:getText()
            },
            function (data)
                local callData = json.decode(data)
                if callData.code == 1 then
                    if self.timer then
                        self:onEnd()
                    end
            	    self:isBindView()
					
                    scheduler.performWithDelayGlobal(function()
                            -- body
                            local str = ""
                            str = bm.LangUtil.getText("DAILY_TASK", "CHIP_REWARD", callData.data.money)
                            nk.TopTipManager:showTopTip(str)
                            self:playBoxRewardAnimation(callData)
                        end, 1.0)
                elseif callData.code == -2 or callData.code == -1 or callData.code == 0 or callData.code == -3 then
            	    nk.TopTipManager:showTopTip(callData.codemsg)
                else
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        getInofo()
                    end
                end
            end,
            function (data)
        	    retryTimes = retryTimes - 1
                if retryTimes > 0 then
                    getInofo()
                end
            end
        )
    end

    if (self.phoneNumberEdit:getText() == "" or self.phoneNumberEdit:getText() == nil) then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "NULLPHONE"))
    elseif (self.keyNumberEdit:getText() == "" or self.keyNumberEdit:getText() == nil) then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "NULLKEY"))
    else
        self.nowPhoneNumber = self.phoneNumberEdit:getText()
        getInofo()
    end

end

function PhoneBind:playBoxRewardAnimation(callData)
    local rewards = {};
    local info;
    if callData.data.money and callData.data.money ~= 0 then 
        info={};
        info.type = 1;
        info.icon = "match_chip.png"
        info.txt = bm.LangUtil.getText("MATCH", "MONEY").." + "..tostring(callData.data.money)
        info.num = bm.formatBigNumber(callData.data.money);
        info.val = callData.data.money;
        table.insert(rewards, #info+1, info)
    end

    if #rewards > 0 then
        nk.UserInfoChangeManager:playBoxRewardAnimation(nk.UserInfoChangeManager.MainHall, rewards, true)
    end
end

--统一管理短线重连和消息发送，此方法可读性太低，且圈复杂度太高，执行效率额低下
--[[function PhoneBind:SendMessage(FunType)
    local params = {
        [1] = {
                mod = "Phone" ,
                act = "isBound"
            }
        ,
        [2] = {
                mod = "Phone" ,
                act = "getVerifyCode",
                phone = self.phoneNumberEdit:getText()
            },
        [3] = {
                mod = "Phone",
                act = "bound",
                code = self.keyNumberEdit:getText(),
                phone = self.phoneNumberEdit:getText()
            }
    }

    local retryTimes = 3

    --失败重连
    local retry = function()
        retryTimes = retryTimes - 1 --请求失败后， 重试次数，3次以后还失败，就关闭绑定手机界面
        if retryTimes > 0 then
            getInofo()
        end
    end

    local getInofo = function()
        bm.HttpService.POST(
            params[FunType],

            function (data)
                local callData = json.decode(data)

                if callData then
                    if FunType == 1 then
                        if callData.code == 0 then
                            print("未绑定显示绑定界面")
                            self:noBindView()--未绑定显示绑定界面
                        elseif callData.code == 1 then
                        self:isBindView()--绑定显示去官网界面
                        else
                            retry()
                        end
                    elseif FunType == 2 then
                        if callData.code == 1  or callData.code == -2 or callData.code == -1 then
                            nk.TopTipManager:showTopTip(callData.codemsg)
                        else
                            retry()
                        end
                    elseif FunType == 3 then
                        if callData.code == 1 then
                            self:isBindView()
                        elseif callData.code == -2 or callData.code == -1 or callData.code == 0 then
                            nk.TopTipManager:showTopTip(callData.codemsg)
                        else
                            retry()
                        end
                    else 

                    end 
                else
                    retry()
                end

            end,

            function (data)
               retry()
            end
        )
    end

    getInofo()
end]]--

--绑定界面
function PhoneBind:isBindView()
	-- body
	self.layerout:removeAllChildren()

    --设置标题
    self.titleText = display.newSprite("#bind_success.png")
        :pos(0,150)
        :addTo(self.layerout)

    self.label = ui.newTTFLabel({
                text  = "",
                color = cc.c3b(0xff, 0xff, 0xff),
                size  = 24,
                align = ui.TEXT_ALIGN_CENTER
            })
            :pos(0,0)
            :addTo(self.layerout)

    self.label:setDimensions(500,0)
    self.label:setString(bm.LangUtil.getText("COMMON", "BINDFHONE"))

    local goto = cc.ui.UIPushButton.new(
		{normal= "#common_btn_green_normal.png", 
		pressed = "#common_btn_green_pressed.png"},
		{scale9 = true})
		:setButtonSize(160, 52)
		:pos(0,-120)
		:onButtonClicked(buttontHandler(self, self.OnGoto))
		:addTo(self.layerout)
	display.newSprite("#bind_goto.png")
		:setAnchorPoint(cc.p(0.5, 0.5))
		:pos(0,5)
		:addTo(goto)
end

--未绑定界面
function PhoneBind:noBindView()
    self.layerout:removeAllChildren()
    --设置标题
    self.titleText = display.newSprite("#bind_title.png")
        :pos(0,150)
        :addTo(self.layerout)
    self.phoneText = display.newSprite("#bind_text_phone.png")
        :setAnchorPoint(cc.p(0, 0.5))
        :pos(-250,90)
        :addTo(self.layerout)
    self.keyText = display.newSprite("#bind_text_key.png")
        :setAnchorPoint(cc.p(0, 0.5))
        :pos(-250,25)
        :addTo(self.layerout)

    --设置号码输入框
    self.phoneNumberEdit = ui.newEditBox({
            size = cc.size(360, 54),
            image = "#common_input_bg.png",
            imagePressed = "#common_input_bg_down.png",
            listener = function(event, editbox)
                if event == "changed" or event == "ended" or event == "return" then
                    self:OnChanged()
                end
            end
        })
        :setFont(ui.DEFAULT_TTF_FONT, 24)
        :setPlaceholderFont(ui.DEFAULT_TTF_FONT, 22)
        :setMaxLength(25)
        :setPlaceholderFontColor(cc.c3b(0x7a, 0x7e, 0xca))
        :setAnchorPoint(cc.p(0, 0.5))
        :setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :pos(-110, 90)
        :addTo(self.layerout)

    --设置验证码输入框
    self.keyNumberEdit = ui.newEditBox({
            size = cc.size(185, 54),
            image = "#common_input_bg.png",
            imagePressed="#common_input_bg_down.png",
        })
        :setFont(ui.DEFAULT_TTF_FONT, 24)
        :setPlaceholderFont(ui.DEFAULT_TTF_FONT, 22)
        :setMaxLength(25)
        :setPlaceholderFontColor(cc.c3b(0x7a, 0x7e, 0xca))
        :setAnchorPoint(cc.p(0, 0.5))
        :setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :pos(-110, 25)
        :addTo(self.layerout)

    --设置获取验证码按钮
    self.keyButton = cc.ui.UIPushButton.new(
        {normal= "#bind_getkey.png", 
        pressed = "#bind_getkey.png"})
        :setButtonSize(170, 26)
        :pos(180,25)
        :onButtonClicked(buttontHandler(self, self.OnGetKey))
        :addTo(self.layerout)
    --设置等待时间提示
    self.waitTimeLabel = ui.newTTFLabel({
                text  = "",
                color = cc.c3b(0xff, 0xff, 0xff),
                size  = 24,
                align = ui.TEXT_ALIGN_CENTER
            })
            :pos(180,25)
            :addTo(self.layerout)
    self.waitTimeLabel:setVisible(false)

    --设置描述文本
    self.desTextLabel = ui.newTTFLabel({
                text  = bm.LangUtil.getText("COMMON", "DESSHOP"),
                color = cc.c3b(0xff, 0xff, 0xff),
                size  = 24,
                align = ui.TEXT_ALIGN_CENTER
            })
            :pos(0,-60)
            :addTo(self.layerout)
    self.desTextLabel:setDimensions(500,0)

    --设置绑定按钮
    self.bindButton = cc.ui.UIPushButton.new(
        {normal= "#common_btn_green_normal.png", 
        pressed = "#common_btn_green_pressed.png"},
        {scale9 = true})
        :setButtonSize(160, 52)
        :pos(0,-140)
        :onButtonClicked(buttontHandler(self, self.OnBindPhone))
        :addTo(self.layerout)
    self.bindButtonText = display.newSprite("#bind_ok.png")
        :setAnchorPoint(cc.p(0.5, 0.5))
        :pos(0,5)
        :addTo(self.bindButton)


end

--去官网
function PhoneBind:OnGoto()
	-- body
    device.openURL("http://th.boyaa.com/")
end

--输入框改变
function PhoneBind:OnChanged()
    -- body
    if self.nowPhoneNumber ~= self.phoneNumberEdit:getText() then
        self.keyButton:setVisible(true)
        self.waitTimeLabel:setVisible(false)
        if self.timer then
            self:onEnd()
        end
    end
end

function PhoneBind:show()
    nk.PopupManager:addPopup(self)
    return self
end

function PhoneBind:close()
    if self.timer then
        self:onEnd()
    end

	display.removeSpriteFramesWithFile("BindPhone.plist", "BindPhone.png")
    nk.PopupManager:removePopup(self)
    return self
end

function PhoneBind:onClose()
    self:close()
end

return PhoneBind