
#import <UIKit/UIKit.h>

@interface UISplitViewController (Private)

- (UIViewController *)masterViewController;
- (UIViewController *)detailViewController;
- (CGRect)_detailViewFrame;
- (CGRect)_masterViewFrame;

- (void)viewWillLayoutSubviews;

@end

@interface UINavigationController (Private)

- (void)_layoutTopViewController;

@end

#define kHandleWidth 16.0f

%hook UISplitViewController

- (void)setGutterWidth:(CGFloat)width {
    %log;
    %orig(kHandleWidth);
}

%new(v@:@)
- (void)panFromRecognizer:(UIPanGestureRecognizer *)recognizer {
    %log;

    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint location = [recognizer locationInView:self.view];
        CGFloat offset = location.x - (kHandleWidth / 2);

        NSLog(@"Resizing view to offset: %f", offset);
        [self setMasterColumnWidth:offset];
        if ([[self masterViewController] isKindOfClass:[UINavigationController class]])
            [(UINavigationController *) [self masterViewController] _layoutTopViewController];
        if ([[self detailViewController] isKindOfClass:[UINavigationController class]])
            [(UINavigationController *) [self detailViewController] _layoutTopViewController];
        [recognizer.view setFrame:CGRectMake(offset, 0, kHandleWidth, [self.view bounds].size.height)];
    }
}

- (void)_commonInit {
    %orig;

    [self setGutterWidth:kHandleWidth];

    UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake([self masterColumnWidth], 0, kHandleWidth, [self.view bounds].size.height)];
    [dragView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:dragView];
    [dragView release];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFromRecognizer:)];
    [dragView addGestureRecognizer:panRecognizer];
    [panRecognizer release];
}

%end


