// PORTED FROM: pcsx2/Host/CubebAudioStream.cpp — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 9.2, 9.3
// STATUS: NEW — AVAudioSession configuration + AudioStream stub

// Audit Sec 9.2: cubeb has native iOS AudioUnit backend.
// This file configures AVAudioSession for iOS audio.
// The actual audio streaming goes through CubebAudioStream.

#include "PrecompiledHeader.h"
#import <AVFoundation/AVFoundation.h>
#include "Host/AudioStream.h"
#include "common/Console.h"

void iOSConfigureAudioSession()
{
    NSError* error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];

    // Audit Sec 9.2: Use Playback category for game audio
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionMixWithOthers
                   error:&error];
    if (error) {
        NSLog(@"[BionicSX2] AVAudioSession category error: %@", error);
    }

    // Audit Sec 9.3: 5ms IOBufferDuration for low latency
    [session setPreferredIOBufferDuration:0.005 error:&error];
    if (error) {
        NSLog(@"[BionicSX2] AVAudioSession buffer duration error: %@", error);
    }

    [session setPreferredSampleRate:48000 error:&error];
    if (error) {
        NSLog(@"[BionicSX2] AVAudioSession sample rate error: %@", error);
    }

    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"[BionicSX2] AVAudioSession activate error: %@", error);
    }

    Console.WriteLn("BionicSX2: AVAudioSession configured (%f Hz)", session.sampleRate);
}

// Handle AVAudioSession interruptions (phone calls, background)
void iOSAudioHandleInterruption(NSNotification* notification)
{
    NSDictionary* userInfo = [notification userInfo];
    NSInteger type = [userInfo[AVAudioSessionInterruptionTypeKey] integerValue];

    if (type == AVAudioSessionInterruptionTypeBegan) {
        Console.WriteLn("BionicSX2: Audio interrupted");
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        Console.WriteLn("BionicSX2: Audio interruption ended");
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
    }
}
