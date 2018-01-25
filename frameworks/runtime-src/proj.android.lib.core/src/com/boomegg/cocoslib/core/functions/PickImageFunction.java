package com.boomegg.cocoslib.core.functions;

import java.io.File;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.ILifecycleObserver;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;

public class PickImageFunction {

	private static final String TAG = PickImageFunction.class.getSimpleName();
	private static final int PICK_REQUEST_CODE = 9634579;
	private static final int CROP_REQUEST_CODE = 9634578;
	private static int callbackMethodId = -1;
	private static File tempFile;
	
	public static void apply(int methodId) {
		if(callbackMethodId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callbackMethodId);
			callbackMethodId = -1;
		}
		callbackMethodId = methodId;
		
		if(isSDCARDMounted()) {
//			final Intent intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
//			intent.setType("image/*");
//			intent.putExtra("crop","true");
//			intent.putExtra("scale", true);
//			intent.putExtra("outputX", 100);
//			intent.putExtra("outputY", 100);
//			intent.putExtra("aspectX", 1);
//			intent.putExtra("aspectY", 1);
//			intent.putExtra(MediaStore.EXTRA_OUTPUT, getTempFileUri());
//			intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
//			Cocos2dxActivityWrapper.getContext().addObserver(observer);
//			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
//				@Override
//				public void run() {
//					Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
//					if(ctx != null) {
//						ctx.startActivityForResult(intent, PICK_REQUEST_CODE);
//					}
//				}
//			}, 50);
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
				Log.d(TAG, "selected image => " + (selectedImage != null ? selectedImage.toString() : null));
				if(selectedImage != null) {
					Intent intent = new Intent("com.android.camera.action.CROP");
					intent.setDataAndType(selectedImage, "image/*");
					intent.putExtra("crop", "true");
					intent.putExtra("scale", true);
					intent.putExtra("aspectX", 1);
					intent.putExtra("aspectY", 1);
					intent.putExtra("outputX", 200);
					intent.putExtra("outputY", 200);
					intent.putExtra("return-data", false);
					intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
					intent.putExtra(MediaStore.EXTRA_OUTPUT, getTempFileUri());
					activity.startActivityForResult(intent, CROP_REQUEST_CODE);
				}
			} else if(Activity.RESULT_CANCELED != resultCode && requestCode == CROP_REQUEST_CODE) {
				if(tempFile == null || !tempFile.exists() || !tempFile.isFile()) {
					Log.d(TAG, "temp head image not found!");
					if(callbackMethodId != -1) {
						Cocos2dxActivityUtil.runOnResumed(new Runnable() {
							@Override
							public void run() {
								Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
									@Override
									public void run() {
										Log.d(TAG, "call callbackMethodId "+ callbackMethodId + " error");
										Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, "error");
									}
								});
							}
						});
					}
				} else {
					Log.d(TAG, "temp head image filepath->" + tempFile.getAbsolutePath());
					if(callbackMethodId != -1) {
						Cocos2dxActivityUtil.runOnResumed(new Runnable() {
							@Override
							public void run() {
								Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
									@Override
									public void run() {
										Log.d(TAG, "call callbackMethodId "+ callbackMethodId + " " + tempFile.getAbsolutePath() + " exists " + tempFile.exists());
										Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, tempFile.getAbsolutePath());
									}
								}, 300);
							}
						});
					}
				}
			}
		}
	};
	
	private static Uri getTempFileUri() {
		if (isSDCARDMounted()) {
			Uri uri = null;
			try {
				tempFile = new File(Environment.getExternalStorageDirectory(), "temp_head_image" + System.currentTimeMillis() + ".jpg");
				if(tempFile.exists()) {
					tempFile.delete();
				}
				uri = Uri.fromFile(tempFile);
				Log.d(TAG, "TEMP file " + uri.getPath());
			} catch (Exception e) {}
			return uri;
		} else {
			return null;
		}
	}

	private static boolean isSDCARDMounted() {
		String status = Environment.getExternalStorageState();
		if (status.equals(Environment.MEDIA_MOUNTED))
			return true;
		return false;
	}
}
