// PORTED FROM: PCSX2 macOS filesystem code — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 6.4, 10.3
// STATUS: NEW — iOS sandbox-aware filesystem paths

// Audit Sec 6.4: All paths resolved via NSSearchPathForDirectoriesInDomains
// Audit Sec 10.3: Never use hardcoded absolute paths on iOS

#import <Foundation/Foundation.h>
#include "PrecompiledHeader.h"
#include "common/FileSystem.h"
#include <string>

// Get the app's Documents directory (user-facing files)
std::string iOSGetDocumentsDirectory()
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documents = [paths firstObject];
    return std::string([documents UTF8String]);
}

// Get the app's Caches directory (temporary files, shader cache)
std::string iOSGetCachesDirectory()
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
        NSCachesDirectory, NSUserDomainMask, YES);
    NSString* caches = [paths firstObject];
    return std::string([caches UTF8String]);
}

// Get the app's Application Support directory (persistent data)
std::string iOSGetApplicationSupportDirectory()
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
        NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString* appSupport = [paths firstObject];
    return std::string([appSupport UTF8String]);
}

// Audit Sec 2.6: ISO file reading is the ONLY path on iOS
// Physical optical drive code excluded entirely (CDVD/Darwin/ is RED)
std::string iOSGetBIOSPath()
{
    return iOSGetDocumentsDirectory() + "/BIOS/";
}

std::string iOSGetISOPath()
{
    return iOSGetDocumentsDirectory() + "/Games/";
}

std::string iOSGetMemcardPath()
{
    return iOSGetDocumentsDirectory() + "/Memcards/";
}

// Audit Sec 6.4: Create standard directories on first launch
void iOSEnsureDirectoriesExist()
{
    NSFileManager* fm = [NSFileManager defaultManager];

    for (const auto& dir : {
        iOSGetBIOSPath(),
        iOSGetISOPath(),
        iOSGetMemcardPath(),
        iOSGetCachesDirectory() + "/shaders/",
        iOSGetApplicationSupportDirectory() + "/savestates/"
    }) {
        NSString* nsPath = [NSString stringWithUTF8String:dir.c_str()];
        if (![fm fileExistsAtPath:nsPath]) {
            NSError* error = nil;
            [fm createDirectoryAtPath:nsPath
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
            if (error) {
                NSLog(@"[BionicSX2] Failed to create directory %@: %@", nsPath, error);
            }
        }
    }
}
