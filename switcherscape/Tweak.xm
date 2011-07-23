
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

%hook SBUIController

- (BOOL)_revealSwitcher:(double)duration appOrientation:(UIInterfaceOrientation)appOrientation switcherOrientation:(UIInterfaceOrientation)switcherOrientation {
    return %orig(duration, appOrientation, appOrientation);
}

%end

@interface SBLinenView : UIView {}
@end

%hook SBAppSwitcherBarView

- (id)initWithFrame:(CGRect)frame {
    self = %orig;

    // this stupidiy is necessary because Apple limits SBLinenView to 320px wide on iPhone

    SBLinenView *linen = nil;

    linen = [[objc_getClass("SBLinenView") alloc] initWithFrame:CGRectMake(0, 0, 320.0f, [self bounds].size.height)];
    [linen setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self addSubview:linen];
    [self sendSubviewToBack:linen];
    [linen release];

    linen = [[objc_getClass("SBLinenView") alloc] initWithFrame:CGRectMake(0, 0, 320.0f, [self bounds].size.height)];
    [linen setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self addSubview:linen];
    [self sendSubviewToBack:linen];
    [linen release];

    return self;
}

%end


