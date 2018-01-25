
local POKER_TYPE_ALL = {}
POKER_TYPE_ALL.POINT_CARD     = 1 --点牌
POKER_TYPE_ALL.STRAIGHT       = 2 --顺子
POKER_TYPE_ALL.STRAIGHT_FLUSH = 3 --同花顺
POKER_TYPE_ALL.THREE_YELLOW   = 4 --三黄
POKER_TYPE_ALL.THREE_KIND     = 5 --三张
POKER_TYPE_ALL.POKDENG        = 6 --博定

-- 获得花色
function getPokerColor(card)
    return math.floor(card / 256)
end

-- 获得牌值
function getPokerValue(card)
    local value = card % 256
    if value == 0xE then
        return 1
    end
    return value
end

-- 花色比较 0:c1与c2花色相同，>0 :c1花色>c2花色，<0 :c1花色<c2花色
function colorCompare(c1, c2)
    if c1 == 1 and c2 == 2 then
        return 1
    elseif c1 == 2 and c2 == 1 then
        return -1
    end
    return c1 - c2
end

-- 获得点数
function getPokerPoint(card)
    local value = getPokerValue(card)
    if value < 0xA then
        return value
    elseif value == 0xE then
        return 1
    else
        return 0
    end
end

local HandPoker = class("HandPoker")
function HandPoker:ctor()
    self.cards_ = {}
    self.count_ = 0  -- 牌数量
    self.point_ = 0  -- 牌点数
    self.type_ = 1   -- 牌型
end

function HandPoker:reset()
    table.sort(self.cards_, function(card1, card2)
        if getPokerValue(card1) ~= getPokerValue(card2) then
            return getPokerValue(card1) > getPokerValue(card2)
        else
            return colorCompare(getPokerColor(card1), getPokerColor(card2)) > 0
        end
    end)    
    self.count_ = 0
    self.point_ = 0
    for _,v in ipairs(self.cards_) do
        if v ~= 0 then
            self.count_ = self.count_ + 1
        end
        self.point_ = self.point_ + getPokerPoint(v)
    end
    self.point_ = self.point_ % 10

    if self:isPokdeng_() then
        self.type_ = POKER_TYPE_ALL.POKDENG
    elseif self:isThreeKind_() then
        self.type_ = POKER_TYPE_ALL.THREE_KIND
    elseif self:isThreeYellow_() then
        self.type_ = POKER_TYPE_ALL.THREE_YELLOW
    elseif self:isStraightFlush_() then
        self.type_ = POKER_TYPE_ALL.STRAIGHT_FLUSH
    elseif self:isStraight_() then
        self.type_ = POKER_TYPE_ALL.STRAIGHT   
    else 
        self.type_ = POKER_TYPE_ALL.POINT_CARD
    end
end


-- 牌型
function HandPoker:getType()
    return self.type_
end

-- 获取牌型描述
function HandPoker:getTypeLabel()
    if self.type_ == POKER_TYPE_ALL.POINT_CARD then
        return bm.LangUtil.getText("COMMON", "PDENG_CARD_TYPE")[POKER_TYPE_ALL.POINT_CARD][self.point_]
    else
        return bm.LangUtil.getText("COMMON", "PDENG_CARD_TYPE")[self.type_]
    end
end

function HandPoker:isPokdeng()
    return self.type_ == POKER_TYPE_ALL.POKDENG
end

function HandPoker:isLargeCardType()
    return self.type_ == POKER_TYPE_ALL.POKDENG or self.type_ == POKER_TYPE_ALL.THREE_KIND or self.type_ == POKER_TYPE_ALL.THREE_YELLOW
end

function HandPoker:isGoodType()
    return self.type_ >= POKER_TYPE_ALL.STRAIGHT and self.type_ <= POKER_TYPE_ALL.POKDENG
end

function HandPoker:isBadType()
    return self.type_ == POKER_TYPE_ALL.POINT_CARD
end

-- 是否需要第三张牌
function HandPoker:needPoker()
    return self:isBadType() and self.point_ < 4 
end

-- 牌点
function HandPoker:getPoint()
    return self.point_
end

-- 手牌
function HandPoker:getCards()
    return self.cards_
end

