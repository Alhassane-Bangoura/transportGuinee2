import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/models/trip.dart';
import '../../../core/utils/app_response.dart';

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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      setState(() => _isLoading = true);
      
      // 1. Charger tous les trajets du chauffeur qui ne sont pas complétés
      // On utilise .not.in() pour exclure plusieurs états de fin de vie
      final response = await _supabase
          .from('trips_with_details')
          .select()
          .eq('driver_id', user.id)
          .filter('status', 'not.ilike', 'completed')
          .filter('status', 'not.ilike', 'cancelled')
          .order('departure_time', ascending: true);
          
      final trips = (response as List).map((t) => Trip.fromJson(t)).toList();
      
      if (trips.isNotEmpty) {
        setState(() {
          _activeTrips = trips;
          // On sélectionne par défaut le trajet le plus proche du départ
          _selectedTrip = trips.first;
        });
        await _loadPassengers(_selectedTrip!.id);
      } else {
        setState(() {
          _activeTrips = [];
          _selectedTrip = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading initial passengers data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadInitialData();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_selectedTrip == null) {
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
              child: _passengers.isEmpty 
                ? ListView( // Utiliser ListView pour que RefreshIndicator fonctionne même si vide
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(child: Text('Aucun passager pour ce trajet.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _passengers.length,
                    itemBuilder: (context, index) {
                      final p = _passengers[index];
                      return _buildModernPassengerCard(p, primaryColor);
                    },
                  ),
            ),
            _buildFloatingContactAll(primaryColor),
          ],
        ),
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
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text('${trip.departureCityName} → ${trip.arrivalCityName}'),
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
                child: Text('$confirmedCount/${_passengers.length} CONFIRMÉS', style: GoogleFonts.plusJakartaSans(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900)),
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
    final String phone = profile['phone'] ?? '+224 ...';
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
                child: Text(name.isNotEmpty ? name[0] : 'P', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
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
                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(phone, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
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
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.chat_bubble_outline_rounded, color: primary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingContactAll(Color primary) {
    return Container(
      padding: const EdgeInsets.only(bottom: 110, left: 16, right: 16, top: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.textPrimary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('CONTACTER TOUS LES PASSAGERS', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
