#import "ABI15_0_0EXInterstitialAdManager.h"
#import "ABI15_0_0EXUnversioned.h"

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <ReactABI15_0_0/ABI15_0_0RCTUtils.h>

@interface ABI15_0_0EXInterstitialAdManager () <FBInterstitialAdDelegate>

@property (nonatomic, strong) ABI15_0_0RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) ABI15_0_0RCTPromiseRejectBlock reject;
@property (nonatomic, strong) FBInterstitialAd *interstitialAd;
@property (nonatomic, strong) UIViewController *adViewController;
@property (nonatomic) bool didClick;
@property (nonatomic) bool isBackground;

@end

@implementation ABI15_0_0EXInterstitialAdManager

@synthesize bridge = _bridge;

ABI15_0_0RCT_EXPORT_MODULE(CTKInterstitialAdManager)

- (void)setBridge:(ABI15_0_0RCTBridge *)bridge
{
  _bridge = bridge;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidForeground:)
                                               name:@"EXKernelBridgeDidForegroundNotification"
                                             object:self.bridge];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidBackground:)
                                               name:@"EXKernelBridgeDidBackgroundNotification"
                                             object:self.bridge];
}

ABI15_0_0RCT_EXPORT_METHOD(
  showAd:(NSString *)placementId
  resolver:(ABI15_0_0RCTPromiseResolveBlock)resolve
  rejecter:(ABI15_0_0RCTPromiseRejectBlock)reject
)
{
  ABI15_0_0RCTAssert(_resolve == nil && _reject == nil, @"Only one `showAd` can be called at once");
  ABI15_0_0RCTAssert(_isBackground == false, @"`showAd` can be called only when experience is running in foreground");
  
  _resolve = resolve;
  _reject = reject;
  
  _interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:placementId];
  _interstitialAd.delegate = self;
  [_interstitialAd loadAd];
}

#pragma mark - FBInterstitialAdDelegate

- (void)interstitialAdDidLoad:(__unused FBInterstitialAd *)interstitialAd
{
  [_interstitialAd showAdFromRootViewController:ABI15_0_0RCTPresentedViewController()];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
  _reject(@"E_FAILED_TO_LOAD", [error localizedDescription], error);
  
  [self cleanUpAd];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
  _didClick = true;
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
  _resolve(@(_didClick));
  
  [self cleanUpAd];
}

- (void)bridgeDidForeground:(NSNotification *)notification
{
  _isBackground = false;
  
  if (_adViewController) {
    [ABI15_0_0RCTPresentedViewController() presentViewController:_adViewController animated:NO completion:nil];
    _adViewController = nil;
  }
}

- (void)bridgeDidBackground:(NSNotification *)notification
{
  _isBackground = true;
  
  if (_interstitialAd) {
    _adViewController = ABI15_0_0RCTPresentedViewController();
    [_adViewController dismissViewControllerAnimated:NO completion:nil];
  }
}

- (void)cleanUpAd
{
  _reject = nil;
  _resolve = nil;
  _interstitialAd = nil;
  _adViewController = nil;
  _didClick = false;
}

@end