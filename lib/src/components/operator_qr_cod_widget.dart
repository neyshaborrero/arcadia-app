import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/hub_checkin.dart';
import 'package:arcadia_mobile/src/structure/location.dart';
import 'package:arcadia_mobile/src/structure/badrequest_exception.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/tools/location.dart';
import 'package:arcadia_mobile/src/views/matches/match_activity.dart';
import 'package:arcadia_mobile/src/views/qrcode/manual_code.dart';
import 'package:arcadia_mobile/src/views/start/scan_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

class OperatorQRScan extends StatefulWidget {
  final ViewType viewType;
  final String? bountyId;
  const OperatorQRScan({super.key, required this.viewType, this.bountyId});

  @override
  _OperatorQRScanState createState() => _OperatorQRScanState();
}

class _OperatorQRScanState extends State<OperatorQRScan> {
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
                  operatorScan: true,
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
                  const SizedBox(
                    height: 40,
                  )
                ]))
    ]);
  }

  Future<void> _validateQRCode(String code, String? bountyId) async {
    try {
      AppLocation? location = await getCurrentLocation();
      if (location != null) {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final String? token = await user.getIdToken();
          if (token != null) {
            if (widget.viewType == ViewType.challengeBounty) {
              final String responseuid =
                  await _arcadiaCloud.fetchUserUID(code, token);

              if (responseuid.isNotEmpty) {
                final String responseBounty = await _arcadiaCloud
                    .requestBountyChallenge(token, bountyId ?? '', responseuid);
                if (responseBounty.isNotEmpty) {
                  Navigator.of(context).pop(responseBounty);
                  return;
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'We couldnt validate the QR Code, try another one.')),
              );
            } else if (widget.viewType == ViewType.createMatch) {
              final String response =
                  await _arcadiaCloud.fetchUserUID(code, token);
              if (response.isNotEmpty) {
                Navigator.of(context).pop(response);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'We couldnt validate the QR Code, try another one.')),
                );
              }
            } else {
              final HubCheckin response =
                  await _arcadiaCloud.validateOperatorQRCode(code, token);

              if (response.hubId.isNotEmpty) {
                Provider.of<UserProfileProvider>(context, listen: false)
                    .updateOperatorCheckIn(response.hubId);
                _goToOperatorView(token, response.hubId);
              }

              return;
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('We couldnt validate the QR Code, try another one.')),
      );
    } finally {
      setState(() {
        isScanning = true;
      });

      await Future.delayed(const Duration(seconds: 5));
      Navigator.of(context).pop();
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

          if (uri.queryParameters['userqr'] != null) {
            return uri.queryParameters['userqr'];
          } else if (uri.queryParameters['hubid'] != null) {
            return uri.queryParameters['hubid'];
          } else {
            return scannedCode;
          }
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
          _validateQRCode(userQR, widget.bountyId);
        } else {
          print("scanned qr $scannedCode");
          if (scannedCode != null) _validateQRCode(scannedCode!, null);
          print('Invalid QR code or missing parameter.');
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _goToOperatorView(String token, String hubId) async {
    Hub? hub = await _arcadiaCloud.getHubDetails(hubId, token);
    if (hub != null) {
      if (hub.type != 'checkin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => GameActivityView(
                    hubId: hubId,
                    hubDetails: hub,
                  )),
        );
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ScanView(
            appBarTitle: "Check In to Arcadia Battle Royale",
          ),
        ));
      }
    } else {
      return;
    }
  }
}
