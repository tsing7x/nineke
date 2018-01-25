package com.boomegg.cocoslib.core.functions;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import org.json.JSONException;
import org.json.JSONObject;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

/**
 * The BOOMEGG Inc 
 * Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved. 
 * @author The Mobile Dev Team
 *          Viking<viking@boomegg.com>
 * 2014-11-5
 */
public class GetDeviceInfoFunction {
	/**
	 * json encode
	 * @return
	 */
	public static String apply(){
		String encodeString = "";
		try {
			JSONObject json = new JSONObject();
			json.put("deviceId", getDeviceId());
			json.put("deviceName", getDeviceAccount());
			json.put("deviceModel", getDeviceModel());
			json.put("installInfo", getInstallInfo());
			json.put("cpuInfo", getCpuInfo());
			json.put("ramSize", getTotalRAMSize());
			json.put("simNum", getSimNumber());
			json.put("networkType", getNetworkType());
			json.put("phoneNumbers", getPhoneNumbers());
			json.put("location", getLocation());
			encodeString = json.toString();
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return encodeString;
	}
	
	/**
	 * 璁惧ID imei
	 * @return
	 */
	private static String getDeviceId() {
		String deviceId = null;
		try{
			Context ctx = Cocos2dxActivityWrapper.getContext();
			TelephonyManager teleMgr = (TelephonyManager) ctx.getSystemService(Context.TELEPHONY_SERVICE);
			if(teleMgr != null) {
				deviceId = teleMgr.getDeviceId();
				if(TextUtils.isEmpty(deviceId) || "000000000000000".equals(deviceId)) {
					deviceId = "";
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		return deviceId == null ? "" : deviceId;
	}	
	
	/** 获取手机电话号码（注意，不能在程序正在启动的时候调用该类型的方法，高级机子可能会crash） */
	public static String getPhoneNumbers() {
		if(!haveSimCard()){
			return "";
		}
		Context ctx = Cocos2dxActivityWrapper.getContext();;
		TelephonyManager tm = (TelephonyManager)ctx.getSystemService(Context.TELEPHONY_SERVICE);
		String res = tm.getLine1Number();
		if(res == null){
			res = "";
		}
		return res;
	}
	
	/**
	 * 是否有sim卡
	 */
	public static boolean haveSimCard(){
		Context ctx = Cocos2dxActivityWrapper.getContext();;
		TelephonyManager tm = (TelephonyManager)ctx.getSystemService(Context.TELEPHONY_SERVICE);
		if(tm.getSimState()==TelephonyManager.SIM_STATE_ABSENT){
			return false;
		}
		return true;
	}
    
    /** 获取经纬度 */
	public static String getLocation() {
		Context ctx = Cocos2dxActivityWrapper.getContext();;
		double latitude=0.0;  
		double longitude =0.0;
		LocationManager locationManager = (LocationManager)ctx.getSystemService(Context.LOCATION_SERVICE);  
        if(locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)){  
            Location location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);  
            if(location != null){  
                latitude = location.getLatitude();  
                longitude = location.getLongitude(); 
                return latitude + "," + longitude;
            }  
        }else{   
            //locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 10000, 0, null);
        	LocationListener locationListener = new LocationListener() {  
                
                // Provider的状态在可用、暂时不可用和无服务三个状态直接切换时触发此函数  
                @Override  
                public void onStatusChanged(String provider, int status, Bundle extras) {  
                      
                }  
                  
                // Provider被enable时触发此函数，比如GPS被打开  
                @Override  
                public void onProviderEnabled(String provider) {  
                      
                }  
                  
                // Provider被disable时触发此函数，比如GPS被关闭   
                @Override  
                public void onProviderDisabled(String provider) {
                      
                }
                //当坐标改变时触发此函数，如果Provider传进相同的坐标，它就不会被触发   
                @Override  
                public void onLocationChanged(Location location) {  
                }  
            };  
            locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 10000, locationListener, ctx.getMainLooper());
            Location location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
            if(location != null){    
                latitude = location.getLatitude(); //经度     
                longitude = location.getLongitude(); //纬度
                return latitude + "," + longitude;
            }
        }  
        return "";
	}
	
	/**
	 * 鐢ㄦ埛鐧诲綍鐨勯閫夎胺姝岃处鍙�
	 * @return
	 */
	private static String getDeviceAccount() {
		String account = null;
		try{
			Context ctx = Cocos2dxActivityWrapper.getContext();
			AccountManager accMgr = (AccountManager) ctx.getSystemService(Context.ACCOUNT_SERVICE);
			if(accMgr != null) {
				Account[] accounts = accMgr.getAccountsByType("com.google");
				List<String> possibleEmails = new ArrayList<String>();
				if(accounts != null && accounts.length > 0){
					for(Account ac : accounts){
						possibleEmails.add(ac.name);
					}
				}
				if(!possibleEmails.isEmpty() && possibleEmails.get(0) != null){
					String email = possibleEmails.get(0);
					String[] parts = email.split("@");
					if(parts != null && parts.length > 0 && parts[0] != null){
						account = parts[0];
					}
				}
			}			
		}catch(Exception e){
			e.printStackTrace();
		}
		return account == null ? "" : account;
	}	
	
	private static String getDeviceModel(){
		String brand = "";
		String model = "";
		int sdk_int = 0;
		String release = "";
		try{
			brand = android.os.Build.BRAND;
			model = Build.MODEL;
			sdk_int = Build.VERSION.SDK_INT;
			release = Build.VERSION.RELEASE;
		}catch(Exception e){
			e.printStackTrace();
		}
		return brand + "_" + model + "|" + sdk_int + "|" + release;
	}
	
	@SuppressLint("NewApi")
	private static String getInstallInfo(){
		try {
			Context ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null){
				PackageManager packageManager = ctx.getPackageManager();
		        // getPackageName()鏄綘褰撳墠绫荤殑鍖呭悕锛�0浠ｈ〃鏄幏鍙栫増鏈俊鎭�
		        PackageInfo packInfo;
				packInfo = packageManager.getPackageInfo(ctx.getPackageName(), 0);
				String[] installInfo = new String[2];
				if(Build.VERSION.SDK_INT > 9){
					installInfo[0] = new SimpleDateFormat("yyyy-M-dd HH:mm:ss", Locale.getDefault()).format(new Date(packInfo.firstInstallTime));
					installInfo[1] = new SimpleDateFormat("yyyy-M-dd HH:mm:ss", Locale.getDefault()).format(new Date(packInfo.lastUpdateTime));					
				}else{
					String dir = packInfo.applicationInfo.publicSourceDir;
					installInfo[0] = installInfo[1] = 
							new SimpleDateFormat("yyyy-M-dd HH:mm:ss", Locale.getDefault()).format(new Date(new File(dir).lastModified()));
				}
				return installInfo[0] + "|" + installInfo[1];
			}
		}catch (Exception e){
			e.printStackTrace();
		}
		return "" + "|" +  "";
	}	
	
