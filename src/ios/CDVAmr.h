#import <UIKit/UIKit.h>
#import <AMRSDK/AMRSDK.h>
#import <Cordova/CDV.h>

@interface CDVAmr : CDVPlugin <AMRBannerDelegate, AMRInterstitialDelegate, AMRRewardedVideoDelegate>

@property(nonatomic, retain) AMRBanner *banner;
@property(nonatomic, retain) AMRInterstitial *interstitial;
@property(nonatomic, retain) AMRRewardedVideo *rewardedVideo;

@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSString *bannerZoneId;
@property (nonatomic, retain) NSString *interstitialZoneId;
@property (nonatomic, retain) NSString *videoZoneId;

@property (assign) float bannerWidth;
@property (assign) BOOL bannerAtTop;
@property (assign) BOOL offsetTopBar;
@property (assign) BOOL overlap;

@property (assign) BOOL autoShowBanner;
@property (assign) BOOL autoShowInterstitial;
@property (assign) BOOL autoShowVideo;

@property (assign) BOOL bannerIsAvaliable;
@property (assign) BOOL bannerIsVisible;
@property (assign) BOOL interstitialIsAvaliable;
@property (assign) BOOL rewardedVideoIsAvaliable;


- (void)setOptions:(CDVInvokedUrlCommand*)command;
- (void)initAMR:(CDVInvokedUrlCommand*)command;


- (void)createBannerAd:(CDVInvokedUrlCommand*)command;
- (void)requestBannerAd:(CDVInvokedUrlCommand*)command;
- (void)showBannerAd:(CDVInvokedUrlCommand*)command;
- (void)destroyBannerAd:(CDVInvokedUrlCommand*)command;


- (void)createInterstitialAd:(CDVInvokedUrlCommand*)command;
- (void)requestInterstitialAd:(CDVInvokedUrlCommand*)command;
- (void)showInterstitialAd:(CDVInvokedUrlCommand*)command;


- (void)createVideoAd:(CDVInvokedUrlCommand*)command;
- (void)requestVideoAd:(CDVInvokedUrlCommand*)command;
- (void)showVideoAd:(CDVInvokedUrlCommand*)command;

@end
