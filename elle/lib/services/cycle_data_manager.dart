import 'package:shared_preferences/shared_preferences.dart';
import 'cycle_prediction_service.dart';

/// Centralized data manager for cycle-related operations
/// Provides caching, error handling, and data consistency
class CycleDataManager {
  static CycleDataManager? _instance;
  static CycleDataManager get instance => _instance ??= CycleDataManager._();
  CycleDataManager._();

  // Cache for cycle data
  CycleData? _cachedData;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// Load cycle data with caching and error handling
  Future<CycleDataResult> loadCycleData({bool forceRefresh = false}) async {
    try {
      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && _isCacheValid()) {
        return CycleDataResult.success(_cachedData!);
      }

      final rawData = await CyclePredictionService.loadCycleData();
      
      if (rawData == null) {
        return const CycleDataResult.noData();
      }

      // Process the raw data into a structured format
      final cycleData = await _processCycleData(rawData);
      
      // Cache the processed data
      _cachedData = cycleData;
      _lastCacheUpdate = DateTime.now();
      
      return CycleDataResult.success(cycleData);
      
    } on SharedPreferencesException catch (e) {
      return CycleDataResult.error(
        'Erreur d\'accès aux données: ${e.toString()}',
        CycleDataErrorType.storage,
      );
    } on FormatException catch (e) {
      return CycleDataResult.error(
        'Données corrompues: ${e.toString()}',
        CycleDataErrorType.dataCorruption,
      );
    } catch (e) {
      return CycleDataResult.error(
        'Erreur inattendue: ${e.toString()}',
        CycleDataErrorType.unknown,
      );
    }
  }

  /// Save cycle data with validation and error handling
  Future<CycleDataResult> saveCycleData({
    required DateTime lastPeriodDate,
    required int cycleDuration,
    int? periodLength,
  }) async {
    try {
      // Validate input data
      final validationResult = _validateCycleData(
        lastPeriodDate: lastPeriodDate,
        cycleDuration: cycleDuration,
        periodLength: periodLength,
      );

      if (!validationResult.isValid) {
        return CycleDataResult.error(
          validationResult.errorMessage!,
          CycleDataErrorType.validation,
        );
      }

      // Save to SharedPreferences
      await CyclePredictionService.saveCycleData(
        lastPeriodDate: lastPeriodDate,
        cycleDuration: cycleDuration,
        periodLength: periodLength,
      );

      // Update cache
      await loadCycleData(forceRefresh: true);
      
      return CycleDataResult.success(_cachedData!);
      
    } on SharedPreferencesException catch (e) {
      return CycleDataResult.error(
        'Erreur de sauvegarde: ${e.toString()}',
        CycleDataErrorType.storage,
      );
    } catch (e) {
      return CycleDataResult.error(
        'Erreur lors de la sauvegarde: ${e.toString()}',
        CycleDataErrorType.unknown,
      );
    }
  }

  /// Add intercourse day with error handling
  Future<CycleDataResult> addIntercourseDay(DateTime date) async {
    try {
      await CyclePredictionService.addIntercourseDay(date);
      
      // Refresh cache to include new intercourse data
      await loadCycleData(forceRefresh: true);
      
      return CycleDataResult.success(_cachedData!);
      
    } catch (e) {
      return CycleDataResult.error(
        'Erreur lors de l\'ajout: ${e.toString()}',
        CycleDataErrorType.storage,
      );
    }
  }

  /// Get intercourse days with error handling
  Future<List<DateTime>> getIntercourseDays() async {
    try {
      return await CyclePredictionService.getIntercourseDays();
    } catch (e) {
      return [];
    }
  }

  /// Clear all cycle data
  Future<void> clearCycleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_period_date');
      await prefs.remove('cycle_duration');
      await prefs.remove('period_length');
      await prefs.remove('intercourse_days');
      
      // Clear cache
      _cachedData = null;
      _lastCacheUpdate = null;
      
    } catch (e) {
      // Silent fail for clearing data
    }
  }

  /// Check if user has completed cycle setup
  Future<bool> hasCompletedSetup() async {
    final result = await loadCycleData();
    return result.isSuccess && result.data != null;
  }

  /// Get current cache status
  bool get hasCachedData => _cachedData != null && _isCacheValid();

  /// Force refresh of cached data
  Future<CycleDataResult> refreshData() => loadCycleData(forceRefresh: true);

  // Private helper methods

  bool _isCacheValid() {
    if (_cachedData == null || _lastCacheUpdate == null) return false;
    
    final now = DateTime.now();
    return now.difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  Future<CycleData> _processCycleData(Map<String, dynamic> rawData) async {
    final lastPeriodDate = rawData['lastPeriodDate'] as DateTime;
    final cycleDuration = rawData['cycleDuration'] as int;
    final periodLength = rawData['periodLength'] as int? ?? 5;

    // Calculate derived data
    final nextPeriodDate = CyclePredictionService.calculateNextPeriod(
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
    );

    final daysUntilNextPeriod = CyclePredictionService.daysUntilNextPeriod(nextPeriodDate);
    
    final currentPhase = CyclePredictionService.getCurrentCyclePhase(
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
      periodLength: periodLength,
    );

    final cycleProgress = CyclePredictionService.getCycleProgress(
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
    );

    final fertileWindow = CyclePredictionService.calculateFertileWindow(nextPeriodDate);
    final ovulationDate = CyclePredictionService.calculateOvulationDate(nextPeriodDate);
    
    final isInFertileWindow = CyclePredictionService.isInFertileWindow(
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
    );

    final isOvulationDay = CyclePredictionService.isOvulationDay(
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
    );

    // Load intercourse days
    final intercourseDays = await CyclePredictionService.getIntercourseDays();

    return CycleData(
      lastPeriodDate: lastPeriodDate,
      nextPeriodDate: nextPeriodDate,
      cycleDuration: cycleDuration,
      periodLength: periodLength,
      daysUntilNextPeriod: daysUntilNextPeriod,
      currentPhase: currentPhase,
      cycleProgress: cycleProgress,
      fertileWindow: fertileWindow,
      ovulationDate: ovulationDate,
      isInFertileWindow: isInFertileWindow,
      isOvulationDay: isOvulationDay,
      intercourseDays: intercourseDays,
    );
  }

  ValidationResult _validateCycleData({
    required DateTime lastPeriodDate,
    required int cycleDuration,
    int? periodLength,
  }) {
    final now = DateTime.now();
    
    // Check if last period date is not in the future
    if (lastPeriodDate.isAfter(now)) {
      return ValidationResult.invalid('La date des dernières règles ne peut pas être dans le futur');
    }
    
    // Check if last period date is not too far in the past (more than 2 years)
    final twoYearsAgo = now.subtract(const Duration(days: 730));
    if (lastPeriodDate.isBefore(twoYearsAgo)) {
      return ValidationResult.invalid('La date des dernières règles est trop ancienne');
    }
    
    // Validate cycle duration
    if (cycleDuration < 21 || cycleDuration > 35) {
      return ValidationResult.invalid('La durée du cycle doit être entre 21 et 35 jours');
    }
    
    // Validate period length if provided
    if (periodLength != null && (periodLength < 3 || periodLength > 10)) {
      return ValidationResult.invalid('La durée des règles doit être entre 3 et 10 jours');
    }
    
    return ValidationResult.valid();
  }
}

