

static int enabled = 1;
static NSMutableArray *appstack = [[NSMutableArray alloc] init];
static id toapp = nil;

static void SlideToApp(NSString *identifier) {
    id app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:identifier];
    [[objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:app];
}

static NSString *Previous(NSArray *element) {
    return [element objectAtIndex:0];
}

static NSString *Next(NSArray *element) {
    return [element objectAtIndex:1];
}

static NSArray *Make(NSString *previous, NSString *next) {
    return [NSArray arrayWithObjects:previous, next, nil];
}

%hook SBAppSwitcherController
- (void)iconTapped:(id)icon {
    // don't slide if you tapped it in the switcher
    enabled -= 1;
    %orig;
}
%end

%hook SBUIController
- (void)_beginAppToAppTransition:(id)appTransition to:(id)to {
    // capture the to app here to avoid the weird
    // issue below with the _toApplication ivar
    toapp = to;
    %orig;
}
%end

%hook SBAppDosadoView
- (void)_beginTransition {
    if (enabled <= 0) {
        // after a non-enabled transition, drop all
        // state so we don't try and go back from that
        // or something equally weird like that.

        enabled = 1;
        [appstack removeAllObjects];

        %orig;
        return;
    }

    UIView *from = MSHookIvar<UIView *>(self, "_fromView");
    UIView *to = MSHookIvar<UIView *>(self, "_toView");
    id fromapp = MSHookIvar<id>(self, "_fromApplication");
    //id toapp = MSHookIvar<id>(self, "_toApplication"); // why is this nil here?

    BOOL downwards = NO;

    if ([appstack count] > 0 && [Previous([appstack lastObject]) isEqual:[toapp displayIdentifier]]) {
        [appstack removeLastObject];
        downwards = YES;
    } else {
        [appstack addObject:Make([[fromapp displayIdentifier] copy], [[toapp displayIdentifier] copy])];
        downwards = NO;
    }

    [self addSubview:(downwards ? to : from)];
    [self addSubview:(downwards ? from : to)];

    CGRect start;
    start.origin = CGPointMake(0, downwards ? 0 : [to bounds].size.height);
    start.size = [to bounds].size;
    [(downwards ? from : to) setFrame:start];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_animationDidStop:)];

    CGRect done;
    done.origin = CGPointMake(0, downwards ? [to bounds].size.height : 0);
    done.size = [to bounds].size;
    [(downwards ? from : to) setFrame:done];

    [UIView commitAnimations];

    // reset enabled state for next time
    enabled = 1;
}
%end

// workaround some weird activator bug where it gives me
// the same exact event twice in a row. wtf?
static BOOL ignore = NO;

@interface AppSlideActivator : NSObject { }
@end

@implementation AppSlideActivator
- (void)stopIgnoring {
    ignore = NO;
}
- (void)activator:(id)activator receiveEvent:(id)event {
    if (ignore) {
        [event setHandled:YES];
        return;
    }

    if (Previous([appstack lastObject]) != nil) {
        SlideToApp(Previous([appstack lastObject]));
        [event setHandled:YES];
        ignore = YES;
        [self performSelector:@selector(stopIgnoring) withObject:nil afterDelay:0.6f];
    }
}
@end

__attribute__((constructor)) static void init() {
    // make sure activator is loaded
    dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);

    static AppSlideActivator *listener = nil;
    listener = [[AppSlideActivator alloc] init];

    // default to single home button press
    id la = [objc_getClass("LAActivator") sharedInstance];
    if ([la respondsToSelector:@selector(hasSeenListenerWithName:)] && [la respondsToSelector:@selector(assignEvent:toListenerWithName:)])
        if (![la hasSeenListenerWithName:@"com.chpwn.appslide"])
            [la assignEvent:[objc_getClass("LAEvent") eventWithName:@"libactivator.menu.press.single"] toListenerWithName:@"com.chpwn.appslide"];

    // register our listener. do this after the above so it still hasn't "seen" us if this is first launch
    [[objc_getClass("LAActivator") sharedInstance] registerListener:listener forName:@"com.chpwn.appslide"];

    %init;
}

