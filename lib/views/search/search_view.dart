import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../ui/ui.dart';
import '../../view_model/feed_view_model.dart';
import '../../view_model/search_view_model.dart';
import '../home/widgets/pin_card.dart';
import '../pin_detail/widgets/save_to_board_sheet.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, String>> _discoveryCategories = [
    {
      'title': 'Sports & Fitness',
      'query': 'Sports',
      'image': 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Architecture',
      'query': 'Architecture',
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Tokyo Neon',
      'query': 'Tokyo',
      'image': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Desk Setups',
      'query': 'Workspace',
      'image': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Coffee & Cafes',
      'query': 'Coffee',
      'image': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Interior Design',
      'query': 'Interior',
      'image': 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Nature & Alps',
      'query': 'Mountains',
      'image': 'https://images.unsplash.com/photo-1510798831971-661eb04b3739?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Ceramics & Craft',
      'query': 'Ceramics',
      'image': 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    ref.read(searchViewModelProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final searchNotifier = ref.read(searchViewModelProvider.notifier);
    final feedState = ref.watch(feedViewModelProvider);
    final feedNotifier = ref.read(feedViewModelProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearchSubmit,
            onChanged: (val) {
              if (val.isEmpty) {
                searchNotifier.clearSearch();
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        searchNotifier.clearSearch();
                      },
                    )
                  : null,
              hintText: 'Search for ideas, sports, cars...',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            ),
          ),
        ),
      ),
      body: searchState.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: AppSpacing.md),
                  Text('Discovering live pins...'),
                ],
              ),
            )
          : searchState.query.isNotEmpty
              ? _buildSearchResults(searchState, feedState, feedNotifier)
              : _buildDiscoveryView(searchState, searchNotifier, isDark),
    );
  }

  Widget _buildSearchResults(
    SearchState searchState,
    FeedState feedState,
    FeedNotifier feedNotifier,
  ) {
    if (searchState.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No pins found for "${searchState.query}"',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try searching with a broader keyword like "sports", "cats", or "japan"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 900 ? 3 : 4);

        return MasonryGridView.count(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 4,
          crossAxisSpacing: 12,
          itemCount: searchState.results.length,
          itemBuilder: (context, index) {
            final pin = searchState.results[index];
            final isLiked = feedState.likedIds.contains(pin.id);
            final isSaved = feedState.savedIds.contains(pin.id);

            return PinCard(
              pin: pin,
              isLiked: isLiked,
              isSaved: isSaved,
              onTap: () {
                // If it's a live search pin, register with feed state so it can be viewed
                if (pin.isLive && !feedState.allPins.any((p) => p.id == pin.id)) {
                  feedNotifier.addPin(pin);
                }
                context.push('/pin/${pin.id}');
              },
              onLikeToggle: () {
                feedNotifier.toggleLike(pin.id);
              },
              onSaveToggle: () {
                SaveToBoardSheet.show(context, pin);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDiscoveryView(
    SearchState searchState,
    SearchNotifier searchNotifier,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches Section
          if (searchState.history.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent searches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => searchNotifier.clearHistory(),
                  child: const Text('Clear all', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchState.history.map((term) {
                return InputChip(
                  label: Text(term),
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  onPressed: () {
                    _searchController.text = term;
                    searchNotifier.search(term);
                  },
                  onDeleted: () => searchNotifier.removeFromHistory(term),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Ideas For You Visual Cards
          const Text(
            'Ideas for you',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: _discoveryCategories.length,
            itemBuilder: (context, index) {
              final cat = _discoveryCategories[index];
              return InkWell(
                onTap: () {
                  _searchController.text = cat['query']!;
                  searchNotifier.search(cat['query']!);
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        cat['image']!,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black45,
                      ),
                      Center(
                        child: Text(
                          cat['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
