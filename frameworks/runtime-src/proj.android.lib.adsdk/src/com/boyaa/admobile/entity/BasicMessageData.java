package com.boyaa.admobile.entity;

/**
 * 基础报文信息
 * @author Carrywen
 *
 */
public class BasicMessageData {
	/** 
	 * 用户触发时间戳
	 */
    public String triggerTimestamp = "";
    /**
     * 应用接口名称，用来标识应用版本
     */
    public String api = "";
    /**
     * 服务端地址
     */
    public String serverUrl = "";
    /**
     * 秘钥 ,秘钥= md5(API_TOKEN.lts_at);
     */
    public String sig = "";
    /**
     * 用户游戏ID
     */
    public String uid = "";
    /**
     * 平台用户编号移动游客使用手机设备号'
     */
    public String platformUid = "";
    /**
     * MAC ADDRESS
     */
    public String macAddress = "";
    /**
     * android id
     */
    public String androidId = "";
    /**
     * 设备编号
     */
    public String deviceId = "";
    /**
     * 事件类型' ：'1'=>'启动', '2'=>'登录', '3'=>'激活', '4'=>'玩牌局数', '5'=>'付费金额'
     */
    public String eventType = "";
    /**
     * 用户IP地址
     */
    public String clientIp = "";
    /**
     * 客户端版本号
     */
    public String appVersion = "";
    /**
     * 操作系统
     */
    public String appOs = "";
    /**
     * 手机设备类型
     */
    public String deviceType = "";
    /**
     * 手机分辨率
     */
    public String pixelInfo = "";
    /**
     * 网络运营商
     */
    public String netServicePro = "";
    /**
     * 联网方式
     */
    public String connNetType = "";
    /**
     * 支付金额
     */
    public String amount = "";
    /**
     * 支付汇率
     */
    public String rate = "";
    /**
     * 支付方式
     */
    public String pmode = "";
    /**
     * 广告商相关联信息
     */
    public String httpRef = "";
    /**
     * 记录唯一标示(MD5(设备ID+时间戳))
     */
    public String recordId = "";
    /**
     * 游戏时长
     */
    public String gameTime = "";


    @Override
    public String toString() {
        return "BasicMessageData{" +
                "triggerTimestamp='" + triggerTimestamp + '\'' +
                ", api='" + api + '\'' +
                ", serverUrl='" + serverUrl + '\'' +
                ", sig='" + sig + '\'' +
                ", uid='" + uid + '\'' +
                ", platformUid='" + platformUid + '\'' +
                ", macAddress='" + macAddress + '\'' +
                ", androidId='" + androidId + '\'' +
                ", deviceId='" + deviceId + '\'' +
                ", eventType='" + eventType + '\'' +
                ", clientIp='" + clientIp + '\'' +
                ", appVersion='" + appVersion + '\'' +
                ", appOs='" + appOs + '\'' +
                ", deviceType='" + deviceType + '\'' +
                ", pixelInfo='" + pixelInfo + '\'' +
                ", netServicePro='" + netServicePro + '\'' +
                ", connNetType='" + connNetType + '\'' +
                ", amount='" + amount + '\'' +
                ", rate='" + rate + '\'' +
                ", pmode='" + pmode + '\'' +
                ", httpRef='" + httpRef + '\'' +
                ", recordId='" + recordId + '\'' +
                ", gameTime='" + gameTime + '\'' +
                '}';
    }
}
