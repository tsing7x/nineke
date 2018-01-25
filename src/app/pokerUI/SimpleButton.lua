--
-- Author: tony
-- Date: 2014-07-25 13:41:40
--

local SimpleButton = class("SimpleButton", function()
    return display.newNode()
end)

function SimpleButton:ctor(params, tag)
    assert(params and params.up, "up state image must be set")
    self.tag_ = tag
    self.isEnabled_ = true
    self:setCascadeOpacityEnabled (true)

    self.touchHelper_ = bm.TouchHelper.new(self, self.onTouch_)
    self.touchHelper_:enableTouch()

    self.images_ = {}
    self.labels_ = {}

    self:createState_("up", params.up)
    self:createState_("down", params.down)
    self:createState_("disabled", params.disabled)

    for k, v in pairs(self.images_) do
        if type(v) == "string" then
            self.images_[k] = self.images_[v]
            v = self.images_[v]
        end
        if v and not v:getParent() then
            v:addTo(self):hide()
        end
    end
    for k, v in pairs(self.labels_) do
        if type(v) == "string" then
            self.labels_[k] = self.labels_[v]
            v = self.labels_[v]
        end
        if v and not v:getParent() then
            v:addTo(self):hide()
        end
    end

    self:changeState_("up")

    if params.label then
        self:label(params.label)
    end
    if params.width and params.height then
        self:size(params.width, params.height)
    elseif params.width then
        self:size(params.width, self:getContentSize().height)
    elseif params.height then
        self:size(self:getContentSize().height, params.height)
    end
end

function SimpleButton:changeState_(st)
    self.state_ = st
    for k, v in pairs(self.images_) do
        if v then
            v:hide()
        end
    end
    for k, v in pairs(self.labels_) do
        if v then
            v:hide()
        end
    end
    if self.images_[st] then
        self.images_[st]:show()
    elseif self.images_["up"] then
        self.images_["up"]:show()
    end
    if self.labels_[st] then
        self.labels_[st]:show()
    elseif self.labels_["up"] then
        self.labels_["up"]:show()
    end
end

function SimpleButton:createState_(state, param)
    if param then
        if type(param) == "table" then
            if param.background == "up" or param.background == "down" or param.background == "disabled" then
                self.images_[state] = param.background
            elseif type(param.background) == "string" then
                self.images_[state] = display.newSprite(param.background)
            elseif type(param.background) == "table" then
                if param.background.scale9 == true then
                    self.images_[state] = display.newScale9Sprite(param.background.texture)
                    self.images_[state].isScale9__ = true
                    if param.background.scale9Rect then
                        self.images_[state]:setCapInsets(param.background.scale9Rect)
                    end
                else
                    self.images_[state] = display.newSprite(param.background.texture)
                end
            elseif type(param.background) == "function" then
                self.images_[state] = param.background()
            else
                self.image_[state] = param.background
            end
            if param.label then
                if param.label == "up" or param.label == "down" or param.label == "disabled" then
                    self.labels_[state] = param.label
                elseif type(param.label) == "function" then
                    self.labels_[state] = param.label()
                elseif type(param.label) == "table" then
                    if param.label.type == "ttf" then
                        self.labels_[state] = ui.newTTFLabel(param.label)
                    elseif param.label.type == "bmf" then
                        self.labels_[state] = ui.newBMFontLabel(param.label)
                    end
                else
                    self.labels_[state] = param.label
                end
            end
        elseif type(param) == "string" then
            self.images_[state] = param
            self.labels_[state] = param
        end
    end
end

function SimpleButton:enabled(isEnabled)
    self.isEnabled_ = isEnabled
    if isEnabled then
        self:changeState_("up")
    else
        self:changeState_("disabled")
    end
    return self
end

function SimpleButton:isEnabled()
    return self.isEnabled_
end

function SimpleButton:label(lb)
    for k, v in pairs(self.labels_) do
        v:setString(lb)
    end
    return self
end

function SimpleButton:onClicked(handler)
    self.onClickedHandler_ = handler
    return self
end

function SimpleButton:size(w, h)
    for k, v in pairs(self.images_) do
        if v.isScale9__ then
            v:setContentSize(cc.size(w, h))
        else
            local size = v:getContentSize()
            v:setScaleX(w / size.width)
            v:setScaleY(h / size.height)
        end
    end
    return self
end

function SimpleButton:onTouch_(evt, isTouchInSprite)
    if self:isVisible() and self:getParent() and self.isEnabled_ then
        if evt == bm.TouchHelper.TOUCH_BEGIN then
            self:changeState_("down")
        elseif evt == bm.TouchHelper.TOUCH_MOVE then
            if isTouchInSprite then
                self:changeState_("down")
            else
                self:changeState_("up")
            end
        elseif evt == bm.TouchHelper.TOUCH_END then
            self:changeState_("up")
        elseif evt == bm.TouchHelper.CLICK then
            if self.onClickedHandler_ then
                self.onClickedHandler_(self.tag_, self)
            end
            self:changeState_("up")
        end
    end
end

return SimpleButton