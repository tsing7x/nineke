--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-01-07 12:29:15
--
local AvatarIcon = class("AvatarIcon", function()
	return display.newNode("AvatarIcon")
end)

local BG_SIZE_W = 90
local BG_SIZE_H = 88

function AvatarIcon:ctor(defaultResID, width, height, radius, bgParasms, itype, offVal, isSelf)
  self:setNodeEventEnabled(true)
  self.bgParasms_ = bgParasms
	self.defaultResID_ = defaultResID or "#transparent.png"
	self.width_ = width or 100
	self.height_ = height or 100
	self.radius_ = radius or 4
  self.offVal_ = offVal or 6
  self.isSelf_ = isSelf or 1
  self.borderRes_ = nil

  if bgParasms and bgParasms.borderRes then
    self.borderRes_ = bgParasms.borderRes
  end

	if self.bgParasms_ then
		self.avatarBg_ = display.newScale9Sprite(self.bgParasms_.resId or "#transparent.png", 0, 0, self.bgParasms_.size or cc.size(self.width_, self.height_))
			:addTo(self)
	end

	self.clipNode_ = cc.ClippingNode:create()
		:pos(0, 0)
		:addTo(self)

  self.type_ = itype or 1
  if self.type_ == 1 then
    	local stencil = display.newDrawNode()
    	self:drawNodeRoundRect_(stencil, cc.rect(-self.width_*0.5, self.height_*0.5, self.width_, self.height_), 1, self.radius_)
    	self.clipNode_:setStencil(stencil)
  elseif self.type_ == 2 then
      local stencil = display.newScale9Sprite("#transparent.png", 0, 0, cc.size(self.width_-2, self.height_-2))
      self.clipNode_:setStencil(stencil)
      -- self.clipNode_:setAlphaThreshold(0) -- 设置绘制底板的Alpha值为0
      -- self.clipNode_:setInverted(true) -- 设置底板可见
  end

	-- 默认头像
	self.avatar_ = display.newSprite(defaultResID or "#transparent.png")
    :pos(0, 0)
    :addTo(self.clipNode_)

  self:refreshAvatarIcon()

  if self.isSelf_ == 1 then
    self:renderVIP()
  end

	self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
end

--新版VIP，边框
function AvatarIcon:renderGoldBorder_()
  if self.laceSpr_ then
    self.laceSpr_:removeFromParent()
    self.laceSpr_ = nil
  end

  local resId = self.borderRes_ or "#avatar_icon_bg.png"
  local offw = 4
  local dws = self.width_+ offw
  local dhs = self.height_+ offw

  self.laceSpr_ = display.newScale9Sprite(resId, 0, 0, cc.size(dws, dhs))
    :addTo(self, 1)   
end

-- 老版区分是否为VIP，暂时保留
-- function AvatarIcon:renderGoldBorder_(isVip)
--   if self.laceSpr_ then
--     self.laceSpr_:removeFromParent()
--     self.laceSpr_ = nil
--   end

--   local resId
--   if isVip then
--     resId = self.borderRes_ or "#pop_vip_icon_level_bg.png"
--   else
--     resId = self.borderRes_ or "#pop_vip_icon_level_bgGray.png"
--   end

--   local dws = self.width_+ self.offVal_
--   local dhs = self.height_+ self.offVal_
--   if dws < BG_SIZE_W or dhs < BG_SIZE_H then
--     self.laceSpr_ = display.newSprite(resId)
--       :pos(0, 0)
--       :addTo(self, 1)
--     self.laceSpr_:setScaleX(dws / BG_SIZE_W)
--     self.laceSpr_:setScaleY(dhs / BG_SIZE_H)
--   else
--     self.laceSpr_ = display.newScale9Sprite(resId, 0, 0, cc.size(dws, dhs))
--       :pos(0, 0)
--       :addTo(self, 1)
--   end
-- end

