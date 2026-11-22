import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../model/board_model.dart';
import '../../ui/ui.dart';
import '../../view_model/boards_view_model.dart';
import '../../view_model/feed_view_model.dart';
import '../home/widgets/pin_card.dart';
import '../pin_detail/widgets/save_to_board_sheet.dart';
import 'widgets/edit_board_dialog.dart';

class BoardDetailView extends ConsumerWidget {
  final String boardId;

  const BoardDetailView({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardsState = ref.watch(boardsViewModelProvider);
    final boardsNotifier = ref.read(boardsViewModelProvider.notifier);
    final feedState = ref.watch(feedViewModelProvider);
    final feedNotifier = ref.read(feedViewModelProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final board = boardsState.boards.firstWhere(
      (b) => b.id == boardId,
      orElse: () => Board(
        id: '',
        name: 'Board',
        description: '',
        isPrivate: false,
        createdAt: DateTime.now(),
      ),
    );

    if (board.id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Board not found')));
    }

    final boardPins = feedState.allPins.where((p) => p.boardId == board.id).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              EditBoardDialog.show(
                context,
                board: board,
                onSave: (updated) {
                  boardsNotifier.updateBoard(updated);
                },
                onDelete: () {
                  boardsNotifier.deleteBoard(board.id);
                  Navigator.pop(context);
                },
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Board Title & Privacy
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  board.name,
                  style: AppTypography.headingLarge.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                if (board.isPrivate) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.lock, size: 20, color: Colors.grey),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // Pin count & description
            Text(
              '${boardPins.length} Pins${board.description.isNotEmpty ? ' • ${board.description}' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Pins in this board
            if (boardPins.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.dashboard_outlined,
                      size: 54,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'There are no Pins on this board yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => context.go('/search'),
                      child: const Text('Find ideas to save'),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 900 ? 3 : 4);

                    return MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 12,
                      itemCount: boardPins.length,
                      itemBuilder: (context, index) {
                        final pin = boardPins[index];
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
