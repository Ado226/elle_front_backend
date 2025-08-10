class CycleDay {
  final DateTime date;
  final String type; // 'period', 'fertile', 'ovulation', 'normal'
  final bool hasReport;
  final String? note;
  final List<String> symptoms;
  
  CycleDay({
    required this.date,
    required this.type,
    this.hasReport = false,
    this.note,
    this.symptoms = const [],
  });
  
  // Create a copy with updated fields
  CycleDay copyWith({
    DateTime? date,
    String? type,
    bool? hasReport,
    String? note,
    List<String>? symptoms,
  }) {
    return CycleDay(
      date: date ?? this.date,
      type: type ?? this.type,
      hasReport: hasReport ?? this.hasReport,
      note: note ?? this.note,
      symptoms: symptoms ?? this.symptoms,
    );
  }
  
  // Check if this day is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  // Get display name for the type
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'period':
        return 'Période';
      case 'fertile':
        return 'Fertile';
      case 'ovulation':
        return 'Ovulation';
      default:
        return 'Normal';
    }
  }
  
  // Check if day is in the current cycle phase
  bool get isSignificantDay {
    return type != 'normal';
  }
  
  @override
  String toString() {
    return 'CycleDay(date: $date, type: $type, hasReport: $hasReport)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CycleDay &&
           other.date == date &&
           other.type == type &&
           other.hasReport == hasReport;
  }
  
  @override
  int get hashCode {
    return date.hashCode ^ type.hashCode ^ hasReport.hashCode;
  }
}

// Mock data generator for testing
class MockCycleData {
  static List<CycleDay> generateMockData() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    List<CycleDay> cycleDays = [];
    
    // Generate days for current month
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      String type = 'normal';
      bool hasReport = false;
      List<String> symptoms = [];
      
      // Mock cycle pattern (28-day cycle starting from day 3)
      final cycleDay = (i + 25) % 28; // Offset to make periods start around day 3
      
      if (cycleDay >= 1 && cycleDay <= 5) {
        type = 'period';
        hasReport = cycleDay <= 3; // Reports on first 3 period days
        symptoms = ['cramps', 'fatigue'];
      } else if (cycleDay >= 9 && cycleDay <= 16) {
        type = 'fertile';
        if (cycleDay == 12 || cycleDay == 15) hasReport = true;
        symptoms = ['cervical_mucus'];
      } else if (cycleDay == 14) {
        type = 'ovulation';
        hasReport = true;
        symptoms = ['ovulation_pain', 'mood_change'];
      }
      
      cycleDays.add(CycleDay(
        date: date,
        type: type,
        hasReport: hasReport,
        symptoms: symptoms,
        note: hasReport ? 'Rapport ajouté' : null,
      ));
    }
    
    return cycleDays;
  }
  
  // Get cycle days for a specific month
  static List<CycleDay> getMockDataForMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    List<CycleDay> cycleDays = [];
    
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      String type = 'normal';
      bool hasReport = false;
      
      // Mock cycle pattern
      final cycleDay = (i + 25) % 28;
      
      if (cycleDay >= 1 && cycleDay <= 5) {
        type = 'period';
        hasReport = cycleDay <= 3;
      } else if (cycleDay >= 9 && cycleDay <= 16) {
        type = 'fertile';
        if (cycleDay == 12 || cycleDay == 15) hasReport = true;
      } else if (cycleDay == 14) {
        type = 'ovulation';
        hasReport = true;
      }
      
      cycleDays.add(CycleDay(
        date: date,
        type: type,
        hasReport: hasReport,
      ));
    }
    
    return cycleDays;
  }
}