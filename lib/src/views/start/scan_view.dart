import 'package:arcadia_mobile/src/components/operator_qr_cod_widget.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:flutter/material.dart';

class ScanView extends StatelessWidget {
  final String appBarTitle;
  final bool disableBack;
  const ScanView({
    super.key,
    required this.appBarTitle,
    required this.disableBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !disableBack,
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
