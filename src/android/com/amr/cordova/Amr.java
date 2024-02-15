package com.amr.cordova;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

import org.apache.cordova.*;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;

import admost.sdk.AdMostInterstitial;
import admost.sdk.AdMostManager;
import admost.sdk.AdMostView;
import admost.sdk.base.AdMost;
import admost.sdk.base.AdMostAdNetwork;
import admost.sdk.base.AdMostConfiguration;
import admost.sdk.listener.AdMostAdListener;
import admost.sdk.listener.AdMostInitListener;
import admost.sdk.listener.AdMostViewListener;
import com.amr.plugin.cordova.AmrAdActivity;

public class Amr extends CordovaPlugin {
    /**
     * Common tag used for logging statements.
     */
    private static final String LOGTAG = "AmrCordova";
    private static final boolean CORDOVA_MIN_4 = Integer.valueOf(CordovaWebView.CORDOVA_VERSION.split("\\.")[0]) >= 4;
    public static final int LAUNCH_AD_ACTIVITY = 2020;
    /**
     * Cordova Actions.
     */
    private static final String ACTION_SET_CONFIG = "AMRSdkConfig";
    private static final String ACTION_START_WITH_CONFIG = "startWithConfig";
    private static final String ACTION_START_TEST_SUITE = "startTestSuite";
    private static final String ACTION_SET_CAN_REQUEST_ADS = "setCanRequestAds";
    private static final String ACTION_LOAD_BANNER = "loadBanner";
    private static final String ACTION_HIDE_BANNER = "hideBanner";
    private static final String ACTION_DESTROY_BANNER = "destroyBanner";

    private static final String ACTION_LOAD_INTERSTITIAL = "loadInterstitial";
    private static final String ACTION_SHOW_INTERSTITIAL = "showInterstitial";
    private static final String ACTION_DESTROY_INTERSTITIAL = "destroyInterstitial";
    private static final String ACTION_LOAD_AND_SHOW_INTERSTITIAL = "loadAndShowInterstitial";

    private static final String ACTION_LOAD_REWARDED_VIDEO = "loadRewardedVideo";
    private static final String ACTION_SHOW_REWARDED_VIDEO = "showRewardedVideo";
    private static final String ACTION_DESTROY_REWARDED_VIDEO = "destroyRewardedVideo";
    private static final String ACTION_LOAD_AND_SHOW_REWARDED_VIDEO = "loadAndShowRewardedVideo";

    private static final String ACTION_TRACK_PURCHASE_FOR_ANDROID = "trackPurchaseForAndroid";
    private static final String ACTION_IS_PRIVACY_CONSENT_REQUIRED = "isPrivacyConsentRequired";

    /**
     * config
     **/
    private static final String OPT_AMR_APP_ID = "applicationIdAndroid";
    private static final String OPT_INTERSTITIAL_ZONE_ID = "interstitialIdAndroid";
    private static final String OPT_BANNER_ZONE_ID = "bannerIdAndroid";
    private static final String OPT_VIDEO_ZONE_ID = "videoIdAndroid";
    private static final String OPT_AD_SIZE = "adSize";
    private static final String OPT_BANNER_AT_TOP = "bannerAtTop";
    private static final String OPT_OVERLAP = "overlap";
    private static final String OPT_OFFSET_TOPBAR = "offsetTopBar";
    private static final String OPT_AUTO_SHOW_INTERSTITIAL = "autoShowInterstitial";
    private static final String OPT_AUTO_SHOW_VIDEO = "autoShowVideo";
    private static final String OPT_SUBJECT_TO_GDPR = "subjectToGdpr";
    private static final String OPT_CONSENT = "userConsent";
    private static final String OPT_CAN_REQUEST_ADS = "canRequestAds";
    private static final String OPT_AUTO_SHOW_BANNER = "autoShowBanner";


