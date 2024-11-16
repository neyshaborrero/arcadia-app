import 'dart:async';

import 'package:flutter/material.dart';

class BountyCountdownWidget extends StatefulWidget {
  final int expirationTimestamp;

  const BountyCountdownWidget({Key? key, required this.expirationTimestamp})
      : super(key: key);

  @override
  _BountyCountdownWidgetState createState() => _BountyCountdownWidgetState();
}

class _BountyCountdownWidgetState extends State<BountyCountdownWidget> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();

    // Calculate the initial time remaining based on the expiration timestamp
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = widget.expirationTimestamp - now;
    _timeLeft = Duration(milliseconds: difference);

    // Start a timer that ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeLeft.inSeconds > 0
          ? "Expires in: ${formatDuration(_timeLeft)}"
          : "Expired",
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
