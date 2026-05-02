import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/booking.dart';

class PassengerTicket extends StatefulWidget {
  final Booking booking;

  const PassengerTicket({super.key, required this.booking});

  @override
  State<PassengerTicket> createState() => _PassengerTicketState();
}

class _PassengerTicketState extends State<PassengerTicket> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  // Capture le widget ticket en image PNG via le package screenshot
  Future<Uint8List?> _captureTicket() async {
    try {
      // Attendre un peu que le rendu soit stable
      await Future.delayed(const Duration(milliseconds: 100));
      return await _screenshotController.capture(pixelRatio: 3.0);
    } catch (e) {
      debugPrint('Error capturing ticket: $e');
      return null;
    }
  }

  // Génère et partage le ticket en PDF
  Future<void> _downloadPdf() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final Uint8List? imageBytes = await _captureTicket();
      if (imageBytes == null) throw Exception('Capture échouée');

      final doc = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );

      final String shortId = widget.booking.id.length >= 8 ? widget.booking.id.substring(0, 8) : widget.booking.id;
      await Printing.sharePdf(bytes: await doc.save(), filename: 'ticket_${shortId.toUpperCase()}.pdf');
    } catch (e) {
      debugPrint('PDF Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur PDF: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Sauvegarde et partage le ticket en image
  Future<void> _downloadTicket() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final Uint8List? imageBytes = await _captureTicket();
      if (imageBytes == null) throw Exception('Capture échouée');
      final String shortId = widget.booking.id.length >= 8 
          ? widget.booking.id.substring(0, 8).toUpperCase() 
          : widget.booking.id.toUpperCase();
      final String fileName = 'ticket_$shortId.png';
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Mon ticket GuinéeTransport #$shortId');
    } catch (e) {
      debugPrint('Capture/Share Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final bool isPending = b.status == 'pending';
    final Color statusColor = isPending ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    // Préparation des données complètes pour le QR Code
    final Map<String, dynamic> qrDataMap = {
      'id': b.id,
      'p_name': b.passengerName,
      'p_phone': b.passengerPhone,
      'd_name': b.driverName,
      'v_model': b.vehicleModel,
      'v_plate': b.vehiclePlate,
      'route': '${b.departureCityName} -> ${b.arrivalCityName}',
      'date': b.departureTime?.toIso8601String(),
      'price': b.totalPrice,
      'seats': b.seats,
      'res_time': b.createdAt.toIso8601String(),
    };
    final String qrData = jsonEncode(qrDataMap);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(
          'Votre Billet',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          children: [
            // Status Icon + Message
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.access_time_rounded : Icons.check_circle_rounded,
                color: statusColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPending ? 'Réservation en Attente' : 'Réservation Confirmée !',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPending
                  ? 'Payez à la gare pour confirmer votre place.'
                  : 'Votre billet est prêt. Bon voyage !',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // ── Ticket Card (captured as image) ──────────────────────────────
            Screenshot(
              controller: _screenshotController,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Header bleu du ticket ─────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'GUINÉE TRANSPORT',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                b.departureCityName ?? 'N/A',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 20),
                              ),
                              Text(
                                b.arrivalCityName ?? 'N/A',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              isPending ? 'À PAYER À LA GARE' : 'CONFIRMÉ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Infos de voyage ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Section Passager
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                backgroundImage: (b.passengerAvatarUrl != null &&
                                        b.passengerAvatarUrl!.isNotEmpty)
                                    ? NetworkImage(b.passengerAvatarUrl!)
                                    : null,
                                child: (b.passengerAvatarUrl == null || b.passengerAvatarUrl!.isEmpty)
                                    ? const Icon(Icons.person_rounded,
                                        color: AppColors.primary, size: 26)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PASSAGER',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      b.passengerName ?? 'Passager',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      b.passengerPhone ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _DividerRow(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfo(
                                Icons.calendar_today_rounded,
                                'DATE',
                                b.departureTime != null
                                    ? DateFormat('dd MMM yyyy', 'fr_FR').format(b.departureTime!)
                                    : 'N/A',
                              ),
                              const SizedBox(width: 20),
                              _buildInfo(
                                Icons.access_time_rounded,
                                'HEURE',
                                b.departureTime != null
                                    ? DateFormat('HH:mm').format(b.departureTime!)
                                    : 'N/A',
                              ),
                              const Spacer(),
                              _buildInfo(
                                Icons.event_seat_rounded,
                                'SIÈGE(S)',
                                b.seats.toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _DividerRow(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfo(
                                  Icons.place_rounded,
                                  'GARE DÉPART',
                                  b.departureStationName ?? 'N/A',
                                ),
                              ),
                              Expanded(
                                child: _buildInfo(
                                  Icons.place_rounded,
                                  'GARE ARRIVÉE',
                                  b.arrivalStationName ?? 'N/A',
                                  alignEnd: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _DividerRow(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfo(
                                  Icons.payments_rounded,
                                  'MODE DE PAIEMENT',
                                  (b.paymentMethod ?? '').toLowerCase().contains('orange') ? 'Orange Money' : 
                                  (b.paymentMethod ?? '').toLowerCase().contains('momo') ? 'MTN MoMo' : 'À PAYER À LA GARE',
                                ),
                              ),
                              Expanded(
                                child: _buildInfo(
                                  Icons.history_toggle_off_rounded,
                                  'RÉSERVÉ LE',
                                  DateFormat('dd/MM HH:mm').format(b.createdAt),
                                  alignEnd: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _DividerRow(),
                          const SizedBox(height: 16),

                          // ── Section Chauffeur & Voiture ─────────────────────────────
                          Row(
                            children: [
                              // Photo du chauffeur
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                backgroundImage: (b.driverAvatarUrl != null &&
                                        b.driverAvatarUrl!.isNotEmpty)
                                    ? NetworkImage(b.driverAvatarUrl!)
                                    : null,
                                child: (b.driverAvatarUrl == null || b.driverAvatarUrl!.isEmpty)
                                    ? const Icon(Icons.person_rounded,
                                        color: AppColors.primary, size: 26)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CHAUFFEUR & VÉHICULE',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      b.driverName ?? 'En attente',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${b.vehicleModel ?? "Véhicule"} • ${b.vehiclePlate ?? "..."}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'PRIX',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b.formattedPrice,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Ligne de découpe ─────────────────────────────────────
                    Row(
                      children: [
                        _buildCutter(isLeft: true),
                        Expanded(
                          child: CustomPaint(
                            painter: _DashedPainter(),
                            child: const SizedBox(height: 1),
                          ),
                        ),
                        _buildCutter(isLeft: false),
                      ],
                    ),

                    // ── QR Code ───────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 140,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppColors.primary,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'TICKET #${widget.booking.id.length >= 8 ? widget.booking.id.substring(0, 8).toUpperCase() : widget.booking.id.toUpperCase()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Présentez ce QR code pour l\'embarquement',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Boutons d'action ────────────────────────────────────────────
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _downloadTicket,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.image_rounded),
                        label: Text(
                          _isSaving ? 'PRÉPARATION...' : 'IMAGE',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _downloadPdf,
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: Text(
                          'PDF',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextButton.icon(
                    onPressed: _isSaving ? null : _downloadTicket,
                    icon: const Icon(Icons.share_rounded, color: AppColors.primary),
                    label: Text('PARTAGER LE TICKET', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Le ticket est également disponible dans "Mes Billets"',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String label, String value,
      {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCutter({required bool isLeft}) {
    return Container(
      width: 18,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topRight: isLeft ? const Radius.circular(18) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(18) : Radius.zero,
          topLeft: !isLeft ? const Radius.circular(18) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(18) : Radius.zero,
        ),
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.border);
  }
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5;
    const dashW = 6.0;
    const dashS = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashW, 0), paint);
      x += dashW + dashS;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