/// Data class for cycle information
class CycleData {
  final DateTime lastPeriodDate;
  final DateTime nextPeriodDate;
  final int cycleDuration;
  final int periodLength;
  final int daysUntilNextPeriod;
  final String currentPhase;
  final double cycleProgress;
  final List<DateTime> fertileWindow;
  final DateTime ovulationDate;
  final bool isInFertileWindow;
  final bool isOvulationDay;
  final List<DateTime> intercourseDays;

  const CycleData({
    required this.lastPeriodDate,
    required this.nextPeriodDate,
    required this.cycleDuration,
    required this.periodLength,
    required this.daysUntilNextPeriod,
    required this.currentPhase,
    required this.cycleProgress,
    required this.fertileWindow,
    required this.ovulationDate,
    required this.isInFertileWindow,
    required this.isOvulationDay,
    required this.intercourseDays,
  });

  /// Get formatted next period date
  String get formattedNextPeriodDate => 
      CyclePredictionService.formatDateInFrench(nextPeriodDate);

  /// Get formatted days until period
  String get formattedDaysUntil => 
      CyclePredictionService.formatDaysUntilInFrench(daysUntilNextPeriod);

  /// Check if a specific date is an intercourse day
  bool isIntercourseDay(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return intercourseDays.any((d) => d.toIso8601String().split('T')[0] == dateStr);
  }
}

/// Result wrapper for cycle data operations
class CycleDataResult {
  final bool isSuccess;
  final CycleData? data;
  final String? errorMessage;
  final CycleDataErrorType? errorType;

  const CycleDataResult.success(this.data)
      : isSuccess = true,
        errorMessage = null,
        errorType = null;

  const CycleDataResult.error(this.errorMessage, this.errorType)
      : isSuccess = false,
        data = null;

  const CycleDataResult.noData()
      : isSuccess = false,
        data = null,
        errorMessage = null,
        errorType = CycleDataErrorType.noData;

  bool get hasData => data != null;
  bool get hasError => errorMessage != null;
  bool get isNoData => errorType == CycleDataErrorType.noData;
}

/// Types of errors that can occur
enum CycleDataErrorType {
  storage,
  dataCorruption,
  validation,
  network,
  noData,
  unknown,
}

/// Validation result for input data
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.invalid(this.errorMessage) : isValid = false;
}

/// Custom exception for SharedPreferences operations
class SharedPreferencesException implements Exception {
  final String message;
  const SharedPreferencesException(this.message);

  @override
  String toString() => 'SharedPreferencesException: $message';
}