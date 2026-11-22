import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';
import '../model/pin_model.dart';
import 'seed_data.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in main');
});

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PinRepository(storage);
});

class PinRepository {
  final StorageService _storage;

  PinRepository(this._storage);

  List<Pin> loadPins() {
    final raw = _storage.getPins();
    if (raw != null && raw.isNotEmpty) {
      try {
        return raw.map((json) => Pin.fromJson(json)).toList();
      } catch (_) {
        // Fallback to seed
      }
    }
    // Seed initial data
    savePins(kSeedPins);
    return List<Pin>.from(kSeedPins);
  }

  Future<void> savePins(List<Pin> pins) async {
    final list = pins.map((p) => p.toJson()).toList();
    await _storage.savePins(list);
  }

  Set<String> loadLikedIds() {
    return _storage.getLikedIds();
  }

  Future<void> saveLikedIds(Set<String> ids) async {
    await _storage.saveLikedIds(ids);
  }

  Set<String> loadSavedIds() {
    final ids = _storage.getSavedIds();
    if (ids.isEmpty) {
      final initial = {'pin-1', 'pin-3', 'pin-5'};
      saveSavedIds(initial);
      return initial;
    }
    return ids;
  }

  Future<void> saveSavedIds(Set<String> ids) async {
    await _storage.saveSavedIds(ids);
  }
}
