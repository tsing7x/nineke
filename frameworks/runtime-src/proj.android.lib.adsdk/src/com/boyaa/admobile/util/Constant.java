package com.boyaa.admobile.util;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;

import java.io.ObjectOutputStream.PutField;
import java.util.HashMap;

/**
 * 常量工具类
 *
 * @author CarryWen
 */
public class Constant {

    public static String version = "1.0";
    public static boolean IS_DEBUG_MODE = true;

    public static final int TIME_OUT = 60000; // 请求超时时间
    public static String clientIp = "";

    /**
     * 上传服务器地址
     */
    public static final String RATE_URL_KEY = "rate_url";
//    public static final String RATE_URL = "http://ad.boyaagame.com/index.php/sdk/event_report_api/get_payrate";
    public static final String API_TOKEN = "f45f6e80ce0dd57e6884adb9cc4c3f9a";
    public static final String CONFIG_KEY = "ad_config";
    public static final int REG_ACTION = 0; // 0.是否注册 1. 是否注册且玩牌
    public static final int REG_PLAY_ACTION = 1;
    
    public static final String FB_PRE = "ad_";
    
    //配置AppsFlyer需要上报的Key
    public static final String AF_KEY = "x7Px3ea6x8SZpwFf7xSWJg";
    
    /*
     * 需要开启的服务
     */
    public static String NEED_SERVICE = "com.boyaa.admobile.service.CommitService";

    public static final String ENGLISH = null; // 英语
    public static final String INDONESIAN = null; // 印尼语
    public static final String SPANISH = null; // 西班牙语
    public static final String ITALIAN = null; // 意大利语
    public static final String German = null; // 德语
    public static final String CHINA_F = null; // 中文繁体
    public static final String TAIYU = null; // 泰语
    public static final String Portugal = null; // 葡萄牙
    public static final Object French = null; // 法语

    // APPS Flyer constant
    public static final String CURRENCY_CODE_DEFAULT = "USD"; // 美元
    public static final String CURRENCY_CODE_GBP = "GBP"; // 英镑
    public static final boolean AF_USE_HTTP = true;
    // Appflyer所需要的初始化参数
    public static final String APP_USER_ID = "uid";

    //增加召回事件
    public static final String AF_EVENT_START = "start";
    public static final String AF_EVENT_LOGIN = "login";
    public static final String AF_EVENT_REGISTER = "registration";
    public static final String AF_EVENT_PLAY = "play";
    public static final String AF_EVENT_PAY = "purchase";
    public static final String AF_EVENT_LOGOUT = "logout";
    public static final String AF_EVENT_CUSTOM = "custom";
    public static final String AF_EVENT_RECALL="recall";
    
    public static final String RECALL_EXTRA = "recall_extra";
    

    // App Fly读取到的广播信息村村的文件名（SharePreference）
    public static final String AF_AD_INFO_LOC = "appsflyer-data";
    public static final String AF_AD_INFO_KEY = "referrer";
    public static final String RATE_FILE = "exchange_rate";
    public static String UNIT = "HKD";
    public static String UNIT_RATE = "rate";
    public static String UNIT_UPDATE_TIME = "rateUpdate";
    public static HashMap<String, String> rateMap = new HashMap<String, String>(){
    	{
    	  //迪拉姆
            put("AED","0.274");
            //阿根廷比索
            put("ARS","0.1781");
            //巴西雷亚尔
            put("BRL","0.438");
            //加元
            put("CAD","0.9537");
            //瑞士法郎
            put("CHF","1.0877");
            //智利比索
            put("CLP","0.002");
            //人民币
            put("CNY","0.1588");
            //哥伦比亚比索
            put("COP","0.000525");
            //欸镑
            put("EGP","0.1428");
            //欧元
            put("EUR","1.2876");
            //FacebookCredits
            put("FBC","0.1");
            //英镑
            put("GBP","1.569");
            //港币
            put("HKD","0.1288");
            //匈牙利福林
            put("HUF","0.004432");
            //印尼盾
            put("IDR","0.0001");
            //以色列镑
            put("ILS","0.274");
            //日元
            put("JPY","0.0101");
            //韩元
            put("KRW","0.000897");
            //摩洛哥迪拉姆
            put("MAD","0.1161");
            //墨西哥比索
            put("MXN","0.07679");
            //马来西亚林吉特
            put("MYR","0.3071");
            //波兰兹罗提
            put("PLN","0.3096");
            //卡塔尔
            put("QAR","0.274");
            //卢布
            put("RUB","0.03");
            //沙特里亚尔
            put("SAR","0.266");
            //瑞典克朗
            put("SEK","0.1554");
            //新加坡元
            put("SGD","0.7916");
            //泰株
            put("THB","0.0280");
            //土耳其里拉
            put("TRY","0.5133");
            //新台币
            put("TWD","0.0334");
            //美元
            put("USD","1");
            //越南盾
            put("VND","0.000044");
    	}
    };
}
