import 'package:arcadia_mobile/src/components/operator_qr_cod_widget.dart';
import 'package:arcadia_mobile/src/components/qr_code_widget.dart';
import 'package:arcadia_mobile/src/notifiers/user_change_notifier.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:arcadia_mobile/src/structure/view_types.dart';
import 'package:arcadia_mobile/src/views/qrcode/my_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QRCodeScreen extends StatefulWidget {
  final ViewType viewType;
  final MatchDetails? matchDetails;
  final String? bountyId;
  const QRCodeScreen(
      {super.key, required this.viewType, this.matchDetails, this.bountyId});

  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    userProfile =
        Provider.of<UserProfileProvider>(context, listen: false).userProfile;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Forces the AppBar to rebuild with the new title
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> tabTitles = [];
    tabTitles.add('QRCode');
    if (widget.viewType != ViewType.createMatch ||
        widget.viewType != ViewType.challengeBounty) tabTitles.add('QRCode');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          tabTitles[_tabController.index],
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight:
                FontWeight.w700, // This corresponds to font-weight: 700 in CSS
          ),
        ),
        toolbarHeight: 30.0,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: 'Scan'),
            if (widget.viewType != ViewType.createMatch ||
                widget.viewType != ViewType.challengeBounty)
              Tab(text: 'My QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: userProfile == null || userProfile?.userType == null
            ? const [
                QRScan(),
                MyQRCode(),
              ]
            : userProfile?.userType == "operator"
                ? [
                    OperatorQRScan(
                      viewType: widget.viewType,
                      bountyId: widget.bountyId,
                    ),
                    MyQRCode(),
                  ]
                : const [
                    QRScan(),
                    MyQRCode(),
                  ],
      ),
    );
  }
}
