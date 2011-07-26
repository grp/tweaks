

#import <UIKit/UIKit.h>

int flag = 0;

%hook UIDevice

- (int)userInterfaceIdiom {
    if (flag > 0) return UIUserInterfaceIdiomPhone;
    else return %orig;
}

%end

%hook FBApplication

- (void)loadRefresh:(BOOL)refresh chatGoOnlineDelayed:(BOOL)delayed {
    flag += 1;
    %orig;
    flag -= 1;
}

- (void)initNetworking {
    flag += 1;
    %orig;
    flag -= 1;
}

%end

%hook FBAppRequest

+ (id)request {
    flag += 1;
    id ret = %orig;
    flag -= 1;
    return ret;
}

%end

%hook FBSession

- (void)convertSessionKeyToAccessToken {
    flag -= 1;
    %orig;
    flag += 1;
}

%end

%hook FBAPIRequest

+ (NSString *)apiSecret {
    // iphone api secret
    return @"c1e620fa708a1d5696fb991c1bde5662";

    // ipad api secret
    return @"7c036d47372dd5f2df27bfe76d4ae0c4";
}

+ (NSString *)apiKey {
    // iphone api key
    return @"3e7c78e35a76a9299309885393b02d97";

    // ipad api key
    return @"f0c9c86c466dc6b5acdf0b35308e83d1";
}

%end


%ctor {
}


