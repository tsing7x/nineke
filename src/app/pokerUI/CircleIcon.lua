--
-- Author: Jonah0608@gmail.com
-- Date: 2016-08-31 15:26:17
--
local CircleIcon = class("CircleIcon",function()
    return display.newNode()
end)

function CircleIcon:ctor()
    self:setNodeEventEnabled(true)
    self.width_ = 84
    self.height_ = 84
    self.avatarBg_ = display.newSprite("#circle_icon_bg.png"):addTo(self)
    self.clipNode_ = cc.ClippingNode:create()
        :pos(0, 0)
        :addTo(self)
    local stencil = self:getStencil(41)
    self.clipNode_:setStencil(stencil)
    self.avatar_ = display.newSprite("#circle_icon_default.png")
        :pos(0, 0)
        :addTo(self.clipNode_)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
end

function CircleIcon:getStencil(radius)
    local circleNode = cc.DrawNode:create()
    local maxTrangle = 360
    local circleVec = {}
    for i = 0,maxTrangle,11 do
        local x = math.cos(i * (math.pi / 180)) * radius
        local y = math.sin(i * (math.pi / 180)) * radius
        table.insert(circleVec,{x,y})
    end
    local circleColor = cc.c4f(0,1,0,1)
    circleNode:drawPolygon(circleVec)
    return circleNode
end

function CircleIcon:resetToDefault()
    self:setSpriteFrame("circle_icon_default.png")
end

function CircleIcon:setSpriteFrame(resId)
    self.avatar_:setSpriteFrame(display.newSpriteFrame(resId))
  self:refreshAvatarIcon()
end

function CircleIcon:refreshAvatarIcon()
  if self.avatar_ then
    local sz = self.avatar_:getContentSize();
    local xscale, yscale = (self.width_ + 0)/sz.width, (self.height_ + 0)/sz.height;
    self.avatar_:setScale(math.min(xscale, yscale))
  end
end

function CircleIcon:setSex(sexStr)
  if not sexStr or string.len(sexStr) < 1 then
    sexStr = "m"
  end

  if sexStr == "f" then
      self:setSpriteFrame("common_female_avatar.png")
  else
      self:setSpriteFrame("common_male_avatar.png")
  end
end

function CircleIcon:setSexAndImgUrl(sexStr, imgUrl)
  if not imgUrl or string.len(imgUrl) <= 5 then
      self:setSex(sexStr)
  else
      self:setSex(sexStr)
      if string.find(imgUrl, "facebook") then
          if string.find(imgUrl, "?") then
              imgUrl = imgUrl .. "&width=200&height=200"
          else
              imgUrl = imgUrl .. "?width=200&height=200"
          end
      end
      self:loadImage(imgUrl)
  end 
end

function CircleIcon:loadImage(imgUrl)
    nk.ImageLoader:loadAndCacheImage(
        self.userAvatarLoaderId_,
        imgUrl,
        handler(self, self.onAvatarLoadComplete_),
        nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
    )
end
-- 
function CircleIcon:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture();
        local texSize = tex:getContentSize();
        if self.avatar_ then
          self.avatar_:setTexture(tex)
          self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height));
          self.avatar_:setScaleX(self.width_/texSize.width);
          self.avatar_:setScaleY(self.height_/texSize.height);
        end
    end
end

function CircleIcon:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

return CircleIcon