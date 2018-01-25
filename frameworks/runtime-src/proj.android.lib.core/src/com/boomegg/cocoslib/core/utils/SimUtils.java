package com.boomegg.cocoslib.core.utils;

import java.util.Arrays;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

import android.content.Context;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

public class SimUtils {
    public static final String[] AIS_MCC_MNC = {"52001", "52003", "52023"};
    public static final String[] DTAC_MCC_MNC = {"52005", "52018"};
    public static final String[] TRUEMOVE_MCC_MNC = {"52000", "52004", "52099"};
    public static final String[] MAXIS_MCC_MNC = {"50212","50217"};
    public static final String[] DIGI_MCC_MNC = {"50210","50216"};
    public static final String[] CELCOM_MCC_MNC = {"50213","50219"};
    
    public static String getOperatorName() {
        TelephonyManager telephonyManager = (TelephonyManager)
                Cocos2dxActivityWrapper.getContext().getSystemService(Context.TELEPHONY_SERVICE);
        String operatorName = "";
        int simState = telephonyManager.getSimState();
        switch(simState) {
        case TelephonyManager.SIM_STATE_READY:
            operatorName = telephonyManager.getNetworkOperatorName();
            break;
        case TelephonyManager.SIM_STATE_ABSENT:
            operatorName = "HAVE NO SIM CARD";
            break;
        case TelephonyManager.SIM_STATE_PIN_REQUIRED:
            operatorName = "SIM CARD HAVA BE LOCKED";
            break;
        case TelephonyManager.SIM_STATE_PUK_REQUIRED:
            operatorName = "SIM CARD HAVA BE LOCKED";
            break;
        case TelephonyManager.SIM_STATE_NETWORK_LOCKED:
            operatorName = "SIM CARD HAVA BE LOCKED";
            break;
        default:
            operatorName = "UNKOWN REASON";
            break;
        }
        return operatorName;
    }
    
    public static boolean haveSimCard() {
        TelephonyManager telephonyManager = (TelephonyManager)
                Cocos2dxActivityWrapper.getContext().getSystemService(Context.TELEPHONY_SERVICE);
        if(telephonyManager.getSimState() == TelephonyManager.SIM_STATE_ABSENT) {
            return false;
        }
        return true;
    }
    
    public static boolean isE2pSupported() {
        String simCode = getSimOperatorCode();
        if(isContainsOf(AIS_MCC_MNC, simCode)
                 || isContainsOf(DTAC_MCC_MNC, simCode)
                 || isContainsOf(TRUEMOVE_MCC_MNC, simCode)
                 ){
            return true;
        }
       return false;
    }
    
    public static boolean isMaDiCelSupported() {
        String simCode = getSimOperatorCode();
         if(isContainsOf(MAXIS_MCC_MNC, simCode)
                  || isContainsOf(DIGI_MCC_MNC, simCode)
                  || isContainsOf(CELCOM_MCC_MNC, simCode)
                  ){
             return true;
         }
        return false;
    }
    
    public static boolean getAirplaneMode(){
        int isAirplaneMode = Settings.System.getInt(Cocos2dxActivityWrapper.getContext().getContentResolver(),
                   Settings.System.AIRPLANE_MODE_ON, 0) ;
        return (isAirplaneMode == 1)? true:false;
    }
    
    public static String getSimOperatorCode() {
        if(!haveSimCard()){
            return "";
        }
        String code = "";
        TelephonyManager tmManager = (TelephonyManager) Cocos2dxActivityWrapper.getContext()
                .getSystemService(Context.TELEPHONY_SERVICE);
        code = tmManager.getSimOperator();
        if (!TextUtils.isEmpty(code)) {
            return code;
        }else{
            code = getSimOperatorFive();
        }
        if (code == null) {
            return "";
        }
        return code;
    }
    
    public static String getSimOperator() {
        if(!haveSimCard()){
            return "";
        }
        TelephonyManager tm = (TelephonyManager)Cocos2dxActivityWrapper.getContext().getSystemService(Context.TELEPHONY_SERVICE);
        return tm.getSubscriberId();
    }
    
    public static String getSimOperatorFive(){
        String code = getSimOperator();
        if (!TextUtils.isEmpty(code) && code.length() > 5) {
            code = code.substring(0, 5);
            return code;
        }
        return code;
    }
    
    public static <T> Boolean isContainsOf(T[] source, T target)
    {
        return Arrays.asList(source).contains(target);
    }
}
