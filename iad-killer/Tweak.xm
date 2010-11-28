// iAdKiller
// by chpwn


#include <substrate.h>

%hook ADManager

+ (id)alloc {
	return nil;
}

%end