import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../auth/login_page.dart';
import '../../profile/screens/edit_profile_page.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/models/wallet_transaction.dart';
import 'passenger_wallet_history.dart';
import 'dart:async';

class PassengerProfile extends StatefulWidget {
  final UserProfile? profile;
  final VoidCallback? onRefresh;
  const PassengerProfile({super.key, this.profile, this.onRefresh});

  @override
  State<PassengerProfile> createState() => _PassengerProfileState();
}

class _PassengerProfileState extends State<PassengerProfile> {
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  late double _walletBalance;
  StreamSubscription<double>? _balanceSubscription;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
    _walletBalance = WalletService().balance;
    _initWallet();
  }

  Future<void> _initWallet() async {
    await WalletService().init();
    if (mounted) {
      setState(() => _walletBalance = WalletService().balance);
    }
    _balanceSubscription = WalletService().onBalanceChanged.listen((newBalance) {
      if (mounted) setState(() => _walletBalance = newBalance);
    });
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadBiometricSettings() async {
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = available;
        _isBiometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        await BiometricService.setBiometricEnabled(true);
        setState(() => _isBiometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentification biométrique activée')),
          );
        }
      }
    } else {
      await BiometricService.setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Choisir la langue', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Français', style: TextStyle(color: AppColors.primary)),
              trailing: Icon(Icons.check, color: AppColors.primary),
            ),
            ListTile(
              title: Text('English', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Traduction en cours de développement.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    String errorMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Changer le mot de passe', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(errorMessage, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                    ),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Mot de passe actuel',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nouveau mot de passe',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Confirmer le nouveau mot de passe',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context), 
                child: const Text('Annuler')
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (currentPasswordController.text.isEmpty || newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
                    setDialogState(() => errorMessage = 'Veuillez remplir tous les champs.');
                    return;
                  }
                  if (newPasswordController.text != confirmPasswordController.text) {
                    setDialogState(() => errorMessage = 'Les nouveaux mots de passe ne correspondent pas.');
                    return;
                  }
                  if (newPasswordController.text.length < 6) {
                    setDialogState(() => errorMessage = 'Le nouveau mot de passe doit faire au moins 6 caractères.');
                    return;
                  }

                  setDialogState(() {
                    isLoading = true;
                    errorMessage = '';
                  });

                  try {
                    final email = Supabase.instance.client.auth.currentUser?.email;
                    if (email == null) throw Exception('Email non trouvé');

                    // Vérifier l'ancien mot de passe
                    await Supabase.instance.client.auth.signInWithPassword(
                      email: email,
                      password: currentPasswordController.text,
                    );

                    // Mettre à jour avec le nouveau
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(password: newPasswordController.text)
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe mis à jour avec succès!')));
                    }
                  } on AuthException catch (e) {
                    setDialogState(() {
                      isLoading = false;
                      if (e.message.contains('Invalid login')) {
                        errorMessage = 'Le mot de passe actuel est incorrect.';
                      } else {
                        errorMessage = 'Erreur: ${e.message}';
                      }
                    });
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = 'Erreur inattendue.';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Modifier', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showTopUpDialog() {
    final amountController = TextEditingController();
    String selectedMethod = 'orange';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Recharger mon compte', 
              style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Numéro de téléphone (Retrait)', 
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      hintText: 'ex: 622 00 00 00',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      prefixIcon: const Icon(Icons.phone_android, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Entrez le montant (GNF)', 
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      hintText: 'ex: 50000',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Moyen de paiement', 
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 12),
                  
                  // Orange Money
                  _buildPaymentMethodItem(
                    id: 'orange',
                    name: 'Orange Money',
                    label: 'ORANGE',
                    color: const Color(0xFFFF7900),
                    isSelected: selectedMethod == 'orange',
                    onTap: () => setDialogState(() => selectedMethod = 'orange'),
                  ),
                  const SizedBox(height: 8),
                  
                  // MTN MoMo
                  _buildPaymentMethodItem(
                    id: 'mtn',
                    name: 'MTN Mobile Money',
                    label: 'MTN',
                    color: const Color(0xFFFFCC00),
                    textColor: const Color(0xFF004F9E),
                    isSelected: selectedMethod == 'mtn',
                    onTap: () => setDialogState(() => selectedMethod = 'mtn'),
                  ),
                  const SizedBox(height: 8),
                  
                  // Kulu
                  _buildPaymentMethodItem(
                    id: 'kulu',
                    name: 'Kulu Transfert',
                    label: 'KULU',
                    color: const Color(0xFF0EA5E9),
                    isSelected: selectedMethod == 'kulu',
                    onTap: () => setDialogState(() => selectedMethod = 'kulu'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () {
                  final amountText = amountController.text;
                  if (amountText.isNotEmpty) {
                    final amount = double.tryParse(amountText) ?? 0;
                    Navigator.pop(context);
                    _processTopUp(amount, selectedMethod);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text('Recharger', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required String id,
    required String name,
    required String label,
    required Color color,
    Color textColor = Colors.white,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Text(label, style: TextStyle(color: textColor, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Text(name, style: TextStyle(color: AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  void _processTopUp(double amount, String methodId) {
    String methodName = {
      'orange': 'Orange Money',
      'mtn': 'MTN Mobile Money',
      'kulu': 'Kulu Transfert',
    }[methodId] ?? 'Orange Money';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    // Simulation de délai de traitement
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        Navigator.pop(context); // Fermer le chargement
        
        final newTx = WalletTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: widget.profile?.id ?? 'unknown',
          amount: amount,
          type: TransactionType.topup,
          method: methodName,
          description: 'Rechargement de compte',
          createdAt: DateTime.now(),
        );

        await WalletService().addTransaction(newTx);
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
              content: Text(
                'Félicitations ! Votre compte a été rechargé de ${amount.toInt()} GNF via $methodName.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text('Génial !', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primary;
    final Color backgroundColor = AppColors.background;
    final Color textSlate900 = AppColors.textPrimary;
    final Color textSlate500 = AppColors.textSecondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(primaryColor, textSlate900, textSlate500),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildWalletCard(primaryColor),
                    const SizedBox(height: 24),
                    _buildMenuSection(
                      title: 'PARAMÈTRES',
                      items: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Informations personnelles',
                          onTap: () async {
                            if (widget.profile == null) return;
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(profile: widget.profile!),
                              ),
                            );
                            if (updated == true && context.mounted) {
                              widget.onRefresh?.call();
                            }
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_none,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Notifications',
                          trailing: _buildBadge('3'),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Aucune nouvelle notification importante.')),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.language,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Langue',
                          trailing: Text(
                            'Français',
                            style: GoogleFonts.plusJakartaSans(color: textSlate500, fontSize: 14),
                          ),
                          onTap: _showLanguageDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildMenuSection(
                      title: 'SÉCURITÉ',
                      items: [
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          iconColor: const Color(0xFFEF4444),
                          title: 'Changer le mot de passe',
                          onTap: _showPasswordDialog,
                        ),
                        if (_isBiometricAvailable)
                          _buildMenuItem(
                            icon: Icons.fingerprint,
                            iconColor: const Color(0xFF10B981),
                            title: 'Authentification biométrique',
                            trailing: Switch(
                              value: _isBiometricEnabled,
                              onChanged: _toggleBiometric,
                              activeColor: primaryColor,
                            ),
                            onTap: () {},
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildMenuSection(
                      title: 'AIDE & SUPPORT',
                      items: [
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          iconColor: const Color(0xFF6366F1),
                          title: 'Centre d\'aide',
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.surface,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                              builder: (context) => Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Centre d\'aide', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 16),
                                    Text('Besoin d\'assistance ? Contactez-nous :', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary)),
                                    const SizedBox(height: 24),
                                    ListTile(
                                      leading: const Icon(Icons.phone, color: AppColors.primary),
                                      title: const Text('Appeler le support', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                      subtitle: const Text('+224 622 00 00 00', style: TextStyle(color: AppColors.textSecondary)),
                                      onTap: () {},
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.chat, color: Colors.green),
                                      title: const Text('WhatsApp', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                      subtitle: const Text('+224 622 00 00 00', style: TextStyle(color: AppColors.textSecondary)),
                                      onTap: () {},
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.email, color: Colors.orange),
                                      title: const Text('Email', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                      subtitle: const Text('support@guineetransport.com', style: TextStyle(color: AppColors.textSecondary)),
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.description_outlined,
                          iconColor: const Color(0xFF64748B),
                          title: 'Conditions d\'utilisation',
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.surface,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                              builder: (context) => DraggableScrollableSheet(
                                initialChildSize: 0.8,
                                minChildSize: 0.5,
                                maxChildSize: 0.95,
                                expand: false,
                                builder: (_, scrollController) => Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Conditions d\'utilisation', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          controller: scrollController,
                                          child: Text(
                                            '1. Introduction\nBienvenue sur GuinéeTransport. En utilisant notre application, vous acceptez les présentes conditions...\n\n'
                                            '2. Réservations et Paiements\nLes billets sont nominatifs. Tout paiement effectué via Orange Money ou MTN est définitif. Aucun remboursement n\'est garanti en cas d\'annulation tardive (moins de 2h avant le départ).\n\n'
                                            '3. Responsabilités du passager\nLe passager doit se présenter à la gare au moins 30 minutes avant le départ. Les bagages de plus de 20kg peuvent être soumis à une tarification supplémentaire par le syndicat.\n\n'
                                            '4. Sécurité des données\nVos données sont protégées et ne seront jamais revendues à des tiers.',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await AuthService.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text('Se déconnecter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE2E2),
                          foregroundColor: const Color(0xFFEF4444),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Version 2.4.0', style: GoogleFonts.plusJakartaSans(color: textSlate500, fontSize: 12)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(Color primary, Color titleColor, Color subtitleColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text('Profil', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withOpacity(0.2), width: 4),
                ),
                child: ClipOval(
                  child: widget.profile?.avatarUrl != null && widget.profile!.avatarUrl!.startsWith('http')
                    ? Image.network(
                        widget.profile!.avatarUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) => Image.network(AppAssets.stationPreview, fit: BoxFit.cover),
                      )
                    : Image.network(AppAssets.stationPreview, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: GestureDetector(
                  onTap: () async {
                    if (widget.profile == null) return;
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(profile: widget.profile!),
                      ),
                    );
                    if (updated == true && context.mounted) {
                      widget.onRefresh?.call();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.profile?.cleanFullName ?? 'Utilisateur',
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
          ),
          Text(widget.profile?.phone ?? '+224 000 00 00 00', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: subtitleColor)),
        ],
      ),
    );
  }

  Widget _buildWalletCard(Color primary) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        image: const DecorationImage(image: NetworkImage(AppAssets.patternCubes), opacity: 0.1, repeat: ImageRepeat.repeat),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solde Portefeuille', 
                    style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text('${_walletBalance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")} GNF',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showTopUpDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: primary, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Recharger', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PassengerWalletHistory(transactions: WalletService().transactions),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Historique', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0)),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({required IconData icon, required Color iconColor, required String title, Widget? trailing, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
