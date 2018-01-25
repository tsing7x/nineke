//
//  AppNotificationCenter.cpp
//  nineke
//
//  Created by Quinn Nie on 7/9/15.
//
//

#include "cocos2d.h"

#include "CCLuaEngine.h"
#include <string>

#include "AppNotificationCenter.h"

USING_NS_CC;

// 把 cmdkey(字符串)和奖励金额(数字)转成字符串格式, #号分隔,写到文件中去
void AppNotificationCenter::handleDidReceiveAutoRecall(const char * msg)
{
	UserDefault * userDefault = UserDefault::getInstance();
	// key值与 COOKIE_KEYS.lua中的一致
	userDefault->setBoolForKey("RN_HAVEAUTORECALL", true);
	userDefault->setStringForKey("RN_AUTORECALL_MSG", std::string(msg));
	userDefault->flush();
}
