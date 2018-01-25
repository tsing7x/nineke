package com.boyaa.admobile.exception;

import java.lang.Thread.UncaughtExceptionHandler;

import com.boyaa.admobile.util.Constant;

import android.content.Context;

/**
 * 全局异常处理
 * 
 * @author Carrywen
 * 
 */
public class CrashHandler implements UncaughtExceptionHandler {
	public static final String TAG = "CrashHandler";
	private static CrashHandler INSTANCE = new CrashHandler();
	private Context mContext;
	private Thread.UncaughtExceptionHandler mDefaultHandler;

	private CrashHandler() {
	}

	public static CrashHandler getInstance() {
		return INSTANCE;
	}

	public void init(Context ctx) {
		mContext = ctx;
		mDefaultHandler = Thread.getDefaultUncaughtExceptionHandler();
		Thread.setDefaultUncaughtExceptionHandler(this);
	}

	@Override
	public void uncaughtException(Thread thread, Throwable ex) {
		 System.out.println("uncaughtException:"+ex.getMessage());  
		 if (Constant.IS_DEBUG_MODE) {
			 ex.printStackTrace();
		}
		
	}

}
