import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/theme/app_colors.dart';
import 'role_selection_page.dart';

class LoginPage extends StatefulWidget {
  final String? initialRole;
  const LoginPage({super.key, this.initialRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isBiometricAvailable = false;

  // New Theme Colors based on user's screenshot
  // Utiliser les vraies couleurs de AppColors
  Color get bgColor => AppColors.background;
  Color get cardColor => AppColors.surface;
  Color get primaryMint => AppColors.primary;
  Color get mutedText => AppColors.textSecondary;
  Color get inputBorder => AppColors.border;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = available && enabled;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authenticated = await BiometricService.authenticate();
    if (!authenticated) return;

    final credentials = await BiometricService.getStoredCredentials();
    if (credentials == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun identifiant stocké pour la biométrie. Veuillez vous connecter manuellement une fois.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.signIn(
        email: credentials['email']!,
        password: credentials['password']!,
      );
      
      if (!mounted) return;

      if (!response.isSuccess || response.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Colors.orange),
        );
        return;
      }

      final profile = response.data!;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => NavigationService.getDashboardForRole(
            profile.appRole,
            profile: profile,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'authentification: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                'Votre voyage commence ici',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),

              // Login Card
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
                      'CONNEXION',
                      style: TextStyle(
                        color: primaryMint,
                        letterSpacing: 2,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

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
                    const SizedBox(height: 16),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Forgot password logic
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(color: mutedText, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                                'CONTINUER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Inscription Link (Highly Visible)
                    Column(
                      children: [
                        Text(
                          "Nouveau sur GuinéeTransport ?",
                          style: TextStyle(color: mutedText, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryMint, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "CRÉER UN COMPTE",
                              style: TextStyle(
                                color: primaryMint,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Biometric fingerprint icon
              if (_isBiometricAvailable)
                GestureDetector(
                  onTap: _handleBiometricLogin,
                  child: Icon(Icons.fingerprint, size: 48, color: mutedText),
                ),
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

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

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

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.signIn(email: email, password: password);
      if (!mounted) return;

      if (!response.isSuccess || response.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Colors.orange),
        );
        return;
      }

      final profile = response.data!;
      
      // Save credentials for biometric login if enabled
      if (await BiometricService.isBiometricEnabled()) {
        await BiometricService.saveCredentials(email, password);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => NavigationService.getDashboardForRole(
            profile.appRole,
            profile: profile,
          ),
        ),
        (route) => false,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('Invalid login credentials')) {
        errorMsg = 'Email ou mot de passe incorrect.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
