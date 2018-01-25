package com.boomegg.cocoslib.adscene;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

import android.util.Log;


public class AdSceneBridge {
	static final String TAG = AdSceneBridge.class.getSimpleName();
	private static int sureListener = -1;
	private static int cancelListener = -1;
	private static int closeListener = -1;
	private static int returnListener = -1;
	private static int getRewardListener = -1;

	public AdSceneBridge() {
		
	}
	
	
	private static AdScenePlugin getAdScenePlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
				.getPluginManager().findPluginByClass(AdScenePlugin.class);
		if (list != null && list.size() > 0) {
			return (AdScenePlugin) list.get(0);
		} else {
			Log.d(TAG, "AdScenePlugin not found");
			return null;
		}
	}
	
	
	public static void setSureListener(final int callback) {
		Log.d(TAG, "setSureListener " + callback);
		if(AdSceneBridge.sureListener != -1) {
			Log.d(TAG, "release lua function " + AdSceneBridge.sureListener);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(AdSceneBridge.sureListener);
			AdSceneBridge.sureListener = -1;
		}
		AdSceneBridge.sureListener = callback;
	}
	
	
	public static void setCancelListener(final int callback) {
		Log.d(TAG, "setSureListener " + callback);
		if(AdSceneBridge.cancelListener != -1) {
			Log.d(TAG, "release lua function " + AdSceneBridge.cancelListener);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(AdSceneBridge.cancelListener);
			AdSceneBridge.cancelListener = -1;
		}
		AdSceneBridge.cancelListener = callback;
	}
	
	public static void setCloseListener(final int callback) {
		Log.d(TAG, "setCloseListener " + callback);
		if(AdSceneBridge.closeListener != -1) {
			Log.d(TAG, "release lua function " + AdSceneBridge.closeListener);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(AdSceneBridge.closeListener);
			AdSceneBridge.closeListener = -1;
		}
		AdSceneBridge.closeListener = callback;
	}
	
	public static void setReturnListener(final int callback) {
	    Log.d(TAG, "setReturnListener " + callback);
	    if(AdSceneBridge.returnListener != -1) {
	        Log.d(TAG,"release lua function " + AdSceneBridge.returnListener);
	        Cocos2dxLuaJavaBridge.releaseLuaFunction(AdSceneBridge.returnListener);
	        AdSceneBridge.returnListener = -1;
	    }
	    AdSceneBridge.returnListener = callback;
	}
	
	public static void setGetRewardListener(final int callback) {
        Log.d(TAG, "getRewardListener " + callback);
        if(AdSceneBridge.getRewardListener != -1) {
            Log.d(TAG,"release lua function " + AdSceneBridge.getRewardListener);
            Cocos2dxLuaJavaBridge.releaseLuaFunction(AdSceneBridge.getRewardListener);
            AdSceneBridge.getRewardListener = -1;
        }
        AdSceneBridge.getRewardListener = callback;
    }
	
	public static void setup(final String appId,final String appSec,final String channelname,final String uid) {
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					adscene.setup(appId, appSec, channelname,uid);
				}
			},50);
			
		}
	}
	
	public static void setFacebookId(final String fbId) {
	    final AdScenePlugin adscene = getAdScenePlugin();
	    if (adscene != null) {
	        Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
	            @Override
	            public void run() {
	                adscene.setFacebookId(fbId);
	            }
	        },50);
	    }
	}
	
	public static void showInterstitialAdDialog() {
		final AdScenePlugin adscene = getAdScenePlugin();
		
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					final int state = adscene.showInterstitialAdDialog();
					callLuaReturnState(state);
				}
			},50);
			
		}
		
	}
	
	
	public static void showInterstitialAdDialog(final int leftTextId,final int rightTextId) {
		final AdScenePlugin adscene = getAdScenePlugin();
		
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					final int state = adscene.showInterstitialAdDialog(leftTextId, rightTextId);
					callLuaReturnState(state);
				}
			},50);
			
			
		}
	
	}
	
	
	public static void showBannerAdDialog() {
	
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					final int state =  adscene.showBannerAdDialog();
					callLuaReturnState(state);
				}
			},50);
			
		}
		
	}
	
	public static void showBannerAdDialog(final int leftTextId,final int rightTextId) {
		final AdScenePlugin adscene = getAdScenePlugin();
		
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					
					final int state = adscene.showBannerAdDialog( leftTextId, rightTextId);
					callLuaReturnState(state);
					Log.v(TAG,"showBannerAdDialog111111 -- state:" + state );
				}
			},50);
			
		}
		
		
	}
	
	public static void setShowRecommendBar(final int isShow) {
		Log.v(TAG,"setShowRecommendBar:" + isShow);
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					
					adscene.setShowRecommendBar(isShow);
				}
			},50);
			
		}
	}
	
//	public static void reportGoldSuccessDat(final String adId) {
//	    Log.v(TAG,"reportGoldSuccessDat:" + adId);
//        final AdScenePlugin adscene = getAdScenePlugin();
//        if (adscene != null) {
//            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
//                @Override
//                public void run() {
//                    
//                    adscene.reportGoldSuccessDat(adId);
//                }
//            },50);
//            
//        }
//	}
	
	public static void setShowSudokuDialog(final int isShow,final boolean isCancelble,final boolean isFloat) {
		final AdScenePlugin adscene = getAdScenePlugin();
		
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					final int state = adscene.setShowSudokuDialog(isShow, isCancelble, isFloat);
					callLuaReturnState(state);
				}
			},50);
			
		}

	}
	
	
	public static void showClassifyDialog(final int isShow,final boolean isCancelble,final boolean isFloat) {
		final AdScenePlugin adscene = getAdScenePlugin();

		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					final int state = adscene.showClassifyDialog(isShow, isCancelble, isFloat);
					callLuaReturnState(state);
				}
			},50);
			
		}
		
	}
	
	
	
	public static void callLuaReturnState(final int state) {
	    Cocos2dxActivityUtil.runOnResumed(new Runnable() {
	        @Override
            public void run() {
        		Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
        			@Override
        			public void run() {
        				Log.d(TAG, "call lua function callLuaReturnState " + AdSceneBridge.returnListener + " " );
        				if(AdSceneBridge.returnListener == -1) return;
        				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AdSceneBridge.returnListener, String.valueOf(state));
        			}
        		}, 50);
	        }
	    });
	}
	
	
	
	public static void callLuaCancelListener(){
		Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
			@Override
			public void run() {
			    if(AdSceneBridge.cancelListener == -1) return;
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AdSceneBridge.cancelListener,"");
			}
		}, 50);
	}
	
	public static void callLuaSureListener(){
		Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
			@Override
			public void run() {
			    if(AdSceneBridge.sureListener == -1) return;
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AdSceneBridge.sureListener,"");
			}
		}, 50);
	}
	
	
	public static void callLuaCloseListener() {
		Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
			@Override
			public void run() {
			    if(AdSceneBridge.closeListener == -1) return;
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AdSceneBridge.closeListener,"");
			}
		}, 50);
	}
	
	public static void callGetRewardListener(final String adId) {
	    Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
            @Override
            public void run() {
                if(AdSceneBridge.getRewardListener == -1) return;
                if(adId == null) return;
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AdSceneBridge.getRewardListener,adId);
            }
        }, 50);
	}
	
	
	public static void clearAll() {
		final AdScenePlugin adscene = getAdScenePlugin();
		if (adscene != null) {
			Cocos2dxActivityUtil.runOnUIThread(new Runnable() {
				@Override
				public void run() {
					adscene.clearAll();
				}
			});
			
			
		}
	}

}
