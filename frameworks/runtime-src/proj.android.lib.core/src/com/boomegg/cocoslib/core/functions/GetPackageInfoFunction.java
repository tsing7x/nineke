package com.boomegg.cocoslib.core.functions;

import java.io.File;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONObject;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

import android.R.string;
import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.ResolveInfo;
import android.content.pm.Signature;
import android.net.Uri;
import android.util.Base64;
import android.util.Log;

public class GetPackageInfoFunction {

	/**
	 * 判断应用是否已安装
	 * 
	 * @param packageName
	 * @return
	 */
	@SuppressLint("NewApi")
	public static String isAppInstalled(String packageName) {
		Context context = Cocos2dxActivityWrapper.getContext();
		if(packageName == null || packageName.equals("")){
			packageName = context.getPackageName();
		}
		
		// 获取到一个PackageManager的instance
		final PackageManager packageManager = context.getPackageManager();
		// PERMISSION_GRANTED = 0
		List<PackageInfo> mPackageInfo = packageManager
				.getInstalledPackages(PackageManager.PERMISSION_GRANTED);
		boolean flag = false;
		long firstInstallTime = 0;
		long lastUpdateTime = 0;
		if (mPackageInfo != null) {
			String tempName = null;
			PackageInfo packInfo = null;
			for (int i = 0; i < mPackageInfo.size(); i++) {
				// 获取到AP包名
				packInfo = mPackageInfo.get(i);
				tempName = packInfo.packageName;
				if (tempName != null && tempName.equals(packageName)) {
					Log.v("GetPackageInfoFunction", "Package[" + packageName+ "]:is installed.");
					flag = true;
					firstInstallTime = packInfo.firstInstallTime;
					lastUpdateTime = packInfo.lastUpdateTime;
					break;
				}
			}
		}
		
		try {
			JSONObject jObj = new JSONObject();
			jObj.put("flag", String.valueOf(flag));
			jObj.put("firstInstallTime", String.valueOf(firstInstallTime));
			jObj.put("lastUpdateTime", String.valueOf(lastUpdateTime));
			
			return jObj.toString();
		} catch (Exception e) {
			// TODO: handle exception
			
		}
		return "";
	}

	public static String isUriAvailable(String url) {

		Context context = Cocos2dxActivityWrapper.getContext();
		final PackageManager packageManager = context.getPackageManager();
		final Intent intent = new Intent(Intent.ACTION_VIEW);
		List<String> packageNames = new ArrayList<String>();
		Uri uri = Uri.parse(url);
		intent.setData(uri);
		JSONObject jsobj = new JSONObject();
		boolean flag = false;

		List<ResolveInfo> resolveInfo = packageManager.queryIntentActivities(
				intent, PackageManager.MATCH_DEFAULT_ONLY);
		if (resolveInfo.size() > 0) {
			for (ResolveInfo info : resolveInfo) {
				ActivityInfo activityInfo = info.activityInfo;
				packageNames.add(activityInfo.packageName);
			}

			flag = true;
		}

		try {
			jsobj.put("packageNames", packageNames);
			jsobj.put("flag", flag);
			return jsobj.toString();
		} catch (Exception e) {
			// TODO: handle exception
		}

		return "";
	}

	public static boolean isIntentAvailable( String action) {
		Context context = Cocos2dxActivityWrapper.getContext();
		final PackageManager packageManager = context.getPackageManager();
		final Intent intent = new Intent(action);

		List<ResolveInfo> resolveInfo = packageManager.queryIntentActivities(
				intent, PackageManager.MATCH_DEFAULT_ONLY);
		if (resolveInfo.size() > 0) {
			return true;
		}
		return false;
	}

	/**
	 * 获取文件安装的Intent
	 * 
	 * @param file
	 * @return
	 */
	public static Intent getFileIntent(File file) {
		Uri uri = Uri.fromFile(file);
		String type = "application/vnd.android.package-archive";
		Intent intent = new Intent("android.intent.action.VIEW");
		intent.addCategory("android.intent.category.DEFAULT");
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		intent.setDataAndType(uri, type);
		return intent;
	}

	/**
	 * 判断应用是否正在运行
	 * 
	 * @param context
	 * @param packageName
	 * @return
	 */
	public static boolean isAppRunning(String packageName) {
		
		Context context = Cocos2dxActivityWrapper.getContext();
		if(packageName == null || packageName.equals("")){
			packageName = context.getPackageName();
		}
		
		ActivityManager am = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		List<RunningAppProcessInfo> list = am.getRunningAppProcesses();
		for (RunningAppProcessInfo appProcess : list) {
			String processName = appProcess.processName;
			if (processName != null && processName.equals(packageName)) {
				return true;
			}
		}
		return false;
	}
	
	
	public static void getKeyCode(String packageName) {
		Context context = Cocos2dxActivityWrapper.getContext();
		// Add code to print out the key hash
	    try {
	    	
	    	if(packageName == null){
	    		packageName =  context.getPackageName();
	    	}
	        PackageInfo info = context.getPackageManager().getPackageInfo(packageName,PackageManager.GET_SIGNATURES);
	        for (Signature signature : info.signatures) {
	            MessageDigest md = MessageDigest.getInstance("SHA");
	            md.update(signature.toByteArray());
	            Log.e("KeyHash:", Base64.encodeToString(md.digest(), Base64.DEFAULT));
	        }
	    } catch (NameNotFoundException e) {
	    	e.printStackTrace();
	    } catch (NoSuchAlgorithmException e) {
	    	e.printStackTrace();
	    }
		
	}
	
	public static void launchApp(String packageName) {
		Context context = Cocos2dxActivityWrapper.getContext();
		Intent intent = new Intent(); 
	  	PackageManager packageManager = context.getPackageManager(); 
	  	intent = packageManager.getLaunchIntentForPackage(packageName); 
	  	intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED | Intent.FLAG_ACTIVITY_CLEAR_TOP) ; 
	  	context.startActivity(intent);
		
	}

}
