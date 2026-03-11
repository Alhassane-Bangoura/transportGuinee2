import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/navigation_service.dart';
import '../onboarding/onboarding_screen.dart';

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

  static const Color primaryColor = Color(0xFF102216);
  static const Color accentColor = Color(0xFF13EC5B);
  static const Color backgroundColor = Color(0xFFF6F8F6);
  static const Color textSlate900 = Color(0xFF0F172A);
  static const Color textSlate500 = Color(0xFF64748B);
  static const Color textSlate400 = Color(0xFF94A3B8);
  static const Color borderSlate200 = Color(0xFFE2E8F0);

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Connexion',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20), // Placeholder for symmetry
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Logo / Brand Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: primaryColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'GuineeTransport',
                        style: GoogleFonts.plusJakartaSans(
                          color: primaryColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Le futur du transport interurbain',
                        style: GoogleFonts.plusJakartaSans(
                          color: textSlate500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                const SizedBox(height: 32),

                const SizedBox(height: 32),

                // Email Field

                // Email Field
                _buildFieldLabel('E-mail'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hint: 'exemple@guinee.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 24),

                // Password Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel('Mot de passe'),
                    Text(
                      'Oublié ?',
                      style: GoogleFonts.plusJakartaSans(
                        color: accentColor.withValues(alpha: 0.8) == accentColor
                            ? accentColor
                            : const Color(
                                0xFF10B981), // Fallback if accent is too light
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: !_isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Login Button
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;

                            final emailError = AuthService.validateEmail(email);
                            if (emailError != null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(emailError)),
                              );
                              return;
                            }

                            if (password.length < 6) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Le mot de passe doit contenir au moins 6 caractères'),
                                ),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);

                            try {
                              debugPrint('[LOGIN] Tentative de connexion : $email');
                              final profile = await AuthService.signIn(
                                email: email,
                                password: password,
                              );

                              debugPrint('[LOGIN] Résultat signIn : ${profile?.appRole}');

                              if (!context.mounted) return;

                              if (profile == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Connexion réussie mais profil introuvable. Contactez le support.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              debugPrint('[LOGIN] Navigation vers dashboard : ${profile.appRole}');
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NavigationService.getDashboardForRole(
                                    profile.appRole,
                                    profile: profile,
                                  ),
                                ),
                                (route) => false,
                              );
                            } on Exception catch (e) {
                              debugPrint('[LOGIN] Exception capturée : $e');
                              if (!context.mounted) return;
                              String errorMsg = e.toString();
                              if (errorMsg.contains('Invalid login credentials') ||
                                  errorMsg.contains('invalid_credentials')) {
                                errorMsg = 'Email ou mot de passe incorrect.';
                              } else if (errorMsg.contains('Email not confirmed')) {
                                errorMsg = 'Veuillez confirmer votre email avant de vous connecter.';
                              } else if (errorMsg.contains('trop de temps') ||
                                  errorMsg.contains('TimeoutException')) {
                                errorMsg = 'Connexion trop lente. Vérifiez votre réseau.';
                              } else {
                                errorMsg = errorMsg
                                    .replaceAll('AuthException: ', '')
                                    .replaceAll('Exception: ', '')
                                    .replaceAll('ClientException: ', '');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            } finally {
                              // Toujours remettre le loading à false, même en cas d'erreur
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          )
                        : Text(
                            'Se connecter',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: borderSlate200, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: GoogleFonts.plusJakartaSans(
                          color: textSlate400,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: borderSlate200, thickness: 1)),
                  ],
                ),

                const SizedBox(height: 24),

                // Social Login
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: borderSlate200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuC7GD-jqdpcRr88zQ6W8ooZxucMIeqV1bctszqJQNZ_5OrHP0jS1CFEqWTTsqalZLF_aukrf5ifSkZpczkkI3MXI6hHVVnvXvl4ng0XQGIeRn_YohDaDPcgzFNQ_d9voAOfaVoV2yGWPb_N_rNMYijL_u2wC31Xq-ilTRBdTEj1swhLElYfR-FJYGMZEHflgc6_v1shwSmEusVy27plWz_ma_DqZmcXBejIIoB9mJghqkYBunLgF2Fsl3SQQ83dDEA5Xaf-hl06M1Jg',
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continuer avec Google',
                        style: GoogleFonts.plusJakartaSans(
                          color: textSlate900,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Bottom Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas de compte ? ",
                      style: GoogleFonts.plusJakartaSans(
                        color: textSlate500,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Créer un compte",
                        style: GoogleFonts.plusJakartaSans(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Bottom Illustration Decoration
                Opacity(
                  opacity: 0.1,
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            primaryColor.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                        border: const Border(
                          top: BorderSide(color: borderSlate200),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 48,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        color: textSlate900,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSlate200),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(color: textSlate900),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: textSlate400),
          prefixIcon: Icon(prefixIcon, color: textSlate400, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: textSlate400,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
