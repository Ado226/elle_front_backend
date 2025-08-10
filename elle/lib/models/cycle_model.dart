class CycleModel {
  final int id;
  final int userId;
  final DateTime startDate;
  final int cycleLength;
  final int menstruationLength;
  final List<DateTime> intercourseData;

  CycleModel({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.cycleLength,
    required this.menstruationLength,
    required this.intercourseData,
  });

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id'],
      userId: json['user_id'],
      startDate: DateTime.parse(json['start_date']),
      cycleLength: json['cycle_length'],
      menstruationLength: json['menstruation_length'],
      intercourseData: (json['intercourse_dates'] as List)
          .map((date) => DateTime.parse(date))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'cycle_length': cycleLength,
      'menstruation_length': menstruationLength,
      'intercourse_dates': intercourseData
          .map((date) => date.toIso8601String().split('T')[0])
          .toList(),
    };
  }
}

class CycleCalculations {
  final CycleModel cycleData;
  final DateTime ovulationDate;
  final List<DateTime> fertileWindow;
  final List<DateTime> menstruationPeriod;
  final List<DateTime> safeDays;
  final String currentPhase;
  final int daysUntilNextPeriod;

  CycleCalculations({
    required this.cycleData,
    required this.ovulationDate,
    required this.fertileWindow,
    required this.menstruationPeriod,
    required this.safeDays,
    required this.currentPhase,
    required this.daysUntilNextPeriod,
  });

  factory CycleCalculations.fromJson(Map<String, dynamic> json) {
    return CycleCalculations(
      cycleData: CycleModel.fromJson(json['cycle_data']),
      ovulationDate: DateTime.parse(json['ovulation_date']),
      fertileWindow: (json['fertile_window'] as List)
          .map((date) => DateTime.parse(date))
          .toList(),
      menstruationPeriod: (json['menstruation_period'] as List)
          .map((date) => DateTime.parse(date))
          .toList(),
      safeDays: (json['safe_days'] as List)
          .map((date) => DateTime.parse(date))
          .toList(),
      currentPhase: json['current_phase'],
      daysUntilNextPeriod: json['days_until_next_period'],
    );
  }
}

class IntercourseToggle {
  final DateTime date;
  final String action; // "add" or "remove"

  IntercourseToggle({
    required this.date,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'action': action,
    };
  }
}

class CycleCreate {
  final int userId;
  final DateTime startDate;
  final int cycleLength;
  final int menstruationLength;
  final List<DateTime> intercourseData;

  CycleCreate({
    required this.userId,
    required this.startDate,
    required this.cycleLength,
    required this.menstruationLength,
    this.intercourseData = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'cycle_length': cycleLength,
      'menstruation_length': menstruationLength,
      'intercourse_dates': intercourseData
          .map((date) => date.toIso8601String().split('T')[0])
          .toList(),
    };
  }
}