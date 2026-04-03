import 'package:flutter/material.dart';
import 'package:guineetransport/core/theme/app_colors.dart';
import 'package:guineetransport/core/services/auth_service.dart';
import 'package:guineetransport/core/widgets/success_dialog.dart'; // Ajouté ici
import '../login_page.dart';

class PassengerRegisterPage extends StatefulWidget {
  const PassengerRegisterPage({super.key});

  @override
  State<PassengerRegisterPage> createState() => _PassengerRegisterPageState();
}

class _PassengerRegisterPageState extends State<PassengerRegisterPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // New Theme Colors based on user's screenshot
  // Utiliser les vraies couleurs de AppColors
  Color get bgColor => AppColors.background;
  Color get cardColor => AppColors.surface;
  Color get primaryMint => AppColors.primary;
  Color get mutedText => AppColors.textSecondary;
  Color get inputBorder => AppColors.border;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Bus Icon
              Icon(Icons.directions_bus, size: 56, color: primaryMint),
              const SizedBox(height: 16),
              
              // App Title
              const Text(
                'GuinéeTransport',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Créez votre compte passager',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),

              // Register Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: inputBorder.withValues(alpha: 0.5), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INSCRIPTION',
                      style: TextStyle(
                        color: primaryMint,
                        letterSpacing: 2,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name Input
                    _buildInputField(
                      label: 'NOM COMPLET',
                      controller: _nameController,
                      hint: 'Prénom & Nom',
                      iconData: Icons.person_outline,
                    ),
                    const SizedBox(height: 24),

                    // Phone Input
                    _buildInputField(
                      label: 'TÉLÉPHONE',
                      controller: _phoneController,
                      hint: '62X... / 66X...',
                      iconData: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    // Email Input
                    _buildInputField(
                      label: 'ADRESSE E-MAIL',
                      controller: _emailController,
                      hint: 'exemple@mail.gn',
                      iconText: '@',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    // Password Input
                    _buildInputField(
                      label: 'MOT DE PASSE',
                      controller: _passwordController,
                      hint: '••••••••',
                      iconData: Icons.lock_outline_rounded,
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    const SizedBox(height: 24),

                    // Confirm Password Input
                    _buildInputField(
                      label: 'CONFIRMER LE MOT DE PASSE',
                      controller: _confirmPasswordController,
                      hint: '••••••••',
                      iconData: Icons.lock_reset_rounded,
                      isPassword: true,
                      obscureText: !_isConfirmPasswordVisible,
                      onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                    const SizedBox(height: 32),

                    // Terms Checkbox
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _acceptTerms,
                            onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                            activeColor: primaryMint,
                            checkColor: bgColor,
                            side: BorderSide(color: mutedText),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "J'accepte les ",
                              style: TextStyle(color: mutedText, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: "Conditions d'utilisation",
                                  style: TextStyle(color: primaryMint, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryMint,
                          foregroundColor: bgColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: bgColor, strokeWidth: 2),
                              )
                            : const Text(
                                "S'INSCRIRE",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Already have an account
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Redirection directe vers LoginPage en vidant l'historique
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                            (route) => false,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: "Vous avez déjà un compte ? ",
                            style: TextStyle(color: mutedText, fontSize: 13),
                            children: [
                              TextSpan(
                                text: "Connexion",
                                style: TextStyle(
                                  color: primaryMint,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? iconText,
    IconData? iconData,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: mutedText,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: (iconData != null || iconText != null) ? primaryMint : Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: inputBorder, fontSize: 16),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: iconText != null
                  ? Text(
                      iconText,
                      style: TextStyle(color: mutedText, fontSize: 20),
                      textAlign: TextAlign.center,
                    )
                  : Icon(iconData, color: mutedText, size: 20),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined,
                      color: mutedText,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: inputBorder, width: 1.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryMint, width: 2),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les conditions d\'utilisation')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nom est obligatoire')));
      return;
    }

    final phoneError = AuthService.validatePhone(phone);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(phoneError)));
      return;
    }

    final emailError = AuthService.validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe doit contenir au moins 6 caractères')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.signUp(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
        roleKey: 'passenger',
        metadata: {
          'emergency_name': _emergencyNameController.text.trim(),
          'emergency_phone': _emergencyPhoneController.text.trim(),
        },
      );

      if (!mounted) return;

      SuccessDialog.show(
        context: context,
        title: "Bienvenue à bord !",
        message: "Votre compte passager a été créé avec succès. Vous pouvez maintenant vous connecter pour réserver vos trajets.",
        buttonText: "SE CONNECTER",
        onButtonPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().contains('user_already_exists')
          ? 'Ce compte existe déjà. Veuillez vous connecter.'
          : 'Erreur : ${e.toString().replaceAll('AuthException: ', '').replaceAll('Exception: ', '')}';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
