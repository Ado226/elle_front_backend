import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'cycle_tracking_screen.dart';

// Styling constants
const Color primaryPink = Color(0xFFE91E63);
const Color backgroundGray = Color(0xFFF5F5F5);
const Color textDark = Color(0xFF333333);
const Color textLight = Color(0xFF666666);
const Color cardBackground = Color(0xFFFFFFFF);
const Color borderColor = Color(0xFFE0E0E0);
const Color selectedBorder = Color(0xFFE91E63);

class OnboardingData {
  DateTime? lastPeriodDate;
  int cycleDuration;
  DateTime? birthDate;
  String? contraceptiveMethod;
  String? pillSchedule;

  OnboardingData({
    this.lastPeriodDate,
    this.cycleDuration = 28,
    this.birthDate,
    this.contraceptiveMethod,
    this.pillSchedule,
  });
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  final OnboardingData _onboardingData = OnboardingData();
  bool _isLoading = false;
  SharedPreferences? _prefs;
  Map<String, dynamic> _fallbackStorage = {};

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializePreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      // Continue without SharedPreferences, will use fallback
    }
  }

  void navigateToNextScreen() {
    if (currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void navigateToPreviousScreen() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isLoading) return; // Prevent multiple clicks
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Validate data first
      if (!_validateOnboardingData()) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Save data with retry mechanism
      await _saveWithRetry();
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to home screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (Route<dynamic> route) => false,
        );
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showErrorDialog('Erreur lors de la sauvegarde', e.toString());
      }
    }
  }

  Future<void> _saveWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _saveOnboardingDataSafely();
        return; // Success, exit retry loop
      } catch (e) {
        if (attempt == maxRetries) {
          throw e; // Final attempt failed
        }
        
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  Future<void> _saveOnboardingDataSafely() async {
    try {
      // Ensure SharedPreferences is initialized
      _prefs ??= await SharedPreferences.getInstance();
      
      // Add delay to ensure platform channel is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Save data with null safety checks
      if (_onboardingData.lastPeriodDate != null) {
        await _prefs!.setString('last_period_date', 
            _onboardingData.lastPeriodDate!.toIso8601String());
      }
      
      await _prefs!.setInt('cycle_duration', _onboardingData.cycleDuration);
      
      if (_onboardingData.birthDate != null) {
        await _prefs!.setString('birth_date', 
            _onboardingData.birthDate!.toIso8601String());
      }
      
      if (_onboardingData.contraceptiveMethod != null) {
        await _prefs!.setString('contraceptive_method', 
            _onboardingData.contraceptiveMethod!);
      }
      
      if (_onboardingData.pillSchedule != null) {
        await _prefs!.setString('pill_schedule', 
            _onboardingData.pillSchedule!);
      }
      
      // Mark onboarding as completed
      await _prefs!.setBool('onboarding_completed', true);
      
    } catch (e) {
      throw Exception('Erreur de sauvegarde: $e');
    }
  }

  Future<void> _saveFallback() async {
    try {
      _fallbackStorage = {
        'last_period_date': _onboardingData.lastPeriodDate?.toIso8601String(),
        'cycle_duration': _onboardingData.cycleDuration,
        'birth_date': _onboardingData.birthDate?.toIso8601String(),
        'contraceptive_method': _onboardingData.contraceptiveMethod,
        'pill_schedule': _onboardingData.pillSchedule,
        'onboarding_completed': true,
      };
      
      // Pass data to next screen via constructor or global state
      print('Data saved to fallback storage: $_fallbackStorage');
      
    } catch (e) {
      throw Exception('Fallback storage failed: $e');
    }
  }

  void _continueWithoutSaving() {
    try {
      // Save to fallback storage
      _saveFallback();
      
      // Navigate anyway
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (Route<dynamic> route) => false,
      );
      
    } catch (e) {
      // If everything fails, just navigate
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (Route<dynamic> route) => false,
      );
    }
  }

  bool _validateOnboardingData() {
    // Check if required fields are filled
    if (_onboardingData.lastPeriodDate == null) {
      _showErrorDialog('Erreur de validation', 'Veuillez sélectionner votre dernière date de règles');
      return false;
    }
    
    if (_onboardingData.cycleDuration < 21 || _onboardingData.cycleDuration > 35) {
      _showErrorDialog('Erreur de validation', 'La durée du cycle doit être entre 21 et 35 jours');
      return false;
    }
    
    return true;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 10),
              Text(
                'Voulez-vous réessayer ou continuer sans sauvegarder?',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Continue without saving (use fallback)
                _continueWithoutSaving();
              },
              child: const Text('Continuer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeOnboarding(); // Retry
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        );
      },
    );
  }

  void updateOnboardingData() {
    setState(() {
      // Update data based on current screen
    });
  }

  bool validateCurrentScreen() {
    switch (currentPage) {
      case 0:
        return _onboardingData.lastPeriodDate != null;
      case 1:
        return _onboardingData.cycleDuration >= 21 && _onboardingData.cycleDuration <= 35;
      case 2:
        return _onboardingData.birthDate != null;
      case 3:
        return true; // Contraceptive method is optional
      case 4:
        return true; // Pill schedule is optional
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    currentPage = page;
                  });
                },
                children: [
                  // Screen 1: Calendar Selection (existing)
                  CycleTrackingScreen(
                    onDateSelected: (date) {
                      setState(() {
                        _onboardingData.lastPeriodDate = date;
                      });
                    },
                    onNext: navigateToNextScreen,
                  ),
                  // Screen 2: Cycle Duration
                  CycleDurationScreen(
                    onboardingData: _onboardingData,
                    onNext: navigateToNextScreen,
                    onBack: navigateToPreviousScreen,
                  ),
                  // Screen 3: Age Input
                  AgeInputScreen(
                    onboardingData: _onboardingData,
                    onNext: navigateToNextScreen,
                    onBack: navigateToPreviousScreen,
                  ),
                  // Screen 4: Contraceptive Method
                  ContraceptiveMethodScreen(
                    onboardingData: _onboardingData,
                    onNext: navigateToNextScreen,
                    onBack: navigateToPreviousScreen,
                  ),
                  // Screen 5: Pill Schedule
                  PillScheduleScreen(
                    onboardingData: _onboardingData,
                    onNext: _completeOnboarding,
                    onBack: navigateToPreviousScreen,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == currentPage ? primaryPink : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen 2: Cycle Duration
class CycleDurationScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CycleDurationScreen({
    Key? key,
    required this.onboardingData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<CycleDurationScreen> createState() => _CycleDurationScreenState();
}

class _CycleDurationScreenState extends State<CycleDurationScreen> {
  late int cycleDuration;

  @override
  void initState() {
    super.initState();
    cycleDuration = widget.onboardingData.cycleDuration;
  }

  void updateCycleDuration(int newDuration) {
    setState(() {
      cycleDuration = newDuration;
      widget.onboardingData.cycleDuration = newDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: textDark,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Title and Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Quelle est la durée typique\nde votre cycle ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '21 à 35 jours sont courant, mais\nchaque personne est unique !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textLight,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Cycle Duration Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (cycleDuration > 21) {
                              updateCycleDuration(cycleDuration - 1);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: primaryPink,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryPink, width: 2),
                          ),
                          child: Text(
                            '$cycleDuration jours',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        GestureDetector(
                          onTap: () {
                            if (cycleDuration < 35) {
                              updateCycleDuration(cycleDuration + 1);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: primaryPink,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SUIVANT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: widget.onNext,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryPink,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: primaryPink, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'JE NE SAIS PAS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen 3: Age Input
class AgeInputScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AgeInputScreen({
    Key? key,
    required this.onboardingData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<AgeInputScreen> createState() => _AgeInputScreenState();
}

class _AgeInputScreenState extends State<AgeInputScreen> {
  String selectedMonth = 'Jan';
  int selectedDay = 4;
  late int selectedYear;
  
  // Dynamic year range calculation
  late int currentYear;
  late int startYear;
  late int endYear;
  late List<String> yearItems;

  final List<String> months = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
    'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
  ];

  @override
  void initState() {
    super.initState();
    currentYear = DateTime.now().year;
    startYear = 1960; // Reasonable starting year
    endYear = currentYear;
    
    // Generate year list with most recent years first
    yearItems = List.generate(
      endYear - startYear + 1, 
      (index) => (endYear - index).toString()
    );
    
    // Set default year to a reasonable value (e.g., 2000 or current year - 20)
    selectedYear = (currentYear - 20).clamp(startYear, endYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: textDark,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Title and Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Quand êtes-vous né(e) ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Connaître les cycles pendant chaque âge\nnous permet de mieux vous conseiller',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textLight,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Date Dropdowns
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Month Dropdown
                        Expanded(
                          child: CustomDropdown(
                            value: selectedMonth,
                            items: months,
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value;
                                // Adjust day if it's invalid for the new month
                                final monthIndex = months.indexOf(selectedMonth) + 1;
                                final maxDays = _getMaxDaysInMonth(selectedYear, monthIndex);
                                if (selectedDay > maxDays) {
                                  selectedDay = maxDays;
                                }
                                updateBirthDate();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Day Dropdown
                        Expanded(
                          child: CustomDropdown(
                            value: selectedDay.toString(),
                            items: _getDayItems(),
                            onChanged: (value) {
                              setState(() {
                                selectedDay = int.parse(value);
                                updateBirthDate();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Year Dropdown
                        Expanded(
                          child: CustomDropdown(
                            value: selectedYear.toString(),
                            items: yearItems,
                            onChanged: (value) {
                              setState(() {
                                selectedYear = int.parse(value);
                                // Adjust day if it's invalid for the new year (e.g., Feb 29 in non-leap year)
                                final monthIndex = months.indexOf(selectedMonth) + 1;
                                final maxDays = _getMaxDaysInMonth(selectedYear, monthIndex);
                                if (selectedDay > maxDays) {
                                  selectedDay = maxDays;
                                }
                                updateBirthDate();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SUIVANT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: widget.onNext,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryPink,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: primaryPink, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'JE NE SAIS PAS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateBirthDate() {
    final monthIndex = months.indexOf(selectedMonth) + 1;
    
    // Validate day based on month and year (handle leap years and month lengths)
    int maxDaysInMonth = _getMaxDaysInMonth(selectedYear, monthIndex);
    if (selectedDay > maxDaysInMonth) {
      selectedDay = maxDaysInMonth;
    }
    
    widget.onboardingData.birthDate = DateTime(selectedYear, monthIndex, selectedDay);
  }

  /// Get maximum days in a given month/year (handles leap years)
  int _getMaxDaysInMonth(int year, int month) {
    switch (month) {
      case 2: // February
        return _isLeapYear(year) ? 29 : 28;
      case 4: // April
      case 6: // June
      case 9: // September
      case 11: // November
        return 30;
      default:
        return 31;
    }
  }

  /// Check if a year is a leap year
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get day items based on selected month and year
  List<String> _getDayItems() {
    final monthIndex = months.indexOf(selectedMonth) + 1;
    final maxDays = _getMaxDaysInMonth(selectedYear, monthIndex);
    
    return List.generate(maxDays, (index) => (index + 1).toString());
  }

  /// Validate age requirements
  bool _validateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    
    // Adjust if birthday hasn't occurred this year
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    // Minimum age check (13 years old for menstrual tracking app)
    if (age < 13) {
      _showSimpleErrorDialog('Vous devez avoir au moins 13 ans pour utiliser cette application');
      return false;
    }
    
    // Maximum age check (80 years old - reasonable upper limit)
    if (age > 80) {
      _showSimpleErrorDialog('Veuillez vérifier votre date de naissance');
      return false;
    }
    
    // Check if birth date is in the future
    if (birthDate.isAfter(today)) {
      _showSimpleErrorDialog('La date de naissance ne peut pas être dans le futur');
      return false;
    }
    
    return true;
  }

  /// Show simple error dialog for validation errors
  void _showSimpleErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur de validation'),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFFE91E63),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Validate and proceed to next step
  void _handleNext() {
    updateBirthDate();
    
    if (widget.onboardingData.birthDate != null) {
      if (_validateAge(widget.onboardingData.birthDate!)) {
        widget.onNext();
      }
    } else {
      _showSimpleErrorDialog('Veuillez sélectionner une date de naissance valide');
    }
  }

  /// Test validation (for debugging - can be removed in production)
  void _testValidation() {
    // Test cases for validation
    DateTime tooYoung = DateTime(currentYear - 10); // 10 years old
    DateTime tooOld = DateTime(currentYear - 85); // 85 years old
    DateTime futureDate = DateTime(currentYear + 1); // Future date
    DateTime validAge = DateTime(currentYear - 25); // 25 years old
    
    print('Testing age validation:');
    print('Too young (10): ${_validateAge(tooYoung)}'); // Should be false
    print('Too old (85): ${_validateAge(tooOld)}'); // Should be false  
    print('Future date: ${_validateAge(futureDate)}'); // Should be false
    print('Valid age (25): ${_validateAge(validAge)}'); // Should be true
  }
}

// Custom Dropdown Component
class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: Container(),
        icon: const Icon(Icons.keyboard_arrow_down, color: primaryPink),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
                color: textDark,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }
}

// Screen 4: Contraceptive Method
class ContraceptiveMethodScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ContraceptiveMethodScreen({
    Key? key,
    required this.onboardingData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<ContraceptiveMethodScreen> createState() => _ContraceptiveMethodScreenState();
}

class _ContraceptiveMethodScreenState extends State<ContraceptiveMethodScreen> {
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: textDark,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Title and Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Utilisez-vous un méthode\ncontraceptif ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nous pouvons personnaliser l\'application\npour qu\'elle soit plus utile pour vous.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textLight,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Contraceptive Options
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        OptionCard(
                          title: 'Pilule combinée',
                          isSelected: selectedMethod == 'Pilule combinée',
                          onTap: () {
                            setState(() {
                              selectedMethod = 'Pilule combinée';
                              widget.onboardingData.contraceptiveMethod = selectedMethod;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        OptionCard(
                          title: 'Autre méthode',
                          isSelected: selectedMethod == 'Autre méthode',
                          onTap: () {
                            setState(() {
                              selectedMethod = 'Autre méthode';
                              widget.onboardingData.contraceptiveMethod = selectedMethod;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        OptionCard(
                          title: 'Aucune méthode',
                          isSelected: selectedMethod == 'Aucune méthode',
                          onTap: () {
                            setState(() {
                              selectedMethod = 'Aucune méthode';
                              widget.onboardingData.contraceptiveMethod = selectedMethod;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SUIVANT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen 5: Pill Schedule
class PillScheduleScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLoading;

  const PillScheduleScreen({
    Key? key,
    required this.onboardingData,
    required this.onNext,
    required this.onBack,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<PillScheduleScreen> createState() => _PillScheduleScreenState();
}

class _PillScheduleScreenState extends State<PillScheduleScreen> {
  String? selectedSchedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: textDark,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Title and Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Comment prenez-vous\nvotre pilule ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cela nous aide à mieux comprendre\nvotre rythme personnel.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textLight,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Pill Schedule Options
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        OptionCard(
                          title: '21 jours sans interruption',
                          subtitle: 'Suivi de 7 jours de pause',
                          isSelected: selectedSchedule == '21 jours sans interruption',
                          onTap: () {
                            setState(() {
                              selectedSchedule = '21 jours sans interruption';
                              widget.onboardingData.pillSchedule = selectedSchedule;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        OptionCard(
                          title: '28 jours continus',
                          subtitle: 'Prise quotidienne sans pause',
                          isSelected: selectedSchedule == '28 jours continus',
                          onTap: () {
                            setState(() {
                              selectedSchedule = '28 jours continus';
                              widget.onboardingData.pillSchedule = selectedSchedule;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'TERMINER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Option Card Component
class OptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedBorder : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? selectedBorder : textDark,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: selectedBorder,
                    size: 20,
                  ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: textLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Utility class for onboarding data management
class OnboardingManager {
  static Future<bool> isOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<OnboardingData> getOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final onboardingData = OnboardingData();
      
      // Load last period date
      final lastPeriodDateString = prefs.getString('last_period_date');
      if (lastPeriodDateString != null) {
        onboardingData.lastPeriodDate = DateTime.parse(lastPeriodDateString);
      }
      
      // Load cycle duration
      onboardingData.cycleDuration = prefs.getInt('cycle_duration') ?? 28;
      
      // Load birth date
      final birthDateString = prefs.getString('birth_date');
      if (birthDateString != null) {
        onboardingData.birthDate = DateTime.parse(birthDateString);
      }
      
      // Load contraceptive method
      onboardingData.contraceptiveMethod = prefs.getString('contraceptive_method');
      
      // Load pill schedule
      onboardingData.pillSchedule = prefs.getString('pill_schedule');
      
      return onboardingData;
    } catch (e) {
      // Return default data if loading fails
      return OnboardingData();
    }
  }

  static Future<void> clearOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_completed');
      await prefs.remove('last_period_date');
      await prefs.remove('cycle_duration');
      await prefs.remove('birth_date');
      await prefs.remove('contraceptive_method');
      await prefs.remove('pill_schedule');
    } catch (e) {
      throw Exception('Failed to clear onboarding data: $e');
    }
  }
}

