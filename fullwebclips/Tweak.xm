
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIWebClip : NSObject { }

+ (BOOL)webClipFullScreenValueForWebDocumentView:(id)webDocumentView;
@property (assign) BOOL fullScreen;
- (void)updateOnDisk;

@end

@interface WebClipViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    UITableViewCell *_tableViewCell;
    UILabel *_infoLabel;
    UIView *_infoLabelContainer;
    BOOL _suspendAfterDismiss;
    UIWebClip *_webClip;
}

@property (retain) UIWebClip *webClip;

@end

%hook WebClipViewController

// make room for the added row on the iPad
- (CGSize)contentSizeForViewInPopoverView {
    CGSize ret = %orig;
    ret.height += 36.0f;
    return ret;
}

%new(i@:@)
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)layoutSubviews {
    %orig;

    UITableView *tableView = MSHookIvar<UITableView *>(self, "_tableView");
    [tableView setContentInset:UIEdgeInsetsZero];
}

%new(f@:@@)
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        return 44.0f;
    }

    return [tableView rowHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        UIWebClip *clip = [self webClip];

        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        [cell.textLabel setText:@"Fullscreen Web Clip"];

        if ([clip fullScreen]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }

        return cell;
    }

    return %orig;
}

%new(v@:@@)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        UIWebClip *clip = [self webClip];
        [clip setFullScreen:![clip fullScreen]];
        [clip updateOnDisk];

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([clip fullScreen]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

%end


