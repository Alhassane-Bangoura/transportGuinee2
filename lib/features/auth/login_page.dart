import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  
  bool _rememberMe = false;
  final _storage = const FlutterSecureStorage();

  Color get bgColor => AppColors.background;
  Color get cardColor => AppColors.surface;
  Color get primaryMint => AppColors.primary;
  Color get mutedText => AppColors.textSecondary;
  Color get inputBorder => AppColors.border;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedEmail = await _storage.read(key: 'remember_email');
    final savedPassword = await _storage.read(key: 'remember_password');
    
    if (savedEmail != null && savedPassword != null) {
      if (mounted) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _rememberMe = true;
        });
      }
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isBiometricEnabled();
    if (mounted) setState(() => _isBiometricAvailable = available && enabled);
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bus, size: 56, color: primaryMint),
                  const SizedBox(height: 16),
                  const Text('GuinéeTransport', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text('Votre voyage commence ici', style: TextStyle(color: mutedText, fontSize: 16)),
                  const SizedBox(height: 48),
                  
                  // Login Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: inputBorder.withOpacity(0.5), width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CONNEXION', style: TextStyle(color: primaryMint, letterSpacing: 2, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 32),
                        _buildInputField(label: 'ADRESSE E-MAIL', controller: _emailController, hint: 'exemple@mail.gn', iconText: '@', keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 24),
                        _buildInputField(label: 'MOT DE PASSE', controller: _passwordController, hint: '••••••••', iconData: Icons.lock_outline_rounded, isPassword: true, obscureText: !_isPasswordVisible, onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                          activeColor: primaryMint,
                                          checkColor: Colors.white,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          side: BorderSide(color: inputBorder.withOpacity(0.5), width: 1.5),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Se souvenir de moi', 
                                          style: TextStyle(color: mutedText.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Logic for forgot password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Fonctionnalité bientôt disponible'))
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: primaryMint,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Mot de passe oublié ?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        _buildLoginButton(),
                        const SizedBox(height: 24),
                        const Divider(height: 32),
                        const SizedBox(height: 8),
                        _buildRegistrationLink(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  if (_isBiometricAvailable) GestureDetector(onTap: _handleBiometricLogin, child: Icon(Icons.fingerprint, size: 48, color: mutedText.withOpacity(0.5))),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(backgroundColor: primaryMint, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
        child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('CONTINUER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildRegistrationLink() {
    return Column(
      children: [
        Text("Nouveau sur GuinéeTransport ?", style: TextStyle(color: mutedText, fontSize: 14)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RoleSelectionPage())),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryMint, width: 1.5), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: Text("CRÉER UN COMPTE", style: TextStyle(color: primaryMint, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String hint, String? iconText, IconData? iconData, bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(label, style: TextStyle(color: mutedText.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background, 
            borderRadius: BorderRadius.circular(28), 
            border: Border.all(color: inputBorder.withOpacity(0.8), width: 1.5),
            boxShadow: [BoxShadow(color: primaryMint.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
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
                decoration: BoxDecoration(color: primaryMint.withOpacity(0.05), shape: BoxShape.circle),
                child: iconText != null ? Text(iconText, style: TextStyle(color: primaryMint, fontSize: 16, fontWeight: FontWeight.w900), textAlign: TextAlign.center) : Icon(iconData, color: primaryMint, size: 18),
              ),
              suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: mutedText.withOpacity(0.4), size: 20), onPressed: onToggleVisibility) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await AuthService.signIn(email: email, password: password);
      if (!mounted) return;
      if (!response.isSuccess || response.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message), backgroundColor: Colors.orange));
        return;
      }

      if (_rememberMe) {
        await _storage.write(key: 'remember_email', value: email);
        await _storage.write(key: 'remember_password', value: password);
      } else {
        await _storage.delete(key: 'remember_email');
        await _storage.delete(key: 'remember_password');
      }

      if (await BiometricService.isBiometricEnabled()) await BiometricService.saveCredentials(email, password);
      final profile = response.data!;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => NavigationService.getDashboardForRole(profile.appRole, profile: profile)), (route) => false);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authenticated = await BiometricService.authenticate();
    if (!authenticated) return;
    final credentials = await BiometricService.getStoredCredentials();
    if (credentials == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await AuthService.signIn(email: credentials['email']!, password: credentials['password']!);
      if (!mounted || !response.isSuccess || response.data == null) return;
      final profile = response.data!;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => NavigationService.getDashboardForRole(profile.appRole, profile: profile)), (route) => false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
