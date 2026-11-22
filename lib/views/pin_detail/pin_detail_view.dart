import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../model/author_model.dart';
import '../../model/pin_model.dart';
import '../../ui/ui.dart';
import '../../utils/color_utils.dart';
import '../../view_model/feed_view_model.dart';
import '../home/widgets/pin_card.dart';
import 'widgets/comments_section.dart';
import 'widgets/save_to_board_sheet.dart';

class PinDetailView extends ConsumerStatefulWidget {
  final String pinId;

  const PinDetailView({
    super.key,
    required this.pinId,
  });

  @override
  ConsumerState<PinDetailView> createState() => _PinDetailViewState();
}

class _PinDetailViewState extends ConsumerState<PinDetailView> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedViewModelProvider);
    final feedNotifier = ref.read(feedViewModelProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Find the current pin
    final pin = feedState.allPins.firstWhere(
      (p) => p.id == widget.pinId,
      orElse: () => feedState.allPins.isNotEmpty
          ? feedState.allPins.first
          : const Pin(
              id: '',
              title: '',
              description: '',
              imageUrl: '',
              aspectRatio: 1.3,
              dominantColor: '#E2E8F0',
              author: Author(name: '', handle: '', avatar: ''),
              boardId: '',
              category: '',
              likesCount: 0,
              tags: [],
              comments: [],
            ),
    );

    if (pin.id.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Pin not found')),
      );
    }

    final isLiked = feedState.likedIds.contains(pin.id);
    final isSaved = feedState.savedIds.contains(pin.id);
    final placeholderColor = ColorUtils.fromHex(pin.dominantColor);

    // Related pins: same category, excluding current pin
    final relatedPins = feedState.allPins
        .where((p) => p.id != pin.id && (p.category == pin.category || p.boardId == pin.boardId))
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? AppColors.primary : null,
            ),
            onPressed: () => feedNotifier.toggleLike(pin.id),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Pin link copied to clipboard!'),
                  backgroundColor: AppColors.black,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  duration: const Duration(milliseconds: 1600),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaved ? AppColors.black : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                ),
                onPressed: () => SaveToBoardSheet.show(context, pin),
                child: Text(
                  isSaved ? 'Saved' : 'Save',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Interactive Image Viewer
            Hero(
              tag: 'pin-${pin.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppSpacing.radiusLg),
                ),
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 3.5,
                  child: AspectRatio(
                    aspectRatio: (1.0 / pin.aspectRatio).clamp(0.5, 1.8),
                    child: CachedNetworkImage(
                      imageUrl: pin.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: placeholderColor,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content Information
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination link
                  if (pin.link != null && pin.link!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(Icons.link, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pin.link!.replaceAll(RegExp(r'^https?://'), '').split('/')[0],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Title
                  if (pin.title.isNotEmpty)
                    Text(
                      pin.title,
                      style: AppTypography.headingLarge.copyWith(
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  if (pin.description.isNotEmpty)
                    Text(
                      pin.description,
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // Creator / Author Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: CachedNetworkImageProvider(pin.author.avatar),
                            backgroundColor: Colors.grey.shade300,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pin.author.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '12.4k followers',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing
                              ? (isDark ? AppColors.darkSurfaceHover : AppColors.lightSurface)
                              : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        ),
                        onPressed: () {
                          setState(() => _isFollowing = !_isFollowing);
                        },
                        child: Text(
                          _isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(
                            color: _isFollowing
                                ? (isDark ? AppColors.darkText : AppColors.lightText)
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tags
                  if (pin.tags.isNotEmpty)
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: pin.tags.map((tag) {
                        return ActionChip(
                          label: Text('#$tag'),
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                          onPressed: () {
                            context.go('/search');
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: AppSpacing.xl),

                  const Divider(),
                  const SizedBox(height: AppSpacing.md),

                  // Comments Section
                  CommentsSection(pin: pin),

                  const SizedBox(height: AppSpacing.xl),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),

                  // Related Pins ("More like this")
                  if (relatedPins.isNotEmpty) ...[
                    const Text(
                      'More like this',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 12,
                      itemCount: relatedPins.length,
                      itemBuilder: (context, index) {
                        final related = relatedPins[index];
                        final isRelatedLiked = feedState.likedIds.contains(related.id);
                        final isRelatedSaved = feedState.savedIds.contains(related.id);

                        return PinCard(
                          pin: related,
                          isLiked: isRelatedLiked,
                          isSaved: isRelatedSaved,
                          onTap: () {
                            context.push('/pin/${related.id}');
                          },
                          onLikeToggle: () {
                            feedNotifier.toggleLike(related.id);
                          },
                          onSaveToggle: () {
                            SaveToBoardSheet.show(context, related);
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
