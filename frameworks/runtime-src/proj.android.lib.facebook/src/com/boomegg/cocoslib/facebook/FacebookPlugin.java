package com.boomegg.cocoslib.facebook;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.net.Uri;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;
import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookDialog;
import com.facebook.FacebookException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.FacebookRequestError;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphRequest.Callback;
import com.facebook.GraphResponse;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.Sharer.Result;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.AppInviteDialog;
import com.facebook.share.widget.GameRequestDialog;
import com.facebook.share.widget.ShareDialog;


public class FacebookPlugin extends LifecycleObserverAdapter implements IPlugin {

    private static final String TAG = FacebookPlugin.class.getSimpleName();
    private static final String PENDING_ACTION_BUNDLE_KEY = "com.boomegg.cocoslib.facebook:PendingAction";
    
    private enum PendingAction {
        NONE(null),
        LOGIN(null),
        INVITE(null),
        GET_REQUEST_ID(null),
        INVITABLE_FRIENDS("user_friends"),
        SHARE_FEED(null),
        UPLOAD_PHOTO(null);
        private List<String> permissions;
        private PendingAction(String permissions) {
            if(!TextUtils.isEmpty(permissions)) {
                this.permissions = new ArrayList<String>();
                this.permissions.addAll(Arrays.asList(permissions.split(",")));
            }
        }
        
        public boolean isAllPermissionGranted(AccessToken accessToken) {
            boolean allPermissionGranted = true;
            if (permissions != null) {
                for(String permission:permissions) {
                    if(!accessToken.getPermissions().contains(permission)) {
                        allPermissionGranted = false;
                        break;
                    }
                }
            }
            return allPermissionGranted && !accessToken.isExpired();
        }
        
        private boolean hasPublishPermission(AccessToken accessToken) {
            return accessToken.getPermissions().contains("publish_actions");
        }
        
        public List<String> getPendingPermissions(AccessToken accessToken,int type) {
            List<String> pendingPermission = new ArrayList<String>();
            if(permissions != null) {
                for(String permission:permissions) {
                    if(type == 1) {
                        if(!LoginManager.isPublishPermission(permission)) {
                            if (accessToken != null) {
                                if(!accessToken.getPermissions().contains(permission)) {
                                    pendingPermission.add(permission);
                                }
                            } else {
                                pendingPermission.add(permission);
                            }
                            
                        }
                    }else if(type == 2) {
                        if(LoginManager.isPublishPermission(permission)) {
                            if (accessToken != null) {
                                if(!accessToken.getPermissions().contains(permission)) {
                                    pendingPermission.add(permission);
                                }
                            } else {
                                pendingPermission.add(permission);
                            }
                            
                        }
                    }
                }
            }
            if(pendingPermission.size() == 0 && (accessToken == null ||accessToken.isExpired())) {
                pendingPermission.add("email");
                pendingPermission.add("user_friends");
            }
            return pendingPermission;
        }
    }
    
    private String pluginId;
    private PendingAction pendingAction = PendingAction.NONE;
    private CallbackManager callbackManager;
    private ProfileTracker profileTracker;
    private String inviteData;
    private String inviteMessage;
    private String inviteToIds;
    private String inviteTitle;
    private String feedData;
    private String uploadPhotoData;
    private int inviteLimit;
    private boolean canPresentShareDialogWithPhotos;
    private GameRequestDialog gameRequestDialog;
    private ShareDialog shareDialog;
    @Override
    public void initialize() {
        Cocos2dxActivityWrapper.getContext().addObserver(this);
    }

    @Override
    public void setId(String id) {
        pluginId = id;
    }
    
    public String getId() {
        return pluginId;
    }
    
    
    private void doLogin(boolean isPermissionUpdated, String reason) {
        Log.d(TAG, "doLogin");
        if(isPermissionUpdated) {
            FacebookBridge.callLuaLogin(AccessToken.getCurrentAccessToken().getToken(), true);
        } else {
            FacebookBridge.callLuaLogin(reason, true);
        }
    }
    
    private void doInvite(boolean isPermissionUpdated, String reason) {
        if(isPermissionUpdated) {
            final Bundle params = new Bundle();
            params.putString("message", inviteMessage);
            params.putString("title", inviteTitle);
            params.putString("to", inviteToIds);
            params.putString("data", inviteData);
        }
        String[] recipientsArray = inviteToIds.split(",");
        
        GameRequestContent content = new GameRequestContent.Builder()
                    .setMessage(inviteMessage)
                    .setTitle(inviteTitle)
                    .setRecipients(Arrays.asList(recipientsArray))
                    .setData(inviteData)
                    .build();
        if(GameRequestDialog.canShow()) {
            gameRequestDialog.show(Cocos2dxActivityWrapper.getContext(), content);
        } else {
            FacebookBridge.callLuaInviteResult("failed", true);
        }
    }
    
