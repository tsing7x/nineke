package com.boomegg.nineke;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebSettings.LayoutAlgorithm;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;


//import com.boomegg.cocoslib.adscene.AdScenePlugin;
import com.boomegg.cocoslib.adsdk.AdSdkPlugin;
import com.boomegg.cocoslib.bluepay.BluePayPlugin;
// import com.boomegg.cocoslib.byactivity.ByActivityPlugin;
import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.PluginManager;
import com.boomegg.cocoslib.easy2payapi.Easy2PayApiPlugin;
import com.boomegg.cocoslib.facebook.FacebookPlugin;
import com.boomegg.cocoslib.gcm.GoogleCloudMessagingPlugin;
// import com.boomegg.cocoslib.iab.InAppBillingPlugin;
import com.boomegg.cocoslib.aisflow.AisFlowPlugin;
import com.boyaa.cocoslib.godsdk.GodSdkPlugin;
import com.boyaa.godsdk.core.ActivityAgent;
import com.umeng.analytics.mobclick.game.MobClickCppHelper;

public class NineKe extends Cocos2dxActivityWrapper {
	
	private GodSdkPlugin mGodSdkPlugin;
	
	public static Context STATIC_REF = null;
	private static NineKe _instance;
	
	private static WebView m_webView;
	private static ProgressDialog m_progressBar;
	private static ImageView m_imageView;
	private static FrameLayout m_webLayout;
	private static FrameLayout.LayoutParams m_lytp;
	private static FrameLayout m_topLayout;
	private static Button m_backButton;
	private static int openWebViewcallbackMethodId = -1;

	private static int pushType = -1;
    private static String pushCode;
	
	public static int getPushType() {
		int type = pushType;
		pushType = -1;
		return type;
	}
    public static String getPushCode(){
        String tempCode = pushCode;
        pushCode = null;
        if(tempCode==null){
            tempCode = "";
        }
        return tempCode;
    }
	
	public static Cocos2dxActivityWrapper getContext() {
        return (Cocos2dxActivityWrapper)STATIC_REF;
    }
	
	public static NineKe getInstance(){
		return _instance;
	}
	
	private void hideSystemUI(){
		int flags;    
        int curApiVersion = android.os.Build.VERSION.SDK_INT;  
        // This work only for android 4.4+  
        if(curApiVersion >= Build.VERSION_CODES.KITKAT){  
            // This work only for android 4.4+  
            // hide navigation bar permanently in android activity  
            // touch the screen, the navigation bar will not show  
            flags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE  
                  | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION  
                  | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                  | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
                  | View.SYSTEM_UI_FLAG_FULLSCREEN // hide status bar
                  | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
            
            Log.v("NineKe", "mSystemUiVisibility = nimeinimei");   
        }else{  
            // touch the screen, the navigation bar will show  
            flags = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION;  
        }  
        Log.v("NineKe", "mSystemUiVisibility = ddddddddd");
        // must be executed in main thread :)  
        getWindow().getDecorView().setSystemUiVisibility(flags);
	}
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		super.onKeyUp(keyCode, event);
		if ((keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)){
			this.hideSystemUI();
		}
		return false;
	}
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		this.mGodSdkPlugin = new GodSdkPlugin();
		
        super.onCreate(savedInstanceState);
        this.hideSystemUI();
        
        MobClickCppHelper.init(this,"541ff0d1fd98c52f45007666","channel");
        
        STATIC_REF = this;
        _instance = this;
        
        Intent intent = getIntent();
        needReport(intent);
        addShortcutIfNeeded(R.string.app_name, R.drawable.icon);
        
        this.mGodSdkPlugin.init();
//        initWebView_();
    }
	
	@Override
	public void onNewIntent(Intent intent) {
	    needReport(intent);
	    ActivityAgent.onNewIntent(this, intent);
	}
	
	@Override
	protected void onStart() {
		// TODO Auto-generated method stub
		super.onStart();
		ActivityAgent.onStart(this);
	}
	
	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		ActivityAgent.onRestart(this);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		this.hideSystemUI();
		
		// 集成游戏统计分析,初始化 Session
		MobClickCppHelper.onResume(this);
		ActivityAgent.onResume(this);
		
