package com.boomegg.cocoslib.facebook;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

public class FacebookBridge {

	private static final String TAG = FacebookBridge.class.getSimpleName();
	
	private static int loginResultCallback = -1;
	private static int sendInvitesResultCallback = -1;
	private static int invitableFriendsResultCallback = -1;
	private static int shareFeedResultCallback = -1;
	private static int getRequestIdResultCallback = -1;
	private static int uploadPhotoResultCallback = -1;
	private static int getFacebookUserCallback = -1;
	
	private static FacebookPlugin getFacebookLoginPlugin() {
		if(Cocos2dxActivityWrapper.getContext() != null) {
			List<IPlugin> list = Cocos2dxActivityWrapper.getContext().getPluginManager().findPluginByClass(FacebookPlugin.class);
			if(list != null && list.size() > 0) {
				return (FacebookPlugin) list.get(0);
			}else {
				Log.d(TAG, "FacebookLoginPlugin not found");
			}
		}
		return null;
	}
	
	//for lua
	public static void setLoginCallback(final int callback) {
		Log.d(TAG, "setLoginCallback " + callback);
		if(FacebookBridge.loginResultCallback != -1) {
			Log.d(TAG, "release lua function " + FacebookBridge.loginResultCallback);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(FacebookBridge.loginResultCallback);
			FacebookBridge.loginResultCallback = -1;
		}
		FacebookBridge.loginResultCallback = callback;
	}
	
	public static void setSendInvitesCallback(final int callback) {
		Log.d(TAG, "setSendInvitesCallback " + callback);
		if(FacebookBridge.sendInvitesResultCallback != -1) {
			Log.d(TAG, "release lua function " + FacebookBridge.sendInvitesResultCallback);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(FacebookBridge.sendInvitesResultCallback);
			FacebookBridge.sendInvitesResultCallback = -1;
		}
		FacebookBridge.sendInvitesResultCallback = callback;
	}
	
	public static void setInvitableFriendsCallback(final int callback) {
		Log.d(TAG, "setInvitableFriendsCallback " + callback);
		if(FacebookBridge.invitableFriendsResultCallback != -1) {
			Log.d(TAG, "release lua function " + FacebookBridge.invitableFriendsResultCallback);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(FacebookBridge.invitableFriendsResultCallback);
			FacebookBridge.invitableFriendsResultCallback = -1;
		}
		FacebookBridge.invitableFriendsResultCallback = callback;
	}
	
	public static void setShareFeedResultCallback(final int callback) {
		Log.d(TAG, "setShareFeedResultCallback " + callback);
		if(FacebookBridge.shareFeedResultCallback != -1) {
			Log.d(TAG, "release lua function " + FacebookBridge.shareFeedResultCallback);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(FacebookBridge.shareFeedResultCallback);
			FacebookBridge.shareFeedResultCallback = -1;
		}
		FacebookBridge.shareFeedResultCallback = callback;
	}
	
	public static void setUploadPhotoResultCallback(final int callback){
		Log.d(TAG, "setUploadPhotoResultCallback " + callback);
		if(FacebookBridge.uploadPhotoResultCallback != -1) {
			Log.d(TAG, "release lua function " + FacebookBridge.uploadPhotoResultCallback);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(FacebookBridge.uploadPhotoResultCallback);
			FacebookBridge.uploadPhotoResultCallback = -1;
		}
		FacebookBridge.uploadPhotoResultCallback = callback;
	}
	
	public static void setGetRequestIdResultCallback(final int callback) {
		Log.d(TAG, "setGetRequestIdResultCallback " + callback);
		if(FacebookBridge.getRequestIdResultCallback != -1) {
			Log.d(TAG, "release lua function " + FacebookBridge.getRequestIdResultCallback);
			Cocos2dxLuaJavaBridge.releaseLuaFunction(FacebookBridge.getRequestIdResultCallback);
			FacebookBridge.getRequestIdResultCallback = -1;
		}
		FacebookBridge.getRequestIdResultCallback = callback;
	}
	
	public static void setGetFacebookUserCallback(final int callback) {
	    Log.d(TAG, "setGetFacebookUserCallback " + callback);
	    if(FacebookBridge.getFacebookUserCallback != -1) {
	        Log.d(TAG, "release lua function " + FacebookBridge.getFacebookUserCallback);
            Cocos2dxLuaJavaBridge.releaseLuaFunction(FacebookBridge.getFacebookUserCallback);
            FacebookBridge.getFacebookUserCallback = -1;
	    }
	    FacebookBridge.getFacebookUserCallback = callback;
	}
	
