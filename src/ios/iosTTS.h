#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>

@interface iosTTS : CDVPlugin <AVSpeechSynthesizerDelegate> {
    AVSpeechSynthesizer* synthesizer;

    // we will store the id here as speak will return async !
    NSString* lastSpeakCallbackId;
    
    // the selected locale
    NSString* locale;
    
    // the selected speed 0 to 1 (e.g. 0.5)
    double rate;
    
    // makes sense to have this at 1.2
    double pitch;
}

- (void)speak:(CDVInvokedUrlCommand*)command;
- (void)interrupt:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
- (void)silence:(CDVInvokedUrlCommand*)command;
- (void)speed:(CDVInvokedUrlCommand*)command;
- (void)pitch:(CDVInvokedUrlCommand*)command;

- (void)getLanguage:(CDVInvokedUrlCommand*)command;
- (void)isLanguageAvailable:(CDVInvokedUrlCommand*)command;
- (void)setLanguage:(CDVInvokedUrlCommand*)command;

@end
