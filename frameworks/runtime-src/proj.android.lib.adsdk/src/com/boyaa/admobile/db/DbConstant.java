package com.boyaa.admobile.db;

/**
 * 数据库常量信息 
 * @author Carrywen
 *
 */
public class DbConstant {
	public static final String DATABASE_NAME = "httpDataDB.db";
	public static final String HTTP_DATA_TABLE = "httpdata";
    public static final int DB_VERSION = 3;

    //HTTP_DATA_TABLE 字段表
	public static final String HTTP_LTS_AT = "lts_at";
	public static final String HTTP_SIG = "sig";
	public static final String HTTP_UID = "uid";
	public static final String HTTP_PLA_UID = "platform_uid";
	public static final String HTTP_IP = "ip";
	public static final String HTTP_EVENT_TYPE = "event_type";
	public static final String HTTP_DEVICE_ID = "device_id";
	public static final String HTTP_CLI_VERSION = "cli_verinfo";
	public static final String HTTP_CLI_OS = "cli_os";
	public static final String HTTP_DEVICE_TYPE = "device_type";
	public static final String HTTP_PX_INFO = "pixel_info";
	public static final String HTTP_ISP = "isp";
	public static final String HTTP_NW_TYPE = "nw_type";
	public static final String HTTP_PAY_MONEY = "amount";
	public static final String HTTP_PAY_RATE="rate";
	public static final String HTTP_PAY_MODE="pmode";
	public static final String HTTP_REF = "httpRef";
	public static final String HTTP_ID= "recordId";
	public static final String HTTP_URL = "server_url";
	public static final String HTTP_API = "cli_api";
	public static final String HTTP_MAC = "mac";
	public static final String HTTP_ANDROID = "androidId";
    public static final String HTTP_GAME_TIME = "gameTime";
    public static final String DB_OP_QUERY_ALL = "select * from httpdata";
	
	
}
