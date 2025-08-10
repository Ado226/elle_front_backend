import 'package:flutter/material.dart';

enum CycleDayType {
  menstruation,
  fertile,
  ovulation,
  safe,
}

enum IntercourseType {
  none,
  protected,
  unprotected,
}

class CycleDay {
  final DateTime date;
  final CycleDayType type;
  final IntercourseType intercourse;
  final String? notes;
  final List<String> symptoms;

  const CycleDay({
    required this.date,
    required this.type,
    this.intercourse = IntercourseType.none,
    this.notes,
    this.symptoms = const [],
  });

  CycleDay copyWith({
    DateTime? date,
    CycleDayType? type,
    IntercourseType? intercourse,
    String? notes,
    List<String>? symptoms,
  }) {
    return CycleDay(
      date: date ?? this.date,
      type: type ?? this.type,
      intercourse: intercourse ?? this.intercourse,
      notes: notes ?? this.notes,
      symptoms: symptoms ?? this.symptoms,
    );
  }

  bool get hasIntercourse => intercourse != IntercourseType.none;

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  Color get backgroundColor {
    switch (type) {
      case CycleDayType.menstruation:
        return const Color(0xFFA0522D); // Sienna
      case CycleDayType.fertile:
        return const Color(0xFF228B22); // Forest Green
      case CycleDayType.ovulation:
        return const Color(0xFFDAA520); // Golden
      case CycleDayType.safe:
        return const Color(0xFF87CEEB); // Sky Blue
    }
  }

  String get typeDisplayName {
    switch (type) {
      case CycleDayType.menstruation:
        return 'Menstruation';
      case CycleDayType.fertile:
        return 'Fertile';
      case CycleDayType.ovulation:
        return 'Ovulation';
      case CycleDayType.safe:
        return 'Safe';
    }
  }

  String get typeEmoji {
    switch (type) {
      case CycleDayType.menstruation:
        return '🩸';
      case CycleDayType.fertile:
        return '🌿';
      case CycleDayType.ovulation:
        return '🌟';
      case CycleDayType.safe:
        return '💙';
    }
  }
}

class MenstrualCycle {
  final DateTime lastPeriodStart;
  final int cycleLength; // Average cycle length in days
  final int menstruationDuration; // Period duration in days
  final Map<DateTime, CycleDay> cycleDays;

  const MenstrualCycle({
    required this.lastPeriodStart,
    this.cycleLength = 28,
    this.menstruationDuration = 5,
    this.cycleDays = const {},
  });

  MenstrualCycle copyWith({
    DateTime? lastPeriodStart,
    int? cycleLength,
    int? menstruationDuration,
    Map<DateTime, CycleDay>? cycleDays,
  }) {
    return MenstrualCycle(
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      cycleLength: cycleLength ?? this.cycleLength,
      menstruationDuration: menstruationDuration ?? this.menstruationDuration,
      cycleDays: cycleDays ?? this.cycleDays,
    );
  }

  // Calculate ovulation day (14 days before next period)
  DateTime get ovulationDay {
    return lastPeriodStart.add(Duration(days: cycleLength - 14));
  }

  // Calculate fertile window (4 days before ovulation to 1 day after)
  DateTimeRange get fertileWindow {
    final fertileStart = ovulationDay.subtract(const Duration(days: 4));
    final fertileEnd = ovulationDay.add(const Duration(days: 1));
    return DateTimeRange(start: fertileStart, end: fertileEnd);
  }

  // Get next period start date
  DateTime get nextPeriodStart {
    return lastPeriodStart.add(Duration(days: cycleLength));
  }

  // Get current cycle day number (1-based)
  int getCurrentCycleDay() {
    final now = DateTime.now();
    final daysSinceLastPeriod = now.difference(lastPeriodStart).inDays;
    return (daysSinceLastPeriod % cycleLength) + 1;
  }

  // Calculate cycle day type for a given date
  CycleDayType getCycleDayType(DateTime date) {
    final daysSinceLastPeriod = date.difference(lastPeriodStart).inDays;
    final cycleDay = (daysSinceLastPeriod % cycleLength) + 1;

    // Menstruation period
    if (cycleDay <= menstruationDuration) {
      return CycleDayType.menstruation;
    }

    // Calculate ovulation day in current cycle
    final ovulationDayInCycle = cycleLength - 14 + 1; // 1-based
    
    // Ovulation day
    if (cycleDay == ovulationDayInCycle) {
      return CycleDayType.ovulation;
    }

    // Fertile window (4 days before ovulation to 1 day after)
    final fertileStart = ovulationDayInCycle - 4;
    final fertileEnd = ovulationDayInCycle + 1;
    
    if (cycleDay >= fertileStart && cycleDay <= fertileEnd) {
      return CycleDayType.fertile;
    }

    // Safe days
    return CycleDayType.safe;
  }

  // Get cycle day for a specific date
  CycleDay getCycleDay(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    
    // Return existing cycle day if it exists
    if (cycleDays.containsKey(dateKey)) {
      return cycleDays[dateKey]!;
    }

    // Create new cycle day based on calculations
    return CycleDay(
      date: dateKey,
      type: getCycleDayType(date),
    );
  }

  // Add or update a cycle day
  MenstrualCycle updateCycleDay(CycleDay cycleDay) {
    final dateKey = DateTime(cycleDay.date.year, cycleDay.date.month, cycleDay.date.day);
    final updatedDays = Map<DateTime, CycleDay>.from(cycleDays);
    updatedDays[dateKey] = cycleDay;
    
    return copyWith(cycleDays: updatedDays);
  }

  // Get days until next period
  int getDaysUntilNextPeriod() {
    final now = DateTime.now();
    final nextPeriod = nextPeriodStart;
    
    if (now.isAfter(nextPeriod)) {
      // Calculate next cycle
      final cyclesSinceLastPeriod = now.difference(lastPeriodStart).inDays ~/ cycleLength;
      final actualNextPeriod = lastPeriodStart.add(Duration(days: (cyclesSinceLastPeriod + 1) * cycleLength));
      return actualNextPeriod.difference(now).inDays;
    }
    
    return nextPeriod.difference(now).inDays;
  }

  // Get current phase description
  String getCurrentPhaseDescription() {
    final now = DateTime.now();
    final currentType = getCycleDayType(now);
    final daysUntilPeriod = getDaysUntilNextPeriod();
    
    switch (currentType) {
      case CycleDayType.menstruation:
        final currentDay = getCurrentCycleDay();
        return 'Day $currentDay of your period';
      case CycleDayType.fertile:
        return 'You are in your fertile window 🌿';
      case CycleDayType.ovulation:
        return 'Today is your ovulation day 🌟';
      case CycleDayType.safe:
        if (daysUntilPeriod <= 3) {
          return 'Your period may start in $daysUntilPeriod day${daysUntilPeriod == 1 ? '' : 's'} 🩸';
        }
        return 'Today is a safe day 💙';
    }
  }

  // Get fertility status message
  String getFertilityMessage() {
    final currentType = getCycleDayType(DateTime.now());
    
    switch (currentType) {
      case CycleDayType.menstruation:
        return 'Low fertility - menstruation period';
      case CycleDayType.fertile:
        return 'High fertility - fertile window';
      case CycleDayType.ovulation:
        return 'Peak fertility - ovulation day';
      case CycleDayType.safe:
        return 'Low fertility - safe day';
    }
  }
}