//		Log.v("NineKe", "mSystemUiVisibility =zzzzzzzzz");
	}
	
	 @Override
	 public void onPause() {
		 super.onPause();
		 
	     //集成游戏统计分析, 结束 Session
		 MobClickCppHelper.onPause(this);
		 ActivityAgent.onPause(this);
	 }
	 
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		this.mGodSdkPlugin.quit();
		super.onDestroy();
		ActivityAgent.onDestroy(this);
	}
	
	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
		ActivityAgent.onStop(this);
	}
	
	@Override
	public void finish() {
		// TODO Auto-generated method stub
		this.mGodSdkPlugin.finish();
		super.finish();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		
		ActivityAgent.onActivityResult(this, requestCode, resultCode, data);
	}
	
	@Override
    public void onWindowFocusChanged(boolean hasFocus) {
    	Log.d(TAG, "onWindowFocusChanged() hasFocus=" + hasFocus);
        super.onWindowFocusChanged(hasFocus);
        if(hasFocus){
        	this.hideSystemUI();
        }
    }
	
	public void needReport(Intent intent) {
        final String sid = intent.getStringExtra("sid");
        final String lid = intent.getStringExtra("lid");
        final String log = intent.getStringExtra("log");
        NineKe.pushType = intent.getIntExtra("type", -1);
        NineKe.pushCode = intent.getStringExtra("code");
        if (!TextUtils.isEmpty(sid) && !TextUtils.isEmpty(lid) && !TextUtils.isEmpty(log)) {
            new Thread(new Runnable(){
                @Override
                public void run() {
                    reportData(sid,lid,log);
                }
            }).start();
        }
	}
	
	@Override
	protected void onSetupPlugins(PluginManager pluginManager) {
		// pluginManager.addPlugin("IN_APP_BILLING", new InAppBillingPlugin("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmfXKoUxe7X0cSe1TWZiMBL4INblbGQ/lm9dlJqhh6h1IGI6OcepIjRhcbyPN3RDAYQi4s9NWgW8uU9XqF+kaZtWB3uGGILXnIKTAv+bMWgUiEQb/Afg4DNjmgt/EqT0tyTe/9biZUlEjPy1B/18mof3zoRT4BV6h3Cah6ZRetII1Un/Nor5ksJhS9RD4W6/fXe68jxvIH+yQm5JcdV28Pk6JZ74ClNc5bGQ8ejwIWSKokEU7F+I7ZV8jHibmZw0mToWd2qO3Usj764+6QP09pywv7L3WQa+7Pjc9MVQ6jvEoAYwDvhQjKtGHsMImy6iLgU5Sr0hoRZz4QjsY9XEQ5QIDAQAB", true));
		pluginManager.addPlugin("FACEBOOK", new FacebookPlugin());
		pluginManager.addPlugin("GOOGLE_CLOUD_MESSAGING", new GoogleCloudMessagingPlugin());
		
		// Set<String> merchantIdSet = new HashSet<String>();
//		merchantIdSet.add("4056");
//		merchantIdSet.add("4057");
//		merchantIdSet.add("4158");
//        merchantIdSet.add("4165");
//		pluginManager.addPlugin("EASY_2_PAY", new Easy2PayPlugin(merchantIdSet, "51afe62ef5d04499265ca7ab7a29fb91", 60, true));
		pluginManager.addPlugin("EASY_2_PAY_API", new Easy2PayApiPlugin());
		pluginManager.addPlugin("BluePay",new BluePayPlugin());
		pluginManager.addPlugin("ADSDK", new AdSdkPlugin());
//		pluginManager.addPlugin("AdScene", new AdScenePlugin());
		// pluginManager.addPlugin("ByActivity", new ByActivityPlugin());
		pluginManager.addPlugin("AisFlow", new AisFlowPlugin());
		pluginManager.addPlugin("GodSdk", this.mGodSdkPlugin);
	}
	
	
	public void reportData(String sid,String lid,String log) {
	    String url = "http://mvlptl9k01.boyaagame.com/m/Push/pushLog?sid="+ sid + "&lid="+ lid;
	    HttpPost httpRequest =new HttpPost(url);
	    List <NameValuePair> params=new ArrayList<NameValuePair>();
	    params.add(new BasicNameValuePair("log",log));
	    try {
            httpRequest.setEntity(new UrlEncodedFormEntity(params,HTTP.UTF_8));
            new DefaultHttpClient().execute(httpRequest);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	/**
	 * 鎵撳紑Html5鍋氱殑鏂板晢鍩�
	 * @param gotoUrl	杩炴帴鍦板潃
	 * @param tip		loading 鎻愮ず淇℃伅锛岀┖瀛楃涓叉爣璇嗕笉鏄剧ずloading
	 * @param screenWidth	webview瀹藉害
	 * @param screenHeight	webview楂樺害
	 * @param isShowBg		鏄惁鏄剧ず鍏ㄥ睆浣跨敤鐨勮儗鏅浘鐗�
	 * @param isShowClose	鏄惁闇�瑕佹樉绀哄叧闂寜閽�
	 * @param callbackId	鍥炶皟鍑芥暟
	 */
	public static void openWebview(final String gotoUrl, final String tip, final int screenWidth, final int screenHeight, final int isShowBg, final int isShowClose, int callbackId) {
		//Log.v("NineKe", "NineKe openWebView::"+gotoUrl);
    	if(null != m_webView){
    		return;
    	}
    	//    	
    	if(-1 != openWebViewcallbackMethodId){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(openWebViewcallbackMethodId);
			openWebViewcallbackMethodId = -1;
		}
    	openWebViewcallbackMethodId = callbackId;
    	//
    	Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {//鍦ㄤ富绾跨▼閲屾坊鍔犲埆鐨勬帶浠�
			@Override
			public void run() {
				_instance.initWebView_(screenWidth, screenHeight);
				//
				if(null != tip && tip.length() > 0){
					m_progressBar = new ProgressDialog(STATIC_REF);
					m_progressBar.setMessage(tip);
				}
				//鍒濆鍖杦ebView
                m_webView = new WebView(STATIC_REF);
                //璁剧疆webView鑳藉鎵цjavascript鑴氭湰
                m_webView.getSettings().setJavaScriptEnabled(true);            
                //璁剧疆鍙互鏀寔缂╂斁
                m_webView.getSettings().setSupportZoom(true);//璁剧疆鍑虹幇缂╂斁宸ュ叿
                m_webView.getSettings().setBuiltInZoomControls(true);
                m_webView.getSettings().setJavaScriptEnabled(true);
                m_webView.getSettings().setSupportZoom(false);
        		// setting.setUseWideViewPort(true);
                m_webView.getSettings().setLoadWithOverviewMode(true);
                m_webView.getSettings().setBuiltInZoomControls(false);
                m_webView.getSettings().setLayoutAlgorithm(LayoutAlgorithm.NORMAL);
                //浣块〉闈㈣幏寰楃劍鐐�
                m_webView.requestFocus();
                //濡傛灉椤甸潰涓摼鎺ワ紝濡傛灉甯屾湜鐐瑰嚮閾炬帴缁х画鍦ㄥ綋鍓峛rowser涓搷搴�
                m_webView.setWebViewClient(new WebViewClient(){
                	@Override
        			public void onPageFinished(WebView view, String url) { // 缁撴潫
        				super.onPageFinished(view, url);
        				hideLoading();
        				m_webView.setVisibility(View.VISIBLE);
        				if( view.getVisibility() == View.VISIBLE ) view.requestFocus();
        			}
                	@Override
        			public void onPageStarted(WebView view, String url, Bitmap favicon) { // 寮�濮�
        				super.onPageStarted(view, url, favicon);
        				showLoading();
        			}
                	@Override
        			public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {// Handle
                		hideLoading();
        				m_webView.loadUrl("");
        			}
                	@Override
                    public boolean shouldOverrideUrlLoading(WebView view, String url) {   
                        if(url.indexOf("tel:")<0){
                            view.loadUrl(url); 
                        }
                        return true;       
                    }    
                });
                //璁剧疆鏈湴璋冪敤瀵硅薄鍙婂叾鎺ュ彛
                m_webView.addJavascriptInterface(STATIC_REF, "JavaScriptInterface");
                //杞藉叆URL
                m_webView.loadUrl(gotoUrl);
                m_webView.setVisibility(View.INVISIBLE);
                //鑳屾櫙鍥�
                m_imageView = new ImageView(STATIC_REF);
                m_imageView.setImageResource(R.drawable.bkgnd);
                m_imageView.setScaleType(ImageView.ScaleType.FIT_XY);
                //鍒濆鍖栧竷灞� 閲岄潰鍔犳寜閽拰webView
                m_topLayout = new FrameLayout(STATIC_REF);
                //鍒濆鍖栬繑鍥炴寜閽�
                m_backButton = new Button(STATIC_REF);
                if(0 == isShowClose){
                	m_backButton.setVisibility(View.INVISIBLE);
                	m_backButton.setBackgroundResource(R.drawable.umeng_update_close_bg_tap);
                }else if(1 == isShowClose){
                	m_backButton.setBackgroundResource(R.drawable.umeng_update_close_bg_normal);
                }else{
                	m_backButton.setBackgroundResource(R.drawable.umeng_update_close_bg_tap);
                }
                LinearLayout.LayoutParams lypt=new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                lypt.gravity=Gravity.RIGHT;
                m_backButton.setLayoutParams(lypt);           
                m_backButton.setOnClickListener(new OnClickListener() {
                    public void onClick(View v) {
                        //绉婚櫎WebView                       
                        removeWebView();
                        //璋冪敤JS鏂规硶
                        //m_webView.loadUrl("javascript:funFromjs()");
                    } 
                });
                //鎶奿mage鍔犲埌涓诲竷灞�閲�
                m_webLayout.addView(m_imageView);
                m_topLayout.addView(m_webView);
                //鎶妛ebView鍔犲叆鍒扮嚎鎬у竷灞�
                m_topLayout.addView(m_backButton);
                //
                if(0 == isShowBg){
                	m_imageView.setVisibility(View.INVISIBLE);
                }else{
                	m_webView.setBackgroundColor(Color.TRANSPARENT);
                }
                //鍐嶆妸绾挎�у竷灞�鍔犲叆鍒颁富甯冨眬
                m_webLayout.addView(m_topLayout);
            }
        }, 50);
    }
	/**
	 * closeWebView鏄毚闇茬粰JS璋冪敤鐨勫叧闂柟娉�
	 * 渚嬪锛欽avaScriptInterface鏄毚闇茬粰JS浣跨敤寮曠敤
	 * JavaScriptInterface.closeWebView()
	 */
	public void closeWebView() {
        Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
			@Override
			public void run() {
				removeWebView();
			}
		}, 50);
    }
	/**
	 * 
	 */
	public static void removeAllWebView(){
		 Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					removeWebView();
				}
			}, 50);
	}
    /**
     * 绉婚櫎webView
     */
    public static void removeWebView() {
    	Log.v("NineKe", "NineKe removeWebView::");
    	if(null != m_imageView){
    		m_webLayout.removeView(m_imageView);
    		m_imageView.destroyDrawingCache();
    		m_imageView = null;
    	}
        
        m_webLayout.removeView(m_topLayout);
        m_topLayout.destroyDrawingCache();
        
        if(null != m_webView){
	        m_topLayout.removeView(m_webView);
	        m_webView.destroy();
	        m_webView = null;
        }
        
        if(null != m_backButton){
        	m_topLayout.removeView(m_backButton);
        	m_backButton.destroyDrawingCache();
        	m_backButton = null;
        }
        
        if(null != m_progressBar){
        	m_progressBar.dismiss();
        	m_progressBar = null;
        }
            
        if(-1 != openWebViewcallbackMethodId){
        	Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(openWebViewcallbackMethodId, "1");//					openWebViewcallbackMethodId = -1;
				}
			}, 50);
        }
    }
    /**
     * 鏄剧ずLoading
     * @param progressBar
     */
    static public void showLoading() {
		if (m_progressBar != null && !m_progressBar.isShowing()) {
			m_progressBar.show();
		}
	}
	/**
	 * 闅愯棌Loading
	 * @param progressBar
	 */
	static public void hideLoading() {
		if (m_progressBar != null && m_progressBar.isShowing()) {  
			m_progressBar.dismiss();
		}
	}
    /**
     * 娣诲姞鍟嗗煄浣跨敤鐨刉ebView
     */
    private void initWebView_(final int width, final int height){
    	if(null == m_webLayout){
            //鍒濆鍖栦竴涓┖甯冨眬
            m_webLayout = new FrameLayout(_instance);
            m_webLayout.bringToFront();
            m_lytp = new FrameLayout.LayoutParams(width, height);
            m_lytp.gravity = Gravity.CENTER;
            addContentView(m_webLayout, m_lytp);
    	}else{
    		if(null != m_lytp){
    			m_lytp.width = width;
        		m_lytp.height = height;
    		}
    	}
	}
    
    /**
     * 閲嶅啓return閿�
     */
    public boolean onKeyDown(int keyCoder,KeyEvent event){
    	if(keyCoder == KeyEvent.KEYCODE_POWER){
    		return false;
    	}
    	//濡傛灉缃戦〉鑳藉洖閫�鍒欏悗閫�锛屽鏋滀笉鑳藉悗閫�绉婚櫎WebView
    	if(keyCoder == KeyEvent.KEYCODE_BACK){
            removeWebView();
        }
        return false;      
    }
}
