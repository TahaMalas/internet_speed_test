#import "InternetSpeedTestPlugin.h"
#if __has_include(<internet_speed_test/internet_speed_test-Swift.h>)
#import <internet_speed_test/internet_speed_test-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "internet_speed_test-Swift.h"
#endif

@implementation InternetSpeedTestPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftInternetSpeedTestPlugin registerWithRegistrar:registrar];
}
@end
