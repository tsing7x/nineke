package com.boomegg.cocoslib.core;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public interface ILifecycleObserver {
	void onCreate(Activity activity, Bundle savedInstanceState);
	void onRestoreInstanceState(Activity activity, Bundle savedInstanceState);
	void onStart(Activity activity);
	void onRestart(Activity activity);
	void onSaveInstanceState(Activity activity, Bundle outState);
	void onPause(Activity activity);
	void onResume(Activity activity);
	void onStop(Activity activity);
	void onDestroy(Activity activity);
	void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data);
}
