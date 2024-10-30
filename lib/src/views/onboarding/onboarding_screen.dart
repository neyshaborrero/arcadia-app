// lib/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'onboarding_page.dart';
import 'onboarding_manager.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      OnboardingPage(
        title: "Welcome to",
        subtitle: "Where is all about the fun of the game!",
        description:
            "Start earning TOKENS now and get ready to use them at the Arcadia Battle Royale gaming event—a day of fun for everyone!",
        buttonText: "Start Collecting Tokens",
        imageAsset: "assets/2024_Logo-B.png",
        onButtonPressed: _nextPage,
        onSecondaryButtonPressed: () {
          // Action for secondary button
        },
      ),
      OnboardingPage(
        subtitle: "START ACUMMULATING",
        subtitle2: 'TOKENS',
        description:
            "Earn tokens by visiting participating stores like Taco Bell and Claro, and find out how you could win up to 30,000 tokens! Plus, keep an eye out for Hambo to earn even more tokens. Start exploring and collecting tokens today!",
        buttonText: "What are the tokens for?",
        imageAsset: "assets/tokenization_onboarding.png",
        onButtonPressed: _nextPage,
        onSecondaryButtonPressed: () {
          // Action for secondary button
        },
      ),
      OnboardingPage(
        subtitle: "IN THE ARCADIA EVENT",
        subtitle2: 'USE YOUR TOKENS!',
        description:
            "Exchange your tokens for chances to win amazing prizes like a Digital PS5 or a game room makeover. Just remember—a ticket to the Arcadia Battle Royale event unlocks all the prizes, so don’t lose your tokens!",
        buttonText: "Buy Ticket to Arcadia",
        imageAsset: "assets/prize_onboarding.png",
        onButtonPressed: _finishOnboarding,
        onSecondaryButtonPressed: () {
          // Action for secondary button
        },
      ),
    ]);
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<void> _finishOnboarding() async {
    launchUrl(Uri.parse('https://prticket.sale/ARCADIA'));
    final manager = OnboardingManager();
    await manager.setOnboardingSeen();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 80.0, left: 16.0), // Align dots to start
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align to the start (left side)
              children: List.generate(
                _pages.length,
                (index) => buildDot(index, context),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 16.0 : 12.0,
      height: _currentPage == index ? 16.0 : 12.0,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFFD20E0D)
            : Colors
                .transparent, // Filled for current, transparent for inactive
        shape: BoxShape.circle,
        border: Border.all(
          color: _currentPage == index
              ? Colors.transparent
              : Colors.grey, // Grey border for inactive dots
          width: 1.5, // Adjust border width as needed
        ),
      ),
    );
  }
}
