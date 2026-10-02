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

  testWidgets('abre el catálogo y renderiza una gráfica', (tester) async {
    await tester.pumpWidget(ExploreCountriesApp(repository: _FakeRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gráficas'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('charts-tab')), findsOneWidget);
    expect(find.text('Elige 7 países'), findsOneWidget);
    expect(find.byKey(const Key('chart-flChart-creative-1')), findsNothing);

    for (final country in [
      'Colombia',
      'Japon',
      'Canada',
      'Brasil',
      'Francia',
      'Alemania',
      'India',
    ]) {
      await tester.enterText(
        find.byKey(const Key('country-chart-search')),
        country,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(country).last);
      await tester.pumpAndSettle();
    }

    expect(find.text('Comparación lista'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('252 gráficas visibles'),
      180,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('charts-tab')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('252 gráficas visibles'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('chart-flChart-creative-1')),
      150,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('charts-tab')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.byKey(const Key('chart-flChart-creative-1'))),
      alignment: 0.3,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chart-flChart-creative-1')));
    await tester.pumpAndSettle();

    expect(find.text('Gráfica 1'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Leyenda y valores'), 250);
    expect(find.text('Leyenda y valores'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('selected-COL')),
      -250,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('charts-tab')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.byKey(const Key('selected-COL'))),
      alignment: 0.25,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quitar Colombia'));
    await tester.pumpAndSettle();
    expect(find.text('Elige 7 países'), findsOneWidget);
    expect(find.byKey(const Key('chart-flChart-creative-1')), findsNothing);
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
        name: 'Brasil',
        capital: 'Brasilia',
        region: 'Americas',
        subregion: 'South America',
        population: 210000000,
        flagPng: '',
        flagAlt: '',
        code: 'BRA',
        languages: ['Portuguese'],
        currencies: ['Real'],
        area: 8515767,
        mapsUrl: '',
      ),
      Country(
        name: 'Francia',
        capital: 'Paris',
        region: 'Europe',
        subregion: 'Western Europe',
        population: 68000000,
        flagPng: '',
        flagAlt: '',
        code: 'FRA',
        languages: ['French'],
        currencies: ['Euro'],
        area: 551695,
        mapsUrl: '',
      ),
      Country(
        name: 'Alemania',
        capital: 'Berlin',
        region: 'Europe',
        subregion: 'Western Europe',
        population: 83000000,
        flagPng: '',
        flagAlt: '',
        code: 'DEU',
        languages: ['German'],
        currencies: ['Euro'],
        area: 357588,
        mapsUrl: '',
      ),
      Country(
        name: 'India',
        capital: 'New Delhi',
        region: 'Asia',
        subregion: 'Southern Asia',
        population: 1420000000,
        flagPng: '',
        flagAlt: '',
        code: 'IND',
        languages: ['Hindi', 'English'],
        currencies: ['Rupee'],
        area: 3287263,
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
