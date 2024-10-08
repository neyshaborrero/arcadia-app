import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/components/ads_carousel.dart';
import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:arcadia_mobile/src/notifiers/activity_change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/change_notifier.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/routes/slide_up_route.dart';
import 'package:arcadia_mobile/src/structure/location.dart';
import 'package:arcadia_mobile/src/structure/badrequest_exception.dart';
import 'package:arcadia_mobile/src/structure/user_activity.dart';
import 'package:arcadia_mobile/src/tools/location.dart';
import 'package:arcadia_mobile/src/views/qrcode/manual_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

import '../structure/view_types.dart';

class QRScan extends StatefulWidget {
  const QRScan({super.key});

  @override
  _QRScanState createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  bool isManual = false;
  String? scannedCode;
  bool isDialogShown = false;
  late final ArcadiaCloud _arcadiaCloud;

  @override
  void initState() {
    super.initState();
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    _arcadiaCloud = ArcadiaCloud(firebaseService);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: isManual
              ? const ManualQRCodeView(
                  operatorScan: false,
                )
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("Scan the QR Code",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xA6A6A680), // Dark background color
                          ),
                          child: QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                            overlay: QrScannerOverlayShape(
                              borderColor: Colors.red,
                              borderRadius: 10,
                              borderLength: 30,
                              borderWidth: 10,
                              cutOutSize:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Arcadia needs to access your location when completing quests. Make sure you approve your location to Arcadia.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => setState(() => isManual = !isManual),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 48, vertical: 16),
                          child: Text(
                            'Enter Manually',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const AdsCarouselComponent(
                    viewType: ViewType.qrscan,
                  ),
                  const SizedBox(
                    height: 40,
                  )
                ]))
    ]);
  }

  Future<void> _validateQRCode(code) async {
    try {
      AppLocation? location = await getCurrentLocation();
      if (location != null) {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final String? token = await user.getIdToken();
          if (token != null) {
            final UserActivity? response =
                await _arcadiaCloud.validateQRCode(code, token, location);

            if (response != null) {
              final userProfileProvider =
                  Provider.of<UserProfileProvider>(context, listen: false);
              userProfileProvider.updateTokens(response.value);
              Provider.of<UserActivityProvider>(context, listen: false)
                  .addUserActivity(response);
              Provider.of<ClickedState>(context, listen: false)
                  .toggleClicked(response.qrcode);

              showActivityDialog(
                      context,
                      response.id,
                      true,
                      true,
                      response.title,
                      response.description,
                      response.imageComplete,
                      response.imageComplete,
                      null)
                  .then((result) {
                if (response.streak != null && response.streak! > 1) {
                  showActivityDialog(
                          context,
                          response.id,
                          true,
                          true,
                          response.title,
                          response.description,
                          response.imageComplete,
                          response.imageComplete,
                          response.streak)
                      .then((result) {
                    Navigator.of(context).pop();
                  });
                } else {
                  Navigator.of(context).pop();
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'We couldnt validate the QR Code, try another one.')),
              );

              await Future.delayed(const Duration(seconds: 5));
              Navigator.of(context).pop();
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Enable location sharing for Arcadia to be able to scan QR Codes.')),
        );
      }
    } on BadRequestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );

      await Future.delayed(const Duration(seconds: 5));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('We couldnt validate the QR Code, try another one.')),
      );

      await Future.delayed(const Duration(seconds: 5));
      Navigator.of(context).pop();
    } finally {
      setState(() {
        isScanning = true;
      });
    }
  }

  // Function to extract 'userqr' value from the scanned URL
  String? _getUserQRFromLink(String? scannedCode) {
    if (scannedCode != null && scannedCode.isNotEmpty) {
      try {
        // Parse the scanned deep link URL
        final uri = Uri.parse(scannedCode);

        // Check if the parsed URI has a valid scheme (http or https) and is not null
        if ((uri.scheme == 'http' || uri.scheme == 'https')) {
          // Retrieve the 'userqr' parameter from the query parameters, if available
          return uri.queryParameters['userqr'];
        } else {
          return scannedCode;
        }
      } catch (e) {
        print('Error parsing QR code URL: $e');
        return null;
      }
    }
    return null;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isDialogShown) {
        setState(() {
          scannedCode = scanData.code;
          isScanning = false; // Stop scanning after the first scan
          isDialogShown = true;
        });

        // Vibrate the device if the vibrator is available
        bool isVibratorAvailable = await Vibration.hasVibrator() ?? false;
        if (isVibratorAvailable) {
          Vibration.vibrate();
        }

        // Extract the value of 'userqr' from the deep link
        final userQR = _getUserQRFromLink(scannedCode);

        // Pass the extracted userQR value to the validation function
        if (userQR != null) {
          _validateQRCode(userQR);
        } else {
          print('Invalid QR code or missing userqr parameter.');
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _navigateUpWithSlideTransition(BuildContext context, Widget page) {
    Navigator.of(context).push(SlideFromBottomPageRoute(page: page));
  }
}
