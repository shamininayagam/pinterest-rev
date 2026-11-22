import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../model/author_model.dart';
import '../../ui/ui.dart';
import '../../view_model/feed_view_model.dart';
import '../boards/boards_view.dart';
import '../home/widgets/pin_card.dart';
import '../pin_detail/widgets/save_to_board_sheet.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _currentUser = Author(
    name: 'Alex Morgan',
    handle: 'alexmorgan',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedViewModelProvider);
    final feedNotifier = ref.read(feedViewModelProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final createdPins = feedState.allPins
        .where((p) => p.author.handle.toLowerCase() == _currentUser.handle.toLowerCase())
        .toList();

    final savedPins = feedState.allPins
        .where((p) => feedState.savedIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share profile',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile link copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              _showSettingsSheet(context);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      child: ClipOval(
                        child: AppImage(
                          url: _currentUser.avatar,
                          width: 92,
                          height: 92,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // User Name
                    Text(
                      _currentUser.name,
                      style: AppTypography.headingLarge.copyWith(
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Handle
                    Text(
                      '@${_currentUser.handle}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Follower Counts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '1.4k followers',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '382 following',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Action Buttons (Share / Edit)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile link copied to clipboard')),
                            );
                          },
                          child: const Text('Share', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onPressed: () {
                            _showEditProfileDialog(context);
                          },
                          child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: isDark ? Colors.white : AppColors.lightText,
                  indicatorWeight: 3,
                  labelColor: isDark ? Colors.white : AppColors.lightText,
                  unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  tabs: [
                    Tab(text: 'Created (${createdPins.length})'),
                    Tab(text: 'Saved (${savedPins.length})'),
                    const Tab(text: 'Boards'),
                  ],
                ),
                backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Created Pins Tab
            _buildPinsGrid(
              pins: createdPins,
              emptyTitle: 'Inspire others with your ideas',
              emptySubtitle: 'Pins you create will show up here.',
              actionLabel: 'Create Pin',
              onAction: () => context.go('/create'),
              feedState: feedState,
              feedNotifier: feedNotifier,
              isDark: isDark,
            ),

            // Saved Pins Tab
            _buildPinsGrid(
              pins: savedPins,
              emptyTitle: 'No saved Pins yet',
              emptySubtitle: 'Save ideas you love so you can easily find them later.',
              actionLabel: 'Find ideas',
              onAction: () => context.go('/search'),
              feedState: feedState,
              feedNotifier: feedNotifier,
              isDark: isDark,
            ),

            // Boards Tab
            const BoardsView(showAppBar: false),
          ],
        ),
      ),
    );
  }

  Widget _buildPinsGrid({
    required List<dynamic> pins,
    required String emptyTitle,
    required String emptySubtitle,
    required String actionLabel,
    required VoidCallback onAction,
    required FeedState feedState,
    required FeedNotifier feedNotifier,
    required bool isDark,
  }) {
    if (pins.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.push_pin_outlined,
                size: 56,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headingMedium.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                ),
                onPressed: onAction,
                child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
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
          padding: const EdgeInsets.all(AppSpacing.md),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 4,
          crossAxisSpacing: 12,
          itemCount: pins.length,
          itemBuilder: (context, index) {
            final pin = pins[index];
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
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Account settings'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy & data'),
                  onTap: () => Navigator.pop(ctx),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Log out', style: TextStyle(color: Colors.red)),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Alex Morgan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'About',
                hintText: 'Passionate about minimalist interior and architecture',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this._tabBar, {required this.backgroundColor});

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
