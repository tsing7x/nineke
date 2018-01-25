package com.boomegg.cocoslib.adscene;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;
import com.boyaa.boyaaad.admanager.AdDataManagement;
import com.boyaa.boyaaad.admanager.AdDataManagement.GetGoldListener;
import com.boyaa.boyaaad.admanager.AdWallManager;
import com.boyaa.boyaaad.admanager.BannerAdManager;
import com.boyaa.boyaaad.admanager.InterstitialAdManager;
import com.boyaa.boyaaad.network.request.RequestConfig;
import com.boyaa.boyaaad.widget.BannerAdView.OnBannerCloselListener;
import com.boyaa.boyaaad.widget.BannerAdView.OnBannerListener;
import com.boyaa.boyaaad.widget.InterstitialAdView.OnInterstitiaSinglelListener;
import com.boyaa.boyaaad.widget.InterstitialAdView.OnInterstitialListener;

public class AdScenePlugin extends LifecycleObserverAdapter implements IPlugin {
	static final String TAG = AdScenePlugin.class.getSimpleName();
	
	protected String id;
	private Activity mActivity;

	public AdScenePlugin() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(activity, savedInstanceState);
		this.mActivity = activity;
	}

	public void setup(String appId, String appSec, String channelname,String uid) {
		Log.v(TAG, "appId:" + appId + " appSec:" + appSec + " channelname:" + channelname);
		AdDataManagement.getInstance().init(mActivity, appId, appSec,
				channelname,uid);
//		setGetGoldListener();
	}

	public void setFacebookId(String fbId) {
	    Log.v(TAG, "fbId:" + fbId);
//	    AdDataManagement.getInstance().setMfacebookId(fbId);
	}
	
	// 插屏广告一
	public int showInterstitialAdDialog() {
		final InterstitialAdManager d = new InterstitialAdManager();
		d.setCancelble(true);
		int state1 = d.showInterstitialAdDialog(this.mActivity,
				new OnInterstitiaSinglelListener() {
					@Override
					public void closeDialogListerer() {
						AdSceneBridge.callLuaCloseListener();
						d.cancelInterstitialAdDialog();

					}
				});
		return state1;
	}

	// 插屏广告二
	public int showInterstitialAdDialog(int leftTextId, int rightTextId) {
		final InterstitialAdManager d = new InterstitialAdManager();
		int state1 = d.showInterstitialAdDialog(this.mActivity,
				new OnInterstitialListener() {

					@Override
					public void onSureListener() {
						AdSceneBridge.callLuaSureListener();
						
						d.cancelInterstitialAdDialog();
					}

					@Override
					public void onCancelListener() {
						AdSceneBridge.callLuaCancelListener();
						d.cancelInterstitialAdDialog();

					}
				}, leftTextId, rightTextId);
		
		return state1;

	}

	// 插屏轮播广告一
	public int showBannerAdDialog() {
		final BannerAdManager id3 = new BannerAdManager();
		int state1 = id3.showBannerAdDialog(this.mActivity, new OnBannerCloselListener() {

			@Override
			public void closeDialogListerer() {
				AdSceneBridge.callLuaCloseListener();
				id3.cancelBannerAdDialog();
			}
		});
		
		return state1;
	}

	// 插屏轮播广告二
	/**
	 * 0 代表轮播插屏广告开关关闭或者其他错误
	 * 1 代表轮播插屏广告显示
	 * 2 无此类广告数据
	 * 3 代表初始化失败
	 * @param leftTextId
	 * @param rightTextId
	 */
	public int showBannerAdDialog(int leftTextId, int rightTextId) {
		Log.v(TAG,"showBannerAdDialog -- leftTextId:" + leftTextId + " rightTextId:" + rightTextId);
		final BannerAdManager id4 = new BannerAdManager();
		int state1 = id4.showBannerAdDialog(this.mActivity, new OnBannerListener() {
			@Override
			public void onSureListener() {
				AdSceneBridge.callLuaSureListener();
				id4.cancelBannerAdDialog();
			}

			@Override
			public void onCancelListener() {
				AdSceneBridge.callLuaCancelListener();
				id4.cancelBannerAdDialog();
			}
		}, leftTextId, leftTextId);
		
		String tip = "showBannerAdDialog -- leftTextId:" + leftTextId + " rightTextId:" + rightTextId + " state1:" + state1;
		Log.v(TAG,tip);
		return state1;
		
	}

	// 添加/移除 悬浮式广告
	public void setShowRecommendBar(int isShow) {
	    Log.v(TAG,"setShowRecommendBar, isShow:" + isShow);
		if (isShow == 1) {
			AdWallManager.getInstance().showRecommendBar(this.mActivity);
		} else {
			AdWallManager.getInstance().removeRecommendBar(this.mActivity);
		}

	}

	/**
	 * 九宫格广告
	 *  @param isShow
	 * @param isCancelble
	 * @param isFloat
	 * 
	 *            isCancelble 设置九宫格弹出框是否可以取消 isFloat 设置是否为系统悬浮窗,true
	 *            代表设置为系统悬浮，false 代表普通的弹窗 此方法会返回返回九宫格广告状态 0 代表九宫格广告开关关闭或者其他错误 1
	 *            代表九宫格广告显示 2 无此类广告数据 3 代表初始化失败
	 */
	public int setShowSudokuDialog(int isShow, boolean isCancelble,
			boolean isFloat) {
		int state1 = -1;
		if (isShow == 1) {
			state1 = AdWallManager.getInstance().showSudokuDialog(this.mActivity,
					isCancelble, isFloat);
		} else {
			AdWallManager.getInstance().cancelSudokuDialog();
		}
		
		return state1;

	}

	/**
	 * 推荐分类广告
	 * 
	 * @param isShow
	 * @param isCancelble
	 * @param isFloat
	 *            isCancelble 设置推荐分类弹出框是否可以取消 isFloat 设置是否为系统悬浮窗,true
	 *            代表设置为系统悬浮，false 代表普通的弹窗 此方法会返回返回推荐分类广告状态 0 代表推荐分类广告开关关闭或者其他错误
	 *            1 代表推荐分类广告显示 2 无此类广告数据 3 代表初始化失败
	 */
	public int showClassifyDialog(int isShow, boolean isCancelble,
			boolean isFloat) {
		int state1 = -1;
		if (isShow == 1) {
			state1 = AdWallManager.getInstance().showClassifyDialog(this.mActivity,
					isCancelble, isFloat);
		} else {
			AdWallManager.getInstance().cancelSudokuDialog();
		}
		
		return state1;
	}

//	public void setGetGoldListener() {
//	    AdDataManagement.getInstance().setmGoldListener(new GetGoldListener() {
//            @Override
//            public void getGoldState(int state, String adId) {
//                if(state == 0) {
//                    AdSceneBridge.callGetRewardListener(adId);
//                } else {
//                    Toast.makeText(mActivity, "รับรางวัลล้มเหลว", Toast.LENGTH_LONG).show(); //领取失败
//                }
//            }
//        });
//	}
	
//	public void reportGoldSuccessDat(String adId) {
//	    AdDataManagement.getInstance().reportGoldSuccessData(this.mActivity, adId);
//	}
	
	// 退出游戏相关缓存
	public void clearAll() {
		AdDataManagement.getInstance().clearAll(this.mActivity);
	}

	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);
	}

	@Override
	public void setId(String id) {
		this.id = id;

	}

}
