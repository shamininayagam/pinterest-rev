import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import '../../../model/comment_model.dart';
import '../../../model/pin_model.dart';
import '../../../ui/ui.dart';
import '../../../view_model/feed_view_model.dart';

class CommentsSection extends ConsumerStatefulWidget {
  final Pin pin;

  const CommentsSection({
    super.key,
    required this.pin,
  });

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      id: 'c-${_uuid.v4().substring(0, 8)}',
      author: 'You',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      text: text,
      time: 'Just now',
    );

    final updatedComments = [...widget.pin.comments, newComment];
    final updatedPin = widget.pin.copyWith(comments: updatedComments);

    ref.read(feedViewModelProvider.notifier).updatePin(updatedPin);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final comments = widget.pin.comments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          '${comments.length} Comments',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Comments list
        if (comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'No comments yet. Be the first to share your thoughts!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: CachedNetworkImageProvider(comment.avatar),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.author,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              comment.time,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          comment.text,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

        const SizedBox(height: AppSpacing.lg),

        // Comment Input Form
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  filled: true,
                  fillColor: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: _submitComment,
            ),
          ],
        ),
      ],
    );
  }
}
