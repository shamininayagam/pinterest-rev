import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../model/author_model.dart';
import '../../model/pin_model.dart';
import '../../ui/ui.dart';
import '../../view_model/boards_view_model.dart';
import '../../view_model/feed_view_model.dart';
import '../../data/seed_data.dart';

class CreatePinView extends ConsumerStatefulWidget {
  const CreatePinView({super.key});

  @override
  ConsumerState<CreatePinView> createState() => _CreatePinViewState();
}

class _CreatePinViewState extends ConsumerState<CreatePinView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _tagsController = TextEditingController();

  final _picker = ImagePicker();
  final _uuid = const Uuid();

  String? _selectedImagePath;
  bool _isNetworkImage = false;
  double _aspectRatio = 1.33; // Default 3:4 portrait
  String? _selectedBoardId;
  String _selectedCategory = 'Interior';
  bool _isSubmitting = false;

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null) {
        _setLocalImage(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load gallery: $e')),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null) {
        _setLocalImage(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open camera: $e')),
        );
      }
    }
  }

  void _setLocalImage(String path) {
    final file = File(path);
    final decodedImage = decodeImageFromList(file.readAsBytesSync());
    decodedImage.then((info) {
      setState(() {
        _selectedImagePath = path;
        _isNetworkImage = false;
        if (info.width > 0 && info.height > 0) {
          _aspectRatio = info.height / info.width;
        }
      });
    }).catchError((_) {
      setState(() {
        _selectedImagePath = path;
        _isNetworkImage = false;
        _aspectRatio = 1.33;
      });
    });
  }

  void _showImagePickerSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Choose Pin Media',
                  style: AppTypography.headingMedium.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from Photo Library'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Paste image URL'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showUrlInputDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: const Text('Select from curated sample images'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSamplePickerSheet();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUrlInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _selectedImagePath = url;
                  _isNetworkImage = true;
                  _aspectRatio = 1.33;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Use Image'),
          ),
        ],
      ),
    );
  }

  void _showSamplePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const Text('Pick a Sample Photo', style: AppTypography.headingMedium),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _sampleImages.length,
                      itemBuilder: (context, index) {
                        final url = _sampleImages[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImagePath = url;
                              _isNetworkImage = true;
                              _aspectRatio = 1.35;
                            });
                            Navigator.pop(ctx);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            child: AppImage(
                              url: url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _publishPin() async {
    final title = _titleController.text.trim();
    if (_selectedImagePath == null || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and enter a title')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final boardsState = ref.read(boardsViewModelProvider);
    final boardId = _selectedBoardId ?? (boardsState.boards.isNotEmpty ? boardsState.boards.first.id : 'board-1');

    final rawTags = _tagsController.text.split(RegExp(r'[, ]+')).map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final tags = rawTags.isEmpty ? [_selectedCategory.toLowerCase()] : rawTags;

    final newPin = Pin(
      id: 'pin-${_uuid.v4().substring(0, 8)}',
      title: title,
      description: _descriptionController.text.trim(),
      imageUrl: _selectedImagePath!,
      aspectRatio: _aspectRatio,
      dominantColor: '#E2E8F0',
      author: const Author(
        name: 'Alex Morgan',
        handle: 'alexmorgan',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      ),
      link: _linkController.text.trim().isNotEmpty ? _linkController.text.trim() : null,
      boardId: boardId,
      category: _selectedCategory,
      likesCount: 0,
      tags: tags,
      comments: const [],
      isLive: false,
    );

    await ref.read(feedViewModelProvider.notifier).addPin(newPin);

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pin published successfully!'),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              context.push('/pin/${newPin.id}');
            },
          ),
          backgroundColor: AppColors.primary,
        ),
      );

      // Reset fields
      _titleController.clear();
      _descriptionController.clear();
      _linkController.clear();
      _tagsController.clear();
      setState(() {
        _selectedImagePath = null;
      });

      // Switch to home feed
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardsState = ref.watch(boardsViewModelProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final canPublish = _selectedImagePath != null && _titleController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Pin'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canPublish ? AppColors.primary : Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                elevation: 0,
              ),
              onPressed: _isSubmitting || !canPublish ? null : _publishPin,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Publish',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Selector Box
            GestureDetector(
              onTap: _showImagePickerSheet,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 220, maxHeight: 340),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.5,
                  ),
                ),
                child: _selectedImagePath != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            child: _isNetworkImage
                                ? AppImage(
                                    url: _selectedImagePath!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Image.file(
                                    File(_selectedImagePath!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Change',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceHover : AppColors.lightSurfaceHover,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.file_upload_outlined,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Choose an image to upload',
                            style: AppTypography.headingMedium.copyWith(
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap here to browse photos or camera',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title input
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.headingMedium.copyWith(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              decoration: InputDecoration(
                hintText: 'Add your title',
                hintStyle: AppTypography.headingMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            // Description input
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Tell everyone what your Pin is about',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            // Destination Link
            TextField(
              controller: _linkController,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link, size: 20),
                hintText: 'Add a destination link (optional)',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // Board Selector Row
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Save to Board'),
              subtitle: Text(
                boardsState.boards.any((b) => b.id == _selectedBoardId)
                    ? boardsState.boards.firstWhere((b) => b.id == _selectedBoardId).name
                    : (boardsState.boards.isNotEmpty ? boardsState.boards.first.name : 'No boards yet'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                _showBoardSelectSheet(boardsState.boards);
              },
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: kCategories
                  .where((c) => c != 'All')
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Tags input
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'e.g. minimalist, interior, cozy',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showBoardSelectSheet(List<dynamic> boards) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              return ListTile(
                title: Text(board.name),
                subtitle: board.description.isNotEmpty ? Text(board.description) : null,
                trailing: _selectedBoardId == board.id ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() {
                    _selectedBoardId = board.id;
                  });
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        );
      },
    );
  }
}
