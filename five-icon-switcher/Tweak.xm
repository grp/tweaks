
#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>

#define idForKeyWithDefault(dict, key, default)	 ([(dict) objectForKey:(key)]?:(default))
#define floatForKeyWithDefault(dict, key, default)   ({ id _result = [(dict) objectForKey:(key)]; (_result)?[_result floatValue]:(default); })
#define NSIntegerForKeyWithDefault(dict, key, default) (NSInteger)({ id _result = [(dict) objectForKey:(key)]; (_result)?[_result integerValue]:(default); })
#define BOOLForKeyWithDefault(dict, key, default)    (BOOL)({ id _result = [(dict) objectForKey:(key)]; (_result)?[_result boolValue]:(default); })

#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.chpwn.five-icon-switcher.plist"]
#define PreferencesChangedNotification "com.chpwn.five-icon-switcher.prefs"

#define GetPreference(name, type) type ## ForKeyWithDefault(prefsDict, @#name, (name))

@interface SBAppSwitcherBarView : UIView { }
+ (unsigned)iconsPerPage:(int)page;
- (CGPoint)_firstPageOffset;
- (CGPoint)_firstPageOffset:(CGSize)size;
- (CGRect)_frameForIndex:(unsigned)index withSize:(CGSize)size;
- (CGRect)_iconFrameForIndex:(unsigned)index withSize:(CGSize)size;
@end

static NSDictionary *prefsDict = nil;

static void preferenceChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[prefsDict release];
	prefsDict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}

CGRect make_frame(SBAppSwitcherBarView *self, int index, CGSize size, CGRect orig) {
    CGRect r = orig;

	int page = index / [[self class] iconsPerPage:0];
	CGFloat gap = ([self frame].size.width - (r.size.width * [[self class] iconsPerPage:0])) / ([[self class] iconsPerPage:0] + 1);
	r.origin.x = gap;

    if ([self respondsToSelector:@selector(_firstPageOffset)]) r.origin.x += [self _firstPageOffset].x;
    else r.origin.x += [self _firstPageOffset:[self frame].size].x;
	r.origin.x += (gap + size.width) * index;
	r.origin.x += (gap * page);
	r.origin.x = floorf(r.origin.x);

	return r;
}

%hook SBAppSwitcherBarView

+ (unsigned int)iconsPerPage:(int)page {
	return [[prefsDict objectForKey:@"FISIconCount"] intValue] ?: 5;
}

// 4.0 and 4.1
- (CGRect)_frameForIndex:(unsigned)index withSize:(CGSize)size {
    return make_frame(self, index, size, %orig);
}

- (CGPoint)_firstPageOffset:(CGSize)offset {
    %log;
    return %orig;
}

// 4.2
- (CGRect)_iconFrameForIndex:(unsigned)index withSize:(CGSize)size {
    return make_frame(self, index, size, %orig);
}


%end

__attribute__((constructor)) static void fis_init() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// SpringBoard only!
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		return;

	prefsDict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);

	[pool release];
}
