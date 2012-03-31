//
//  MultiPlayerService.h
//  Shuriken
//  这里依赖GameKit.framework
//  Created by Orange on 12-2-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlueToothService.h"
#import "GameCenterService.h"
enum {
    BLUETOOTH = 1,
    GAMECENTER,
}ConnectionTypes;

enum MULTI_GAME_TYPE {
    GAME_CENTER_GAME = 0,
    BLUETOOTH_GAME = 1
};

@protocol MultiPlayerServiceDelegate <NSObject>

- (void)multiPlayerGamePrepared;
- (void)multiPlayerGameEnd;
- (void)gameRecieveData:(NSData*)data from:(NSString*)playerId;
- (void)playerLeaveGame:(NSString*)playerId;
- (void)gameCanceled;

@end

@interface MultiPlayerService : NSObject  <BlueToothServiceDelegate, GameCenterServiceDelegate> {
    int _multiGameType;
    BlueToothService* _bluetoothService;
    
}
@property (assign, nonatomic) id<MultiPlayerServiceDelegate> delegate;
@property (retain, nonatomic) BlueToothService* bluetoothService;
- (id)initWithMultiPlayerGameType:(NSInteger)aType;
- (void)findPlayers:(UIViewController*)superController;
- (void)sendDataToAllPlayers:(NSData*)data;
- (void)quitMultiPlayersGame;
@end
