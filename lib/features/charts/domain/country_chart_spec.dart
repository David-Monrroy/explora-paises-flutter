/// Presentation contract shared by the staged country-chart catalogs.
abstract interface class CountryChartSpec {
  String get title;
  String get explanation;
  int get componentCount;
  bool get usesLayerColors;
}
