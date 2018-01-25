--
-- Author: tony
-- Maintainer: DavidFeng
-- Date: 2014-08-01 16:31:47
--
-- change log:
-- 0. Tony 实现了背景, 关闭按钮, 模态窗口(输入,show/hide)等基础功能
-- 1. David 自定义panel位置 (work in progress)
--
--      TODO: 此display.lua中的api有问题,居然不处理sprite frame,需要修改之
--      所以boomegg把repeat下的贴图直接放到了res/下
--      newTilesSprite "repeat/panel_repeat_tex.png",

local Panel = class("Panel", function()
    return display.newNode()
end)

Panel.SIZE_SMALL = {}
Panel.SIZE_NORMAL = {750, 480}
Panel.SIZE_LARGE = {}

local PANEL_CLOSE_BTN_Z_ORDER = 99

function Panel:ctor(args)
    self.width_, self.height_= args[1], args[2]
    self.fontSize_ = args.fontSize or 24;

    local px, py
    if type(args.x) == 'number' and type(args.y) == 'number' then
        px, py = args.x, args.y
        self.close_x_ = px + self.width_ - 45
        self.close_y_ = py + self.height_ - 45
    else
        px, py = -(self.width_ - 3) * 0.5, -(self.height_ - 3) * 0.5
        self.close_x_ = self.width_ * 0.5 - 45
        self.close_y_ = self.height_ * 0.5 - 40
    end

    self.background_ = display.newScale9Sprite("#pop_common_bg.png", 0, 0, cc.size(self.width_, self.height_), cc.rect(60, 70, 1, 1)):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    self.backgroundTex_ = display.newTilesSprite(
            "repeat/panel_repeat_tex.png",
            cc.rect(0, 0, self.width_ - 3, self.height_ - 3))
        :pos(px, py)
        :addTo(self)

    self:addDecoration()

    display.newSprite("#pop_common_decoration1.png"):addTo(self.background_)
        :align(display.TOP_RIGHT, self.width_ * 0.5 + 2, self.height_ - 6)

    local title_bg2_ = display.newSprite("#pop_common_decoration1.png"):addTo(self.background_)
        :align(display.TOP_RIGHT, self.width_ * 0.5 + 2, self.height_ - 6)

    title_bg2_:setScaleX(-1)
end

--修改背景
function Panel:setBackgroundStyle1()
    self.background_:removeFromParent()
    self.background_ = display.newScale9Sprite(
            "#common_transparent_skin.png",
            0, 0, cc.size(self.width_, self.height_))
        :addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    display.newScale9Sprite(
            "#pop_common2_bg.png",
            self.width_ * 0.25 + 2, self.height_ * 0.5, cc.size(self.width_ * 0.5 + 4, self.height_),
            cc.rect(240, 150, 1, 1))
        :addTo(self.background_)

    local background2_ = display.newScale9Sprite(
            "#pop_common2_bg.png",
            self.width_ * 0.75 - 2, self.height_ * 0.5, cc.size(self.width_ * 0.5 + 4, self.height_),
            cc.rect(240, 150, 1, 1))
        :addTo(self.background_)
    background2_:setScaleX(-1)

    self:addDecoration()

    display.newSprite("#pop_common2_decoration1.png"):addTo(self.background_)
            :align(display.TOP_RIGHT, self.width_ * 0.5 + 2, self.height_ - 6)

    local title_bg2_ = display.newSprite("#pop_common2_decoration1.png"):addTo(self.background_)
            :align(display.TOP_RIGHT, self.width_ * 0.5 + 2, self.height_ - 6)

    title_bg2_:setScaleX(-1)
    
    --添加左上角的发光
    local de1 = display.newSprite("#pop_common2_decoration2.png"):addTo(self)
        :align(display.TOP_LEFT, -self.width_ * 0.5 + 6, self.height_ * 0.5 - 24)
end

function Panel:addDecoration()
    display.newSprite("#pop_common2_decoration3.png"):addTo(self.background_)
        :pos(self.width_ * 0.5, self.height_ * 0.5)
        :scale(3.0)

    display.newSprite("#pop_common2_decoration4.png"):addTo(self.background_)
        :align(display.BOTTOM_RIGHT, self.width_ * 0.5, 10)

    local bottom_bg2_ = display.newSprite("#pop_common2_decoration4.png"):addTo(self.background_)
        :align(display.BOTTOM_RIGHT, self.width_ * 0.5, 10)

    bottom_bg2_:setScaleX(-1)
end

function Panel:addBgLight()
end

function Panel:addTopDivide(yoffset_)
end

function Panel:addTopIcon(icon_, yoffset_)
    if not self.topIcon_ then
        display.newSprite("#pop_common_icon_bg.png")
            :align(display.BOTTOM_CENTER, 0, self.height_ * 0.5 - 2)
            :addTo(self)

        self.topIcon_ = display.newSprite(icon_)
            :pos(0, self.height_ * 0.5 - (yoffset_ or 16))
            :addTo(self)
    end
end

function Panel:addTitle(title_, yoffset_)
    self.title_ = ui.newTTFLabel({text = title_, color = cc.c3b(0xeb, 0xce, 0x8e), size = self.fontSize_, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, self.height_ * 0.5 - 48 + (yoffset_ or 0))
        :addTo(self)
end

function Panel:addCloseBtn()
    if not self.closeBtn_ then
        self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#pop_common_close_normal.png", pressed="#pop_common_close_pressed.png"})
            :pos(self.close_x_, self.close_y_)
            :onButtonClicked(function()
                self:onClose()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            end)
            :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)
    end
end

--设置通用弹框样式
function Panel:setCommonStyle(title_, yoffset_)
    self:addCloseBtn()
    self:addTitle(title_, yoffset_)
end 

--设置关闭按钮位置
function Panel:setCloseBtnOffset(x, y)
    self.closeBtn_:pos(self.close_x_ + x, self.close_y_ + y)
end 

--- example usage:
-- self:showPanelEx_ {
--      isModal             = true, -- default: true
--      isCentered          = true, -- default: true
--      closeWhenTouchModel = true, -- default: true
--      useShowAnimation    = true, -- default: true
-- }
function Panel:showPanelEx_(args)
    -- 设置默认参数
    assert(args == nil or type(args) == 'table', 'error arguments')
    local isModal, isCentered, cwt, usa
    if args == nil then
        isModal, isCentered, cwt, usa = true, true, true, true
    else
        isModal = args.isModal == nil and true or args.isModal
        isCentered = args.isCentered == nil and true or args.isCentered
        cwt = args.closeWhenTouchModel == nil and true or args.closeWhenTouchModel
        usa = args.useShowAnimation == nil and true or args.useShowAnimation
    end

    nk.PopupManager:addPopup(self, isModal, isCentered, cwt, usa)
    return self
end

function Panel:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation)
    nk.PopupManager:addPopup(self, isModal ~= false, isCentered ~= false, closeWhenTouchModel ~= false, useShowAnimation ~= false)
    return self
end

function Panel:hidePanel_()
    nk.PopupManager:removePopup(self)
    return self
end

function Panel:setCloseCallback(closeCallback)
    self.closeCallback_ = closeCallback
    return self
end

function Panel:onClose()
    if self.closeCallback_ then
        self.closeCallback_()
    end

    self:hidePanel_()
end

return Panel
