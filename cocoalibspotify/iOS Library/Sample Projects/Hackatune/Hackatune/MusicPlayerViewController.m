//
//  MusicPlayerViewController.m
//  Hackatune
//
//  Created by John Barbero Unenge on 8/7/13.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import "MusicPlayerViewController.h"
#include "appkey.c"

@implementation MusicPlayerViewController

@synthesize trackTitle = _trackTitle;
@synthesize trackArtist = _trackArtist;
@synthesize coverView = _coverView;
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
    
    self.playButtonImage = [UIImage imageNamed:@"playbutton.png"];
    self.pauseButtonImage = [UIImage imageNamed:@"pausebutton.png"];
    
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
    
    NSLog(@"U: %@ C: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyUser"], [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyCredential"]);
    
    NSString *user = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyUser"];
    NSString *credentials = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotifyCredential"];
    if (user && credentials)
        [[SPSession sharedSession] attemptLoginWithUserName:user existingCredential:credentials];
    else
        [self performSelector:@selector(showLogin)];
    

    // Do any additional setup after loading the view from its nib.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTrack.name"]) {
        self.trackTitle.text = [self.currentTrack.name uppercaseString];
	} else if ([keyPath isEqualToString:@"currentTrack.artists"]) {
		self.trackArtist.text = [[[self.currentTrack.artists valueForKey:@"name"] componentsJoinedByString:@","] uppercaseString];
	} else if ([keyPath isEqualToString:@"currentTrack.album.cover.image"]) {
		self.coverView.image = self.currentTrack.album.cover.image;
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
            
            [SPAsyncLoading waitUntilLoaded:track timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *tracks, NSArray *notLoadedTracks) {
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
            }];
        }
    }];
}

- (IBAction)nextTrack:(id)sender
{
    if (!self.tracks && [self.tracks count] <= 0)
        return;
    
    ++self.currentTrackIndex;
    
    if (self.currentTrackIndex >= [self.tracks count] || self.currentTrackIndex < 0)
        self.currentTrackIndex = 0;
    
    self.currentTrackURI = [self.tracks objectAtIndex:self.currentTrackIndex];
    
    NSLog(@"New Track: %@",self.currentTrackURI);
    
    [self startPlayback];
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

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
	// Invoked by SPSession after a successful login.
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

@end
