import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/mock_api.dart';
import '../../data/models/property.dart';
import '../../providers/favorites_provider.dart';

/// The Explore tab.
///
/// This started as a simple list and grew. Filtering, sorting, the detail
/// page and the scheduling sheet all live in this file. Splitting it up
/// has been on the backlog since March.
///
/// State is setState here, but favourites go through FavoritesProvider,
/// so the two are kept in sync by hand.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MockApi _api = MockApi();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Property> _allProperties = [];
  List<Property> _visibleProperties = [];

  bool _loading = true;
  String? _error;

  String _typeFilter = 'all';
  String _sortBy = 'newest';
  String _searchQuery = '';

  int _minPrice = 0;
  int _maxPrice = 40000000;
  int _minBedrooms = 0;
  bool _featuredOnly = false;
  bool _gridMode = false;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _applyFilters();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.fetchProperties();
      setState(() {
        _allProperties = result;
        _loading = false;
        _applyFilters();
      });
    } catch (e) {
      print('HomeScreen load failed: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _load();
  }

  void _applyFilters() {
    var list = List<Property>.from(_allProperties);

    if (_typeFilter != 'all') {
      list = list.where((p) => p.type == _typeFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((p) {
        return p.title.toLowerCase().contains(_searchQuery) ||
            p.district.toLowerCase().contains(_searchQuery) ||
            p.address.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    list = list.where((p) => p.price >= _minPrice && p.price <= _maxPrice).toList();

    if (_minBedrooms > 0) {
      list = list.where((p) => p.bedrooms >= _minBedrooms).toList();
    }

    if (_featuredOnly) {
      list = list.where((p) => p.isFeatured).toList();
    }

    if (_sortBy == 'newest') {
      list.sort((a, b) => b.listedAt.compareTo(a.listedAt));
    } else if (_sortBy == 'price_low') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_high') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'area') {
      list.sort((a, b) => b.areaSqm.compareTo(a.areaSqm));
    }

    _visibleProperties = list;
  }

  void _setTypeFilter(String type) {
    setState(() {
      _typeFilter = type;
      _applyFilters();
    });
  }

  int get _activeFilterCount {
    var count = 0;
    if (_minPrice > 0) count++;
    if (_maxPrice < 40000000) count++;
    if (_minBedrooms > 0) count++;
    if (_featuredOnly) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: Icon(_gridMode ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _gridMode = !_gridMode;
              });
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _openFilterSheet,
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_activeFilterCount',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTypeChips(),
          _buildResultsBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Search + filter chrome
  // -------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Container(
      color: kPrimary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by title, district or address',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTypeChips() {
    final types = [
      {'key': 'all', 'label': 'All', 'icon': Icons.apps},
      {'key': 'house', 'label': 'House', 'icon': Icons.house_outlined},
      {'key': 'condo', 'label': 'Condo', 'icon': Icons.apartment},
      {'key': 'apartment', 'label': 'Apartment', 'icon': Icons.location_city},
    ];

    return Container(
      height: 56,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final t = types[index];
          final selected = _typeFilter == t['key'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              selected: selected,
              label: Text(t['label'] as String),
              avatar: Icon(
                t['icon'] as IconData,
                size: 18,
                color: selected ? kPrimary : Colors.grey,
              ),
              onSelected: (_) => _setTypeFilter(t['key'] as String),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
      child: Row(
        children: [
          Text(
            '${_visibleProperties.length} properties',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.swap_vert, size: 18),
            label: Text(_sortLabel()),
            onPressed: _openSortSheet,
          ),
        ],
      ),
    );
  }

  String _sortLabel() {
    if (_sortBy == 'newest') return 'Newest';
    if (_sortBy == 'price_low') return 'Price ↑';
    if (_sortBy == 'price_high') return 'Price ↓';
    return 'Largest';
  }

  // -------------------------------------------------------------------
  // Body states
  // -------------------------------------------------------------------

  Widget _buildBody() {
    if (_loading) {
      return _buildLoadingState();
    }
    if (_error != null) {
      return _buildErrorState();
    }
    if (_visibleProperties.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: _gridMode ? _buildGrid() : _buildList(),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          height: 260,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Could not load properties',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _load, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No properties match your filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try widening your price range or clearing the search.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _typeFilter = 'all';
                  _minPrice = 0;
                  _maxPrice = 40000000;
                  _minBedrooms = 0;
                  _featuredOnly = false;
                  _searchController.clear();
                  _applyFilters();
                });
              },
              child: const Text('Clear all filters'),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // List + grid
  // -------------------------------------------------------------------

  Widget _buildList() {
    final featured = _visibleProperties.where((p) => p.isFeatured).toList();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _visibleProperties.length + (featured.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (featured.isNotEmpty && index == 0) {
          return _buildFeaturedCarousel(featured);
        }
        final realIndex = featured.isNotEmpty ? index - 1 : index;
        return _buildPropertyCard(_visibleProperties[realIndex]);
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _visibleProperties.length,
      itemBuilder: (context, index) {
        return _buildGridCard(_visibleProperties[index]);
      },
    );
  }

  Widget _buildFeaturedCarousel(List<Property> featured) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: kAccent),
              const SizedBox(width: 6),
              const Text(
                'Featured',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${featured.length} listings',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              itemBuilder: (context, index) {
                return _buildFeaturedCard(featured[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Property property) {
    // Inline price formatting. There is a formatPrice() in core/utils but
    // this one shows the exact figure, which the designer asked for.
    final priceText = '฿${(property.price / 1000000).toStringAsFixed(1)}M';

    return GestureDetector(
      onTap: () => _openDetail(property),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: kPrimary.withOpacity(0.12),
                child: Icon(
                  _iconForType(property.type),
                  size: 48,
                  color: kPrimary.withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(_iconForType(property.type), size: 16, color: kPrimary),
                  const SizedBox(width: 6),
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                property.district,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(property.id);

    // Another inline price format, this one with thousands separators.
    final priceString = property.price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openDetail(property),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: kPrimary.withOpacity(0.10),
                    child: Icon(
                      _iconForType(property.type),
                      size: 56,
                      color: kPrimary.withOpacity(0.4),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? kDanger : Colors.grey,
                      ),
                      onPressed: () {
                        context.read<FavoritesProvider>().toggle(property.id);
                      },
                    ),
                  ),
                ),
                if (property.isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.address}, ${property.district}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '฿$priceString',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSpecChip(Icons.bed_outlined, '${property.bedrooms} bed'),
                      const SizedBox(width: 8),
                      _buildSpecChip(
                        Icons.bathtub_outlined,
                        '${property.bathrooms} bath',
                      ),
                      const SizedBox(width: 8),
                      _buildSpecChip(
                        Icons.square_foot,
                        '${property.areaSqm.toStringAsFixed(0)} m²',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(Property property) {
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(property.id);

    return GestureDetector(
      onTap: () => _openDetail(property),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: kPrimary.withOpacity(0.10),
                    child: Icon(
                      _iconForType(property.type),
                      size: 40,
                      color: kPrimary.withOpacity(0.4),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    iconSize: 18,
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? kDanger : Colors.white,
                    ),
                    onPressed: () {
                      context.read<FavoritesProvider>().toggle(property.id);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '฿${(property.price / 1000000).toStringAsFixed(2)}M',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${property.bedrooms} bed · ${property.areaSqm.toStringAsFixed(0)} m²',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    if (type == 'house') return Icons.house_outlined;
    if (type == 'condo') return Icons.apartment;
    return Icons.location_city;
  }

  // -------------------------------------------------------------------
  // Sheets
  // -------------------------------------------------------------------

  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sort by',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildSortOption('newest', 'Newest first', Icons.schedule),
              _buildSortOption('price_low', 'Price: low to high', Icons.arrow_upward),
              _buildSortOption('price_high', 'Price: high to low', Icons.arrow_downward),
              _buildSortOption('area', 'Largest area', Icons.square_foot),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String key, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: _sortBy == key ? kPrimary : Colors.grey),
      title: Text(label),
      trailing: _sortBy == key ? const Icon(Icons.check, color: kPrimary) : null,
      onTap: () {
        setState(() {
          _sortBy = key;
          _applyFilters();
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var localMin = _minPrice;
        var localMax = _maxPrice;
        var localBeds = _minBedrooms;
        var localFeatured = _featuredOnly;

        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            localMin = 0;
                            localMax = 40000000;
                            localBeds = 0;
                            localFeatured = false;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Price range',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  RangeSlider(
                    min: 0,
                    max: 40000000,
                    divisions: 40,
                    values: RangeValues(
                      localMin.toDouble(),
                      localMax.toDouble(),
                    ),
                    labels: RangeLabels(
                      '฿${(localMin / 1000000).toStringAsFixed(0)}M',
                      '฿${(localMax / 1000000).toStringAsFixed(0)}M',
                    ),
                    onChanged: (values) {
                      setSheetState(() {
                        localMin = values.start.round();
                        localMax = values.end.round();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Minimum bedrooms',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [0, 1, 2, 3, 4].map((n) {
                      final selected = localBeds == n;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(n == 0 ? 'Any' : '$n+'),
                          selected: selected,
                          onSelected: (_) {
                            setSheetState(() {
                              localBeds = n;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Featured listings only'),
                    value: localFeatured,
                    onChanged: (v) {
                      setSheetState(() {
                        localFeatured = v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = localMin;
                          _maxPrice = localMax;
                          _minBedrooms = localBeds;
                          _featuredOnly = localFeatured;
                          _applyFilters();
                        });
                        Navigator.of(builderContext).pop();
                      },
                      child: const Text('Show results'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------
  // Detail
  // -------------------------------------------------------------------

  void _openDetail(Property property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }
}

/// Property detail.
///
/// Lives in home_screen.dart because it was faster at the time.
class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final MockApi _api = MockApi();

  bool _scheduling = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(property.id);

    return WillPopScope(
      onWillPop: () async {
        if (_scheduling) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait, booking in progress')),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? kDanger : Colors.white,
                  ),
                  onPressed: () {
                    context.read<FavoritesProvider>().toggle(property.id);
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: kPrimary.withOpacity(0.2),
                  child: Icon(
                    property.type == 'house'
                        ? Icons.house_outlined
                        : Icons.apartment,
                    size: 96,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${property.address}, ${property.district}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '฿${(property.price / 1000000).toStringAsFixed(2)}M',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: kPrimary,
                      ),
                    ),
                    Text(
                      '฿${property.pricePerSqm.toStringAsFixed(0)} per m²',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    _buildSpecRow(property),
                    const SizedBox(height: 24),
                    const Text(
                      'About this property',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.description,
                      style: TextStyle(
                        height: 1.5,
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.amenities.map((a) {
                        return Chip(
                          label: Text(a, style: const TextStyle(fontSize: 12)),
                          backgroundColor: kPrimary.withOpacity(0.08),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    _buildAgentCard(property),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.event_available),
                        label: const Text('Schedule a viewing'),
                        onPressed: _scheduling ? null : _openScheduleSheet,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(Property property) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSpecItem(Icons.bed_outlined, '${property.bedrooms}', 'Bedrooms'),
        _buildSpecItem(
          Icons.bathtub_outlined,
          '${property.bathrooms}',
          'Bathrooms',
        ),
        _buildSpecItem(
          Icons.square_foot,
          property.areaSqm.toStringAsFixed(0),
          'm² area',
        ),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: kPrimary, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAgentCard(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: kPrimary.withOpacity(0.15),
            child: Text(
              property.agentName.substring(0, 1),
              style: const TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.agentName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                property.agentPhone,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.phone, color: kPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${property.agentName}...')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openScheduleSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(builderContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule a viewing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, color: kPrimary),
                    title: Text(
                      _selectedDate == null
                          ? 'Pick a date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: builderContext,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setSheetState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time, color: kPrimary),
                    title: Text(
                      _selectedTime == null
                          ? 'Pick a time'
                          : _selectedTime!.format(builderContext),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: builderContext,
                        initialTime: const TimeOfDay(hour: 10, minute: 0),
                      );
                      if (picked != null) {
                        setSheetState(() {
                          _selectedTime = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes for the agent (optional)',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(builderContext).pop();
                        _confirmSchedule();
                      },
                      child: const Text('Request viewing'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmSchedule() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date and time')),
      );
      return;
    }

    setState(() {
      _scheduling = true;
    });

    final when = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    await _api.scheduleViewing(
      propertyId: widget.property.id,
      propertyTitle: widget.property.title,
      propertyImageUrl: widget.property.imageUrl,
      when: when,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    setState(() {
      _scheduling = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viewing requested. Check the Viewings tab.'),
      ),
    );
  }
}
