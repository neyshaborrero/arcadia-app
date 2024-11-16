import 'package:arcadia_mobile/src/notifiers/prizes_change_notifier.dart';
import 'package:arcadia_mobile/src/views/events/loot_prize_screen.dart';
import 'package:arcadia_mobile/src/views/events/prize_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LootView extends StatefulWidget {
  const LootView({super.key});

  @override
  _LootViewState createState() => _LootViewState();
}

class _LootViewState extends State<LootView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          'Royal Loot',
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight:
                FontWeight.w700, // This corresponds to font-weight: 700 in CSS
          ),
        ),
        toolbarHeight: 30.0,
      ),
      body: LootPrizeScreen(
        prizeList: Provider.of<PrizesChangeProvider>(context).getLootPrizes(),
      ),
    );
  }
}
