--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-11 11:30:01
--
local ActivityServerUrl = {
    { name="内网测试",url="http://192.168.204.68/operating/web/index.php?m=%s&p=%s&appid=%s&api=%s"},
    { name="线上测试",url="http://mvlp9kapi.boyaagame.com/?m=%s&p=%s&appid=%s&api=%s"},
    { name="正式环境",url="http://mvlp9kapi.boyaagame.com/?m=%s&p=%s&appid=%s&api=%s"}
}

return ActivityServerUrl