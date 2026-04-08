import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _error = 'New passwords do not match');
      return;
    }

    // Enforce strong password: at least 8 chars, 1 uppercase letter, 1 digit
    final hasUppercase = newPassword.contains(RegExp(r'[A-Z]'));
    final hasDigit     = newPassword.contains(RegExp(r'[0-9]'));
    if (newPassword.length < 8 || !hasUppercase || !hasDigit) {
      setState(() => _error = 'Password must be at least 8 characters and include a capital letter and a number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);
        setState(() {
          _success = 'Password updated successfully';
          _currentPasswordCtrl.clear();
          _newPasswordCtrl.clear();
          _confirmPasswordCtrl.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'An error occurred updating password');
    } catch (e) {
      setState(() => _error = e.toString());
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
          'Change Password',
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.goldLight,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(_error!, style: const TextStyle(color: AppColors.red)),
              ),
            if (_success != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(_success!, style: const TextStyle(color: AppColors.green)),
              ),
            _buildTextField(_currentPasswordCtrl, 'Current Password', obscure: true),
            const SizedBox(height: 16),
            _buildTextField(_newPasswordCtrl, 'New Password', obscure: true),
            const SizedBox(height: 16),
            _buildTextField(_confirmPasswordCtrl, 'Confirm New Password', obscure: true),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _isLoading ? null : _changePassword,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.black))
                      : Text(
                          'UPDATE PASSWORD',
                          style: GoogleFonts.dmSans(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldBorder),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.whiteDim),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
