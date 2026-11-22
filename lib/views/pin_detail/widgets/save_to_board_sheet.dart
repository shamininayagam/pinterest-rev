import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/pin_model.dart';
import '../../../ui/ui.dart';
import '../../../view_model/boards_view_model.dart';
import '../../../view_model/feed_view_model.dart';

class SaveToBoardSheet extends ConsumerStatefulWidget {
  final Pin pin;

  const SaveToBoardSheet({
    super.key,
    required this.pin,
  });

  static Future<void> show(BuildContext context, Pin pin) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveToBoardSheet(pin: pin),
    );
  }

  @override
  ConsumerState<SaveToBoardSheet> createState() => _SaveToBoardSheetState();
}

class _SaveToBoardSheetState extends ConsumerState<SaveToBoardSheet> {
  final TextEditingController _newBoardController = TextEditingController();
  bool _isCreating = false;
  bool _isPrivate = false;

  @override
  void dispose() {
    _newBoardController.dispose();
    super.dispose();
  }

  void _handleSave(String boardId, String boardName) {
    ref.read(feedViewModelProvider.notifier).toggleSave(widget.pin.id, boardId);
    ref.read(boardsViewModelProvider.notifier).setCoverPin(boardId, widget.pin.id);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved to $boardName!'),
        backgroundColor: AppColors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  Future<void> _handleCreateBoard() async {
    final name = _newBoardController.text.trim();
    if (name.isEmpty) return;

    final newBoard = await ref.read(boardsViewModelProvider.notifier).createBoard(
          name,
          isPrivate: _isPrivate,
        );

    _newBoardController.clear();
    setState(() => _isCreating = false);
    _handleSave(newBoard.id, newBoard.name);
  }

  @override
  Widget build(BuildContext context) {
    final boardsState = ref.watch(boardsViewModelProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Save to board',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              // Create Board Toggle / Form
              if (_isCreating)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    children: [
                      TextField(
                        controller: _newBoardController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Name this board',
                          filled: true,
                          fillColor: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Keep this board secret 🔒'),
                          Switch(
                            value: _isPrivate,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) => setState(() => _isPrivate = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isCreating = false),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              ),
                            ),
                            onPressed: _handleCreateBoard,
                            child: const Text('Create', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isDark ? AppColors.darkSurfaceHover : AppColors.lightSurface,
                    child: Icon(Icons.add, color: isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                  title: const Text(
                    'Create board',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () => setState(() => _isCreating = true),
                ),

              // Boards List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: boardsState.boards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final board = boardsState.boards[index];
                    final isCurrentBoard = widget.pin.boardId == board.id;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceHover : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(
                          board.isPrivate ? Icons.lock : Icons.dashboard_outlined,
                          size: 22,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      title: Text(
                        board.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        board.isPrivate ? 'Secret board' : 'Public board',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrentBoard ? AppColors.black : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () => _handleSave(board.id, board.name),
                        child: Text(
                          isCurrentBoard ? 'Saved' : 'Save',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
