
@interface SBApplication : NSObject { }

- (BOOL)isClassic;
- (BOOL)isActuallyClassic;
- (NSString *)displayIdentifier;

@end


%hook SBApplication

- (BOOL)isClassic {
    if ([[self displayIdentifier] isEqual:@"com.facebook.Facebook"]) return NO;
    else return %orig;
}

- (BOOL)isActuallyClassic {
    return [self isClassic];
}

%end


