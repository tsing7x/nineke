package com.boomegg.cocoslib.core.utils;

import java.util.List;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.telephony.SmsManager;
import android.text.TextUtils;

public class SmsUtils {
    public static final int SMS_SUCCESS = 0;
    public static final int SMS_TEXT_IS_EMPTY = 1;// 短信内容为空
    public static final int SMS_DEST_ADDRESS_IS_EMPTY = 2;// 对方号码为空
    public static final int SMS_FAIL_NOSIM = 4; //无sim卡
    
    // 短信发送intent标示
    public static final String SENT_SMS_ACTION = "SENT_SMS_ACTION";
    // 短信传送intent标示
    public static final String DELIVERED_SMS_ACTION = "DELIVERED_SMS_ACTION";
    
    public static int sendSms(String destinationAddress,String smsText) {
        if(SimUtils.haveSimCard()||SimUtils.getAirplaneMode()) {
            return SMS_FAIL_NOSIM;
        }
        if(TextUtils.isEmpty(destinationAddress)) {
            return SMS_DEST_ADDRESS_IS_EMPTY;
        }
        if(TextUtils.isEmpty(smsText)) {
            return SMS_TEXT_IS_EMPTY;
        }
        Context context = Cocos2dxActivityWrapper.getContext();
        SmsManager smsManager = SmsManager.getDefault();
        PendingIntent sendPI = PendingIntent.getBroadcast(context, 0,
                new Intent(SENT_SMS_ACTION), 0);
        PendingIntent mDeliverPI = PendingIntent.getBroadcast(context, 0,
                new Intent(DELIVERED_SMS_ACTION), 0);
        
        if (smsText.length() > 70) {
            List<String> smsTextList = smsManager.divideMessage(smsText);
            for (String text : smsTextList) {
                smsManager.sendTextMessage(destinationAddress, null, text,
                        sendPI, mDeliverPI);
            }
        } else {
            smsManager.sendTextMessage(destinationAddress, null, smsText,
                    sendPI, mDeliverPI);
        }
        return SMS_SUCCESS;
    }
    
    public static int sendSmsAndToast(final Context context,final String destinationAddress,final String smsText,
            final SMSSendCallBack callback,final int...upid){
        if (TextUtils.isEmpty(destinationAddress)) {
            return SMS_DEST_ADDRESS_IS_EMPTY;
        }
        if (TextUtils.isEmpty(smsText)) {
            return SMS_TEXT_IS_EMPTY;
        }
        SmsManager smsManager = SmsManager.getDefault();
        PendingIntent sendPI = PendingIntent.getBroadcast(context, 0,
                new Intent(SENT_SMS_ACTION), 0);
        PendingIntent mDeliverPI = PendingIntent.getBroadcast(context, 0,
                new Intent(DELIVERED_SMS_ACTION), 0);
        
        if (smsText.length() > 70) {
            List<String> smsTextList = smsManager.divideMessage(smsText);
            for (String text : smsTextList) {
                smsManager.sendTextMessage(destinationAddress, null, text,
                        sendPI, mDeliverPI);
            }
        } else {
            smsManager.sendTextMessage(destinationAddress, null, smsText,
                    sendPI, mDeliverPI);
        }
        context.registerReceiver(new BroadcastReceiver() {  
            @Override  
            public void onReceive(Context _context, Intent _intent) {  
                int code = getResultCode();
                switch (code) {  
                case Activity.RESULT_OK:  
                    if(callback != null){
                        callback.onSuccess(Activity.RESULT_OK);
                    }
                break;  
                case SmsManager.RESULT_ERROR_GENERIC_FAILURE:
                    if(callback != null){
                        callback.onFailed(SmsManager.RESULT_ERROR_GENERIC_FAILURE);
                    }
                break;  
                case SmsManager.RESULT_ERROR_RADIO_OFF:  
                    if(callback != null){
                        callback.onFailed(SmsManager.RESULT_ERROR_RADIO_OFF);
                    }
                break;  
                case SmsManager.RESULT_ERROR_NULL_PDU:  
                    if(callback != null){
                        callback.onFailed(SmsManager.RESULT_ERROR_NULL_PDU);
                    }
                break;  
                }  
                context.unregisterReceiver(this);
            }  
        }, new IntentFilter(SENT_SMS_ACTION));
        return SMS_SUCCESS;
    
    }
    
    public static int sendSmsAndToast(Context context, String destinationAddress,
            String smsText) {
        return sendSmsAndToast(context,destinationAddress,smsText,null);
    }
}