	public static void getRequestId() {
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin getRequestId begin");
					plugin.getRequestId();
					Log.d(TAG, "plugin getRequestId end");
				}
			}, 50);
		}
	}
	
	public static void login() {
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin login begin");
					plugin.login();
					Log.d(TAG, "plugin login end");
				}
			}, 50);
		}
	}
	
	public static void logout() {
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin logout begin");
					plugin.logout();
					Log.d(TAG, "plugin logout end");
				}
			}, 50);
		}
	}
	
	public static void getInvitableFriends(final int friendsNum) {
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin getInvitableFriends begin");
					plugin.getInvitableFriends(friendsNum);
					Log.d(TAG, "plugin getInvitableFriends end");
				}
			}, 50);
		}
	}
	
	public static void sendInvites(final String data, final String toIds, final String title, final String message) {
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin sendInvites begin");
					plugin.sendInvites(data, toIds, title, message);
					Log.d(TAG, "plugin sendInvites end");
				}
			}, 50);
		}
	}
	
	public static void shareFeed(final String params) {
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin shareFeed begin");
					plugin.shareFeed(params);
					Log.d(TAG, "plugin shareFeed end");
				}
			}, 50);
		}
	}

	public static void ShareBySystem(final String params) {
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin shareFeed begin");
					plugin.ShareBySystem(params);
					Log.d(TAG, "plugin shareFeed end");
				}
			}, 50);
		}
	}
	
	public static void uploadPhoto(final String params){
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin uploadPhoto begin");
					plugin.uploadPhoto(params);
					Log.d(TAG, "plugin uploadPhoto end");
				}
			}, 50);
		}
	}
	
	public static void deleteRequestId(final String requestId) {
		final FacebookPlugin plugin = getFacebookLoginPlugin();
		if(plugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					Log.d(TAG, "plugin deleteRequestId begin");
					plugin.deleteRequestId(requestId);
					Log.d(TAG, "plugin deleteRequestId end");
				}
			}, 50);
		}
	}
	
	//to lua
	static void callLuaLogin(final String accessToken, boolean delay) {
		Log.d(TAG, "callLuaLogin " + Thread.currentThread().getId());
		if(delay) {
			Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				Cocos2dxActivityUtil.runOnResumed(new Runnable() {
					@Override
					public void run() {
						Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
							@Override
							public void run() {
								Log.d(TAG, "call lua function loginResultCallback " + FacebookBridge.loginResultCallback + " " + accessToken);
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.loginResultCallback, accessToken);
							}
						}, 50);
					}
				});
			}
		} else {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Log.d(TAG, "call lua function loginResultCallback " + FacebookBridge.loginResultCallback + " " + accessToken);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.loginResultCallback, accessToken);
						}
					});
				}
			});
		}
	}
	
	static void callLuaGetUser(final String userFbId, boolean delay) {
        Log.d(TAG, "callLuaLogin " + Thread.currentThread().getId());
        if(delay) {
            Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
            if(ctx != null) {
                Cocos2dxActivityUtil.runOnResumed(new Runnable() {
                    @Override
                    public void run() {
                        Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
                            @Override
                            public void run() {
                                Log.d(TAG, "call lua function getFacebookUserCallback " + FacebookBridge.getFacebookUserCallback + " " + userFbId);
                                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.getFacebookUserCallback, userFbId);
                            }
                        }, 50);
                    }
                });
            }
        } else {
            Cocos2dxActivityUtil.runOnResumed(new Runnable() {
                @Override
                public void run() {
                    Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
                        @Override
                        public void run() {
                            Log.d(TAG, "call lua function getFacebookUserCallback " + FacebookBridge.getFacebookUserCallback + " " + userFbId);
                            Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.getFacebookUserCallback, userFbId);
                        }
                    });
                }
            });
        }
    }
	
	static void callLuaInvitableFriendsResult(final String result, boolean delay) {
		Log.d(TAG, "callLuaInvitableFriendsResult " + Thread.currentThread().getId());
		if(delay) {
			Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				Cocos2dxActivityUtil.runOnResumed(new Runnable() {
					@Override
					public void run() {
						Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
							@Override
							public void run() {
								Log.d(TAG, "call lua function invitableFriendsResultCallback " + FacebookBridge.invitableFriendsResultCallback + " " + result);
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.invitableFriendsResultCallback, result);
							}
						}, 50);
					}
				});
			}
		} else {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Log.d(TAG, "call lua function invitableFriendsResultCallback " + FacebookBridge.invitableFriendsResultCallback + " " + result);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.invitableFriendsResultCallback, result);
						}
					});
				}
			});
		}
	}
	
	static void callLuaInviteResult(final String result, boolean delay) {
		Log.d(TAG, "callLuaInviteResult " + Thread.currentThread().getId());
		if(delay) {
			Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				Cocos2dxActivityUtil.runOnResumed(new Runnable() {
					@Override
					public void run() {
						Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
							@Override
							public void run() {
								Log.d(TAG, "call lua function sendInvitesResultCallback " + FacebookBridge.sendInvitesResultCallback + " " + result);
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.sendInvitesResultCallback, result);
							}
						}, 50);
					}
				});
			}
		} else {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Log.d(TAG, "call lua function sendInvitesResultCallback " + FacebookBridge.sendInvitesResultCallback + " " + result);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.sendInvitesResultCallback, result);
						}
					});
				}
			});
		}
	}
	
	static void callLuaGetRequestIdResult(final String result, boolean delay) {
		Log.d(TAG, "callLuaGetRequestIdResult " + Thread.currentThread().getId());
		if(delay) {
			Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				Cocos2dxActivityUtil.runOnResumed(new Runnable() {
					@Override
					public void run() {
						Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
							@Override
							public void run() {
								Log.d(TAG, "call lua function getRequestIdResult " + FacebookBridge.getRequestIdResultCallback + " " + result);
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.getRequestIdResultCallback, result);
							}
						}, 50);
					}
				});
			}
		} else {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Log.d(TAG, "call lua function getRequestIdResult " + FacebookBridge.getRequestIdResultCallback + " " + result);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.getRequestIdResultCallback, result);
						}
					});
				}
			});
		}
	}
	
	static void callLuaShareFeedResult(final String result, boolean delay) {
		Log.d(TAG, "callLuaShareFeedResult " + Thread.currentThread().getId());
		if(delay) {
			Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				Cocos2dxActivityUtil.runOnResumed(new Runnable() {
					@Override
					public void run() {
						Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
							@Override
							public void run() {
								Log.d(TAG, "call lua function shareFeedResultCallback " + FacebookBridge.shareFeedResultCallback + " " + result);
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.shareFeedResultCallback, result);
							}
						}, 50);
					}
				});
			}
		} else {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Log.d(TAG, "call lua function shareFeedResultCallback " + FacebookBridge.shareFeedResultCallback + " " + result);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.shareFeedResultCallback, result);
						}
					});
				}
			});
		}
	}
	
	static void callLuaUploadPhotoResult(final String result, boolean delay) {
		Log.d(TAG, "callLuaUploadPhotoResult " + Thread.currentThread().getId());
		if(delay) {
			Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				Cocos2dxActivityUtil.runOnResumed(new Runnable() {
					@Override
					public void run() {
						Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
							@Override
							public void run() {
								Log.d(TAG, "call lua function uploadPhotoResultCallback " + FacebookBridge.uploadPhotoResultCallback + " " + result);
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.uploadPhotoResultCallback, result);
							}
						}, 50);
					}
				});
			}
		} else {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Log.d(TAG, "call lua function uploadPhotoResultCallback " + FacebookBridge.uploadPhotoResultCallback + " " + result);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(FacebookBridge.uploadPhotoResultCallback, result);
						}
					});
				}
			});
		}
	}
	
	static void releaseMethods() {
		Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				if(loginResultCallback != -1) {
					Cocos2dxLuaJavaBridge.releaseLuaFunction(loginResultCallback);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(sendInvitesResultCallback);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(invitableFriendsResultCallback);
					Cocos2dxLuaJavaBridge.releaseLuaFunction(shareFeedResultCallback);
					
					loginResultCallback = -1;
					sendInvitesResultCallback = -1;
					invitableFriendsResultCallback = -1;
					shareFeedResultCallback = -1;
				}
			}
		});
	}
}
