--
-- Author: tony
-- Date: 2014-07-11 15:31:09
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    通用声音进入游戏预加载，不需释放
    房间声音进入房间预加载，退出房间释放
]]

local SoundManager = class("SoundManager")

SoundManager.commonSounds = {
    CLICK_BUTTON  = "sounds/clickButton.mp3", 
    CLOSE_BUTTON = "sounds/closeButton.mp3",
    REPLACE_SCENE = "sounds/replaceScene.mp3", 
    GEAR_TICK  = "sounds/gearTick.mp3",  
    BOX_OPEN_NORMAL = "sounds/box_open_normal.mp3",
    BOX_OPEN_REWARD = "sounds/box_open_reward.mp3",
    WHEEL_WIN = "sounds/WheelWin.mp3",
    WHEEL_LOOP = "sounds/WheelLoop.mp3",
    WHEEL_START = "sounds/WheelStart.mp3",
    WHEEL_END = "sounds/WheelEnd.mp3",
    SLOT_WIN = "sounds/SlotWin.mp3",
    SLOT_LOOP = "sounds/SlotLoop.mp3",
    SLOT_START = "sounds/SlotStart.mp3",
    SLOT_END = "sounds/SlotEnd.mp3",
    SLOT_BET = "sounds/SlotBet.mp3",
    SLOT_AUTO_BET = "sounds/SlotAutoBet.mp3",
    CLOCK      = "sounds/clock.mp3",

    PUMP_JUMP = "sounds/pumpJump.mp3",
    PUMP_POUNCH = "sounds/pumpPounch.mp3"
}

SoundManager.roomSounds = {
    MOVE_CHIP  = "sounds/moveChip.mp3", 
    NOTICE     = "sounds/notice.mp3", 
    CALL       = "sounds/call.mp3", 
    FOLD       = "sounds/fold.mp3", 
    RAISE      = "sounds/raise.mp3", 
    CHECK      = "sounds/check.mp3", 
    CLOCK_TICK = "sounds/clockTick.mp3", 
    GEAR_TICK  = "sounds/gearTick.mp3", 
    DEAL_CARD  = "sounds/dealCard.mp3", 
    FLIP_CARD  = "sounds/flipCard.mp3", 
    TAP_TABLE  = "sounds/tapTable.mp3",
    CHIP_DROP  = "sounds/chipDropping.mp3", 
    APPLAUSE   = "sounds/Applause.mp3",
    SHOW_HAND_CARD = "sounds/ShowHandCard.mp3",
    WINNER1    = "sounds/winner1.mp3",
    WINNER2    = "sounds/winner2.mp3",
    WINNER3    = "sounds/winner3.mp3",
    ALLIN      = "sounds/allin.mp3",
    DROPCARD   = "sounds/dropcard.mp3",
    SELECTCARD = "sounds/selectcard.mp3",
    DICE_BET   = "sounds/audio_call.mp3",
    DICE_VS    = "sounds/audio_vs.mp3",
    DICE_CHIPMOVE = "sounds/audio_chipmove.mp3",
    DICE_CLOCK = "sounds/dice_clock_timeout.mp3"
}

SoundManager.hddjSounds = {
    [1]     = "sounds/Egg.mp3",
    [2]     = "sounds/PourWater.mp3",
    [3]     = "sounds/Flower.mp3",
    [4]     = "sounds/Kiss.mp3",
    [5]     = "sounds/Toast.mp3",
    [6]     = "sounds/Tomato.mp3",
    [7]     = "sounds/Dog.mp3",
    [8]     = "sounds/Hammer.mp3",
    [9]     = "sounds/Bomb.mp3",
    [10]    = "sounds/tissure.mp3",
    [11]    = "sounds/Flower.mp3",
    [1009]    = "sounds/waterLampA.mp3",
    [1010]    = "sounds/waterLampB.mp3",
    [17]    = "sounds/pumpLamp.mp3"
}

SoundManager.chatSounds = {
    [1]     = "sounds/chat1.mp3",
    [2]     = "sounds/chat2.mp3",
    [3]     = "sounds/chat3.mp3",
    [4]     = "sounds/chat4.mp3",
    [5]     = "sounds/chat5.mp3",
    [6]     = "sounds/chat6.mp3",
    [7]     = "sounds/chat7.mp3",
    [8]     = "sounds/chat8.mp3",
    [9]     = "sounds/chat9.mp3",
    [10]     = "sounds/chat10.mp3",
    [11]     = "sounds/chat11.mp3",
    [12]     = "sounds/chat12.mp3",
    [13]     = "sounds/chat13.mp3",
    [14]     = "sounds/chat14.mp3",
}

for k, v in pairs(SoundManager.commonSounds) do
    SoundManager[k] = v
end

for k, v in pairs(SoundManager.roomSounds) do
    SoundManager[k] = v
end

function SoundManager:ctor()
    self:updateVolume()
end

function SoundManager:preload(soundsType)
    if self[soundsType] and type(self[soundsType]) == "table" then
        for _, soundName in pairs(self[soundsType]) do
            audio.preloadSound(soundName)
        end
    end
end

function SoundManager:unload(soundsType)
    if self[soundsType] and type(self[soundsType]) == "table" then
        for _, soundName in pairs(self[soundsType]) do
            audio.unloadSound(soundName)
        end
    end
end

function SoundManager:playSound(soundName, loop)
    if self.volume_ > 0 then
        return audio.playSound(soundName, loop or false)
    end
    return nil
end

function SoundManager:playHddjSound(id)
    if self.volume_ > 0 then
        audio.playSound(SoundManager.hddjSounds[id], false)
    end
end

function SoundManager:playChatSound(id)
    if self.isChatVoice_ and self.volume_ > 0 and SoundManager.chatSounds[id] then
        audio.playSound(SoundManager.chatSounds[id], false)
    end
end

function SoundManager:updateVolume()
    self.volume_ = nk.userDefault:getIntegerForKey(nk.cookieKeys.VOLUME, 100)
    self.isChatVoice_ = nk.userDefault:getBoolForKey(nk.cookieKeys.CHATVOICE, true)
    audio.setSoundsVolume(self.volume_ / 100)
end

function SoundManager:playBgMusic()
    local isBgSound = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.BG_SOUND, true)
    if isBgSound then
        if self.bgmusic_ then
            return
        end
        self.bgmusic_ = true
        audio.playMusic("sounds/background.mp3",true)
    end
end

function SoundManager:stopBgMusic()
    if self.bgmusic_ then
        audio.stopMusic(false)
        self.bgmusic_ = nil
    end
end

return SoundManager