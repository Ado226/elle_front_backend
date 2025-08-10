import 'package:shared_preferences/shared_preferences.dart';

class CyclePredictionService {
  static const int DEFAULT_CYCLE_LENGTH = 28;
  static const int DEFAULT_PERIOD_LENGTH = 5;
  
  /// Calculate next period based on user's cycle history
  static DateTime calculateNextPeriod({
    required DateTime lastPeriodDate,
    required int cycleDuration,
    List<DateTime>? previousPeriods,
  }) {
    // Use personal cycle data if available, otherwise use average
    int personalCycleLength = cycleDuration;
    
    // If user has historical data, calculate average cycle length
    if (previousPeriods != null && previousPeriods.length >= 2) {
      personalCycleLength = _calculateAverageCycleLength(previousPeriods);
    }
    
    return lastPeriodDate.add(Duration(days: personalCycleLength));
  }
  
  /// Calculate average cycle length from historical data
  static int _calculateAverageCycleLength(List<DateTime> previousPeriods) {
    if (previousPeriods.length < 2) return DEFAULT_CYCLE_LENGTH;
    
    // Sort periods chronologically
    List<DateTime> sortedPeriods = List.from(previousPeriods)..sort();
    
    List<int> cycleLengths = [];
    for (int i = 1; i < sortedPeriods.length; i++) {
      int daysBetween = sortedPeriods[i].difference(sortedPeriods[i - 1]).inDays;
      if (daysBetween >= 21 && daysBetween <= 35) { // Valid cycle range
        cycleLengths.add(daysBetween);
      }
    }
    
    if (cycleLengths.isEmpty) return DEFAULT_CYCLE_LENGTH;
    
    // Calculate average
    int totalDays = cycleLengths.reduce((a, b) => a + b);
    return (totalDays / cycleLengths.length).round();
  }
  
  /// Calculate fertile window based on next period date
  static List<DateTime> calculateFertileWindow(DateTime nextPeriod) {
    // Ovulation typically occurs 14 days before next period
    DateTime ovulationDate = nextPeriod.subtract(Duration(days: 14));
    
    // Fertile window: 5 days before ovulation + ovulation day + 1 day after
    List<DateTime> fertileWindow = [];
    for (int i = -5; i <= 1; i++) {
      fertileWindow.add(ovulationDate.add(Duration(days: i)));
    }
    return fertileWindow;
  }
  
  /// Calculate ovulation date based on next period
  static DateTime calculateOvulationDate(DateTime nextPeriod) {
    return nextPeriod.subtract(Duration(days: 14));
  }
  
  /// Calculate days until next period
  static int daysUntilNextPeriod(DateTime nextPeriod) {
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    DateTime nextPeriodDate = DateTime(nextPeriod.year, nextPeriod.month, nextPeriod.day);
    return nextPeriodDate.difference(todayDate).inDays;
  }
  
  /// Get cycle progress as percentage (0.0 to 1.0)
  static double getCycleProgress({
    required DateTime lastPeriodDate,
    required int cycleDuration,
  }) {
    DateTime today = DateTime.now();
    int daysSinceLastPeriod = today.difference(lastPeriodDate).inDays;
    
    if (daysSinceLastPeriod < 0) return 0.0;
    if (daysSinceLastPeriod >= cycleDuration) return 1.0;
    
    return daysSinceLastPeriod / cycleDuration;
  }
  
  /// Check if today is in fertile window
  static bool isInFertileWindow({
    required DateTime lastPeriodDate,
    required int cycleDuration,
  }) {
    DateTime nextPeriod = calculateNextPeriod(
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
    );
    
    List<DateTime> fertileWindow = calculateFertileWindow(nextPeriod);
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    
    return fertileWindow.any((date) => 
      date.year == todayDate.year && 
      date.month == todayDate.month && 
      date.day == todayDate.day
    );
  }
  
