//
//  BlueToothService.m
//  Shuriken
//
//  Created by Orange on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BlueToothService.h"
#define C2S_SESSION_ID @"sksessionc2s"

@implementation BlueToothService
@synthesize delegate = _delegate;
@synthesize peerName = _peerName;

- (void)dealloc
{
    [_currentSession release];
    [_peerName release];
    [super dealloc];
}


- (id)initWithName:(NSString*)aName 
{
    self = [super init];
    if (self) {
        self.peerName = aName;
    }
    return self;
}

- (void)findDevice
{
    GKPeerPickerController* _picker = [[[GKPeerPickerController alloc] init] autorelease];
    
    _picker.delegate = self;
    
    _picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [_picker show];
}

- (void)sendData:(NSData*)data
{
    [_currentSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

#pragma --peerpickercontroller delegate

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker{
    if (_delegate && [_delegate respondsToSelector:@selector(peerPickerCanceled)]) {
        [_delegate peerPickerCanceled];
    }
}

-(GKSession *) peerPickerController: (GKPeerPickerController*) controller
           sessionForConnectionType: (GKPeerPickerConnectionType) type {
    if (!_currentSession) {
        _currentSession = [[GKSession alloc]
                           initWithSessionID:C2S_SESSION_ID
                           displayName:self.peerName//在线用户名
                           sessionMode:GKSessionModePeer];
        _currentSession.delegate = self;
    }
    //[_currentSession setDataReceiveHandler:self withContext:nil];
    return _currentSession;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    //被接受，点击接受
    [picker dismiss];
    picker.delegate = nil;
    //_actingAsHost = NO;//设为客户端
    if (_delegate && [_delegate respondsToSelector:@selector(connectDeviceSuccessfully:)]) {
        [_delegate connectDeviceSuccessfully:peerID];
    }
}
- (void)session:(GKSession *)session
didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    //弹出是否接受的提示
    //_actingAsHost = NO;//设为客户端
//    if (_delegate && [_delegate respondsToSelector:@selector(acceptDevice)]) {
//        [_delegate didAcceptedByDevice:peer];
//    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            [session setDataReceiveHandler: self withContext: nil];
            NSLog(@"peer connected");
            //这里待测试一下，把触发游戏开关设在这里
            break;
        case GKPeerStateAvailable:
            NSLog(@"peer available");
            break;
        case GKPeerStateDisconnected:
            if (_delegate && [_delegate respondsToSelector:@selector(peerDisconnectFromSession:)]) {
                [_delegate peerDisconnectFromSession:peerID];
            }
            NSLog(@"peer disconnected");
            break;
        case GKPeerStateConnecting:
            NSLog(@"peer connecting");
            break;
        case GKPeerStateUnavailable:
            NSLog(@"peer unavailable");
            break;
            default:
            break;
    }
    
}

- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type{

}

- (void) receiveData: (NSData*) data fromPeer: (NSString*) peerID
           inSession: (GKSession*) session context: (void*) context {
    if (_delegate && [_delegate respondsToSelector:@selector(receiveData:fromPeer:)]) {
        [_delegate receiveData:data fromPeer:peerID];
    }
}

- (void)disconnectFromAllPeers
{
    if (_currentSession) {
        [_currentSession disconnectFromAllPeers];
    }
    [_currentSession release];
}



@end
