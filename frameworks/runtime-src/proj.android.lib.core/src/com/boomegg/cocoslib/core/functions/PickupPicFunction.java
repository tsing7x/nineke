package com.boomegg.cocoslib.core.functions;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.ILifecycleObserver;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;

public class PickupPicFunction {

	private static final String TAG = PickupPicFunction.class.getSimpleName();
	private static final int PICK_REQUEST_CODE = 20100715;
	private static int callbackMethodId = -1;
	
	public static void apply(int methodId) {
		if(callbackMethodId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callbackMethodId);
			callbackMethodId = -1;
		}
		callbackMethodId = methodId;
		
		if(isSDCARDMounted()) {
			final Intent intent = new Intent(Intent.ACTION_PICK, null);
			intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
			Cocos2dxActivityWrapper.getContext().addObserver(observer);
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
					if(ctx != null) {
						ctx.startActivityForResult(intent, PICK_REQUEST_CODE);
					}
				}
			}, 50);
		} else {
			Log.d(TAG, "SD Card is not found!");
			if(callbackMethodId != -1) {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, "nosdcard");
			}
		}
	}
	
	private static final ILifecycleObserver observer = new LifecycleObserverAdapter() {
		@Override
		public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
			if(Activity.RESULT_CANCELED != resultCode && requestCode == PICK_REQUEST_CODE){
				Uri selectedImage = data.getData();
				String[] filePathColumn = { MediaStore.Images.Media.DATA };
				Context mContext = Cocos2dxActivityWrapper.getContext();
				Cursor cursor = mContext.getContentResolver().query(selectedImage,filePathColumn, null, null, null);
				cursor.moveToFirst();
				int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
				final String picturePath = cursor.getString(columnIndex);
				Log.d(TAG, "selectedImage:" + selectedImage + ",picturePath:" + picturePath);
				if(callbackMethodId != -1) {
					Cocos2dxActivityUtil.runOnBGThread(new Runnable() {
						@Override
						public void run() {
							BitmapFactory.Options newOpts = new BitmapFactory.Options();  
					        //开始读入图片，此时把options.inJustDecodeBounds 设回true了  
					        newOpts.inJustDecodeBounds = true;  
					        Bitmap bitmap = BitmapFactory.decodeFile(picturePath,newOpts);//此时返回bm为空  
					          
					        newOpts.inJustDecodeBounds = false;  
					        int w = newOpts.outWidth;  
					        int h = newOpts.outHeight;  
					        float hh = 800f;
					        float ww = 800f;
					        //缩放比。由于是固定比例缩放，只用高或者宽其中一个数据进行计算即可  
					        int be = 1;//be=1表示不缩放  
					        if (w > h && w > ww) {//如果宽度大的话根据宽度固定大小缩放  
					            be = (int) (newOpts.outWidth / ww);  
					        } else if (w < h && h > hh) {//如果高度高的话根据宽度固定大小缩放  
					            be = (int) (newOpts.outHeight / hh);  
					        }  
					        if (be <= 0)  
					            be = 1;  
					        newOpts.inSampleSize = be;//设置缩放比例  
					        //重新读入图片，注意此时已经把options.inJustDecodeBounds 设回false了  
					        bitmap = BitmapFactory.decodeFile(picturePath, newOpts);
					        
					        File file = new File(Environment.getExternalStorageDirectory(), "/temp_upload_image.jpg");
							if(file.exists()) {
								file.delete();
							}
							FileOutputStream fos = null;
							String newPicturePath = picturePath;
							try {
								fos = new FileOutputStream(file);
								bitmap.compress(Bitmap.CompressFormat.JPEG, 40, fos);
								fos.flush();
								newPicturePath = file.getAbsolutePath();
								file.deleteOnExit();
							} catch (FileNotFoundException e) {
								Log.e(TAG, e.getMessage(), e);
							} catch (IOException e) {
								Log.e(TAG, e.getMessage(), e);
							} finally {
								if(fos != null) {
									try {
										fos.close();
									} catch(Exception e) {}
								}
							}
							final String finalPicturePath = newPicturePath;
							Cocos2dxActivityUtil.runOnResumed(new Runnable() {
								@Override
								public void run() {
									Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
										@Override
										public void run() {
											Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, finalPicturePath);
										}
									}, 50);
								}
							});
						}
					});
				}
			}
		}
	};

	private static boolean isSDCARDMounted() {
		String status = Environment.getExternalStorageState();
		if (status.equals(Environment.MEDIA_MOUNTED))
			return true;
		return false;
	}
}
