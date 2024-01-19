#import "CDVAmr.h"
#import <Cordova/CDV.h>

@implementation CDVAmr
    
-(void)pluginInitialize {
    [super pluginInitialize];
    
    _appId = @"";
    _bannerZoneId = nil;
    _interstitialZoneId = nil;
    _videoZoneId = nil;
    
    _userConsent = nil;
    _canRequestAds = nil;
    _subjectToGdpr = nil;
    _subjectToCCPA = nil;
    
    _bannerWidth = 0;
    _bannerAtTop = NO;
    _offsetTopBar = NO;
    _overlap = NO;
    
    _autoShowBanner = YES;
    _autoShowInterstitial = YES;
    _autoShowVideo = YES;
    
    _bannerIsAvaliable = NO;
    _bannerIsVisible = NO;
    
    _interstitialIsAvaliable = NO;
    _rewardedVideoIsAvaliable = NO;
}
    
- (void)dealloc {
    _banner.delegate = nil;
    _banner = nil;
    
    _interstitial.delegate = nil;
    _interstitial = nil;
    
    _rewardedVideo.delegate = nil;
    _rewardedVideo = nil;
}
    
- (void)AMRSdkConfig:(CDVInvokedUrlCommand*)command {
    NSLog(@"<AMRSDK> setOptions");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
- (void)startWithConfig:(CDVInvokedUrlCommand*)command {
    NSLog(@"<AMRSDK> startWithConfig");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    CDVPluginResult *pluginResult;
    
    if (!_appId || _appId.length == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid app id"];
    } else {
        if (_userConsent != nil) {
            BOOL consent = [_userConsent isEqualToString:@"1"] ? YES:NO;
            [AMRSDK setUserConsent:consent];
        }
        
         if (_canRequestAds != nil) {
            BOOL canRequestAds = [_canRequestAds isEqualToString:@"1"] ? YES:NO;
            [AMRSDK canRequestAds: canRequestAds];
        }

        if (_subjectToGdpr != nil) {
            BOOL gdpr = [_subjectToGdpr isEqualToString:@"1"] ? YES:NO;
            [AMRSDK subjectToGDPR:gdpr];
        }
        
        if (_subjectToCCPA != nil) {
            BOOL ccpa = [_subjectToCCPA isEqualToString:@"1"] ? YES:NO;
            [AMRSDK subjectToCCPA:ccpa];
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [AMRSDK startWithAppId:_appId];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setCanRequestAds:(CDVInvokedUrlCommand*)command {
    NSLog(@"<AMRSDK> setCanRequestAds");
    
    if (command.arguments.count > 0) {
            NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
            [self __setOptions:params.];

        if (_canRequestAds != nil) {
            BOOL canRequestAds = [_canRequestAds isEqualToString:@"1"] ? YES:NO;
            [AMRSDK canRequestAds: canRequestAds];
        }
    }
}
    
- (void)startTestSuite:(CDVInvokedUrlCommand*)command {
    NSLog(@"<AMRSDK> startTestSuite");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    CDVPluginResult *pluginResult;
    
    if (!_appId || _appId.length == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid app id"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [AMRSDK startTestSuiteWithAppId:_appId];
    }
        
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
    
- (void)loadBanner:(CDVInvokedUrlCommand *)command {
    NSLog(@"<AMRSDK> loadBanner");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    if(!_banner) {
        [self _loadBanner];
    } else {
        [_banner loadBanner];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)hideBanner:(CDVInvokedUrlCommand*)command {
    NSLog(@"<AMRSDK> hideBanner");
       
       if(_banner) {
           [_banner.bannerView removeFromSuperview];
           _bannerIsVisible = NO;
           
           [self resizeContent];
       }
       
       CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
       [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
- (void)showBanner:(CDVInvokedUrlCommand *)command {
    NSLog(@"<AMRSDK> showBanner");
    
    BOOL showBanner = YES;
    if (command.arguments.count > 0) {
        NSString* showValue = [command.arguments objectAtIndex:0];
        showBanner = showValue ? [showValue boolValue] : YES;
    }
    
    CDVPluginResult *pluginResult;
    
    if (!self.banner)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"banner is not initiliazed."];
    else if (!_bannerIsAvaliable)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"banner is not ready."];
    else if (_bannerIsVisible && showBanner)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"banner is already visible."];
    else {
        [self _showBanner:showBanner];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
-(void)destroyBanner:(CDVInvokedUrlCommand *)command {
    NSLog(@"<AMRSDK> destroyBanner");
    
    if(_banner) {
        [_banner setDelegate:nil];
        [_banner.bannerView removeFromSuperview];
        _banner = nil;
        _bannerIsVisible = NO;
        
        [self resizeContent];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
- (void)loadInterstitial:(CDVInvokedUrlCommand *)command {
    NSLog(@"<AMRSDK> loadInterstitial");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    if (!_interstitial)
    [self _loadInterstitial];
    else
    [_interstitial loadInterstitial];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
- (void)showInterstitial:(CDVInvokedUrlCommand *)command {
    NSLog(@"<AMRSDK> showInterstitial");
    
    CDVPluginResult *pluginResult;
    
    if (!_interstitial)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"interstitial is not initiliazed."];
    else if (!_interstitialIsAvaliable)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"interstitial is not ready."];
    else {
        [self _showInterstitial];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
-(void)loadRewardedVideo:(CDVInvokedUrlCommand *)command {
    NSLog(@"<AMRSDK> loadRewardedVideo");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    if (!_rewardedVideo)
    [self _loadRewardedVideo];
    else
    [_rewardedVideo loadRewardedVideo];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
-(void)showRewardedVideo:(CDVInvokedUrlCommand *)command {
    NSLog(@"<AMRSDK> showRewardedVideo");
    
    CDVPluginResult *pluginResult;
    
    if (!_rewardedVideo)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"video is not initiliazed."];
    else if (!_rewardedVideoIsAvaliable)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"video is not ready."];
    else {
        [self _showRewardedVideo];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
#pragma mark - Local
    
- (void)_loadBanner {
    NSLog(@"AMR _loadBanner");
    
    _banner = [AMRBanner bannerForZoneId:_bannerZoneId];
    
    if (_bannerWidth != 0)
    _banner.bannerWidth = _bannerWidth;
    
    _banner.delegate = self;
    _bannerIsAvaliable = NO;
    _bannerIsVisible = NO;
    [_banner loadBanner];
}
    
- (void)_showBanner:(BOOL)show {
    NSLog(@"AMR _showBanner");
    
    if (show) {
        if (_bannerIsAvaliable && !_bannerIsVisible) {
            
            UIView* parentView = _overlap ? self.webView : [self.webView superview];
            
            [parentView addSubview:_banner.bannerView];
            [parentView bringSubviewToFront:_banner.bannerView];
            
            _bannerIsVisible = YES;
        }
    } else {
        [_banner.bannerView removeFromSuperview];
        _bannerIsVisible = NO;
    }
    
    [self resizeContent];
}
    
- (void)_loadInterstitial {
    NSLog(@"AMR _loadInterstitial");
    
    _interstitial = [AMRInterstitial interstitialForZoneId:_interstitialZoneId];
    _interstitial.delegate = self;
    [_interstitial loadInterstitial];
}
    
- (void)_showInterstitial {
    NSLog(@"AMR _showInterstitial");
    
    if(_interstitial && _interstitialIsAvaliable) {
        [_interstitial showFromViewController:self.viewController];
    }
}
    
- (void)_loadRewardedVideo {
    NSLog(@"AMR _loadRewardedVideo");
    
    _rewardedVideo = [AMRRewardedVideo rewardedVideoForZoneId:_videoZoneId];
    _rewardedVideo.delegate = self;
    [_rewardedVideo loadRewardedVideo];
}
    
- (void)_showRewardedVideo {
    NSLog(@"AMR _showRewardedVideo");
    
    if(_rewardedVideo && _rewardedVideoIsAvaliable) {
        [_rewardedVideo showFromViewController:self.viewController];
    }
}
    
#pragma mark - AMRBannerDelegate
    
-(void)didReceiveBanner:(AMRBanner *)banner {
    _bannerIsAvaliable = YES;
    _bannerIsVisible = NO;
    
    if (_autoShowBanner)
    [self _showBanner:YES];
    
    [self fireEvent:@"onBannerReady" withData:nil];
}
    
-(void)didFailToReceiveBanner:(AMRBanner *)banner error:(AMRError *)error {
    NSString* jsonData = [NSString stringWithFormat:@"{'error': '%@'}", error.errorDescription];
    
    [self fireEvent:@"onBannerFail" withData:jsonData];
}
    
#pragma mark - AMRInterstitialDelegate
    
-(void)didReceiveInterstitial:(AMRInterstitial *)interstitial {
    _interstitialIsAvaliable = YES;
    
    if (_autoShowInterstitial)
    [self _showInterstitial];
    
    [self fireEvent:@"onInterstitialReady" withData:nil];
}
    
-(void)didFailToReceiveInterstitial:(AMRInterstitial *)interstitial error:(AMRError *)error {
    NSString* jsonData = [NSString stringWithFormat:@"{'error': '%@'}", error.errorDescription];
    
    [self fireEvent:@"onInterstitialFail" withData:jsonData];
}
    
- (void)didShowInterstitial:(AMRInterstitial *)interstitial {
    [self fireEvent:@"onInterstitialShow" withData:nil];
}
    
-(void)didDismissInterstitial:(AMRInterstitial *)interstitial {
    [self fireEvent:@"onInterstitialDismiss" withData:nil];
}

- (void)didInterstitialStateChanged:(AMRInterstitial *)interstitial state:(AMRAdState)state {
    NSString* jsonData = [NSString stringWithFormat:@"{'status': '%@'}", @(state)];
    [self fireEvent:@"onInterstitialStatusChanged" withData:jsonData];
}
    
#pragma mark - AMRRewardedVideoDelegate
    
- (void)didReceiveRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    _rewardedVideoIsAvaliable = YES;
    
    if (_autoShowVideo)
    [self _showRewardedVideo];
    
    [self fireEvent:@"onVideoReady" withData:nil];
}
    
- (void)didFailToReceiveRewardedVideo:(AMRRewardedVideo *)rewardedVideo error:(AMRError *)error {
    NSString* jsonData = [NSString stringWithFormat:@"{'error': '%@'}", error.errorDescription];
    
    [self fireEvent:@"onVideoFail" withData:jsonData];
}
    
- (void)didShowRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    [self fireEvent:@"onVideoShow" withData:nil];
}
    
- (void)didDismissRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    [self fireEvent:@"onVideoDismiss" withData:nil];
}
    
- (void)didCompleteRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    [self fireEvent:@"onVideoComplete" withData:nil];
}

- (void)didRewardedVideoStateChanged:(AMRRewardedVideo *)rewardedVideo state:(AMRAdState)state {
    NSString* jsonData = [NSString stringWithFormat:@"{'status': '%@'}", @(state)];
    [self fireEvent:@"onVideoStatusChanged" withData:jsonData];
}
    
#pragma mark - Util
- (void)fireEvent:(NSString *)eventName withData:(NSString *)jsonData {
    NSString* event;
    
    if(jsonData && [jsonData length]>0)
    event = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@',%@);", eventName, jsonData];
    else
    event = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@');", eventName];
    
    [self.commandDelegate evalJs:event];
    
}
    
- (void)__setOptions:(NSDictionary*) options{
    if ((NSNull *)options == [NSNull null]) return;
    
    NSString* str = nil;
    
    str = [options objectForKey:@"applicationIdIOS"];
    if(str && [str length]>0) _appId = str;
    
    str = [options objectForKey:@"bannerIdIOS"];
    if(str && [str length]>0) _bannerZoneId = str;
    
    str = [options objectForKey:@"interstitialIdIOS"];
    if(str && [str length]>0) _interstitialZoneId = str;
    
    str = [options objectForKey:@"videoIdIOS"];
    if(str && [str length]>0) _videoZoneId = str;
    
    str = [options objectForKey:@"userConsent"];
    if(str && [str length]>0) _userConsent = str;

    str = [options objectForKey:@"canRequestAds"];
    if(str && [str length]>0) _canRequestAds = str;
    
    str = [options objectForKey:@"subjectToGdpr"];
    if(str && [str length]>0) _subjectToGdpr = str;
    
    str = [options objectForKey:@"subjectToCCPA"];
    if(str && [str length]>0) _subjectToCCPA = str;
    
    str = [options objectForKey:@"bannerWidth"];
    if(str) _bannerWidth = [str floatValue];
    
    str = [options objectForKey:@"bannerAtTop"];
    if(str) _bannerAtTop = [str boolValue];
    
    str = [options objectForKey:@"offsetTopBar"];
    if(str) _offsetTopBar = [str boolValue];
    
    str = [options objectForKey:@"overlap"];
    if(str) _overlap = [str boolValue];
    
    str = [options objectForKey:@"autoShowBanner"];
    if(str) _autoShowBanner = [str boolValue];
    
    str = [options objectForKey:@"autoShowInterstitial"];
    if(str) _autoShowInterstitial = [str boolValue];
    
    str = [options objectForKey:@"autoShowVideo"];
    if(str) _autoShowVideo = [str boolValue];
}
    
- (void)resizeContent {
    CGRect pr = self.webView.superview.bounds, wf = pr;
    
    BOOL isIOS7 = ([[UIDevice currentDevice].systemVersion floatValue] >= 7);
    CGRect sf = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat top = isIOS7 ? MIN(sf.size.height, sf.size.width) : 0.0;
    if(! self.offsetTopBar) top = 0.0;
    
    wf.origin.y = top;
    wf.size.height = pr.size.height - top;
    
    if(_banner) {
        CGRect bf = _banner.bannerView.frame;
        if( _bannerIsVisible ) {
            //NSLog( @"banner visible" );
            
            if(_bannerAtTop) {
                if(_overlap) {
                    wf.origin.y = top;
                    bf.origin.y = 0; // banner is subview of webview
                } else {
                    bf.origin.y = top;
                    wf.origin.y = bf.origin.y + bf.size.height;
                }
            } else {
                // move webview to top
                wf.origin.y = top;
                
                if(_overlap) {
                    bf.origin.y = wf.size.height - bf.size.height; // banner is subview of webview
                } else {
                    bf.origin.y = pr.size.height - bf.size.height;
                }
            }
            
            if(!_overlap) wf.size.height -= bf.size.height;
            
            bf.origin.x = (pr.size.width - bf.size.width) * 0.5f;
            _banner.bannerView.frame = bf;
        }
    }
    self.webView.frame = wf;
}
    
@end
