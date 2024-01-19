#import <UIKit/UIKit.h>
#import <AMRSDK/AMRSDK.h>
#import <Cordova/CDV.h>

@interface CDVAmr : CDVPlugin <AMRBannerDelegate, AMRInterstitialDelegate, AMRRewardedVideoDelegate>

@property(nonatomic, retain) AMRBanner *banner;
@property(nonatomic, retain) AMRInterstitial *interstitial;
@property(nonatomic, retain) AMRRewardedVideo *rewardedVideo;

@property (assign) BOOL bannerIsAvaliable;
@property (assign) BOOL bannerIsVisible;
@property (assign) BOOL interstitialIsAvaliable;
@property (assign) BOOL rewardedVideoIsAvaliable;

@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSString *bannerZoneId;
@property (nonatomic, retain) NSString *interstitialZoneId;
@property (nonatomic, retain) NSString *videoZoneId;

@property (nonatomic, retain) NSString *userConsent;
@property (nonatomic, retain) NSString *subjectToGdpr;
@property (nonatomic, retain) NSString *subjectToCCPA;

@property (assign) float bannerWidth;
@property (assign) BOOL bannerAtTop;
@property (assign) BOOL offsetTopBar;
@property (assign) BOOL overlap;

@property (assign) BOOL autoShowBanner;
@property (assign) BOOL autoShowInterstitial;
@property (assign) BOOL autoShowVideo;

- (void)AMRSdkConfig:(CDVInvokedUrlCommand*)command;
- (void)startWithConfig:(CDVInvokedUrlCommand*)command;
- (void)setCanRequestAds(CDVInvokedUrlCommand*)command;
- (void)startTestSuite:(CDVInvokedUrlCommand*)command;

- (void)loadBanner:(CDVInvokedUrlCommand*)command;
- (void)hideBanner:(CDVInvokedUrlCommand*)command;
- (void)showBanner:(CDVInvokedUrlCommand*)command;
- (void)destroyBanner:(CDVInvokedUrlCommand*)command;

- (void)loadInterstitial:(CDVInvokedUrlCommand*)command;
- (void)showInterstitial:(CDVInvokedUrlCommand*)command;

- (void)loadRewardedVideo:(CDVInvokedUrlCommand*)command;
- (void)showRewardedVideo:(CDVInvokedUrlCommand*)command;

@end
