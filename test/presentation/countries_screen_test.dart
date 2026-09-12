import 'package:explora_paises/app/app.dart';
import 'package:explora_paises/data/models/country.dart';
import 'package:explora_paises/data/repositories/country_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra paises obtenidos desde el repositorio', (tester) async {
    await tester.pumpWidget(ExploreCountriesApp(repository: _FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Explora Pa\u00edses'), findsWidgets);
    expect(find.text('Colombia'), findsWidgets);
    expect(find.text('Japon'), findsWidgets);
    expect(find.byKey(const Key('country-search')), findsOneWidget);
  });

  testWidgets('filtra paises desde el buscador', (tester) async {
    await tester.pumpWidget(ExploreCountriesApp(repository: _FakeRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('country-search')), 'jap');
    await tester.pumpAndSettle();

    expect(find.text('Japon'), findsWidgets);
    expect(find.byKey(const Key('country-tile-CAN')), findsNothing);
  });

  testWidgets('agrega un pais a favoritos', (tester) async {
    await tester.pumpWidget(ExploreCountriesApp(repository: _FakeRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar a favoritos').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('favorites-tab')), findsOneWidget);
    expect(find.text('Colombia'), findsWidgets);
  });
}

class _FakeRepository implements CountryRepository {
  @override
  Future<List<Country>> fetchCountries() async {
    return const [
      Country(
        name: 'Colombia',
        capital: 'Bogota',
        region: 'Americas',
        subregion: 'South America',
        population: 52215503,
        flagPng: '',
        flagAlt: 'Bandera de Colombia',
        code: 'COL',
        languages: ['Spanish'],
        currencies: ['Colombian peso'],
        area: 1141748,
        mapsUrl: '',
      ),
      Country(
        name: 'Japon',
        capital: 'Tokyo',
        region: 'Asia',
        subregion: 'Eastern Asia',
        population: 125700000,
        flagPng: '',
        flagAlt: 'Bandera de Japon',
        code: 'JPN',
        languages: ['Japanese'],
        currencies: ['Japanese yen'],
        area: 377975,
        mapsUrl: '',
      ),
      Country(
        name: 'Canada',
        capital: 'Ottawa',
        region: 'Americas',
        subregion: 'North America',
        population: 41000000,
        flagPng: '',
        flagAlt: 'Bandera de Canada',
        code: 'CAN',
        languages: ['English', 'French'],
        currencies: ['Canadian dollar'],
        area: 9984670,
        mapsUrl: '',
      ),
    ];
  }
}
