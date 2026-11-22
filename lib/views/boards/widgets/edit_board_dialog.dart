import 'package:flutter/material.dart';
import '../../../model/board_model.dart';
import '../../../ui/ui.dart';

class EditBoardDialog extends StatefulWidget {
  final Board board;
  final ValueChanged<Board> onSave;
  final VoidCallback onDelete;

  const EditBoardDialog({
    super.key,
    required this.board,
    required this.onSave,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Board board,
    required ValueChanged<Board> onSave,
    required VoidCallback onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => EditBoardDialog(
        board: board,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<EditBoardDialog> createState() => _EditBoardDialogState();
}

class _EditBoardDialogState extends State<EditBoardDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late bool _isPrivate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.board.name);
    _descController = TextEditingController(text: widget.board.description);
    _isPrivate = widget.board.isPrivate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Edit Board', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Board name',
                filled: true,
                fillColor: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Secret board 🔒', style: TextStyle(fontSize: 14)),
              value: _isPrivate,
              activeTrackColor: AppColors.primary,
              onChanged: (val) => setState(() => _isPrivate = val),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Board', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;

            final updated = widget.board.copyWith(
              name: name,
              description: _descController.text.trim(),
              isPrivate: _isPrivate,
            );

            Navigator.pop(context);
            widget.onSave(updated);
          },
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
