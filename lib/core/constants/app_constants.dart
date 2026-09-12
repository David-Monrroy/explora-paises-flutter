import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const appName = 'Explora Pa\u00edses';
  static const maxMobileWidth = 430.0;

  static const primaryColor = Color(0xFF0B7D6B);
  static const darkGreen = Color(0xFF173C36);
  static const backgroundColor = Color(0xFFF7F8F5);
  static const navigationColor = Color(0xFFEEF4F1);
  static const navigationIndicatorColor = Color(0xFFCBECE3);

  static const restCountriesV5Url =
      'https://api.restcountries.com/countries/v5';
  static const officialDatasetUrl =
      'https://raw.githubusercontent.com/restcountries/restcountries/'
      'master/src/main/resources/countriesV3.1.json';
  static const apiKey = String.fromEnvironment('REST_COUNTRIES_API_KEY');
  static const v5Fields =
      'names,codes,capitals,flag,region,subregion,population,languages,'
      'currencies,area,links';

  static const featuredCountryCodes = ['COL', 'JPN', 'CAN', 'BRA', 'FRA'];
}
