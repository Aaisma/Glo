import '../model/ovulation_log_model.dart';

abstract class OvulationRepo {
  Future<void> addLog(OvulationLogModel log);
  Future<void> updateLog(OvulationLogModel log);
  Future<void> deleteLog(String id);
  Future<OvulationLogModel?> getLogByDate(String userId, DateTime date);
  Future<List<OvulationLogModel>> getLogsForUser(String userId);
}
