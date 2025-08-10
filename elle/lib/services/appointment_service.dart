import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/appointment.dart';

class AppointmentService {
  static const String _appointmentsKey = 'user_appointments';
  static const String _favoriteDoctorsKey = 'favorite_doctors';
  static const String _recentSearchesKey = 'recent_searches';

  // Sample medical centers data
  static final List<MedicalCenter> _sampleCenters = [
    MedicalCenter(
      id: '1',
      name: 'Centre Médical de la Femme',
      address: '15 Avenue Kwame Nkrumah',
      city: 'Ouagadougou',
      region: 'Centre',
      phoneNumber: '+226 25 30 45 67',
      emailAddress: 'contact@cmf-ouaga.bf',
      latitude: 12.3714,
      longitude: -1.5197,
      specialties: [
        DoctorSpecialty.gynecologist,
        DoctorSpecialty.obstetrician,
        DoctorSpecialty.midwife,
      ],
      rating: 4.6,
      reviewCount: 145,
      workingHours: {
        'Lundi': '08:00-17:00',
        'Mardi': '08:00-17:00',
        'Mercredi': '08:00-17:00',
        'Jeudi': '08:00-17:00',
        'Vendredi': '08:00-17:00',
        'Samedi': '08:00-12:00',
      },
      isEmergencyAvailable: true,
      isTelehealthAvailable: true,
    ),
    MedicalCenter(
      id: '2',
      name: 'Clinique Sainte Marie',
      address: '28 Boulevard Charles de Gaulle',
      city: 'Bobo-Dioulasso',
      region: 'Hauts-Bassins',
      phoneNumber: '+226 20 97 45 23',
      emailAddress: 'accueil@clinique-saintmarie.bf',
      latitude: 11.1770,
      longitude: -4.2970,
      specialties: [
        DoctorSpecialty.generalPractitioner,
        DoctorSpecialty.gynecologist,
        DoctorSpecialty.psychologist,
        DoctorSpecialty.dermatologist,
      ],
      rating: 4.3,
      reviewCount: 89,
      workingHours: {
        'Lundi': '07:30-18:00',
        'Mardi': '07:30-18:00',
        'Mercredi': '07:30-18:00',
        'Jeudi': '07:30-18:00',
        'Vendredi': '07:30-18:00',
        'Samedi': '08:00-14:00',
        'Dimanche': '10:00-14:00',
      },
      isEmergencyAvailable: true,
      isTelehealthAvailable: false,
    ),
    MedicalCenter(
      id: '3',
      name: 'Cabinet Médical Yennenga',
      address: '42 Rue Maurice Bishop',
      city: 'Ouagadougou',
      region: 'Centre',
      phoneNumber: '+226 25 36 78 90',
      latitude: 12.3589,
      longitude: -1.5353,
      specialties: [
        DoctorSpecialty.midwife,
        DoctorSpecialty.psychologist,
        DoctorSpecialty.endocrinologist,
      ],
      rating: 4.8,
      reviewCount: 67,
      workingHours: {
        'Lundi': '08:00-16:00',
        'Mardi': '08:00-16:00',
        'Mercredi': '08:00-16:00',
        'Jeudi': '08:00-16:00',
        'Vendredi': '08:00-16:00',
      },
      isEmergencyAvailable: false,
      isTelehealthAvailable: true,
    ),
  ];

