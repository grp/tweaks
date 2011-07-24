
#import <UIKit/UIKit.h>
#import <GraphicsServices/GraphicsServices.h>
#import <objc/runtime.h>

@protocol CQTextCompletionViewDelegate;

@interface CQTextCompletionView : UIView {
	@protected
	IBOutlet id <CQTextCompletionViewDelegate> delegate;
	CGSize _completionTextSizes[5];
	NSUInteger _selectedCompletion;
	NSArray *_completions;
}
@property (nonatomic, copy) NSArray *completions;
@property (nonatomic) NSUInteger selectedCompletion;
@property (nonatomic, getter=isCloseSelected) BOOL closeSelected;

@property (nonatomic, assign) id <CQTextCompletionViewDelegate> delegate;
@end

@protocol CQTextCompletionViewDelegate <NSObject>
@optional
- (void) textCompletionView:(CQTextCompletionView *) textCompletionView didSelectCompletion:(NSString *) completion;
- (void) textCompletionViewDidClose:(CQTextCompletionView *) textCompletionView;
@end

static CQTextCompletionView *currentCompletionView = nil;

%hook CQTextCompletionView

- (id)initWithFrame:(CGRect)frame {
    if ((self = %orig)) {
        currentCompletionView = self;
    }

    return self;
}

- (void)dealloc {
    currentCompletionView = nil;
    %orig;
}

%end

%hook UIApplication

- (void)_handleKeyEvent:(GSEventRef)event {
    %orig;

    if (GSEventIsTabKeyEvent(event)) {
        NSString *completion = [currentCompletionView.completions count] ? [currentCompletionView.completions objectAtIndex:0] : nil;

        if (completion != nil) {
            [currentCompletionView.delegate textCompletionView:currentCompletionView didSelectCompletion:completion];
        }
    }
}

%end

