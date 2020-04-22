# internet_speed_test

Internet speed test plugin to integrate it in your app whenever you want.

## Get started

### Add dependency

```yaml
dependencies:
  internet_speed_test: ^1.0.1
```

### Example

```dart

  import 'package:internet_speed_test/internet_speed_test.dart';

  final internetSpeedTest = InternetSpeedTest();

  internetSpeedTest.startDownloadTesting(
     onDone: (double transferRate, SpeedUnit unit) {
        // TODO: Change UI
     },
     onProgress: (double percent, double transferRate, SpeedUnit unit) {
        // TODO: Change UI
     },
     onError: (String errorMessage, String speedTestError) {
        // TODO: Show toast error
     },
   );



  internetSpeedTest.startUploadTesting(
     onDone: (double transferRate, SpeedUnit unit) {
       print('the transfer rate $transferRate');
       setState(() {
         // TODO: Change UI
       });
     },
     onProgress: (double percent, double transferRate, SpeedUnit unit) {
       print(
           'the transfer rate $transferRate, the percent $percent');
       setState(() {
         // TODO: Change UI
       });
     },
     onError: (String errorMessage, String speedTestError) {
       // TODO: Show toast error
     },
  );

```

### Platforms

This packages only supports Android for now, very soon will be implemented for iOS devices.

### Shoutout

Shoutout to [JSpeedTest](https://github.com/bertrandmartel/speed-test-lib)