  // Sample doctors data
  static final List<Doctor> _sampleDoctors = [
    Doctor(
      id: '1',
      firstName: 'Dr. Aminata',
      lastName: 'Ouédraogo',
      specialty: DoctorSpecialty.gynecologist,
      medicalCenterId: '1',
      languages: ['Français', 'Mooré', 'Dioula'],
      experienceYears: 12,
      rating: 4.8,
      reviewCount: 156,
      bio: 'Spécialiste en gynécologie avec plus de 12 ans d\'expérience. Diplômée de l\'Université de Ouagadougou et spécialisée dans la santé reproductive féminine.',
      consultationFee: 15000,
      telehealthFee: 8000,
      isVerified: true,
      availability: {
        'Lundi': ['09:00', '10:00', '14:00', '15:00', '16:00'],
        'Mardi': ['09:00', '10:00', '11:00', '14:00', '15:00'],
        'Mercredi': ['09:00', '14:00', '15:00', '16:00'],
        'Jeudi': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        'Vendredi': ['09:00', '10:00', '14:00', '15:00'],
      },
    ),
    Doctor(
      id: '2',
      firstName: 'Dr. Fatou',
      lastName: 'Sankara',
      specialty: DoctorSpecialty.midwife,
      medicalCenterId: '1',
      languages: ['Français', 'Fulfuldé', 'Mooré'],
      experienceYears: 8,
      rating: 4.7,
      reviewCount: 98,
      bio: 'Sage-femme expérimentée, spécialisée dans l\'accompagnement des femmes enceintes et l\'accouchement naturel.',
      consultationFee: 12000,
      telehealthFee: 6000,
      isVerified: true,
      availability: {
        'Lundi': ['08:00', '09:00', '10:00', '14:00', '15:00'],
        'Mardi': ['08:00', '09:00', '14:00', '15:00', '16:00'],
        'Mercredi': ['08:00', '09:00', '10:00', '11:00', '14:00'],
        'Jeudi': ['08:00', '09:00', '14:00', '15:00'],
        'Vendredi': ['08:00', '09:00', '10:00', '14:00', '15:00', '16:00'],
        'Samedi': ['08:00', '09:00', '10:00'],
      },
    ),
    Doctor(
      id: '3',
      firstName: 'Dr. Marie',
      lastName: 'Compaoré',
      specialty: DoctorSpecialty.psychologist,
      medicalCenterId: '2',
      languages: ['Français', 'Dioula'],
      experienceYears: 15,
      rating: 4.9,
      reviewCount: 203,
      bio: 'Psychologue clinicienne spécialisée dans la santé mentale féminine, la périnatalité et les troubles de l\'humeur.',
      consultationFee: 18000,
      telehealthFee: 12000,
      isVerified: true,
      availability: {
        'Lundi': ['10:00', '11:00', '14:00', '15:00', '16:00'],
        'Mardi': ['09:00', '10:00', '11:00', '14:00', '15:00'],
        'Mercredi': ['10:00', '11:00', '14:00', '15:00'],
        'Jeudi': ['09:00', '10:00', '14:00', '15:00', '16:00'],
        'Vendredi': ['10:00', '11:00', '14:00', '15:00'],
      },
    ),
    Doctor(
      id: '4',
      firstName: 'Dr. Salimata',
      lastName: 'Traoré',
      specialty: DoctorSpecialty.generalPractitioner,
      medicalCenterId: '2',
      languages: ['Français', 'Bambara', 'Dioula'],
      experienceYears: 6,
      rating: 4.4,
      reviewCount: 72,
      bio: 'Médecin généraliste avec une approche holistique de la santé féminine. Consultations en français et langues locales.',
      consultationFee: 10000,
      telehealthFee: 5000,
      isVerified: true,
      isAvailableForEmergency: true,
      availability: {
        'Lundi': ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        'Mardi': ['08:00', '09:00', '10:00', '14:00', '15:00', '16:00'],
        'Mercredi': ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00'],
        'Jeudi': ['08:00', '09:00', '14:00', '15:00', '16:00'],
        'Vendredi': ['08:00', '09:00', '10:00', '14:00', '15:00', '16:00'],
        'Samedi': ['08:00', '09:00', '10:00', '11:00'],
        'Dimanche': ['10:00', '11:00', '12:00'],
      },
    ),
    Doctor(
      id: '5',
      firstName: 'Dr. Rasmané',
      lastName: 'Zongo',
      specialty: DoctorSpecialty.endocrinologist,
      medicalCenterId: '3',
      languages: ['Français', 'Mooré'],
      experienceYears: 10,
      rating: 4.6,
      reviewCount: 84,
      bio: 'Endocrinologue spécialisé dans les troubles hormonaux féminins, SOPK, thyroïde et métabolisme.',
      consultationFee: 20000,
      telehealthFee: 15000,
      isVerified: true,
      availability: {
        'Lundi': ['09:00', '10:00', '11:00', '14:00', '15:00'],
        'Mardi': ['09:00', '10:00', '14:00', '15:00'],
        'Mercredi': ['09:00', '10:00', '11:00', '14:00'],
        'Jeudi': ['09:00', '14:00', '15:00'],
        'Vendredi': ['09:00', '10:00', '11:00', '14:00', '15:00'],
      },
    ),
  ];