	private static String getCpuInfo(){
        String str1 = "/proc/cpuinfo";  
        String str2 = "";  
        String retString = "" + "|" + "";
        String[] cpuInfo = { "", "" }; // 1-cpu鍨嬪彿 //2-cpu棰戠巼   
        String[] arrayOfString;  
        try {  
            FileReader fr = new FileReader(str1);  
            BufferedReader localBufferedReader = new BufferedReader(fr, 8192);  
            str2 = localBufferedReader.readLine();  
            arrayOfString = str2.split("\\s+");  
            for (int i = 2; i < arrayOfString.length; i++) {  
                cpuInfo[0] = cpuInfo[0] + arrayOfString[i] + " ";  
            }  
            str2 = localBufferedReader.readLine();  
            arrayOfString = str2.split("\\s+");  
            cpuInfo[1] += arrayOfString[2];  
            localBufferedReader.close(); 
            retString = cpuInfo[0] + "|" + cpuInfo[1];
        }catch(Exception e) {
        	e.printStackTrace();
        }
        // Log.i(TAG, "cpuinfo:" + cpuInfo[0] + " " + cpuInfo[1]);   
        return retString; 		
	}
	
    // RAM 鎬诲ぇ灏�   
	private static String getTotalRAMSize() {  
        String str1 = "/proc/meminfo";// 绯荤粺鍐呭瓨淇℃伅鏂囦欢   
        String str2;  
        String[] arrayOfString;  
        long totalSize = 0;  
        try {  
            FileReader localFileReader = new FileReader(str1);  
            BufferedReader localBufferedReader = new BufferedReader(  
                    localFileReader, 8192);  
            str2 = localBufferedReader.readLine();// 璇诲彇meminfo绗竴琛岋紝绯荤粺鎬诲唴瀛樺ぇ灏�   
            arrayOfString = str2.split("\\s+");  
            // 鑾峰緱绯荤粺鎬诲唴瀛橈紝鍗曚綅鏄疜B锛屼箻浠�1024杞崲涓築yte   
            totalSize = Integer.valueOf(arrayOfString[1]).intValue() * 1024;  
            localBufferedReader.close();  
  
        } catch (Exception e) { 
        	e.printStackTrace();
        }  
        return String.valueOf(totalSize);  
    }	
    
    //SIM
	private static String getSimNumber(){
		String SimSerialNumber = null;
		try{
			Context ctx = Cocos2dxActivityWrapper.getContext();
	    	TelephonyManager tm = (TelephonyManager)ctx.getSystemService(Context.TELEPHONY_SERVICE); 
	    	SimSerialNumber = tm.getSimSerialNumber();
		}catch(Exception e){
			e.printStackTrace();
		}   
    	return SimSerialNumber == null ? "" : SimSerialNumber;
    }
	
	//NetworkType
	private static String getNetworkType() {
		String netType = null;
		try{
			Context ctx = Cocos2dxActivityWrapper.getContext();
			ConnectivityManager connectivityManager = (ConnectivityManager) ctx.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
			if (networkInfo == null) {
				netType =  "";
			}
			int nType = networkInfo.getType();
			if (nType == ConnectivityManager.TYPE_MOBILE) {
				netType = "mobile" + "_" + networkInfo.getSubtypeName();
			} else if (nType == ConnectivityManager.TYPE_WIFI) {
				netType = "wifi";
			}			
		}catch(Exception e){
			e.printStackTrace();
		}
		return netType == null ? "" : netType;
	}
}
