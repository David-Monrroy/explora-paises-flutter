import '../models/country.dart';

abstract interface class CountryRepository {
  Future<List<Country>> fetchCountries();
}
