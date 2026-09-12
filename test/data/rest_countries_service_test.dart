import 'package:explora_paises/data/services/rest_countries_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('usa el dataset oficial cuando no se configura una clave v5', () async {
    var requests = 0;
    final service = RestCountriesService(
      client: MockClient((request) async {
        requests++;
        return http.Response(
          '[{"name":{"common":"Colombia"},'
          '"capital":["Bogota"],"region":"Americas",'
          '"subregion":"South America","population":52215503,'
          '"flags":{},"cca3":"COL","languages":{"spa":"Spanish"},'
          '"currencies":{"COP":{"name":"Colombian peso"}},'
          '"area":1141748,"maps":{}}]',
          200,
        );
      }),
    );

    final countries = await service.fetchCountries();

    expect(requests, 1);
    expect(countries.single.name, 'Colombia');
    expect(countries.single.region, 'Am\u00e9rica');
  });
}
