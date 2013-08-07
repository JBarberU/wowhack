//
//  MusicPlayerViewController.m
//  Hackatune
//
//  Created by John Barbero Unenge on 8/7/13.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import "MusicPlayerViewController.h"
#include "appkey.c"
#import "DatabaseHelper.h"

@implementation MusicPlayerViewController

@synthesize trackTitle = _trackTitle;
@synthesize trackArtist = _trackArtist;
@synthesize coverView1 = _coverView1;
@synthesize coverView2 = _coverView2;
@synthesize playbackManager = _playbackManager;
@synthesize currentTrack = _currentTrack;
@synthesize tracks = _tracks;
@synthesize currentTrackIndex = _currentTrackIndex;
@synthesize currentTrackURI = _currentTrackURI;
@synthesize jsonHTTPConnection = _jsonHTTPConnection;
@synthesize jsonData = _jsonData;
@synthesize playButtonImage = _playButtonImage;
@synthesize pauseButtonImage = _pauseButtonImage;
@synthesize playPauseButton = _playPauseButton;


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
    self.currentCoverImage = 1;
    self.playButtonImage = [UIImage imageNamed:@"playbutton.png"];
    self.pauseButtonImage = [UIImage imageNamed:@"pausebutton.png"];
    
    self.mediumFont = [UIFont fontWithName:@"AvantGardeCapsAltsMedium" size:18];
    self.boldFont  = [UIFont fontWithName:@"AvantGardeCapsAltsDemi" size:30];
    
    [self.trackArtist setFont:self.mediumFont];
    [self.trackTitle setFont:self.boldFont];
    
    self.trackTitle.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    self.trackArtist.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    self.trackArtist.textColor = [UIColor whiteColor];
    self.trackTitle.textColor = [UIColor whiteColor];
    
    self.trackTitle.fadeLength = 25.0f;
    self.trackArtist.fadeLength = 25.0f;
    
    NSURLRequest *jsonRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hackatune.gotconsulting.se/wow.json"]];
    self.jsonData = [[NSMutableData alloc] init];
    self.jsonHTTPConnection = [[NSURLConnection alloc] initWithRequest:jsonRequest delegate:self startImmediately:YES];
    
    //Load Fonts
    _mediumFont = [UIFont fontWithName:@"AvantGardeCapsAltsMedium" size:18];
    _boldFont  = [UIFont fontWithName:@"AvantGardeCapsAltsDemi" size:30];
    [_trackArtist setFont:_mediumFont];
    [_trackTitle setFont:_boldFont];
    
	NSError *error = nil;
	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
											   userAgent:@"se.hackatune-iOS"
										   loadingPolicy:SPAsyncLoadingManual
												   error:&error];
	if (error != nil) {
		NSLog(@"CocoaLibSpotify init failed: %@", error);
		abort();
	}
    
	self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
	[[SPSession sharedSession] setDelegate:self];
    
    [[SPSession sharedSession] setPlaybackDelegate:self];
    
	[self addObserver:self forKeyPath:@"currentTrack.name" options:0 context:nil];
	[self addObserver:self forKeyPath:@"currentTrack.artists" options:0 context:nil];
	[self addObserver:self forKeyPath:@"currentTrack.album.cover.image" options:0 context:nil];
}


