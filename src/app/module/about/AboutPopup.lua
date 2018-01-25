--
-- Author: viking@boomegg.com
-- Date: 2014-09-04 16:38:09
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local Panel = import("app.pokerUI.Panel")
local AboutPopup = class("AboutPopup", Panel)

AboutPopup.WIDTH = 480
AboutPopup.HEIGHT = 300

local TOP_HEIGHT = 44
local CONTENT_WIDTH = 455
local CONTENT_HEIGHT = 165
local topTitleSize = 30
local topTitleColor = cc.c3b(0x64, 0x9a, 0xc9)
local contentSize = 22
local contentColor = cc.c3b(0xca, 0xca, 0xca)
local serviceSize = 14
local serviceColor = cc.c3b(0x64, 0x9a, 0xc9)

function AboutPopup:ctor()
    AboutPopup.super.ctor(self, {AboutPopup.WIDTH, AboutPopup.HEIGHT})

    --顶部文字
    local titleMarginTop = 10
    local titleLabel = ui.newTTFLabel({
            text = bm.LangUtil.getText("ABOUT", "TITLE"),
            size = topTitleSize,
            color = topTitleColor,
            align = ui.TEXT_ALIGN_CENTER
        }):pos(0, AboutPopup.HEIGHT/2 - TOP_HEIGHT + TOP_HEIGHT/2 - titleMarginTop):addTo(self)


    local container = display.newNode():addTo(self)

    local contentMarginTop = 15
    local contentOriginY = AboutPopup.HEIGHT/2 - TOP_HEIGHT - contentMarginTop
    --内容背景
    display.newScale9Sprite("#panel_overlay.png", 0, contentOriginY - CONTENT_HEIGHT/2, cc.size(CONTENT_WIDTH, CONTENT_HEIGHT)):addTo(container)    

    local contentLabelMarginTop = 15
    local contentLabelMarginLeft = 35
    local contentLabelPadding = 15
    --玩家uid
    local uidLabel = ui.newTTFLabel({
            text = bm.LangUtil.getText("ABOUT", "UID", nk.userData.uid),
            size = contentSize,
            color = contentColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(container)
    uidLabel:setAnchorPoint(cc.p(0, 0.5))

    local contentLabelHeight = uidLabel:getContentSize().height
    uidLabel:pos(-AboutPopup.WIDTH/2 + contentLabelMarginLeft, contentOriginY - contentLabelHeight/2 - contentLabelMarginTop)

    --版本号
    local versionLabel = ui.newTTFLabel({
            text = bm.LangUtil.getText("ABOUT", "VERSION", BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion()),
            size = contentSize,
            color = contentColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(container)
    versionLabel:setAnchorPoint(cc.p(0, 0.5))
    versionLabel:pos(-AboutPopup.WIDTH/2 + contentLabelMarginLeft, contentOriginY - contentLabelHeight * 3/2 - contentLabelMarginTop - contentLabelPadding)

    --粉丝页
    local fansLabel = ui.newTTFLabel({
            text = bm.LangUtil.getText("ABOUT", "FANS"),
            size = contentSize,
            color = contentColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(container)
    fansLabel:setAnchorPoint(cc.p(0, 0.5))
    fansLabel:pos(-AboutPopup.WIDTH/2 + contentLabelMarginLeft, contentOriginY - contentLabelHeight * 5/2 - contentLabelMarginTop - contentLabelPadding * 2)

    --粉丝页地址
    local fansAddrLabel = ui.newTTFLabel({
            text = bm.LangUtil.getText("ABOUT", "FANS_URL"),
            size = contentSize,
            color = contentColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(container)
    fansAddrLabel:setAnchorPoint(cc.p(0, 0.5))
    fansAddrLabel:pos(-AboutPopup.WIDTH/2 + contentLabelMarginLeft, contentOriginY - contentLabelHeight * 7/2 - contentLabelMarginTop - contentLabelPadding * 2)

    local contentBottom = contentOriginY - CONTENT_HEIGHT
    --服务条款
    local serviceLabel = ui.newTTFLabel({
            text = bm.LangUtil.getText("ABOUT", "SERVICE"),
            size = serviceSize,
            color = serviceColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)

    local serviceLabelHeight = serviceLabel:getContentSize().height
    local serviceLabelMarginTop = 15
    local serviceLabelPadding = 5
    serviceLabel:pos(0, contentBottom - serviceLabelHeight/2 - serviceLabelMarginTop)

    --公司版权
    local rightLabel = ui.newTTFLabel({
            text = bm.LangUtil.getText("ABOUT", "COPY_RIGHT"),
            size = serviceSize,
            color = serviceColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)
    rightLabel:pos(0, contentBottom - serviceLabelHeight* 3/2 - serviceLabelMarginTop - serviceLabelPadding)

    self:addCloseBtn()
end

function AboutPopup:show()
    self:showPanel_()
end

function AboutPopup:hide()
    self:hidePanel_()
end

return AboutPopup