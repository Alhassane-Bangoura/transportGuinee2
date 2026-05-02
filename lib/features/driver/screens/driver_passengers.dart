import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/models/trip.dart';
import '../../../core/utils/app_response.dart';
import 'ticket_verification_screen.dart';

class DriverPassengersPage extends StatefulWidget {
  const DriverPassengersPage({super.key});

  @override
  State<DriverPassengersPage> createState() => _DriverPassengersPageState();
}

class _DriverPassengersPageState extends State<DriverPassengersPage> {
  Trip? _selectedTrip;
  List<Trip> _activeTrips = [];
  List<Map<String, dynamic>> _passengers = [];
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  Stream<List<Trip>>? _tripsStream;

  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _tripsStream = TripService.getDriverTripsStream(user.id);
    }
  }

  Future<void> _handleRefresh() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final response = await BookingService.getTripPassengers(_selectedTrip?.id ?? '');
      if (mounted) setState(() => _passengers = response.data ?? []);
    }
  }

  Future<void> _loadPassengers(String tripId) async {
    final response = await BookingService.getTripPassengers(tripId);
    if (mounted) {
      setState(() {
        _passengers = response.data ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _contactAllPassengers() async {
    if (_passengers.isEmpty) return;
    final List<String> phones = _passengers
        .map((p) => (p['profiles']?['phone'] ?? '').toString())
        .where((phone) => phone.isNotEmpty)
        .toList();
    
    if (phones.isEmpty) return;

    // Sur Android, on peut séparer par des virgules ou points-virgules selon l'app
    final String numbers = phones.join(',');
    final Uri launchUri = Uri(scheme: 'sms', path: numbers, queryParameters: {
      'body': 'Bonjour, c\'est votre chauffeur GuinéeTransport. Le départ est proche, merci de vous présenter à la gare.'
    });
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trip>>(
      stream: _tripsStream,
      builder: (context, tripSnapshot) {
        final trips = tripSnapshot.data ?? [];
        _activeTrips = trips.where((t) => t.status.toLowerCase() != 'completed' && t.status.toLowerCase() != 'cancelled').toList();
        
        if (_selectedTrip == null && _activeTrips.isNotEmpty) {
          _selectedTrip = _activeTrips.first;
          _loadPassengers(_selectedTrip!.id);
        }

        if (_activeTrips.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off_rounded, size: 64, color: AppColors.textHint.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('Aucun trajet actif trouvé.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }

    final Color primaryColor = AppColors.primary;
    final confirmedCount = _passengers.where((p) => p['status'] == 'confirmed' || p['status'] == 'used').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: Column(
          children: [
            _buildPremiumHeader(),
            _buildTripSelector(),
            _buildTripSummarySection(primaryColor, confirmedCount),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: BookingService.getTripPassengersStream(_selectedTrip!.id),
                builder: (context, snapshot) {
                  final passengers = snapshot.data ?? _passengers;
                  if (passengers.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(child: Text('Aucun passager pour ce trajet.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))),
                      ],
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: passengers.length,
                    itemBuilder: (context, index) {
                      final p = passengers[index];
                      return _buildModernPassengerCard(p, primaryColor);
                    },
                  );
                },
              ),
            ),
            _buildActionButtons(primaryColor),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildActionButtons(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _showScanSimulator();
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text('SCANNER UN TICKET', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _contactAllPassengers,
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showScanSimulator() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Simulateur de Scan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Entrez l\'ID du ticket (ou scannez un QR code en situation réelle)', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'ID de réservation',
                border: OutlineInputBorder(),
                hintText: 'ex: 550e8400-e29b...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () {
              final id = controller.text.trim();
              if (id.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TicketVerificationScreen(bookingId: id)),
                );
              }
            },
            child: const Text('VÉRIFIER'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              'GUINEE TRANSPORT',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            Text(
              'LISTE DES PASSAGERS',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSelector() {
    return Container(
      height: 60,
      width: double.infinity,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _activeTrips.length,
        itemBuilder: (context, index) {
          final trip = _activeTrips[index];
          final isSelected = _selectedTrip?.id == trip.id;
          final dateStr = DateFormat('dd/MM').format(trip.departureTime);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text('${trip.departureCityName} → ${trip.arrivalCityName} ($dateStr)'),
              selected: isSelected,
              onSelected: (selected) {
                 if (selected && !isSelected) {
                   setState(() {
                     _selectedTrip = trip;
                     _isLoading = true;
                   });
                   _loadPassengers(trip.id);
                 }
              },
              selectedColor: AppColors.primary.withOpacity(0.15),
              labelStyle: GoogleFonts.plusJakartaSans(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 12,
              ),
              backgroundColor: AppColors.background,
              side: BorderSide(
                color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.border,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripSummarySection(Color primary, int confirmedCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRAJET', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  Text('${_selectedTrip!.departureCityName} → ${_selectedTrip!.arrivalCityName}', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DATE', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  Text(DateFormat('dd MMM. yyyy').format(_selectedTrip!.departureTime), style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20)),
                child: Text('VEHICULE: ${_selectedTrip!.licensePlate ?? "N/A"}', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('${(_selectedTrip!.totalSeats ?? 0) - _selectedTrip!.availableSeats}/${_selectedTrip!.totalSeats ?? "?"} RÉSERVÉS', style: GoogleFonts.plusJakartaSans(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('$confirmedCount/${_passengers.length} PRÉSENTS', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernPassengerCard(Map<String, dynamic> p, Color primary) {
    final profile = p['profiles'] ?? {};
    final bool isPresent = p['status'] == 'confirmed' || p['status'] == 'used';
    final String name = profile['full_name'] ?? 'Passager';
    final String phone = profile['phone'] ?? '';
    final String avatar = profile['avatar_url'] ?? '';
    final String seat = '${p['seats']} Place(s)';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPresent ? Colors.green.withOpacity(0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isPresent ? Colors.green.withOpacity(0.2) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primary.withOpacity(0.1),
                backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                child: avatar.isEmpty ? Text(name.isNotEmpty ? name[0] : 'P', style: TextStyle(color: primary, fontWeight: FontWeight.bold)) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                          child: Text(seat, style: GoogleFonts.plusJakartaSans(color: primary, fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (p['payment_method'] ?? '').toLowerCase().contains('at_station') 
                                ? Colors.orange.withOpacity(0.1) 
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (p['payment_method'] ?? '').toLowerCase().contains('orange') ? 'Orange Money' : 
                            (p['payment_method'] ?? '').toLowerCase().contains('momo') ? 'MTN MoMo' : 'PAYER À LA GARE',
                            style: GoogleFonts.plusJakartaSans(
                              color: (p['payment_method'] ?? '').toLowerCase().contains('at_station') ? Colors.orange : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(phone.isEmpty ? '+224 ...' : phone, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (!isPresent) {
                      await BookingService.confirmPassengerPresence(p['id']);
                      _loadPassengers(_selectedTrip!.id);
                    }
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isPresent ? Colors.green.withOpacity(0.1) : Colors.green,
                      borderRadius: BorderRadius.circular(14),
                      border: isPresent ? Border.all(color: Colors.green.withOpacity(0.3)) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isPresent ? Icons.verified_rounded : Icons.check_circle_outline, color: isPresent ? Colors.green : Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isPresent ? 'DÉJÀ PRÉSENT' : 'CONFIRMER PRÉSENCE',
                          style: GoogleFonts.plusJakartaSans(color: isPresent ? Colors.green : Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (phone.isNotEmpty) ...[
                GestureDetector(
                  onTap: () => _makePhoneCall(phone),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.phone_rounded, color: Colors.blue, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendSMS(phone),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.chat_bubble_outline_rounded, color: primary, size: 20),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

