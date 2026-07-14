import 'package:flutter/material.dart';
import '../model/journal_model.dart';
import '../repo/journal_repo.dart';
import 'package:uuid/uuid.dart';

class WriteJournalViewModel extends ChangeNotifier {
  final JournalRepo repository;
  String _selectedMood = 'Calm';
  String _selectedEmoji = '😊';

  WriteJournalViewModel({required this.repository});

  String get selectedMood => _selectedMood;
  String get selectedEmoji => _selectedEmoji;

  void updateMood(String mood, String emoji) {
    _selectedMood = mood;
    _selectedEmoji = emoji;
    notifyListeners();
  }

  Future<void> saveEntry({
    required String userId,
    required String userName,
    required String title,
    required String content,
  }) async {
    final entry = JournalModel(
      id: const Uuid().v4(),
      userId: userId,
      userName: userName,
      title: title.isEmpty ? 'Untitled' : title,
      content: content,
      createdAt: DateTime.now(),
      mood: _selectedMood,
      emoji: _selectedEmoji,
    );
    await repository.addJournal(entry);
    notifyListeners();
  }
}