- (void)finishInitiation
{
    NSLog(@"U: %@ C: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyUser"], [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyCredential"]);
    
    NSString *user = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyUser"];
    NSString *credentials = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyCredential"];
    if (user && credentials)
        [[SPSession sharedSession] attemptLoginWithUserName:user existingCredential:credentials];
    else
        [self performSelector:@selector(showLogin)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTrack.name"]) {
        self.trackTitle.text = [self.currentTrack.name uppercaseString];
	} else if ([keyPath isEqualToString:@"currentTrack.artists"]) {
		self.trackArtist.text = [[[self.currentTrack.artists valueForKey:@"name"] componentsJoinedByString:@","] uppercaseString];
	} else if ([keyPath isEqualToString:@"currentTrack.album.cover.image"]) {
        if (self.currentCoverImage == 2) {
            self.coverView1.image = self.currentTrack.album.cover.image;
            CGRect right = self.coverView1.frame;
            CGRect left = right;
            right = CGRectMake([[UIScreen mainScreen] bounds].size.width + right.size.width, right.origin.y, right.size.width, right.size.height);
            left = CGRectMake(0 - left.size.width, left.origin.y, left.size.width, left.size.height);
            
            CGRect center = self.coverView2.frame;
            [self.coverView1 setFrame:right];
            
            [UIView beginAnimations:nil context:NULL]; // animate the following:
            [self.coverView1 setFrame:center];
            [self.coverView2 setFrame:left];
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView commitAnimations];
            
            self.currentCoverImage = 1;
        } else {
            self.coverView2.image = self.currentTrack.album.cover.image;
            CGRect right = self.coverView1.frame;
            CGRect left = right;
            right = CGRectMake([[UIScreen mainScreen] bounds].size.width + right.size.width, right.origin.y, right.size.width, right.size.height);
            left = CGRectMake(0 - left.size.width, left.origin.y, left.size.width, left.size.height);
            
            CGRect center = self.coverView1.frame;
            [self.coverView2 setFrame:right];
            
            [UIView beginAnimations:nil context:NULL]; // animate the following:
            [self.coverView2 setFrame:center];
            [self.coverView1 setFrame:left];
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView commitAnimations];
            self.currentCoverImage = 2;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)showLogin
{
    SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	controller.allowsCancel = NO;
	[self presentModalViewController:controller animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logout
{
	[[SPSession sharedSession] logout:^{}];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentTrack.name"];
    [self removeObserver:self forKeyPath:@"currentTrack.artists"];
    [self removeObserver:self forKeyPath:@"currentTrack.album.cover.image"];
}

#pragma mark -

- (IBAction)playTrack:(id)sender
{
    if (self.currentTrack == nil)
        [self startPlayback];
    else
        self.playbackManager.isPlaying = !self.playbackManager.isPlaying;
    
    [self checkPlayState];
}

- (void)checkPlayState
{
    if (self.playbackManager.isPlaying)
        [self.playPauseButton setImage:self.pauseButtonImage forState:nil];
    else
        [self.playPauseButton setImage:self.playButtonImage forState:nil];
}

- (void)startPlayback
{
    // Invoked by clicking the "Play" button in the UI.
    NSURL *trackURL = [NSURL URLWithString:self.currentTrackURI];
    [[SPSession sharedSession] trackForURL:trackURL callback:^(SPTrack *track) {
        
        if (track != nil) {
            NSLog(@"1");
            if(![[DatabaseHelper sharedDatabaseHelper] selectSongWithID:self.currentTrackURI]) {
                NSLog(@"2");
                [SPAsyncLoading waitUntilLoaded:track timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *tracks, NSArray *notLoadedTracks) {
                    NSLog(@"3");
                    [self.playbackManager playTrack:track callback:^(NSError *error) {
                        if (error) {
                            NSLog(@"Error: %@",error);
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                                            message:[error localizedDescription]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        } else {
                            self.currentTrack = track;
                            self.playbackManager.delegate = self;
                        }
                        
                    }];
                    [[DatabaseHelper sharedDatabaseHelper] insertSongWithID:self.currentTrackURI];
                }];
            } else {
                [self nextTrack:nil];
            }
        }
    }];
}

- (IBAction)nextTrack:(id)sender
{
    if (!self.tracks && [self.tracks count] <= 0)
        return;
    
    [self.playlistButton setEnabled:(self.hackatunePlaylist != nil)];
    
    ++self.currentTrackIndex;
    
    if (self.currentTrackIndex >= [self.tracks count] || self.currentTrackIndex < 0) {
        self.currentTrackIndex = 0;
        [[DatabaseHelper sharedDatabaseHelper] clearSongs];
    }
    
    self.currentTrackURI = [self.tracks objectAtIndex:self.currentTrackIndex];
    
    NSLog(@"New Track: %@",self.currentTrackURI);
    
    [self startPlayback];
}

- (IBAction)addTrackToPlaylist:(id)sender
{
    if (!self.hackatunePlaylist) {
        NSLog(@"Hackatune playlist unavailable");
        return;
    }
    
    static bool buttonEnabled = NO;
    [self.hackatunePlaylist addItem:self.currentTrack atIndex:0 callback:^(NSError *error) {
        if (error) {
            NSLog(@"Could not add track to playlist!");
            buttonEnabled = YES;
        }
    }];
    [self.playlistButton setEnabled:buttonEnabled];
}

#pragma -
#pragma TouchDelegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1)
        self.touchPoint = [[touches anyObject] locationInView:self.view];
    else
        self.touchPoint = CGPointMake(-1.0f,-1.0f);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"bARBEerbBBER");
    if (self.touchPoint.x >= 0 && self.touchPoint.y >= 0 && [touches count] == 1) {
        CGPoint p = [[touches anyObject] locationInView:self.view];
        
        CGRect screen = [[UIScreen mainScreen] bounds];
        float d = p.x - self.touchPoint.x;
        
        if ((d < 0 ? d * -1 : d) > screen.size.width/2) {
            if (d < 0)
                [self nextTrack:nil];
            else {
                SettingsViewController *svc = [[SettingsViewController alloc] initWithSettingsViewDelegate:self];
                svc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentModalViewController:svc animated:YES];
            }                
        }
    }
    
    self.touchPoint = CGPointMake(-1, -1);
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate Methods

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.jsonData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.jsonData options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"Unable to load JSON");
        return;
    }
    
    if ([json count] <= 0) {
        self.currentTrackIndex = -1;
        self.tracks = nil;
        return;
    }
    
    NSMutableArray *newTracks = [[NSMutableArray alloc] initWithCapacity:[json count]];
    for (NSDictionary *inner in [json objectEnumerator]) {
        id obj = [inner objectForKey:@"spotify_id"];
        if (obj)
            [newTracks addObject:[NSString stringWithFormat:@"spotify:track:%@",obj]];
    }
    self.tracks = [NSArray arrayWithArray:newTracks];
    
    self.currentTrackIndex = 0;
    self.currentTrackURI = [self.tracks objectAtIndex:self.currentTrackIndex];
}


