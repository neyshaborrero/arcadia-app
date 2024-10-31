// lib/onboarding/onboarding_page.dart
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String? title;
  final String subtitle;
  final String? subtitle2;
  final String description;
  final String? secondaryButtonText;
  final String buttonText;
  final String imageAsset;
  final VoidCallback onButtonPressed;
  final VoidCallback onSecondaryButtonPressed;

  const OnboardingPage({
    super.key,
    this.title,
    required this.subtitle,
    this.subtitle2,
    required this.description,
    this.secondaryButtonText,
    required this.buttonText,
    required this.imageAsset,
    required this.onButtonPressed,
    required this.onSecondaryButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (title != null)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 1.0), // Adjust the top padding as needed
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 20.0,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          title!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700, // Bold text
                            color: Colors.white, // Color of the text
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              if (title != null) const SizedBox(height: 30),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) Image.asset(imageAsset, height: 200),
                  if (title == null) Image.asset(imageAsset, height: 200),
                  const SizedBox(height: 50),
                  if (title != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700, // Bold text
                        fontSize: 20,
                        color: Colors.white, // Color of the text
                      ),
                    ),
                  if (title != null) const SizedBox(height: 30),
                  if (title != null)
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white, // Color of the text
                      ),
                    ),
                ],
              ),
              if (title != null) const SizedBox(height: 90),
              if (title != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 368),
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              if (title == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2c2b2b),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle2 != null)
                        Text(
                          subtitle2!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 30),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 368),
                        child: ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Text(
                              buttonText,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      if (secondaryButtonText != null)
                        const SizedBox(height: 10),
                      if (secondaryButtonText != null)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 368),
                          child: OutlinedButton(
                            onPressed: onSecondaryButtonPressed,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: Text(
                              secondaryButtonText!,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
