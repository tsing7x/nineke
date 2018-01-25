package com.boomegg.cocoslib.bluepay;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONObject;

import android.R.bool;
import android.R.integer;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import com.bluepay.interfaceClass.BlueInitCallback;
import com.bluepay.pay.BlueMessage;
import com.bluepay.pay.BluePay;
import com.bluepay.pay.Client;
import com.bluepay.pay.IPayCallback;
import com.bluepay.pay.LoginResult;
import com.bluepay.pay.PublisherCode;
import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;


public class BluePayPlugin extends LifecycleObserverAdapter implements IPlugin {

	protected String id;
	private Activity mActivity;
	
	private boolean isSetupComplete = false;
	private boolean isSetuping = false;
	private boolean isSupported = false;
	private boolean isPurchasing = false;
	private int retryLimit = 4;
	private String uid;
	protected final String TAG = getClass().getSimpleName();
	
	public BluePayPlugin() {
		// TODO Auto-generated constructor stub
	}
	
	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		super.onCreate(activity, savedInstanceState);
		this.mActivity = activity;
		Log.e("BluePayPlugin.onCreate:", String.valueOf(this.mActivity == null));
	}
	
	
	@Override
	public void onDestroy(Activity activity) {
		// BluePay<m>: 退出接口
		Client.exit();
		super.onDestroy(activity);
	}

	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);

	}

	@Override
	public void setId(String id) {
		this.id = id;
		

	}
	
	public boolean isSetupComplete() {
		return isSetupComplete;
	}
	
	public boolean isSupported() {
		return isSupported;
	}
	
	
	private final BlueInitCallback setupFinishedListener = new BlueInitCallback() {
		
		@Override
		public void initComplete(String loginResult, String resultDesc) {
			Log.i(TAG, "Setup finished.");
			
			if (loginResult.equals(LoginResult.LOGIN_SUCCESS)) {
				Log.i(TAG, "Setup successful.");
				isSetupComplete = true;
				isSetuping = false;
				isSupported = true;
				isPurchasing = false;
				
				// BluePay<p>: 使用SDK的UI时,设置UI显示模式为横屏
				BluePay.setLandscape(true);
				BluePayBridge.callLuaSteupCompleteCallbackMethod(true);
				
			} else if (loginResult.equals(LoginResult.LOGIN_FAIL)) {
				// Oh noes, there was a problem.
				Log.e(TAG, "Problem setting up bluePay fail " + resultDesc);
				if(retryLimit-- > 0) {
					Log.i(TAG, "retry ... limit left " + retryLimit);
					startSetUp(setupFinishedListener);
				} else {
					isSetupComplete = true;
					isSetuping = false;
					isSupported = false;
					BluePayBridge.callLuaSteupCompleteCallbackMethod(false);
				}
				
			} else {
				Log.e(TAG, "Problem setting up bluePay other " + resultDesc);
				if(retryLimit-- > 0) {
					Log.i(TAG, "retry ... limit left " + retryLimit);
					startSetUp(setupFinishedListener);
				} else {
					isSetupComplete = true;
					isSetuping = false;
					isSupported = false;
					BluePayBridge.callLuaSteupCompleteCallbackMethod(false);
				}
			}
			
			
		}
	};
	
	
	
	private void startSetUp(final BlueInitCallback setupFinishedListener){
		Log.d(TAG, "setup -> startSetup");
		Client.init(this.mActivity,setupFinishedListener);
	}
	
	
	
	public void setup(){
		
		if(!isSetupComplete){
			if(!isSetuping){
				isSetuping = true;
				retryLimit = 4;
				startSetUp(setupFinishedListener);
			}
		}
		
	}
	
	
	PayCallback mPayCallback = new PayCallback();
	class PayCallback extends IPayCallback {

		private static final long serialVersionUID = 1L;

		/***
		 * 请注意：参数1 的code并非计费成功返回的code，而只是发送计费请求发送成功 计费成功的status code
		 * 在参数2中的msg.getCode()，方法中获取.
		 * */
		/**
		 * Pay attention please: the first parameter its't the code of the
		 * charge,this parameter means whether the request is send success. the
		 * charge status code on the object BlueMessage ,you can get the status
		 * code on msg,for example ,msg.getCode();
		 */
		@Override
		public void onFinished(BlueMessage blueMsg) {
			String title = "";
			isPurchasing = false;
			String result = null;
			int code = blueMsg.getCode();
			boolean isSuccess = false;
			final String transationID = (blueMsg.getTransactionId() == null?"":blueMsg.getTransactionId());
			final String desc = (blueMsg.getDesc() == null)?"":blueMsg.getDesc();
			
			
			if(blueMsg.getPropsName() != null)
			{
				if(code == 200)
				{
					title = BluePayPlugin.this.uid + "购买道具：[" + blueMsg.getPropsName() + "] 成功！";
					result = "bcode:" + blueMsg.getCode() +" 账单ID:"+transationID;
					isSuccess = true;
				}
				else if (code == 603)
				{
					title = BluePayPlugin.this.uid + "购买道具：[" + blueMsg.getPropsName() + "] 取消！";
					result = "bcode:" + blueMsg.getCode() + " 账单ID:"+transationID;
					isSuccess = false;
				}
				else
				{
					title = BluePayPlugin.this.uid + "购买道具：[" + blueMsg.getPropsName() + "] 失败！";
					result = "bcode:" + blueMsg.getCode() + " 账单ID:"+transationID;
					isSuccess = false;
				}
			}
			else
			{
				if(code == 200)
				{
					title = BluePayPlugin.this.uid + "付费：[" + blueMsg.getPrice() + "] 成功！";
					result = "bcode:" + blueMsg.getCode() +" 账单ID:"+transationID;
					isSuccess = true;
				}
				else if (code == 603)
				{
					title = BluePayPlugin.this.uid + "付费：[" + blueMsg.getPrice() + "] 取消！";
					result = "bcode:" + blueMsg.getCode() +" 账单ID:"+ transationID;
					isSuccess = false;
				}
				else
				{
					title = BluePayPlugin.this.uid + "付费：[" + blueMsg.getPrice() + "] 失败！";
					result = "bcode:" + blueMsg.getCode() +" 账单ID:"+ transationID;
					isSuccess = false;
				}
			}
			
			Map<String, String> dataMap = new HashMap<String, String>();
			dataMap.put("result", result);
			dataMap.put("isSuccess", String.valueOf(isSuccess));
			dataMap.put("title", title);
			dataMap.put("code", String.valueOf(code));
			dataMap.put("desc", desc);
			if((blueMsg.getTransactionId()) != null){
				dataMap.put("transationID", transationID);
			}
			try {
				JSONObject jsonObject = new JSONObject(dataMap);
//				Log.i(TAG,"handleMessage jsonObject-->:" + jsonObject.toString());
				final String ret = result;
//				Cocos2dxActivityUtil.runOnUIThread(new Runnable() {
//
//					@Override
//					public void run() {
//						Toast.makeText(BluePayPlugin.this.mActivity, ret,
//								Toast.LENGTH_LONG).show();
//
//					}
//				});
				BluePayBridge.callLuaPurchaseCompleteCallbackMethod(jsonObject
						.toString());
			} catch (Exception e) {
				// TODO: handle exception
				e.printStackTrace();
			}
			
			
		}

		

	}
	
	//transactionId(pid)
	//参数: price必须是泰铢价格X100, 参数都必须填写.
	public void payBySMS(String uid,String pid,String transactionId,String currency,String price,int smsId,String propsName,boolean isShowDialog){
		this.uid = uid;
//		Log.d(TAG, "payBySMS222-> " + "orderId:" + transactionId + "pid: " + pid + "uid: " + uid + " currency:"+ currency + " price:" + price + " smsId:" + smsId + "propsName:" + propsName + " isShowDialog:" + String.valueOf(isShowDialog) );
		if(isSetupComplete && isSupported && !isPurchasing){
//			Log.e("payBySMS","===========================================");
			BluePay.getInstance().payBySMS(this.mActivity, transactionId, currency, price, smsId, propsName, isShowDialog,mPayCallback);
			isPurchasing = true;
		}
	}
	
	
	
	public void payByCashcard(String uid,String pid, String transactionId, String propsName, String publicer, String cardNo, String serialNo){
		if(publicer == "12Call"){
			publicer = PublisherCode.PUBLISHER_12CALL;	
		}else if(publicer == "trueMoney"){
			publicer = PublisherCode.PUBLISHER_TRUEMONEY;
		}
		this.uid = uid;
		if(isSetupComplete && isSupported && !isPurchasing){
			BluePay.getInstance().payByCashcard(this.mActivity,uid,transactionId, propsName,publicer, cardNo, serialNo,mPayCallback);
			isPurchasing = true;
		}
	}

	//transactionId(pid)
	//参数: price必须是泰铢价格X100, 参数都必须填写.
	public void payByBank(String uid,String pid,String transactionId,String currency,String price,String propsName,boolean isShowDialog){
		this.uid = uid;
//		Log.d(TAG, "payByBank-> " + "orderId:" + transactionId + "pid: " + pid + "uid: " + uid + " currency:"+ currency + " price:" + price + "propsName:" + propsName + " isShowDialog:" + String.valueOf(isShowDialog) );
		if(isSetupComplete && isSupported && !isPurchasing){
//			Log.e("payByBank","===========================================");
			BluePay.getInstance().payByBank(this.mActivity, transactionId, currency, price, propsName, isShowDialog, mPayCallback);
			isPurchasing = true;
		}
	}
}
