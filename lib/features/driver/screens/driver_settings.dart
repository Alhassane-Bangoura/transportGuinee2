import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _smsEnabled = true;
  bool _locationEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('pref_notifications') ?? true;
      _smsEnabled = prefs.getBool('pref_sms') ?? true;
      _locationEnabled = prefs.getBool('pref_location') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Changer le mot de passe', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPasswordField(oldPasswordController, 'Mot de passe actuel'),
              const SizedBox(height: 12),
              _buildPasswordField(newPasswordController, 'Nouveau mot de passe'),
              const SizedBox(height: 12),
              _buildPasswordField(confirmPasswordController, 'Confirmer le mot de passe'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Les nouveaux mots de passe ne correspondent pas.'))
                  );
                  return;
                }
                
                setDialogState(() => isSaving = true);
                final res = await AuthService.changePassword(
                  oldPassword: oldPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                
                if (mounted) {
                  if (res.isSuccess) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mot de passe mis à jour avec succès.'))
                    );
                  } else {
                    setDialogState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.message), backgroundColor: Colors.red)
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('CONFIRMER'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Paramètres', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Préférences'),
          _buildSwitchItem(
            Icons.notifications_active_outlined, 
            'Notifications Push', 
            'Recevoir les alertes de réservation dans l\'app', 
            _notificationsEnabled, 
            (v) {
              setState(() => _notificationsEnabled = v);
              _saveSetting('pref_notifications', v);
            }
          ),
          _buildSwitchItem(
            Icons.message_outlined, 
            'Notifications SMS', 
            'Recevoir les alertes par SMS', 
            _smsEnabled, 
            (v) {
              setState(() => _smsEnabled = v);
              _saveSetting('pref_sms', v);
            }
          ),
          _buildSwitchItem(
            Icons.location_on_outlined, 
            'Localisation en arrière-plan', 
            'Permettre aux passagers de suivre le bus', 
            _locationEnabled, 
            (v) {
              setState(() => _locationEnabled = v);
              _saveSetting('pref_location', v);
            }
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Gestion du compte'),
          _buildActionItem(Icons.lock_outline, 'Changer de mot de passe', () => _showChangePasswordDialog()),
          _buildActionItem(Icons.language_rounded, 'Changer la langue', () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le français est la langue par défaut.')));
          }),
          _buildActionItem(Icons.delete_outline, 'Supprimer le compte', () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Supprimer le compte ?'),
                content: const Text('Cette action est définitive. Toutes vos données seront supprimées.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red))),
                ],
              ),
            );
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900,
          color: AppColors.textHint,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: AppColors.primary,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: AppColors.border,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.redAccent : AppColors.textPrimary;
    final iconBgColor = isDestructive ? Colors.redAccent.withOpacity(0.1) : AppColors.primary.withOpacity(0.1);
    final iconColor = isDestructive ? Colors.redAccent : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: isDestructive ? Colors.redAccent.withOpacity(0.2) : AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: color, fontSize: 15)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: isDestructive ? Colors.redAccent.withOpacity(0.5) : AppColors.textHint, size: 14),
      ),
    );
  }
}