  /// Check if today is ovulation day
  static bool isOvulationDay({
    required DateTime lastPeriodDate,
    required int cycleDuration,
  }) {
    DateTime nextPeriod = calculateNextPeriod(
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
    );
    
    DateTime ovulationDate = calculateOvulationDate(nextPeriod);
    DateTime today = DateTime.now();
    
    return ovulationDate.year == today.year && 
           ovulationDate.month == today.month && 
           ovulationDate.day == today.day;
  }
  
  /// Save cycle data to SharedPreferences
  static Future<void> saveCycleData({
    required DateTime lastPeriodDate,
    required int cycleDuration,
    int? periodLength,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('last_period_date', lastPeriodDate.toIso8601String());
    await prefs.setInt('cycle_duration', cycleDuration);
    await prefs.setInt('period_length', periodLength ?? DEFAULT_PERIOD_LENGTH);
  }
  
  /// Load cycle data from SharedPreferences
  static Future<Map<String, dynamic>?> loadCycleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      String? lastPeriodStr = prefs.getString('last_period_date');
      int? cycleDuration = prefs.getInt('cycle_duration');
      int? periodLength = prefs.getInt('period_length');
      
      if (lastPeriodStr == null || cycleDuration == null) {
        return null;
      }
      
      return {
        'lastPeriodDate': DateTime.parse(lastPeriodStr),
        'cycleDuration': cycleDuration,
        'periodLength': periodLength ?? DEFAULT_PERIOD_LENGTH,
      };
    } catch (e) {
      return null;
    }
  }
  
  /// Add intercourse day (❤️ functionality)
  static Future<void> addIntercourseDay(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> intercourseDays = prefs.getStringList('intercourse_days') ?? [];
    
    String dateStr = date.toIso8601String().split('T')[0];
    if (!intercourseDays.contains(dateStr)) {
      intercourseDays.add(dateStr);
      await prefs.setStringList('intercourse_days', intercourseDays);
    }
  }
  
  /// Get intercourse days
  static Future<List<DateTime>> getIntercourseDays() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> intercourseDays = prefs.getStringList('intercourse_days') ?? [];
    
    return intercourseDays.map((dateStr) => DateTime.parse(dateStr)).toList();
  }
  
  /// Check if date is an intercourse day
  static Future<bool> isIntercourseDay(DateTime date) async {
    List<DateTime> intercourseDays = await getIntercourseDays();
    String dateStr = date.toIso8601String().split('T')[0];
    
    return intercourseDays.any((d) => d.toIso8601String().split('T')[0] == dateStr);
  }
  
  /// Get current cycle phase
  static String getCurrentCyclePhase({
    required DateTime lastPeriodDate,
    required int cycleDuration,
    int periodLength = DEFAULT_PERIOD_LENGTH,
  }) {
    DateTime today = DateTime.now();
    int daysSinceLastPeriod = today.difference(lastPeriodDate).inDays;
    
    if (daysSinceLastPeriod < 0) {
      return 'Invalid';
    } else if (daysSinceLastPeriod < periodLength) {
      return 'Menstrual';
    } else if (daysSinceLastPeriod < (cycleDuration / 2 - 3)) {
      return 'Follicular';
    } else if (daysSinceLastPeriod >= (cycleDuration / 2 - 3) && 
               daysSinceLastPeriod <= (cycleDuration / 2 + 1)) {
      return 'Fertile';
    } else if (daysSinceLastPeriod == (cycleDuration / 2).round()) {
      return 'Ovulation';
    } else {
      return 'Luteal';
    }
  }
  
  /// Format date in French
  static String formatDateInFrench(DateTime date) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
  
  /// Format days until period in French
  static String formatDaysUntilInFrench(int days) {
    if (days == 0) return 'Aujourd\'hui';
    if (days == 1) return 'Demain';
    if (days < 0) return 'En retard de ${days.abs()} jour(s)';
    return 'Dans $days jours';
  }
}