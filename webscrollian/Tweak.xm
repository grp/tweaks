
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

%hook UIWebBrowserView

+ (CGFloat)preferredScrollDecelerationFactor {
    return 0.998;
}

%end



