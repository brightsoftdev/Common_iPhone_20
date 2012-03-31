//
//  GameCenterService.h
//  Shuriken
//
//  Created by Orange on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
@protocol GameCenterServiceDelegate <NSObject>
 @optional
- (void)matchStarted;
- (void)playerLeaveGame:(NSString*)playerId;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data 
   fromPlayer:(NSString *)playerID;
- (void)inviteReceived;
- (void)quitGame;
- (void)cancelFromGameCenter;
@end

@interface GameCenterService : NSObject <GKMatchDelegate, 
GKMatchmakerViewControllerDelegate>{
    GKMatch* _match;
    GKInvite *_pendingInvite;
    NSArray *_pendingPlayersToInvite;
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    id<GameCenterServiceDelegate> _delegate;
    BOOL _matchStarted;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (retain, nonatomic) GKMatch* match;
@property (retain, nonatomic) UIViewController* gameViewController;
@property (retain) NSMutableDictionary *playersDict;
@property (retain, nonatomic) id<GameCenterServiceDelegate> delegate;
@property (retain, nonatomic) GKInvite* pendingInvite;
@property (retain, nonatomic) NSArray* pendingPlayersToInvite;

+ (GameCenterService *) sharedInstance;
- (void)authenticateLocalUser;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers 
                 viewController:(UIViewController *)viewController 
                       delegate:(id<GameCenterServiceDelegate>)aDelegate;
- (void)reportScore: (int64_t) score forCategory: (NSString*) category;
- (void)sendData:(NSData *)data;
- (void) loadCategoryTitles;
- (void)quitMatch;
@end
