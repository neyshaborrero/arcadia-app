import 'package:arcadia_mobile/src/notifiers/prizes_change_notifier.dart';
import 'package:arcadia_mobile/src/views/events/prize_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RaffleView extends StatefulWidget {
  const RaffleView({super.key});

  @override
  _RaffleViewState createState() => _RaffleViewState();
}

class _RaffleViewState extends State<RaffleView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Forces the AppBar to rebuild with the new title
        });
      }
    });
  }

  List<String> tabTitles = ['Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
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
          tabs: const [
            Tab(text: 'Saturday'),
            Tab(text: 'Sunday'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PrizeScreen(
            prizeList: Provider.of<PrizesChangeProvider>(context)
                .getPrizesByRaffleDate('2024-12-07'),
          ),
          PrizeScreen(
            prizeList: Provider.of<PrizesChangeProvider>(context)
                .getPrizesByRaffleDate('2024-12-08'),
          ),
        ],
      ),
    );
  }
}
