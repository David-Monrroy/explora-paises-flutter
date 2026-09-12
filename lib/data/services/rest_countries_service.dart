import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/errors/country_exception.dart';
import '../models/country.dart';
import '../repositories/country_repository.dart';
import '../sources/emergency_countries.dart';

class RestCountriesService implements CountryRepository {
  RestCountriesService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<Country>> fetchCountries() async {
    if (AppConstants.apiKey.isNotEmpty) {
      try {
        return await _fetchV5Countries();
      } catch (_) {
        // La fuente oficial de respaldo mantiene disponible la demostración
        // cuando una clave de aula caduca o no tiene conexión.
      }
    }

    try {
      return await _fetchOfficialDataset();
    } catch (_) {
      return emergencyCountries;
    }
  }

  Future<List<Country>> _fetchOfficialDataset() async {
    final response = await _client
        .get(Uri.parse(AppConstants.officialDatasetUrl))
        .timeout(const Duration(seconds: 15));
    return _parseDatasetResponse(response);
  }

  List<Country> _parseDatasetResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw const CountryException('No se pudo consultar REST Countries.');
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw const CountryException(
        'La respuesta de REST Countries no tiene el formato esperado.',
      );
    }

    final countries =
        data.whereType<Map<String, dynamic>>().map(Country.fromJson).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }

  Future<List<Country>> _fetchV5Countries() async {
    final countries = <Country>[];

    for (var offset = 0; offset < 300; offset += 100) {
      final uri = Uri.parse(
        '${AppConstants.restCountriesV5Url}?limit=100&offset=$offset'
        '&response_fields=${AppConstants.v5Fields}',
      );
      final response = await _client
          .get(uri, headers: {'Authorization': 'Bearer ${AppConstants.apiKey}'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw const CountryException(
          'La clave de REST Countries no es válida.',
        );
      }

      final payload = _readMap(jsonDecode(response.body));
      final data = _readMap(payload['data']);
      final objects = _readList(data['objects']);
      countries.addAll(
        objects.whereType<Map<String, dynamic>>().map(Country.fromV5Json),
      );

      final meta = _readMap(data['meta']);
      if (meta['more'] != true) break;
    }

    if (countries.isEmpty) {
      throw const CountryException('REST Countries no devolvió países.');
    }
    countries.sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }

  static Map<String, dynamic> _readMap(Object? value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  static List<dynamic> _readList(Object? value) {
    return value is List ? value : <dynamic>[];
  }
}
