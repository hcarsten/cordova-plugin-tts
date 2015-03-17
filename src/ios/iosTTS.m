#import <Cordova/CDV.h>
#import "iosTTS.h"

@implementation iosTTS

- (void)pluginInitialize {
    synthesizer = [AVSpeechSynthesizer new];
    synthesizer.delegate = self;
    
    // directly addressing the members and prevent
    // property access !
    
    // defaults to en-US !
    locale = @"en-US";
    
    // normal rate
    rate = 1.0;
    
    // normal pitch
    pitch = 1.2;
}

// delegate implementation
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer
 didFinishSpeechUtterance:(AVSpeechUtterance*)utterance {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    if (lastSpeakCallbackId) {
        [self.commandDelegate sendPluginResult:result callbackId:lastSpeakCallbackId];
        lastSpeakCallbackId = nil;
    }
}

- (void)startup:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)shutdown:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)speak:(CDVInvokedUrlCommand*)command {
    lastSpeakCallbackId = command.callbackId;

    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];

    NSString* text = [command.arguments objectAtIndex:0];
    
    AVSpeechUtterance* utterance = [[AVSpeechUtterance new] initWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:locale];
    
    // check this formula here !
    utterance.rate = (AVSpeechUtteranceMinimumSpeechRate * 1.5 + AVSpeechUtteranceDefaultSpeechRate)
                        / 2.5 * rate * rate;
    
    utterance.pitchMultiplier = 1.2;
    [synthesizer speakUtterance:utterance];
}

- (void)interrupt:(CDVInvokedUrlCommand*)command {
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)silence:(CDVInvokedUrlCommand*)command {
    NSString* txtDelay = [command.arguments objectAtIndex:0];
    double msDelay = [txtDelay doubleValue] / 1000;
    
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [synthesizer performSelector:@selector(continueSpeaking) withObject:nil afterDelay:msDelay];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)speed:(CDVInvokedUrlCommand*)command {
    NSString* txtRate = [command.arguments objectAtIndex:0];
    rate = [txtRate doubleValue];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)pitch:(CDVInvokedUrlCommand*)command {
    NSString* txtPitch = [command.arguments objectAtIndex:0];
    pitch = [txtPitch doubleValue];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getLanguage:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: locale];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)isLanguageAvailable:(CDVInvokedUrlCommand*)command {
    int retValue = 0;

    NSString* txtLocale = [command.arguments objectAtIndex:0];
    txtLocale = [txtLocale stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    NSArray *localeParts = [txtLocale componentsSeparatedByString:@"-"];
    txtLocale = [NSString stringWithFormat:@"%@-%@", [[localeParts objectAtIndex:0] lowercaseString], [[localeParts objectAtIndex:0] uppercaseString]];

    NSArray* speechVoices = [AVSpeechSynthesisVoice speechVoices];

    for (id voice in speechVoices) {
        if ([txtLocale compare:[voice language] options:NSCaseInsensitiveSearch]) {
            retValue = 1;
            break;
        }
    }
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:retValue];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setLanguage:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* result = nil;
    
    NSString* txtLocale = [command.arguments objectAtIndex:0];
    txtLocale = [txtLocale stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    NSArray *localeParts = [txtLocale componentsSeparatedByString:@"-"];
    txtLocale = [NSString stringWithFormat:@"%@-%@", [[localeParts objectAtIndex:0] lowercaseString], [[localeParts objectAtIndex:0] uppercaseString]];
    
    id testVoice = [AVSpeechSynthesisVoice voiceWithLanguage:txtLocale];
    if (testVoice != nil) {
        locale = txtLocale;
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Sorry, locale not avaliable"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
