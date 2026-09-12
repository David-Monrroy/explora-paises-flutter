class Country {
  const Country({
    required this.name,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.flagPng,
    required this.flagAlt,
    required this.code,
    required this.languages,
    required this.currencies,
    required this.area,
    required this.mapsUrl,
  });

  final String name;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final String flagPng;
  final String flagAlt;
  final String code;
  final List<String> languages;
  final List<String> currencies;
  final double area;
  final String mapsUrl;

  factory Country.fromJson(Map<String, dynamic> json) {
    final translations = _readMap(json['translations']);
    final spanishName = _readMap(translations['spa'])['common']?.toString();
    final name =
        spanishName ??
        _readMap(json['name'])['common']?.toString() ??
        'Sin nombre';
    final flags = _readMap(json['flags']);
    final maps = _readMap(json['maps']);

    return Country(
      name: name,
      capital: _readList(json['capital']).isEmpty
          ? 'No registra'
          : _readList(json['capital']).first.toString(),
      region: _translateRegion(json['region']?.toString() ?? 'Sin regi\u00f3n'),
      subregion: _translateSubregion(
        json['subregion']?.toString() ?? 'Sin subregi\u00f3n',
      ),
      population: _readInt(json['population']),
      flagPng: flags['png']?.toString() ?? '',
      flagAlt: flags['alt']?.toString() ?? 'Bandera de $name',
      code: json['cca3']?.toString() ?? json['cca2']?.toString() ?? name,
      languages: _readMap(json['languages']).values
          .map((item) => '$item')
          .toList(),
      currencies: _readCurrencies(json['currencies']),
      area: _readDouble(json['area']),
      mapsUrl: maps['googleMaps']?.toString() ?? '',
    );
  }

  factory Country.fromV5Json(Map<String, dynamic> json) {
    final names = _readMap(json['names']);
    final translations = _readMap(names['translations']);
    final spanishName = _readMap(translations['spa'])['common']?.toString();
    final name = spanishName ?? names['common']?.toString() ?? 'Sin nombre';
    final capitals = _readList(json['capitals']);
    final capital = capitals.isEmpty
        ? 'No registra'
        : _readMap(capitals.first)['name']?.toString() ?? 'No registra';
    final flag = _readMap(json['flag']);
    final codes = _readMap(json['codes']);
    final area = _readMap(json['area']);
    final links = _readMap(json['links']);

    return Country(
      name: name,
      capital: capital,
      region: _translateRegion(json['region']?.toString() ?? 'Sin regi\u00f3n'),
      subregion: _translateSubregion(
        json['subregion']?.toString() ?? 'Sin subregi\u00f3n',
      ),
      population: _readInt(json['population']),
      flagPng: flag['url_png']?.toString() ?? '',
      flagAlt: flag['description']?.toString() ?? 'Bandera de $name',
      code:
          codes['alpha_3']?.toString() ?? codes['alpha_2']?.toString() ?? name,
      languages: _readV5Languages(json['languages']),
      currencies: _readV5Currencies(json['currencies']),
      area: _readDouble(area['kilometers']),
      mapsUrl: links['google_maps']?.toString() ?? '',
    );
  }

  bool matches(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return true;

    return name.toLowerCase().contains(text) ||
        capital.toLowerCase().contains(text) ||
        region.toLowerCase().contains(text) ||
        subregion.toLowerCase().contains(text) ||
        code.toLowerCase().contains(text);
  }

  static Map<String, dynamic> _readMap(Object? value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  static List<dynamic> _readList(Object? value) {
    return value is List ? value : <dynamic>[];
  }

  static int _readInt(Object? value) => value is num ? value.round() : 0;

  static double _readDouble(Object? value) {
    return value is num ? value.toDouble() : 0;
  }

  static List<String> _readCurrencies(Object? value) {
    final currencies = _readMap(value);
    return currencies.entries.map((entry) {
      final data = _readMap(entry.value);
      final name = data['name']?.toString() ?? entry.key;
      final symbol = data['symbol']?.toString();
      return symbol == null ? name : '$name ($symbol)';
    }).toList();
  }

  static List<String> _readV5Languages(Object? value) {
    return _readList(value)
        .map((item) {
          final language = _readMap(item);
          return language['name']?.toString() ??
              language['native_name']?.toString() ??
              '';
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<String> _readV5Currencies(Object? value) {
    final currencies = _readMap(value);
    return currencies.entries.map((entry) {
      final currency = _readMap(entry.value);
      final name = currency['name']?.toString() ?? entry.key;
      final symbol = currency['symbol']?.toString();
      return symbol == null || symbol.isEmpty ? name : '$name ($symbol)';
    }).toList();
  }

  static String _translateRegion(String value) {
    return const {
          'Americas': 'Am\u00e9rica',
          'Africa': '\u00c1frica',
          'Europe': 'Europa',
          'Oceania': 'Ocean\u00eda',
          'Antarctic': 'Ant\u00e1rtida',
        }[value] ??
        value;
  }

  static String _translateSubregion(String value) {
    return const {
          'South America': 'Am\u00e9rica del Sur',
          'North America': 'Am\u00e9rica del Norte',
          'Central America': 'Am\u00e9rica Central',
          'Caribbean': 'Caribe',
          'Eastern Asia': 'Asia Oriental',
          'Western Asia': 'Asia Occidental',
          'Southern Asia': 'Asia Meridional',
          'South-Eastern Asia': 'Sudeste Asi\u00e1tico',
          'Central Asia': 'Asia Central',
          'Northern Europe': 'Europa del Norte',
          'Southern Europe': 'Europa del Sur',
          'Eastern Europe': 'Europa Oriental',
          'Western Europe': 'Europa Occidental',
        }[value] ??
        value;
  }
}