    private void doGetInvitableFriends(boolean isPermissionUpdated, String reason) {
        if(isPermissionUpdated) {
            Bundle args = new Bundle();
            args.putInt("limit", inviteLimit);
            Log.d("doGetInvitableFriends", "" + inviteLimit);
            GraphRequest.newGraphPathRequest(AccessToken.getCurrentAccessToken(), "me/invitable_friends",args, new Callback() {
                @Override
                public void onCompleted(GraphResponse response) {
                    FacebookRequestError error = response.getError();
                    if(error != null) {
                        Log.e(TAG, "invitable_friends error" + error.toString());
                        FacebookBridge.callLuaInvitableFriendsResult("failed", true);
                    } else {
                        String rawStr = response.getRawResponse();
                        Log.d(TAG, "invitable_friends ret->" + rawStr);
                        try {
                            JSONObject rawJson = new JSONObject(rawStr);
                            JSONArray dataArr = rawJson.getJSONArray("data");
                            int len = dataArr.length();
                            JSONArray arr = new JSONArray();
                            for(int i = 0; i < len; i++) {
                                JSONObject row = dataArr.getJSONObject(i);
                                JSONObject picture = row.getJSONObject("picture");
                                JSONObject retJson = new JSONObject();
                                retJson.put("id", row.optString("id"));
                                retJson.put("name", row.optString("name"));
                                if(picture != null) {
                                    JSONObject data = picture.optJSONObject("data");
                                    if(data != null) {
                                        retJson.put("url", data.optString("url"));
                                    }
                                }
                                arr.put(retJson);
                            }
                            //yk
                            String token = AccessToken.getCurrentAccessToken().getToken();
                            JSONObject retJson = new JSONObject();
                            retJson.put("token", token);
                            arr.put(retJson);
//                            String result = arr.toString() + "<accessToken=" + token + ">";
                            FacebookBridge.callLuaInvitableFriendsResult(arr.toString(), true);
                            //old
//                            FacebookBridge.callLuaInvitableFriendsResult(arr.toString(), true);
                        } catch(Exception e) {
                            Log.e(TAG, e.getMessage(), e);
                            FacebookBridge.callLuaInvitableFriendsResult("failed", true);
                        }
                    }
                }
            }).executeAsync();
        } else {
            FacebookBridge.callLuaInvitableFriendsResult(reason, true);
        }
    }
    
    private void doGetRequestId(boolean isPermissionUpdated, String reason) {
        if(isPermissionUpdated) {
            GraphRequest.newGraphPathRequest(AccessToken.getCurrentAccessToken(), "me/apprequests", new Callback() {
                @Override
                public void onCompleted(GraphResponse response) {
                    FacebookRequestError error = response.getError();
                    if(error != null) {
                        Log.e(TAG, "get apprequests error" + error.toString());
                        FacebookBridge.callLuaGetRequestIdResult("failed", true);
                    } else {
                        String rawStr = response.getRawResponse();
                        Log.d(TAG, "get apprequests ret->" + rawStr);
                        try {
                            JSONObject rawJson = new JSONObject(rawStr);
                            JSONArray dataArr = rawJson.getJSONArray("data");
                            JSONObject ret = new JSONObject();
                            if(dataArr != null && dataArr.length() > 0) {
                                JSONObject json = dataArr.getJSONObject(0);
                                String requestId = json.optString("id");
                                String requestData = json.optString("data");
                                ret.putOpt("requestId", requestId);
                                ret.putOpt("requestData", requestData);
                            }
                            FacebookBridge.callLuaGetRequestIdResult(ret.toString(), true);
                        } catch(Exception e) {
                            Log.e(TAG, e.getMessage(), e);
                            FacebookBridge.callLuaGetRequestIdResult("failed", true);
                        }
                    }
                }
            }).executeAsync();
        } else {
            FacebookBridge.callLuaGetRequestIdResult(reason, true);
        }
    }
    
