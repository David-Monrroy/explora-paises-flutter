import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/country.dart';
import '../../data/repositories/country_repository.dart';

class CountriesViewModel extends ChangeNotifier {
  CountriesViewModel(this._repository);

  final CountryRepository _repository;
  final Set<String> _favoriteCodes = <String>{};

  List<Country> _countries = <Country>[];
  bool _isLoading = true;
  String? _error;
  String _query = '';
  int _tabIndex = 0;
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  int get tabIndex => _tabIndex;
  List<Country> get countries => List.unmodifiable(_countries);
  Set<String> get favoriteCodes => Set.unmodifiable(_favoriteCodes);

  List<Country> get filteredCountries {
    return _countries.where((country) => country.matches(_query)).toList();
  }

  List<Country> get favorites {
    return _countries
        .where((country) => _favoriteCodes.contains(country.code))
        .toList();
  }

  List<Country> get featured {
    final featured = <Country>[];
    for (final code in AppConstants.featuredCountryCodes) {
      final matches = _countries.where((country) => country.code == code);
      if (matches.isNotEmpty) featured.add(matches.first);
    }
    if (featured.length < 5) {
      featured.addAll(_countries.take(5 - featured.length));
    }
    return featured;
  }

  int get regionCount =>
      _countries.map((country) => country.region).toSet().length;

  bool isFavorite(Country country) => _favoriteCodes.contains(country.code);

  Future<void> loadCountries() async {
    _isLoading = true;
    _error = null;
    _notify();

    try {
      _countries = await _repository.fetchCountries();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void setQuery(String value) {
    _query = value;
    _notify();
  }

  void setTab(int index) {
    _tabIndex = index;
    _notify();
  }

  void toggleFavorite(Country country) {
    if (!_favoriteCodes.remove(country.code)) {
      _favoriteCodes.add(country.code);
    }
    _notify();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
