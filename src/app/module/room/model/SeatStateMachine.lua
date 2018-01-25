--
-- Author: tony
-- Date: 2014-07-10 15:04:44
--
local SeatStateMachine = class("SeatStateMachine")
local logger = bm.Logger.new("SeatStateMachine")

SeatStateMachine.SIT_DOWN = "tra_sitdown"
SeatStateMachine.STAND_UP = "tra_standup"
SeatStateMachine.GAME_START = "tra_gamestart"
SeatStateMachine.GAME_OVER = "tra_gameover"
SeatStateMachine.TURN_TO = "tra_turnto"
SeatStateMachine.FOLD = "tra_fold"
SeatStateMachine.CHECK = "tra_check"
SeatStateMachine.CALL = "tra_call"
SeatStateMachine.RAISE = "tra_raise"
SeatStateMachine.ALL_IN = "tra_allin"
SeatStateMachine.DROP_CARD = "tra_dropcard"
SeatStateMachine.GAME_START_4K = "tra_gamestart_4k"

SeatStateMachine.STATE_EMPTY        = "st_empty"        --空座
SeatStateMachine.STATE_WAIT_START    = "st_waitstart"    --等待开始
SeatStateMachine.STATE_WAIT_BETTING    = "st_waitbetting"    --等待下注
SeatStateMachine.STATE_ALL_IN         = "st_allin"        --AllIn
SeatStateMachine.STATE_FOLD         = "st_fold"            --弃牌
SeatStateMachine.STATE_BETTING         = "st_betting"        --下注中
SeatStateMachine.STATE_DROP             = "st_drop"            --丢牌中

function SeatStateMachine:ctor(seatData, isBetting, gameStatus)
    seatData.nick = string.trim(seatData.nick)
    self.stateDefault_ = nk.Native:getFixedWidthText(ui.DEFAULT_TTF_FONT, 24, seatData.nick, 100)
    self.statetext_ = self.stateDefault_
    self.seatId_ = seatData.seatId

    local initialState = "st_empty"
    local betState = seatData.betState

    if gameStatus == consts.SVR_GAME_STATUS.CAN_NOT_START then
        --重连登录，人还不够开始
        initialState = "st_waitstart"
    elseif gameStatus == consts.SVR_GAME_STATUS.READY_TO_START then
        --重连登录，马上要开始下一轮
        initialState = "st_waitstart"
    elseif gameStatus == consts.SVR_GAME_STATUS.WAIT_FOLD_CARD then
        initialState = "st_drop"
    elseif isBetting then
        initialState = "st_betting"
    elseif betState == consts.SVR_BET_STATE.WAITTING_START then
        initialState = "st_waitstart"
    elseif betState == consts.SVR_BET_STATE.WAITTING_BET then
        initialState = "st_waitbetting"
    elseif betState == consts.SVR_BET_STATE.FOLD then
        initialState = "st_fold"
        self.statetext_ = bm.LangUtil.getText("ROOM", "FOLD")
    elseif betState == consts.SVR_BET_STATE.ALL_IN then
        initialState = "st_allin"
        self.statetext_ = bm.LangUtil.getText("ROOM", "ALL_IN")
    elseif betState == consts.SVR_BET_STATE.CALL then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "CALL")
    elseif betState == consts.SVR_BET_STATE.SMALL_BLIND then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "SMALL_BLIND")
    elseif betState == consts.SVR_BET_STATE.BIG_BLIND then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "BIG_BLIND")
    elseif betState == consts.SVR_BET_STATE.CHECK then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "CHECK")
    elseif betState == consts.SVR_BET_STATE.RAISE then
        initialState = "st_waitbetting"
        self.statetext_ = bm.LangUtil.getText("ROOM", "RAISE_NUM", bm.formatBigNumber(seatData.betChips))
    elseif betState == consts.SVR_BET_STATE.PRE_CALL then
        initialState = "st_waitbetting"
    end

    self.statemachine_ = {}
    cc.GameObject.extend(self.statemachine_)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()
    self.statemachine_:setupState({
        initial = initialState,
        events = {
            {name="tra_sitdown", from="st_empty", to="st_waitstart"},
            {name="tra_standup", from="*", to="st_empty"},

            -- 加上后面这几个是因为重连登录的时候没有结束包 "st_allin", "st_fold", "st_waitbetting"
            -- 注释和代码不一致, 不确定这里是否有bug (david Apr 20)
            {name="tra_gamestart", from={"st_waitstart", }, to="st_waitbetting"},
            {name="tra_gamestart_4k", from={"st_waitstart",}, to="st_drop"},
            {name="tra_dropcard", from="st_drop", to="st_waitbetting"},
            {name="tra_gameover", from={
                "st_allin", "st_fold",
                "st_waitbetting", -- 站起导致结束
                "st_betting", "st_waitstart","st_drop"
            }, to="st_waitstart"},

            {name="tra_turnto", from="st_waitbetting", to="st_betting"},
            {name="tra_fold", from={"st_betting","st_drop"}, to="st_fold"},
            {name="tra_check", from="st_betting", to="st_waitbetting"},
            {name="tra_call", from="st_betting", to="st_waitbetting"},
            {name="tra_raise", from="st_betting", to="st_waitbetting"},
            {name="tra_allin", from="st_betting", to="st_allin"},
            {name="reset", from="*", to="st_empty"},
        },
        callbacks = {
            onchangestate = handler(self, self.onChangeState_)
        }
    })
