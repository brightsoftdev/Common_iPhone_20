//
//  BlueToothService.h
//  Shuriken
//
//  Created by Orange on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
@protocol BlueToothServiceDelegate <NSObject>

- (void)receiveData: (NSData*) data fromPeer: (NSString*) peerID;
- (void)connectDeviceSuccessfully:(NSString*)peerId;
- (void)peerDisconnectFromSession:(NSString*)peerId;
- (void)peerPickerCanceled;
@end

@interface BlueToothService : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate> {
    GKSession* _currentSession;
    BOOL _actingAsHost;
}
@property (assign, nonatomic) id<BlueToothServiceDelegate> delegate;
@property (retain, nonatomic) NSString* peerName;
- (void)findDevice;
- (void)sendData:(NSData*)data;
- (id)initWithName:(NSString*)aName;
- (void)disconnectFromAllPeers;

@end
