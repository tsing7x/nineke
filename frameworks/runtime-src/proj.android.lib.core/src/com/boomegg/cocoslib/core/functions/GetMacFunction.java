package com.boomegg.cocoslib.core.functions;

import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.net.NetworkInterface;
import java.util.Collections;
import java.util.List;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

public class GetMacFunction {
	public static String TAG = GetMacFunction.class.getSimpleName();
	public static final String STORE_NAME = "GetMacFunction";
	public static final String STORE_KEY_MAC = "MAC_ADDRESS";
	private static String mac = null;
	private static final String EMPTY_MAC = "00:00:00:00:00:00";
	private static final String MIUI_EMPTY_MAC = "02:00:00:00:00:00";
	public static String apply() {
		Context ctx = Cocos2dxActivityWrapper.getContext();
		String preMac = "";
		if(ctx != null) {
			SharedPreferences sp = ctx.getSharedPreferences(STORE_NAME, Activity.MODE_PRIVATE);
			preMac = sp.getString(STORE_KEY_MAC, "");
			if(TextUtils.isEmpty(mac)) {
				mac = getMacFromWifiManager(ctx);
				Log.d(TAG, "getMacFromWifiManager:" + mac);
				if(TextUtils.isEmpty(mac) || EMPTY_MAC.equals(mac) || MIUI_EMPTY_MAC.equals(mac)) {
					mac = getMacFromShellWlan();
					Log.d(TAG, "getMacFromShellWlan:" + mac);
				}
				if(TextUtils.isEmpty(mac) || EMPTY_MAC.equals(mac) || MIUI_EMPTY_MAC.equals(mac)) {
					mac = getMACFromNetworkInterface("wlan0");
					Log.d(TAG, "getMACFromNetworkInterface(wlan0):" + mac);
				}
				if(EMPTY_MAC.equals(mac) || MIUI_EMPTY_MAC.equals(mac)) {
					mac = "";
				}
			}
			
			if("".equals(preMac)){
				preMac = mac;
				SharedPreferences.Editor ed = sp.edit();
				ed.putString(STORE_KEY_MAC, preMac);
				ed.commit();
			}
		}
		return preMac;
	}
	
	public static String getMacAddr(){
		if(mac == null){
			apply();
		}
		return mac;
	}
	
	private static String getMacFromWifiManager(Context ctx) {
		try {
			WifiManager wifiMgr = (WifiManager) ctx.getSystemService(Context.WIFI_SERVICE);
			String mac;
			if(wifiMgr != null) {
				WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
				if(wifiInfo != null) {
					mac = wifiInfo.getMacAddress();
					if(!TextUtils.isEmpty(mac) && !EMPTY_MAC.equals(mac) && !MIUI_EMPTY_MAC.equals(mac)) {
						//鐩存帴浠巜ifimanager鑾峰彇鍒癿ac
						return mac;
					} else {
						//鐩存帴鑾峰彇澶辫触锛屽皾璇曟墦寮�wifi閲嶈瘯
						boolean turnOnWifiFlag = false;
						try {
							int wifiState = wifiMgr.getWifiState();
							if(wifiState != WifiManager.WIFI_STATE_ENABLED && wifiState != WifiManager.WIFI_STATE_ENABLING) {
								turnOnWifiFlag = true;
								wifiMgr.setWifiEnabled(true);
							}
							wifiInfo = wifiMgr.getConnectionInfo();
							if(wifiInfo == null || TextUtils.isEmpty(wifiInfo.getMacAddress())) {
								//鎵撳紑wifi閲嶈瘯涓嶆垚鍔燂紝绛夊緟100ms鍚庡啀娆￠噸璇�
								try {
									Thread.sleep(100);
								} catch(Exception e) {}
								wifiInfo = wifiMgr.getConnectionInfo();
							}
							if(wifiInfo != null && !TextUtils.isEmpty((mac = wifiInfo.getMacAddress()))) {
								//閲嶈瘯鎴愬姛浠巜ifimanager鑾峰彇鍒癿ac
								return mac;
							}
						} finally {
							//鎵嬪伐鎵撳紑鐨剋ifi瑕佸叧闂�
							if(turnOnWifiFlag) {
								wifiMgr.setWifiEnabled(false);
							}
						}
					}
				}
			}
		} catch(Exception e) {
			Log.e(TAG, e.getMessage(), e);
		}
		return null;
	}
	
	@SuppressLint("NewApi")
	private static String getMACFromNetworkInterface(String interfaceName) {
		if(Build.VERSION.SDK_INT >= 9) {
			try {
				List<NetworkInterface> interfaces = Collections.list(NetworkInterface.getNetworkInterfaces());
				for (NetworkInterface intf : interfaces) {
					if (interfaceName != null) {
						if (!intf.getName().equalsIgnoreCase(interfaceName)) {
							continue;
						}
					}
					byte[] mac = intf.getHardwareAddress();
					if (mac == null) {
						return null;
					}
					StringBuilder buf = new StringBuilder();
					for (int idx = 0; idx < mac.length; idx++) {
						buf.append(String.format("%02X:", mac[idx]));
					}
					if (buf.length() > 0) {
						buf.deleteCharAt(buf.length() - 1);
					}
					return buf.toString();
				}
			} catch (Exception e) {
				Log.e(TAG, e.getMessage(), e);
			}
		}
		return null;
	}
	
	private static String getMacFromShellWlan() {
		InputStreamReader isr = null;
        LineNumberReader lnr = null;
        Process proc = null;
        String mac;
		try {
			proc = Runtime.getRuntime().exec("cat /sys/class/net/wlan0/address ");
			isr = new InputStreamReader(proc.getInputStream());
			lnr = new LineNumberReader(isr);
			
			while((mac = lnr.readLine()) != null) {
				mac = mac.trim();
				if(!TextUtils.isEmpty(mac)) {
					//Linux鍛戒护鎴愬姛鍙栧埌mac
					return mac;
				}
			}
		} catch (Exception e) {
			Log.e(TAG, e.getMessage(), e);
		} finally {
			if(lnr != null) {
				try {
					lnr.close();
				} catch(Exception e) {}
			}
			if(isr != null) {
				try {
					isr.close();
				} catch(Exception e) {}
			}
			if(proc != null) {
				try {
					proc.destroy();
				} catch(Exception e) {}
			}
		}
		return null;
	}
}
