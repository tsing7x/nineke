package com.boomegg.cocoslib.byactivity;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.util.Log;

import com.boomegg.cocoslib.byactivity.ByActivityPlugin;
import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

public class ByActivityBridge {
static final String TAG = ByActivityPlugin.class.getSimpleName();
	
	private static int byActivityCallbackMethodId = -1;
	private static int byActivityCloseCallBackMethodId = -1;
	
	private static ByActivityPlugin getByActivityPlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
				.getPluginManager().findPluginByClass(ByActivityPlugin.class);
		if (list != null && list.size() > 0) {
			return (ByActivityPlugin) list.get(0);
		} else {
			Log.d(TAG, "ByActivityPlugin not found");
			return null;
		}
	}
	
	public static void setByActivityCallback(int methodId) {
		if (byActivityCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(byActivityCallbackMethodId);
			byActivityCallbackMethodId = -1;
		}
		if (methodId != -1) {
			byActivityCallbackMethodId = methodId;
		}
	}
	
	public static void setByActivityCloseCallback(int methodId) {
		if (byActivityCloseCallBackMethodId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(byActivityCloseCallBackMethodId);
			byActivityCloseCallBackMethodId = -1;
		}
		if (methodId != -1) {
			byActivityCloseCallBackMethodId = methodId;
		}
	}
	
	public static void setup(final String mid,final String sitemid,final String usertype,final String version,final String api,final String appid,final String deviceno ) {
		Log.d(TAG, "ByActivityBridge.setup");
		final ByActivityPlugin byactivity = getByActivityPlugin();
		if (byactivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					byactivity.setup(mid, sitemid, usertype, version, api, appid, deviceno);
				}
			}, 50);
		}
	}
	
	public static void display() {
		Log.d(TAG, "display");
		final ByActivityPlugin byactivity = getByActivityPlugin();
		if (byactivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					byactivity.display();
				}
			}, 50);
		}
	}
	
	public static void displayForce(final int size) {
		Log.d(TAG, "displayForce size:" + size);
		final ByActivityPlugin byactivity = getByActivityPlugin();
		if (byactivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					byactivity.displayForce(size);
				}
			}, 50);
		}
	}
	
	
	public static void switchServer(final int Id) {
		Log.d(TAG, "switchServer.serverId :" + Id);
		final ByActivityPlugin byActivity = getByActivityPlugin();
		
		if (byActivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					byActivity.switchServer(Id);
				}
			}, 50);
		}
	}
	
	public static void setWebViewTimeOut(final long time) {
		Log.d(TAG, "setWebViewTimeOut.time :" + time);
		
		final ByActivityPlugin byActivity = getByActivityPlugin();
		
		if (byActivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					byActivity.setWebViewTimeout(time);
				}
			}, 50);
		}
	}
	
	public static void setWebViewCloseTip(final String tips) {
		Log.d(TAG, "setWebViewCloseTip.tips :" + tips);
		final ByActivityPlugin byActivity = getByActivityPlugin();
		
		if (byActivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					byActivity.setWebViewCloseTip(tips);
				}
			}, 50);
		}
	}
	
	public static void setNetWorkBadTip(final String tips) {
		Log.d(TAG, "setNetWorkBadTip.tips:" + tips);

		final ByActivityPlugin byActivity = getByActivityPlugin();

		if (byActivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

				@Override
				public void run() {
					// TODO Auto-generated method stub
					byActivity.setBadNetWorkTip(tips);
				}
			}, 50);
		}
	}
	
	public static void setAnimIn(final int animId) {
		Log.d(TAG, "setAnimIn.animId" + animId);
		
		final ByActivityPlugin byActivity = getByActivityPlugin();

		if (byActivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

				@Override
				public void run() {
					// TODO Auto-generated method stub
					byActivity.setAnimIn(animId);
				}
			}, 50);
		}
	}
	
	public static void setAnimOut(final int animId) {
		Log.d(TAG, "setAnimIn.animId" + animId);
		
		final ByActivityPlugin byActivity = getByActivityPlugin();

		if (byActivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

				@Override
				public void run() {
					// TODO Auto-generated method stub
					byActivity.setAnimOut(animId);
				}
			}, 50);
		}
	}
	
	public static void setCloseClickOnce(final boolean isOnceClose) {
		Log.d(TAG, "setCloseClickOnce.isOnceClose" + isOnceClose);
		
		final ByActivityPlugin byActivity = getByActivityPlugin();
		if (byActivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					byActivity.setCloseType(isOnceClose);
				}
			}, 50);
		}
	}
	
	public static void dismiss(final int animId) {
		Log.d(TAG, "dismiss.animId" + animId);
		
		final ByActivityPlugin byActivity = getByActivityPlugin();
		
		if (byActivity != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {

				@Override
				public void run() {
					// TODO Auto-generated method stub
					byActivity.dismiss(animId);
				}
			}, 50);
		}
	}
	
	static void callLuaByAcvityCallbackMethod(final String result) {
		Log.d(TAG, "callLuaByAcvityCallbackMethod " + result);
		if (byActivityCallbackMethodId != -1) {
//			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
//				@Override
//				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									byActivityCallbackMethodId, result);
						}
					});
//				}
//			});
		}
	}
	
	static void callLuaByAcvityCloseCallbackMethod(final String result) {
		final String tempStr = (result == null ? "" : result);
		Log.d(TAG, "callLuaByAcvityCloseCallbackMethod " + result);
		if (byActivityCloseCallBackMethodId != -1) {
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
							byActivityCloseCallBackMethodId, tempStr);
				}
			});
		}
	}
	

	
	
}
