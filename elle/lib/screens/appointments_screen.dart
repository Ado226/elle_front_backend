import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/app_theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;
  
  final List<String> _tabs = ['À venir', 'Historique', 'Disponibilités'];
  final List<AppointmentItem> _upcomingAppointments = [];
  final List<AppointmentItem> _pastAppointments = [];
  final List<DoctorAvailability> _availabilities = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadMockData();
    _animationController.forward();
  }

  void _loadMockData() {
    // Mock upcoming appointments
    _upcomingAppointments.addAll([
      AppointmentItem(
        id: '1',
        doctorName: 'Dr. Aminata Traoré',
        specialty: 'Gynécologue',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '14:30',
        type: 'Consultation générale',
        location: 'Cabinet Médical - Cocody',
        status: 'Confirmé',
      ),
      AppointmentItem(
        id: '2',
        doctorName: 'Dr. Fatoumata Keita',
        specialty: 'Nutritionniste',
        date: DateTime.now().add(const Duration(days: 5)),
        time: '10:00',
        type: 'Suivi nutritionnel',
        location: 'Centre de Santé - Plateau',
        status: 'En attente',
      ),
    ]);

    // Mock past appointments
    _pastAppointments.addAll([
      AppointmentItem(
        id: '3',
        doctorName: 'Dr. Mariam Coulibaly',
        specialty: 'Psychologue',
        date: DateTime.now().subtract(const Duration(days: 10)),
        time: '16:00',
        type: 'Consultation psychologique',
        location: 'Cabinet Privé - Adjamé',
        status: 'Terminé',
      ),
    ]);

    // Mock doctor availabilities
    _availabilities.addAll([
      DoctorAvailability(
        doctorName: 'Dr. Aminata Traoré',
        specialty: 'Gynécologue',
        availableSlots: [
          TimeSlot(date: DateTime.now().add(const Duration(days: 1)), time: '09:00'),
          TimeSlot(date: DateTime.now().add(const Duration(days: 1)), time: '11:30'),
          TimeSlot(date: DateTime.now().add(const Duration(days: 3)), time: '14:00'),
        ],
      ),
      DoctorAvailability(
        doctorName: 'Dr. Fatoumata Keita',
        specialty: 'Nutritionniste',
        availableSlots: [
          TimeSlot(date: DateTime.now().add(const Duration(days: 2)), time: '08:30'),
          TimeSlot(date: DateTime.now().add(const Duration(days: 4)), time: '15:30'),
        ],
      ),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Rendez-vous Médicaux',
          style: AppTheme.headerStyle.copyWith(fontSize: 20),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: AppTheme.primaryPink,
          unselectedLabelColor: AppTheme.lightGray,
          indicatorColor: AppTheme.primaryPink,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTab(),
          _buildHistoryTab(),
          _buildAvailabilityTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookingDialog(),
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingAppointments.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: AppointmentCard(
                  appointment: _upcomingAppointments[index],
                  onTap: () => _showAppointmentDetail(_upcomingAppointments[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pastAppointments.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: AppointmentCard(
                  appointment: _pastAppointments[index],
                  onTap: () => _showAppointmentDetail(_pastAppointments[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailabilityTab() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availabilities.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: DoctorAvailabilityCard(
                  availability: _availabilities[index],
                  onSlotTap: (slot) => _bookAppointment(_availabilities[index], slot),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAppointmentDetail(AppointmentItem appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppointmentDetailSheet(appointment: appointment),
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouveau rendez-vous', style: AppTheme.subHeaderStyle),
        content: const Text('Fonctionnalité de réservation en cours de développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTheme.bodyTextStyle),
          ),
        ],
      ),
    );
  }

  void _bookAppointment(DoctorAvailability doctor, TimeSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer le rendez-vous', style: AppTheme.subHeaderStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Médecin: ${doctor.doctorName}', style: AppTheme.bodyTextStyle),
            Text('Spécialité: ${doctor.specialty}', style: AppTheme.bodyTextStyle),
            Text('Date: ${_formatDate(slot.date)}', style: AppTheme.bodyTextStyle),
            Text('Heure: ${slot.time}', style: AppTheme.bodyTextStyle),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTheme.bodyTextStyle),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rendez-vous confirmé!')),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: Text('Confirmer', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class AppointmentCard extends StatelessWidget {
  final AppointmentItem appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryPink,
                      child: Text(
                        appointment.doctorName.split(' ').last[0],
                        style: AppTheme.bodyTextStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: AppTheme.bodyTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            appointment.specialty,
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(appointment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointment.status,
                        style: AppTheme.captionStyle.copyWith(
                          color: _getStatusColor(appointment.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppTheme.lightGray),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(appointment.date)} à ${appointment.time}',
                      style: AppTheme.captionStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppTheme.lightGray),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.location,
                        style: AppTheme.captionStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'terminé':
        return AppTheme.lightGray;
      default:
        return AppTheme.lightGray;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class DoctorAvailabilityCard extends StatelessWidget {
  final DoctorAvailability availability;
  final Function(TimeSlot) onSlotTap;

  const DoctorAvailabilityCard({
    Key? key,
    required this.availability,
    required this.onSlotTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryPink,
                child: Text(
                  availability.doctorName.split(' ').last[0],
                  style: AppTheme.bodyTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      availability.doctorName,
                      style: AppTheme.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      availability.specialty,
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Créneaux disponibles:',
            style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availability.availableSlots.map((slot) {
              return GestureDetector(
                onTap: () => onSlotTap(slot),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryPink.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${_formatDate(slot.date)} ${slot.time}',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class AppointmentDetailSheet extends StatelessWidget {
  final AppointmentItem appointment;

  const AppointmentDetailSheet({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Détails du rendez-vous', style: AppTheme.subHeaderStyle),
                  const SizedBox(height: 20),
                  _buildDetailRow('Médecin', appointment.doctorName),
                  _buildDetailRow('Spécialité', appointment.specialty),
                  _buildDetailRow('Type', appointment.type),
                  _buildDetailRow('Date', _formatDate(appointment.date)),
                  _buildDetailRow('Heure', appointment.time),
                  _buildDetailRow('Lieu', appointment.location),
                  _buildDetailRow('Statut', appointment.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTheme.captionStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyTextStyle),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Data models
class AppointmentItem {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final String time;
  final String type;
  final String location;
  final String status;

  AppointmentItem({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.type,
    required this.location,
    required this.status,
  });
}

class DoctorAvailability {
  final String doctorName;
  final String specialty;
  final List<TimeSlot> availableSlots;

  DoctorAvailability({
    required this.doctorName,
    required this.specialty,
    required this.availableSlots,
  });
}

class TimeSlot {
  final DateTime date;
  final String time;

  TimeSlot({
    required this.date,
    required this.time,
  });
}