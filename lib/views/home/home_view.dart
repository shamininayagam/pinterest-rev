import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../ui/ui.dart';
import '../../view_model/feed_view_model.dart';
import '../pin_detail/widgets/save_to_board_sheet.dart';
import 'widgets/category_bar.dart';
import 'widgets/pin_card.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedViewModelProvider);
    final feedNotifier = ref.read(feedViewModelProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Pinterest',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.go('/search');
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Bar
          CategoryBar(
            selectedCategory: feedState.selectedCategory,
            onCategorySelected: (cat) {
              feedNotifier.setCategory(cat);
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Main Masonry Waterfall Grid
          Expanded(
            child: feedState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : feedState.filteredPins.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No pins found in "${feedState.selectedCategory}"',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive column count based on available screen width
                          final int crossAxisCount = constraints.maxWidth < 600
                              ? 2
                              : constraints.maxWidth < 900
                                  ? 3
                                  : constraints.maxWidth < 1200
                                      ? 4
                                      : 5;

                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () async {
                              feedNotifier.loadFeed();
                            },
                            child: MasonryGridView.count(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 12,
                              itemCount: feedState.filteredPins.length,
                              itemBuilder: (context, index) {
                                final pin = feedState.filteredPins[index];
                                final isLiked = feedState.likedIds.contains(pin.id);
                                final isSaved = feedState.savedIds.contains(pin.id);

                                return PinCard(
                                  pin: pin,
                                  isLiked: isLiked,
                                  isSaved: isSaved,
                                  onTap: () {
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
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