  // Medical Centers
  static Future<List<MedicalCenter>> getMedicalCenters({
    String? city,
    DoctorSpecialty? specialty,
    double? userLat,
    double? userLon,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var centers = List<MedicalCenter>.from(_sampleCenters);

    if (city != null && city.isNotEmpty) {
      centers = centers.where((center) => 
        center.city.toLowerCase().contains(city.toLowerCase())
      ).toList();
    }

    if (specialty != null) {
      centers = centers.where((center) => 
        center.specialties.contains(specialty)
      ).toList();
    }

    // Sort by distance if user location is provided
    if (userLat != null && userLon != null) {
      centers.sort((a, b) => 
        a.calculateDistance(userLat, userLon)
            .compareTo(b.calculateDistance(userLat, userLon))
      );
    } else {
      // Sort by rating
      centers.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return centers;
  }

  static Future<MedicalCenter?> getMedicalCenterById(String centerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      return _sampleCenters.firstWhere((center) => center.id == centerId);
    } catch (e) {
      return null;
    }
  }

  // Doctors
  static Future<List<Doctor>> getDoctors({
    String? medicalCenterId,
    DoctorSpecialty? specialty,
    String? searchQuery,
    bool? availableToday,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var doctors = List<Doctor>.from(_sampleDoctors);

    if (medicalCenterId != null) {
      doctors = doctors.where((doctor) => 
        doctor.medicalCenterId == medicalCenterId
      ).toList();
    }

    if (specialty != null) {
      doctors = doctors.where((doctor) => doctor.specialty == specialty).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      doctors = doctors.where((doctor) {
        return doctor.fullName.toLowerCase().contains(query) ||
               doctor.specialtyDisplayName.toLowerCase().contains(query) ||
               doctor.languages.any((lang) => lang.toLowerCase().contains(query));
      }).toList();
    }

    if (availableToday == true) {
      final today = _getDayOfWeek(DateTime.now());
      doctors = doctors.where((doctor) => 
        doctor.availability.containsKey(today) &&
        doctor.availability[today]!.isNotEmpty
      ).toList();
    }

    // Sort by rating
    doctors.sort((a, b) => b.rating.compareTo(a.rating));

    return doctors;
  }

  static Future<Doctor?> getDoctorById(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      return _sampleDoctors.firstWhere((doctor) => doctor.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Doctor>> getFeaturedDoctors() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _sampleDoctors
        .where((doctor) => doctor.rating >= 4.5 && doctor.isVerified)
        .take(5)
        .toList();
  }

  // Appointments
  static Future<List<Appointment>> getUserAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getString(_appointmentsKey);
      
      if (appointmentsJson == null) return [];
      
      final appointmentsData = jsonDecode(appointmentsJson) as List;
      return appointmentsData.map((data) => Appointment.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> bookAppointment(Appointment appointment) async {
    try {
      final appointments = await getUserAppointments();
      appointments.insert(0, appointment);
      
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = jsonEncode(
        appointments.map((apt) => apt.toJson()).toList()
      );
      
      return await prefs.setString(_appointmentsKey, appointmentsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateAppointment(Appointment appointment) async {
    try {
      final appointments = await getUserAppointments();
      final index = appointments.indexWhere((apt) => apt.id == appointment.id);
      
      if (index == -1) return false;
      
      appointments[index] = appointment;
      
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = jsonEncode(
        appointments.map((apt) => apt.toJson()).toList()
      );
      
      return await prefs.setString(_appointmentsKey, appointmentsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelAppointment(String appointmentId, String reason) async {
    try {
      final appointments = await getUserAppointments();
      final index = appointments.indexWhere((apt) => apt.id == appointmentId);
      
      if (index == -1) return false;
      
      appointments[index] = appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
        cancellationReason: reason,
        updatedAt: DateTime.now(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = jsonEncode(
        appointments.map((apt) => apt.toJson()).toList()
      );
      
      return await prefs.setString(_appointmentsKey, appointmentsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<Appointment?> getAppointmentById(String appointmentId) async {
    final appointments = await getUserAppointments();
    try {
      return appointments.firstWhere((apt) => apt.id == appointmentId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Appointment>> getUpcomingAppointments() async {
    final appointments = await getUserAppointments();
    final now = DateTime.now();
    
    return appointments.where((apt) {
      return apt.scheduledDate.isAfter(now) &&
             (apt.status == AppointmentStatus.scheduled ||
              apt.status == AppointmentStatus.confirmed);
    }).toList();
  }

  // Availability and time slots
  static Future<List<String>> getAvailableTimeSlots(
    String doctorId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final doctor = await getDoctorById(doctorId);
    if (doctor == null) return [];
    
    final dayOfWeek = _getDayOfWeek(date);
    final availableSlots = doctor.availability[dayOfWeek] ?? [];
    
    // Filter out already booked slots (simplified for demo)
    final bookedAppointments = await getUserAppointments();
    final bookedSlots = bookedAppointments
        .where((apt) => 
          apt.doctorId == doctorId &&
          apt.scheduledDate.year == date.year &&
          apt.scheduledDate.month == date.month &&
          apt.scheduledDate.day == date.day &&
          apt.status != AppointmentStatus.cancelled
        )
        .map((apt) => apt.timeSlot)
        .toList();
    
    return availableSlots.where((slot) => !bookedSlots.contains(slot)).toList();
  }

  static Future<List<DateTime>> getAvailableDates(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final doctor = await getDoctorById(doctorId);
    if (doctor == null) return [];
    
    final availableDates = <DateTime>[];
    final now = DateTime.now();
    
    // Generate next 30 days of availability
    for (int i = 1; i <= 30; i++) {
      final date = now.add(Duration(days: i));
      final dayOfWeek = _getDayOfWeek(date);
      
      if (doctor.availability.containsKey(dayOfWeek) &&
          doctor.availability[dayOfWeek]!.isNotEmpty) {
        availableDates.add(date);
      }
    }
    
    return availableDates;
  }

  // Favorites
  static Future<List<String>> getFavoriteDoctors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoriteDoctorsKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> toggleFavoriteDoctor(String doctorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteDoctors();
      
      if (favorites.contains(doctorId)) {
        favorites.remove(doctorId);
      } else {
        favorites.add(doctorId);
      }
      
      return await prefs.setStringList(_favoriteDoctorsKey, favorites);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isDoctorFavorite(String doctorId) async {
    final favorites = await getFavoriteDoctors();
    return favorites.contains(doctorId);
  }

  // Search history
  static Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addRecentSearch(String searchQuery) async {
    try {
      if (searchQuery.trim().isEmpty) return false;
      
      final prefs = await SharedPreferences.getInstance();
      final searches = await getRecentSearches();
      
      // Remove if already exists
      searches.remove(searchQuery);
      
      // Add to beginning
      searches.insert(0, searchQuery);
      
      // Keep only last 10 searches
      if (searches.length > 10) {
        searches.removeRange(10, searches.length);
      }
      
      return await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      return false;
    }
  }

  // Utility methods
  static String _getDayOfWeek(DateTime date) {
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    return days[date.weekday - 1];
  }

  static String generateAppointmentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'APT_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
  }

  static double calculateConsultationFee(
    Doctor doctor,
    AppointmentType type,
  ) {
    switch (type) {
      case AppointmentType.telehealth:
        return doctor.telehealthFee;
      case AppointmentType.emergency:
        return doctor.consultationFee * 1.5; // 50% surcharge for emergency
      default:
        return doctor.consultationFee;
    }
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  static String formatAppointmentDate(DateTime date, String timeSlot) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    final days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    
    final dayName = days[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    
    return '$dayName $day $month $year à ${timeSlot}h';
  }
}