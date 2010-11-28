
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

%hook SBFolderIcon
- (void)setBadge:(id)badge { }
%end

