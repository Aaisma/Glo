import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/period_log_model.dart';
import '../model/ovulation_log_model.dart';
import '../model/cycle_analytics_engine.dart';

abstract class AdminMonthlyTrackingRepo {
  Future<Map<String, dynamic>> getPeriodAnalytics(DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getOvulationAnalytics(DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getSymptomsAnalytics(DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getSymptomsDetails(String symptom, DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getCalendarDailySummary(DateTime date);
}

class AdminMonthlyTrackingRepoImpl implements AdminMonthlyTrackingRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>> getPeriodAnalytics(DateTime startDate, DateTime endDate) async {
    // Aggregation logic using real data where possible, with fallbacks to design numbers if dataset is empty
    final snapshot = await _firestore
        .collection('period')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final logs = snapshot.docs.map((doc) => PeriodLogModel.fromMap(doc.data())).toList();
    int totalLogs = logs.length;
    
    Map<String, List<PeriodLogModel>> logsByUser = {};
    for (var log in logs) {
      if (!logsByUser.containsKey(log.userId)) logsByUser[log.userId] = [];
      logsByUser[log.userId]!.add(log);
    }

    List<int> cycleLengths = [];
    List<int> periodLengths = [];
    Map<int, int> startDayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0}; // 1=Mon, 7=Sun

    for (var userLogs in logsByUser.values) {
      userLogs.sort((a, b) => a.date.compareTo(b.date));
      int currentPeriodLength = 0;
      DateTime? lastPeriodStart;

      for (int i = 0; i < userLogs.length; i++) {
        final log = userLogs[i];
        if (log.isPeriodDay) {
          currentPeriodLength++;
          if (i == 0 || userLogs[i - 1].date.difference(log.date).inDays.abs() > 1) {
            startDayCounts[log.date.weekday] = (startDayCounts[log.date.weekday] ?? 0) + 1;
            if (lastPeriodStart != null) {
              int cycleLen = log.date.difference(lastPeriodStart).inDays;
              if (cycleLen > 10 && cycleLen < 100) cycleLengths.add(cycleLen);
            }
            lastPeriodStart = log.date;
          }
        } else {
          if (currentPeriodLength > 0) {
            periodLengths.add(currentPeriodLength);
            currentPeriodLength = 0;
          }
        }
      }
      if (currentPeriodLength > 0) periodLengths.add(currentPeriodLength);
    }

    double avgCycleLength = cycleLengths.isEmpty ? 28 : cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    double avgPeriodLength = periodLengths.isEmpty ? 5 : periodLengths.reduce((a, b) => a + b) / periodLengths.length;

    int cycleLess26 = cycleLengths.where((c) => c < 26).length;
    int cycle26To32 = cycleLengths.where((c) => c >= 26 && c <= 32).length;
    int cycleMore32 = cycleLengths.where((c) => c > 32).length;
    int totalCycles = cycleLengths.length;
    
    int p1To3 = periodLengths.where((p) => p >= 1 && p <= 3).length;
    int p4To6 = periodLengths.where((p) => p >= 4 && p <= 6).length;
    int p7To9 = periodLengths.where((p) => p >= 7 && p <= 9).length;
    int p10Plus = periodLengths.where((p) => p >= 10).length;
    int totalPeriods = periodLengths.length;
    
    // Removed fallback simulated data per requirements.


    return {
      "avgCycleLength": avgCycleLength.round(),
      "avgPeriodLength": avgPeriodLength.round(),
      "totalPeriodLogs": totalLogs,
      "cycleDistribution": {
        "< 26 days": totalCycles == 0 ? 0 : (cycleLess26 / totalCycles * 100).round(),
        "26-32 days": totalCycles == 0 ? 0 : (cycle26To32 / totalCycles * 100).round(),
        "> 32 days": totalCycles == 0 ? 0 : (cycleMore32 / totalCycles * 100).round(),
      },
      "periodDistribution": {
        "1-3 days": totalPeriods == 0 ? 0 : (p1To3 / totalPeriods * 100).round(),
        "4-6 days": totalPeriods == 0 ? 0 : (p4To6 / totalPeriods * 100).round(),
        "7-9 days": totalPeriods == 0 ? 0 : (p7To9 / totalPeriods * 100).round(),
        "10+ days": totalPeriods == 0 ? 0 : (p10Plus / totalPeriods * 100).round(),
      },
      "startDayDistribution": startDayCounts.map((k, v) {
        int totalStarts = startDayCounts.values.reduce((a, b) => a + b);
        return MapEntry(k, totalStarts == 0 ? 0 : (v / totalStarts * 100).round());
      }),
    };
  }

  @override
  Future<Map<String, dynamic>> getOvulationAnalytics(DateTime startDate, DateTime endDate) async {
    final ovulationSnap = await _firestore
        .collection('ovulation')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();
        
    final periodSnap = await _firestore
        .collection('period')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final ovulationLogs = ovulationSnap.docs.map((doc) => OvulationLogModel.fromMap(doc.data())).toList();
    final periodLogs = periodSnap.docs.map((doc) => PeriodLogModel.fromMap(doc.data())).toList();
    
    int totalOvulationLogs = ovulationLogs.length;

    // Group by user
    Map<String, List<OvulationLogModel>> ovLogsByUser = {};
    for (var log in ovulationLogs) {
      ovLogsByUser.putIfAbsent(log.userId, () => []).add(log);
    }
    Map<String, List<PeriodLogModel>> pLogsByUser = {};
    for (var log in periodLogs) {
      pLogsByUser.putIfAbsent(log.userId, () => []).add(log);
    }

    Set<String> allUserIds = {...ovLogsByUser.keys, ...pLogsByUser.keys};

    List<int> ovulationDays = [];
    List<int> fertileWindowLengths = [];
    int accuratePredictions = 0;
    int inaccuratePredictions = 0;

    for (String userId in allUserIds) {
      final userOvLogs = ovLogsByUser[userId] ?? [];
      final userPLogs = pLogsByUser[userId] ?? [];
      
      final result = CycleAnalyticsEngine.calculate(periodLogs: userPLogs, ovulationLogs: userOvLogs);
      
      for (var cycle in result.pastCycles) {
        if (cycle.ovulationDate != null) {
          int ovDay = cycle.ovulationDate!.difference(cycle.startDate).inDays + 1;
          ovulationDays.add(ovDay);
          fertileWindowLengths.add(cycle.fertileDays.length);
          
          if (cycle.isOvulationConfirmed) {
            // In the engine, if it wasn't confirmed, it defaults to nextStart - 14 days.
            // If it is confirmed, the engine uses the confirmed date.
            // But we need to compare the predicted date against the confirmed date for accuracy.
            // The engine's CycleData model doesn't store the purely "predicted" date if confirmed. 
            // So we re-calculate the basic prediction: nextStart - 14.
            DateTime basicPredicted = cycle.endDate.add(const Duration(days: 1)).subtract(const Duration(days: 14));
            int diff = cycle.ovulationDate!.difference(basicPredicted).inDays.abs();
            if (diff <= 2) {
              accuratePredictions++;
            } else {
              inaccuratePredictions++;
            }
          }
        }
      }
    }

    double avgOvulationDay = ovulationDays.isEmpty ? 0 : ovulationDays.reduce((a, b) => a + b) / ovulationDays.length;
    double avgFertileWindow = fertileWindowLengths.isEmpty ? 0 : fertileWindowLengths.reduce((a, b) => a + b) / fertileWindowLengths.length;

    int ovLess12 = ovulationDays.where((d) => d < 12).length;
    int ov12To16 = ovulationDays.where((d) => d >= 12 && d <= 16).length;
    int ovMore16 = ovulationDays.where((d) => d > 16).length;
    int totalOvCycles = ovulationDays.length;

    int fw3To4 = fertileWindowLengths.where((f) => f >= 3 && f <= 4).length;
    int fw5To7 = fertileWindowLengths.where((f) => f >= 5 && f <= 7).length;
    int fw8To10 = fertileWindowLengths.where((f) => f >= 8 && f <= 10).length;
    int fw10Plus = fertileWindowLengths.where((f) => f > 10).length;
    int totalFwCycles = fertileWindowLengths.length;

    int totalAccuracyChecks = accuratePredictions + inaccuratePredictions;

    return {
      "avgOvulationDay": avgOvulationDay.round(),
      "avgFertileWindow": avgFertileWindow.round(),
      "totalOvulationLogs": totalOvulationLogs,
      "ovulationDistribution": {
        "< 12 days": totalOvCycles == 0 ? 0 : (ovLess12 / totalOvCycles * 100).round(),
        "12-16 days": totalOvCycles == 0 ? 0 : (ov12To16 / totalOvCycles * 100).round(),
        "> 16 days": totalOvCycles == 0 ? 0 : (ovMore16 / totalOvCycles * 100).round(),
      },
      "fertileWindowDistribution": {
        "3-4 days": totalFwCycles == 0 ? 0 : (fw3To4 / totalFwCycles * 100).round(),
        "5-7 days": totalFwCycles == 0 ? 0 : (fw5To7 / totalFwCycles * 100).round(),
        "8-10 days": totalFwCycles == 0 ? 0 : (fw8To10 / totalFwCycles * 100).round(),
        "10+ days": totalFwCycles == 0 ? 0 : (fw10Plus / totalFwCycles * 100).round(),
      },
      "accuracy": {
        "Accurate": totalAccuracyChecks == 0 ? 0 : (accuratePredictions / totalAccuracyChecks * 100).round(),
        "Inaccurate": totalAccuracyChecks == 0 ? 0 : (inaccuratePredictions / totalAccuracyChecks * 100).round(),
      }
    };
  }

  @override
  Future<Map<String, dynamic>> getSymptomsAnalytics(DateTime startDate, DateTime endDate) async {
    final periodSnap = await _firestore
        .collection('period')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final ovulationSnap = await _firestore
        .collection('ovulation')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final pLogs = periodSnap.docs.map((doc) => PeriodLogModel.fromMap(doc.data())).toList();
    final ovLogs = ovulationSnap.docs.map((doc) => OvulationLogModel.fromMap(doc.data())).toList();

    int totalSymptoms = 0;
    Set<String> usersLoggingSymptoms = {};
    Map<String, int> symptomCounts = {};
    Map<String, int> phaseCounts = {
      "Menstruation": 0,
      "Follicular": 0,
      "Ovulation": 0,
      "Fertile Window": 0,
      "Luteal": 0
    };

    // Group logs by user
    Map<String, List<PeriodLogModel>> pLogsByUser = {};
    for (var log in pLogs) {
      pLogsByUser.putIfAbsent(log.userId, () => []).add(log);
    }
    Map<String, List<OvulationLogModel>> ovLogsByUser = {};
    for (var log in ovLogs) {
      ovLogsByUser.putIfAbsent(log.userId, () => []).add(log);
    }

    Set<String> allUserIds = {...pLogsByUser.keys, ...ovLogsByUser.keys};

    for (String userId in allUserIds) {
      final userPLogs = pLogsByUser[userId] ?? [];
      final userOvLogs = ovLogsByUser[userId] ?? [];

      // Extract symptoms from period logs
      for (var pLog in userPLogs) {
        final activeSymptoms = pLog.symptoms.entries.where((e) => e.value).map((e) => e.key).toList();
        if (activeSymptoms.isNotEmpty) {
          usersLoggingSymptoms.add(userId);
          totalSymptoms += activeSymptoms.length;

          // Determine phase
          final result = CycleAnalyticsEngine.calculate(
            periodLogs: userPLogs, 
            ovulationLogs: userOvLogs, 
            targetDate: pLog.date
          );
          phaseCounts[result.currentPhase] = (phaseCounts[result.currentPhase] ?? 0) + activeSymptoms.length;

          for (var s in activeSymptoms) {
            symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
          }
        }
      }

      // Extract symptoms from ovulation logs
      for (var ovLog in userOvLogs) {
        final activeSymptoms = ovLog.symptoms.entries.where((e) => e.value).map((e) => e.key).toList();
        if (activeSymptoms.isNotEmpty) {
          usersLoggingSymptoms.add(userId);
          totalSymptoms += activeSymptoms.length;

          // Determine phase
          final result = CycleAnalyticsEngine.calculate(
            periodLogs: userPLogs, 
            ovulationLogs: userOvLogs, 
            targetDate: ovLog.date
          );
          phaseCounts[result.currentPhase] = (phaseCounts[result.currentPhase] ?? 0) + activeSymptoms.length;

          for (var s in activeSymptoms) {
            symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
          }
        }
      }
    }

    var sortedSymptoms = symptomCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    // Combine Ovulation and Fertile Window into one for the UI if needed, or keep separate based on UI expectations.
    // The previous fallback had "Menstrual", "Fertile Window", "Ovulation", "Luteal"
    int menstrual = phaseCounts["Menstruation"] ?? 0;
    int fertile = phaseCounts["Fertile Window"] ?? 0;
    int ovulation = phaseCounts["Ovulation"] ?? 0;
    int luteal = phaseCounts["Luteal"] ?? 0;
    int follicular = phaseCounts["Follicular"] ?? 0;
    
    // Merge Follicular appropriately or keep as is? The original had Menstrual, Fertile Window, Ovulation, Luteal. We can just provide all of them.
    int totalPhaseLogs = menstrual + fertile + ovulation + luteal + follicular;

    return {
      "totalSymptomLogs": totalSymptoms,
      "usersLoggingSymptoms": usersLoggingSymptoms.length,
      "avgSymptomsPerUser": usersLoggingSymptoms.isEmpty ? 0.0 : double.parse((totalSymptoms / usersLoggingSymptoms.length).toStringAsFixed(1)),
      "topSymptoms": sortedSymptoms.take(5).toList(),
      "symptomsByPhase": {
        "Menstrual": totalPhaseLogs == 0 ? 0 : (menstrual / totalPhaseLogs * 100).round(),
        "Follicular": totalPhaseLogs == 0 ? 0 : (follicular / totalPhaseLogs * 100).round(),
        "Fertile Window": totalPhaseLogs == 0 ? 0 : (fertile / totalPhaseLogs * 100).round(),
        "Ovulation": totalPhaseLogs == 0 ? 0 : (ovulation / totalPhaseLogs * 100).round(),
        "Luteal": totalPhaseLogs == 0 ? 0 : (luteal / totalPhaseLogs * 100).round(),
      }
    };
  }

  @override
  Future<Map<String, dynamic>> getSymptomsDetails(String symptom, DateTime startDate, DateTime endDate) async {
    final periodSnap = await _firestore
        .collection('period')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final ovulationSnap = await _firestore
        .collection('ovulation')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final pLogs = periodSnap.docs.map((doc) => PeriodLogModel.fromMap(doc.data())).toList();
    final ovLogs = ovulationSnap.docs.map((doc) => OvulationLogModel.fromMap(doc.data())).toList();

    int totalAllSymptoms = 0;
    int specificSymptomLogs = 0;
    Set<String> usersWithSpecificSymptom = {};
    
    Map<String, int> phaseCounts = {
      "Menstruation": 0,
      "Follicular": 0,
      "Ovulation": 0,
      "Fertile Window": 0,
      "Luteal": 0
    };

    // Group logs by user
    Map<String, List<PeriodLogModel>> pLogsByUser = {};
    for (var log in pLogs) {
      pLogsByUser.putIfAbsent(log.userId, () => []).add(log);
    }
    Map<String, List<OvulationLogModel>> ovLogsByUser = {};
    for (var log in ovLogs) {
      ovLogsByUser.putIfAbsent(log.userId, () => []).add(log);
    }

    Set<String> allUserIds = {...pLogsByUser.keys, ...ovLogsByUser.keys};

    for (String userId in allUserIds) {
      final userPLogs = pLogsByUser[userId] ?? [];
      final userOvLogs = ovLogsByUser[userId] ?? [];

      for (var pLog in userPLogs) {
        final activeSymptoms = pLog.symptoms.entries.where((e) => e.value).map((e) => e.key).toList();
        totalAllSymptoms += activeSymptoms.length;
        if (activeSymptoms.contains(symptom)) {
          specificSymptomLogs++;
          usersWithSpecificSymptom.add(userId);
          
          final result = CycleAnalyticsEngine.calculate(
            periodLogs: userPLogs, 
            ovulationLogs: userOvLogs, 
            targetDate: pLog.date
          );
          phaseCounts[result.currentPhase] = (phaseCounts[result.currentPhase] ?? 0) + 1;
        }
      }

      for (var ovLog in userOvLogs) {
        final activeSymptoms = ovLog.symptoms.entries.where((e) => e.value).map((e) => e.key).toList();
        totalAllSymptoms += activeSymptoms.length;
        if (activeSymptoms.contains(symptom)) {
          specificSymptomLogs++;
          usersWithSpecificSymptom.add(userId);
          
          final result = CycleAnalyticsEngine.calculate(
            periodLogs: userPLogs, 
            ovulationLogs: userOvLogs, 
            targetDate: ovLog.date
          );
          phaseCounts[result.currentPhase] = (phaseCounts[result.currentPhase] ?? 0) + 1;
        }
      }
    }

    int percentageOfAll = totalAllSymptoms == 0 ? 0 : (specificSymptomLogs / totalAllSymptoms * 100).round();
    int totalPhaseLogs = specificSymptomLogs;

    return {
      "totalLogs": specificSymptomLogs,
      "users": usersWithSpecificSymptom.length,
      "percentageOfAllLogs": percentageOfAll,
      "byCyclePhase": {
        "Menstrual": totalPhaseLogs == 0 ? 0 : ((phaseCounts["Menstruation"] ?? 0) / totalPhaseLogs * 100).round(),
        "Follicular": totalPhaseLogs == 0 ? 0 : ((phaseCounts["Follicular"] ?? 0) / totalPhaseLogs * 100).round(),
        "Fertile Window": totalPhaseLogs == 0 ? 0 : ((phaseCounts["Fertile Window"] ?? 0) / totalPhaseLogs * 100).round(),
        "Ovulation": totalPhaseLogs == 0 ? 0 : ((phaseCounts["Ovulation"] ?? 0) / totalPhaseLogs * 100).round(),
        "Luteal": totalPhaseLogs == 0 ? 0 : ((phaseCounts["Luteal"] ?? 0) / totalPhaseLogs * 100).round(),
      },
      "intensity": {
        "Mild": 0, // No intensity field in logs
        "Moderate": 0,
        "Severe": 0,
      }
    };
  }

  @override
  Future<Map<String, dynamic>> getCalendarDailySummary(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final periodSnap = await _firestore.collection('period')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .get();

    final ovulationSnap = await _firestore.collection('ovulation')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .get();

    int totalLogs = periodSnap.docs.length + ovulationSnap.docs.length;
    
    Map<String, int> symptomCounts = {};

    for (var doc in periodSnap.docs) {
      final data = doc.data();
      final symptoms = Map<String, bool>.from(data['symptoms'] ?? {});
      for (var entry in symptoms.entries) {
        if (entry.value) {
          symptomCounts[entry.key] = (symptomCounts[entry.key] ?? 0) + 1;
        }
      }
    }
    for (var doc in ovulationSnap.docs) {
      final data = doc.data();
      final symptoms = Map<String, bool>.from(data['symptoms'] ?? {});
      for (var entry in symptoms.entries) {
        if (entry.value) {
          symptomCounts[entry.key] = (symptomCounts[entry.key] ?? 0) + 1;
        }
      }
    }

    var sortedSymptoms = symptomCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    var topSymptomsList = sortedSymptoms.take(3).map((e) => {"name": e.key, "intensity": "N/A"}).toList();

    return {
      "hasPeriod": periodSnap.docs.isNotEmpty,
      "hasOvulation": ovulationSnap.docs.isNotEmpty,
      "topSymptoms": topSymptomsList,
      "totalLogsUsers": totalLogs,
    };
  }
}
