import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PassengerRegisterPage extends StatefulWidget {
  const PassengerRegisterPage({super.key});

  @override
  State<PassengerRegisterPage> createState() => _PassengerRegisterPageState();
}

class _PassengerRegisterPageState extends State<PassengerRegisterPage> {
  bool _isPasswordVisible = false;
  bool _acceptTerms = false;

  static const Color primaryColor = Color(0xFF0AC247);
  static const Color backgroundColor = Color(0xFFF5F8F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Inscription Passager',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    Text(
                      'Créer votre compte',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Veuillez remplir les informations ci-dessous pour commencer vos trajets avec GuineeTransport.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildFieldLabel('Nom complet'),
                    _buildTextField(
                        hint: 'Ex: Mamadou Diallo', icon: Icons.person_outline),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Numéro de téléphone'),
                    _buildTextField(
                        hint: '+224 6XX XX XX XX',
                        icon: Icons.phone_iphone_outlined,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Email'),
                    _buildTextField(
                        hint: 'votre@email.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Mot de passe'),
                    _buildTextField(
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      onSuffixTap: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Confirmer le mot de passe'),
                    _buildTextField(
                        hint: '••••••••',
                        icon: Icons.lock_reset_outlined,
                        isPassword: true,
                        obscureText: true),

                    const SizedBox(height: 24),

                    // Emergency Contact Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.contact_emergency_outlined,
                                  color: primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Contact d’urgence',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel('Nom du contact'),
                          _buildTextField(hint: 'Nom du proche', isSmall: true),
                          const SizedBox(height: 12),
                          _buildFieldLabel('Numéro du contact'),
                          _buildTextField(
                              hint: '+224 6XX XX XX XX',
                              isSmall: true,
                              keyboardType: TextInputType.phone),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (v) =>
                              setState(() => _acceptTerms = v ?? false),
                          activeColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "J'accepte les ",
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF64748B)),
                              children: [
                                TextSpan(
                                    text: "Conditions d'Utilisation",
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold)),
                                const TextSpan(text: " et la "),
                                TextSpan(
                                    text: "Politique de Confidentialité",
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold)),
                                const TextSpan(text: " de GuineeTransport."),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('S\'inscrire',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Déjà un compte ? ",
                          style: const TextStyle(color: Color(0xFF64748B)),
                          children: [
                            TextSpan(
                              text: "Se connecter",
                              style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.maybePop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
    bool isSmall = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: icon != null
              ? Icon(icon, color: primaryColor.withOpacity(0.7))
              : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF94A3B8)),
                  onPressed: onSuffixTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: isSmall ? 12 : 16),
        ),
      ),
    );
  }
}
