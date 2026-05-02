import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
  
  File? _profileImage;

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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryMint),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryMint),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Erreur image picker: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
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
                  color: AppColors.textPrimary,
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
                  border: Border.all(color: inputBorder.withOpacity(0.5), width: 1),
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

                    // Image Picker Avatar
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: primaryMint.withOpacity(0.1),
                              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                              child: _profileImage == null
                                  ? Icon(Icons.person, size: 50, color: primaryMint)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: inputBorder),
                                ),
                                child: Icon(Icons.camera_alt, color: primaryMint, size: 20),
                              ),
                            ),
                          ],
                        ),
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
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: mutedText.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: inputBorder.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryMint.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            cursorColor: primaryMint,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textHint.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w500),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryMint.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: iconText != null
                    ? Text(
                        iconText,
                        style: TextStyle(color: primaryMint, fontSize: 16, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      )
                    : Icon(iconData, color: primaryMint, size: 18),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: mutedText.withOpacity(0.4),
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              isDense: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
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
          if (_profileImage != null) 'local_profile_image_path': _profileImage!.path,
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
