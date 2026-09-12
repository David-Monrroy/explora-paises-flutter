class CountryException implements Exception {
  const CountryException(this.message);

  final String message;

  @override
  String toString() => message;
}
