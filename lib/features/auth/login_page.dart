import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/navigation_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/biometric_service.dart';
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
      final profile = await AuthService.signIn(
        email: credentials['email']!,
        password: credentials['password']!,
      );
      
      if (!mounted) return;

      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil introuvable.'), backgroundColor: Colors.orange),
        );
        return;
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
      backgroundColor: AppColors.premiumDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // Logo/Icon placeholder (Spotify style)
              const Center(
                child: Icon(
                  Icons.directions_bus_filled_rounded,
                  color: AppColors.success,
                  size: 60,
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'Se connecter',
                style: AppTextStyles.headingLarge.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Si vous avez besoin d\'aide, Cliquez ici',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                ),
              ),

              const SizedBox(height: 48),

              // Form
              _buildInputField(
                label: 'Email ou nom d\'utilisateur',
                controller: _emailController,
                hint: 'Entrez votre email',
                icon: Icons.person_outline_rounded,
              ),
              
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Mot de passe',
                controller: _passwordController,
                hint: 'Mot de passe',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: !_isPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Récupérer le mot de passe',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.premiumGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Se connecter',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
              
              const Text(
                'Ou',
                style: TextStyle(color: AppColors.premiumGrey, fontSize: 14),
              ),
              
              const SizedBox(height: 24),

              // Social Logins
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(icon: Icons.g_mobiledata_rounded, color: Colors.red),
                  const SizedBox(width: 40),
                  _socialButton(icon: Icons.apple_rounded, color: Colors.white),
                ],
              ),

              const SizedBox(height: 48),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pas encore de compte ? ',
                    style: TextStyle(color: AppColors.premiumGrey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                      );
                    },
                    child: const Text(
                      'S\'inscrire ici',
                      style: TextStyle(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.premiumSteel),
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.premiumNavy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.premiumSteel),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.premiumMutedBlue),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.premiumGrey,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
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
      final profile = await AuthService.signIn(email: email, password: password);
      if (!mounted) return;

      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil introuvable.'), backgroundColor: Colors.orange),
        );
        return;
      }

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
