package com.boyaa.admobile.util;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningServiceInfo;
import android.app.Service;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.WindowManager;
import com.boyaa.admobile.entity.BasicMessageData;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.*;
import java.security.MessageDigest;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * AD SDK工具集
 * 
 * @author Carrywen
 * 
 */
public class BUtility {
	public static final String TAG = "BUtility";
	public static final String PCK_NAME = "packageName";
	public static final String VERSION_NAME = "version_name";
	public static final String VERSION_CODE = "version_code";
	public static final String PCK_LABEL = "packageLabel";

	/**
	 * 读取配置文件信息（SharePreferences中的）
	 * 
	 * @param context
	 * @param fileName
	 * @param key
	 * @return
	 */
	public static String getConfigInfoByKey(Context context, String fileName,
			String key) {
		SharedPreferences sPreferences = context.getSharedPreferences(fileName,
				Context.MODE_PRIVATE);
		String info = sPreferences.getString(key, "");
		BDebug.d(TAG, "result=" + info);
		return info;
	}

	/**
	 * 获取网络类型
	 * 
	 * @param context
	 * @return
	 */
	public static String getNetworkType(Context context) {
		final ConnectivityManager connectivityManager = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		final NetworkInfo networkInfo = connectivityManager
				.getActiveNetworkInfo();

		if (networkInfo == null || !networkInfo.isAvailable()) {
			return "";
		}

		if (networkInfo.getType() == ConnectivityManager.TYPE_WIFI) {
			return "wifi";
		}

		if (isFastMobileNetwork(context)) {
			return "3G";
		} else {
			return "2G";
		}

	}

	private static boolean isFastMobileNetwork(Context context) {
		TelephonyManager telephonyManager = (TelephonyManager) context
				.getSystemService(Context.TELEPHONY_SERVICE);

		switch (telephonyManager.getNetworkType()) {
		case TelephonyManager.NETWORK_TYPE_1xRTT:
			return false; // ~ 50-100 kbps
		case TelephonyManager.NETWORK_TYPE_CDMA:
			return false; // ~ 14-64 kbps
		case TelephonyManager.NETWORK_TYPE_EDGE:
			return false; // ~ 50-100 kbps
		case TelephonyManager.NETWORK_TYPE_EVDO_0:
			return true; // ~ 400-1000 kbps
		case TelephonyManager.NETWORK_TYPE_EVDO_A:
			return true; // ~ 600-1400 kbps
		case TelephonyManager.NETWORK_TYPE_GPRS:
			return false; // ~ 100 kbps
		case TelephonyManager.NETWORK_TYPE_HSDPA:
			return true; // ~ 2-14 Mbps
		case TelephonyManager.NETWORK_TYPE_HSPA:
			return true; // ~ 700-1700 kbps
		case TelephonyManager.NETWORK_TYPE_HSUPA:
			return true; // ~ 1-23 Mbps
		case TelephonyManager.NETWORK_TYPE_UMTS:
			return true; // ~ 400-7000 kbps
		case TelephonyManager.NETWORK_TYPE_IDEN:
			return false; // ~25 kbps
		case TelephonyManager.NETWORK_TYPE_UNKNOWN:
			return false;
		default:
			return false;

		}
	}

    /**
     * 获取字符串中的数字串
     *
     * @param numStr
     * @return
     */
    public static String getNumericStr(String numStr) {
        if (TextUtils.isEmpty(numStr)) {
            return "0";
        }
        StringBuffer stringBuffer = null;
        if (isNumeric(numStr)) {
            return numStr;
        } else {
            stringBuffer = new StringBuffer();
            for (int i = 0; i < numStr.length(); i++) {
                if (numStr.charAt(i) >= 46 && numStr.charAt(i) <= 57) {
                    stringBuffer.append(numStr.charAt(i));
                }
            }
        }
        String result = stringBuffer.toString();
        if (TextUtils.isEmpty(result)) {
            return "0";
        } else {
            if (isNumeric(result)) {
                return result;
            } else {
                return "0";
            }
        }
    }

