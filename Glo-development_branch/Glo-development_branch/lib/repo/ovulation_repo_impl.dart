import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/ovulation_log_model.dart';
import 'ovulation_repo.dart';

class OvulationRepoImpl implements OvulationRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addLog(OvulationLogModel log) async {
    final docRef = _firestore.collection('ovulation').doc();
    final logWithId = log.copyWith(id: docRef.id);
    await docRef.set(logWithId.toMap());
  }

  @override
  Future<void> updateLog(OvulationLogModel log) async {
    await _firestore.collection('ovulation').doc(log.id).update(log.toMap());
  }

  @override
  Future<void> deleteLog(String id) async {
    await _firestore.collection('ovulation').doc(id).delete();
  }

  @override
  Future<OvulationLogModel?> getLogByDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('ovulation')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .get();

    if (snapshot.docs.isNotEmpty) {
      return OvulationLogModel.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  @override
  Future<List<OvulationLogModel>> getLogsForUser(String userId) async {
    final snapshot = await _firestore
        .collection('ovulation')
        .where('userId', isEqualTo: userId)
        .get();

    final logs = snapshot.docs.map((doc) => OvulationLogModel.fromMap(doc.data())).toList();
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }
}
