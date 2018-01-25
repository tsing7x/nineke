package com.boomegg.cocoslib.core;

public interface ILifecycleNotifier {

	void addObserver(ILifecycleObserver observer);
	
	void removeObserver(ILifecycleObserver observer);
}
