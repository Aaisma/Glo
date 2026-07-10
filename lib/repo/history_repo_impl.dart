import '../model/history_model.dart';
import '../services/history_service.dart';
import 'history_repo.dart';

class HistoryRepoImpl implements HistoryRepo {
  final HistoryService service;

  HistoryRepoImpl(this.service);

  @override
  Future<void> addHistory(
      HistoryModel history,
      String userId,
      ) {
    return service.addHistory(
      history,
      userId,
    );
  }

  @override
  Future<void> updateHistory(
      HistoryModel history,
      String userId,
      ) {
    return service.updateHistory(
      history,
      userId,
    );
  }

  @override
  Future<void> deleteHistory(
      String userId,
      String historyId,
      ) {
    return service.deleteHistory(
      userId,
      historyId,
    );
  }

  @override
  Future<List<HistoryModel>> getHistory(
      String userId,
      ) {
    return service.getHistory(userId);
  }

  @override
  Stream<List<HistoryModel>> getHistoryStream(
      String userId,
      ) {
    return service.getHistoryStream(userId);
  }

  @override
  Stream<int> getAllHistoryCountStream() {
    return service.getAllHistoryCountStream();
  }

  @override
  Stream<int> getUserHistoryCountStream(
      String userId,
      ) {
    return service.getUserHistoryCountStream(userId);
  }
}