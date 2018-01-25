--
-- Author: Johnny Lee
-- Date: 2014-07-10 16:44:55
--
local pokerUI = {}

pokerUI.PokerCard           = import(".PokerCard")
pokerUI.SimpleButton        = import(".SimpleButton")
pokerUI.Panel               = import(".Panel")
pokerUI.Dialog              = import(".Dialog")
pokerUI.ProgressBar         = import(".ProgressBar")
pokerUI.RoomLoading         = import(".RoomLoading")
pokerUI.TabBarWithIndicator = import(".TabBarWithIndicator")
pokerUI.CommonPopupTabBar   = import(".CommonPopupTabBar")
pokerUI.CheckBoxButtonGroup = import(".CheckBoxButtonGroup")
pokerUI.Juhua               = import(".Juhua")
pokerUI.ChangeChipAnim      = import(".ChangeChipAnim")
pokerUI.PaoPaoTips          = import(".PaoPaoTips")
pokerUI.CircleIcon          = import(".CircleIcon")
-- 添加点击声效
function buttontHandler(obj, method)
    return function(...)
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        return method(obj, ...)
    end
end

return pokerUI