    /**
     * 判断是否为数字串 包括.
     *
     * @param str
     * @return
     */
    public static boolean isNumeric(String str) {
        for (int i = str.length(); --i >= 0; ) {
            if (str.charAt(i) < 46 || str.charAt(i) > 57) {
                return false;
            }

        }
        return true;
    }

    /**
	 * 获取设备名称
	 * 
	 * @return
	 */
	public static String getDeviceName() {
		String deviceName = (new Build()).MODEL;
		return deviceName != null ? deviceName.replace(" ", "_") : "";
	}

	/**
	 * 获取设备androidId
	 * 
	 * @param context
	 * @return
	 */
	public static String getAndroidId(Context context) {
		String androidID = Settings.Secure.getString(
				context.getContentResolver(), "android_id");
		if (TextUtils.isEmpty(androidID)) {
			return "";
		} else {
			return androidID;
		}
	}

	/**
	 * 获取手机mac地址
	 * 
	 * @param context
	 * @return
	 */
	public static String getMacAddress(Context context) {
		WifiManager wifiMan = (WifiManager) context.getSystemService("wifi");
		WifiInfo wifiInf = wifiMan.getConnectionInfo();
		String macAddress = wifiInf.getMacAddress();
		if (TextUtils.isEmpty(macAddress)) {
			return "";
		} else {
			return macAddress;
		}
	}

	/**
	 * JSON字符串转MAP
	 * 
	 * @param jsonParam
	 * @return
	 */
	public static HashMap jsonToMap(String jsonParam) {
		HashMap tempMap = new HashMap();
		if (TextUtils.isEmpty(jsonParam)) {
			return tempMap;
		}
		try {
			JSONObject localJSONObject;
			Iterator localIterator;
			if (!TextUtils.isEmpty(jsonParam)) {
				localJSONObject = new JSONObject(jsonParam);
				localIterator = localJSONObject.keys();
				String str = null;
				while (localIterator.hasNext()) {
					str = (String) localIterator.next();
					tempMap.put(str, localJSONObject.getString(str));
				}
			}
		} catch (Exception e) {
			BDebug.e(TAG, "json error", e);
		}

		return tempMap;
	}

	/**
	 * 唯一的设备ID： GSM手机的 IMEI 和 CDMA手机的 MEID.
	 * 
	 * @param context
	 * @return
	 */
	public static String getUniqueDeviceId(Context context) {
		TelephonyManager tmManager = (TelephonyManager) context
				.getSystemService(Service.TELEPHONY_SERVICE);
		String deviceId = tmManager.getDeviceId();
		if (TextUtils.isEmpty(deviceId)) {
			deviceId = "";
		}
		return deviceId;
	}

	/**
	 * 唯一的用户ID： 例如：IMSI(国际移动用户识别码) for a GSM phone.
	 * 
	 * @param context
	 * @return
	 */
	public static String getUniqueUserId(Context context) {
		TelephonyManager tmManager = (TelephonyManager) context
				.getSystemService(Service.TELEPHONY_SERVICE);
		String userId = tmManager.getSubscriberId();
		if (TextUtils.isEmpty(userId)) {
			userId = "";
		}
		return userId;
	}

	/**
	 * 将key-value形式的参数转换成签名
	 * 
	 * @return
	 * 
	 *         public static String getSig(HashMap parameterMap) {
	 *         TreeSet<String> ts = new TreeSet<String>(); if (parameterMap !=
	 *         null) { Iterator localIterator =
	 *         parameterMap.entrySet().iterator(); String key=null; String value
	 *         = null; while (localIterator.hasNext()) { Map.Entry entry =
	 *         (Map.Entry)localIterator.next(); try { key = (String)
	 *         entry.getKey(); value = (String) entry.getValue(); ts.add( key+
	 *         "=" + URLEncoder.encode(value==null?"":value, "utf-8")); } catch
	 *         (Exception localException) { localException.printStackTrace(); }
	 *         } } StringBuffer sb = new StringBuffer(); for (String ob : ts) {
	 *         sb.append(ob); } String md5Str = encode("MD5", encode("SHA1",
	 *         sb.toString())+"lk;ajsd$123!@S2iasf"); BDebug.d("getSig",
	 *         md5Str); return md5Str; }
	 */

