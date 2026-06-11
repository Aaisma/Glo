import '../model/period_log_model.dart';
import '../model/ovulation_log_model.dart';

class CycleData {
  final int number;
  final DateTime startDate;
  final DateTime endDate;
  final int lengthInDays;
  final int periodLength;
  final DateTime? ovulationDate;
  final bool isOvulationConfirmed;
  final List<DateTime> periodDays;
  final List<DateTime> fertileDays;

  CycleData({
    required this.number,
    required this.startDate,
    required this.endDate,
    required this.lengthInDays,
    required this.periodLength,
    this.ovulationDate,
    required this.isOvulationConfirmed,
    required this.periodDays,
    required this.fertileDays,
  });
}

class CycleAnalyticsResult {
  final int averageCycleLength;
  final int averagePeriodLength;
  final int averageOvulationDay;
  final int regularityPercentage;
  final int shortestCycle;
  final int longestCycle;
  final int currentCycleDay;
  final String currentPhase;
  final String nextPredictedEventText;
  final DateTime? nextPredictedEventDate;
  final List<CycleData> pastCycles;
  final DateTime? lastPeriodStartDate;

  CycleAnalyticsResult({
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.averageOvulationDay,
    required this.regularityPercentage,
    required this.shortestCycle,
    required this.longestCycle,
    required this.currentCycleDay,
    required this.currentPhase,
    required this.nextPredictedEventText,
    this.nextPredictedEventDate,
    required this.pastCycles,
    this.lastPeriodStartDate,
  });
}

