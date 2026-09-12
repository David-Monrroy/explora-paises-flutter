import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../data/repositories/country_repository.dart';
import '../data/services/rest_countries_service.dart';
import '../presentation/screens/countries_screen.dart';

class ExploreCountriesApp extends StatelessWidget {
  const ExploreCountriesApp({super.key, this.repository});

  final CountryRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: AppConstants.navigationColor,
          indicatorColor: AppConstants.navigationIndicatorColor,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      builder: (context, child) {
        if (MediaQuery.sizeOf(context).width <= AppConstants.maxMobileWidth) {
          return child!;
        }
        return ColoredBox(
          color: const Color(0xFFE5ECE8),
          child: Center(
            child: SizedBox(
              width: AppConstants.maxMobileWidth,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x240A2F29),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRect(child: child),
              ),
            ),
          ),
        );
      },
      home: CountriesScreen(repository: repository ?? RestCountriesService()),
    );
  }
}
