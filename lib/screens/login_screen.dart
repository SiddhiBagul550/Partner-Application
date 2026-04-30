import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/vendor_service.dart';
import '../services/logger_service.dart';
import 'forgot_password_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Rate-limiting constants ────────────────────────────────────────────────────
const int _kMaxAttempts = 5;
const Duration _kLockoutDuration = Duration(minutes: 15);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _isLoading    = false;
  String? _error;

  // Local rate-limit state
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _isLockedOut {
    if (_lockedUntil == null) return false;
    return DateTime.now().isBefore(_lockedUntil!);
  }

  String get _lockoutMessage {
    if (_lockedUntil == null) return '';
    final remaining = _lockedUntil!.difference(DateTime.now());
    final minutes   = remaining.inMinutes + 1;
    return 'Too many failed attempts. Try again in $minutes minute(s).';
  }

  Future<void> _login() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password.');
      return;
    }

    // ── Rate-limit check ────────────────────────────────────────────────────
    if (_isLockedOut) {
      setState(() => _error = _lockoutMessage);
      return;
    }

    setState(() {
      _isLoading = true;
      _error     = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      // ── Email-verification gate ─────────────────────────────────────────
      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _error = 'Please verify your email before signing in.\n'
                   'Check your inbox for a verification link.';
          _isLoading = false;
        });
        return;
      }

      // ── Vendor-approval check ────────────────────────────────────────────
      final vendor = await VendorService().getVendorByEmail(email);
      if (vendor == null || vendor.status != 'approved') {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _isLoading = false;
          if (vendor == null) {
            _error = 'Account not found.';
          } else if (vendor.status == 'suspended') {
            _error = 'Your account has been suspended.';
          } else if (vendor.status == 'rejected') {
            _error = 'Your vendor application was denied.';
          } else {
            _error = 'Your application is not approved yet.';
          }
        });
        return;
      }

      // ── Success: reset counters, MainScaffold handles navigation ─────────
      _failedAttempts = 0;
      _lockedUntil    = null;

    } on FirebaseAuthException catch (e) {
      _failedAttempts++;
      if (_failedAttempts >= _kMaxAttempts) {
        _lockedUntil    = DateTime.now().add(_kLockoutDuration);
        _failedAttempts = 0;
        LoggerService().logAuthFailure(email, 'Rate limit triggered');
        setState(() => _error = _lockoutMessage);
      } else {
        LoggerService().logAuthFailure(email, e.code);
        setState(() => _error = _mapFirebaseError(e.code));
      }
    } catch (e) {
      LoggerService().logAuthFailure(email, e.toString());
      setState(() => _error = 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait and try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'Partner Portal',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldLight,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in using the credentials sent to your email.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.whiteDim,
                ),
              ),
              const SizedBox(height: 40),

              // Error banner
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    border: Border.all(color: AppColors.red.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email Field
              _buildTextField(
                controller: _emailCtrl,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                autofillHint: AutofillHints.email,
              ),
              const SizedBox(height: 16),

              // Password Field
              _buildTextField(
                controller: _passwordCtrl,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
                autofillHint: AutofillHints.password,
              ),
              const SizedBox(height: 12),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.dmSans(
                      color: AppColors.gold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              GestureDetector(
                onTap: _isLoading ? null : _login,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldGlow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'SIGN IN',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Registration Prompt
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.black3,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Not a partner yet?',
                      style: GoogleFonts.dmSans(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can login into the app only after getting approval from the admin via the vendor application.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        color: AppColors.whiteDim,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final Uri url = Uri.parse('https://partners.fliqaindia.com/vendor/apply');
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          debugPrint('Could not launch \$url');
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: AppColors.gold.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: AppColors.gold.withOpacity(0.5)),
                        ),
                      ),
                      child: Text(
                        'Apply Now',
                        style: GoogleFonts.dmSans(
                          color: AppColors.goldLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? autofillHint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofillHints: autofillHint != null ? [autofillHint] : null,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: AppColors.whiteDim),
          prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
