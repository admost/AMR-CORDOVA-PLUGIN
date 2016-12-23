#import "CDVAmr.h"
#import <Cordova/CDV.h>

@implementation CDVAmr

-(void)pluginInitialize {
    [super pluginInitialize];
    
    _appId = @"";
    _bannerZoneId = nil;
    _interstitialZoneId = nil;
    _videoZoneId = nil;
    
    _bannerWidth = 0;
    _bannerAtTop = YES;
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

- (void)setOptions:(CDVInvokedUrlCommand*)command {
    NSLog(@"AMR setOptions");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)initAMR:(CDVInvokedUrlCommand*)command {
    NSLog(@"AMR init");
    
    [AMRSDK startWithAppId:_appId];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    if (!_appId || _appId.length == 0)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid app id"];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)createBannerAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR createBannerAd");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    if(!_banner) {
        [self _createBannerAd];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)requestBannerAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR requestBannerAd");
    
    if (!_banner)
    [self _createBannerAd];
    else
    [_banner loadBanner];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showBannerAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR showBannerAd");
    
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
        [self _showBannerAd:showBanner];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)destroyBannerAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR destroyBannerAd");
    
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

-(void)createInterstitialAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR createInterstitialAd");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    if (!_interstitial)
    [self _createInterstitialAd];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)requestInterstitialAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR requestInterstitialAd");
    
    if (!_interstitial)
    [self _createInterstitialAd];
    else
    [_interstitial loadInterstitial];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showInterstitialAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR showInterstitialAd");
    
    CDVPluginResult *pluginResult;
    
    if (!_interstitial)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"interstitial is not initiliazed."];
    else if (!_interstitialIsAvaliable)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"interstitial is not ready."];
    else {
        [self _showInterstitialAd];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)createVideoAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR createVideoAd");
    
    if (command.arguments.count > 0) {
        NSDictionary* params = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:params];
    }
    
    if (!_rewardedVideo)
    [self _createRewardedVideoAd];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)requestVideoAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR requestVideoAd");
    
    if (!_rewardedVideo)
    [self _createRewardedVideoAd];
    else
    [_rewardedVideo loadRewardedVideo];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)showVideoAd:(CDVInvokedUrlCommand *)command {
    NSLog(@"AMR showVideoAd");
    
    CDVPluginResult *pluginResult;
    
    if (!_rewardedVideo)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"video is not initiliazed."];
    else if (!_rewardedVideoIsAvaliable)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"video is not ready."];
    else {
        [self _showRewardedVideoAd];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Local

- (void)_createBannerAd {
    NSLog(@"AMR _createBannerAd");
    
    if(!_banner) {
        _banner = [AMRBanner bannerForZoneId:_bannerZoneId];
        if (_bannerWidth != 0)
        _banner.bannerWidth = _bannerWidth;
        _banner.delegate = self;
        _bannerIsAvaliable = NO;
        _bannerIsVisible = NO;
        [_banner loadBanner];
    }
}

- (void)_showBannerAd:(BOOL)show {
    NSLog(@"AMR _showBannerAd");
    
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

- (void)_createInterstitialAd {
    NSLog(@"AMR _createInterstitialAd");
    
    if (!_interstitial) {
        _interstitial = [AMRInterstitial interstitialForZoneId:_interstitialZoneId];
        _interstitial.delegate = self;
        [_interstitial loadInterstitial];
    }
}

- (void)_showInterstitialAd {
    NSLog(@"AMR _showInterstitialAd");
    
    if(_interstitial && _interstitialIsAvaliable) {
        [_interstitial showFromViewController:self.viewController];
    }
}

- (void)_createRewardedVideoAd {
    NSLog(@"AMR _createRewardedVideoAd");
    
    if (!_rewardedVideo) {
        _rewardedVideo = [AMRRewardedVideo rewardedVideoForZoneId:_videoZoneId];
        _rewardedVideo.delegate = self;
        [_rewardedVideo loadRewardedVideo];
    }
}

- (void)_showRewardedVideoAd {
    NSLog(@"AMR _showRewardedVideoAd");
    
    if(_rewardedVideo && _rewardedVideoIsAvaliable) {
        [_rewardedVideo showFromViewController:self.viewController];
    }
}

#pragma mark - AMRBannerDelegate

-(void)didReceiveBanner:(AMRBanner *)banner {
    _bannerIsAvaliable = YES;
    
    if (_autoShowBanner)
    [self _showBannerAd:YES];
    
    [self fireEvent:@"onReceiveBannerAd" withData:nil];
}

-(void)didFailToReceiveBanner:(AMRBanner *)banner error:(AMRError *)error {
    NSString* jsonData = [NSString stringWithFormat:@"{'error': '%@'}", error.errorDescription];
    
    [self fireEvent:@"onFailedToReceiveBannerAd" withData:jsonData];
}

#pragma mark - AMRInterstitialDelegate

-(void)didReceiveInterstitial:(AMRInterstitial *)interstitial {
    _interstitialIsAvaliable = YES;
    
    if (_autoShowInterstitial)
    [self _showInterstitialAd];
    
    [self fireEvent:@"onReceiveInterstitialAd" withData:nil];
}

-(void)didFailToReceiveInterstitial:(AMRInterstitial *)interstitial error:(AMRError *)error {
    NSString* jsonData = [NSString stringWithFormat:@"{'error': '%@'}", error.errorDescription];
    
    [self fireEvent:@"onFailedToReceiveInterstitialAd" withData:jsonData];
}

-(void)didDismissInterstitial:(AMRInterstitial *)interstitial {
    [self fireEvent:@"onDismissInterstitialAd" withData:nil];
}

#pragma mark - AMRRewardedVideoDelegate

- (void)didReceiveRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    _rewardedVideoIsAvaliable = YES;
    
    if (_autoShowVideo)
    [self _showRewardedVideoAd];
    
    [self fireEvent:@"onReceiveVideoAd" withData:nil];
}

- (void)didFailToReceiveRewardedVideo:(AMRRewardedVideo *)rewardedVideo error:(AMRError *)error {
    NSString* jsonData = [NSString stringWithFormat:@"{'error': '%@'}", error.errorDescription];
    
    [self fireEvent:@"onFailedToReceiveVideoAd" withData:jsonData];
}

- (void)didDismissRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    [self fireEvent:@"onDismissVideoAd" withData:nil];
}

