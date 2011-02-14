
#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static BOOL really = NO;
static BOOL glock;
static BOOL gsound;

static UIWindow *back;
static UIView *white, *top, *bottom;

static void really_lock(BOOL lock, BOOL sound) {
    really = YES;
    [[objc_getClass("SBUIController") sharedInstance] lock:lock disableLockSound:sound];
    really = NO;
}

%hook SBUIController
%new(v@:)
- (void)secondPartDone {
    really_lock(glock, gsound);

    [back setHidden:YES];
    [back release];
    back = top = white = bottom = nil;
}
%new(v@:)
- (void)firstPartDone {
    [back setBackgroundColor:[UIColor blackColor]];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(secondPartDone)];

    [white setFrame:CGRectMake([back bounds].size.width / 2, 0.0f, 0.0f, [back bounds].size.height)];

    [UIView commitAnimations];
}
- (void)lock:(BOOL)lock disableLockSound:(BOOL)sound {
    if (really) {
        %orig;
    } else {
        glock = lock;
        gsound = sound;

        back = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [back setWindowLevel:UIWindowLevelStatusBar + 9001.0f];
        [back makeKeyAndVisible];

        white = [[UIView alloc] initWithFrame:[back bounds]];
        [white setBackgroundColor:[UIColor whiteColor]];
        [white setAlpha:0.0f];
        [back addSubview:white];
        [white release];

        top = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -[back bounds].size.height, [back bounds].size.width, [back bounds].size.height)];
        bottom = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [back bounds].size.height, [back bounds].size.width, [back bounds].size.height)];
        [top setBackgroundColor:[UIColor blackColor]];
        [bottom setBackgroundColor:[UIColor blackColor]];
        [back addSubview:top];
        [back addSubview:bottom];
        [top release];
        [bottom release];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(firstPartDone)];

        [top setFrame:CGRectMake(0.0f, -([back bounds].size.height / 2) - 2.0f, [back bounds].size.width, [back bounds].size.height)];
        [bottom setFrame:CGRectMake(0.0f, [back bounds].size.height / 2 + 2.0f, [back bounds].size.width, [back bounds].size.height)];
        [white setAlpha:1.0f];

        [UIView commitAnimations];
    }
}
%end

