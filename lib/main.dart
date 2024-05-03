import 'package:flutter/material.dart';
import 'src/views/start/start_view.dart';
import 'package:provider/provider.dart';
import 'src/notifiers/change_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ClickedState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcadia Battle Royale 2024',
      theme: ThemeData(
        textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
            ),
            labelSmall: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
            labelMedium: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
            labelLarge: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700)),
        scaffoldBackgroundColor: const Color(0xFF000000),
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD20E0D),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey), // border color when focused
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFFD20E0D)),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF313131)),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        tabBarTheme: const TabBarTheme(
          labelStyle: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight
                  .w400 // Set font size for selected tab labels // and also set weight, etc., as needed
              ),
          // Style for the tab text when unselected.
          unselectedLabelStyle: TextStyle(
            fontSize: 20.0, // Set font size for unselected tab labels
          ),
          // Color for the tab text and icons when selected.
          labelColor: Color(0xFFD20E0D),
          // Color for the indicator beneath the selected tab.
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Color(0xFFD20E0D),
                  width: 2.0 // Border color Indicator thickness
                  ),
            ),
          ),
        ),
      ),
      home: const StartScreen(),
    );
  }
}
