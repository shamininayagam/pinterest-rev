import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../ui/ui.dart';
import '../../view_model/boards_view_model.dart';
import '../../view_model/feed_view_model.dart';
import 'widgets/board_card.dart';

class BoardsView extends ConsumerWidget {
  final bool showAppBar;

  const BoardsView({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardsState = ref.watch(boardsViewModelProvider);
    final boardsNotifier = ref.read(boardsViewModelProvider.notifier);
    final feedState = ref.watch(feedViewModelProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = boardsState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : boardsState.boards.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.dashboard_customize_outlined,
                        size: 64,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Keep your ideas organized',
                        style: AppTypography.headingMedium.copyWith(
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create boards to save Pins for recipes, outfits, home decor, and projects.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Create board'),
                        onPressed: () {
                          _showCreateBoardDialog(context, boardsNotifier);
                        },
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 900 ? 3 : 4);

                    return GridView.builder(
                      shrinkWrap: !showAppBar,
                      physics: showAppBar ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: boardsState.boards.length,
                      itemBuilder: (context, index) {
                        final board = boardsState.boards[index];
                        final pinsInBoard = feedState.allPins.where((p) => p.boardId == board.id).toList();

                        return BoardCard(
                          board: board,
                          pins: pinsInBoard,
                          onTap: () {
                            context.push('/board/${board.id}');
                          },
                        );
                      },
                    );
                  },
                ),
              );

    if (!showAppBar) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Board',
            onPressed: () => _showCreateBoardDialog(context, boardsNotifier),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: content,
    );
  }

  void _showCreateBoardDialog(BuildContext context, BoardsNotifier notifier) {
    final nameCtrl = TextEditingController();
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Create board'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Places to Visit',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Keep board secret'),
                  subtitle: const Text('Only you can see this board'),
                  value: isPrivate,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => isPrivate = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isNotEmpty) {
                    await notifier.createBoard(name, isPrivate: isPrivate);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}