    /**
     * gdpr
     **/
    private String subjectToGdpr = "-1";
    private String consent = "-1";
    private String canRequestAds = "-1";
    private String subjectToCCPA = "-1";
    private static String isPrivacyConsentRequired = "isPrivacyConsentRequired";
   /* OPT_SUBJECT_TO_GDPR
    OPT_CONSENT
*/
    /**
     * Interstitial Responses
     **/
    private static String onInterstitialDismiss = "onInterstitialDismiss";
    private static String onInterstitialReady = "onInterstitialReady";
    private static String onInterstitialFail = "onInterstitialFail";
    private static String onInterstitialShow = "onInterstitialShow";
    private static String onInterstitialStatusChanged = "onInterstitialStatusChanged";

    /**
     * Video Responses
     **/
    private static String onVideoDismiss = "onVideoDismiss";
    private static String onVideoReady = "onVideoReady";
    private static String onVideoFail = "onVideoFail";
    private static String onVideoShow = "onVideoShow";
    private static String onVideoComplete = "onVideoComplete";
    private static String onVideoStatusChanged = "onVideoStatusChanged";

    /**
     * Banner Responses
     **/
    private static String onBannerShown = "onBannerShow";
    private static String onBannerHide = "onBannerHide";
    private static String onBannerFail = "onBannerFail";
    private static String onBannerReady = "onBannerReady";
    private static String onBannerLoad = "onBannerLoad";

    private static String isPrivacyConsentRequired = "isPrivacyConsentRequired";

    private ViewGroup parentView;

    /**
     * The adView to display to the user.
     */
    private AdMostView adView;
    /**
     * if want banner view overlap webview, we will need this layout
     */
    private RelativeLayout adViewLayout = null;

    /**
     * The interstitial ad to display to the user.
     */
    private AdMostInterstitial interstitialAd;
    private AdMostInterstitial videoAd;

    private String productReceipt = "";
    private String productLocalizedPrice = "";
    private String productIsoCurrencyCode = "";
    private String amrAppId = "";
    private String amrInterstitialZoneId = "";
    private String amrBannerZoneId = "";
    private String amrVideoZoneId = "";
    private int adSize = AdMostManager.getInstance().AD_BANNER;


    /**
     * Whether or not the ad should be positioned at top or bottom of screen.
     */
    private boolean bannerAtTop = false;
    /**
     * Whether or not the banner will overlap the webview instead of push it up or down
     */
    private boolean bannerOverlap = false;
    private boolean offsetTopBar = false;
    private boolean bannerShow = true;
    private boolean autoShow = true;

    private boolean autoShowInterstitial = true;
    private boolean autoShowInterstitialTemp = false;        //if people call it when it's not ready
    private boolean autoShowVideo = true;
    private boolean autoShowVideoTemp = false;                //if people call it when it's not ready

    private boolean bannerVisible = false;
    private boolean isGpsAvailable = false;

    SharedPreferences settings;
    SharedPreferences.Editor editor;

    private volatile static Amr instance;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        settings = PreferenceManager.getDefaultSharedPreferences(this.cordova.getActivity().getApplicationContext());
        editor = settings.edit();

