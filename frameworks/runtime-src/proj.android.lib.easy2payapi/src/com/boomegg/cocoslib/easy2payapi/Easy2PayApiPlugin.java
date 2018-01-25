package com.boomegg.cocoslib.easy2payapi;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.utils.SMSSendCallBack;
import com.boomegg.cocoslib.core.utils.SimUtils;
import com.boomegg.cocoslib.core.utils.SmsUtils;

import android.content.Intent;
import android.net.Uri;
import android.widget.Toast;


public class Easy2PayApiPlugin implements IPlugin {
	protected String id;
	@Override
	public void initialize() {		
	}

	@Override
	public void setId(String id) {		
		this.id = id;
	}

	public float getFloat(String strToFloat){
		return getFloat(strToFloat, 0f);
	}

	private void toSendSMSActivity(Uri uri,
			String content) {
		try {
			Intent it = new Intent(Intent.ACTION_SENDTO, uri);
			it.putExtra("sms_body", content);
			Cocos2dxActivityWrapper.getContext().startActivity(it);
		} catch (Exception e) {

		}
	}
	
	/**
	 * 试图将strToFloat字符串转换成float返回, 若无法转换, 则返回指定的默认值defaultVal
	 * @param strToFloat 需要转换成float的字符串
	 * @param defaultVal 默认返回值
	 * @return 如果转换成功则返回成功的值, 否则返回指定的默认值defaultVal
	 */
	public float getFloat(String strToFloat, float defaultVal) {
		try{
			return Float.parseFloat(strToFloat);
		}catch(Exception e){
			return defaultVal;
		}
	}
	
	private <T> Boolean isContainsOf(T[] source, T target) {
		return Arrays.asList(source).contains(target);
	}
	
	public void callback(int code,String msg) {
		Map<String,String> dataMap = new HashMap<String,String>();
		dataMap.put("code", String.valueOf(code));
		dataMap.put("msg", msg);
		Easy2PayApiBridge.callCallback(dataMap);
	}
	
	public void makePurchase(String orderId, String userId,String merchantId,String priceId) {
		String smsTo = ""; // 短信发送的地址
		String smsContent = "";
		SMSSendCallBack smscallback = new SMSSendCallBack() {

			@Override
			public void onSuccess(int code) {
				callback(100,"");
			}

			@Override
			public void onFailed(int code) {
				callback(300 + code,"");
			}

		};

		/** 将价格转换为价格ID **/
		String i_price = (int) getFloat(priceId + "") + ""; // 防止传入的价格带小数点
		String priceID = "";
		if (i_price.equals("10")) {
			priceID = "01";
		} else if (i_price.equals("20")) {
			priceID = "02";
		} else if (i_price.equals("49")) {
			priceID = "04";
		} else if (i_price.equals("79")) {
			priceID = "07";
		} else if (i_price.equals("99")) {
			priceID = "09";
		} else if (i_price.equals("149")) {
			priceID = "14";
		} else {
			callback(500,"");
			return;
		}
		int flag = 1;
		smsContent = merchantId.trim() + " " + orderId;
		if (flag == 1) {// 自动检测SIM运营商
			smsTo = "42105" + priceID;
			int code = SmsUtils.sendSmsAndToast(Cocos2dxActivityWrapper.getContext(), smsTo,
						smsContent, smscallback);
			if(code != 0) {
				callback(400 + code,"");
			}
		} else if (flag == 2) {// 手动选择AIX
			smsTo = "42105" + priceID;
			SmsUtils.sendSmsAndToast(Cocos2dxActivityWrapper.getContext(), smsTo,
					smsContent, smscallback);
		} else if (flag == 3) {// 手动选择DTAC,TRUEMOVE和TRUEMOVEH
			smsTo = "42100" + priceID;
			SmsUtils.sendSmsAndToast(Cocos2dxActivityWrapper.getContext(), smsTo,
					smsContent, smscallback);
		} else if (flag == 4) {// 跳转到系统自带短信发送窗口
			toSendSMSActivity(Uri.parse("smsto:42105" + priceID),smsContent);
		} else if (flag == 5) {
			toSendSMSActivity(Uri.parse("smsto:42100" + priceID),smsContent);

		}
		return;
	}
}