    private void doShareFeed(boolean isPermissionUpdated,String reason) {
        if(isPermissionUpdated) {
            try {
                JSONObject json = new JSONObject(feedData);
                String name = json.optString("name");
                String caption = json.optString("caption");
                String message = json.optString("message");
                String link = json.optString("link");
                String picture = json.optString("picture");
                ShareLinkContent content = new ShareLinkContent.Builder()
                            .setContentTitle(caption)
                            .setContentDescription(name)
                            .setContentUrl(Uri.parse(link))
                            .setImageUrl(Uri.parse(picture))
                            .build();
                if(ShareDialog.canShow(ShareLinkContent.class)) {
                    shareDialog.show(content, ShareDialog.Mode.FEED);
                } else {
                    FacebookBridge.callLuaShareFeedResult("failed", true);
                }
            }catch(Exception e) {
                Log.e(TAG, e.getMessage(), e);
            }
        } else {
            FacebookBridge.callLuaShareFeedResult(reason, true);
        }
    }
    
    
    private void doUploadPhoto(boolean isPermissionUpdated,String reason) {
//        if(isPermissionUpdated) {
//            try {
//                JSONObject json = new JSONObject(uploadPhotoData);
//                String path = json.optString("path");
//                String link = json.optString("link");
//                File file = new File(path);
//                if (canPresentShareDialogWithPhotos) {
//                    FacebookDialog uploadDialog = createShareDialogBuilderForaddPhotoFiles(file).build();
//                    uploadDialog.present();
////                  uiHelper.trackPendingDialogCall(shareDialog.present());
//                }else{
//                     GraphRequest request = GraphRequest.newUploadPhotoRequest(
//                             AccessToken.getCurrentAccessToken(),
//                             file,
//                             new GraphRequest.Callback() {
//                                 @Override
//                                 public void onCompleted(GraphResponse response) {
//                                     FacebookRequestError error = response.getError();
//                                     Log.e(TAG, "FUCK HUA DIDI");
//                                     if(error == null) {
//                                         String rawStr = response.getRawResponse();
//                                         Log.d(TAG, "uploadPhotoId ret->" + rawStr);
//                                         FacebookBridge.callLuaUploadPhotoResult(rawStr, true);
//                                     } else {
//                                         Log.e(TAG, "uploadPhotoId error" + error.toString());
//                                         FacebookBridge.callLuaUploadPhotoResult("failed", true);
//                                     }
//                                 }
//                             }
//                     );
//                     Bundle parameters = request.getParameters(); // <-- THIS IS IMPORTANT
//                     parameters.putString("name", json.optString("name"));
//                     parameters.putString("caption", json.optString("caption"));
//                     parameters.putString("message", json.optString("message"));
//                     parameters.putString("link", json.optString("link"));
////                   parameters.putString("picture", json.optString("picture"));
//                     request.setParameters(parameters);
//                     request.executeAsync();
//                }
//            } catch(Exception e) {
//                Log.e(TAG, e.getMessage(), e);
//            }
//        } else {
//            FacebookBridge.callLuaUploadPhotoResult(reason, true);
//        }
    }
    
    private void handlePendingAction(boolean isPermissionUpdated, String reason) {
        Log.d(TAG, "handlePendingAction " + isPermissionUpdated + " " + reason);
        PendingAction previouslyPendingAction = pendingAction;
        // These actions may re-set pendingAction if they are still pending, but we assume they
        // will succeed.
        pendingAction = PendingAction.NONE;

        switch (previouslyPendingAction) {
            case LOGIN:
                doLogin(isPermissionUpdated, reason);
                break;
            case INVITE:
                doInvite(isPermissionUpdated, reason);
                break;
            case SHARE_FEED:
                doShareFeed(isPermissionUpdated, reason);
                break;
            case UPLOAD_PHOTO:
                doUploadPhoto(isPermissionUpdated, reason);
                break;
            case INVITABLE_FRIENDS:
                doGetInvitableFriends(isPermissionUpdated, reason);
                break;
            case GET_REQUEST_ID:
                doGetRequestId(isPermissionUpdated, reason);
                break;
            case NONE:
                break;
        }
    }
    
    public void requestPermission(AccessToken accessToken, PendingAction pendingAction) {
        Log.d(TAG,"requestPermission");
        List<String> permissions = pendingAction.getPendingPermissions(accessToken, 1);
        if(permissions != null && permissions.size() > 0) {
            Log.d(TAG, "request read permission" + Arrays.toString(permissions.toArray()));
            LoginManager.getInstance().logInWithReadPermissions(Cocos2dxActivityWrapper.getContext(), permissions);
        }else {
            permissions = pendingAction.getPendingPermissions(accessToken, 2);
            if(permissions != null && permissions.size() > 0) {
                Log.d(TAG, "request publish permission" + Arrays.toString(permissions.toArray()));
                LoginManager.getInstance().logInWithPublishPermissions(Cocos2dxActivityWrapper.getContext(), permissions);
            }
        }
    }
    
