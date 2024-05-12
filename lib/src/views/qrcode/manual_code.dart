import 'package:arcadia_mobile/src/components/quests_dialogs.dart';
import 'package:flutter/material.dart';

class ManualQRCodeView extends StatefulWidget {
  const ManualQRCodeView({super.key});

  @override
  _ManualQRCodeViewState createState() => _ManualQRCodeViewState();
}

class _ManualQRCodeViewState extends State<ManualQRCodeView> {
  final TextEditingController _codeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 50),
      Text('Enter the Code manually',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(
        height: 16,
      ),
      TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: 'QR Code',
            contentPadding: EdgeInsets.fromLTRB(16, 18, 16, 18),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft:
                    Radius.circular(10), // CSS border-radius: 10px 0px 0px 0px;
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              borderSide: BorderSide.none, // CSS opacity: 0; implies no border
            ),
            fillColor: Color(0xFF2C2B2B), // Use appropriate color
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          )),
      Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                showActivityDialog(
                    context,
                    true,
                    'Quest Check-in',
                    'Won 10 tokens for checking in to Taco Bell',
                    'assets/map_icon_1.png',
                    '');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          )),
    ]);
  }
}
