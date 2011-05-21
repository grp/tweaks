
#import <UIKit/UIKit.h>

%hook ABUITableViewDisruptorController
- (id)initWithTableView:(id)tv { return nil; }
%end

%hook TweetieStatusListViewController
- (void)addDisruptorInset { }
- (BOOL)shouldShowDisruptor { return NO; }
%end

