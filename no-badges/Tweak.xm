
#import <UIKit/UIKit.h>

// iOS 4
%hook SBIconBadge
- (id)initWithBadgeString:(id)string { return nil; }
- (id)initWithFrame:(CGRect)frame { return nil; }
%end

// iOS 5
%hook SBIcon
- (id)badgeNumberOrString { return nil; }
%end

