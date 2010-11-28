#include <SpringBoard/SpringBoard.h>

%hook SBIconBadge
- (id)initWithBadgeString:(id)string { return nil; }
- (id)initWithFrame:(CGRect)frame { return nil; }
%end


