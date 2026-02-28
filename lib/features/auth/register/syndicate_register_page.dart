import 'package:flutter/material.dart';
import '../../dashboard/syndicate_dashboard.dart';

class SyndicateRegisterPage extends StatefulWidget {
  const SyndicateRegisterPage({super.key});

  @override
  State<SyndicateRegisterPage> createState() => _SyndicateRegisterPageState();
}

class _SyndicateRegisterPageState extends State<SyndicateRegisterPage> {
  bool _isPasswordVisible = false;

  static const Color primaryColor = Color(0xFF135BEC);
  static const Color backgroundColor = Color(0xFFF6F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav Bar
            Container(
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.8),
                border: const Border(bottom: BorderSide(color: Colors.black12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Inscription Syndicat',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance,
                        color: primaryColor, size: 16),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.app_registration,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Portail GuineeTransport',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(
                                  'Digitalisation du transport interurbain. Enregistrez votre entité officielle.',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section: Organisation
                    _buildSectionHeader('Détails de l\'Organisation'),
                    _buildLabel('Nom du syndicat'),
                    _buildTextField(
                        hint: 'Ex: Syndicat des Transporteurs',
                        icon: Icons.groups_outlined),

                    const SizedBox(height: 16),
                    _buildLabel('Ville représentée'),
                    _buildDropdownField(
                        hint: 'Sélectionner une ville',
                        options: [
                          'Conakry',
                          'Kindia',
                          'Boké',
                          'Labé',
                          'Kankan',
                          'Nzérékoré'
                        ]),

                    const SizedBox(height: 16),
                    _buildLabel('Numéro d’enregistrement'),
                    _buildTextField(
                        hint: 'SYND-GN-000', icon: Icons.badge_outlined),

                    const SizedBox(height: 16),
                    _buildLabel('Adresse du bureau'),
                    _buildTextField(
                        hint: 'Ex: Boulbinet, Kaloum',
                        icon: Icons.home_work_outlined),

                    const SizedBox(height: 24),
                    const Divider(height: 32, thickness: 1),

                    // Section: Responsable
                    _buildSectionHeader('Détails du Responsable'),
                    _buildLabel('Nom complet du responsable'),
                    _buildTextField(
                        hint: 'Ex: Mamadou Diallo', icon: Icons.person_outline),

                    const SizedBox(height: 16),
                    _buildLabel('Téléphone personnel'),
                    _buildTextField(
                        hint: '+224 6XX XX XX XX',
                        icon: Icons.phone_iphone_outlined,
                        keyboardType: TextInputType.phone),

                    const SizedBox(height: 24),
                    const Divider(height: 32, thickness: 1),

                    // Section: Sécurité
                    _buildSectionHeader('Sécurité du Compte'),
                    _buildLabel('Mot de passe'),
                    _buildTextField(
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      onToggle: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                          'Utilisez au moins 8 caractères avec des chiffres et symboles.',
                          style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey)),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SyndicateDashboard()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.how_to_reg, size: 20),
                            SizedBox(width: 8),
                            Text('Finaliser l\'inscription',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: "En cliquant sur finaliser, vous acceptez les ",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                          children: [
                            TextSpan(
                                text: "Conditions Générales d'Utilisation",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline)),
                            TextSpan(text: " de GuineeTransport."),
                          ],
                        ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: primaryColor),
          const SizedBox(width: 12),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black87)),
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
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.black45, size: 20) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black45,
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

  Widget _buildDropdownField(
      {required String hint, required List<String> options}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black45),
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {},
        ),
      ),
    );
  }
}
