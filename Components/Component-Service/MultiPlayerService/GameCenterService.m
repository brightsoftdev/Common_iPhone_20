//
//  GameCenterService.m
//  Shuriken
//
//  Created by Orange on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameCenterService.h"

static GameCenterService *globalGetGameCenterService ;

@implementation GameCenterService
@synthesize gameCenterAvailable;
@synthesize match = _match;
@synthesize gameViewController = _gameViewController;
@synthesize playersDict = _playersDict;
@synthesize delegate = _delegate;
@synthesize pendingInvite = _pendingInvite;
@synthesize pendingPlayersToInvite = _pendingPlayersToInvite;

+ (GameCenterService *) sharedInstance {
    if (!globalGetGameCenterService) {
        globalGetGameCenterService = [[GameCenterService alloc] init];
    }
    return globalGetGameCenterService;
}

#pragma mark Initialization

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged { 
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE; 
        [GKMatchmaker sharedMatchmaker].inviteHandler =^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
            
            NSLog(@"Received invite");
            self.pendingInvite = acceptedInvite;
            self.pendingPlayersToInvite = playersToInvite;
            [_delegate inviteReceived];
        };
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

- (void)lookupPlayers {
    
    NSLog(@"Looking up %d players...", self.match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:self.match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            _matchStarted = NO;
            [_delegate quitGame];
        } else {            
            // Populate players dict
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [self.playersDict setObject:player forKey:player.playerID];
            }            
            // Notify delegate match can begin
            _matchStarted = YES;
            [_delegate matchStarted];
            
        }
    }];
    
}

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        NSLog(@"Error sending init packet");
    }
}

#pragma mark - User functions

- (void)authenticateLocalUser { 
    
    if (!gameCenterAvailable) return;
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) { 
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil]; 
    } else {
        NSLog(@"Already authenticated!");
    }
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers 
                 viewController:(UIViewController *)viewController 
                       delegate:(id<GameCenterServiceDelegate>)aDelegate {
    
    if (!gameCenterAvailable) return;
    self.match = nil;
    _matchStarted = NO;
    self.gameViewController = viewController;
    _delegate = aDelegate;
    
    if (_pendingInvite != nil) {
        [(UIViewController*)self.gameViewController dismissModalViewControllerAnimated:NO];
        GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithInvite:_pendingInvite] autorelease];
        mmvc.matchmakerDelegate = self;
        [(UIViewController*)self.gameViewController presentModalViewController:mmvc animated:YES];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
    } else {
        [(UIViewController*)self.gameViewController dismissModalViewControllerAnimated:NO];
        
        GKMatchRequest *request = [[GKMatchRequest alloc] init] ; 
        request.minPlayers = minPlayers; 
        request.maxPlayers = maxPlayers;
        
        GKMatchmakerViewController *mmvc = 
        [[GKMatchmakerViewController alloc] initWithMatchRequest:request]; 
        mmvc.matchmakerDelegate = self;
        
        [(UIViewController*)self.gameViewController presentModalViewController:mmvc animated:YES];
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
    }
}

#pragma mark - GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID { 
    if (self.match != theMatch) return;
    
    [_delegate match:theMatch didReceiveData:data fromPlayer:playerID];
    
    NSLog(@"recieve data from others");
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state { 
    if (self.match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected: 
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!_matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            
            break; 
        case GKPlayerStateDisconnected:
            // a player just disconnected. 
            NSLog(@"Player disconnected!");
            _matchStarted = NO;
            [_delegate playerLeaveGame:playerID];
            break;
    } 
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (self.match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    _matchStarted = NO;
    //[_delegate playerLeaveGame:playerID];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (self.match != theMatch) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [_delegate quitGame];
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [(UIViewController*)self.gameViewController dismissModalViewControllerAnimated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(cancelFromGameCenter)]) {
        [_delegate cancelFromGameCenter];
    }
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [(UIViewController*)self.gameViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription); 
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    [(UIViewController*)self.gameViewController dismissModalViewControllerAnimated:YES];
    self.match = theMatch;
    self.match.delegate = self;
    if (!_matchStarted && self.match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
}


- (void) reportScore: (int64_t) score forCategory: (NSString*) category
{
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            NSLog(@"report score error!");
            // handle the reporting error
        } else {
            NSLog(@"report score success!");
        }
    }];
}

- (void) loadCategoryTitles                                                
{
    [GKLeaderboard loadCategoriesWithCompletionHandler:^(NSArray *categories, NSArray *titles, NSError *error) {
        if (error != nil)
        {
            // handle the error
        }
        NSLog(@"id is %@, name is %@", [categories objectAtIndex:0], [titles objectAtIndex:0]);
        [self reportScore:(int64_t)1000 forCategory:[categories objectAtIndex:0]];
        // use the category and title information
    }];
}

- (void)quitMatch
{
    [self.match disconnect];
}

@end