--刷新其他玩家VIP显示
function AvatarIcon:renderOtherVIP(vipLevel)
  if vipLevel and vipLevel > 0 then
      if self.vipIcon_ then
        self.vipIcon_:setSpriteFrame(display.newSpriteFrame("pop_vip_icon_level_" .. vipLevel .. ".png"))
      else
        local px, py = self.width_ * 0.5, self.height_ * 0.5
        local s = self:getVipIconScale_(vipLevel)
        self.vipIcon_ = display.newSprite("#pop_vip_icon_level_" .. vipLevel .. ".png")
          :pos(px, py)
          :scale(s)
          :addTo(self, 2)
      end
      self:renderGoldBorder_(true)
      if self.vipIcon_ then
        self.vipIcon_:show()
      end
  else
      if self.vipIcon_ then
        self.vipIcon_:removeFromParent()
        self.vipIcon_ = nil
      end
      -- 灰色处理边框
      self:renderGoldBorder_(false)
  end
end

-- function AvatarIcon:renderVIP()
--   local vipconfig = nk.OnOff:getConfig('vipmsg')
--   if vipconfig and vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light and vipconfig.vip.light == 1 then
--       if self.vipIcon_ then
--         self.vipIcon_:setSpriteFrame(display.newSpriteFrame("pop_vip_icon_level_" .. vipconfig.vip.level .. ".png"))
--       else
--         local px, py = self.width_ * 0.5 - 0, self.height_ * 0.5 - 0
--         self.vipIcon_ = display.newSprite("#pop_vip_icon_level_" .. vipconfig.vip.level .. ".png")
--           :pos(px, py)
--           :addTo(self, 2)
--       end
--       self:renderGoldBorder_(true)
--       self.vipIcon_:show()
--   else
--       if self.vipIcon_ then
--         self.vipIcon_:removeFromParent()
--         self.vipIcon_ = nil
--       end
--       -- 灰色处理边框
--       self:renderGoldBorder_(false)
--   end
-- end

--yk 刷新自己VIP显示
function AvatarIcon:renderVIP()
  local isVip, vipconfig = self:checkIsVip_()
  if isVip then--yk
      local img ="pop_vip_icon_level_" .. vipconfig.vip.level .. ".png"
      if self.vipIcon_ then
        self.vipIcon_:setSpriteFrame(display.newSpriteFrame(img))
      else
        local px, py = self.width_ * 0.5, self.height_ * 0.5
        local s = self:getVipIconScale_(vipconfig.vip.level)
        self.vipIcon_ = display.newSprite("#" .. img)
          :pos(px, py)
          :scale(s)
          :addTo(self, 2)
      end

      self:renderGoldBorder_(true)
      self.vipIcon_:show()
  else
      if self.vipIcon_ then
        self.vipIcon_:removeFromParent()
        self.vipIcon_ = nil
      end
      -- 灰色处理边框
      self:renderGoldBorder_(false)
  end
end

--yk
function AvatarIcon:checkIsVip_()
    local isVip = false
    local config
    local vipconfig = nk.OnOff:getConfig('vipmsg')
    local vipconfig_2 = nk.OnOff:getConfig('newvipmsg')

    if vipconfig_2 and vipconfig_2.newvip == 1 then
      isVip = true
      config = vipconfig_2
    else
      if vipconfig and vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light and vipconfig.vip.light == 1 then
        isVip = true
        config = vipconfig
      else
        config = vipconfig_2
      end
    end

    return isVip, config
end

--兼容老版icon缩放系数
function AvatarIcon:getVipIconScale_(level)
  local s = 1.0
  if tonumber(level) >= 7 then --大于7，新版VIP
    s = 0.7
  end

  return s
end

-- 设置显示帧
function AvatarIcon:setSpriteFrame(resId)
	self.avatar_:setSpriteFrame(display.newSpriteFrame(resId))
  self:refreshAvatarIcon()
end
-- 
function AvatarIcon:loadImage(imgUrl)
	nk.ImageLoader:loadAndCacheImage(
		self.userAvatarLoaderId_,
		imgUrl,
		handler(self, self.onAvatarLoadComplete_),
		nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
	)
