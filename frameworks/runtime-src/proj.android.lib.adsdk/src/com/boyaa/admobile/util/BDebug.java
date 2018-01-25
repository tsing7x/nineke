package com.boyaa.admobile.util;

import android.util.Log;

/**
 * 日志输出类
 * 
 * @author Carrywen
 * 
 */
public class BDebug {

	public static void v(String tag, String msg) {
		if (Constant.IS_DEBUG_MODE) {
			Log.v(tag, msg);
		}
	}

	public static void d(String tag, String msg) {
		if (Constant.IS_DEBUG_MODE) {
			Log.d(tag, msg);
		}
	}

	public static void d(String tag, String msg, Throwable e) {
		if (Constant.IS_DEBUG_MODE) {
			Log.d(tag, msg, e);
		}
	}

	public static void i(String tag, String msg) {
		if (Constant.IS_DEBUG_MODE) {
			Log.i(tag, msg);
		}
	}

	public static void w(String tag, String msg) {
		if (Constant.IS_DEBUG_MODE) {
			Log.w(tag, msg);
		}
	}

	public static void e(String tag, String msg) {
		if (Constant.IS_DEBUG_MODE) {
			Log.e(tag, msg);
		}
	}

	public static void e(String tag, String message, Throwable e) {
		if (Constant.IS_DEBUG_MODE) {
			Log.e(tag, message, e);
		}
	}

}
