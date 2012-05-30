//
//  AudioManager.m
//  Shuriken
//
//  Created by Orange on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PPDebug.h"
#import "MusicItem.h"

AudioManager* backgroundMusicManager;
AudioManager* soundManager;

static AudioManager* globalGetAudioManager()
{
    if (backgroundMusicManager == nil) {
        backgroundMusicManager = [[AudioManager alloc] init];
        [backgroundMusicManager loadSoundSettings];
    }
    return backgroundMusicManager;
}

@implementation AudioManager
@synthesize backgroundMusicPlayer = _backgroundMusicPlayer;
@synthesize sounds = _sounds;
@synthesize isSoundOn = _isSoundOn;
@synthesize isMusicOn = _isMusicOn;
@synthesize isBGMPrepared = _isBGMPrepared;
@synthesize volume = _volume;

- (void)setBackGroundMusicWithName:(NSString*)aMusicName
{
    NSString* name;
    NSString* type;
    NSString *soundFilePath;
    NSArray* nameArray = [aMusicName componentsSeparatedByString:@"."];
    if ([nameArray count] == 2) {
        name = [nameArray objectAtIndex:0];
        type = [nameArray objectAtIndex:1];
        soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    } else {
        soundFilePath = [[NSBundle mainBundle] pathForResource:aMusicName ofType:@"mp3"];
    }
    if (_isBGMPrepared && [self.backgroundMusicPlayer isPlaying]) {
        [self.backgroundMusicPlayer stop];
    }
    if (soundFilePath) {
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        NSError* error = nil;
        [self.backgroundMusicPlayer initWithContentsOfURL:soundFileURL error:&error];
        if (!error){
            PPDebug(@"<AudioManager>Init audio player successfully, sound file %@", soundFilePath);
            self.backgroundMusicPlayer.numberOfLoops = -1; //infinite
            [self.backgroundMusicPlayer setVolume:self.volume];
            [self.backgroundMusicPlayer play];
             self.isBGMPrepared = YES;
        }
        else {
            PPDebug(@"<AudioManager>Fail to init audio player with sound file%@, error = %@", soundFilePath, [error description]);
        }
    }
    
}

- (BOOL)setBackGroundMusicWithURL:(NSURL*)url
{
    if (_isBGMPrepared && [self.backgroundMusicPlayer isPlaying]) {
        [self.backgroundMusicPlayer stop];
    }
    if (url == nil) {
        return NO;
    }
    NSError* error = nil;
    if (_backgroundMusicPlayer == nil) {
        _backgroundMusicPlayer = [[AVAudioPlayer alloc] init];
    }
    [self.backgroundMusicPlayer initWithContentsOfURL:url error:&error];
    if (!error){
        PPDebug(@"<AudioManager>Init audio player successfully, sound file %@", url);
        self.backgroundMusicPlayer.numberOfLoops = -1; //infinite
        [self.backgroundMusicPlayer prepareToPlay];
        [self.backgroundMusicPlayer setVolume:self.volume];
        self.isBGMPrepared = YES;
        return YES;
    }
    else {
        PPDebug(@"<AudioManager>Fail to init audio player with sound file%@, error = %@", url, [error description]);
        self.isBGMPrepared = NO;
        _backgroundMusicPlayer = nil;
        return NO;
    }
    return NO;
}


- (void)initSounds:(NSArray*)soundNames
{
    SystemSoundID soundId;
    for (NSString* soundName in soundNames) {
        NSString* name;
        NSString* type;
        NSString *soundFilePath;
        NSArray* nameArray = [soundName componentsSeparatedByString:@"."];
        if ([nameArray count] == 2) {
            name = [nameArray objectAtIndex:0];
            type = [nameArray objectAtIndex:1];
            soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
        } else {
            soundFilePath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"WAV"];
        }
        if (soundFilePath) {
            NSURL* soundURL = [NSURL fileURLWithPath:soundFilePath];
            
            //Register sound file located at that URL as a system sound
            OSStatus err = AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &soundId);
            [self.sounds addObject:[NSNumber numberWithInt:soundId]];
            if (err != kAudioServicesNoError) {
                PPDebug(@"<AudioManager>Could not load %@, error code: %ld", soundURL, err);
            }
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        _backgroundMusicPlayer = [[AVAudioPlayer alloc] init];
        _sounds = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)dealloc
{
    [_backgroundMusicPlayer release];
    [_sounds release];
    [super dealloc];
}