        isGpsAvailable = (GooglePlayServicesUtil.isGooglePlayServicesAvailable(cordova.getActivity()) == ConnectionResult.SUCCESS);
        Log.w(LOGTAG, String.format("isGooglePlayServicesAvailable: %s", isGpsAvailable ? "true" : "false"));
    }

    @Override
    public boolean execute(String action, JSONArray inputs, CallbackContext callbackContext) throws JSONException {
        PluginResult result = null;

        if (ACTION_SET_CONFIG.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeAMRSdkConfig(config, callbackContext);
        } else if (ACTION_START_WITH_CONFIG.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeStartWithConfig(config, callbackContext);

        } else if (ACTION_START_TEST_SUITE.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeTestSuite(config, callbackContext);

        } else if (ACTION_SET_CAN_REQUEST_ADS.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeSetCanRequestAds(config, callbackContext);

        } else if (ACTION_LOAD_INTERSTITIAL.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeLoadInterstitial(config, callbackContext);

        } else if (ACTION_SHOW_INTERSTITIAL.equals(action)) {
            result = executeShowInterstitial(callbackContext);

        } else if (ACTION_DESTROY_INTERSTITIAL.equals(action)) {
            result = executeDestroyInterstitial(callbackContext);

        } else if (ACTION_LOAD_REWARDED_VIDEO.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeLoadRewardedVideo(config, callbackContext);

        } else if (ACTION_SHOW_REWARDED_VIDEO.equals(action)) {
            result = executeShowRewardedVideo(callbackContext);

        } else if (ACTION_DESTROY_REWARDED_VIDEO.equals(action)) {
            result = executeDestroyRewardedVideo(callbackContext);


        } else if (ACTION_LOAD_BANNER.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeLoadBanner(config, callbackContext);

        } else if (ACTION_HIDE_BANNER.equals(action)) {
            result = executeHideBanner(callbackContext);

        } else if (ACTION_DESTROY_BANNER.equals(action)) {

            result = executeDestroyBanner(callbackContext);
        } else if (ACTION_LOAD_AND_SHOW_REWARDED_VIDEO.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeShowRewardedVideoWithActivity(config, callbackContext);
        } else if (ACTION_LOAD_AND_SHOW_INTERSTITIAL.equals(action)) {
            JSONObject config = inputs.optJSONObject(0);
            result = executeShowInterstitialWithActivity(config, callbackContext);
        }else if (ACTION_IS_PRIVACY_CONSENT_REQUIRED.equals(action)) {
                result = executeIsPrivacyConsentRequired();
        } else if (ACTION_GET_REMOTE_CONFIG_STRING.equals(action)) {
            AdMostLog.e("remote action");
            JSONObject config = inputs.optJSONObject(0);
            result = executeGetRemoteConfigString(config, callbackContext);
        } else if(ACTION_TRACK_PURCHASE_FOR_ANDROID.equals(action)){
            JSONObject config = inputs.optJSONObject(0);
            result = executeTrackPurchaseForAndroid(config, callbackContext);
        } else {
            Log.d(LOGTAG, String.format("Invalid action passed: %s", action));
            result = new PluginResult(Status.INVALID_ACTION);
        }

        if (result != null) callbackContext.sendPluginResult(result);

        return true;
    }

    private PluginResult executeAMRSdkConfig(JSONObject config, CallbackContext callbackContext) {
        Log.w(LOGTAG, "executeAMRSdkConfig");

        this.AMRSdkConfig(config);

        callbackContext.success();
        return null;
    }


    private void AMRSdkConfig(JSONObject config) {
        if (config == null) return;

        if (config.has(OPT_AMR_APP_ID)) this.amrAppId = config.optString(OPT_AMR_APP_ID);
        if (config.has(OPT_INTERSTITIAL_ZONE_ID))
            this.amrInterstitialZoneId = config.optString(OPT_INTERSTITIAL_ZONE_ID);
        if (config.has(OPT_BANNER_ZONE_ID))
            this.amrBannerZoneId = config.optString(OPT_BANNER_ZONE_ID);
        if (config.has(OPT_VIDEO_ZONE_ID))
            this.amrVideoZoneId = config.optString(OPT_VIDEO_ZONE_ID);
        if (config.has(OPT_AD_SIZE)) this.adSize = config.optInt(OPT_AD_SIZE);

        if (config.has(OPT_CONSENT)) this.consent = config.optString(OPT_CONSENT);
        if (config.has(OPT_CAN_REQUEST_ADS)) this.canRequestAds = config.optString(OPT_CAN_REQUEST_ADS);
        if (config.has(OPT_SUBJECT_TO_GDPR))
            this.subjectToGdpr = config.optString(OPT_SUBJECT_TO_GDPR);

        if (config.has(OPT_BANNER_AT_TOP)) this.bannerAtTop = config.optBoolean(OPT_BANNER_AT_TOP);
        if (config.has(OPT_OVERLAP)) this.bannerOverlap = config.optBoolean(OPT_OVERLAP);
        if (config.has(OPT_OFFSET_TOPBAR)) this.offsetTopBar = config.optBoolean(OPT_OFFSET_TOPBAR);
        if (config.has(OPT_AUTO_SHOW_INTERSTITIAL))
            this.autoShowInterstitial = config.optBoolean(OPT_AUTO_SHOW_INTERSTITIAL);
        if (config.has(OPT_AUTO_SHOW_VIDEO))
            this.autoShowVideo = config.optBoolean(OPT_AUTO_SHOW_VIDEO);
    }

    private PluginResult executeStartWithConfig(JSONObject config, final CallbackContext callbackContext) {

        this.AMRSdkConfig(config);

        if (this.amrAppId.length() < 5) {
            Log.e(LOGTAG, "Please set applicationIdAndroid parameter.");
            return null;
        }
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {

                initAmr(cordova.getActivity(), consent, subjectToGdpr, subjectToCCPA, amrAppId, canRequestAds);
                callbackContext.success();
            }
        });
        return null;
    }


    static void initAmr(Activity activity, String consent, String subjectToGdpr, String subjectToCCPA, String appId, String canRequestAds) {
        if (!AdMost.getInstance().isInitStarted()) {
            AdMostConfiguration.Builder configuration = new AdMostConfiguration.Builder(activity, appId);
            if (!consent.equals("-1"))
                configuration.setUserConsent(consent.equals("1"));

            if (!subjectToGdpr.equals("-1"))
                configuration.setSubjectToGDPR(subjectToGdpr.equals("1"));
            if (!subjectToCCPA.equals("-1"))
                configuration.setSubjectToCCPA(subjectToCCPA.equals("1"));
            if (!canRequestAds.equals("-1"))
                configuration.canRequestAds(canRequestAds.equals("1"));

            Log.i(LOGTAG, "AdMost Init Called");
            AdMost.getInstance().init(configuration.build(), new AdMostInitListener() {
                @Override
                public void onInitCompleted() {
                    Log.i(LOGTAG, "AdMost onInitCompleted");
                }

                @Override
                public void onInitFailed(int i) {
                    Log.w(LOGTAG, "AdMost onInitFailed");
                }
            });

        }
    }

    private PluginResult executeGetRemoteConfigString(JSONObject config, final CallbackContext callbackContext) {
        String key = "";
        String defValue = "";
        if (config.has("key")) key = config.optString("key");
        if (config.has("value")) defValue = config.optString("value");
        String value = AdMostRemoteConfig.getInstance().getString(key,defValue);
        AdMostLog.e("VALUE:" + value);
        PluginResult result = new PluginResult(Status.OK, value);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
        return result;
    }


    private PluginResult executeLoadBanner(JSONObject config, final CallbackContext callbackContext) {

        this.AMRSdkConfig(config);

        if (this.amrBannerZoneId.length() < 5) {
            Log.e(LOGTAG, "Please set bannerIdAndroid parameter.");
            return null;
        }

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {


                adView = new AdMostView(cordova.getActivity(), Amr.this.amrBannerZoneId, adSize, new AdMostViewListener() {
                    @Override
                    public void onReady(String network, int ecpm, View adView) {
                        sendResponseToListener(onBannerReady, null);

                    }

                    @Override
                    public void onFail(int errorCode) {
                        sendResponseToListener(onBannerFail, String.format("{ 'error': %d }", errorCode));
                    }

                    @Override
                    public void onClick(String network) {

                    }

                }, null);

                adView.load();
                executeShowBanner(true, null);

                callbackContext.success();
            }
        });

        return null;
    }

    private PluginResult executeIsPrivacyConsentRequired(){
        AdMost.getInstance().setPrivacyConsentListener(Layout.this, new AdMost.PrivacyConsentListener() {
            @Override
            public void isPrivacyConsentRequired(String status) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        sendResponseToListener(isPrivacyConsentRequired, String.format("{status: '%s'}", status));
                    }
                });
            }
        });

        return null;
    }

    private PluginResult executeTestSuite(JSONObject config, final CallbackContext callbackContext) {

        this.AMRSdkConfig(config);

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AdMost.getInstance().startTestSuite();
            }

        });

        return null;
    }

    private PluginResult executeSetCanRequestAds(JSONObject config, final CallbackContext callbackContext) {
        this.AMRSdkConfig(config);

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AdMost.getInstance().setCanRequestAds(Amr.this.canRequestAds.equals("1"));
            }

        });

        return null;
    }

    private PluginResult executeDestroyBanner(final CallbackContext callbackContext) {
        Log.w(LOGTAG, "executeDestroyBanner");
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (adView != null) {
                    ViewGroup parentView = (ViewGroup) adView.getView().getParent();
                    if (parentView != null) {
                        parentView.removeView(adView.getView());
                    }
                    adView.destroy();
                    adView = null;
                }
                bannerVisible = false;
                if (callbackContext != null)
                    callbackContext.success();
            }
        });

        return null;
    }


    private PluginResult executeLoadInterstitial(final JSONObject config, final CallbackContext callbackContext) {
        this.AMRSdkConfig(config);

        if (this.amrInterstitialZoneId.length() < 5) {
            Log.e(LOGTAG, "Please set interstitialIdAndroid parameter.");
            return null;
        }
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.w(LOGTAG, "interstitial ad started : " + Amr.this.amrInterstitialZoneId);
                interstitialAd = new AdMostInterstitial(cordova.getActivity(), Amr.this.amrInterstitialZoneId, new AdMostAdListener() {
                    @Override
                    public void onDismiss(String message) {
                        sendResponseToListener(onInterstitialDismiss, null);
                        interstitialAd.destroy();
                    }

                    @Override
                    public void onFail(int errorCode) {
                        sendResponseToListener(onInterstitialFail, String.format("{ 'error': %d }", errorCode));

                    }

                    @Override
                    public void onReady(String network, int ecpm) {
                        sendResponseToListener(onInterstitialReady, null);
                        if (autoShowInterstitial == true) {
                            executeShowInterstitial(callbackContext);
                        }
                    }

                    @Override
                    public void onShown(String network) {
                        sendResponseToListener(onInterstitialShow, null);
                    }

                    @Override
                    public void onClicked(String s) {


                    }

                    @Override
                    public void onComplete(String s) {

                    }

                    @Override
                    public void onStatusChanged(int status) {
                        sendResponseToListener(onInterstitialStatusChanged, String.format("{ 'status': %d }", status));
                    }

                });
            }
        });
        executeRequestInterstitial(config, callbackContext);


        return null;
    }

    private PluginResult executeLoadRewardedVideo(final JSONObject config, final CallbackContext callbackContext) {
        this.AMRSdkConfig(config);

        if (this.amrVideoZoneId.length() < 5) {
            Log.e(LOGTAG, "Please set videoIdAndroid parameter.");
            return null;
        }
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.w(LOGTAG, "Video ad started : " + Amr.this.amrVideoZoneId);
                videoAd = new AdMostInterstitial(cordova.getActivity(), Amr.this.amrVideoZoneId, new AdMostAdListener() {
                    @Override
                    public void onReady(String network, int ecpm) {
                        sendResponseToListener(onVideoReady, null);
                        if (autoShowVideo == true) {
                            executeShowRewardedVideo(null, callbackContext);
                        }
                    }

                    @Override
                    public void onFail(int errorCode) {
                        sendResponseToListener(onVideoFail, String.format("{ 'error': %d }", errorCode));
                    }

                    @Override
                    public void onDismiss(String message) {
                        sendResponseToListener(onVideoDismiss, null);
                        videoAd.destroy();
                    }

                    @Override
                    public void onComplete(String network) {
                        sendResponseToListener(onVideoComplete, null);
                    }

                    @Override
                    public void onShown(String network) {
                        sendResponseToListener(onVideoShow, null);
                    }

                    @Override
                    public void onClicked(String s) {
                        //Ad Clicked
                    }

                    @Override
                    public void onStatusChanged(int status) {
                        sendResponseToListener(onVideoStatusChanged, String.format("{ 'status': %d }", status));
                    }
                });

                executeRequestVideoAd(config, callbackContext);
                callbackContext.success();

            }
        });
        return null;
    }

    private PluginResult executeShowRewardedVideoWithActivity(final JSONObject config, final CallbackContext callbackContext) {
        this.AMRSdkConfig(config);
        if (this.amrVideoZoneId.length() < 5) {
            Log.e(LOGTAG, "Please set videoIdAndroid parameter.");
            return null;
        }
        cordova.setActivityResultCallback(this);

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Activity activity = cordova.getActivity();
                if (activity == null)
                    return;
                Intent i = new Intent(activity, AmrAdActivity.class);
                i.putExtra("ZONE_ID", amrVideoZoneId);
                i.putExtra("IS_REWARDED", true);
                i.putExtra("APP_ID", amrAppId);
                i.putExtra("CONSENT", consent);
                i.putExtra("CAN_REQUEST_ADS", canRequestAds);
                i.putExtra("SUBJECT_TO_GDPR", subjectToGdpr);
                //i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); // do not use this
                cordova.startActivityForResult((CordovaPlugin) Amr.this, i, LAUNCH_AD_ACTIVITY);
                callbackContext.success();
            }
        });
        return null;
    }

    private PluginResult executeShowInterstitialWithActivity(final JSONObject config, final CallbackContext callbackContext) {
        this.AMRSdkConfig(config);

        if (this.amrInterstitialZoneId.length() < 5) {
            Log.e(LOGTAG, "Please set videoIdAndroid parameter.");
            return null;
        }
        cordova.setActivityResultCallback(this);
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Activity activity = cordova.getActivity();
                if (activity == null)
                    return;
                Intent i = new Intent(activity, AmrAdActivity.class);
                i.putExtra("ZONE_ID", Amr.this.amrInterstitialZoneId);
                i.putExtra("IS_REWARDED", false);
                i.putExtra("APP_ID", amrAppId);
                i.putExtra("CONSENT", consent);
                i.putExtra("CAN_REQUEST_ADS", canRequestAds);
                i.putExtra("SUBJECT_TO_GDPR", subjectToGdpr);
                //i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK); // do not use this
                activity.startActivityForResult(i, LAUNCH_AD_ACTIVITY);
                callbackContext.success();
            }
        });
        return null;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode != LAUNCH_AD_ACTIVITY || resultCode != Activity.RESULT_OK || intent == null)
            return;
        Log.d(LOGTAG, "onActivityResult: " + (intent == null ? "" : intent.getIntExtra("RESULT", -1)));
        if (intent.getIntExtra("RESULT", -1) == AmrAdActivity.COMPLETED) {
            sendResponseToListener(onVideoComplete, null);
            sendResponseToListener(onVideoDismiss, null);
        } else if (intent.getIntExtra("RESULT", -1) == AmrAdActivity.DISMISS) {
            if (intent.getBooleanExtra("IS_REWARDED", false)) {
                sendResponseToListener(onVideoDismiss, null);
            } else {
                sendResponseToListener(onInterstitialDismiss, null);
            }

        } else if (intent.getIntExtra("RESULT", -1) == AmrAdActivity.ON_FAIL) {
            if (intent.getBooleanExtra("IS_REWARDED", false)) {
                sendResponseToListener(onVideoFail, null);
            } else {
                sendResponseToListener(onInterstitialFail, null);
            }
        }
    }

    private PluginResult executeRequestAd(JSONObject config, final CallbackContext callbackContext) {
        this.AMRSdkConfig(config);

        if (adView == null) {
            callbackContext.error("adView is null, call loadBanner first");
            return null;
        }

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                adView.getView();
                callbackContext.success();
            }
        });

        return null;
    }

    private PluginResult executeRequestInterstitial(JSONObject config, final CallbackContext callbackContext) {
        this.AMRSdkConfig(config);

        if (interstitialAd == null) {
            callbackContext.error("interstitialAd is null, call createInterstitialView first");
            return null;
        }

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                interstitialAd.refreshAd(false);
                callbackContext.success();
            }
        });

        return null;
    }

    private PluginResult executeRequestVideoAd(JSONObject config, final CallbackContext callbackContext) {
        this.AMRSdkConfig(config);

        if (videoAd == null) {
            callbackContext.error("videoAd is null, call createVideoAd first");
            return null;
        }

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                videoAd.refreshAd(false);
                callbackContext.success();
            }
        });

        return null;
    }

    private PluginResult executeShowBanner(boolean showAd, final CallbackContext callbackContext) {

        if (adView == null) {
            return new PluginResult(Status.ERROR, "adView is null, call createBannerView first.");
        }

        bannerShow = showAd;

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(adView == null || adView.getView() == null){
                    return new PluginResult(Status.ERROR, "adView is null, call createBannerView first.");
                }
                if (bannerVisible == bannerShow) { // no change

                } else if (bannerShow) {
                    if (adView.getView().getParent() != null) {
                        ((ViewGroup) adView.getView().getParent()).removeView(adView.getView());
                    }
                    if (bannerOverlap) {
                        RelativeLayout.LayoutParams params2 = new RelativeLayout.LayoutParams(
                                RelativeLayout.LayoutParams.MATCH_PARENT,
                                RelativeLayout.LayoutParams.WRAP_CONTENT);
                        params2.addRule(bannerAtTop ? RelativeLayout.ALIGN_PARENT_TOP : RelativeLayout.ALIGN_PARENT_BOTTOM);

                        if (adViewLayout == null) {
                            adViewLayout = new RelativeLayout(cordova.getActivity());
                            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
                            try {
                                ((ViewGroup) (((View) webView.getClass().getMethod("getView").invoke(webView)).getParent())).addView(adViewLayout, params);
                            } catch (Exception e) {
                                ((ViewGroup) webView).addView(adViewLayout, params);
                            }
                        }

                        adViewLayout.addView(adView.getView(), params2);
                        adViewLayout.bringToFront();
                    } else {
                        if (CORDOVA_MIN_4) {
                            ViewGroup wvParentView = (ViewGroup) getWebView().getParent();
                            if (parentView == null) {
                                parentView = new LinearLayout(webView.getContext());
                            }
                            if (wvParentView != null && wvParentView != parentView) {
                                wvParentView.removeView(getWebView());
                                ((LinearLayout) parentView).setOrientation(LinearLayout.VERTICAL);
                                parentView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, 0.0F));
                                getWebView().setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, 1.0F));
                                parentView.addView(getWebView());
                                cordova.getActivity().setContentView(parentView);
                            }

                        } else {
                            parentView = (ViewGroup) ((ViewGroup) webView).getParent();
                        }

                        if (bannerAtTop) {
                            parentView.addView(adView.getView(), 0);
                        } else {
                            parentView.addView(adView.getView());
                        }
                        parentView.bringToFront();
                        parentView.requestLayout();
                    }

                    adView.getView().setVisibility(View.VISIBLE);
                    bannerVisible = true;
                    if (bannerShow == true) {
                        sendResponseToListener(onBannerShown, null);
                    } else {
                        sendResponseToListener(onBannerHide, null);

                    }


                } else {
                    adView.getView().setVisibility(View.GONE);
                    bannerVisible = false;
                }

                if (callbackContext != null) callbackContext.success();
            }
        });

        return null;
    }


    private PluginResult executeHideBanner(final CallbackContext callbackContext) {

        executeShowBanner(false, null);
        return null;
    }

    private PluginResult executeShowInterstitial(final CallbackContext callbackContext) {


        if (interstitialAd == null) {
            return new PluginResult(Status.ERROR, "interstitialAd is null, call createInterstitialView first.");
        }

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {

                if (interstitialAd.isLoaded()) {
                    Log.v(LOGTAG, "Interstital is loaded");
                    interstitialAd.show();
                } else {
                    Log.e(LOGTAG, "Interstital not ready yet, temporarily setting autoshow.");
                    autoShowInterstitialTemp = true;
                }

                if (callbackContext != null) callbackContext.success();
            }
        });

        return null;
    }

    private PluginResult executeDestroyRewardedVideo(final CallbackContext callbackContext) {

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (videoAd != null) {
                    videoAd.destroy();
                }

            }
        });

        return null;
    }

    private PluginResult executeDestroyInterstitial(final CallbackContext callbackContext) {

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (interstitialAd != null) {

                    interstitialAd.destroy();
                }

            }
        });

        return null;
    }


    private PluginResult executeShowRewardedVideo(String tag, final CallbackContext callbackContext) {
        Log.v(LOGTAG, "Show Video Ad");
        Log.v(LOGTAG, tag);
        if (videoAd == null) {
            return new PluginResult(Status.ERROR, "VideoAd is null, call createVideoView first.");
        }

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {

                if (videoAd.isLoaded()) {
                    videoAd.show(tag);
                } else {
                    Log.e(LOGTAG, "VideoAd is not ready yet, temporarily setting autoshow.");
                    autoShowVideoTemp = true;
                }

                if (callbackContext != null) callbackContext.success();
            }
        });

        return null;
    }

    @Override
    public void onPause(boolean multitasking) {
        if (adView != null) {
            adView.pause();
        }
        if (AdMost.getInstance().isInitStarted())
            AdMost.getInstance().onPause(cordova.getActivity());
        super.onPause(multitasking);
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        isGpsAvailable = (GooglePlayServicesUtil.isGooglePlayServicesAvailable(cordova.getActivity()) == ConnectionResult.SUCCESS);
        if (AdMost.getInstance().isInitStarted())
            AdMost.getInstance().onResume(cordova.getActivity());
        if (adView != null) {
            adView.resume();
        }
    }

    @Override
    public void onDestroy() {
        if (adView != null) {
            adView.destroy();
            adView = null;
        }
        if (adViewLayout != null) {
            ViewGroup parentView = (ViewGroup) adViewLayout.getParent();
            if (parentView != null) {
                parentView.removeView(adViewLayout);
            }
            adViewLayout = null;
        }
        if (interstitialAd != null) {
            interstitialAd.destroy();
        }
        if (videoAd != null) {
            videoAd.destroy();
        }
        if (AdMost.getInstance().isInitStarted())
            AdMost.getInstance().onDestroy(cordova.getActivity());
        super.onDestroy();
    }

    private View getWebView() {
        try {
            return (View) webView.getClass().getMethod("getView").invoke(webView);
        } catch (Exception e) {
            return (View) webView;
        }
    }

    private void sendResponseToListener(String event, String extra) {
        Log.i(LOGTAG, event);
        if (webView != null && webView.isInitialized())
            webView.loadUrl("javascript:cordova.fireDocumentEvent('" + event + "'" + (extra == null ? "" : "," + extra) + ");");
    }

}
