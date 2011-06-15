%hook SBLockdownManager
- (BOOL) isInternalInstall { %log; return YES; }
%end
%hook SBPlatformController
- (BOOL)allowSensitiveUI:(BOOL)ui hasInternalBundle:(BOOL)bundle { %log; return YES; }
- (BOOL)isCarrierInstall:(BOOL)install hasInternalBundle:(BOOL)bundle { %log; return YES; }
- (BOOL)isInternalInstall { %log; return YES; }
- (BOOL)isCarrierInstall { %log; return YES; }
%end