end
-- 
function AvatarIcon:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(self.width_/texSize.width)
        self.avatar_:setScaleY(self.height_/texSize.height)
    end
end

-- 传入DrawNode对象，画圆角矩形
function AvatarIcon:drawNodeRoundRect_(drawNode, rect, borderWidth, radius, color, fillColor)
  -- segments表示圆角的精细度，值越大越精细
  color = color or cc.c4f(0.1, 1, 0.1, 0.0)
  fillColor = fillColor or cc.c4f(0.1, 1, 0.1, 0.0)
  local segments    = 100
  local origin      = cc.p(rect.x, rect.y)
  local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
  local points      = {}

  -- 算出1/4圆
  local coef     = math.pi / 2 / segments
  local vertices = {}

  for i=0, segments do
    local rads = (segments - i) * coef
    local x    = radius * math.sin(rads)
    local y    = radius * math.cos(rads)

    table.insert(vertices, cc.p(x, y))
  end

  local tagCenter      = cc.p(0, 0)
  local minX           = math.min(origin.x, destination.x)
  local maxX           = math.max(origin.x, destination.x)
  local minY           = math.min(origin.y, destination.y)
  local maxY           = math.max(origin.y, destination.y)
  local dwPolygonPtMax = (segments + 1) * 4
  local pPolygonPtArr  = {}

  -- 左上角
  tagCenter.x = minX + radius
  tagCenter.y = maxY - radius

  for i=0, segments do
    local x = tagCenter.x - vertices[i + 1].x
    local y = tagCenter.y + vertices[i + 1].y

    -- table.insert(pPolygonPtArr, cc.p(x, y))
    table.insert(pPolygonPtArr, {x, y})
  end

  -- 右上角
  tagCenter.x = maxX - radius
  tagCenter.y = maxY - radius

  for i=0, segments do
    local x = tagCenter.x + vertices[#vertices - i].x
    local y = tagCenter.y + vertices[#vertices - i].y

    table.insert(pPolygonPtArr, {x, y})
  end

  -- 右下角
  tagCenter.x = maxX - radius
  tagCenter.y = minY + radius

  for i=0, segments do
    local x = tagCenter.x + vertices[i + 1].x
    local y = tagCenter.y - vertices[i + 1].y

    table.insert(pPolygonPtArr, {x, y})
  end

  -- 左下角
  tagCenter.x = minX + radius
  tagCenter.y = minY + radius

  for i=0, segments do
    local x = tagCenter.x - vertices[#vertices - i].x
    local y = tagCenter.y - vertices[#vertices - i].y

    table.insert(pPolygonPtArr, {x, y})
  end

  if fillColor == nil then
    fillColor = cc.c4f(0, 0, 0, 0)
  end

  drawNode:drawPolygon(pPolygonPtArr, fillColor, #pPolygonPtArr, color)
end
-- 设置性别
function AvatarIcon:setSex(sexStr)
  if not sexStr or string.len(sexStr) < 1 then
    return 
  end

  if sexStr == "f" then
      self:setSpriteFrame("common_female_avatar.png")
  else
      self:setSpriteFrame("common_male_avatar.png")
  end
end
-- 设置性别和头像
function AvatarIcon:setSexAndImgUrl(sexStr, imgUrl)
  self:setSex("m")
  if not imgUrl or string.len(imgUrl) <= 5 then
      self:setSex(sexStr)
  else
      self:loadImage(imgUrl)
  end 
end

function AvatarIcon:refreshAvatarIcon()
  if self.avatar_ then
    local sz = self.avatar_:getContentSize()
    local xscale, yscale = (self.width_ + 0)/sz.width, (self.height_ + 0)/sz.height
    self.avatar_:setScale(math.min(xscale, yscale))
  end
end

function AvatarIcon:onCleanup()
  if self.userAvatarLoaderId_ then
	   nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
     self.userAvatarLoaderId_ = nil
  end
end

return AvatarIcon