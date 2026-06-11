import 'package:flutter_test/flutter_test.dart';
import 'package:glo/model/cycle_analytics_engine.dart';
import 'package:glo/model/period_log_model.dart';
import 'package:glo/model/ovulation_log_model.dart';

void main() {
  group('CycleAnalyticsEngine tests', () {
    test('Calculate cycle stats with no data', () {
      final result = CycleAnalyticsEngine.calculate(
        periodLogs: [],
        ovulationLogs: [],
        targetDate: DateTime(2026, 6, 11),
      );

      expect(result.averageCycleLength, equals(28));
      expect(result.averagePeriodLength, equals(5));
      expect(result.currentCycleDay, equals(1));
      expect(result.currentPhase, equals('Follicular'));
    });

    test('Calculate stats with log history', () {
      final now = DateTime.now();
      final periodLogs = [
        PeriodLogModel(
          id: '1',
          userId: 'user1',
          date: DateTime(2026, 5, 1),
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        ),
        PeriodLogModel(
          id: '2',
          userId: 'user1',
          date: DateTime(2026, 5, 2),
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        ),
        PeriodLogModel(
          id: '3',
          userId: 'user1',
          date: DateTime(2026, 5, 3),
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        ),
        PeriodLogModel(
          id: '4',
          userId: 'user1',
          date: DateTime(2026, 5, 4),
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        ),
        PeriodLogModel(
          id: '5',
          userId: 'user1',
          date: DateTime(2026, 5, 5),
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        ),
        PeriodLogModel(
          id: '6',
          userId: 'user1',
          date: DateTime(2026, 5, 29),
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        ),
        PeriodLogModel(
          id: '7',
          userId: 'user1',
          date: DateTime(2026, 5, 30),
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        ),
        PeriodLogModel(
          id: '8',
          userId: 'user1',
          date: DateTime(2026, 5, 31),
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = CycleAnalyticsEngine.calculate(
        periodLogs: periodLogs,
        ovulationLogs: [],
        targetDate: DateTime(2026, 6, 11),
      );

      // Average stats from 1 past cycle (May 1 to May 29 = 28 days)
      expect(result.averageCycleLength, equals(28));
      expect(result.averagePeriodLength, equals(5));
      expect(result.pastCycles.length, equals(1));
      expect(result.pastCycles[0].lengthInDays, equals(28));
      expect(result.pastCycles[0].periodLength, equals(5));

      // Active cycle: starts May 29. June 11 is 14 days after May 29 (day 14)
      expect(result.currentCycleDay, equals(14));
      // Ovulation day is June 12. So June 11 is day before ovulation (within fertile window)
      expect(result.currentPhase, equals('Fertile Window'));
    });
  });
}
