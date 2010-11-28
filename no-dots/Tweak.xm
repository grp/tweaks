
%hook SBIconListPageControl
- (id)initWithFrame:(CGRect)frame { [%orig release]; return nil; }
%end