- (void)didCancelRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    [self fireEvent:@"onSkipVideoAd" withData:nil];
}

- (void)didCompleteRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    [self fireEvent:@"onCompleteVideoAd" withData:nil];
}

- (void)didRewardUser:(NSNumber *)rewardAmount forRewardedVideo:(AMRRewardedVideo *)rewardedVideo {
    NSString* jsonData = [NSString stringWithFormat:@"{'amount': '%@'}", rewardAmount];
    
    [self fireEvent:@"onRewardedVideoAd" withData:jsonData];
}

#pragma mark - Util
- (void) fireEvent:(NSString *)eventName withData:(NSString *)jsonData {
    NSString* event;
    
    if(jsonData && [jsonData length]>0)
    event = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@',%@);", eventName, jsonData];
    else
    event = [NSString stringWithFormat:@"javascript:cordova.fireDocumentEvent('%@');", eventName];
    
    [self.commandDelegate evalJs:event];
    
}

- (void) __setOptions:(NSDictionary*) options{
    if ((NSNull *)options == [NSNull null]) return;
    
    NSString* str = nil;
    
    str = [options objectForKey:@"amrAppId"];
    if(str && [str length]>0) _appId = str;
    
    str = [options objectForKey:@"amrBannerZoneId"];
    if(str && [str length]>0) _bannerZoneId = str;
    
    str = [options objectForKey:@"amrInterstitialZoneId"];
    if(str && [str length]>0) _interstitialZoneId = str;
    
    str = [options objectForKey:@"amrVideoZoneId"];
    if(str && [str length]>0) _videoZoneId = str;
    
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