#pragma mark -
#pragma mark SPSessionDelegate Methods

-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return self;
}

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession {

    [SPAsyncLoading waitUntilLoaded:[SPSession sharedSession] timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedession, NSArray *notLoadedSession) {
        
        // The session is logged in and loaded — now wait for the userPlaylists to load.
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Session loaded.");
        
        [SPAsyncLoading waitUntilLoaded:[SPSession sharedSession].userPlaylists timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedContainers, NSArray *notLoadedContainers) {
            
            // User playlists are loaded — wait for playlists to load their metadata.
            NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Container loaded.");
            
            NSMutableArray *playlists = [NSMutableArray array];
            [playlists addObject:[SPSession sharedSession].starredPlaylist];
            [playlists addObject:[SPSession sharedSession].inboxPlaylist];
            [playlists addObjectsFromArray:[SPSession sharedSession].userPlaylists.flattenedPlaylists];
            
            [SPAsyncLoading waitUntilLoaded:playlists timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedPlaylists, NSArray *notLoadedPlaylists) {
                
                // All of our playlists have loaded their metadata — wait for all tracks to load their metadata.
                NSLog(@"[%@ %@]: %@ of %@ playlists loaded.", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
                      [NSNumber numberWithInteger:loadedPlaylists.count], [NSNumber numberWithInteger:loadedPlaylists.count + notLoadedPlaylists.count]);

                self.hackatunePlaylist = nil;
                for (SPPlaylist *pl in playlists) {
                    if ([pl.name isEqualToString:@"Hackatune"]) {
                        self.hackatunePlaylist = pl;
                        break;
                    }
                }
                
                if (!self.hackatunePlaylist) {
                    [[[SPSession sharedSession] userPlaylists] createPlaylistWithName:@"Hackatune" callback:^(SPPlaylist *createdPlaylist) {
                        self.hackatunePlaylist = createdPlaylist;
                    }];
                }
                
                [self.playlistButton setEnabled:(self.hackatunePlaylist != nil)];
            }];
        }];
    }];
    
}

-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName
{
    NSLog(@"Saving credentials");
    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"spotifyUser"];
    [[NSUserDefaults standardUserDefaults] setValue:credential forKey:@"spotifyCredential"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error
{
    NSLog(@"Login error: %@", error);
    if (error.code == 8)
        [self performSelector:@selector(showLogin)];
}

-(void)sessionDidLogOut:(SPSession *)aSession {
	
	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	
	if (self.presentedViewController != nil) return;
	
	controller.allowsCancel = NO;
	    
	[self presentModalViewController:controller
                            animated:YES];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	return;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)sessionDidEndPlayback:(id <SPSessionPlaybackProvider>)aSession
{
    [self nextTrack:nil];
}

#pragma -
#pragma SPPlaybackManagerDelegate
- (void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager
{
    [self checkPlayState];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma -
#pragma SettingsViewDelegate
- (void)didFinish
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didPressLogout
{
    [[SPSession sharedSession] logout:^() {}];
    UIAlertView *uiav = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully logged out" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [uiav show];
}

@end
