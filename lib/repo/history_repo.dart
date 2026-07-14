import '../model/history_model.dart';

abstract class HistoryRepo {
  Future<void> addHistory(HistoryModel history, String userId);

  Future<void> updateHistory(HistoryModel history, String userId);

  Future<void> deleteHistory(String userId, String historyId);

  Future<List<HistoryModel>> getHistory(String userId);

  Stream<List<HistoryModel>> getHistoryStream(String userId);

  Stream<int> getAllHistoryCountStream();
}
