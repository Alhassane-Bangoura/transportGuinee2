import 'package:flutter/material.dart';
import '../../dashboard/station_admin_dashboard.dart';

class StationAdminRegisterPage extends StatefulWidget {
  const StationAdminRegisterPage({super.key});

  @override
  State<StationAdminRegisterPage> createState() =>
      _StationAdminRegisterPageState();
}

class _StationAdminRegisterPageState extends State<StationAdminRegisterPage> {
  bool _isPasswordVisible = false;

  static const Color primaryColor = Color(0xFF0FBD0F);
  static const Color backgroundColor = Color(0xFFF6F8F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Inscription Admin Gare',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings,
                          color: primaryColor, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Informations Administrateur',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Créez votre compte de gestionnaire de gare pour GuineeTransport.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 32),

                    _buildLabel('Nom complet'),
                    _buildTextField(
                        hint: 'Ex: Mamadou Diallo', icon: Icons.person_outline),

                    const SizedBox(height: 16),
                    _buildLabel('Téléphone'),
                    _buildTextField(
                        hint: '+224 6XX XX XX XX',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone),

                    const SizedBox(height: 16),
                    _buildLabel('Email professionnel'),
                    _buildTextField(
                        hint: 'admin@gare-conakry.gn',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress),

                    const SizedBox(height: 16),
                    _buildLabel('Mot de passe'),
                    _buildTextField(
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      onToggle: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    const Text(
                      'Affectation Professionnelle',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Gare assignée'),
                    _buildDropdownField(
                      hint: 'Sélectionner une gare',
                      options: [
                        'Gare Routière de Bambeto (Conakry)',
                        'Gare Routière de Madina (Conakry)',
                        'Gare Centrale de Kindia',
                        'Gare de Kouroula (Labé)',
                        'Gare de Kankan'
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Numéro d’employé'),
                              _buildTextField(hint: 'EMP-2024'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Fonction'),
                              _buildDropdownField(
                                options: [
                                  'Responsable Départ',
                                  'Responsable Arrivée',
                                  'Chef Billetterie',
                                  'Gérant Principal'
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StationAdminDashboard()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          shadowColor: primaryColor.withOpacity(0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Créer mon compte admin',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.how_to_reg, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(
                            text:
                                'En cliquant sur "Créer mon compte", vous acceptez les ',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                            children: [
                              TextSpan(
                                  text: 'conditions d\'utilisation',
                                  style: TextStyle(
                                      color: primaryColor,
                                      decoration: TextDecoration.underline)),
                              TextSpan(
                                  text:
                                      ' professionnelles de GuineeTransport.'),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Footer Promo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                                color: primaryColor, shape: BoxShape.circle),
                            child: const Icon(Icons.map,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Digitalisation locale',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text(
                                    'Aidez-nous à moderniser les gares de Guinée.',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      size: 18),
                  onPressed: onToggle)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField({String? hint, required List<String> options}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: hint != null
              ? Text(hint,
                  style: const TextStyle(color: Colors.grey, fontSize: 14))
              : null,
          isExpanded: true,
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {},
        ),
      ),
    );
  }
}
