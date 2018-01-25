package com.boomegg.cocoslib.byactivity;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;
import com.boyaa_sdk.base.CloseCallBack;
import com.boyaa_sdk.data.BoyaaAPI;

public class ByActivityPlugin extends LifecycleObserverAdapter implements
		IPlugin {

	protected String id;
	private Activity mActivity;
	protected final String TAG = getClass().getSimpleName();
	private CloseCallBack mCloseCallBack;
	
	public ByActivityPlugin() {
		mCloseCallBack = new CloseCallBack() {
			
			@Override
			public void close() {
				// TODO Auto-generated method stub
				ByActivityBridge.callLuaByAcvityCloseCallbackMethod(null);
				
			}
		};
	}
	
	/**
	 * 初始化活动中心
	 * @param mid
	 * @param sitemid
	 * @param usertype
	 * @param version
	 * @param api
	 * @param appid
	 * @param deviceno
	 */
	public void setup(final String mid,final String sitemid,final String usertype,final String version,final String api,final String appid,final String deviceno ) {
		Log.d(TAG, "setup -- mid"+ mid + " sitemid:"+sitemid + " usertype:"+usertype+" version:" +version + " api:" +api + " appid:"+appid + " deviceno:"+deviceno);
	    try {
	        BoyaaAPI.BoyaaData boyaa_data; // 数据
	        BoyaaAPI boyaa_api; // 主体类

	        boyaa_api = BoyaaAPI.getInstance(this.mActivity);
	        boyaa_data = boyaa_api.getBoyaaData(this.mActivity);
	        // 设定mid,version,api,appid,sitemid,sid等值
	        boyaa_data.setAppid(appid);
	        boyaa_data.setSecret_key("boyaa&#@9606");
	        boyaa_data.setUrl("http://mvlp9kapi.boyaagame.com");
	        boyaa_data.setMid(mid);
	        boyaa_data.setVersion(version);
	        boyaa_data.setApi(api);
	        boyaa_data.setChanneID("");
	        boyaa_data.setSitemid(sitemid);
	        boyaa_data.setUsertype(usertype);
	        boyaa_data.setDeviceno(deviceno);
	        boyaa_data.set_lua_class("com.boomegg.cocoslib.byactivity.ByActivityPlugin"); // 设定sdk调用lua
	        boyaa_data.set_lua_method("byActivityCallBack"); // 设定sdk调用lua 的方法名
	        boyaa_data.set_current_lua_type("text_callLua"); // 设定sdk调用lua 的type
	        boyaa_data.set_language(1);
	        boyaa_data.set_debug_toast_show(false);
//	        boyaa_data.cut_service(1);
	        boyaa_api.set_close_by_oneClick(true);
//	        StaticParameter.dialog_color_transparent = false;
	        boyaa_data.set_standard_screen(1280, 800);
	        // 以下为选填参数
	        
			boyaa_data.finish();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}  //该方法检查完毕参数之后，就会去获取活动数目，然后通过设定的lua 反射数据反射给客户端
	}
	
	//显示活动中心
	public void display() {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);
		boyaa_api.display(this.mActivity);
	}
	
	/**
	 * 强推显示
	 * @param size 0:小 1:中  2:大
	 */
	public void displayForce(final int size) {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);
		boyaa_api.related(size,this.mActivity);
	}
	
	/**
	 * 
	 * @param severId 这里1代表测试服务器，0代表正式服务器，传其他的值没有用的哦
	 */
	
	public void switchServer(final int severId){
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);
		BoyaaAPI.BoyaaData boyaa_data = boyaa_api.getBoyaaData(this.mActivity);
		boyaa_data.cut_service(severId);
	}
	
	/**
	 * 
	 * @param time 网页超时时间
	 */
	public void setWebViewTimeout(final long time) {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);
//		BoyaaAPI.BoyaaData boyaa_data = boyaa_api.getBoyaaData(this.mActivity);
		
		boyaa_api.set_webview_timeout(time);
	}
	
	/**
	 * 
	 * @param tips 关闭WebView时的toast提醒内容
	 */
	public void setWebViewCloseTip(final String tips) {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);
//		BoyaaAPI.BoyaaData boyaa_data = boyaa_api.getBoyaaData(this.mActivity);
		
		boyaa_api.set_close_webview_toast(tips);
	}
	
	/**
	 * 
	 * @param tips 网络情况差时的toast提示内容
	 */
	public void setBadNetWorkTip(final String tips) {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);
		
		boyaa_api.set_network_bad_toast(tips);
	}
	
	
	public void setAnimIn(final int id) {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);

		boyaa_api.set_huodong_anim_in(id);
	}
	
	
	public void setAnimOut(final int id) {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);

		boyaa_api.set_huodong_anim_out(id);
	}
	
	public void setCloseType(final boolean isClickOnceClose) {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);
		
		boyaa_api.set_close_by_oneClick(isClickOnceClose);
	}
	
	public void dismiss(final int animId) {
		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(this.mActivity);
		
		boyaa_api.dismiss(animId);
	}
	
	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(activity, savedInstanceState);
		this.mActivity = activity;
	}
	
	@Override
	public void initialize() {
		// TODO Auto-generated method stub
		Cocos2dxActivityWrapper.getContext().addObserver(this);

	}

	@Override
	public void setId(String id) {
		// TODO Auto-generated method stub
		this.id = id;
	}
	
	
	
	public void byActivityCallBack(final String data1,final String data2){
		Map<String, String> dataMap = new HashMap<String, String>();
		dataMap.put("data1", (data1 == null? "":data1));
		dataMap.put("data2", (data2 == null? "":data2));
		Log.i(TAG,"byActivityCallBack - data1:" + (data1 ==null? "":data1));
		Log.i(TAG,"byActivityCallBack - data2:" + (data2 ==null? "":data2));
		
		try {
			JSONObject jsonObject = new JSONObject(dataMap);
			Log.i(TAG,"handleMessage jsonObject-->:" + jsonObject.toString());
			ByActivityBridge.callLuaByAcvityCallbackMethod(jsonObject
					.toString());
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
	}

}
