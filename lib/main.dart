import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:daily_exposures/features/home/home_screen.dart';
import 'package:flutter/material.dart';

final ValueNotifier<bool> isDarkMode = ValueNotifier(true);
final ValueNotifier<bool> isLeftHandedMode = ValueNotifier(false);

void main() {
  runApp(const DailyExposures());
}

class DailyExposures extends StatelessWidget {
  const DailyExposures({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return MaterialApp(
          themeMode: value ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            appBarTheme: const AppBarTheme(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: Sizes.size16,
                fontWeight: Fonts.weightBold,
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: Sizes.size16,
                fontWeight: Fonts.weightBold,
              ),
            ),
          ),
          home: Home(),
        );
      },
    );
  }
}
