//
//  Simple_PlayerAppDelegate.m
//  Simple Player
//
//  Created by Daniel Kennett on 10/3/11.
/*
 Copyright (c) 2011, Spotify AB
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Spotify AB nor the names of its contributors may
 be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "HackatuneAppDelegate.h"
#include "appkey.c"
#import "MarqueeLabel.h"

@implementation HackatuneAppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;
@synthesize trackURIField = _trackURIField;
@synthesize trackTitle = _trackTitle;
@synthesize trackArtist = _trackArtist;
@synthesize coverView = _coverView;
@synthesize playbackManager = _playbackManager;
@synthesize currentTrack = _currentTrack;
@synthesize TEST_TRACKS = _TEST_TRACKS;
@synthesize TEST_CURRENT_INDEX = _TEST_CURRENT_INDEX;
@synthesize currentTrackURI = _currentTrackURI;
@synthesize jsonHTTPConnection = _jsonHTTPConnection;
@synthesize jsonData = _jsonData;
@synthesize playButtonImage = _playButtonImage;
@synthesize pauseButtonImage = _pauseButtonImage;
@synthesize playPauseButton = _playPauseButton;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    
    _trackTitle.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    _trackArtist.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    _trackArtist.textColor = [UIColor whiteColor];
    _trackTitle.textColor = [UIColor whiteColor];
    
    _trackTitle.fadeLength = 25.0f;
    _trackArtist.fadeLength = 25.0f;
    

    
	// Override point for customization after application launch.
	[self.window makeKeyAndVisible];
    
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

    return YES;
}

-(void)showLogin
{
    SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	controller.allowsCancel = NO;
	
	[self.mainViewController presentModalViewController:controller
											   animated:NO];
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

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
	
	[[SPSession sharedSession] logout:^{}];
}


- (void)dealloc {
	
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
    if (!self.TEST_TRACKS && [self.TEST_TRACKS count] <= 0)
        return;
    
    ++self.TEST_CURRENT_INDEX;
    
    if (self.TEST_CURRENT_INDEX >= [self.TEST_TRACKS count] || self.TEST_CURRENT_INDEX < 0)
        self.TEST_CURRENT_INDEX = 0;
    
    self.currentTrackURI = [self.TEST_TRACKS objectAtIndex:self.TEST_CURRENT_INDEX];
    
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
        self.TEST_CURRENT_INDEX = -1;
        self.TEST_TRACKS = nil;
        return;
    }
    
    NSMutableArray *newTracks = [[NSMutableArray alloc] initWithCapacity:[json count]];
    for (NSDictionary *inner in [json objectEnumerator]) {
        id obj = [inner objectForKey:@"spotify_id"];
        if (obj)
            [newTracks addObject:[NSString stringWithFormat:@"spotify:track:%@",obj]];
    }
    self.TEST_TRACKS = [NSArray arrayWithArray:newTracks];
    
    self.TEST_CURRENT_INDEX = 0;
    self.currentTrackURI = [self.TEST_TRACKS objectAtIndex:self.TEST_CURRENT_INDEX];
}


#pragma mark -
#pragma mark SPSessionDelegate Methods

-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return self.mainViewController;
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
	
	if (self.mainViewController.presentedViewController != nil) return;
	
	controller.allowsCancel = NO;
	
	[self.mainViewController presentModalViewController:controller
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
