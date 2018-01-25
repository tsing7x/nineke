--
-- Author: zhangyibc@outlook.com
-- Date: 2017-12-22 10:59
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
local OpenURL = class("OpenURL", nk.ui.Panel)
local NavigationBarHeight = 60
local intervalWidth = display.width/8

--local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function OpenURL:ctor(URL)
    display.addSpriteFrames("WebView.plist", "WebView.png")
    self.layerout = display.newNode()
        :pos(0, 0)
        :addTo(self)
    --进入输入网址的界面（用于测试）
    self:onInput()
    --直接打开网页
    --self:onWebView(URL)
end

function OpenURL:onWebView(URL)
    self.layerout:removeAllChildren()
    self:setUpWebView(URL)
    self:setUpNavigationBar()
end

function OpenURL:onInput()
    self.layerout:removeAllChildren()
    self:setUpInputView()
end

function OpenURL:setUpInputView()
    self.layerout:removeAllChildren()
    --网址输入框
    self.addressEdit = ui.newEditBox({
            size = cc.size(360, 54),
            image = "#common_input_bg.png",
            imagePressed = "#common_input_bg_down.png"
        })
        :setFont(ui.DEFAULT_TTF_FONT, 24)
        :setPlaceholderFont(ui.DEFAULT_TTF_FONT, 22)
        :setMaxLength(25)
        :setPlaceholderFontColor(cc.c3b(0x7a, 0x7e, 0xca))
        :setAnchorPoint(cc.p(0, 0.5))
        :setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        :setInputMode(cc.EDITBOX_INPUT_MODE_URL)
        :pos(-110, 90)
        :addTo(self.layerout)
    --进入按钮
    --设置绑定按钮
    self.gotoButton = cc.ui.UIPushButton.new(
        {normal= "#common_btn_green_normal.png", 
        pressed = "#common_btn_green_pressed.png"},
        {scale9 = true})
        :setButtonSize(160, 52)
        :pos(0,-140)
        :onButtonClicked(buttontHandler(self, self.OnGotoButton))
        :addTo(self.layerout)
end

--跳转到制定网页
function OpenURL:OnGotoButton()
    if self.addressEdit:getText() ~= "" or self.addressEdit:getText() ~= nil then
        print(self.addressEdit:getText())
        self:onWebView("http://"..self.addressEdit:getText())
    end
end

function OpenURL:setUpWebView(URL)
    --创建浏览器窗口
    if ccexp.WebView then
        self.actWebView_ = ccexp.WebView:create()
        self.layerout:addChild(self.actWebView_)
        self.actWebView_:setVisible(true)
        self.actWebView_:setScalesPageToFit(true)
        self.actWebView_:loadURL(URL)
        self.actWebView_:setContentSize(cc.size(display.width,display.height - NavigationBarHeight))
        self.actWebView_:setPosition(0,NavigationBarHeight)
        self.actWebView_:reload()
    else
        dump("ccexp.WebView Module Not Export!")
    end    
end

function OpenURL:setUpNavigationBar()
    --导航栏容器
    self.NavigationBarLayerout = display.newNode()
        :pos(-display.width/2, -display.height/2 + 30)
        :addTo(self.layerout)
    --导航栏背景
    self.NavigationBar = cc.ui.UIPushButton.new(
        {normal= "#WebView_bg.png", 
        pressed = "#WebView_bg.png"})
        :setButtonSize(display.width, 100)
        :pos(display.width/2,20)
        :addTo(self.NavigationBarLayerout)
    --后退按钮
    self.backButton = cc.ui.UIPushButton.new(
        {normal = "#WebView_defback.png", pressed="#WebView_back.png"})
        :setButtonSize(60, 60)
        :pos(intervalWidth * 1, NavigationBarHeight/2 - 15)
        :onButtonClicked(buttontHandler(self, self.onBackButton))
        :addTo(self.NavigationBarLayerout)
    --前进按钮
    self.gotoButton = cc.ui.UIPushButton.new(
        {normal = "#WebView_defgoto.png", pressed="#WebView_goto.png"})
        :setButtonSize(60, 60)
        :pos(intervalWidth * 3, NavigationBarHeight/2 - 15)
        :onButtonClicked(buttontHandler(self, self.onGotoButton))
        :addTo(self.NavigationBarLayerout)
    --刷新按钮
    self.refushButton = cc.ui.UIPushButton.new(
        {normal = "#WebView_defrefush.png", pressed="#WebView_refush.png"})
        :setButtonSize(60, 60)
        :pos(intervalWidth * 5, NavigationBarHeight/2 - 15)
        :onButtonClicked(buttontHandler(self, self.onRefushButton))
        :addTo(self.NavigationBarLayerout)
    --关闭按钮
    self.closeButton = cc.ui.UIPushButton.new(
        {normal = "#WebView_defclose.png", pressed="#WebView_close.png"})
        :setButtonSize(60, 60)
        :pos(intervalWidth * 7, NavigationBarHeight/2 - 15)
        :onButtonClicked(buttontHandler(self, self.onCloseButton))
        :addTo(self.NavigationBarLayerout)
end
--后退按钮
function OpenURL:onBackButton()
    if self.actWebView_:canGoBack() then
        self.actWebView_:goBack()
    end
end
--前进按钮
function OpenURL:onGotoButton()
    if self.actWebView_:canGoForward() then
        self.actWebView_:goForward()
    end   
end
--刷新按钮
function OpenURL:onRefushButton()
    self.actWebView_:reload()
end
--关闭按钮
function OpenURL:onCloseButton()
    self:close()
end

function OpenURL:show()
    nk.PopupManager:addPopup(self)
    return self
end

function OpenURL:close()
    display.removeSpriteFramesWithFile("WebView.plist", "WebView.png")
    nk.PopupManager:removePopup(self)
    return self
end

function OpenURL:onClose()
    self:close()
end

return OpenURL