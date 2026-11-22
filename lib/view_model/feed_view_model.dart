import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pin_repository.dart';
import '../model/pin_model.dart';

class FeedState {
  final List<Pin> allPins;
  final Set<String> likedIds;
  final Set<String> savedIds;
  final String selectedCategory;
  final bool isLoading;

  const FeedState({
    required this.allPins,
    required this.likedIds,
    required this.savedIds,
    required this.selectedCategory,
    this.isLoading = false,
  });

  List<Pin> get filteredPins {
    if (selectedCategory == 'All') {
      return allPins;
    }
    return allPins.where((p) => p.category.toLowerCase() == selectedCategory.toLowerCase()).toList();
  }

  FeedState copyWith({
    List<Pin>? allPins,
    Set<String>? likedIds,
    Set<String>? savedIds,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return FeedState(
      allPins: allPins ?? this.allPins,
      likedIds: likedIds ?? this.likedIds,
      savedIds: savedIds ?? this.savedIds,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final PinRepository _repository;

  FeedNotifier(this._repository)
      : super(const FeedState(
          allPins: [],
          likedIds: {},
          savedIds: {},
          selectedCategory: 'All',
          isLoading: true,
        )) {
    loadFeed();
  }

  void loadFeed() {
    final pins = _repository.loadPins();
    final liked = _repository.loadLikedIds();
    final saved = _repository.loadSavedIds();

    state = state.copyWith(
      allPins: pins,
      likedIds: liked,
      savedIds: saved,
      isLoading: false,
    );
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> toggleLike(String pinId) async {
    final currentLikes = Set<String>.from(state.likedIds);
    final isLiked = currentLikes.contains(pinId);

    if (isLiked) {
      currentLikes.remove(pinId);
    } else {
      currentLikes.add(pinId);
    }

    final updatedPins = state.allPins.map((pin) {
      if (pin.id == pinId) {
        final newCount = isLiked
            ? (pin.likesCount > 0 ? pin.likesCount - 1 : 0)
            : pin.likesCount + 1;
        return pin.copyWith(likesCount: newCount);
      }
      return pin;
    }).toList();

    state = state.copyWith(
      likedIds: currentLikes,
      allPins: updatedPins,
    );

    await _repository.saveLikedIds(currentLikes);
    await _repository.savePins(updatedPins);
  }

  Future<void> toggleSave(String pinId, String boardId) async {
    final currentSaved = Set<String>.from(state.savedIds);
    final isSaved = currentSaved.contains(pinId);

    if (isSaved) {
      currentSaved.remove(pinId);
    } else {
      currentSaved.add(pinId);
    }

    final updatedPins = state.allPins.map((pin) {
      if (pin.id == pinId) {
        return pin.copyWith(boardId: boardId);
      }
      return pin;
    }).toList();

    state = state.copyWith(
      savedIds: currentSaved,
      allPins: updatedPins,
    );

    await _repository.saveSavedIds(currentSaved);
    await _repository.savePins(updatedPins);
  }

  Future<void> addPin(Pin pin) async {
    final updated = [pin, ...state.allPins];
    final currentSaved = Set<String>.from(state.savedIds)..add(pin.id);

    state = state.copyWith(
      allPins: updated,
      savedIds: currentSaved,
    );

    await _repository.savePins(updated);
    await _repository.saveSavedIds(currentSaved);
  }

  Future<void> updatePin(Pin pin) async {
    final updated = state.allPins.map((p) => p.id == pin.id ? pin : p).toList();
    state = state.copyWith(allPins: updated);
    await _repository.savePins(updated);
  }
}

final feedViewModelProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final repository = ref.watch(pinRepositoryProvider);
  return FeedNotifier(repository);
});
