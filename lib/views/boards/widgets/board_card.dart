import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../model/board_model.dart';
import '../../../model/pin_model.dart';
import '../../../ui/ui.dart';

class BoardCard extends StatelessWidget {
  final Board board;
  final List<Pin> pins;
  final VoidCallback onTap;

  const BoardCard({
    super.key,
    required this.board,
    required this.pins,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final img1 = pins.isNotEmpty ? pins[0].imageUrl : null;
    final img2 = pins.length > 1 ? pins[1].imageUrl : null;
    final img3 = pins.length > 2 ? pins[2].imageUrl : null;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3-Image Collage Box
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              height: 160,
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              child: Row(
                children: [
                  // Main Cover Image (left 2/3)
                  Expanded(
                    flex: 2,
                    child: img1 != null
                        ? CachedNetworkImage(
                            imageUrl: img1,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            placeholder: (context, url) => Container(color: Colors.grey.shade400),
                            errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image)),
                          )
                        : Container(
                            color: isDark ? AppColors.darkSurfaceHover : AppColors.lightSurfaceHover,
                            child: const Center(child: Icon(Icons.dashboard_outlined, color: Colors.grey)),
                          ),
                  ),
                  const SizedBox(width: 2),

                  // Stacked Thumbnails (right 1/3)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: img2 != null
                              ? CachedNetworkImage(
                                  imageUrl: img2,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(color: Colors.grey.shade400),
                                  errorWidget: (context, url, error) => const SizedBox(),
                                )
                              : Container(
                                  color: isDark ? AppColors.darkSurfaceHover : AppColors.lightSurfaceHover,
                                ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: img3 != null
                              ? CachedNetworkImage(
                                  imageUrl: img3,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(color: Colors.grey.shade400),
                                  errorWidget: (context, url, error) => const SizedBox(),
                                )
                              : Container(
                                  color: isDark ? AppColors.darkSurfaceHover : AppColors.lightSurfaceHover,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Board Title & Count
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 2, right: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        board.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                    if (board.isPrivate) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.lock, size: 14, color: Colors.grey),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${pins.length} Pins${board.description.isNotEmpty ? ' • ${board.description}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
