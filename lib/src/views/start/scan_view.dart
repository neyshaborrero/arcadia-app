import 'package:arcadia_mobile/src/components/operator_qr_cod_widget.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
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
      body: OperatorQRScan(
        viewType: ViewType.checkin,
      ),
    );
  }
}
