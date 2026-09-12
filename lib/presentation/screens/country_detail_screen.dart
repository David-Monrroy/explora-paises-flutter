import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/number_formatters.dart';
import '../../data/models/country.dart';
import '../widgets/common_widgets.dart';

class CountryDetailScreen extends StatefulWidget {
  const CountryDetailScreen({
    super.key,
    required this.country,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final Country country;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  late bool _isFavorite = widget.isFavorite;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onToggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    final country = widget.country;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          country.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          FavoriteButton(
            isFavorite: _isFavorite,
            onPressed: _toggleFavorite,
            foreground: const Color(0xFFE16354),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: FlagImage(
                url: country.flagPng,
                alt: country.flagAlt,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 58,
                      height: 44,
                      child: FlagImage(
                        url: country.flagPng,
                        alt: country.flagAlt,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text('${country.subregion} · ${country.code}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _DetailTile(
                  icon: Icons.location_on_outlined,
                  label: 'Capital',
                  value: country.capital,
                ),
                _DetailTile(
                  icon: Icons.public_rounded,
                  label: 'Regi\u00f3n',
                  value: country.region,
                ),
                _DetailTile(
                  icon: Icons.groups_outlined,
                  label: 'Poblaci\u00f3n',
                  value: formatNumber(country.population),
                ),
                _DetailTile(
                  icon: Icons.translate_rounded,
                  label: 'Idiomas',
                  value: country.languages.isEmpty
                      ? 'No registra'
                      : country.languages.join(', '),
                ),
                _DetailTile(
                  icon: Icons.payments_outlined,
                  label: 'Moneda',
                  value: country.currencies.isEmpty
                      ? 'No registra'
                      : country.currencies.join(', '),
                ),
                _DetailTile(
                  icon: Icons.square_foot_rounded,
                  label: 'Superficie',
                  value: '${formatNumber(country.area.round())} km\u00b2',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          minVerticalPadding: 12,
          leading: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFFE7F4F0),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Icon(icon, color: AppConstants.primaryColor, size: 20),
            ),
          ),
          title: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF66746F)),
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 64, color: Color(0xFFE8ECEA)),
      ],
    );
  }
}
