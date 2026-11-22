import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';
import '../model/board_model.dart';
import 'pin_repository.dart';
import 'seed_data.dart';

final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return BoardRepository(storage);
});

class BoardRepository {
  final StorageService _storage;

  BoardRepository(this._storage);

  List<Board> loadBoards() {
    final raw = _storage.getBoards();
    if (raw != null && raw.isNotEmpty) {
      try {
        return raw.map((json) => Board.fromJson(json)).toList();
      } catch (_) {
        // Fallback
      }
    }
    // Seed initial boards
    saveBoards(kSeedBoards);
    return List<Board>.from(kSeedBoards);
  }

  Future<void> saveBoards(List<Board> boards) async {
    final list = boards.map((b) => b.toJson()).toList();
    await _storage.saveBoards(list);
  }
}
