--
-- Author: Jonah0608@gmail.com
-- Date: 2016-07-12 17:20:31
--

local CARD_GAP = 60
local FoldCards = class("FoldCards", function ()
    return display.newNode()
end)

-- 除了自己，其他座位上的牌默认scale = 0.8
function FoldCards:ctor(sizeScale)
    -- 设置缩放
    if sizeScale then self:setScale(sizeScale) end
    -- 扑克牌容器
    local PokerCard = nk.ui.PokerCard
    self.cards = {}
    for i = 1,5 do
        self.cards[i] = PokerCard.new():pos((i-(5 + 1) / 2) * CARD_GAP, 0):addTo(self)
    end
end

function FoldCards:setCards(cardsValue)
    assert(type(cardsValue) == "table" and (#cardsValue == 4 or #cardsValue == 5), "cardsValue should be a table with length equals 3")
    local cardNum = #cardsValue
    for i = 1,cardNum do
        self.cards[i]:pos((i-(cardNum + 1) / 2) * CARD_GAP, 0)
    end
    if cardNum == 4 then
        self.cards[5]:hide()
    end
    for i, cardUint in ipairs(cardsValue) do
        self.cards[i]:setCard(cardUint)
    end
    return self
end

function FoldCards:showFrontAll()
    for _, card in ipairs(self.cards) do
        card:showFront()
    end
    return self
end

function FoldCards:addDarkAll()
    for _, card in ipairs(self.cards) do
        card:addDark()
    end
    return self
end

function FoldCards:removeDarkAll()
    for _, card in ipairs(self.cards) do
        card:removeDark()
    end
    return self
end

return FoldCards