import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class DriverDocumentsScreen extends StatefulWidget {
  final Map<String, dynamic>? metadata;

  const DriverDocumentsScreen({super.key, this.metadata});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  late Map<String, dynamic> _currentMetadata;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentMetadata = Map<String, dynamic>.from(widget.metadata ?? {});
  }

  Future<void> _updateDocumentStatus(String key, String status) async {
    setState(() => _isUpdating = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final newMetadata = {
        ..._currentMetadata,
        key: status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('profiles').update({
        'metadata': newMetadata,
      }).eq('id', userId);

      if (mounted) {
        setState(() {
          _currentMetadata = newMetadata;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document mis à jour avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _viewDocument(String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.description_outlined, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text('Aperçu du document sécurisé', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, String statusKey) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        // Dans une vraie app, on uploaderait ici vers Supabase Storage
        // Ici, on simule l'envoi réussi pour mettre à jour le statut
        await _updateDocumentStatus(statusKey, 'VALIDE');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur galerie : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceSheet(String docTitle, String statusKey) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Téléverser $docTitle', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Choisissez une source pour le document', textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, statusKey);
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Caméra'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, statusKey);
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galerie'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Documents Officiels',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildDocumentCard(
                  title: 'Permis de conduire',
                  status: _currentMetadata['license_status'] ?? 'VALIDE',
                  statusKey: 'license_status',
                  icon: Icons.assignment_ind_rounded,
                  expiry: _currentMetadata['expiry_date'] ?? '06/04/2027',
                ),
                const SizedBox(height: 16),
                _buildDocumentCard(
                  title: 'Assurance véhicule',
                  status: _currentMetadata['insurance_status'] ?? 'À RENOUVELER',
                  statusKey: 'insurance_status',
                  icon: Icons.verified_user_rounded,
                  expiry: '12/05/2026',
                ),
                const SizedBox(height: 16),
                _buildDocumentCard(
                  title: 'Carte grise',
                  status: _currentMetadata['registration_status'] ?? 'VALIDE',
                  statusKey: 'registration_status',
                  icon: Icons.description_rounded,
                  expiry: 'Permanent',
                ),
                const SizedBox(height: 40),
                _buildUploadButton(),
              ],
            ),
          ),
          if (_isUpdating)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1A5F7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conformité du compte',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  'Gardez vos documents à jour pour continuer à rouler sur la plateforme.',
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String status,
    required String statusKey,
    required IconData icon,
    required String expiry,
  }) {
    // Calcul de l'état réel
    bool isExpired = false;
    try {
      final date = DateFormat('dd/MM/yyyy').parse(expiry);
      if (date.isBefore(DateTime.now())) {
        isExpired = true;
      }
    } catch (_) {}

    String statusLabel = status.toUpperCase();
    if (statusLabel.isEmpty || statusLabel == 'NULL') {
      statusLabel = 'PAS DE DOCUMENT';
    } else if (isExpired) {
      statusLabel = 'À RENOUVELER';
    }

    final isValide = statusLabel == 'VALIDE';
    final isPending = statusLabel == 'EN ATTENTE';
    final isError = statusLabel == 'À RENOUVELER' || statusLabel == 'PAS DE DOCUMENT';
    
    final statusColor = isValide 
        ? AppColors.success 
        : (isPending ? Colors.blue : (isError ? Colors.red : Colors.orange));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
                    Text('Expire le : $expiry', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _viewDocument(title),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Voir'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
                ),
              ),
              Container(width: 1, height: 20, color: AppColors.border),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showImageSourceSheet(title, statusKey),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Modifier'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              'Ajouter un nouveau document',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