    public void login() {
        Log.d(TAG, "login");
        pendingAction = PendingAction.NONE;
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if(accessToken != null && !accessToken.isExpired()) {
            FacebookBridge.callLuaLogin(accessToken.getToken(), false);
        } else {
           pendingAction = PendingAction.LOGIN;
           Log.d(TAG, "request permission");
           List<String> permissions = new ArrayList<String>();
           permissions.add("email");
           permissions.add("user_friends");
           LoginManager loginManager = LoginManager.getInstance();
           loginManager.logInWithReadPermissions(Cocos2dxActivityWrapper.getContext(), permissions);
        }
    }
    
    
    public void getRequestId() {
        pendingAction = PendingAction.GET_REQUEST_ID;
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if(accessToken != null && pendingAction.isAllPermissionGranted(accessToken)) {
            handlePendingAction(true, null);
        } else {
            requestPermission(accessToken, pendingAction);
        }
    }
    
    public void logout() {
        pendingAction = PendingAction.NONE;
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if(accessToken != null) {
            LoginManager.getInstance().logOut();
        }
        
    }
    
    public void getInvitableFriends(final int friendsNum) {
        pendingAction = PendingAction.INVITABLE_FRIENDS;
        inviteLimit = friendsNum;
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if(accessToken != null && pendingAction.isAllPermissionGranted(accessToken)) {
            handlePendingAction(true, null);
        } else {
            requestPermission(accessToken, pendingAction);
        }
    }
    
    public void sendInvites(final String data, final String toIds, final String title, final String message) {
        pendingAction = PendingAction.INVITE;
        inviteMessage = message;
        inviteToIds = toIds;
        inviteTitle = title;
        inviteData = data;
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if(accessToken != null && pendingAction.isAllPermissionGranted(accessToken)) {
            handlePendingAction(true, null);
        } else {
            requestPermission(accessToken, pendingAction);
        }
    }
    
    public void shareFeed(String params) {
        pendingAction = PendingAction.SHARE_FEED;
        feedData = params;
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if(accessToken != null && pendingAction.isAllPermissionGranted(accessToken)) {
            handlePendingAction(true, null);
        } else {
            requestPermission(accessToken, pendingAction);
        }
    }

	public void ShareBySystem(String params) {
		feedData = params;
		try {
				JSONObject json = new JSONObject(feedData);
			    String name = json.optString("name");
			    String caption = json.optString("caption");
			    String message = json.optString("message");
			    String link = json.optString("link");
			    String picture = json.optString("picture");

                Intent shareIntent = new Intent();
                shareIntent.setAction(Intent.ACTION_SEND);

			    if(picture != null && !picture.equals("")){
					Uri imageUri = Uri.fromFile(new File(picture));
			        shareIntent.putExtra(Intent.EXTRA_STREAM, imageUri);
			        shareIntent.setType("image/*");
			    }else{
                    shareIntent.setType("text/plain"); 
                }
                if(name != null){
                    shareIntent.putExtra(Intent.EXTRA_TEXT, name + link);
                    shareIntent.putExtra("sms_body", name + link);
                }
                if(caption != null){
                    shareIntent.putExtra(Intent.EXTRA_SUBJECT, caption);
                }
                Cocos2dxActivityWrapper.getContext().startActivity(Intent.createChooser(shareIntent, "Share to"));
			} catch(Exception e) {
				Log.e(TAG, e.getMessage(), e);
			}
	}
	
    public void uploadPhoto(String params) {
        pendingAction = PendingAction.UPLOAD_PHOTO;
        uploadPhotoData = params;
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if(accessToken != null && pendingAction.hasPublishPermission(accessToken)) {
            handlePendingAction(true, null);
        } else {
            requestPermission(accessToken, pendingAction);
        }
    }
    
    public void deleteRequestId(String requestId) {
        GraphRequest.newDeleteObjectRequest(AccessToken.getCurrentAccessToken(), requestId, new Callback() {
            @Override
            public void onCompleted(GraphResponse response) {
                FacebookRequestError error = response.getError();
                if(error != null) {
                    Log.e(TAG, "deleteRequestId error" + error.toString());
                } else {
                    String rawStr = response.getRawResponse();
                    Log.d(TAG, "deleteRequestId ret->" + rawStr);
                }
            }
        }).executeAsync();
    }
    
