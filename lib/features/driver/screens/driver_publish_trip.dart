import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/trip_service.dart';
import '../../../core/services/driver_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DriverPublishTripScreen extends StatefulWidget {
  final UserProfile profile;

  const DriverPublishTripScreen({super.key, required this.profile});

  @override
  State<DriverPublishTripScreen> createState() => _DriverPublishTripScreenState();
}

class _DriverPublishTripScreenState extends State<DriverPublishTripScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _routeDetails;
  bool _isLoadingRoute = true;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  final _seatsController = TextEditingController(text: '0');
  final _priceController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _loadRouteDetails();
  }

  Future<void> _loadRouteDetails() async {
    debugPrint('[PublishTrip] Profile routeId: ${widget.profile.routeId}');
    if (widget.profile.routeId == null) {
      if (mounted) setState(() => _isLoadingRoute = false);
      return;
    }

    final response = await TripService.getRouteById(widget.profile.routeId!);
    debugPrint('[PublishTrip] Route response success: ${response.isSuccess}');
    
    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _routeDetails = response.data;
        } else {
          // Si l'ID est invalide (ex: erreur de clé étrangère en base)
          _routeDetails = null;
          debugPrint('[PublishTrip] Error: Route ID ${widget.profile.routeId} not found in database.');
        }
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.profile.routeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun itinéraire associé à votre compte.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 0. Auto-detect vehicle_id
    final vehicle = await DriverService.getDriverVehicle(widget.profile.id);
    
    // 1. Validation de l'itinéraire
    if (_routeDetails == null || widget.profile.routeId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur : Votre itinéraire est invalide ou non configuré.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final departureDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Nettoyage des entrées (trim) et conversion sécurisée
    final int seats = int.tryParse(_seatsController.text.trim()) ?? 0;
    final double price = double.tryParse(_priceController.text.trim()) ?? 0;

    if (seats <= 0 || price <= 0) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un nombre de places et un prix valides.')),
        );
      }
      return;
    }

    final tripData = {
      'route_id': widget.profile.routeId,
      'driver_id': widget.profile.id,
      'vehicle_id': vehicle?['id'],
      'departure_time': departureDateTime.toIso8601String(),
      'available_seats': seats,
      'price': price,
    };

    final response = await TripService.publishTrip(tripData);

    if (response.isSuccess) {
      // Les notifications sont maintenant gérées automatiquement par le déclencheur (trigger) 
      // de la base de données pour plus de fiabilité et de performance.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trajet publié avec succès ! Les passagers ont été notifiés.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Publier un Trajet', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoadingRoute
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Info Header (Fixed)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCitySymbol(_routeDetails?['departure_city']?['name'] ?? '...'),
                              const SizedBox(width: 12),
                              const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 28),
                              const SizedBox(width: 12),
                              _buildCitySymbol(_routeDetails?['arrival_city']?['name'] ?? '...'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.profile.routeId == null || _routeDetails == null
                              ? 'ERREUR : ITINÉRAIRE INVALIDE' 
                              : 'Itinéraire fixe (Enregistré)',
                            style: GoogleFonts.plusJakartaSans(
                              color: (widget.profile.routeId == null || _routeDetails == null) 
                                ? Colors.orangeAccent 
                                : Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (widget.profile.routeId != null && _routeDetails == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'ID: ${widget.profile.routeId}',
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text('DÉTAILS DU DÉPART', style: AppTextStyles.label),
                    const SizedBox(height: 16),

                    // Date & Time Selectors
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectorCard(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date',
                            value: DateFormat('dd MMM yyyy').format(_selectedDate),
                            onTap: _selectDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSelectorCard(
                            icon: Icons.access_time_rounded,
                            label: 'Heure',
                            value: _selectedTime.format(context),
                            onTap: _selectTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Capacity & Price
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _seatsController,
                            label: 'Places',
                            icon: Icons.event_seat_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            controller: _priceController,
                            label: 'Prix (GNF)',
                            icon: Icons.payments_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handlePublish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.rocket_launch_rounded),
                                  const SizedBox(width: 12),
                                  Text(
                                    'PUBLIER LE TRAJET',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Les passagers de l\'itinéraire seront notifiés.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCitySymbol(String name) {
    return Column(
      children: [
        Text(
          name.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            if (int.tryParse(value) == null) return 'Nombre invalide';
            return null;
          },
        ),
      ],
    );
  }
}
