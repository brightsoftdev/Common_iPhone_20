//
//  MultiPlayerService.m
//  Shuriken
//
//  Created by Orange on 12-2-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MultiPlayerService.h"

@implementation MultiPlayerService
@synthesize delegate = _delegate;
@synthesize bluetoothService = _bluetoothService;

- (void)dealloc
{
    [_bluetoothService release];
    [super dealloc];
}

- (id)initWithMultiPlayerGameType:(NSInteger)aType
{
    self = [super init];
    if (self) {
        _multiGameType = aType;
        switch (aType) {
            case BLUETOOTH_GAME:
                _bluetoothService = [[BlueToothService alloc] init];
                _bluetoothService.delegate = self;
                break;
            case GAME_CENTER_GAME: {
            }
                break;
            default:
                break;
        }

    }
    return self;
}

- (void)sendDataToAllPlayers:(NSData*)data
{
    switch (_multiGameType) {
        case BLUETOOTH_GAME:
            [_bluetoothService sendData:data];
            break;
        case GAME_CENTER_GAME: {
            [[GameCenterService sharedInstance] sendData:data];
        }
        default:
            break;
    } 
}

- (void)findPlayers:(UIViewController*)superController
{
    switch (_multiGameType) {
        case BLUETOOTH_GAME:
            if (_bluetoothService == nil) {
                _bluetoothService = [[BlueToothService alloc] init];
            }
            [_bluetoothService findDevice];
            break;
        case GAME_CENTER_GAME: {
            [[GameCenterService sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:superController delegate:self];
        }
            break;
        default:
            break;
    }
    
}

- (void)quitMultiPlayersGame
{
    if (_bluetoothService && _multiGameType == BLUETOOTH_GAME) {
        [_bluetoothService disconnectFromAllPeers];
    } else {
        [[GameCenterService sharedInstance] quitMatch];
    }
}

#pragma mark - bluetooth service delegate
- (void)receiveData: (NSData*) data fromPeer: (NSString*) peerID
{
    if (_delegate && [_delegate respondsToSelector:@selector(gameRecieveData:from:)]) {
        [_delegate gameRecieveData:data from:peerID];
    }
}

- (void)connectDeviceSuccessfully:(NSString*)peerId
{
    if (_delegate && [_delegate respondsToSelector:@selector(multiPlayerGamePrepared)]) {
        [_delegate multiPlayerGamePrepared];
    }
}

- (void)peerDisconnectFromSession:(NSString*)peerId;

{
    if (_delegate && [_delegate respondsToSelector:@selector(playerLeaveGame:)]) {
        [_delegate playerLeaveGame:peerId];
    }
    
}

- (void)peerPickerCanceled
{
    if (_delegate && [_delegate respondsToSelector:@selector(gameCanceled)]) {
        [_delegate gameCanceled];
    }
}

#pragma mark - Game Center Delegate
- (void)cancelFromGameCenter
{
    if (_delegate && [_delegate respondsToSelector:@selector(gameCanceled)]) {
        [_delegate gameCanceled];
    }
}

- (void)matchStarted
{
    if (_delegate && [_delegate respondsToSelector:@selector(multiPlayerGamePrepared)]) {
        [_delegate multiPlayerGamePrepared];
    }
}

- (void)quitGame
{
    if (_delegate && [_delegate respondsToSelector:@selector(gameCanceled)]) {
        [_delegate gameCanceled];
    }
}

- (void)playerLeaveGame:(NSString *)playerId
{
    if (_delegate && [_delegate respondsToSelector:@selector(playerLeaveGame:)]) {
        [_delegate playerLeaveGame:playerId];
    }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data 
   fromPlayer:(NSString *)playerID
{
    if (_delegate && [_delegate respondsToSelector:@selector(gameRecieveData:from:)]) {
        [_delegate gameRecieveData:data from:playerID];
    }
}

- (void)inviteReceived
{
    if (_delegate && [_delegate respondsToSelector:@selector(multiPlayerGamePrepared)]) {
        [_delegate multiPlayerGamePrepared];
    }
}

@end
