/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
#import "RCTRootView.h"

#import "AppDelegate.h"

@import AVFoundation;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *packagerUrl = [defaults stringForKey:@"packager_url"];
  NSURL *jsCodeLocation = [NSURL URLWithString:packagerUrl];

  RCTRootView* rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"RemoteNative"
                                                   launchOptions:launchOptions];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [[UIViewController alloc] init];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  [self initAudio];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqual:@"outputVolume"]) {
    NSLog(@"Reload from remote");
    
    [RCTRootView reloadAll];
    
    UIView* rootView = self.window.rootViewController.view;
    
    [UIView animateWithDuration:0.5 animations:^{
      rootView.layer.opacity = 0;
    } completion:^(BOOL done){
      rootView.layer.opacity = 1;
    }
     ];
  }
}

-(void)initAudio
{
  [[AVAudioSession sharedInstance] setActive:YES error:nil];
  
  // enjoy music during development
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
  
  [[AVAudioSession sharedInstance] addObserver:self
                forKeyPath:@"outputVolume"
                options:0
                context:nil];
}

@end
