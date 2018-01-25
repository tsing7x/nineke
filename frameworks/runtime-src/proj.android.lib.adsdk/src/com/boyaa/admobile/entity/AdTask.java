package com.boyaa.admobile.entity;

import android.content.Context;
import android.text.TextUtils;
import com.boyaa.admobile.service.ReportDataService;
import com.boyaa.admobile.util.BDebug;
import com.boyaa.admobile.util.BUtility;
import com.boyaa.admobile.util.Constant;

import java.net.HttpURLConnection;
import java.util.HashMap;
import java.util.Map;

/**
 * 广告任务基类
 * 
 * @author CarryWen
 * 
 */
public class AdTask {
	public boolean offLineFlag = false;
	public Context context;
	public HashMap<String, String> params;
	public BasicMessageData data;
	private ReportDataService service;

	public AdTask(HashMap paramsMap) {
		params = paramsMap;
	}

	public AdTask(BasicMessageData messageData) {
		data = messageData;
	}

	/**
	 * 正常执行流程
	 */
	public void execute() {
		data = convertMapToBean(context, params);
		service = ReportDataService.getReportService(context);
		HashMap<String, Object> httpResult = null;
		// 执行HTTP请求
		httpResult = request(context, data);
		boolean insertFlag = false;
		if (null != httpResult) {
			int code = (Integer) httpResult.get("code");
			if (code == HttpURLConnection.HTTP_OK) {
				try {
					String reStr = (String) httpResult.get("result");
					BDebug.d("BRequestUtil", reStr);
					HashMap retMap = BUtility.jsonToMap(reStr);
					String retCode = (String) retMap.get("code");
					if (TextUtils.isEmpty(retCode) || !retCode.equals("0000")) {
						if (retCode.equals("1111")) {
							return ;
						}
						insertFlag = firstExecute(data);
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			} else {
				insertFlag = firstExecute(data);
			}
		}
		if (insertFlag) {
			BDebug.d("task", "添加一条任务：pid=" + data.recordId);
		}

	}

	/**
	 * 离线任务执行流程
	 */
	public void offLineTask() {
		service = ReportDataService.getReportService(context);
		HashMap<String, Object> httpResult = null;
		// 执行HTTP请求
		httpResult = request(context, data);
		if (null != httpResult) {
			int code = (Integer) httpResult.get("code");
			if (code == HttpURLConnection.HTTP_OK) {
				try {
					String reStr = (String) httpResult.get("result");
					BDebug.d("BRequestUtil", reStr);
					HashMap retMap = BUtility.jsonToMap(reStr);
					String retCode = (String) retMap.get("code");
					if (!TextUtils.isEmpty(retCode) && retCode.equals("0000")) {
						boolean deleteFlag = lastExcute(data.recordId);
						if (deleteFlag) {
							BDebug.d("task", "删除一条任务:" + data.recordId);
						}
					} else {
						// 如果该记录不是当天的记录，再次发送一次，如果还不成功则从数据库删除
						if (!BUtility.isWithinDayRecord(data.triggerTimestamp,2)) {
							boolean deleteFlag = lastExcute(data.recordId);
							if (deleteFlag) {
								BDebug.d("task", "删除一条任务:" + data.recordId);
							}
						}
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			} else {
				// 如果该记录不是当天的记录，再次发送一次，如果还不成功则从数据库删除
				if (!BUtility.isWithinDayRecord(data.triggerTimestamp,2)) {
					boolean deleteFlag = lastExcute(data.recordId);
					if (deleteFlag) {
						BDebug.d("task", "删除一条任务:" + data.recordId);
					}
				}
			}
		}
	}

	protected HashMap<String, Object> request(Context context,
			BasicMessageData message) {
		return service.reportDataToHttp(context, message);
	}

	/**
	 * 存储数据库
	 * 
	 * @param message
	 * @return
	 */
	protected boolean firstExecute(BasicMessageData message) {
		return service.save(message);
	}

	/**
	 * 从数据库删除
	 * 
	 * @param service
	 * @return
	 */
	protected boolean lastExcute(String recordId) {
		return service.delete(recordId);
	}

	public HashMap<String, String> getParams() {
		return params;
	}

	public void setParams(HashMap<String, String> params) {
		this.params = params;
	}

	private BasicMessageData convertMapToBean(Context context,
			HashMap<String, String> paramsHashMap) {
		BasicMessageData messageData = new BasicMessageData();
		String lts_at = paramsHashMap.get("lts_at");
		if (TextUtils.isEmpty(lts_at)) {
			lts_at = BUtility.getUnixTimestamp();
		}
		messageData.triggerTimestamp = lts_at;
		String sig = BUtility.encode("md5", Constant.API_TOKEN
				+ messageData.triggerTimestamp);
		messageData.sig = sig;
	
		messageData.uid = paramsHashMap.get("uid");
		messageData.platformUid = paramsHashMap.get("platform_uid");
		messageData.eventType = paramsHashMap.get("et_id");
		
		String deviceId = paramsHashMap.get("udid");
		if (TextUtils.isEmpty(deviceId)) {
			deviceId = BUtility.getUniqueDeviceId(context);
		}
		messageData.deviceId = deviceId;
			
		//获取程序版本信息
		Map<String, String> appInfo = BUtility.getPackageInfo(context);
		
		String appVersion = paramsHashMap.get("cli_verinfo");
		if (TextUtils.isEmpty(appVersion)) {
			appVersion = appInfo.get(BUtility.VERSION_NAME);
		}
		messageData.appVersion = appVersion;

		String clientIp = paramsHashMap.get("ip");
		if (TextUtils.isEmpty(clientIp)) {
			clientIp = Constant.clientIp;
		}
		messageData.clientIp = clientIp;

		String cli_os = paramsHashMap.get("cli_os");
		if (TextUtils.isEmpty(cli_os)) {
			cli_os = "Android";
		}
		messageData.appOs = cli_os;
		
		String deviceType = paramsHashMap.get("device_type");
		if (TextUtils.isEmpty(deviceType)) {
			deviceType = android.os.Build.BRAND+" "+android.os.Build.MODEL;
		}
		messageData.deviceType = deviceType;
		String pixelInfo = paramsHashMap.get("pixel_info");
		if (TextUtils.isEmpty(pixelInfo)) {
			pixelInfo = BUtility.getPhonePixelInfo(context);
		}
		messageData.pixelInfo = pixelInfo;
		
		String netServicePro = paramsHashMap.get("isp");
		if (TextUtils.isEmpty(netServicePro)) {
			netServicePro = BUtility.getSimOperatorInfo(context);
		}
		messageData.netServicePro = netServicePro;
		
		String connNetType = paramsHashMap.get("nw_type");
		if (TextUtils.isEmpty(connNetType)) {
			connNetType = BUtility.getNetworkType(context);
		}
		messageData.connNetType = connNetType;
		messageData.amount = paramsHashMap.get("pay_money");
		messageData.rate = paramsHashMap.get("pay_rate");
		messageData.pmode = paramsHashMap.get("pay_mode");
		
		String httpRef = paramsHashMap.get("http_ref");
		if (TextUtils.isEmpty(httpRef)) {
			
			httpRef = BUtility.getConfigInfoByKey(context,
					 Constant.AF_AD_INFO_LOC, Constant.AF_AD_INFO_KEY);
		}
		messageData.httpRef = spiltAppKey(httpRef);
        String gameTime = paramsHashMap.get("gameTime");
        if (!TextUtils.isEmpty(gameTime)) {
            messageData.gameTime = gameTime;
        }
        messageData.recordId = BUtility.getUniqueFlag(context);
		messageData.pmode = paramsHashMap.get("pay_mode");
		
		String serverUrl = paramsHashMap.get("server_url");

		messageData.serverUrl = serverUrl;
		messageData.macAddress = BUtility.getMacAddress(context);
		messageData.androidId = BUtility.getAndroidId(context);
		messageData.api = paramsHashMap.get("api");
		BDebug.d("task", messageData.toString());
		return messageData;   
	}

	private String spiltAppKey(String key){
		String[] items = key.split("&");
		String result = "";
		if (null != items && items.length>0) {
			for (String item : items) {
				if (item.contains("pid")) {
					result = item;
					break;
				}
			}
		}
		if (!TextUtils.isEmpty(result)) {
			String[] subItems = result.split("=");
			if (null != subItems && subItems.length>0) {
				result = subItems[1];
			}
		}
		return result;
	
	}

}