end

function SeatStateMachine:getStateText()
    return self.statetext_
end

function SeatStateMachine:setStateText(txt)
    self.statetext_ = txt
end

function SeatStateMachine:getState()
    return self.statemachine_:getState()
end

function SeatStateMachine:doEvent(name, ...)
    if self.statemachine_:canDoEvent(name) then
        self.statemachine_:doEvent(name, ...)
    else
        logger:errorf("%s Can't do event %s on state %s", self.seatId_, name, self.statemachine_:getState())
        self.statemachine_:doEventForce(name, ...)
    end
end

function SeatStateMachine:onChangeState_(evt)
    logger:debugf("%s do event %s from %s to %s", self.seatId_, evt.name, evt.from, evt.to)
    local P = nk.socket.RoomSocket.PROTOCOL
    local st = evt.to
    local tra = evt.name
    local arg = ""
    if evt.args and evt.args[1] then
        arg = evt.args[1]
    end
    if checknumber(arg) > 0 then
        arg = bm.formatBigNumber(tonumber(arg))
    end

    if st == SeatStateMachine.STATE_EMPTY then
        self.statetext_ = ""
    elseif st == SeatStateMachine.STATE_FOLD then
        self.statetext_ = bm.LangUtil.getText("ROOM", "FOLD")
    elseif st == SeatStateMachine.STATE_ALL_IN then
        self.statetext_ = bm.LangUtil.getText("ROOM", "ALL_IN")
    elseif st == SeatStateMachine.STATE_BETTING or st == SeatStateMachine.STATE_WAIT_BETTING then
        if tra == SeatStateMachine.CHECK then
            self.statetext_ = bm.LangUtil.getText("ROOM", "CHECK")
        elseif tra == SeatStateMachine.CALL then
            self.statetext_ = bm.LangUtil.getText("ROOM", "CALL_NUM", arg)
        elseif tra == SeatStateMachine.RAISE then
            self.statetext_ = bm.LangUtil.getText("ROOM", "RAISE_NUM", arg)
        else
            self.statetext_ = self.stateDefault_
        end
    end
end

function SeatStateMachine:setDefaultString(nick)
    nick = string.trim(nick)
    self.stateDefault_ = nk.Native:getFixedWidthText(ui.DEFAULT_TTF_FONT, 24, nick, 100)
end

return SeatStateMachine
