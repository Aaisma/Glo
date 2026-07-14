import '../model/period_log_model.dart';

abstract class PeriodRepo {
  Future<void> addLog(PeriodLogModel log);
  Future<void> updateLog(PeriodLogModel log);
  Future<void> deleteLog(String id);
  Future<PeriodLogModel?> getLogByDate(String userId, DateTime date);
  Future<List<PeriodLogModel>> getLogsForUser(String userId);
}
