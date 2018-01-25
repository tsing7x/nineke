package com.boomegg.cocoslib.core.functions;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;

public class GetAppVersionFunction {
	
	public static String apply(){
		try {
			Context ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null){
				PackageManager packageManager = ctx.getPackageManager();
		        // getPackageName()是你当前类的包名，0代表是获取版本信息
		        PackageInfo packInfo;
				packInfo = packageManager.getPackageInfo(ctx.getPackageName(), 0);
				return packInfo.versionName;
			}
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		return "";
	}
}