-- 起手牌
function HandPoker:setCards(cards)
    local mycards = clone(cards)
    if #mycards == 2 then
       mycards[#mycards+1] = 0 
    end
    if #mycards ~= 3 then
       --出错了
       return
    end
    self.cards_ = mycards
    self:reset()
end

--能否要第三张牌
function HandPoker:canGetCard()
    return (not self:isPokdeng_()) and self.count_ == 2
end

-- 加第三张牌
function HandPoker:addCard(card)
    self.cards_[3] = card   
    self:reset()
end


function HandPoker:isPokdeng_()
    if self.count_ ~= 2 then
        return false
    end
    return self.point_ > 7
end

function HandPoker:isThreeKind_()
    if self.count_ ~= 3 then
        return false
    end
    return getPokerValue(self.cards_[1]) == getPokerValue(self.cards_[2]) and getPokerValue(self.cards_[2]) == getPokerValue(self.cards_[3])
end

function HandPoker:isStraightFlush_()
    local color1 = getPokerColor(self.cards_[1])
    local color2 = getPokerColor(self.cards_[2])
    local color3 = getPokerColor(self.cards_[3])
    if color1 == color2 and color2 == color3 then
        return self:isStraight_()
    end
    return false
end

function HandPoker:isStraight_()
    if self.count_ ~= 3 then
        return false
    end
    local val1 = getPokerValue(self.cards_[1])
    local val2 = getPokerValue(self.cards_[2])
    local val3 = getPokerValue(self.cards_[3])    
    -- 排除3 , 2 , 1 
    if val1 ~= 0x3 and val1 - 1 == val2 and val2 - 1 == val3 then
        return true
    end
    -- AKQ
    if val1 == 0xd and val2 == 0xc and val3 == 0x1 then
        return true
    end
    return false
end

function HandPoker:isThreeYellow_()
    if self.count_ ~= 3 then
        return false
    end
    local val1 = getPokerValue(self.cards_[1])
    local val2 = getPokerValue(self.cards_[2])
    local val3 = getPokerValue(self.cards_[3])

    local color1 = getPokerColor(self.cards_[1])
    local color2 = getPokerColor(self.cards_[2])
    local color3 = getPokerColor(self.cards_[3])
    if val1 > 0xa and val2 > 0xa and val3 > 0xa then
        if color1 ~= color2 or color2 ~= color3 or color3 ~= color1 then
            return true
        end
    end
    return false
end

function HandPoker:isPointCard_()
    if not self:isPokdeng_() and not self:isThreeKind_() and not self:isStraight_() and not self:isThreeYellow_() then
        return true
    end
    return false
end

-- 获得倍数
function HandPoker:getX()
    local bigHand = self
    -- 算倍数
    local ret = 0
    if bigHand ~= nil then
       ret = 1
       if bigHand:getType() == POKER_TYPE_ALL.POKDENG then
           -- 博定同花和队子是2倍
           if getPokerColor(bigHand:getCards()[1]) == getPokerColor(bigHand:getCards()[2]) or getPokerValue(bigHand:getCards()[1]) == getPokerValue(bigHand:getCards()[2]) then
                ret = 2
           end
       elseif bigHand:getType() == POKER_TYPE_ALL.THREE_KIND then
            ret = 5
       elseif bigHand:getType() == POKER_TYPE_ALL.THREE_YELLOW then
            ret = 3
       elseif bigHand:getType() == POKER_TYPE_ALL.STRAIGHT_FLUSH then
            ret = 5
       elseif bigHand:getType() == POKER_TYPE_ALL.STRAIGHT then
            ret = 3       
       else
            --点牌同花 3张是3倍 2张是2倍            
            local cards = bigHand:getCards()
            if getPokerValue(cards[3]) ~= 0x0 then
                ret = 3
            else
                ret = 2 
            end

            local color = getPokerColor(cards[1])
            for i=2,3 do
                if getPokerValue(cards[i]) ~= 0x0 and color ~= getPokerColor(cards[i])  then
                    ret = 1 -- 不是同花色
                    break
                end
            end           
            
            --2张牌点牌对子翻倍(不含AA,kk,qq,jj,10 10 等点数小于3点的牌型)          
            if getPokerValue(cards[3]) == 0x0 and getPokerValue(bigHand:getCards()[1]) == getPokerValue(bigHand:getCards()[2]) then
                -- if self.point_ > 3 then
                --     ret = 2
                -- else 
                --     ret = 1
                -- end
                return 2
            end
       end       
    end
   
    return ret
end

return HandPoker
