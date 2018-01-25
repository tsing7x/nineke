package com.boyaa.admobile.ad.boya;

import android.content.Context;
import android.content.Intent;
import com.boyaa.admobile.entity.AdTask;
import com.boyaa.admobile.entity.BasicMessageData;
import com.boyaa.admobile.service.CommitService;
import com.boyaa.admobile.util.TaskManager;

import java.util.HashMap;

/**
 * @author Carrywen
 */
public class BoyaaManager {


    public static BoyaaManager mBoyaaManager;

    private static byte[] sync = new byte[1];


    private BoyaaManager() {
    }


    public static BoyaaManager getInstance() {
        if (mBoyaaManager == null) {
            mBoyaaManager = new BoyaaManager();
        }
        return mBoyaaManager;
    }

    /**
     * 续传上报数据
     *
     * @param context
     * @param data
     */
    public void commitRecord(Context context, BasicMessageData data) {
        AdTask adTask = new AdTask(data);
        adTask.offLineFlag = true;
        TaskManager.getInstance(context).addTask(adTask);
    }

    /**
     * 启动离线上报数据服务
     *
     * @param context
     */
    public void startCommitService(Context context) {
        Intent intent = new Intent(context, CommitService.class);
        context.startService(intent);
    }

}
