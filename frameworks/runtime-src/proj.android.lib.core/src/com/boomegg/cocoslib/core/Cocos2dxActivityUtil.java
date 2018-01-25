package com.boomegg.cocoslib.core;

import android.util.Log;

public class Cocos2dxActivityUtil {
	
	private static final String TAG = Cocos2dxActivityUtil.class.getSimpleName();
	
	public static void runOnResumed(Runnable runnable) {
		Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.runOnResumed(wrapRunnable(runnable));
		}
	}
	
	public static void runOnUIThread(Runnable runnable) {
		Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.runOnUiThread(wrapRunnable(runnable));
		}
	}
	
	public static void runOnGLThread(Runnable runnable) {
		Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.runOnGLThread(wrapRunnable(runnable));
		}
	}
	
	public static void runOnBGThread(Runnable runnable) {
		Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.getBackgroundThreadHandler().post(wrapRunnable(runnable));
		}
	}
	
	public static void runOnUiThreadDelay(Runnable runnable, long delayMillis) {
		Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.getUIThreadHandler().postDelayed(wrapRunnable(runnable), delayMillis);
		}
	}
	
	public static void runOnGLThreadDelay(final Runnable runnable, long delayMillis) {
		final Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.getUIThreadHandler().postDelayed(new Runnable() {
				@Override
				public void run() {
					ctx.runOnGLThread(wrapRunnable(runnable));
				}
			}, delayMillis);
		}
	}
	
	public static void runOnBGThreadDelay(Runnable runnable, long delayMillis) {
		Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.getBackgroundThreadHandler().postDelayed(wrapRunnable(runnable), delayMillis);
		}
	}
	
	static Runnable wrapRunnable(final Runnable runnable) {
		return new Runnable() {
			@Override
			public void run() {
				try {
					runnable.run();
				} catch(Exception e) {
					Log.e(TAG, e.getMessage(), e);
				}
			}
		};
	}
}
