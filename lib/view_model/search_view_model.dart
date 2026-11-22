import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../data/pin_repository.dart';
import '../model/pin_model.dart';
import 'feed_view_model.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class SearchState {
  final String query;
  final List<String> history;
  final List<Pin> results;
  final bool isLoading;

  const SearchState({
    required this.query,
    required this.history,
    required this.results,
    this.isLoading = false,
  });

  SearchState copyWith({
    String? query,
    List<String>? history,
    List<Pin>? results,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      history: history ?? this.history,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ApiService _apiService;
  final StorageService _storageService;
  final Ref _ref;

  SearchNotifier(this._apiService, this._storageService, this._ref)
      : super(const SearchState(query: '', history: [], results: [])) {
    loadHistory();
  }

  void loadHistory() {
    final history = _storageService.getSearchHistory();
    state = state.copyWith(history: history);
  }

  Future<void> search(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(
      query: clean,
      isLoading: true,
    );

    // 1. Filter local pins from feed
    final allPins = _ref.read(feedViewModelProvider).allPins;
    final cleanLower = clean.toLowerCase();

    final localMatches = allPins.where((p) {
      final titleMatch = p.title.toLowerCase().contains(cleanLower);
      final descMatch = p.description.toLowerCase().contains(cleanLower);
      final tagMatch = p.tags.any((t) => t.toLowerCase().contains(cleanLower));
      final catMatch = p.category.toLowerCase().contains(cleanLower);
      return titleMatch || descMatch || tagMatch || catMatch;
    }).toList();

    // 2. Fetch live images from Openverse / Wikipedia
    List<Pin> liveMatches = [];
    try {
      liveMatches = await _apiService.searchImages(clean);
    } catch (_) {
      // Ignore network errors, keep local
    }

    // Merge without duplicates
    final seenIds = localMatches.map((p) => p.id).toSet();
    final combined = [
      ...localMatches,
      ...liveMatches.where((p) => !seenIds.contains(p.id)),
    ];

    // Add to history
    final updatedHistory = [
      clean,
      ...state.history.where((h) => h.toLowerCase() != cleanLower),
    ].take(10).toList();

    state = state.copyWith(
      results: combined,
      history: updatedHistory,
      isLoading: false,
    );

    await _storageService.saveSearchHistory(updatedHistory);
  }

  void clearSearch() {
    state = state.copyWith(
      query: '',
      results: [],
      isLoading: false,
    );
  }

  Future<void> removeFromHistory(String item) async {
    final updated = state.history.where((h) => h != item).toList();
    state = state.copyWith(history: updated);
    await _storageService.saveSearchHistory(updated);
  }

  Future<void> clearHistory() async {
    state = state.copyWith(history: []);
    await _storageService.saveSearchHistory([]);
  }
}

final searchViewModelProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return SearchNotifier(api, storage, ref);
});
