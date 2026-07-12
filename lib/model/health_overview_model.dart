import 'package:flutter/material.dart';

class HealthOverviewData {
  final String dateRange;
  final int activeUsers;
  final int totalVisits;
  final int totalTreatments;
  final int totalReminders;

  final String activeUsersChange;
  final String visitsChange;
  final String treatmentsChange;
  final String remindersChange;

  final String activeUsersDetails;
  final String visitsDetails;
  final String treatmentsDetails;
  final String remindersDetails;

  final List<TreatmentStat> topTreatments;

  const HealthOverviewData({
    required this.dateRange,
    required this.activeUsers,
    required this.totalVisits,
    required this.totalTreatments,
    required this.totalReminders,
    required this.activeUsersChange,
    required this.visitsChange,
    required this.treatmentsChange,
    required this.remindersChange,
    required this.activeUsersDetails,
    required this.visitsDetails,
    required this.treatmentsDetails,
    required this.remindersDetails,
    required this.topTreatments,
  });

  factory HealthOverviewData.empty() {
    return const HealthOverviewData(
      dateRange: 'No data available yet',
      activeUsers: 0,
      totalVisits: 0,
      totalTreatments: 0,
      totalReminders: 0,
      activeUsersChange: '0%',
      visitsChange: '0%',
      treatmentsChange: '0%',
      remindersChange: '0%',
      activeUsersDetails: 'No user data has been added yet.',
      visitsDetails: 'No visit data has been added yet.',
      treatmentsDetails: 'No treatment data has been added yet.',
      remindersDetails: 'No reminder data has been added yet.',
      topTreatments: [],
    );
  }
}

class TreatmentStat {
  final String name;
  final int count;

  const TreatmentStat({
    required this.name,
    required this.count,
  });
}

class StatCardData {
  final String title;
  final String value;
  final String percent;
  final IconData icon;
  final String details;

  const StatCardData({
    required this.title,
    required this.value,
    required this.percent,
    required this.icon,
    required this.details,
  });
}