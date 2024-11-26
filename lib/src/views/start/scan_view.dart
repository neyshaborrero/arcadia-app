import 'package:arcadia_mobile/src/components/qr_code_widget.dart';
import 'package:flutter/material.dart';

class ScanView extends StatelessWidget {
  final String appBarTitle;
  const ScanView({
    super.key,
    required this.appBarTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: QRScan(),
    );
  }
}
