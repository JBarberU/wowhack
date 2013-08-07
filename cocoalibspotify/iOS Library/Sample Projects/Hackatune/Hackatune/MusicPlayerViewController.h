//
//  MusicPlayerViewController.h
//  Hackatune
//
//  Created by John Barbero Unenge on 8/7/13.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "MarqueeLabel.h"
#import "SettingsViewController.h"

@interface MusicPlayerViewController : UIViewController <SPSessionDelegate, SPSessionPlaybackDelegate, SPPlaybackManagerDelegate, NSURLConnectionDataDelegate, SettingsViewDelegate>
{
	MarqueeLabel *_trackTitle;
	MarqueeLabel *_trackArtist;
	UIImageView *_coverView;
    UIButton *_playPauseButton;
    UIImage *_playButtonImage;
    UIImage *_pauseButtonImage;
    
	SPPlaybackManager *_playbackManager;
	SPTrack *_currentTrack;

    NSString *_currentTrackURI;
    NSURLConnection *_jsonHTTPConnection;
    NSMutableData *_jsonData;
    
    NSArray *_tracks;
    int _currentTrackIndex;
}

@property (nonatomic, strong) IBOutlet MarqueeLabel *trackTitle;
@property (nonatomic, strong) IBOutlet MarqueeLabel *trackArtist;
@property (nonatomic, strong) IBOutlet UIImageView *coverView;
@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) UIFont *mediumFont;
@property (nonatomic, strong) UIFont *boldFont;
@property (nonatomic, strong) UIImage *playButtonImage;
@property (nonatomic, strong) UIImage *pauseButtonImage;
@property (nonatomic, strong) IBOutlet UIButton *playPauseButton;
@property (nonatomic, strong) IBOutlet UIButton *playlistButton;

@property (nonatomic, strong) SPTrack *currentTrack;
@property (nonatomic, strong) SPPlaybackManager *playbackManager;

@property (nonatomic, strong) NSString *currentTrackURI;
@property (nonatomic, strong) NSURLConnection *jsonHTTPConnection;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) SPPlaylist *hackatunePlaylist;

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic) int currentTrackIndex;

@property (nonatomic) CGPoint touchPoint;
@property (nonatomic) CGRect standardCoverFrame;

- (IBAction)playTrack:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)addTrackToPlaylist:(id)sender;
- (void)startPlayback;
- (void)checkPlayState;
- (void)logout;
- (void)finishInitiation;
- (void)doneCoverFlowAnimating;

@end
