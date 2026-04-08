import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading  = false;
  bool _sent       = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    // Basic email format check
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error     = null;
    });

    try {
      // Call our backend API which uses Resend to send the email from the real domain
      final response = await http.post(
        Uri.parse('http://localhost:3005/api/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        setState(() => _sent = true);
      } else {
        debugPrint('[ForgotPassword] API Error: ${response.statusCode} - ${response.body}');
        setState(() => _error = 'Failed to send reset email. Please try again.');
      }
    } catch (e) {
      debugPrint('[ForgotPassword] Unexpected error: $e');
      setState(() => _error = 'Something went wrong. Please check your connection and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.gold),
        title: Text(
          'Reset Password',
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.goldLight,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('📬', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 20),
        Text(
          'Check Your Inbox',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'If an account exists for ${_emailCtrl.text.trim()}, '
          'a password reset link has been sent.\n\nThe link expires in 1 hour.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.whiteDim,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'BACK TO LOGIN',
              style: GoogleFonts.dmSans(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter the email address linked to your account and '
          'we will send you a secure reset link.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.whiteDim,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Error
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
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
        ],

        // Email field
        Container(
          decoration: BoxDecoration(
            color: AppColors.black3,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldBorder),
          ),
          child: TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Email Address',
              hintStyle: TextStyle(color: AppColors.whiteDim),
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.gold, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Submit button
        GestureDetector(
          onTap: _isLoading ? null : _sendReset,
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
                      'SEND RESET LINK',
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
      ],
    );
  }
}
