
#import <CoreFoundation/CoreFoundation.h>
#import <substrate.h>

Boolean (*original_CFPreferencesGetAppBooleanValue)(CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat);
Boolean replaced_CFPreferencesGetAppBooleanValue(CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat) {
    if ([(NSString *)key isEqualToString:@"EnableFirebreak"]) return true;
    return original_CFPreferencesGetAppBooleanValue(key, applicationID, keyExistsAndHasValidFormat);
}

%ctor {
    MSHookFunction((void *)CFPreferencesGetAppBooleanValue, (void *)replaced_CFPreferencesGetAppBooleanValue, (void **)&original_CFPreferencesGetAppBooleanValue);
}


