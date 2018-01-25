--
-- Author: tony
-- Date: 2014-07-28 20:21:22
--
local CardType = class("CardType")

function CardType:ctor(type, point)
    self.type_ = type
    self.point_ = point
end

function CardType:getCardTypeValue()
    return self.type_
end

function CardType:getCardPointValue()
    return self.point_
end

function CardType:getLabel()
    if self.type_ == consts.CARD_TYPE.POINT_CARD then
        return bm.LangUtil.getText("COMMON", "CARD_TYPE")[consts.CARD_TYPE.POINT_CARD][self.point_]
    else
        return bm.LangUtil.getText("COMMON", "CARD_TYPE")[self.type_]
    end
end

function CardType:compareTo(cardType)
    return CardType.comparetorAsc_(self, cardType)
end

function CardType.comparetor(asc)
    if not asc then
        return CardType.comparetorDesc_
    else
        return CardType.comparetorDesc_
    end
end

function CardType:isLargeCardType()
    return self.type_ == consts.CARD_TYPE.ROYAL or self.type_ == consts.CARD_TYPE.STRAIGHT_FLUSH or self.type_ == consts.CARD_TYPE.THREE_KIND
end

function CardType:isGoodType()
    return self.type_ >= consts.CARD_TYPE.STRAIGHT and self.type_ <= consts.CARD_TYPE.THREE_KIND
end

function CardType:isBadType()
    return self.type_ == consts.CARD_TYPE.POINT_CARD
end

function CardType.comparetorAsc_(cardType1, cardType2)
    if cardType1.type_ == consts.CARD_TYPE.POINT_CARD and cardType1.type_ == cardType2.type_ then
        return cardType1.point_ - cardType2.point_
    else
        return cardType1.type_ - cardType2.type_
    end
end

function CardType.comparetorDesc_(cardType1, cardType2)
    if cardType1.type_ == consts.CARD_TYPE.POINT_CARD and cardType1.type_ == cardType2.type_ then
        return cardType2.point_ - cardType1.point_
    else
        return cardType2.type_ - cardType1.type_
    end
end

return CardType