class CycleAnalyticsEngine {
  static CycleAnalyticsResult calculate({
    required List<PeriodLogModel> periodLogs,
    required List<OvulationLogModel> ovulationLogs,
    DateTime? targetDate,
  }) {
    final today = targetDate ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // 1. Find all period days and sort them ascending
    final List<DateTime> periodDays = periodLogs
        .where((l) => l.isPeriodDay)
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toList();
    periodDays.sort((a, b) => a.compareTo(b));

    // 2. Group contiguous period days into periods (split if gap > 2 days)
    final List<List<DateTime>> periods = [];
    if (periodDays.isNotEmpty) {
      List<DateTime> currentPeriod = [periodDays.first];
      for (int i = 1; i < periodDays.length; i++) {
        final prev = periodDays[i - 1];
        final curr = periodDays[i];
        if (curr.difference(prev).inDays <= 3) {
          // A gap of 1, 2 or 3 days is grouped together (some people have spotting/pauses)
          currentPeriod.add(curr);
        } else {
          periods.add(currentPeriod);
          currentPeriod = [curr];
        }
      }
      periods.add(currentPeriod);
    }

    // Period starts (S_i)
    final List<DateTime> periodStarts = periods.map((p) => p.first).toList();
    periodStarts.sort((a, b) => a.compareTo(b));

    final List<CycleData> pastCycles = [];
    int cycleNumber = 1;

    // 3. Build past cycles
    for (int i = 0; i < periodStarts.length - 1; i++) {
      final start = periodStarts[i];
      final nextStart = periodStarts[i + 1];
      final end = nextStart.subtract(const Duration(days: 1));
      final length = end.difference(start).inDays + 1;
      
      final cyclePeriodDays = periodDays.where((d) => d.isAfter(start.subtract(const Duration(days: 1))) && d.isBefore(nextStart)).toList();
      final pLength = cyclePeriodDays.length;

      // Find ovulation logs for this cycle range
      final cycleOvulationLogs = ovulationLogs.where((l) {
        final d = DateTime(l.date.year, l.date.month, l.date.day);
        return d.isAfter(start.subtract(const Duration(days: 1))) && d.isBefore(nextStart);
      }).toList();

      DateTime? ovulationDate;
      bool isOvulationConfirmed = false;

      // Check if user logged manual ovulation
      final manualOv = cycleOvulationLogs.where((l) => l.isOvulationDay).toList();
      if (manualOv.isNotEmpty) {
        ovulationDate = DateTime(manualOv.first.date.year, manualOv.first.date.month, manualOv.first.date.day);
        isOvulationConfirmed = true;
      } else {
        // Check symptoms for confirmation
        final confirmedLog = cycleOvulationLogs.where((l) {
          final isPositiveTest = l.symptoms['Ovulation Test_Positive'] == true || l.symptoms['Positive'] == true || l.symptoms['Ovulation Test'] == true;
          final isPain = l.symptoms['Ovulation Pain'] == true;
          final isEggWhite = l.symptoms['Vaginal Discharge_Egg white'] == true || l.symptoms['Egg white'] == true;
          return isPositiveTest || isPain || isEggWhite;
        }).toList();

        if (confirmedLog.isNotEmpty) {
          ovulationDate = DateTime(confirmedLog.first.date.year, confirmedLog.first.date.month, confirmedLog.first.date.day);
          isOvulationConfirmed = true;
        }
      }

      // Default to 14 days before next period start if not found
      ovulationDate ??= nextStart.subtract(const Duration(days: 14));

      // Fertile days: 3 days before ovulation, ovulation day, 2 days after
      final fertileDays = <DateTime>[];
      for (int offset = -3; offset <= 2; offset++) {
        fertileDays.add(ovulationDate.add(Duration(days: offset)));
      }

      pastCycles.add(CycleData(
        number: cycleNumber++,
        startDate: start,
        endDate: end,
        lengthInDays: length,
        periodLength: pLength,
        ovulationDate: ovulationDate,
        isOvulationConfirmed: isOvulationConfirmed,
        periodDays: cyclePeriodDays,
        fertileDays: fertileDays,
      ));
    }

    // 4. Calculate stats from past cycles
    int avgCycleLength = 28;
    int avgPeriodLength = 5;
    int avgOvulationDay = 14;
    int shortestCycle = 28;
    int longestCycle = 28;
    int regularityPercentage = 95;

    if (pastCycles.isNotEmpty) {
      final lengths = pastCycles.map((c) => c.lengthInDays).toList();
      final pLengths = pastCycles.map((c) => c.periodLength).toList();

      avgCycleLength = (lengths.reduce((a, b) => a + b) / lengths.length).round();
      avgPeriodLength = (pLengths.reduce((a, b) => a + b) / pLengths.length).round();
      
      shortestCycle = lengths.reduce((a, b) => a < b ? a : b);
      longestCycle = lengths.reduce((a, b) => a > b ? a : b);

      // Average ovulation relative to start
      final ovOffsets = pastCycles
          .map((c) => c.ovulationDate!.difference(c.startDate).inDays + 1)
          .toList();
      avgOvulationDay = (ovOffsets.reduce((a, b) => a + b) / ovOffsets.length).round();

      // Regularity %
      int regularCount = 0;
      for (final l in lengths) {
        if ((l - avgCycleLength).abs() <= 2) {
          regularCount++;
        }
      }
      regularityPercentage = ((regularCount / lengths.length) * 100).round();
    }

    // 5. Active Cycle Calculations
    final lastPeriodStart = periodStarts.isNotEmpty ? periodStarts.last : null;
    int currentCycleDay = 1;
    String currentPhase = "Follicular";
    String nextEventText = "Log period to predict cycle";
    DateTime? nextEventDate;

    if (lastPeriodStart != null) {
      currentCycleDay = today.difference(lastPeriodStart).inDays + 1;
      final nextPeriod = lastPeriodStart.add(Duration(days: avgCycleLength));
      
      // Predict ovulation for this cycle
      DateTime predictedOvulation = nextPeriod.subtract(const Duration(days: 14));
      bool isCurrentOvulationConfirmed = false;

      // Check if user has confirmed ovulation in active cycle
      final cycleOvulationLogs = ovulationLogs.where((l) {
        final d = DateTime(l.date.year, l.date.month, l.date.day);
        return d.isAfter(lastPeriodStart.subtract(const Duration(days: 1)));
      }).toList();

      final activeManualOv = cycleOvulationLogs.where((l) => l.isOvulationDay).toList();
      if (activeManualOv.isNotEmpty) {
        predictedOvulation = DateTime(activeManualOv.first.date.year, activeManualOv.first.date.month, activeManualOv.first.date.day);
        isCurrentOvulationConfirmed = true;
      } else {
        final activeConfirmedLog = cycleOvulationLogs.where((l) {
          final isPositiveTest = l.symptoms['Ovulation Test_Positive'] == true || l.symptoms['Positive'] == true || l.symptoms['Ovulation Test'] == true;
          final isPain = l.symptoms['Ovulation Pain'] == true;
          final isEggWhite = l.symptoms['Vaginal Discharge_Egg white'] == true || l.symptoms['Egg white'] == true;
          return isPositiveTest || isPain || isEggWhite;
        }).toList();

        if (activeConfirmedLog.isNotEmpty) {
          predictedOvulation = DateTime(activeConfirmedLog.first.date.year, activeConfirmedLog.first.date.month, activeConfirmedLog.first.date.day);
          isCurrentOvulationConfirmed = true;
        }
      }

      final activeFertileStart = predictedOvulation.subtract(const Duration(days: 3));
      final activeFertileEnd = predictedOvulation.add(const Duration(days: 2));

      // Phase identification
      final todayNormalized = DateTime(today.year, today.month, today.day);
      
      // Is today logged as period?
      final isPeriodToday = periodLogs.any((l) => l.isPeriodDay && DateTime(l.date.year, l.date.month, l.date.day) == todayNormalized);

      if (isPeriodToday || (currentCycleDay >= 1 && currentCycleDay <= avgPeriodLength)) {
        currentPhase = "Menstruation";
      } else if (todayNormalized == predictedOvulation) {
        currentPhase = "Ovulation";
      } else if (todayNormalized.isAfter(activeFertileStart.subtract(const Duration(days: 1))) &&
                 todayNormalized.isBefore(activeFertileEnd.add(const Duration(days: 1)))) {
        currentPhase = "Fertile Window";
      } else if (todayNormalized.isBefore(activeFertileStart)) {
        currentPhase = "Follicular";
      } else {
        currentPhase = "Luteal";
      }

      // Predictions for next events
      if (todayNormalized.isBefore(predictedOvulation)) {
        final days = predictedOvulation.difference(todayNormalized).inDays;
        nextEventText = days == 0 ? "Ovulation is today" : "Ovulation expected in $days days";
        nextEventDate = predictedOvulation;
      } else if (todayNormalized.isBefore(nextPeriod)) {
        final days = nextPeriod.difference(todayNormalized).inDays;
        nextEventText = days == 0 ? "Period starts today" : "Period expected in $days days";
        nextEventDate = nextPeriod;
      } else {
        final days = todayNormalized.difference(nextPeriod).inDays;
        nextEventText = days == 0 ? "Period starts today" : "Period is $days days late";
        nextEventDate = nextPeriod;
      }
    }

    return CycleAnalyticsResult(
      averageCycleLength: avgCycleLength,
      averagePeriodLength: avgPeriodLength,
      averageOvulationDay: avgOvulationDay,
      regularityPercentage: regularityPercentage,
      shortestCycle: shortestCycle,
      longestCycle: longestCycle,
      currentCycleDay: currentCycleDay,
      currentPhase: currentPhase,
      nextPredictedEventText: nextEventText,
      nextPredictedEventDate: nextEventDate,
      pastCycles: pastCycles,
      lastPeriodStartDate: lastPeriodStart,
    );
  }
}
