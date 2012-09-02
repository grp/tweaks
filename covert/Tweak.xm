#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static id addressView = nil;
static id buttonBar = nil;
static id navbars = nil;
static id button = nil;
static NSHTTPCookieAcceptPolicy policy;
static BOOL enabled = nil;

%hook AddressView

%new(v@:cc)
- (void)setPrivate:(BOOL)priv animated:(BOOL)animated {
	UIView *bar = MSHookIvar<id>(self, "_gradientBar");
	NSArray *subs = [bar subviews];

	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
	}

	if (priv) {
		for (UIView *s in subs) {
			if ([s isKindOfClass:[UIImageView class]]) [s setAlpha:0.7f];
		}
	} else {
		for (UIView *s in subs) {
			if ([s isKindOfClass:[UIImageView class]]) [s setAlpha:1.0f];
		}
	}

	if (animated) [UIView commitAnimations];
}

- (id)initWithFrame:(CGRect)frame {
	return (addressView = %orig);
}

%end

%hook UINavigationBar

%new(v@:cc)
+ (void)setPrivate:(BOOL)priv animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
	}

	for (id nav in navbars) {
		if (priv) [nav setTintColor:[UIColor grayColor]];
		else [nav setTintColor:nil];
	}

	if (animated) [UIView commitAnimations];
}

- (id)initWithFrame:(CGRect)frame {
	self = %orig;
	[navbars addObject:self];
	[[self class] setPrivate:enabled animated:NO];
	return self;
}

- (void)dealloc {
	[navbars removeObject:self];
	%orig;
}

%end

%hook BrowserButtonBar

%new(v@:cc)
- (void)setPrivate:(BOOL)priv animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
	}

	if (priv) [self setTintColor:[UIColor grayColor]];
	else [self setTintColor:nil];

	if (animated) [UIView commitAnimations];
}

- (void)setFrame:(CGRect)frame {
	%orig;

	// XXX: i fail, and i know it
	if (frame.size.height < 44.0f)
		[button setFrame:CGRectMake(180.0f, 5.0f, 120.0f, 24.0f)];
	else
		[button setFrame:CGRectMake(112.0f, 8.0f, 120.0f, 30.0f)];
}

%end

%hook WebHistory

// XXX: (jedi mind trick:) you did /not/ see this
- (void)_visitedURL:(NSURL *)url withTitle:(NSString *)title method:(NSString *)method wasFailure:(BOOL)wasFailure increaseVisitCount:(BOOL)increaseVisitCount {
	if (!enabled) %orig;
}

%end

%hook BrowserController

%new(c@:)
- (BOOL)covertEnabled {
	return enabled;
}

- (void)addRecentSearch:(id)search {
	if (!enabled) %orig;
}

- (void)setShowingTabs:(BOOL)tabs {
	%orig;

	if (tabs) [buttonBar addSubview:button];
	else [button removeFromSuperview];
}

%end

%hook Application

%new(v@:)
- (void)togglePrivate {
	enabled = !enabled;

	if (enabled) {
		policy = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookieAcceptPolicy];
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
		[[NSUserDefaults standardUserDefaults] setInteger:policy forKey:@"CovertCookiePolicy"];
	} else {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:policy];
	}

	if (enabled) {
		[button setStyle:(UIBarButtonItemStyle)2];
		[button setTitle:@"Exit Private" forState:UIControlStateNormal];
	} else {
		[button setStyle:(UIBarButtonItemStyle)0];
		[button setTitle:@"Private Browsing" forState:UIControlStateNormal];

		[MSHookIvar<id>(addressView, "_searchTextField") setText:@""];
	}

	[buttonBar setPrivate:enabled animated:YES];
	[addressView setPrivate:enabled animated:YES];
	[UINavigationBar setPrivate:enabled animated:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	%orig;

	[[NSUserDefaults standardUserDefaults] setInteger:policy forKey:@"CovertCookiePolicy"];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:policy];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	%orig;

    navbars = [[NSMutableArray alloc] init];
	buttonBar = [[%c(BrowserController) sharedBrowserController] buttonBar];

	if ([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"CovertCookiePolicy"]) {
		policy = [[NSUserDefaults standardUserDefaults] integerForKey:@"CovertCookiePolicy"];
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:policy];
	} else {
		policy = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookieAcceptPolicy];
		[[NSUserDefaults standardUserDefaults] setInteger:policy forKey:@"CovertCookiePolicy"];
	}

	button = [[%c(UINavigationButton) alloc] initWithTitle:@"Private Browsing"];
	[button addTarget:self action:@selector(togglePrivate) forControlEvents:UIControlEventTouchUpInside];
	[buttonBar setFrame:[buttonBar frame]];
}
%end