	public static String encode(String algorithm, String str) {
		if (str == null) {
			return null;
		}
		try {
			MessageDigest messageDigest = MessageDigest.getInstance(algorithm);
			messageDigest.update(str.getBytes());
			return getFormattedText(messageDigest.digest());
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private static final char[] HEX_DIGITS = { '0', '1', '2', '3', '4', '5',
			'6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

	private static String getFormattedText(byte[] bytes) {
		int len = bytes.length;
		StringBuilder buf = new StringBuilder(len * 2);
		for (int j = 0; j < len; j++) {
			buf.append(HEX_DIGITS[(bytes[j] >> 4) & 0x0f]);
			buf.append(HEX_DIGITS[bytes[j] & 0x0f]);
		}
		return buf.toString();
	}

	/**
	 * 获取unix时间戳
	 * 
	 * @return
	 */
	public static String getUnixTimestamp() {
		Calendar calendar = Calendar.getInstance();
		return calendar.getTimeInMillis() / 1000 + "";
	}

	/**
	 * 获取1点，定时任务
	 * 
	 * @return
	 */
	public static long getAlarmTime() {
		Calendar calendar = Calendar.getInstance();
		calendar.set(Calendar.HOUR_OF_DAY, 1);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		return calendar.getTimeInMillis();
	}

	/**
	 * 获取网络提供商信息(国别——供应商代码——供应商名称)
	 * 
	 * @param context
	 * @return
	 */
	public static String getSimOperatorInfo(Context context) {
		TelephonyManager tmManager = (TelephonyManager) context
				.getSystemService(Service.TELEPHONY_SERVICE);
		if (TextUtils.isEmpty(tmManager.getSimOperator())) {
			return "";
		}
		return tmManager.getSimCountryIso() + "_" + tmManager.getSimOperator()
				+ "_" + tmManager.getSimOperatorName();
	}

	/**
	 * 获取手机分辨率
	 * 
	 * @param context
	 * @return
	 */
	public static String getPhonePixelInfo(Context context) {
		WindowManager wManager = (WindowManager) context
				.getSystemService(Service.WINDOW_SERVICE);
		DisplayMetrics dm = new DisplayMetrics();
		wManager.getDefaultDisplay().getMetrics(dm);

		return dm.heightPixels + "_" + dm.widthPixels;
	}

	/**
	 * 天的时间戳
	 * 
	 * @return
	 */
	public static String getDayTimeStamp(int day) {
		SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
		Calendar calendar = Calendar.getInstance();
		if (day != 0) {
			calendar.add(Calendar.DAY_OF_MONTH, day);
		}
		String time = "";
		try {
			time = format.parse(format.format(calendar.getTime())).getTime()
					/ 1000 + "";
		} catch (ParseException e) {
			BDebug.e(TAG, "getDayTimeStamp error", e);
		}
		return time;
	}

	public static boolean isWithUnixTime(String timestamp, int day) {
		long compareTime = Long.parseLong(getDayTimeStamp(day));
		long pointTime = Long.parseLong(timestamp);
		if (pointTime > compareTime) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 获取唯一标示
	 * 
	 * @param context
	 * @return
	 */
	public static String getUniqueFlag(Context context) {
		String deviceId = getUniqueDeviceId(context);
		String timeStamp = getUnixTimestamp();
		String uniqueCode = deviceId + timeStamp;
		BDebug.d(TAG, uniqueCode);
		return uniqueCode;
	}

	/**
	 * 判断该时间戳是否属于当天
	 * 
	 * @param timestamp
	 * @return
	 */
	public static boolean isWithinDayRecord(String timestamp, int day) {
		Calendar nowDay = Calendar.getInstance();
		Calendar pointDay = Calendar.getInstance();
		pointDay.setTimeInMillis(Long.parseLong(timestamp) * 1000);
		if (nowDay.get(Calendar.YEAR) != pointDay.get(Calendar.YEAR)) {
			return false;
		}
		if (nowDay.get(Calendar.MONTH) != pointDay.get(Calendar.MONTH)) {
			return false;
		}
		if (nowDay.get(Calendar.DAY_OF_MONTH)
				- pointDay.get(Calendar.DAY_OF_MONTH) <= day) {
			return true;
		}
		return false;
	}

	public static String getNetIp() {
		URL infoUrl = null;
		InputStream inStream = null;
		try {
			infoUrl = new URL("http://iframe.ip138.com/ic.asp");
			URLConnection connection = infoUrl.openConnection();
			HttpURLConnection httpConnection = (HttpURLConnection) connection;

			int responseCode = httpConnection.getResponseCode();

			if (responseCode == HttpURLConnection.HTTP_OK) {
				inStream = httpConnection.getInputStream();
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(inStream, "utf-8"));
				StringBuilder strber = new StringBuilder();
				String line = null;

				while ((line = reader.readLine()) != null)
					strber.append(line + "\n");
				inStream.close();
				// 从反馈的结果中提取出IP地址
				int start = strber.indexOf("[");
				int end = strber.indexOf("]", start + 1);
				line = strber.substring(start + 1, end);
				return line;
			}
		} catch (Exception e) {
			BDebug.e(TAG, "getNetIp error", e);
		}
		return null;
	}

	/**
	 * wifi服务获取IP地址
	 * 
	 * @param context
	 * @returnd
	 */
	public static void getClientIp(Context context) {
		String ipAddr = getNetIp();
		if (!TextUtils.isEmpty(ipAddr)) {
			Constant.clientIp = ipAddr;
			return;
		}
		WifiManager wifiManager = (WifiManager) context
				.getSystemService(Context.WIFI_SERVICE);
//		if (!wifiManager.isWifiEnabled()) {
//			wifiManager.setWifiEnabled(true);
//		}
		WifiInfo wifiInfo = wifiManager.getConnectionInfo();
		int ipAddress = wifiInfo.getIpAddress();
		String ip = "";

		if (0 == ipAddress) {
			ip = getHostIp(context);

		} else {
			ip = intToIp(ipAddress);
		}
		Constant.clientIp = ip;
	}

	private static String intToIp(int i) {
		return (i & 0xFF) + "." + ((i >> 8) & 0xFF) + "." + ((i >> 16) & 0xFF)
				+ "." + (i >> 24 & 0xFF);
	}

	/**
	 * 获取android hostIp地址 通过GPS形式
	 * 
	 * @param context
	 * @return
	 */
	public static String getHostIp(Context context) {
		try {
			for (Enumeration<NetworkInterface> en = NetworkInterface
					.getNetworkInterfaces(); en.hasMoreElements();) {

				NetworkInterface intf = en.nextElement();

				for (Enumeration<InetAddress> enumIpAddr = intf
						.getInetAddresses(); enumIpAddr.hasMoreElements();) {
					InetAddress inetAddress = enumIpAddr.nextElement();
					if (!inetAddress.isLoopbackAddress()) {
						return inetAddress.getHostAddress().toString();
					}
				}
			}
		}

		catch (SocketException ex) {
			BDebug.e(TAG, "getHostIp error", ex);
		}
		return "";
	}

	/**
	 * 获取本应用包名
	 * 
	 * @param context
	 * @return
	 */
	public static Map<String, String> getPackageInfo(Context context) {
		PackageInfo info;
		Map<String, String> packInfo = new HashMap<String, String>();
		String packageNames = "";
		String versionName = "";
		String versionCode = "";
		String packageLabel = "";
		try {
			info = context.getPackageManager().getPackageInfo(
					context.getPackageName(), 0);
			ApplicationInfo applicationInfo = null;
			applicationInfo = context.getPackageManager().getApplicationInfo(
					context.getPackageName(), 0);

			packageNames = info.packageName;
			versionCode = info.versionCode + "";
			versionName = info.versionName;
			packageLabel = (String) context.getPackageManager()
					.getApplicationLabel(applicationInfo);

		} catch (NameNotFoundException e) {
			BDebug.e(TAG, "getPackageInfo error", e);
		} finally {
			packInfo.put(PCK_NAME, packageNames);
			packInfo.put(VERSION_NAME, versionName);
			packInfo.put(VERSION_CODE, versionCode);
			packInfo.put(PCK_LABEL, packageLabel);
		}
		return packInfo;

	}

	/**
	 * 判断服务是否开启
	 * 
	 * @param serviceName
	 * @param context
	 * @return
	 */
	public static boolean isServiceLaunch(Context context, String serviceName) {
		ActivityManager mActivityManager = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		List<RunningServiceInfo> mServiceList = mActivityManager
				.getRunningServices(50);
		for (RunningServiceInfo serviceInfo : mServiceList) {
			if (serviceName.equals(serviceInfo.service.getClassName())) {
				return true;
			}
		}
		return false;
	}

	public static HashMap<String, String> convertDataToMap(BasicMessageData data) {

		Map<String, String> dataMap = new HashMap<String, String>();
		StringBuffer sbBuffer = new StringBuffer();
		sbBuffer.append("{");
		dataMap.put("api", data.api);
		dataMap.put("lts_at", data.triggerTimestamp);
		dataMap.put("sig", data.sig);

		sbBuffer.append("\"uid\":").append("\"" + data.uid + "\"").append(",")
				.append("\"platform_uid\":")
				.append("\"" + data.platformUid + "\"").append(",")
				.append("\"udid\":").append("\"" + data.deviceId + "\"")
				.append(",").append("\"et_id\":")
				.append("\"" + data.eventType + "\"").append(",")
				.append("\"lts_at\":")
				.append("\"" + data.triggerTimestamp + "\"").append(",")
				.append("\"ip\":").append("\"" + data.clientIp + "\"")
				.append(",").append("\"cli_verinfo\":")
				.append("\"" + data.appVersion + "\"").append(",")
				.append("\"cli_os\":").append("\"" + data.appOs + "\"")
				.append(",").append("\"device_type\":")
				.append("\"" + data.deviceType + "\"").append(",")
				.append("\"pixel_info\":").append("\"" + data.pixelInfo + "\"")
				.append(",").append("\"isp\":")
				.append("\"" + data.netServicePro + "\"").append(",")
				.append("\"nw_type\":").append("\"" + data.connNetType + "\"")
				.append(",").append("\"pay_money\":")
				.append("\"" + data.amount + "\"").append(",")
				.append("\"pay_rate\":").append("\"" + data.rate + "\"")
				.append(",").append("\"pay_mode\":")
				.append("\"" + data.pmode + "\"").append(",")
				.append("\"http_ref\":").append("\"" + data.httpRef + "\"")
				.append(",").append("\"mac\":")
				.append("\"" + data.macAddress + "\"").append(",")
				.append("\"android_id\":").append("\"" + data.androidId + "\"")
                .append(",").append("\"et_val\":").append("\"" + data.gameTime + "\"")
                .append("}");
		String dataJson = sbBuffer.toString();
		BDebug.d(TAG, dataJson);
		dataMap.put("data", dataJson);
		return (HashMap<String, String>) dataMap;
	}


}