+ (AudioManager*)defaultManager
{
    return globalGetAudioManager();
}

- (void)playSoundById:(NSInteger)aSoundIndex
{
    if (self.isSoundOn) {
        if (aSoundIndex < 0 || aSoundIndex >= [self.sounds count]){
            PPDebug(@"<playSoundById> but sound index (%d) out of range", aSoundIndex);
            return;
        }

        NSNumber* num = [self.sounds objectAtIndex:aSoundIndex];
        SystemSoundID soundId = num.intValue;
        AudioServicesPlaySystemSound(soundId);
        PPDebug(@"<AudioManager>play sound-%d, systemId=%d", aSoundIndex, num.intValue);
    }    
}

- (void)backgroundMusicStart
{
    //[self setBackGroundMusicWithName:@"sword.mp3"];
    if (self.isBGMPrepared && _isMusicOn) {
        [self.backgroundMusicPlayer play];
    } else {
        PPDebug(@"<AudioManager> Background music has not prepared");
    }
    
}

- (void)backgroundMusicPause
{
    //[self.backgroundMusicPlayer pause];
    if (self.isBGMPrepared) {
        [self.backgroundMusicPlayer pause];
    } else {
        PPDebug(@"<AudioManager> Background music has not prepared");
    }
}

- (void)backgroundMusicContinue
{
    //[self.backgroundMusicPlayer play];
    if (self.isBGMPrepared && _isMusicOn) {
        [self.backgroundMusicPlayer play];
    } else {
        PPDebug(@"<AudioManager> Background music has not prepared");
    }
}

- (void)backgroundMusicStop
{
    //[self.backgroundMusicPlayer stop];
    if (self.isBGMPrepared) {
        [self.backgroundMusicPlayer stop];
    } else {
        PPDebug(@"<AudioManager> Background music has not prepared");
    }
}

- (void)vibrate
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}
#define SOUND_SWITCHER @"sound_switcher"
#define MUSIC_SWITCHER @"music_switcher"
#define MUSIC_VOLUME    @"music_volume"
- (void)saveSoundSettings
{
    NSNumber* soundSwitcher = [NSNumber numberWithBool:self.isSoundOn];
    NSNumber* musicSwitcher = [NSNumber numberWithBool:self.isMusicOn];
    NSNumber* volume = [NSNumber numberWithFloat:self.volume];
    [[NSUserDefaults standardUserDefaults] setObject:soundSwitcher forKey:SOUND_SWITCHER];
    [[NSUserDefaults standardUserDefaults] setObject:musicSwitcher forKey:MUSIC_SWITCHER];
    [[NSUserDefaults standardUserDefaults] setObject:volume forKey:MUSIC_VOLUME];
}

- (void)loadSoundSettings
{
    NSNumber* soundSwitcher = [[NSUserDefaults standardUserDefaults] objectForKey:SOUND_SWITCHER];
    NSNumber* musicSwitcher = [[NSUserDefaults standardUserDefaults] objectForKey:MUSIC_SWITCHER];
    NSNumber* volume = [[NSUserDefaults standardUserDefaults] objectForKey:MUSIC_VOLUME];
    if (soundSwitcher) {
        self.isSoundOn = soundSwitcher.boolValue;
    } else {
        self.isSoundOn = YES;
    }
    if (musicSwitcher) {
        self.isMusicOn = musicSwitcher.boolValue;
    } else {
        self.isMusicOn = YES;
    }
    if (volume) {
        self.volume = volume.floatValue;
    } else {
        self.isMusicOn = 1;
    }
}

- (void)setIsMusicOn:(BOOL)isMusicOn 
{
    _isMusicOn = isMusicOn;
    if (isMusicOn) {
        [self backgroundMusicStart];
    } else {
        [self backgroundMusicPause];
    }
    [self saveSoundSettings];
}

- (void)setVolume:(float)volume
{
    _volume = volume;
    if (volume >= 0 && volume <= 1 && self.isBGMPrepared) {
        self.backgroundMusicPlayer.volume = volume;
    } else {
        PPDebug(@"<AudioManager> backgroundMusicPlayer not prepared or volume %.2f out of range! ", volume);
    }
}

//- (float)volume
//{
//    if (self.backgroundMusicPlayer != nil && self.isBGMPrepared) {
//         return self.backgroundMusicPlayer.volume;
//    } else {
//        PPDebug(@"<AudioManager> Background music has not prepared");
//    }
//    return 0;
//   
//}

@end
