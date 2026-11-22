import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/board_repository.dart';
import '../model/board_model.dart';

class BoardsState {
  final List<Board> boards;
  final bool isLoading;

  const BoardsState({
    required this.boards,
    this.isLoading = false,
  });

  BoardsState copyWith({
    List<Board>? boards,
    bool? isLoading,
  }) {
    return BoardsState(
      boards: boards ?? this.boards,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BoardsNotifier extends StateNotifier<BoardsState> {
  final BoardRepository _repository;
  final _uuid = const Uuid();

  BoardsNotifier(this._repository)
      : super(const BoardsState(boards: [], isLoading: true)) {
    loadBoards();
  }

  void loadBoards() {
    final list = _repository.loadBoards();
    state = state.copyWith(boards: list, isLoading: false);
  }

  Future<Board> createBoard(
    String name, {
    String description = '',
    bool isPrivate = false,
  }) async {
    final newBoard = Board(
      id: 'board-${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      description: description.trim(),
      isPrivate: isPrivate,
      createdAt: DateTime.now(),
    );

    final updated = [newBoard, ...state.boards];
    state = state.copyWith(boards: updated);
    await _repository.saveBoards(updated);
    return newBoard;
  }

  Future<void> setCoverPin(String boardId, String pinId) async {
    final updated = state.boards.map((b) {
      if (b.id == boardId && (b.coverPinId == null || b.coverPinId!.isEmpty)) {
        return b.copyWith(coverPinId: pinId);
      }
      return b;
    }).toList();

    state = state.copyWith(boards: updated);
    await _repository.saveBoards(updated);
  }

  Future<void> deleteBoard(String boardId) async {
    final updated = state.boards.where((b) => b.id != boardId).toList();
    state = state.copyWith(boards: updated);
    await _repository.saveBoards(updated);
  }
}

final boardsViewModelProvider = StateNotifierProvider<BoardsNotifier, BoardsState>((ref) {
  final repository = ref.watch(boardRepositoryProvider);
  return BoardsNotifier(repository);
});
