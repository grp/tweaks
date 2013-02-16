

#import <QuartzCore/QuartzCore.h>

@interface CASpringAnimation : CABasicAnimation
@property (nonatomic, assign) CGFloat mass;
@property (nonatomic, assign) CGFloat stiffness;
@property (nonatomic, assign) CGFloat damping;
@property (nonatomic, assign) CGFloat velocity;
@end

static NSDictionary *preferences = nil;

static NSNumberFormatter *formatter = nil;


static CGFloat PreferencesFloat(NSString *key, CGFloat def) {
    NSString *s = [preferences objectForKey:key];

    if (s != nil) {
        NSNumber *n = [formatter numberFromString:s];

        if (n != nil) {
            CGFloat f = [n floatValue];

            if (f > 0) {
                return f;
            }
        }
    }

    return def;
}

%hook CABasicAnimation

+ (id)animationWithKeyPath:(NSString *)keyPath {
    if (self == [CABasicAnimation class]) {
        CASpringAnimation *spring = [CASpringAnimation animationWithKeyPath:keyPath];
        [spring setMass:PreferencesFloat(@"Mass", 1.0)];
        [spring setStiffness:PreferencesFloat(@"Stiffness", 300.0)];
        [spring setDamping:PreferencesFloat(@"Damping", 30.0)];
        [spring setVelocity:PreferencesFloat(@"Velocity", 20.0)];
        return spring;
    } else {
        return %orig;
    }
}

- (void)setDuration:(NSTimeInterval)duration {
    %orig(duration * PreferencesFloat(@"TimeScale", 1.5));
}

%end

#define PreferencesChangedNotification "com.chpwn.iphone.cydia.hooks-law.preferences-changed"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.chpwn.iphone.cydia.hooks-law.plist"]


static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[preferences release];
	preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}

__attribute__((constructor)) static void hookslaw_init() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

	preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);


	[pool release];
}

