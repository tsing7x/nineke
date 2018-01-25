--
-- Author: zhangyibc@outlook.com
-- Date: 2018-1-12 17:45
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

local ActivityTitle = class("ActivityTitle", nk.ui.Panel)

local POP_WIDTH = 870
local POP_HEIGHT = 579

function ActivityTitle:ctor(image,text)
  ActivityTitle.super.ctor(self,{POP_WIDTH, POP_HEIGHT})
  display.addSpriteFrames("BindPhone.plist", "BindPhone.png")

  self.layerout = display.newNode():pos(0,0):addTo(self)

  self:addCloseBtn()
  self:setNodeEventEnabled(true)

  self.imageSource = image
  self.textDes = text

  self:setView()
end

function ActivityTitle:setView()
  --设置标题
  self.titleText = display.newSprite("#bind_title.png")
    :pos(0,250)
    :addTo(self.layerout)

  --设置描述图片
  self.imgDes = display.newSprite("football_quiz_button.png"):pos(0,80):addTo(self.layerout)
  dump(self.imgDes:getContentSize())
  self.imgDes:setScaleX(POP_WIDTH/self.imgDes:getContentSize().width)
  self.imgDes:setScaleY(250/self.imgDes:getContentSize().height)

  --设置描述文本
  self.desTextLabel = ui.newTTFLabel({
              text  = "12345678987654321\n123223422\n1135356",
              color = cc.c3b(0xff, 0xff, 0xff),
              size  = 24,
              align = ui.TEXT_ALIGN_CENTER
          })
          :pos(0,-130)
          :addTo(self.layerout)
  self.desTextLabel:setDimensions(500,0)

  --设置前往按钮
  self.bindButton = cc.ui.UIPushButton.new(
      {normal= "#common_btn_green_normal.png", 
      pressed = "#common_btn_green_pressed.png"},
      {scale9 = true})
      :setButtonSize(160, 52)
      :pos(0,-230)
      :onButtonClicked(buttontHandler(self, self.gotoActivityCenter))
      :addTo(self.layerout)
  self.bindButtonText = display.newSprite("#bind_ok.png")
      :setAnchorPoint(cc.p(0.5, 0.5))
      :pos(0,5)
      :addTo(self.bindButton)
end

function ActivityTitle:show()
  nk.PopupManager:addPopup(self)
  return self
end

--打开活动中心
function ActivityTitle:gotoActivityCenter()
  self:onClose()
  bm.EventCenter:dispatchEvent({name = "onGotoActivityCenterEvent", data = nil})
end

function ActivityTitle:close()
  display.removeSpriteFramesWithFile("BindPhone.plist", "BindPhone.png")
  nk.PopupManager:removePopup(self)
  return self
end

function ActivityTitle:onClose()
  self:close()
end

return ActivityTitle