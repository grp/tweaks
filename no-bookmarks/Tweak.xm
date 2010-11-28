
#import <UIKit/UIKit.h>

static BOOL disableBookmarksFlag = 0;

%hook BrowserController
- (void)setupWithURL:(id)url {
	disableBookmarksFlag = YES;
	%orig;
	disableBookmarksFlag = NO;
}
- (void)toggleBookmarksFromButtonBar { 
	if (!disableBookmarksFlag) %orig;
}
%end

