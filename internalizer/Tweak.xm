
#define PreferencesChangedNotification "com.chpwn.internalizer.prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.chpwn.internalizer.plist"]

static NSDictionary *preferences = nil;

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[preferences release];
	preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}

%hook SBLockdownManager
- (BOOL) isInternalInstall { %log; return YES; }
%end

%hook SBPlatformController
- (BOOL)allowSensitiveUI:(BOOL)ui hasInternalBundle:(BOOL)bundle { %log; return YES; }
- (BOOL)isCarrierInstall:(BOOL)install hasInternalBundle:(BOOL)bundle { %log; return YES; }
- (BOOL)isInternalInstall { %log; return YES; }
- (BOOL)isCarrierInstall { %log; return YES; }
%end

%hook NSBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    // this is the order they are shown on the lockscreen
    if ([key isEqual:@"INTERNAL_INSTALL_LEGAL_DECLARATION"]) return [preferences objectForKey:@"InternalizerDeclaration"] ?: @"Change this";
    if ([key isEqual:@"INTERNAL_INSTALL_LEGAL_INSTRUCTIONS"]) return [preferences objectForKey:@"InternalizerInstructions"] ?: @"text in the";
    if ([key isEqual:@"INTERNAL_INSTALL_LEGAL_CONTACT"]) return [preferences objectForKey:@"InternalizerContact"] ?: @"Settings app";

    return %orig;
}

%end

__attribute__((constructor)) static void internalizer_init() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);

	[pool release];
}

