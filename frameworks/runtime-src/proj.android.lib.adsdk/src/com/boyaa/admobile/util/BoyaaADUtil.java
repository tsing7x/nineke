package com.boyaa.admobile.util;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;
import com.boyaa.admobile.ad.appsflyer.AppsFlyManager;
import com.boyaa.admobile.ad.boya.BoyaaManager;
import com.boyaa.admobile.ad.facebook.FaceBookManager;
import com.boyaa.admobile.exception.CrashHandler;
import com.boyaa.admobile.service.CommitManager;

import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import android.util.Log;

/**
 * 供业务调用
 * 
 * @author Carrywen
 */
public class BoyaaADUtil {
	public static final String IS_REGISTER_PLAY = "is_register_play";
	public static final String TAG = "BoyaaADUtil";
    protected static ExecutorService executorService = Executors
            .newCachedThreadPool();
    public static final int METHOD_START 	= 1;
    public static final int METHOD_REG 		= 2;
    public static final int METHOD_LOGIN 	= 3;
    public static final int METHOD_PLAY 		= 4;
    public static final int METHOD_PAY 		= 5;
    public static final int METHOD_CUSTOM 	= 6;
    public static final int METHOD_RECALL 	= 7;
    public static final int METHOD_LOGOUT 	= 8;
	public static final int METHOD_SHARE   	= 9;
	public static final int METHOD_INVITE  	= 10;
	public static final int METHOD_PURCHASE_CANCEL = 11;
    
    
    public static void push(final Activity context,final HashMap<String, String> paraterMap,int type){
    	switch(type){
    	case METHOD_START:{
    		CrashHandler crashHandler = CrashHandler.getInstance();
    		crashHandler.init(context);
    		if (context instanceof Activity) {
    			((Activity) context).runOnUiThread(new Runnable() {

    				@Override
    				public void run() {
    					new AsyncTask<Void, Void, Void>() {
    						@Override
    						protected Void doInBackground(Void... params) {
    							// TODO Auto-generated method stub
    							return null;
    						}
    					};

    				}
    			});
    		}
    		executorService.execute(new Runnable() {
    			
    			@Override
    			public void run() {
    				try {
    					Log.d(TAG, "app start");
    					AppsFlyManager.getInstance(context).start(paraterMap);
    					FaceBookManager.getInstance(context).start(paraterMap);
    				} catch (Exception e) {
						Log.e(TAG, "BoyaaAd异常", e);
    				} finally {
    				}
    			}
    		});
    	}
    		break;
    	case METHOD_REG:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
					Log.d(TAG, "app register");

					String regTime = CommitManager.getStringValue(context,
							CommitManager.F_REGISTER);
					if (TextUtils.isEmpty(regTime)) {
						CommitManager.saveValue(context,
								CommitManager.F_REGISTER,
								BUtility.getDayTimeStamp(0));
						CommitManager.saveValue(context, CommitManager.REG_PLAY,
								"1111");
						try {
							AppsFlyManager.getInstance(context).register(paraterMap);
							FaceBookManager.getInstance(context).register(paraterMap);
						} catch (Exception e) {
							Log.e(TAG, "BoyaaAd异常", e);
						}
					}

    			}
    		});
    		}
    		break;
    	case METHOD_LOGIN:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				try {
						Log.d(TAG, "app login");
    					AppsFlyManager.getInstance(context).login(paraterMap);
    					FaceBookManager.getInstance(context).login(paraterMap);
    				} catch (Exception e) {
						Log.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    	}
    		break;
    	case METHOD_PLAY:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				try {
						Log.d(TAG, "app play");
    					String regPlay = CommitManager.getStringValue(context,
    							CommitManager.REG_PLAY);
						Log.d(TAG, "regPlay is " + regPlay);
    					if (regPlay.equals("0000")) {
							Log.d(TAG, "reg and play true");
    					} else if (regPlay.equals("1111")) {
    						String regTime = CommitManager.getStringValue(context,
    								CommitManager.F_REGISTER);
    						boolean regFlag = BUtility
    								.isWithinDayRecord(regTime, 0);
							Log.d(TAG, "regFlag is " + regFlag);
    						if (regFlag) {
    							CommitManager.saveValue(context,
    									CommitManager.REG_PLAY, "0000");
    							AppsFlyManager.getInstance(context).play(paraterMap);
    							FaceBookManager.getInstance(context).play(paraterMap);
    						}
    					} else {

    					}

    				} catch (Exception e) {
						Log.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    		}
    		break;
    	case METHOD_PAY:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				try {
						Log.d(TAG, "app pay");
    					String unit = paraterMap.get("currencyCode");

    					AppsFlyManager.getInstance(context).pay(paraterMap);
    					FaceBookManager.getInstance(context).pay(paraterMap);
    				} catch (Exception e) {
						Log.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    	}
    		break;
    	case METHOD_CUSTOM:{
    		executorService.execute(new Runnable() {
    			@Override
    			public void run() {
    				try {
						Log.d(TAG, "app customEvent");
    					AppsFlyManager.getInstance(context).customEvent(paraterMap);
    					FaceBookManager.getInstance(context).customEvent(paraterMap);
    				} catch (Exception e) {
						Log.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    	}
    		break;
    	case METHOD_RECALL:
    		
    		executorService.execute(new Runnable() {
    			
    			@Override
    			public void run() {
    				try {
						Log.d(TAG, "app recall");
    					AppsFlyManager.getInstance(context).recall(paraterMap);
    					FaceBookManager.getInstance(context).recall(paraterMap);
    				} catch (Exception e) {
						Log.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    		break;

    	case METHOD_LOGOUT:

    		executorService.execute(new Runnable() {
    			
    			@Override
    			public void run() {
    				try {
						Log.d(TAG, "app logout");
    					AppsFlyManager.getInstance(context).logout(paraterMap);
    					FaceBookManager.getInstance(context).logout(paraterMap);
    				} catch (Exception e) {
						Log.e(TAG, "BoyaaAd异常", e);
    				}
    			}
    		});
    		break;

		case METHOD_SHARE:
			executorService.execute(new Runnable() {
				@Override
				public void run() {
					try {
						Log.d(TAG, "app share");
						AppsFlyManager.getInstance(context).share(paraterMap);
						FaceBookManager.getInstance(context).share(paraterMap);
					} catch (Exception e) {
						Log.e(TAG, "BoyaaAd异常", e);
					}
				}
			});
			break;

			case METHOD_INVITE:
				executorService.execute(new Runnable() {
					@Override
					public void run() {
						try {
							Log.d(TAG, "app share");
							AppsFlyManager.getInstance(context).invite(paraterMap);
							FaceBookManager.getInstance(context).invite(paraterMap);
						} catch (Exception e) {
							Log.e(TAG, "BoyaaAd异常", e);
						}
					}
				});
				break;

			case METHOD_PURCHASE_CANCEL:
				executorService.execute(new Runnable() {
					@Override
					public void run() {
						try {
							Log.d(TAG, "app purchaseCancel");
							AppsFlyManager.getInstance(context).purchaseCancel(paraterMap);
							FaceBookManager.getInstance(context).purchaseCancel(paraterMap);
						} catch (Exception e) {
							Log.e(TAG, "BoyaaAd异常", e);
						}
					}
				});
				break;
    	}
    }

}
