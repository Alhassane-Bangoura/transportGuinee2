import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/booking.dart';

class PassengerTicket extends StatefulWidget {
  final Booking booking;

  const PassengerTicket({super.key, required this.booking});

  @override
  State<PassengerTicket> createState() => _PassengerTicketState();
}

class _PassengerTicketState extends State<PassengerTicket> {
  final GlobalKey _ticketKey = GlobalKey();
  bool _isSaving = false;

  // Capture le widget ticket en image PNG
  Future<Uint8List?> _captureTicket() async {
    try {
      final RenderRepaintBoundary boundary =
          _ticketKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing ticket: $e');
      return null;
    }
  }

  // Sauvegarde et partage le ticket en image
  Future<void> _downloadTicket() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final Uint8List? imageBytes = await _captureTicket();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la capture du ticket.')),
          );
        }
        return;
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'ticket_${widget.booking.id.substring(0, 8).toUpperCase()}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Mon ticket GuinéeTransport — ${widget.booking.departureCityName ?? ''} ➔ ${widget.booking.arrivalCityName ?? ''}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
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
            RepaintBoundary(
              key: _ticketKey,
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

                          // ── Section Chauffeur ─────────────────────────────
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
                                      'CHAUFFEUR',
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (b.driverPhone != null)
                                      Text(
                                        b.driverPhone!,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
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
                              data: 'GT-${b.id}-${b.tripId}',
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
                            'TICKET #${b.id.substring(0, 8).toUpperCase()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Présentez ce QR code à la gare',
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
                        : const Icon(Icons.download_rounded),
                    label: Text(
                      _isSaving ? 'PRÉPARATION...' : 'SAUVEGARDER',
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(14),
                    icon: const Icon(Icons.share_rounded, color: AppColors.primary),
                    onPressed: _isSaving ? null : _downloadTicket,
                    tooltip: 'Partager le ticket',
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
