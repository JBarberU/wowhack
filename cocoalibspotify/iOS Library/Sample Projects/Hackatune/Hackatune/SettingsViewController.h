//
//  SettingsViewController.h
//  Hackatune
//
//  Created by John Barbero Unenge on 8/7/13.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewDelegate <NSObject>

- (void)didPressLogout;
- (void)didFinish;

@end

@interface SettingsViewController : UIViewController

- (id)initWithSettingsViewDelegate:(id<SettingsViewDelegate>)delegate;
- (IBAction)logout:(id)sender;

@property (nonatomic, strong) id<SettingsViewDelegate> delegate;

@end