    public void onCreate(Activity activity, Bundle savedInstanceState) {
        FacebookSdk.sdkInitialize(Cocos2dxActivityWrapper.getContext().getApplicationContext());
        
        callbackManager = CallbackManager.Factory.create();
        LoginManager.getInstance().registerCallback(callbackManager,
                new FacebookCallback<LoginResult>(){

                    @Override
                    public void onSuccess(LoginResult result) {
                        handlePendingAction(true,null);
                    }

                    @Override
                    public void onCancel() {
                        handlePendingAction(false,"canceled");
                    }

                    @Override
                    public void onError(FacebookException error) {
                        handlePendingAction(false, error instanceof FacebookException ? "canceled" : "failed" );
                    }
        });
        FacebookCallback<GameRequestDialog.Result> gameRequestCallback =
                new FacebookCallback<GameRequestDialog.Result>() {
                    @Override
                    public void onSuccess(GameRequestDialog.Result result) {
                        Log.d(TAG, "Success!");
                        String requestId = result.getRequestId();
                        if(requestId != null) {
                            StringBuilder idSb = new StringBuilder();
                            List<String> ids = result.getRequestRecipients();
                            for(int i = 0; i < ids.size() - 1;i++) {
                                idSb.append(ids.get(i)).append(",");
                            }
                            idSb.append(ids.get(ids.size() - 1));
                            JSONObject json = new JSONObject();
                            try {
                                json.put("requestId", requestId);
                                json.put("toIds", idSb.toString());
                            } catch(Exception e) {
                                Log.e(TAG, e.getMessage(), e);
                            }
                            FacebookBridge.callLuaInviteResult(json.toString(), true);
                        }
                    }

                    @Override
                    public void onCancel() {
                        Log.d(TAG, "Canceled");
                        FacebookBridge.callLuaInviteResult("canceled", true);
                    }

                    @Override
                    public void onError(FacebookException error) {
                        Log.d(TAG, String.format("Error: %s", error.toString()));
                        error.printStackTrace();
                        if (error instanceof FacebookOperationCanceledException) {
                            FacebookBridge.callLuaInviteResult("canceled", true);
                        } else {
                            FacebookBridge.callLuaInviteResult(String.format("failed;reson:%s", error.toString()), true);
                        }
                    }
                };
        gameRequestDialog = new GameRequestDialog(Cocos2dxActivityWrapper.getContext());
        gameRequestDialog.registerCallback(callbackManager, gameRequestCallback);
        
        FacebookCallback<ShareDialog.Result> shareDialogCallback = 
                new FacebookCallback<ShareDialog.Result>() {

                    @Override
                    public void onSuccess(Result result) {
                        // TODO Auto-generated method stub
                        final String postId = result.getPostId();
                        if (postId != null) {
                            FacebookBridge.callLuaShareFeedResult(postId, true);
                        } else {
                            // User clicked the Cancel button
                            FacebookBridge.callLuaShareFeedResult("canceled", true);
                        }
                    }

                    @Override
                    public void onCancel() {
                        // TODO Auto-generated method stub
                        FacebookBridge.callLuaShareFeedResult("canceled", true);
                    }

                    @Override
                    public void onError(FacebookException error) {
                        // TODO Auto-generated method stub
                        FacebookBridge.callLuaShareFeedResult("failed", true);
                    }
            
        };
        shareDialog = new ShareDialog(Cocos2dxActivityWrapper.getContext());
        shareDialog.registerCallback(callbackManager, shareDialogCallback);
        
        if(savedInstanceState != null) {
            String name = savedInstanceState.getString(PENDING_ACTION_BUNDLE_KEY);
            pendingAction = PendingAction.valueOf(name);
        }
        
        profileTracker = new ProfileTracker() {
            @Override
            protected void onCurrentProfileChanged(Profile oldProfile,
                    Profile currentProfile) {
            }
        };
    }
    
    @Override
    public void onResume(Activity activity) {
        AppEventsLogger.activateApp(activity);
    }
    
    @Override
    public void onSaveInstanceState(Activity activity, Bundle outState) {
        if(outState != null && pendingAction != null) {
            outState.putString(PENDING_ACTION_BUNDLE_KEY, pendingAction.name());
        }
    }
    
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        callbackManager.onActivityResult(requestCode, resultCode, data);
    }
    
    @Override
    public void onPause(Activity activity) {
        AppEventsLogger.deactivateApp(activity);
    }
    
    @Override
    public void onDestroy(Activity activity) {
        profileTracker.stopTracking();
    }
}