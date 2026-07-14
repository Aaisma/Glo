import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/period_log_model.dart';
import 'period_repo.dart';

class PeriodRepoImpl implements PeriodRepo {
  final FirebaseFirestore _firestore;

  PeriodRepoImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addLog(PeriodLogModel log) async {
    final docRef = _firestore.collection('periods').doc();
    final logWithId = log.copyWith(id: docRef.id);
    await docRef.set(logWithId.toMap());
  }

  @override
  Future<void> updateLog(PeriodLogModel log) async {
    await _firestore.collection('periods').doc(log.id).update(log.toMap());
  }

  @override
  Future<void> deleteLog(String id) async {
    await _firestore.collection('periods').doc(id).delete();
  }

  @override
  Future<PeriodLogModel?> getLogByDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('periods')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .get();

    if (snapshot.docs.isNotEmpty) {
      return PeriodLogModel.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  @override
  Future<List<PeriodLogModel>> getLogsForUser(String userId) async {
    final snapshot = await _firestore
        .collection('periods')
        .where('userId', isEqualTo: userId)
        .get();

    final logs = snapshot.docs.map((doc) => PeriodLogModel.fromMap(doc.data())).toList();
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }
}
