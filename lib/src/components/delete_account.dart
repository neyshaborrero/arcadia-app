import 'package:arcadia_mobile/services/arcadia_cloud.dart';
import 'package:flutter/material.dart';

Future<bool?> showDeleteAccount(
  BuildContext context,
  String userToken,
  String title,
  String description,
  int tokens,
  ArcadiaCloud arcadiaCloud,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        child: SingleChildScrollView(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.transparent, // Background color
            ),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Makes the column wrap its content
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD20E0D),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // Use MainAxisSize.min to wrap content in the column.
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight
                                  .w700, // This corresponds to font-weight: 700 in CSS
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Image.asset(
                              'assets/no_connection.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight
                                  .w600, // This corresponds to font-weight: 700 in CSS
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          if (tokens != 0)
                            Text(
                              'Remember you would lose the $tokens tokens you earned for the event',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight
                                    .w700, // This corresponds to font-weight: 700 in CSS
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 48),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(false); // Close the dialog and return false
                        },
                        child: const Text('No'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 48),
                          backgroundColor: const Color(0xFF313131),
                        ),
                        onPressed: () {
                          arcadiaCloud.deleteUser(userToken).then((response) {
                            if (response['success']) {
                              Navigator.of(context).pop(
                                  true); // Close the dialog and return true
                            } else {
                              print(
                                  "Error deleting account: ${response['message']}");
                              Navigator.of(context).pop(
                                  false); // Close the dialog and return false
                            }
                          }).catchError((error) {
                            print("Exception occurred: $error");
                            Navigator.of(context).pop(
                                false); // Close the dialog and return false
                          });
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
