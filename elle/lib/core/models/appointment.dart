import 'dart:ui';

enum DoctorSpecialty {
  gynecologist,
  generalPractitioner,
  obstetrician,
  midwife,
  psychologist,
  dermatologist,
  endocrinologist,
}

enum AppointmentType {
  consultation,
  followUp,
  emergency,
  telehealth,
  vaccination,
  screening,
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

class MedicalCenter {
  final String id;
  final String name;
  final String address;
  final String city;
  final String region;
  final String phoneNumber;
  final String? emailAddress;
  final double latitude;
  final double longitude;
  final List<DoctorSpecialty> specialties;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final Map<String, String> workingHours;
  final bool isEmergencyAvailable;
  final bool isTelehealthAvailable;

  const MedicalCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.region,
    required this.phoneNumber,
    this.emailAddress,
    required this.latitude,
    required this.longitude,
    required this.specialties,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imageUrls = const [],
    this.workingHours = const {},
    this.isEmergencyAvailable = false,
    this.isTelehealthAvailable = false,
  });

  MedicalCenter copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? region,
    String? phoneNumber,
    String? emailAddress,
    double? latitude,
    double? longitude,
    List<DoctorSpecialty>? specialties,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    Map<String, String>? workingHours,
    bool? isEmergencyAvailable,
    bool? isTelehealthAvailable,
  }) {
    return MedicalCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      specialties: specialties ?? this.specialties,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      workingHours: workingHours ?? this.workingHours,
      isEmergencyAvailable: isEmergencyAvailable ?? this.isEmergencyAvailable,
      isTelehealthAvailable: isTelehealthAvailable ?? this.isTelehealthAvailable,
    );
  }

  String get formattedAddress => '$address, $city, $region';

  double calculateDistance(double userLat, double userLon) {
    // Simple distance calculation (in a real app, use a proper geolocation library)
    final deltaLat = latitude - userLat;
    final deltaLon = longitude - userLon;
    return (deltaLat * deltaLat + deltaLon * deltaLon) * 111; // Approximate km
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'region': region,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties.map((s) => s.name).toList(),
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrls': imageUrls,
      'workingHours': workingHours,
      'isEmergencyAvailable': isEmergencyAvailable,
      'isTelehealthAvailable': isTelehealthAvailable,
    };
  }

  factory MedicalCenter.fromJson(Map<String, dynamic> json) {
    return MedicalCenter(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      region: json['region'] as String,
      phoneNumber: json['phoneNumber'] as String,
      emailAddress: json['emailAddress'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      specialties: (json['specialties'] as List)
          .map((s) => DoctorSpecialty.values.firstWhere((e) => e.name == s))
          .toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      workingHours: Map<String, String>.from(json['workingHours'] as Map? ?? {}),
      isEmergencyAvailable: json['isEmergencyAvailable'] as bool? ?? false,
      isTelehealthAvailable: json['isTelehealthAvailable'] as bool? ?? false,
    );
  }
}

