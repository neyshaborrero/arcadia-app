// import 'package:flutter_driver/flutter_driver.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   group('App Test', () {
//     FlutterDriver driver;

//     setUpAll(() async {
//       driver = await FlutterDriver.connect();
//     });

//     tearDownAll(() async {
//       if (driver != null) {
//         driver.close();
//       }
//     });

//     test('take screenshot of start screen', () async {
//       await driver.waitFor(find.byType('StartScreen'));
//       await driver.screenshot(
//           'start_screen'); // Ensure filename is consistent and without spaces
//     });

//     test('take screenshot of details screen', () async {
//       await driver.tap(find.byValueKey('createAccountButtonKey'));
//       await driver.waitFor(find.byType('CreateAccountView'));
//       await driver.screenshot(
//           'create_account_screen'); // Ensure filename is consistent and without spaces
//     });
//   });
// }

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('App Test', () async {
    FlutterDriver driver = await FlutterDriver.connect();

    setUpAll(() async {
      //driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver.close();
    });

    test('take screenshot of start screen', () async {
      await driver.waitFor(find.byType('StartScreen'));
      await driver.screenshot();
    });

    test('take screenshot of details screen', () async {
      await driver.tap(find.byValueKey('createAccountButtonKey'));
      await driver.waitFor(find.byType('CreateAccountView'));
      await driver.screenshot();
    });
  });
}
