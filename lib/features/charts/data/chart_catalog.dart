import '../domain/chart_definition.dart';
import 'fl_creative_catalog.dart';
import 'syncfusion_creative_catalog.dart';
import 'maintained_creative_catalog.dart';
import 'graphic_creative_catalog.dart';

abstract final class ChartCatalog {
  static final List<ChartDefinition> all = List.unmodifiable([
    ...FlCreativeCatalog.all,
    ...SyncfusionCreativeCatalog.all,
    ...MaintainedCreativeCatalog.all,
    ...GraphicCreativeCatalog.all,
  ]);
}