class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final DoctorSpecialty specialty;
  final String? profileImageUrl;
  final String medicalCenterId;
  final List<String> languages;
  final int experienceYears;
  final double rating;
  final int reviewCount;
  final String? bio;
  final Map<String, List<String>> availability; // Day -> List of time slots
  final double consultationFee;
  final double telehealthFee;
  final bool isAvailableForEmergency;
  final bool isVerified;

  const Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    this.profileImageUrl,
    required this.medicalCenterId,
    this.languages = const ['Français'],
    this.experienceYears = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.bio,
    this.availability = const {},
    this.consultationFee = 0.0,
    this.telehealthFee = 0.0,
    this.isAvailableForEmergency = false,
    this.isVerified = false,
  });

  Doctor copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DoctorSpecialty? specialty,
    String? profileImageUrl,
    String? medicalCenterId,
    List<String>? languages,
    int? experienceYears,
    double? rating,
    int? reviewCount,
    String? bio,
    Map<String, List<String>>? availability,
    double? consultationFee,
    double? telehealthFee,
    bool? isAvailableForEmergency,
    bool? isVerified,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      specialty: specialty ?? this.specialty,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      medicalCenterId: medicalCenterId ?? this.medicalCenterId,
      languages: languages ?? this.languages,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      bio: bio ?? this.bio,
      availability: availability ?? this.availability,
      consultationFee: consultationFee ?? this.consultationFee,
      telehealthFee: telehealthFee ?? this.telehealthFee,
      isAvailableForEmergency: isAvailableForEmergency ?? this.isAvailableForEmergency,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get fullName => '$firstName $lastName';

  String get specialtyDisplayName {
    switch (specialty) {
      case DoctorSpecialty.gynecologist:
        return 'Gynécologue';
      case DoctorSpecialty.generalPractitioner:
        return 'Médecin généraliste';
      case DoctorSpecialty.obstetrician:
        return 'Obstétricien';
      case DoctorSpecialty.midwife:
        return 'Sage-femme';
      case DoctorSpecialty.psychologist:
        return 'Psychologue';
      case DoctorSpecialty.dermatologist:
        return 'Dermatologue';
      case DoctorSpecialty.endocrinologist:
        return 'Endocrinologue';
    }
  }

  String get specialtyEmoji {
    switch (specialty) {
      case DoctorSpecialty.gynecologist:
        return '🩺';
      case DoctorSpecialty.generalPractitioner:
        return '👨‍⚕️';
      case DoctorSpecialty.obstetrician:
        return '🤱';
      case DoctorSpecialty.midwife:
        return '👩‍⚕️';
      case DoctorSpecialty.psychologist:
        return '🧠';
      case DoctorSpecialty.dermatologist:
        return '🔬';
      case DoctorSpecialty.endocrinologist:
        return '⚗️';
    }
  }

  String get formattedConsultationFee => '${consultationFee.toStringAsFixed(0)} XOF';
  String get formattedTelehealthFee => '${telehealthFee.toStringAsFixed(0)} XOF';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'specialty': specialty.name,
      'profileImageUrl': profileImageUrl,
      'medicalCenterId': medicalCenterId,
      'languages': languages,
      'experienceYears': experienceYears,
      'rating': rating,
      'reviewCount': reviewCount,
      'bio': bio,
      'availability': availability,
      'consultationFee': consultationFee,
      'telehealthFee': telehealthFee,
      'isAvailableForEmergency': isAvailableForEmergency,
      'isVerified': isVerified,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      specialty: DoctorSpecialty.values.firstWhere(
        (e) => e.name == json['specialty'],
        orElse: () => DoctorSpecialty.generalPractitioner,
      ),
      profileImageUrl: json['profileImageUrl'] as String?,
      medicalCenterId: json['medicalCenterId'] as String,
      languages: List<String>.from(json['languages'] as List? ?? ['Français']),
      experienceYears: json['experienceYears'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      bio: json['bio'] as String?,
      availability: Map<String, List<String>>.from(
        (json['availability'] as Map? ?? {}).map(
          (key, value) => MapEntry(key as String, List<String>.from(value as List)),
        ),
      ),
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
      telehealthFee: (json['telehealthFee'] as num?)?.toDouble() ?? 0.0,
      isAvailableForEmergency: json['isAvailableForEmergency'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

class Appointment {
  final String id;
  final String userId;
  final String doctorId;
  final String medicalCenterId;
  final AppointmentType type;
  final AppointmentStatus status;
  final DateTime scheduledDate;
  final String timeSlot;
  final String? reason;
  final String? symptoms;
  final String? notes;
  final double fee;
  final bool isPaid;
  final bool isReminder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;

  const Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.medicalCenterId,
    required this.type,
    required this.status,
    required this.scheduledDate,
    required this.timeSlot,
    this.reason,
    this.symptoms,
    this.notes,
    required this.fee,
    this.isPaid = false,
    this.isReminder = true,
    required this.createdAt,
    this.updatedAt,
    this.cancellationReason,
    this.metadata,
  });

  Appointment copyWith({
    String? id,
    String? userId,
    String? doctorId,
    String? medicalCenterId,
    AppointmentType? type,
    AppointmentStatus? status,
    DateTime? scheduledDate,
    String? timeSlot,
    String? reason,
    String? symptoms,
    String? notes,
    double? fee,
    bool? isPaid,
    bool? isReminder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    Map<String, dynamic>? metadata,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      medicalCenterId: medicalCenterId ?? this.medicalCenterId,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      reason: reason ?? this.reason,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      fee: fee ?? this.fee,
      isPaid: isPaid ?? this.isPaid,
      isReminder: isReminder ?? this.isReminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      metadata: metadata ?? this.metadata,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.followUp:
        return 'Suivi';
      case AppointmentType.emergency:
        return 'Urgence';
      case AppointmentType.telehealth:
        return 'Téléconsultation';
      case AppointmentType.vaccination:
        return 'Vaccination';
      case AppointmentType.screening:
        return 'Dépistage';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Programmé';
      case AppointmentStatus.confirmed:
        return 'Confirmé';
      case AppointmentStatus.inProgress:
        return 'En cours';
      case AppointmentStatus.completed:
        return 'Terminé';
      case AppointmentStatus.cancelled:
        return 'Annulé';
      case AppointmentStatus.rescheduled:
        return 'Reprogrammé';
    }
  }

  String get typeEmoji {
    switch (type) {
      case AppointmentType.consultation:
        return '🩺';
      case AppointmentType.followUp:
        return '📋';
      case AppointmentType.emergency:
        return '🚨';
      case AppointmentType.telehealth:
        return '💻';
      case AppointmentType.vaccination:
        return '💉';
      case AppointmentType.screening:
        return '🔬';
    }
  }

  Color get statusColor {
    switch (status) {
      case AppointmentStatus.scheduled:
        return const Color(0xFF3B82F6); // Blue
      case AppointmentStatus.confirmed:
        return const Color(0xFF10B981); // Green
      case AppointmentStatus.inProgress:
        return const Color(0xFFF59E0B); // Orange
      case AppointmentStatus.completed:
        return const Color(0xFF6366F1); // Purple
      case AppointmentStatus.cancelled:
        return const Color(0xFFEF4444); // Red
      case AppointmentStatus.rescheduled:
        return const Color(0xFF8B5CF6); // Violet
    }
  }

  String get formattedFee => '${fee.toStringAsFixed(0)} XOF';

  bool get canBeCancelled {
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1]),
    );
    
    return (status == AppointmentStatus.scheduled || status == AppointmentStatus.confirmed) &&
           appointmentDateTime.isAfter(now.add(const Duration(hours: 2))); // Can cancel 2 hours before
  }

  bool get canBeRescheduled {
    return canBeCancelled;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'doctorId': doctorId,
      'medicalCenterId': medicalCenterId,
      'type': type.name,
      'status': status.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeSlot': timeSlot,
      'reason': reason,
      'symptoms': symptoms,
      'notes': notes,
      'fee': fee,
      'isPaid': isPaid,
      'isReminder': isReminder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'metadata': metadata,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      doctorId: json['doctorId'] as String,
      medicalCenterId: json['medicalCenterId'] as String,
      type: AppointmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppointmentType.consultation,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      timeSlot: json['timeSlot'] as String,
      reason: json['reason'] as String?,
      symptoms: json['symptoms'] as String?,
      notes: json['notes'] as String?,
      fee: (json['fee'] as num).toDouble(),
      isPaid: json['isPaid'] as bool? ?? false,
      isReminder: json['isReminder'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}