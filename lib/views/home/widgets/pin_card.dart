import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../model/pin_model.dart';
import '../../../ui/ui.dart';
import '../../../utils/color_utils.dart';

class PinCard extends StatelessWidget {
  final Pin pin;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;
  final VoidCallback onSaveToggle;

  const PinCard({
    super.key,
    required this.pin,
    required this.isLiked,
    required this.isSaved,
    required this.onTap,
    required this.onLikeToggle,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final placeholderColor = ColorUtils.fromHex(pin.dominantColor);

    // aspectRatio in model is height / width, so width / height = 1.0 / aspectRatio
    final widthOverHeight = pin.aspectRatio > 0 ? (1.0 / pin.aspectRatio) : 0.75;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media with rounded corners and overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: widthOverHeight.clamp(0.5, 1.6),
                  child: CachedNetworkImage(
                    imageUrl: pin.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: placeholderColor,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // Top right: Quick Save Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onSaveToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSaved ? AppColors.black : AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        isSaved ? 'Saved' : 'Save',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Right: Like Button overlay
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onLikeToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isLiked ? AppColors.primary : AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metadata beneath card
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2, right: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pin.title.isNotEmpty)
                  Text(
                    pin.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      height: 1.25,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundImage: CachedNetworkImageProvider(pin.author.avatar),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        pin.author.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
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
