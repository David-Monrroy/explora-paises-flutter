import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/country.dart';
import '../../data/repositories/country_repository.dart';
import '../view_models/countries_view_model.dart';
import '../widgets/common_widgets.dart';
import '../widgets/country_cards.dart';
import 'country_detail_screen.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key, required this.repository});

  final CountryRepository repository;

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  final _searchController = TextEditingController();
  late final CountriesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CountriesViewModel(widget.repository)..loadCountries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _openCountry(Country country) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CountryDetailScreen(
          country: country,
          isFavorite: _viewModel.isFavorite(country),
          onToggleFavorite: () => _viewModel.toggleFavorite(country),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        const titles = [AppConstants.appName, 'Favoritos', 'Mi perfil'];
        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: Text(
              titles[_viewModel.tabIndex],
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: _viewModel.tabIndex == 0
                    ? 'Actualizar pa\u00edses'
                    : 'M\u00e1s opciones',
                onPressed: _viewModel.tabIndex == 0
                    ? _viewModel.loadCountries
                    : () {},
                icon: Icon(
                  _viewModel.tabIndex == 0
                      ? Icons.notifications_none_rounded
                      : Icons.more_vert_rounded,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _bodyForState(),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _viewModel.tabIndex,
            onDestinationSelected: _viewModel.setTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.public_rounded),
                label: 'Explorar',
              ),
              NavigationDestination(
                icon: Icon(Icons.star_border_rounded),
                selectedIcon: Icon(Icons.star_rounded),
                label: 'Favoritos',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bodyForState() {
    if (_viewModel.isLoading) {
      return const LoadingView(key: ValueKey('loading'));
    }

    if (_viewModel.error != null) {
      return ErrorView(
        key: const ValueKey('error'),
        message: _viewModel.error!,
        onRetry: _viewModel.loadCountries,
      );
    }

    return IndexedStack(
      key: const ValueKey('content'),
      index: _viewModel.tabIndex,
      children: [
        _ExploreTab(
          controller: _searchController,
          query: _viewModel.query,
          countries: _viewModel.filteredCountries,
          featured: _viewModel.featured,
          favoriteCodes: _viewModel.favoriteCodes,
          onQueryChanged: _viewModel.setQuery,
          onOpenCountry: _openCountry,
          onToggleFavorite: _viewModel.toggleFavorite,
        ),
        _FavoritesTab(
          countries: _viewModel.favorites,
          onOpenCountry: _openCountry,
          onToggleFavorite: _viewModel.toggleFavorite,
        ),
        _ProfileTab(
          countryCount: _viewModel.countries.length,
          favoriteCount: _viewModel.favorites.length,
          regionCount: _viewModel.regionCount,
        ),
      ],
    );
  }
}

class _ExploreTab extends StatelessWidget {
  const _ExploreTab({
    required this.controller,
    required this.query,
    required this.countries,
    required this.featured,
    required this.favoriteCodes,
    required this.onQueryChanged,
    required this.onOpenCountry,
    required this.onToggleFavorite,
  });

  final TextEditingController controller;
  final String query;
  final List<Country> countries;
  final List<Country> featured;
  final Set<String> favoriteCodes;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Country> onOpenCountry;
  final ValueChanged<Country> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width.clamp(320.0, 430.0);
    final featuredCardWidth = (viewportWidth - 60) / 3;
    return CustomScrollView(
      key: const Key('explore-tab'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
          sliver: SliverToBoxAdapter(
            child: SearchPanel(
              controller: controller,
              query: query,
              onChanged: onQueryChanged,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Pa\u00edses destacados',
            action: 'Ver todos',
            onActionPressed: () => onQueryChanged(''),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 164,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: featured.take(3).length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final country = featured[index];
                return FeaturedCountryCard(
                  width: featuredCardWidth,
                  country: country,
                  isFavorite: favoriteCodes.contains(country.code),
                  onOpen: () => onOpenCountry(country),
                  onToggleFavorite: () => onToggleFavorite(country),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Todos los pa\u00edses'),
        ),
        if (countries.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No hay resultados',
              subtitle:
                  'Prueba con otro nombre, capital, regi\u00f3n o c\u00f3digo.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            sliver: SliverList.separated(
              itemCount: countries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final country = countries[index];
                return CountryTile(
                  country: country,
                  onOpen: () => onOpenCountry(country),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({
    required this.countries,
    required this.onOpenCountry,
    required this.onToggleFavorite,
  });

  final List<Country> countries;
  final ValueChanged<Country> onOpenCountry;
  final ValueChanged<Country> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (countries.isEmpty) {
      return const EmptyState(
        icon: Icons.star_border_rounded,
        title: 'Sin favoritos',
        subtitle:
            'Marca pa\u00edses con el coraz\u00f3n para tenerlos aqu\u00ed.',
      );
    }

    return ListView.separated(
      key: const Key('favorites-tab'),
      padding: const EdgeInsets.all(18),
      itemCount: countries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final country = countries[index];
        return FavoriteCard(
          country: country,
          onOpen: () => onOpenCountry(country),
          onToggleFavorite: () => onToggleFavorite(country),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.countryCount,
    required this.favoriteCount,
    required this.regionCount,
  });

  final int countryCount;
  final int favoriteCount;
  final int regionCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          elevation: 0,
          color: AppConstants.darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.travel_explore_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(height: 18),
                Text(
                  'Explora el mundo con REST Countries',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consulta informaci\u00f3n de pa\u00edses mediante peticiones HTTP GET.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        MetricTile(
          icon: Icons.flag_rounded,
          title: 'Pa\u00edses cargados',
          value: '$countryCount',
        ),
        MetricTile(
          icon: Icons.map_rounded,
          title: 'Regiones encontradas',
          value: '$regionCount',
        ),
        MetricTile(
          icon: Icons.star_rounded,
          title: 'Favoritos guardados',
          value: '$favoriteCount',
        ),
        const SizedBox(height: 12),
        const ApiInfoBox(),
      ],
    );
  }
}
