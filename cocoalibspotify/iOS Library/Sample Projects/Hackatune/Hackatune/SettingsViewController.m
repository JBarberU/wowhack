//
//  SettingsViewController.m
//  Hackatune
//
//  Created by John Barbero Unenge on 8/7/13.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import "SettingsViewController.h"
#import "CocoaLibSpotify.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithSettingsViewDelegate:(id<SettingsViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender
{
    if (self.delegate) {
        [self.delegate didPressLogout];
        [self.delegate didFinish];
    }
}

@end
